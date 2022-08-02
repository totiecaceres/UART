module initial_try7(clk, nrst, data, ready, tx, data_store, bit_count, state, busy, idle, done, signal);
	input clk;
	input nrst;
	input data;
	output ready;
	output tx;
	output [9:0] data_store;
	output [3:0] bit_count;
	output [1:0] state;
	output busy;
	output idle;
	output done;
	output signal;
	
	parameter baud = 9600;
	parameter freq = 12000000;
	parameter lim = (freq/baud);
	
	initial_tx 	transmit(clk, nrst, ready, data, tx, bit_count, state, busy, idle, done, signal);
	initial_rx 	recieve(clk, nrst, data, tx_read, ready, data_store);
	
endmodule

module initial_tx(clk, nrst, ready, data, tx, bit_count, state, busy, idle, done, signal);
	input clk;
	input nrst;
	input ready;
	input data;
	//output tx_read;
	output tx;
	//output [10:0] count;
	output [3:0] bit_count;
	output [1:0] state;
	//output [13:0] byte_count;
	output busy;
	output idle;
	output done;
	output signal;
	
	//reg [31:0] data = {8'h53,8'h6E,8'h61,8'h70};
	//assign data = data_in;
	parameter baud = 9600; //1/9600 = 104.1667 us
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = (freq/baud);
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [10:0] count = 11'd0; //clk_div
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg [13:0] byte_count = 0;
	reg busy = 0;
	reg idle = 0;
	reg tx; 
	//reg data;
	reg [1:0] state = 0;
	reg done = 0;
	reg signal = 0;
	
	always@(posedge clk or nrst)begin
		if(!nrst)begin
			signal <= 0;
		end
		else begin
			signal <= ~ready;
		end
	end
	
	always @(posedge clk or nrst or negedge ready)
		begin
			if(!nrst)begin
				bit_count <= 0;
				count <= 11'b0;
			end
			else begin
				if(count!=lim-1)begin
					count <= count +11'b1;
				end
				else begin
					count <= 11'b0;
					if(bit_count==4'd9)begin
						bit_count <= 0;
						//idle <= ~idle;						//idle signal will generate...
						if(byte_count!=960-1)begin				//10% of 1 sec or 960 [10% of 9600]
							byte_count <= byte_count + 1;
						end
						else begin
							byte_count <= 0;
							busy <= ~busy;						//busy signal will generate..
						end	
					end
					else begin
						bit_count <= bit_count + 4'b1;
					end
				end
			end
		end
	
	always @(bit_count or nrst or busy or idle or data or ready)
	begin
		if(!nrst)begin
			state <= 2'b00;
			tx <= 1;
		end
		else begin
			if(!busy)begin
				if(!idle)begin
					if(!ready)begin
						if(bit_count==5'd0 && ready)begin // start bit
								state <= 2'b01;
								tx <= 0;
							//data <= data_in;
						end
						else if(bit_count==4'd9)begin
							state <= 2'b10;
							tx <= 1;
						end
						else begin
							state <= 2'b11;
							tx <= data;
							//data <= data; // Shifting of 8-bit data to 1-bit tx
						end
					end
					else begin
						state <= 2'b01;
						tx <= data;
					end
				end
				else begin
					state <= 2'b00;
					tx <= 1;
				end
			end
			else begin
				state <= 2'b00;
				tx <= 1;
			end
		end
	end
	
	// Call the Receiver function:
	//initial_rx 	serialize(clk, nrst, tx, tx_read, data_store);
	
endmodule

module initial_rx(clk, nrst, tx_temp, tx_read, ready, data_store); //Receiver module
	input clk;
	input nrst;
	input tx_temp;
	output tx_read;
	output ready;
	output [9:0] data_store;
	reg [9:0] data_store = 10'b0;
	//serializer:
	parameter baud = 9600; //1/9600 = 104.1667 us
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = (freq/baud);
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [10:0] count = 11'd0; //clk_div
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg [13:0] byte_count = 0;
	reg busy = 0;
	reg idle = 0;
	reg tx_read=0;
	reg ready=0;
	always @(posedge clk or nrst or negedge tx_temp)
		begin
			if(!nrst)begin
				bit_count <= 0;
				count <= 11'b0;
				tx_read <= 0;
				data_store <= 10'b1111111111;
			end
			else begin
				if(count!=lim-1)begin
					count <= count +11'b1;
				end
				else begin
					count <= 11'b0;
					data_store <= data_store << 1 | {9'b000000000, tx_temp};
					if(bit_count!=4'd9)begin
						bit_count <= bit_count + 4'b1;
					end
					else begin
						bit_count <= 0;
					end
				end
			end
		end
		
	always @(posedge clk or nrst or negedge tx_temp or bit_count)begin
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
			ready <= tx_read && !tx_temp;
		end
	end

endmodule



