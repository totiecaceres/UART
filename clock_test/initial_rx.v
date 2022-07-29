module initial_rx(clk, nrst, tx_temp, tx_read, data_store);
	input clk;
	input nrst;
	input tx_temp;
	output tx_read;
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

	always @(posedge clk or nrst or tx_temp)
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
				end
			end
		end
		
	always @(posedge clk or nrst or tx_temp)begin
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
		end
	end

endmodule
