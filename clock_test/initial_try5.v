module initial_try5(clk, nrst, data_in, tx_read, tx, data_store, busy);
	input clk;
	input nrst;
	input [7:0] data_in;
	output tx_read;
	output tx;
	output [9:0] data_store;
	//output [10:0] count;
	//output [3:0] bit_count;
	//output [1:0] state;
	//output [13:0] byte_count;
	output busy;
	//output idle;
	
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
	reg [1:0] state = 0;
	reg [7:0] data;
	reg [9:0] detect;
	
	
	always @(posedge clk or nrst)
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
					if(bit_count!=4'd9)begin
						bit_count <= bit_count + 4'b1;
					end
					else begin
						bit_count <= 0;
						idle <= ~idle;							//idle signal will generate...
						if(byte_count!=960-1)begin				//10% of 1 sec or 960 [10% of 9600]
							byte_count <= byte_count + 1;
						end
						else begin
							byte_count <= 0;
							busy <= ~busy;						//busy signal will generate..
						end
					end
				end
			end
		end
	
	always @(bit_count or nrst or busy or idle or data_in)
	begin
		if(!nrst)begin
			state <= 2'b00;
			tx <= 1;
		end
		else begin
			if(!busy)begin
				if(!idle)begin
					if(bit_count==4'd0 )begin // start bit
						state <= 2'b01;
						tx <= 0;
						data <= data_in;
					end
					else if(bit_count==4'd9)begin
						state <= 2'b10;
					end
					else begin
						state <= 2'b11;
						tx <= data[0];
						data <= data >> 1; // Shifting of 8-bit data to 1-bit tx
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
	
	// call the receiver function:
	initial_rx 	serialize(clk, nrst, tx, tx_read, data_store);
	
endmodule
