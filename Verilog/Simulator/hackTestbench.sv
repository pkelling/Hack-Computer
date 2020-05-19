module HackComp;

  /* CPU Inputs */
  wire [0:15] instruction, ramDin;
  reg clk;
  
  /* CPU Outputs */
  wire [0:15] ramDout;
  wire [0:14] ramAddr, instrAddr;
  wire ramStore;
  
  
  RAM ram(ramDin, ramDout, ramAddr, ramAddr, ramStore, clk);
  
  ROM rom(instruction, instrAddr); 
  
  CPU cpu(instruction, instrAddr, ramAddr, ramDin, ramDout, ramStore, clk);
  
  /* //Monitor for Sum
  initial
    $monitor($time,"  @i= %-d @sum= %-d",ram.mem[16], ram.mem[17]);
  */
  
  // Monitor for multiply 
  initial
    $monitor($time, "  a=%-d b=%-d a*b=%-d",ram.mem[0],ram.mem[1],ram.mem[2]);
    
    
  initial
    clk = 0;
  
  always
    #5 clk = ~clk;
  
  initial
    begin
       #20000 $finish;
    end
		
endmodule
