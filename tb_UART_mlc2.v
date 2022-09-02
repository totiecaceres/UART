module tb_UART_mlc2;
	reg clk;
	reg nrst;
	//reg [1:0] baud;
	reg rx;
	wire tx;
	wire txD;
	//wire [9:0] data_store;
	//wire [31:0] data_store3;
	//wire ready;
//	wire rx2;
//	wire txD;
	wire trigout_ch0;
	wire trigout_ch1;
	wire trigout_ch2;
	wire trigout_ch3;
	wire [7:0] vctrout_ch0;
	//wire [7:0] vctrout_ch1;
	//wire [7:0] vctrout_ch2;
	//wire [7:0] vctrout_ch3;
	//wire busy;
	//wire trig_en;
	//wire h53;
	//wire h5C;
	//wire hA5;
	//wire h00;
	//wire idle;
	//wire [2:0] t_ind;
	//wire [4:0] byte_count;
	//wire [9:0] bit_count;
	
	UART_mlc2 uut(
		.clk(clk),
		.nrst(nrst),
		//.baud(baud),
		.rx(rx),
		.tx(tx),
		.txD(txD),
		//.data_store(data_store),
		//.data_store3(data_store3),
		//.ready(ready),
//		.rx2(rx2),
//		.txD(txD),
		.trigout_ch0(trigout_ch0),
		.trigout_ch1(trigout_ch1),
		.trigout_ch2(trigout_ch2),
		.trigout_ch3(trigout_ch3),
		.vctrout_ch0(vctrout_ch0)
		//.vctrout_ch1(vctrout_ch1),
		//.vctrout_ch2(vctrout_ch2),
		//.vctrout_ch3(vctrout_ch3),
		//.busy(busy)
		//.trig_en(trig_en),
		//.h53(h53),
		//.h5C(h5C),
		//.hA5(hA5),
		//.h00(h00),
		//.idle(idle),
		//.t_ind(t_ind),
		//.byte_count(byte_count),
		//.bit_count(bit_count)
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

			////////////////////////////////////////////////////////////////////////
			assign data_in = 8'h53;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			//#(delay*10);
			//end
			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			#(delay*10);
			assign data_in = 8'h01;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			
			assign data_in = 8'h03;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			#(delay*100);
			#(delay*10);
			
			////////////////////////////////////////////////////////////////////////
			assign data_in = 8'h5C;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end

			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			
			#(delay*100);
			#(delay*10);
			
			assign data_in = 8'h53;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			//#(delay*10);
			//end
			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			#(delay*10);
			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			
			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			#(delay*100);
			#(delay*10);
			
			////////////////////////////////////////////////////////////////////////
			assign data_in = 8'h5C;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end

			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			
			#(delay*100);
			#(delay*10);
			
			assign data_in = 8'h53;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			//#(delay*10);
			//end
			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			#(delay*10);
			assign data_in = 8'h02;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			
			assign data_in = 8'h15;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			#(delay*100);
			#(delay*10);
			
			////////////////////////////////////////////////////////////////////////
			assign data_in = 8'h5C;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end

			assign data_in = 8'h00;
			for(j=0; j<10; j=j+1)begin
				if(j==0)begin
					assign rx = 0;
					#(delay);						
				end
				else if(j==9)begin
					assign rx = 1;
					#(delay);
				end
				else begin
					assign rx = data_in[j-1];
					#(delay);							//104 us = 1/9600
				end
			end
			
		
		end

	initial begin
		clk = 0;
		nrst = 0;
		rx = 1;
		data_in = 8'hff;
		//baud = 2'b11;
		#2154335;
		nrst = 1;
	end
	
endmodule
