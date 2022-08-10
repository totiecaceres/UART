//module UART_tx_rx(clk, nrst, rx, tx, rx2, tx2);
module UART_tx_rx_buff(clk, nrst, rx, tx, ready, data_store, bit_count, bit_count2, byte_count, busy, busy2, idle, bit_count3, data_store2, busy1);
	input clk;
	input nrst;
	input rx;
	output tx;
	//output rx2;
	//output tx2;
	output ready;
	output [9:0] data_store;
	output [3:0] bit_count;
	output [3:0] bit_count2;
	output [3:0] byte_count;
	output busy;
	output busy2;
	output idle;
	output [4:0] bit_count3;
	output [31:0] data_store2 = 32'b0;
	output busy1;
	//assign rx2 = rx;
	//assign tx2 = tx;
	parameter baud = 9600; //1/9600 = 104.1667 us
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = (freq/baud);
	parameter byte_size = 4;
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [10:0] count = 11'd0; //clk_div
	reg [10:0] count2 = 11'd0;
	reg [10:0] count3 = 11'd0;
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg [3:0] bit_count2 = 4'b0000;
	reg [4:0] bit_count3 = 5'b00000;
	reg [3:0] byte_count = 0;
	reg [3:0] byte_count2 = 0;
	reg [9:0] data_store = 10'b0;
	reg [31:0] data_store2 = 32'b0;
	reg busy1 = 0;
	reg busy2 = 0;
	reg idle = 0;
	reg ready=0;
	reg tx_read=1;
	reg tx; 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	always @(posedge clk or negedge nrst)
		begin
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE I: RECEIVING PART... 
			if(!nrst || busy)begin
				count <= 11'b0;
				bit_count <= 0;
				bit_count2 <= 0;
				data_store <= 10'b1111111111;
			end
			else begin
				////////////////////////////////////////////////////////////////////////////////////////////// 1a. START BIT DETECTOR..
				if(!nrst)begin
					tx_read <= 1;
				end
				else begin
					if(data_store!=10'b1111111111)begin
						tx_read <= 0;
					end
					else begin
						tx_read <= 1;
					end
					ready <= tx_read && !rx;
				end
				/////////////////////////////////////////////////////////////////////////////////////////////// 1b. [GENERATE IDLE STATE FOR TX]..
				if(idle==1)begin
					if(count2!=lim-1)begin
						count2 <= count2 + 11'b1;
					end
					else begin
						count2 <= 11'b0;
						if(bit_count2==4'd8)begin
							bit_count2 <= 0;
							idle <= ~idle;
						end
						else begin
							bit_count2 <= bit_count2 +1;
						end
					end	
				end
				else begin
					count <= 11'b0;
					bit_count2 <= 0;
				end
				/////////////////////////////////////////////////////////////////////////////////////////////// 1c. STORING DATA...
				if(count!=lim-1)begin
					count <= count + 1;
				end
				else begin
					count <= 11'b0;
					data_store <= data_store << 1 | {9'b000000000, rx};
					if(bit_count==8)begin
						data_store2 <= data_store2 << 8 | {24'd0,data_store[7:0]}; 
					end
					if(ready)begin
						bit_count <= 0;
						idle <= ~idle;
					end
					else begin
						if(bit_count!=15)begin
							bit_count <= bit_count + 1;
						end
						else begin
							bit_count <= bit_count;
						end
					end
				end
			end
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE II: TRANSMITING PART....
			if(!nrst || !busy)begin
				bit_count3 <= 0;
				count3 <= 11'b0;
				tx <= 1;
			end
			else if(byte_count2==byte_size)begin
				busy2 <= ~busy2;
				bit_count3 <= 0;
				count3 <= 11'b0;
				byte_count2 <= 0;
			end
			else begin
				if(count3!=lim-1)begin
					count3 <= count3 +11'b1;
				end
				else begin
					count3 <= 11'b0;
					if(bit_count3!=5'd19)begin ////////////////////////////////////////////////////////// 2a. ADD 10-BIT SPACER FOR RX
						bit_count3 <= bit_count3 + 5'b1;
						if(bit_count3<=8)begin
							if(bit_count3==0)begin
								tx<=0;
							end
							else begin
								tx <= data_store2[31]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
								data_store2 <= data_store2 << 1 | 32'd1;
							end
						end
						else begin
							tx <= 1;
						end
					end
					else begin
						bit_count3 <= 0;
						byte_count2 <= byte_count2 + 1;
					end
				end
			end
		end
/////////////////////////////////////////////////////////////////////////////////////////////////	TRANSMIT STATE SIGNAL...
	assign busy = (busy1 ^ busy2);
	always@(negedge idle or negedge nrst)begin
		if(!nrst || busy)begin
			byte_count <= 0;
		end
		else begin
			if(byte_count==byte_size-1)begin
				byte_count <= 0;
				busy1 <= ~busy1;
			end
			else begin
				byte_count <= byte_count + 1;
			end
		end
	end
/////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
