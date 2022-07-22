module initial_try(clk, nrst, tx, count, bit_count, clk_pulse);
	input clk;
	input nrst;
	output tx;
	output [10:0] count;
	output [3:0] bit_count;
	output clk_pulse;
	parameter [7:0] data = 8'b01010100;
	parameter baud = 9600; //
	parameter freq = 12000000; //clock speed f=1/s
	parameter lim = freq/baud;
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	
	reg [10:0] count = 11'd0; //clk_div
	reg clk_pulse=1;
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg tx;
	always @(posedge clk)
		begin
			if(!nrst)begin
				bit_count <= 0;
				count <= 11'b0; end
			else begin
				//different condition: if idle/transition state, do not pulse the next start bit.
				if(count!=11'd1250)begin
					count <= count +11'b1;
				end
				else begin
					bit_count <= bit_count + 4'b1;
						if(bit_count==4'd9)begin
							bit_count <= 0;
							clk_pulse <= 1;
						end
						else if(bit_count<4'd4)begin
							clk_pulse <= 1;
						end
						else if(bit_count>=4'd4)begin
							clk_pulse <= 0;
						end
						else begin
							//
						end
					count <= 11'b0;
				end
			end
		end
	
					  
endmodule
