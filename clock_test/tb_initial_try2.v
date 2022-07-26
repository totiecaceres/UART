module tb_initial_try2;
	reg clk;
	reg nrst;
	reg [7:0] data_in;
	wire tx;
	wire [10:0] count;
	wire [3:0] bit_count;
	wire clk_pulse;
	wire [1:0] state;
	integer i;
	initial_try2 uut(
		.clk(clk),
		.nrst(nrst),
		.data_in(data_in),
		.tx(tx),
		.count(count),
		.bit_count(bit_count),
		.clk_pulse(clk_pulse),
		.state(state)
	);
	always
		#4167 assign clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
	
	initial begin
		clk = 0;
		nrst = 0;
		data_in = 8'b0;
		#2150100;
		nrst =1;
		for(i=0; i<100; i=i+1)begin
			assign data_in = $urandom%256;
			#104175000;
		end
		//assign data_in = 8'h53;
		//#104164179;
		//assign data_in = 8'h6E;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
		//assign data_in = 8'h53;
		//#104164179;
		//assign data_in = 8'h6E;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
		//nrst = 0;
		//#2150100;
		//nrst =1;
		//assign data_in = 8'h53;
		//#104164179;
		//assign data_in = 8'h6E;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
		//assign data_in = 8'h53;
		//#104164179;
		//assign data_in = 8'h6E;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
		//nrst = 0;
		//#20;
		
	end
endmodule
