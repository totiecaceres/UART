module UART_tx_rx_buff_baud(clk, nrst, baud, rx, tx, rx2, tx2);
	input clk;
	input nrst;
	input [1:0] baud;
	input rx;
	output tx;
	output rx2;
	output tx2;
	//output ready;
	//output [9:0] data_store;
	//output [9:0] bit_count;
	//output [3:0] bit_count2;
	//output [3:0] byte_count;
	//output [3:0] byte_count2;
	//output busy;
	//output busy2;
	//output idle;
	//output [4:0] bit_count3;
	//output [31:0] data_store2;
	//output busy1;
	assign rx2 = rx;
	assign tx2 = tx;
	
	reg [19:0] count = 20'd0; //clk_div
	reg [19:0] count2 = 20'd0;
	reg [19:0] count3 = 11'd0;
	reg [9:0] bit_count = 10'd0;
	reg [3:0] bit_count2 = 4'b0000;
	reg [4:0] bit_count3 = 5'b00000;
	reg [4:0] byte_count = 5'd0;
	reg [4:0] byte_count2 = 5'd0;
	reg [9:0] data_store = 10'b0;
	reg [31:0] data_store2[5:0];
	reg busy1 = 0;
	reg busy2 = 0;
	reg idle = 0;
	reg ready=0;
	reg tx; 
	parameter i=0;
	reg [19:0] lim;
	reg [9:0] lim2;

	always@(*) begin
		if(baud==2'b00)begin			//baud 110  --> 1/110 = 9090.9091 us
			lim <= 20'd109091;
			lim2 <= 10'd21;
		end
		else if(baud==2'b01)begin		//baud 600 --> 1/600 = 1666.6667 us
			lim <= 20'd20000;
			lim2 <= 10'd70;
		end
		else if(baud==2'b10)begin		//baud 2400 --> 1/2400 = 416.6667 us
			lim <= 20'd5000;
			lim2 <= 10'd250;
		end
		else begin				//baud 9600	--> 1/9600 = 104.1667 us
			lim <= 20'd1250;
			lim2 <= 10'd970;
		end
	end
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	always @(posedge clk or negedge nrst)
		begin
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE I: RECEIVING PART... 
			if(!nrst || busy)begin
				count <= 20'b0;
				bit_count <= 10'd0;
				bit_count2 <= 4'd0;
				data_store <= 10'b1111111111;
			end
			else begin
				////////////////////////////////////////////////////////////////////////////////////////////// 1a. START BIT DETECTOR..
				if(data_store==10'b1111111111 &&  !rx)begin
					ready <= 1'b1;
				end
				else begin
					ready <= 1'b0;
				end

				/////////////////////////////////////////////////////////////////////////////////////////////// 1b. [GENERATE IDLE STATE FOR TX]..
				if(idle==1)begin
					if(count2!=lim-1)begin
						count2 <= count2 + 20'd1;
					end
					else begin
						count2 <= 20'b0;
						if(bit_count2==4'd8)begin /// it means the 8-bit data already stored... idle signal ends 
							bit_count2 <= 4'd0;
							idle <= ~idle;
						end
						else begin
							bit_count2 <= bit_count2 + 1;
						end
					end	
				end
				else begin
					count <= 20'b0;
					bit_count2 <= 4'd0;
				end
				/////////////////////////////////////////////////////////////////////////////////////////////// 1c. STORING DATA...
				if(count!=lim-1)begin
					count <= count + 1;
				end
				else begin
					count <= 20'b0;
					data_store <= data_store << 1 | {9'b000000000, rx}; 			///keep storeing...
					if(bit_count==10'd8)begin											///save to data_store 2.... 
						if(byte_count==5'd1)begin
							data_store2[0] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==5'd2)begin
							data_store2[0] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[0][7:0]};
						end
						else if(byte_count==5'd3)begin
							data_store2[0] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[0][15:0]};
						end
						else if(byte_count==5'd4)begin
							data_store2[0] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[0][23:0]};
						end
						else if(byte_count==5'd5)begin
							data_store2[1] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==5'd6)begin
							data_store2[1] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[1][7:0]};
						end
						else if(byte_count==5'd7)begin
							data_store2[1] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[1][15:0]};
						end
						else if(byte_count==5'd8)begin
							data_store2[1] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[1][23:0]};
						end
						else if(byte_count==5'd9)begin
							data_store2[2] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==5'd10)begin
							data_store2[2] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[2][7:0]};
						end
						else if(byte_count==5'd11)begin
							data_store2[2] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[2][15:0]};
						end
						else if(byte_count==5'd12)begin
							data_store2[2] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[2][23:0]};
						end
						else if(byte_count==5'd13)begin
							data_store2[3] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==5'd14)begin
							data_store2[3] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[3][7:0]};
						end
						else if(byte_count==5'd15)begin
							data_store2[3] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[3][15:0]};
						end
						else if(byte_count==5'd16)begin
							data_store2[3] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[3][23:0]};
						end
						else if(byte_count==5'd17)begin
							data_store2[4] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==5'd18)begin
							data_store2[4] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[4][7:0]};
						end
						else if(byte_count==5'd19)begin
							data_store2[4] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[4][15:0]};
						end
						else if(byte_count==5'd20)begin
							data_store2[4] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[4][23:0]};
						end
						else if(byte_count==5'd21)begin
							data_store2[5] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
						end
						else if(byte_count==5'd22)begin
							data_store2[5] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[4][7:0]};
						end
						else if(byte_count==5'd23)begin
							data_store2[5] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[4][15:0]};
						end
						else if(byte_count==5'd24)begin
							data_store2[5] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[4][23:0]};
						end
						else begin
							data_store2[0] <= data_store2[0];
							data_store2[1] <= data_store2[1];
							data_store2[2] <= data_store2[2];
							data_store2[3] <= data_store2[3];
							data_store2[4] <= data_store2[4];
							data_store2[5] <= data_store2[5];
						end
					end
					else begin
						data_store2[0] <= data_store2[0];
						data_store2[1] <= data_store2[1];
						data_store2[2] <= data_store2[2];
						data_store2[3] <= data_store2[3];
						data_store2[4] <= data_store2[4];
						data_store2[5] <= data_store2[5];
					end
					
					if(ready)begin 		///// no data entering....
						bit_count <= 10'd0;
						idle <= ~idle;		///// idle signal will start..
						byte_count <= byte_count + 5'd1;
						byte_count2 <= byte_count2;
					end
					else begin
						byte_count <= byte_count;
						if(bit_count!=lim2)begin     //just to limit the counter if no start bit detected...
							bit_count <= bit_count + 1;
							byte_count2 <= byte_count2;
						end
						else begin
							bit_count <= 10'd0; // stop counting when no start bit detected...
							busy1 <= ~busy1;
							byte_count2 <= 5'd0;
						end
					end
				end
			end
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE II: TRANSMITING PART....
			if(!nrst || !busy)begin
				bit_count3 <= 5'b0;
				count3 <= 20'b0;
				tx <= 1;
			end
			else if(byte_count2==byte_count)begin
				busy2 <= ~busy2;
				bit_count3 <= 5'b0;
				count3 <= 20'b0;
				byte_count <= 5'b0;
			end
			else begin
				if(count3!=lim-1)begin
					count3 <= count3 +20'b1;
				end
				else begin
					count3 <= 20'b0;
					if(bit_count3!=5'd19)begin ////////////////////////////////////////////////////////// 2a. ADD 10-BIT SPACER FOR RX
						if(bit_count3<=5'd8)begin
							if(bit_count3==5'd0)begin
								tx <= 0;
							end
							else begin
								if(byte_count2<=5'd3) begin
									tx <= data_store2[0][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[0] <= {1'b0,data_store2[0][31:1]};
								end
								else if(byte_count2>5'd3 && byte_count2<=5'd7) begin
									tx <= data_store2[1][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[1] <= {1'b0,data_store2[1][31:1]};
								end
								else if(byte_count2>5'd7 && byte_count2<=5'd11) begin
									tx <= data_store2[2][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[2] <= {1'b0,data_store2[2][31:1]};
								end
								else if(byte_count2>5'd11 && byte_count2<=5'd15) begin
									tx <= data_store2[3][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[3] <= {1'b0,data_store2[3][31:1]};
								end
								else if(byte_count2>5'd15 && byte_count2<=5'd19) begin
									tx <= data_store2[4][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[4] <= {1'b0,data_store2[4][31:1]};
								end
								else begin
									tx <= data_store2[5][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[5] <= {1'b0,data_store2[5][31:1]};
								end
							end
						end
						else begin
							tx <= 1;
						end
						bit_count3 <= bit_count3 + 5'd1;
					end
					else begin
						bit_count3 <= 5'd0;
						byte_count2 <= byte_count2 + 5'd1;
					end
				end
			end
		end

	assign busy = (busy1 ^ busy2);
	
/////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
