module clock_check;
  
  reg clk30M = 1'b0;
  reg nrst;
  //30Mhz is 0.3ns in one period
  always #150 clk30M <= ~clk30M;
  wire tx=1'b1;
  wire clk_puls;
  reg [11:0] clkdiv = 12'b0;
  always @(posedge clk30M & nrst) 
	  clkdiv <= clkdiv+12'd1; 	
  always @(!nrst)
	  clkdiv <= 12'b0;
  assign clk_puls  = clkdiv[11:0]==12'd3125;
  always @(posedge clk30M & nrst)
	  if(clk_puls==1)
		  clkdiv <= 12'd0;
 
  initial
  begin
	nrst=0;
	#600;
	nrst =1;
    #150110000;
	nrst=0;
	#20;
    //$finish();
  end
  initial 
  begin 
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule
