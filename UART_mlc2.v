module UART_mlc2(clk, nrst, rx, rx2, tx, txD, trigout_ch0, trigout_ch1, trigout_ch2, trigout_ch3, vctrout_ch0);
	input clk;
	input nrst;
	input rx;
	output rx2;
	output tx;
	output txD;
	output trigout_ch0;
	output trigout_ch1;
	output trigout_ch2;
	output trigout_ch3;
	output [7:0] vctrout_ch0;
	assign rx2 = rx;
	
	reg [19:0] count = 20'd0; //clk_div
	reg [19:0] count2 = 20'd0;
	reg [19:0] count3 = 11'd0;
	reg [19:0] count4 = 11'd0;
	reg [9:0] bit_count = 10'd0;
	reg [3:0] bit_count2 = 4'b0000;
	reg [4:0] bit_count3 = 5'b00000;
	reg [4:0] bit_count4 = 5'b00000;
	reg [4:0] byte_count = 5'd0;
	reg [4:0] byte_count2 = 5'd0;
	reg [7:0] byte_count4 = 8'd0;
	reg [9:0] data_store = 10'b0;
	reg [9:0] data_store0 = 10'b0;
	reg [31:0] data_store2[5:0];
	reg [31:0] data_store3 = 32'hffffffff;
	wire busy;
	reg busy1 = 0;
	reg busy2 = 0;
	reg idle = 0;
	reg ready=0;
	reg tx; 
	reg txD; 
	parameter i=0;
	reg [19:0] lim = 20'd1250;
	reg [9:0] lim2 = 10'd249; ////////////// 10'd25 for test bench
	reg [7:0] vctrout_ch0 = 8'd0;
	reg [7:0] vctrout_ch1 = 8'd0;
	reg [7:0] vctrout_ch2 = 8'd0;
	reg [7:0] vctrout_ch3 = 8'd0;
	reg trigout_ch0 = 1'b0;
	reg trigout_ch1 = 1'b0;
	reg trigout_ch2 = 1'b0;
	reg trigout_ch3 = 1'b0;
	reg trig_en0 = 1'b0;
	reg trig_en1 = 1'b0;
	reg trig_en2 = 1'b0;
	reg trig_en3 = 1'b0;
	reg vct_en = 1'b0;
	reg h53 = 1'b0;
	reg h5C = 1'b0;
	reg h5C_en0 = 1'b0;
	reg h5C_en1 = 1'b0;
	reg h5C_en2 = 1'b0;
	reg h5C_en3 = 1'b0;
	reg hA5 = 1'b0;
	reg h00 = 1'b0;
	reg [2:0] t_ind = 3'd0;
	reg [2:0] v_ind = 3'd0;
	reg [1:0] trig_type0 = 2'b11;
	reg [1:0] trig_type1 = 2'b11;
	reg [1:0] trig_type2 = 2'b11;
	reg [1:0] trig_type3 = 2'b11;
	reg zero_trig_type = 1'b0;
	reg [7:0] trig_val0 = 8'd0;
	reg [7:0] trig_val1 = 8'd0;
	reg [7:0] trig_val2 = 8'd0;
	reg [7:0] trig_val3 = 8'd0;
	reg trigout_end = 1'b0;
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	always @(posedge clk or negedge nrst)
		begin
			///////////////////////////////////////////////////////////////////////////////////////////////// PHASE I: RECEIVING PART... 
			if(!nrst || busy)begin
				count <= 20'b0;
				bit_count <= 10'd0;
				bit_count2 <= 4'd0;
				data_store <= 10'b1111111111;
				data_store0 <= 10'b1111111111;
				if(!nrst)begin
					trig_val0 <= 8'd0;
					trig_val1 <= 8'd0;
					trig_val2 <= 8'd0;
					trig_val3 <= 8'd0;
				end
				else begin
					trig_val0 <= trig_val0;
					trig_val1 <= trig_val1;
					trig_val2 <= trig_val2;
					trig_val3 <= trig_val3;
				end
			end
			else begin
				////////////////////////////////////////////////////////////////////////////////////////////// 1a. START BIT DETECTOR..
				if(data_store0==10'b1111111111 &&  !rx)begin
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
					data_store0 <= data_store0 << 1 | {9'b000000000, rx};
					
					if(hA5==1'b1)begin
						if(v_ind==3'd1 && byte_count==5'd3)begin
							 if(bit_count==10'd8)begin
								vctrout_ch0 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
								vct_en <= ~vct_en;
							 end
							 else begin
								vctrout_ch0 <= vctrout_ch0;
							 end
						end
						else if(v_ind==3'd2 && byte_count==5'd3)begin
							if(bit_count==10'd8)begin
								vctrout_ch1 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
								vct_en <= ~vct_en;
							 end
							 else begin
								vctrout_ch1 <= vctrout_ch1;
							 end
						end
						else if(v_ind==3'd3 && byte_count==5'd3)begin
							if(bit_count==10'd8)begin
								vctrout_ch2 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
								vct_en <= ~vct_en;
							 end
							 else begin
								vctrout_ch2 <= vctrout_ch2;
							 end
						end
						else if(v_ind==3'd4 && byte_count==5'd3)begin
							if(bit_count==10'd8)begin
								vctrout_ch3 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
								vct_en <= ~vct_en;
							 end
							 else begin
								vctrout_ch3 <= vctrout_ch3;
							 end
						end
						else begin
							vctrout_ch0 <= vctrout_ch0;
							vctrout_ch1 <= vctrout_ch1;
							vctrout_ch2 <= vctrout_ch2;
							vctrout_ch3 <= vctrout_ch3;
						end
					end
					else begin
						 vctrout_ch0 <= vctrout_ch0;
						 vctrout_ch1 <= vctrout_ch1;
						 vctrout_ch2 <= vctrout_ch2;
						 vctrout_ch3 <= vctrout_ch3;
					end
					
					
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					if(bit_count==10'd8)begin											///save to data_store 2.... 
						data_store0 <= 10'b1111111111;
						if(byte_count==5'd1)begin
							data_store2[0] <= {24'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
							if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h53)begin
								h53 <= 1'b1;
								h5C <= 1'b0;
								h00 <= 1'b0;
								hA5 <= 1'b0;
								h5C_en0 <= 1'b0;
								h5C_en1 <= 1'b0;
								h5C_en2 <= 1'b0;
								h5C_en3 <= 1'b0;
								data_store3 <= {24'hffffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
							end
							else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h5c)begin
								h5C <= 1'b1;
								h53 <= 1'b0;
								h00 <= 1'b0;
								hA5 <= 1'b0;
								data_store3 <= {24'hffffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
							end
							else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h00)begin
								h00 <= 1'b1;
								hA5 <= 1'b0;
								h53 <= 1'b0;
								h5C <= 1'b0;
								h5C_en0 <= 1'b0;
								h5C_en1 <= 1'b0;
								h5C_en2 <= 1'b0;
								h5C_en3 <= 1'b0;
								data_store3 <= {24'hffffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
							end
							else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'hA5)begin
								h00 <= 1'b0;
								hA5 <= 1'b1;
								h53 <= 1'b0;
								h5C <= 1'b0;
								h5C_en0 <= 1'b0;
								h5C_en1 <= 1'b0;
								h5C_en2 <= 1'b0;
								h5C_en3 <= 1'b0;
								data_store3 <= {24'hffffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
							end
							else begin
								h00 <= 1'b0;
								hA5 <= 1'b0;
								h53 <= 1'b0;
								h5C <= 1'b0;
								h5C_en0 <= 1'b0;
								h5C_en1 <= 1'b0;
								h5C_en2 <= 1'b0;
								h5C_en3 <= 1'b0;
								data_store3 <= 32'hffffffff;
							end
						end
						else if(byte_count==5'd2)begin ////////////////////////////////////////////////////////////////////////////////////////////////
							data_store2[0] <= {16'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							if(h5C==1'b1)begin
							     if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h00)begin
										h5C_en0 <= 1'b1;
										h5C_en1 <= 1'b0;
										h5C_en2 <= 1'b0;
										h5C_en3 <= 1'b0;
										data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h01)begin
										h5C_en0 <= 1'b0;
										h5C_en1 <= 1'b1;
										h5C_en2 <= 1'b0;
										h5C_en3 <= 1'b0;
										data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h02)begin
										h5C_en0 <= 1'b0;
										h5C_en1 <= 1'b0;
										h5C_en2 <= 1'b1;
										h5C_en3 <= 1'b0;
										data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h03)begin
										h5C_en0 <= 1'b0;
										h5C_en1 <= 1'b0;
										h5C_en2 <= 1'b0;
										h5C_en3 <= 1'b1;
										data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else begin
										h5C_en0 <= 1'b0;
										h5C_en1 <= 1'b0;
										h5C_en2 <= 1'b0;
										h5C_en3 <= 1'b0;
										data_store3 <= {24'hffffff,data_store3[7:0]};
							     end
						    end
							else if(h53==1'b1)begin
							     if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h00)begin
							        t_ind <= 3'd1;
									trig_en0 <= 1'b1;
									trig_en1 <= 1'b0;
									trig_en2 <= 1'b0;
									trig_en3 <= 1'b0;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h01)begin
							        t_ind <= 3'd2;
									trig_en0 <= 1'b0;
									trig_en1 <= 1'b1;
									trig_en2 <= 1'b0;
									trig_en3 <= 1'b0;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h02)begin
							        t_ind <= 3'd3;
									trig_en0 <= 1'b0;
									trig_en1 <= 1'b0;
									trig_en2 <= 1'b1;
									trig_en3 <= 1'b0;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h03)begin
							        t_ind <= 3'd4;
									trig_en0 <= 1'b0;
									trig_en1 <= 1'b0;
									trig_en2 <= 1'b0;
									trig_en3 <= 1'b1;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else begin
							        t_ind <= 3'd0;
									trig_en0 <= 1'b0;
									trig_en1 <= 1'b0;
									trig_en2 <= 1'b0;
									trig_en3 <= 1'b0;
									data_store3 <= {24'hffffff,data_store3[7:0]};
							     end
						    end
							else if(h00==1'b1)begin
							     if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h00)begin
										data_store3 <= {8'hff,vctrout_ch0[7:0],data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
										v_ind <= 3'd1;
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h01)begin
										data_store3 <= {8'hff,vctrout_ch1[7:0],data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
										v_ind <= 3'd2;
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h02)begin
										data_store3 <= {8'hff,vctrout_ch2[7:0],data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
										v_ind <= 3'd3;
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h03)begin
										data_store3 <= {8'hff,vctrout_ch3[7:0],data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
										v_ind <= 3'd4;
							     end
							     else begin
										v_ind <= 3'd0;
										data_store3 <= {24'hffffff,data_store3[7:0]};
							     end
						    end
							else if(hA5==1'b1)begin
							     if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h00)begin
							         v_ind <= 3'd1;
									vct_en <= 1'd1;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h01)begin
							        v_ind <= 3'd2;
									vct_en <= 1'd1;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h02)begin
							        v_ind <= 3'd3;
									vct_en <= 1'd1;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h03)begin
							        v_ind <= 3'd4;
									vct_en <= 1'd1;
									data_store3 <= {16'hffff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[7:0]};
							     end
							     else begin
							        v_ind <= 3'd0;
									vct_en <= 1'd0;
									data_store3 <= {24'hffffff,data_store3[7:0]};
							     end
						    end
							else begin
								v_ind <= 3'd0;
								t_ind <= 3'd0;
								trig_en0 <= 1'b0;
								trig_en1 <= 1'b0;
								trig_en2 <= 1'b0;
								trig_en3 <= 1'b0;
								vct_en <= 1'd0;
								data_store3 <= {24'hffffff,data_store3[7:0]};
							end
						end
						else if(byte_count==5'd3)begin ////////////////////////////////////////////////////////////////////////////////////////////////
							data_store2[0] <= {8'd0,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[0][15:0]};
							if(h53==1'b1)begin
								if(trig_en0 || trig_en1 || trig_en2 || trig_en3)begin
									if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h00)begin
										data_store3 <= {8'hff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[15:0]};
										if(trig_en0)begin
											trig_type0 <= {~trig_type0, ~trig_type0};
										end
										else if(trig_en1) begin
											trig_type1 <= {~trig_type1, ~trig_type1};
										end
										else if(trig_en2) begin
											trig_type2 <= {~trig_type2, ~trig_type2};
										end
										else begin
											trig_type3 <= {~trig_type3, ~trig_type3};
										end
										zero_trig_type <= 1'b1;
									end
									else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h01)begin
										data_store3 <= {8'hff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[15:0]};
										if(trig_en0)begin
											trig_type0 <= 2'b01;
										end
										else if(trig_en1) begin
											trig_type1 <= 2'b01;
										end
										else if(trig_en2) begin
											trig_type2 <= 2'b01;
										end
										else begin
											trig_type3 <= 2'b01;
										end
										zero_trig_type <= 1'b0;
									end
									else if({data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]}==8'h02)begin
										data_store3 <= {8'hff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[15:0]};
										if(trig_en0)begin
											trig_type0 <= 2'b10;
										end
										else if(trig_en1) begin
											trig_type1 <= 2'b10;
										end
										else if(trig_en2) begin
											trig_type2 <= 2'b10;
										end
										else begin
											trig_type3 <= 2'b10;
										end
										zero_trig_type <= 1'b0;
									end
									else begin
										trig_type0 <= trig_type0;
										trig_type1 <= trig_type1;
										trig_type2 <= trig_type2;
										trig_type3 <= trig_type3;
										zero_trig_type <= zero_trig_type;
										data_store3 <= {16'hffff,data_store3[15:0]};
									end
								end
								else begin
									data_store3 <= {16'hffff,data_store3[15:0]};
								end
							end
							else if(h5C==1'b1)begin
								data_store3 <= {8'hff,8'hff,data_store3[15:0]};
							end
							
							else if(hA5==1'b1)begin
								data_store3 <= {8'hff,data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[0][15:0]};
							end
							else if(h00==1'b1)begin
								if(v_ind==3'd1)begin
									data_store3 <= {8'hff,vctrout_ch0[7:0],data_store3[15:0]};
								end
								else if(v_ind==3'd2)begin
									data_store3 <= {8'hff,vctrout_ch1[7:0],data_store3[15:0]};
								end
								else if(v_ind==3'd3)begin
									data_store3 <= {8'hff,vctrout_ch2[7:0],data_store3[15:0]};
								end
								else if(v_ind==3'd4)begin
									data_store3 <= {8'hff,vctrout_ch3[7:0],data_store3[15:0]};
								end
								else begin
									data_store3 <= {16'hffff,data_store3[15:0]};
								end
							end
							else begin
								data_store3 <= 32'hffffffff;
							end
						end
						else if(byte_count==5'd4)begin ////////////////////////////////////////////////////////////////////////////////////////////////////////
							data_store2[0] <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store2[0][23:0]};
							if(h53==1'b1)begin
								if(trig_en0 ||trig_en1 || trig_en2 ||trig_en3)begin
									data_store3 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[23:0]};
									if(trig_en0 && trig_type0!=2'b11 && !zero_trig_type)begin
										trig_val0 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
									end
									else if(trig_en1 && trig_type1!=2'b11 && !zero_trig_type)begin
										trig_val1 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
									end
									else if(trig_en2 && trig_type2!=2'b11 && !zero_trig_type)begin
										trig_val2 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
									end
									else if(trig_en3 && trig_type3!=2'b11 && !zero_trig_type)begin
										trig_val3 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7]};
									end
									else begin
										trig_val0 <= trig_val0;
										trig_val1 <= trig_val1;
										trig_val2 <= trig_val2;
										trig_val3 <= trig_val3;
									end
										
								end
								else begin
									data_store3 <= {8'hff,data_store3[23:0]};
									trig_val0 <= trig_val0;
									trig_val1 <= trig_val1;
									trig_val2 <= trig_val2;
									trig_val3 <= trig_val3;
								end
							end
							else if(hA5==1'b1)begin
								data_store3 <= {data_store[0],data_store[1],data_store[2],data_store[3],data_store[4],data_store[5],data_store[6],data_store[7],data_store3[23:0]};
							end
							else if(h5C==1'b1)begin
								data_store3 <= {8'hff,data_store3[23:0]};
							end
							else if(h00==1'b1)begin
								data_store3 <= {8'hff,data_store3[23:0]};
							end
							else begin
								data_store3 <= 32'hffffffff;
							end
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
				txD <= 1;
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
								if(byte_count2>=4)begin
									txD <= 1;
								end
								else if(h5C==1'b1 && byte_count2>=2)begin
									txD <= 1;
								end
								else if(h00==1'b1 && byte_count2>2)begin
									txD <= 1;
								end
								else if(byte_count==5'd0 &&(h00==1 || hA5==1 || h53==1 || h5C==1))begin
									txD <= 1;
								end
								else if(!h00 && !hA5 && !h53 && !h5C)begin
									txD <= 1;
								end
								else begin
									txD <= 0;
								end
							end
							else begin
								if(byte_count2<=5'd3) begin
									tx <= data_store2[0][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[0] <= {1'b0,data_store2[0][31:1]};
									if(h00==1'b1 && byte_count==5'd2)begin
										byte_count <= byte_count +1; 
										txD <= data_store3[0];
										data_store3 <= {1'b1,data_store3[31:1]};
									end
									else begin
										txD <= data_store3[0];
										data_store3 <= {1'b1,data_store3[31:1]};
									end
								end
								else if(byte_count2>5'd3 && byte_count2<=5'd7) begin
									tx <= data_store2[1][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[1] <= {1'b0,data_store2[1][31:1]};
									txD <= data_store3[0];
									data_store3 <= {1'b1,data_store3[31:1]};
								end
								else if(byte_count2>5'd7 && byte_count2<=5'd11) begin
									tx <= data_store2[2][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[2] <= {1'b0,data_store2[2][31:1]};
									txD <= data_store3[0];
									data_store3 <= {1'b1,data_store3[31:1]};
								end
								else if(byte_count2>5'd11 && byte_count2<=5'd15) begin
									tx <= data_store2[3][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[3] <= {1'b0,data_store2[3][31:1]};
									txD <= data_store3[0];
									data_store3 <= {1'b1,data_store3[31:1]};
								end
								else if(byte_count2>5'd15 && byte_count2<=5'd19) begin
									tx <= data_store2[4][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[4] <= {1'b0,data_store2[4][31:1]};
									txD <= data_store3[0];
									data_store3 <= {1'b1,data_store3[31:1]};
								end
								else begin
									tx <= data_store2[5][0]; ////////////////////////////////////////////////// 2b. ACTUAL TRANSMISSION
									data_store2[5] <= {1'b0,data_store2[5][31:1]};
									txD <= data_store3[0];
									data_store3 <= {1'b1,data_store3[31:1]};
								end
							end
						end
						else begin
							tx <= 1;
							txD <= 1;
						end
			
						bit_count3 <= bit_count3 + 5'd1;
					end
					else begin
						bit_count3 <= 5'd0;
						byte_count2 <= byte_count2 + 5'd1;
					end
				end
			end
			
			
			if(!nrst || (!h5C_en0 && !h5C_en1 && !h5C_en2 && !h5C_en3) || data_store3[31:0]==32'hffffff53)begin
				if(!nrst)begin
					trigout_ch0 <= 0;
					trigout_ch1 <= 0;
					trigout_ch2 <= 0;
					trigout_ch3 <= 0;
				end
				else begin
					trigout_ch0 <= trigout_ch0;
					trigout_ch1 <= trigout_ch1;
					trigout_ch2 <= trigout_ch2;
					trigout_ch3 <= trigout_ch3;
				end
				count4 <= 0;
				bit_count4 <= 0;
				byte_count4 <= 0;
			end
			else begin
				if(count4!=95)begin ///////////////////////////////Adjust this, so the pulses of trig out is visible on logic analyzer..
					count4 <= count4 +20'b1;
				end
				else begin
					count4 <= 20'b0;
					if(bit_count4!=5'd9)begin
						if(bit_count4<5'd5)begin
							if(trig_type0 != 2'b10)begin////////
								if(h5C_en0)begin
									trigout_ch0 <= 1'b1;
								end
								else begin
									trigout_ch0 <= trigout_ch0;
								end
							end
							else begin
								if(h5C_en0)begin
									trigout_ch0 <= 1'b0;
								end
								else begin
									trigout_ch0 <= trigout_ch0;
								end
							end
							if(trig_type1 != 2'b10)begin////////
								if(h5C_en1)begin
									trigout_ch1 <= 1'b1;
								end
								else begin
									trigout_ch1 <= trigout_ch1;
								end
							end
							else begin
								if(h5C_en1)begin
									trigout_ch1 <= 1'b0;
								end
								else begin
									trigout_ch1 <= trigout_ch1;
								end
							end
							if(trig_type2 != 2'b10)begin////////
								if(h5C_en2)begin
									trigout_ch2 <= 1'b1;
								end
								else begin
									trigout_ch2 <= trigout_ch2;
								end
							end
							else begin
								if(h5C_en2)begin
									trigout_ch2 <= 1'b0;
								end
								else begin
									trigout_ch2 <= trigout_ch2;
								end
							end
							if(trig_type3 != 2'b10)begin////////
								if(h5C_en3)begin
									trigout_ch3 <= 1'b1;
								end
								else begin
									trigout_ch3 <= trigout_ch3;
								end
							end
							else begin
								if(h5C_en3)begin
									trigout_ch3 <= 1'b0;
								end
								else begin
									trigout_ch3 <= trigout_ch3;
								end
							end
						end
						else begin/////////////////////////////////////////////
							if(trig_type0 != 2'b10)begin//////////
								if(h5C_en0)begin
									trigout_ch0 <= 1'b0;
								end
								else begin
									trigout_ch0 <= trigout_ch0;
								end
							end
							else begin
								if(h5C_en0)begin
									trigout_ch0 <= 1'b1;
								end
								else begin
									trigout_ch0 <= trigout_ch0;
								end
							end
							if(trig_type1 != 2'b10)begin//////////
								if(h5C_en1)begin
									trigout_ch1 <= 1'b0;
								end
								else begin
									trigout_ch1 <= trigout_ch1;
								end
							end
							else begin
								if(h5C_en1)begin
									trigout_ch1 <= 1'b1;
								end
								else begin
									trigout_ch1 <= trigout_ch1;
								end
							end
							if(trig_type2 != 2'b10)begin//////////
								if(h5C_en2)begin
									trigout_ch2 <= 1'b0;
								end
								else begin
									trigout_ch2 <= trigout_ch2;
								end
							end
							else begin
								if(h5C_en2)begin
									trigout_ch2 <= 1'b1;
								end
								else begin
									trigout_ch2 <= trigout_ch2;
								end
							end
							if(trig_type3 != 2'b10)begin//////////
								if(h5C_en3)begin
									trigout_ch3 <= 1'b0;
								end
								else begin
									trigout_ch3 <= trigout_ch3;
								end
							end
							else begin
								if(h5C_en3)begin
									trigout_ch3 <= 1'b1;
								end
								else begin
									trigout_ch3 <= trigout_ch3;
								end
							end
						end
						bit_count4 <= bit_count4 + 1;
					end
					else begin
						if(h5C_en0 && h5C)begin
							if(trig_val0!= byte_count4+1 && trig_val0!=0)begin//////////
								byte_count4 <= byte_count4 + 1;
								bit_count4 <= 0;
							end
							else begin
								byte_count4 <= byte_count4;
								bit_count4 <= bit_count4;
							end
						end
						else if(h5C_en1 && h5C)begin
							if(trig_val1!= byte_count4+1 && trig_val1!=0)begin//////////
								byte_count4 <= byte_count4 + 1;
								bit_count4 <= 0;
							end
							else begin
								byte_count4 <= byte_count4;
								bit_count4 <= bit_count4;
							end
						end
						else if(h5C_en2 && h5C)begin
							if(trig_val2!= byte_count4+1 && trig_val2!=0)begin//////////
								byte_count4 <= byte_count4 + 1;
								bit_count4 <= 0;
							end
							else begin
								byte_count4 <= byte_count4;
								bit_count4 <= bit_count4;
							end
						end
						else if(h5C_en3 && h5C)begin
							if(trig_val3!= byte_count4+1 && trig_val3!=0)begin//////////
								byte_count4 <= byte_count4 + 1;
								bit_count4 <= 0;
							end
							else begin
								byte_count4 <= byte_count4;
								bit_count4 <= bit_count4;
							end
						end
						else begin
							byte_count4 <= byte_count4;
							trigout_end <= trigout_end;
						end
						
					end
				end
			end
		end ///
	assign busy = (busy1 ^ busy2);

	
/////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
