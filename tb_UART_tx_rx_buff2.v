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
		.busy1(busy1)
	);
	integer i=0, j=0;
	reg [7:0] data_in;
	always
		#4167 clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
	
	always @(nrst)
		if(!nrst)begin
			rx = 1;
		end
		else begin
			#10417500;
			#10417500;
			#10417500;
			#10417500;
			#1041750;
			for(i=0; i<480; i=i+1)begin				//480 is half of 960 ->> 10% of baud.
					assign data_in = $urandom%254;
					for(j=0; j<10; j=j+1)begin
						if(j==0)begin
							assign rx = 0;
							#10417500;							
						end
						else if(j==9)begin
							if(i%2)begin
								assign rx = 1;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
							end
							else begin
								assign rx = 1;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#10417500;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
								#104175000;
							end
						end
						else begin
							assign rx = data_in[j-1];
							#10417500;							//104 us = 1/9600
						end
					end
					#104175000;
					
				
				
				//else begin
					//assign data_in = 10'd255;
					//for(j=0; j<10; j=j+1)begin
						//if(j==0)begin
							//assign rx = 1;
							//if(i>960)begin
								//assign rx = 1;
								//#10417500;
								//#10417500;
								//#10417500;
								//#10417500;
							//end
							//#10417500;							

						//end
						//else if(j==9)begin
							//assign rx = 1;
							//#10417500;							

						//end
						//else begin
							//assign rx = data_in[j-1];
							//#10417500;							//104 us = 1/9600

						//end
					//end
					//#104175000;
				//end
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
