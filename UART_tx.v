module UART_tx(clk, nrst, tx);
	input clk;
	input nrst;
	output tx;
	
	parameter freq = 12000000;
	parameter baud = 9600;
	parameter lim = freq/baud;
	
	reg [10:0] count = 11'd0;
	reg bit_clk = 0;
	 	
	always @(posedge clk or negedge nrst)begin
		if(!nrst)begin
			count <= 0;
			bit_clk <= 0;
		end
		else begin
			if(count!=lim-1)begin
				if(count==(lim-1)/2)begin
					bit_clk <= ~bit_clk;
				end
				else if(count==0)begin
					bit_clk <= ~bit_clk;
				end
				else begin
					bit_clk <= bit_clk;
				end
				count <= count + 11'd1;
			end
			else begin
				count <= 0;
			end
		end
	end
	
	reg [9:0] data = {1'b1,8'hff,1'b1};
	reg tx;
	reg [3:0] bit_count = 4'd0;  
	reg [1:0] flag = 2'b0;
	reg [3:0] byte_count = 3'd0;
	reg busy = 1'd1;
	reg [9:0] frame_count = 10'd0;
	
	always@(posedge bit_clk or negedge nrst)begin
		if(!nrst)begin
			tx <= 1;
			bit_count <= 0;
			flag <= 1;
			byte_count <= 0;
		end
		else begin
			if(bit_count!=10)begin
				bit_count <= bit_count + 1;
			end
			else begin
				bit_count <= 1;
				if(frame_count!=125)begin
					frame_count <= frame_count + 10'd1;
				end
				else begin
					frame_count <= 10'd0;
					busy <= ~busy;
				end

				if(flag!=3)begin
					flag <= flag + 1;
				end
				else begin
					flag <= 1;
				end
			
				if(byte_count!=4)begin
					byte_count <= byte_count + 1;
				end
				else begin
					byte_count <= 0;
				end
				
				case(byte_count)
					3'b000	: data <= {1'b1,8'h53,1'b0};
					3'b001	: data <= {1'b1,8'h53,1'b0};
					3'b010	: data <= {1'b1,8'h6e,1'b0};
					3'b011	: data <= {1'b1,8'h6e,1'b0};
					3'b100	: data <= {1'b1,8'h61,1'b0};
					3'b101	: data <= {1'b1,8'h61,1'b0};
					3'b110	: data <= {1'b1,8'h70,1'b0};
					3'b111	: data <= {1'b1,8'h70,1'b0};
					default : data <= {1'b1,8'hff,1'b1};
				endcase
			end
			
			if(!busy)begin
				tx <= 1'b1;
			end
			else begin
				case(flag)
					2'b00 	: tx <= 1'b1;
					2'b01	: begin
							tx <= data[0];	
							data <= data >> 1 | {data[0],9'd0};
							end
					default	: tx <= 1'b1;
				endcase
			end
		end
	end
	
endmodule
