module initial_try(clk, nrst, data_in, tx);
	input clk;
	input nrst;
	input [31:0] data_in;
	output tx;
	//output [10:0] count;s
	//output [3:0] bit_count;
	//output clk_pulse;
	//output [1:0] state;
	//reg [31:0] data = {8'h53,8'h6E,8'h61,8'h70};
	//assign data = data_in;
	parameter baud = 9600; //1/9600 = 104.1667 ms
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = freq/baud;
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [10:0] count = 11'd0; //clk_div
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg tx;
	reg clk_pulse=0;
	reg [1:0] state = 0;
	
	always @(posedge clk)
		begin
			if(!nrst)begin
				bit_count <= 0;
				count <= 11'b0;
			end
			else begin
				//different condition: if idle/transition state, do not pulse the next start bit.
				if(count!=11'd1249)begin
					count <= count +11'b1;
				end
				else begin
					bit_count <= bit_count + 4'b1;
					if(bit_count!=4'd9)begin
						if(bit_count>=4'd4)begin
							clk_pulse <= 0;
						end
						else begin
							clk_pulse <= 1;
						end
					end
					else begin
						bit_count <= 0;
						clk_pulse <= 1;
					end
					count <= 11'b0;
				end
			end
		end
		
	always @(*)
	begin
		if(bit_count==4'd0)begin
			state <= 2'b01;
		end
		else if(bit_count==4'd9)begin
			state <= 2'b10;
		end
		else begin
			state <= 2'b11;
		end
	end
	
	reg [31:0] data;
	initial begin
		data <= data_in[31:0];
	end
	
	reg start_flag;
	reg stop_flag;
	always @(state or bit_count or nrst)
	begin
		if(!nrst) begin
			tx <= 1;
		end	
		else begin
			if(state==2'b01)begin // start bit
				tx <= 0;
				start_flag <= 1;
			end
			else if(state==2'b11)begin // sending..
				if(start_flag==1)begin
					tx <= data[0];
					data <= data >> 1 | {tx,32'b0};
					if(bit_count!=8)begin
						stop_flag <= 0;
					end
					else begin
						stop_flag <= 1;
					end
				end
				else begin
					//
				end
			end
			else begin					// stop bit
				if(stop_flag==1)begin
					tx <= 0;
					start_flag <= 1;
				end
				else begin
					tx <= 1;
					start_flag <= 0;
				end
			end
		end
	end
		  
endmodule
