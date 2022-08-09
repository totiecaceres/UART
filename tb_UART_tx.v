module tb_UART_tx;
	reg clk;
	reg nrst;
	//wire busy;
	wire tx;
	//wire [3:0] bit_count;
	//wire [9:0] frame_count;
	wire [1:0] byte_count;
	
	UART_tx uut(
		.clk(clk),
		.nrst(nrst),
		//.busy(busy),
		.tx(tx),
		//.bit_count(bit_count),
		//.frame_count(frame_count)
		.byte_count(byte_count)
		);
		
	always
		#4167 assign clk = ~clk;
		
	initial begin
		clk = 0;
		nrst = 0;
		#2154335;
		nrst = 1;
		
	end
endmodule
