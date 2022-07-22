module tb_initial_try;
	reg clk;
	reg nrst;
	wire tx=1;
	wire [10:0] count;
	wire [3:0] bit_count;
	wire clk_pulse;

	initial_try uut(
		.clk(clk),
		.nrst(nrst),
		.tx(tx),
		.count(count),
		.bit_count(bit_count),
		.clk_pulse(clk_pulse)
	);
	always
		#4200 assign clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
	initial begin
		clk = 0;
		nrst = 0;
		#21000000;
		nrst =1;
		#420000000;
		nrst =0;
		#20;
		
	end
endmodule
