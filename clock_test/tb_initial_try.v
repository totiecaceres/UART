module tb_initial_try;
	reg clk;
	reg nrst;
	reg [31:0] data_in = {8'h53,8'h6E,8'h61,8'h70};
	wire tx;
	//wire [10:0] count;
	//wire [3:0] bit_count;
	//wire clk_pulse;
	//wire [1:0] state;

	initial_try uut(
		.clk(clk),
		.nrst(nrst),
		.data_in(data_in),
		.tx(tx)
		//.count(count),
		//.bit_count(bit_count),
		//.clk_pulse(clk_pulse),
		//.state(state)
	);
	always
		#4200 assign clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
	initial begin
		clk = 0;
		nrst = 0;
		#21000000;
		nrst =1;
		#210000000;
		nrst =1;
		#210000000;
		nrst =1;
		#210000000;
		nrst = 0;
		#20;
		
	end
endmodule
