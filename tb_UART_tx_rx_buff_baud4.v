module tb_UART_tx_rx_buff_baud3;
	reg clk;
	reg nrst;
	reg [1:0] baud;
	reg rx;
	wire tx;
	wire rx2;
	wire tx2;
	wire [7:0] trigout_ch0;
	wire [7:0] trigout_ch1;
	wire [7:0] trigout_ch2;
	wire [7:0] trigout_ch3;
	wire busy;
	wire trig_en;
	wire [2:0] vt_ind;
	wire [4:0] byte_count;
	
	UART_tx_rx_buff_baud3 uut(
		.clk(clk),
		.nrst(nrst),
		.baud(baud),
		.rx(rx),
		.tx(tx),
		.rx2(rx2),
		.tx2(tx2),
		.trigout_ch0(trigout_ch0),
		.trigout_ch1(trigout_ch1),
		.trigout_ch2(trigout_ch1),
		.trigout_ch3(trigout_ch3),
		.busy(busy),
		.trig_en(trig_en),
		.vt_ind(vt_ind),
		.byte_count(byte_count)
	);
	integer i=0, j=0;
	reg [7:0] data_in;
	integer delay = 10417500; 	// 1/9600 = 104.1667 us
	//integer delay = 41666700;	// 1/2400 = 416.6667 us
	//integer delay = 166666700;// 1/600 = 1666.6667 us
	//integer delay = 909090900;// 1/110 = 9090.9091 us
	//parameter baud = 4; // 1/9600 = 104.1667 us
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
			//for(i=0; i<baud; i=i+1)begin				//480 is half of 960 ->> 10% of baud.
			assign data_in = 8'h53;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					if((i/3)%2)begin
						assign rx = 1;
						#(delay);
						#(delay);
						#(delay);
						#(delay);
					end
					else begin
						assign rx = 1;
						#(delay*10);
					end
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			//#(delay*10);
			//end
			assign data_in = 8'h30;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					if((i/3)%2)begin
						assign rx = 1;
						#(delay);
						#(delay);
						#(delay);
						#(delay);
					end
					else begin
						assign rx = 1;
						#(delay*10);
					end
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			//#(delay*10);
			
			assign data_in = 8'hAB;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					if((i/3)%2)begin
						assign rx = 1;
						#(delay);
						#(delay);
						#(delay);
						#(delay);
					end
					else begin
						assign rx = 1;
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

	initial begin
		clk = 0;
		nrst = 0;
		rx = 1;
		data_in = 8'hff;
		baud = 2'b11;
		#2154335;
		nrst = 1;
	end
	
endmodule
