module tb_initial_try5;
	reg clk;
	reg nrst;
	reg [7:0] data_in;
	wire tx_read;
	wire tx;
	wire [9:0] data_store;
	//wire [10:0] count;
	//wire [3:0] bit_count;
	//wire [1:0] state;
	//wire [13:0] byte_count;
	wire busy;
	//wire idle;
	
	initial_try5 uut(
		.clk(clk),
		.nrst(nrst),
		.data_in(data_in),
		.tx_read(tx_read),
		.tx(tx),
		.data_store(data_store),
		//.count(count),
		//.bit_count(bit_count),
		//.state(state),
		//.byte_count(byte_count),
		.busy(busy)
		//.idle(idle)	
	);
	integer i=0;
	always
		#4167 assign clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
		
	//always @(!busy)begin 
		//assign data_in = 8'h53;
		//#104164179;
		//assign data_in = 8'h6E;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
		//assign data_in = 8'hff;
		//#104175000;
	//end
	always @(!busy)
		for(i=0; i<480; i=i+1)begin				//480 is half of 960 ->> 10% of baud.
			if(!busy)begin
				assign data_in = $urandom%255;
				#104175000;							//104 us = 1/9600
				#104175000;
			end
			else begin
				assign data_in = data_in;
				#104175000;
				#104175000;
			end
		end
		
	initial begin
		clk = 0;
		nrst = 0;
		data_in = 8'hff;
		#2150100;
		nrst =1;
		//assign data_in = 8'h53;
		//#104164179;
		//#104164179;
		//assign data_in = 8'h6E;
		//#104175000;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
		//#104175000;
		//assign data_in = 8'h53;
		//#104175000;
		//#104175000;
		//assign data_in = 8'h6E;
		//#104175000;
		//#104175000;
		//assign data_in = 8'h61;
		//#104175000;
		//#104175000;
		//assign data_in = 8'h70;
		//#104175000;
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
