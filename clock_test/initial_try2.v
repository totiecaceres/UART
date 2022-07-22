module initial_try2(clk, nrst, tx, count, bit_count);
	input clk;
	input nrst;
	output tx;
	output [10:0] count;
	output [3:0] bit_count;
	parameter [7:0] data = 8'b01010100;
	parameter baud = 9600; //
	parameter freq = 12000000; //clock speed f=1/s
	parameter lim = freq/baud;
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	
	reg [10:0] count = 11'd0; //clk_div
	wire clk_pulse;
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg tx;
	always @(posedge clk)
		begin
			if(!nrst)begin
				tx <= 1;
				bit_count <= 0;
				count <= 11'b0; end
			else begin
				//different condition: if idle/transition state, do not pulse the next start bit.
				count <= count +11'b1;
				if(count==11'd1250)begin
					//new bit
					//tx <= 0; // start bit
						if(bit_count==4'd9)begin
							tx <= 1; //end bit
							bit_count <= 0;
						end
						else if(bit_count>0 & bit_count<4'd9)begin
							integer i = bit_count;
							tx <= data[i-1]; 	
						end
						else begin
							tx <= 0;
						end
					count <= 11'b0;
					bit_count <= bit_count + 4'b1;
				end
				else begin
					tx <= 1; //active high
				end
			end
		end
					  
endmodule
