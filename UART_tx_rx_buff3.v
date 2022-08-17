//module UART_tx_rx_buff2(clk, nrst, rx, tx, rx2, tx2);
module UART_tx_rx_buff2(clk, nrst, rx, tx, ready, data_store, bit_count, bit_count2, byte_count, byte_count2, busy, busy2, idle, bit_count3, data_store2, busy1, count);
	input clk;
	input nrst;
	input rx;
	output tx;
	//output rx2;
	//output tx2;
	output ready;
	output [9:0] data_store;
	output [9:0] bit_count;
	output [3:0] bit_count2;
	output [3:0] byte_count;
	output [3:0] byte_count2;
	output busy;
	output busy2;
	output idle;
	output [4:0] bit_count3;
	output [31:0] data_store2;
	output busy1;
	output [19:0] count;
	//assign rx2 = rx;
	//assign tx2 = tx;
	parameter baud = 9600; // 1/9600 = 104.1667 us
	//parameter baud = 2400; // 1/2400 = 416.6667 us
	//parameter baud = 600;	// 1/600 = 1666.6667 us
	//parameter baud = 110;	// 1/110 = 9090.9091 us
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = (freq/baud);
	parameter lim2 = 45;
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [19:0] count = 11'd0; //clk_div
	reg [19:0] count2 = 11'd0;
	reg [19:0] count3 = 11'd0;
	reg [9:0] bit_count = 10'd0; //req. 10 bit per frame so, it has 4 bit
	reg [3:0] bit_count2 = 4'b0000;
	reg [4:0] bit_count3 = 5'b00000;
	reg [3:0] byte_count = 0;
	reg [3:0] byte_count2 = 0;
	reg [3:0] byte_count4 = 0;
	reg [9:0] data_store = 10'b0;
	reg [31:0] data_store2 = 32'b0;
	reg [31:0] data_store3 = 32'b0;
	reg busy1 = 0;
	reg busy2 = 0;
	reg idle = 0;
	reg ready=0;
	reg tx_read=1;
	reg tx; 
	parameter i=0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	always @(posedge clk or negedge nrst)
		begin
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE I: RECEIVING PART... 
			if(!nrst || busy)begin
				count <= 20'b0;
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
						count2 <= count2 + 20'b1;
					end
					else begin
						count2 <= 20'b0;
						if(bit_count2==4'd8)begin /// it means the 8-bit data already stored... idle signal ends 
							bit_count2 <= 0;
							idle <= ~idle;
						end
						else begin
							bit_count2 <= bit_count2 +1;
						end
					end	
				end
				else begin
					count <= 20'b0;
					bit_count2 <= 0;
				end
				/////////////////////////////////////////////////////////////////////////////////////////////// 1c. STORING DATA...
				if(count!=lim-1)begin
					count <= count + 1;
				end
				else begin
					count <= 20'b0;
					data_store <= data_store << 1 | {9'b000000000, rx}; 			///keep storeing...
					if(bit_count==8)begin											///save to data_store 2.... 
						if(byte_count==1)begin
							data_store2 <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==2)begin
							data_store2 <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[7:0]};
						end
						else if(byte_count==3)begin
							data_store2 <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[15:0]};
						end
						else if(byte_count==4)begin
							data_store2 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[23:0]};
						end
						else if(byte_count==5)begin
							data_store3 <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==6)begin
							data_store3 <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
						end
						else if(byte_count==7)begin
							data_store3 <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[15:0]};
						end
						else if(byte_count==8)begin
							data_store3 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[23:0]};
						end
						else begin
							data_store2 <= data_store2;
							data_store3 <= data_store3;
						end
					end
					else begin
						data_store2 <= data_store2;
					end
					if(ready)begin 		///// no data entering....
						bit_count <= 0;
						idle <= ~idle;		///// idle signal will start..
						byte_count <= byte_count + 1;
					end
					else begin
						if(bit_count!=lim2)begin     //just to limit the counter if no start bit detected...
							bit_count <= bit_count + 1;
						end
						else begin
							bit_count <= 0; // stop counting when no start bit detected...
							busy1 <= ~busy1;
							byte_count2 <= 0;
							//yte_count <= 0;
						end
					end
				end
			end
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE II: TRANSMITING PART....
			if(!nrst || !busy)begin
				bit_count3 <= 0;
				count3 <= 20'b0;
				tx <= 1;
			end
			else if(byte_count2==byte_count)begin
				busy2 <= ~busy2;
				bit_count3 <= 0;
				count3 <= 20'b0;
				//byte_count2 <= 0;
				byte_count <= 0;
			end
			else begin
				if(count3!=lim-1)begin
					count3 <= count3 +20'b1;
				end
				else begin
					count3 <= 20'b0;
					if(bit_count3!=5'd19)begin ////////////////////////////////////////////////////////// 2a. ADD 10-BIT SPACER FOR RX
						bit_count3 <= bit_count3 + 5'b1;
						if(bit_count3<=8)begin
							if(bit_count3==0)begin
								tx<=0;
								//data_store2 <= 32'hffff;
							end
							else begin
								if(byte_count2<=3) begin
									tx <= data_store2[0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2 <= data_store2 >> 1;
								end
								else begin
									tx <= data_store3[0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store3 <= data_store3 >> 1;
								end
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

	assign busy = (busy1 ^ busy2);
	
/////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
