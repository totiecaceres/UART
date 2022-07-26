module initial_try2(clk, nrst, data_in, tx, count, bit_count, clk_pulse, state);
	input clk;
	input nrst;
	input [7:0] data_in;
	output tx;
	output [10:0] count;
	output [3:0] bit_count;
	output clk_pulse;
	output [1:0] state;
	//reg [31:0] data = {8'h53,8'h6E,8'h61,8'h70};
	//assign data = data_in;
	parameter baud = 9600; //1/9600 = 104.1667 ms
	parameter freq = 12000000; //clock speed f=1/s, 83.333ns
	parameter lim = (freq/baud);
	//12M/9.6k = 1250 bits ; log2(1250) = 10.2877 or 11 bits [000 0000 0000] counter
	//determine the number of count that will generate in 30Mhz freq at 9.6k bit per sec
	//log2(1250) = 10.2877 or 11 bits so,
	reg [10:0] count = 11'd0; //clk_div
	reg [3:0] bit_count = 4'b0000; //req. 10 bit per frame so, it has 4 bit
	reg tx;
	reg clk_pulse;
	reg [1:0] state = 0;
	reg [7:0] data;
	always @(posedge clk or nrst)
		begin
			if(!nrst)begin
				bit_count <= 0;
				count <= 11'b0;
				clk_pulse <= 1;
			end
			else begin
				//different condition: if idle/transition state, do not pulse the next start bit.
				if(count!=lim-1)begin
					count <= count +11'b1;
					if(count==lim/2)begin
						clk_pulse = ~clk_pulse;
					end
				end
				else begin
					if(bit_count!=4'd9)begin
						bit_count <= bit_count + 4'b1;
					end
					else begin
						bit_count <= 0;
					end
					clk_pulse = ~clk_pulse;
					count <= 11'b0;
				end
			end
		end
	
	always @(bit_count or nrst)
	begin
		if(!nrst)begin
			state <= 2'b00;
		end
		else begin
			if(bit_count==4'd0)begin // start bit
			state <= 2'b01;
			end
			else if(bit_count==4'd9)begin
				state <= 2'b10;
			end
			else begin
				state <= 2'b11;
			end
		end
	end
	//reg [7:0] data;
	reg start_flag;
	reg stop_flag;
	initial begin
		start_flag <= 1;
		stop_flag <= 1;
	end
	
	always @(state or bit_count or nrst or data_in)
	begin
		if(!nrst) begin
			tx <= 1;
		end	
		else begin
			if(state==2'b01)begin // start bit
				tx <= 0;
				start_flag <= 1;
				data <= data_in; // niddle
			end
			else if(state==2'b11)begin // sending..
				if(start_flag==1)begin
					tx <= data[0];
					if(bit_count!=8)begin
						stop_flag <= 0;
						data <= data >> 1;
					end
					else begin
						stop_flag <= 1;
					end
				end
				//else begin
					//data <= 8'h59;
				//end
			end
			else if(state==2'b10) begin					// stop bit
				if(stop_flag==1)begin
					//tx <= 0;
					start_flag <= 1;
				end
				else begin
					tx <= 1;
					start_flag <= 0;
					data <= data_in;
				end
			end
			else begin
				tx <= 1;
				start_flag <= 1;
				stop_flag <= 1;
			end
		end
	end
		  
endmodule
