module tb_UART_tx_rx_buff2;
	reg clk;
	reg nrst;
	reg rx;
	wire tx;
	wire ready;
	wire [9:0] data_store;
	wire [9:0] bit_count;
	wire [3:0] bit_count2;
	wire [3:0] byte_count;
	wire [3:0] byte_count2;
	wire busy;
	wire busy2;
	wire idle;
	wire [4:0] bit_count3;
	wire [31:0] data_store2;
	wire busy1;
	wire [19:0] count;
	
	UART_tx_rx_buff2 uut(
		.clk(clk),
		.nrst(nrst),
		.rx(rx),
		.tx(tx),
		.ready(ready),
		.data_store(data_store),
		.bit_count(bit_count),
		.bit_count2(bit_count2),
		.byte_count(byte_count),
		.byte_count2(byte_count2),
		.busy(busy),
		.busy2(busy2),
		.idle(idle),
		.bit_count3(bit_count3),
		.data_store2(data_store2),
		.busy1(busy1),
		.count(count)
	);
	integer i=0, j=0;
	reg [7:0] data_in;
	integer delay = 10417500; 	// 1/9600 = 104.1667 us
	//integer delay = 41666700;	// 1/2400 = 416.6667 us
	//integer delay = 166666700;// 1/600 = 1666.6667 us
	//integer delay = 909090900;// 1/110 = 9090.9091 us
	parameter baud = 960; // 1/9600 = 104.1667 us
	//parameter baud = 240; // 1/2400 = 416.6667 us
	//parameter baud = 60;	// 1/600 = 1666.6667 us
	//parameter baud = 11;	// 1/110 = 9090.9091 us
	always
		#4167 clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
	
	always @(nrst)
		if(!nrst)begin
			rx = 1;
		end
		else begin
			#(delay);
			#(delay);
			#(delay);
			#(delay);
			#(delay/10);
			for(i=0; i<baud/2; i=i+1)begin				//480 is half of 960 ->> 10% of baud.
					assign data_in = $urandom%254;
					for(j=0; j<10; j=j+1)begin
						if(j==0)begin
							assign rx = 0;
							#(delay);						
						end
						else if(j==9)begin
							if((i/7)%2)begin
								assign rx = 1;
								#(delay);
								#(delay);
								#(delay);
								#(delay);
							end
							else begin
								assign rx = 1;
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
								#(delay*10);
							end
						end
						else begin
							assign rx = data_in[j-1];
							#(delay);							//104 us = 1/9600
						end
					end
					#(delay*10);
			end
		end

	initial begin
		clk = 0;
		nrst = 0;
		rx = 1;
		data_in = 8'hff;
		#2154335;
		nrst = 1;
	end
	
endmodule
