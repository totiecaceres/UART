module tb_UART_tx_rx_buff;
	reg clk;
	reg nrst;
	reg rx;
	wire tx;
	wire ready;
	wire [9:0] data_store;
	wire [3:0] bit_count;
	wire [3:0] bit_count2;
	wire [3:0] byte_count;
	wire busy;
	wire busy2;
	wire idle;
	wire [4:0] bit_count3;
	wire [31:0] data_store2;
	wire busy1;
	
	UART_tx_rx_buff uut(
		.clk(clk),
		.nrst(nrst),
		.rx(rx),
		.tx(tx),
		.ready(ready),
		.data_store(data_store),
		.bit_count(bit_count),
		.bit_count2(bit_count2),
		.byte_count(byte_count),
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
		#4167 assign clk = ~clk; // 12Mhz --> 83.33ns per full cyc --> 41.666ns per half period
		
	initial begin
		clk = 0;
		nrst = 0;
		data_in = 8'hff;
		#2154335;
		nrst = 1;
		
		if(!busy || !nrst)begin
			rx= 1;
		end
		else begin
			for(i=0; i<480; i=i+1)begin				//480 is half of 960 ->> 10% of baud.
				assign data_in = $urandom%255;
				for(j=0; j<10; j=j+1)begin
					if(j==10)begin
						if(i==1)begin
							assign rx= 1;
							#10417500;
							#10417500;
							#10417500;
						end
						else if(i==2) begin
							assign rx= 1;
							#99999999999;
							//#10417500000;
						end
						else begin
							assign rx= 1;
							#10417500;
						end
					end
					else if(j==0)begin
						assign rx= 0;
						#10417500;							
					end
					else if(j==9)begin
						if(i==1)begin
							assign rx= 1;
							#10417500;
							#10417500;
							#10417500;
						end
						else if(i==2) begin
							assign rx= 1;
							#99999999999;
							//#10417500000;
						end
						else begin
							assign rx= 1;
							#10417500;
						end
					end
					else begin
						assign rx= data_in[j-1];
						#10417500;							//104 us = 1/9600
					end
				end
				#10417500000;
				end
			end
		end
		
		
	end
endmodule
