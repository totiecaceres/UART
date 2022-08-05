module initial_try10(clk, nrst, rx, ready, tx, data_store, bit_count, byte_count, busy, idle, done, signal, bit_count3, data_store2);
//module initial_try10(clk, nrst, rx, tx, busy);
	input clk;
	input nrst;
	input rx;
	output ready;
	output tx;
	output [9:0] data_store;
	output [7:0] bit_count;
	output [13:0] byte_count;
	output busy;
	output idle;
	output done;
	output signal;
	output [7:0] bit_count3;
	output [31:0] data_store2;
	
	parameter baud = 9600;
	parameter freq = 12000000;
	parameter lim = (freq/baud);
	
	initial_tx 	transmit(clk, nrst, rx, tx, bit_count, byte_count, busy, idle, done, signal, data_store, ready, bit_count3, data_store2);
	//initial_tx 	transmit(clk, nrst, rx, tx, busy);
	//initial_rx 	recieve(clk, nrst, data, tx_read, ready, data_store);
	
endmodule

module initial_tx(clk, nrst, rx, tx, bit_count, byte_count, busy, idle, done, signal, data_store, ready, bit_count3, data_store2);
//module initial_tx(clk, nrst, rx, tx, busy);
	input clk;
	input nrst;
	input rx;
	//output tx_read;
	output tx;
	//output [10:0] count;
	output [7:0] bit_count;
	output [13:0] byte_count;
	output busy;
	output idle;
	output done;
	output signal;
	output ready;
	output [9:0] data_store;
	output [7:0] bit_count3;
	output [31:0] data_store2 = 32'b0;
	reg [9:0] data_store = 10'b0;
	reg [31:0] data_store2 = 31'b0;
	
	//reg [31:0] data = {8'h53,8'h6E,8'h61,8'h70};
	//assign data = data_in;
	parameter baud = 9600; //1/9600 = 104.1667 us
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = (freq/baud);
	parameter byte_size = 4;
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [10:0] count = 11'd0; //clk_div
	reg [7:0] bit_count = 8'b00000000; //req. 10 bit per frame so, it has 4 bit
	reg [13:0] byte_count = 14'd0;
	reg [3:0] byte_count2 = 4'd0;
	reg [7:0] bit_count3 = 8'd0;
	reg busy = 0;
	reg idle = 0;
	reg tx; 
	//reg data;
	reg [1:0] state = 0;
	reg done = 0;
	reg signal;
	reg tx_read=1;
	reg ready=0;
	reg [10:0] count2 = 11'd0;
	reg [3:0] bit_count2 = 4'b0000;
	reg [10:0] count3 = 11'd0;
	
/////////////////////////////////////////////////////////////////////////////////////////////////
	always @(negedge ready or negedge nrst)begin
		if(!nrst)begin
			signal <= 1'b0;
		end
		else begin
			signal <= ~signal;
		end
	end
/////////////////////////////////////////////////////////////////////////////////////////////////	
	always@(negedge signal)begin
		if(!nrst || busy)begin
			byte_count <= 1'b0;
		end
		else begin
			if(byte_count==byte_size-1)begin
				busy <= ~busy;
				byte_count <= 14'd0;
			end
			else begin
				byte_count <= byte_count + 14'd1;
			end
		end
	end
/////////////////////////////////////////////////////////////////////////////////////////////////
	always@(posedge clk or negedge nrst)begin
		if(!nrst || busy || !signal)begin
			count2 <= 11'b0;
			bit_count2 <= 4'd0;
			signal <= 1'b0;
		end
		else begin
			if(count2!=lim-1)begin
				count2 <= count2 + 11'd1;
			end
			else begin
				if(bit_count2!=4'd8)begin
					count2 <= 11'd0;
					bit_count2 <= bit_count2 + 4'd1;
				end
				else begin
					bit_count2 <= 4'd0;
					signal <= 1'b0;
				end
			end	
		end
	end
/////////////////////////////////////////////////////////////////////////////////////////////////	
	always @(posedge ready or negedge nrst)begin
		bit_count <= 1'b0;
	end
/////////////////////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk or negedge nrst or posedge ready)begin
		bit_count <= 1'b0;
		if(!nrst || busy)begin
			bit_count <= 8'd0;
			count <= 11'b0;
			data_store <= 10'b1111111111;
		end
		else begin
			if(count!=lim-1)begin
				count <= count +11'b1;
			end
			else begin
				count <= 11'b0;
				data_store <= data_store << 1'b1 | {10'd0, rx};
				bit_count <= bit_count + 8'd1;
				if(bit_count==9)begin
					data_store2 <= data_store2 << 8 | {24'd0,data_store[7:0]}; 
				end
				else begin
					data_store2 <= data_store2;
				end
			end
		end
	end
/////////////////////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk or negedge nrst)begin
		if(!nrst)begin
			tx_read <= 1'b1;
		end
		else begin
			if(data_store!=10'b1111111111)begin
				tx_read <= 1'b0;
			end
			else begin
				tx_read <= 1'b1;
			end
			ready <= tx_read && !rx;
		end
	end
/////////////////////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk or negedge nrst)
		begin
			if(!nrst || !busy)begin
				bit_count3 <= 8'd0;
				count3 <= 11'b0;
				tx <= 1;
			end
			else if(byte_count2==byte_size)begin
				busy <= ~busy;
				bit_count3 <= 8'd0;
				count3 <= 11'b0;
				byte_count2 <= 4'd0;
			end
			else begin
				if(count3!=lim-1)begin
					count3 <= count3 + 11'd1;
				end
				else begin
					count3 <= 11'b0;
					if(bit_count3!=8'd20)begin
						bit_count3 <= bit_count3 + 8'b1;
						if(bit_count3<=8)begin
							if(bit_count3==8'd0)begin
								tx<=0;
							end
							else begin
								tx <= data_store2[31];
								data_store2 <= data_store2 << 1 | 32'd1;
							end
						end
						else begin
							tx <= 1'b1;
						end
					end
					else begin
						tx <= 1'b1;
						bit_count3 <= 8'd0;
						byte_count2 <= byte_count2 + 4'd1;
					end
				end
			end
		end
		
endmodule



