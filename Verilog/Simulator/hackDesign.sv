module CPU(instruction, instrAddr, ramAddr, ramDin, ramDout, ramStore, clk);
  
  /* ramDin -> data out of ram into cpu */
  /* instruction -> 16 bit CPU instruction */
  input [0:15] instruction, ramDin;
  input clk;
    
  /* ramAddr -> address in RAM to set or get value */
  /* ramDout	->  output value into ram */
  output [0:15] ramDout;
  output [0:14] ramAddr, instrAddr;
  output ramStore;
  
  
  /* How CPU Works
  *
  *		In CPU there are 2 registers (A & D).
  *		Outside CPU is RAM for storage and ROM for instructions.
  *
  *
  *		CPU takes 16 Bit instruction:
  *
  *		If most significant bit [0] is 0, set register A to next 15 bits [1:15].
  *			-This is the only way to put value into CPU, RAM, registers, etc.
  * 
  *		If MSB [0] is 1, the instruction is a compute instruction:
  *			
  *			-register D is x (for ALU input)
  *			
  *			-the 'a' bit is bit [3] 
  *				if [3] = 0, use A register as y into ALU
  *				if [3] = 1, use RAM[A] as y into ALU
  *			
  *			-bits [4-9] specify the alu instruction: (zx, nx, zy, ny, f, no) respectively
  *			
  *			-bits [10-12] specify the destination of ALU output
  *				[10] = 1 -> store o in RAM at address specified by register A
  *				[11] = 1 -> store o in D register
  *				[12] = 1 -> store o in A register
  *				Note: if [10] and [12] are 1, you need to read A as addr, then store new A
  *			
  *			-bits [13-15] specify a jump in instructions
  *				[13] = 1 -> jump if (o < 0)
  *				[14] = 1 -> jump if (o = 0)
  *				[15] = 1 -> jump if (o > 0)
  *				Note: 1 to of 3 can be specified. Jump to line [A] in ROM
  *
  */
  
  
  /* Create register input wires */
  wire [0:15] data_A, A;
  wire [0:15] data_D, D;
  wire [0:14] data_IA;
  
  /* Instantiate registers */
  Register16 A_Reg (data_A, clk, A);
  Register16 D_Reg (data_D, clk, D);
  Register15 instrAddrReg (data_IA, clk, instrAddr);
  
  
  /* Create ALU i/o wires */
  wire signed [0:15] x,y,o;
  
  
  /* assign ALU input wires */
  assign x = D;
  assign y = instruction[3]? ramDin : A;
  
  
  /* Instantiate ALU */
  ALU alu( x,y, instruction[4], instruction[5], instruction[6], instruction[7],
          instruction[8], instruction[9], o);
  
  
  
  /* Handle storage into register A and D inputs, and RAM output*/ 
  
  // assign data_A to either instruction (last 15 bits), A (do nothing), or o (ALU output), 
  assign data_A = (~instruction[0]) ? instruction[0:15] : ( instruction[10]? o : A );
  
  // assign data_D wire to either D (same value) or o
  assign data_D = (instruction[0] & instruction[11])? o : D;
  
  // Output value to RAM if needed
  assign ramAddr = A[1:15];
  assign ramDout = o;
  assign ramStore = (instruction[0] & instruction[12]);
    
  
  
  /* Handle Jump instruction ROM[A]  (Program Counter) */
  wire setInstrAddr;
  
  // Note, output is treated as 2s compliment, o[0] = 1 -> negative
  assign setInstrAddr = instruction[0] & ((o<0 & instruction[13]) ||
                                          (o==0 & instruction[14]) || 
                                          (o>0 & instruction[15]));
  
  assign data_IA = (setInstrAddr)? A[1:15] : instrAddr + 1;
  
endmodule



module ALU(x,y, zx, nx, zy, ny, f, no, o);

	input [0:15] x,y;
	output signed [0:15] o;
      
	input zx, nx, zy, ny, f, no;

	wire [0:15] x_step1, x_step2;
	wire [0:15] y_step1, y_step2;

	assign x_step1 = zx ? 16'h0000 : x;
	assign y_step1 = zy ? 16'h0000 : y;

	assign x_step2 = nx ? ~x_step1 : x_step1;
	assign y_step2 = ny ? ~y_step1 : y_step1;

	wire [0:15] o_step1;

  assign o_step1 = (f)? (x_step2 + y_step2) : (x_step2 & y_step2);

	assign o = no ? ~o_step1 : o_step1;


endmodule



module Register16 (D, Clk, Q);
  
  input [0:15] D;
  input Clk;
  output reg [0:15] Q;
  
  initial
    Q = 16'h0000;
  
  always @(posedge Clk)
  	Q <= D;
    
endmodule 


module Register15 (D, Clk, Q);
  
  input [0:14] D;
  input Clk;
  output reg [0:14] Q;
  
  initial
  	Q = 15'b0000_0000_0000_000;
  
  always @(posedge Clk)
  	Q <= D;
    
endmodule



module RAM(output [0:15] q,
                      input [0:15] d,
           			  input [0:14] write_address, read_address,
                      input we, clk);
  
  reg [0:15] mem [0:32767];
  always @ (posedge clk)
    begin
      if (we)
    	mem[write_address] = d;
    end
  
  assign q = mem[read_address];

  
endmodule



module ROM(output [0:15] q,
           input [0:14] read_address);
  
  reg [0:15] mem [0:32767];
      
  initial
   begin
     //  SUM of 3 + 3, then increment (ans 7)
     /*
     mem[0] = 16'b0000000000000011;
     mem[1] = 16'b1110110000010000;
     mem[2] = 16'b0000000000000011;
     mem[3] = 16'b1110000010010000;
     mem[4] = 16'b0000000000000000;
     mem[5] = 16'b1110001100001000;
     mem[6] = 16'b1111110111001000;
     mem[7] = 16'b0000000000000111;
     mem[8] = 16'b1110101010000111;
     */
     
     
     // Multiply 2 numbers (7*4)
     // load the numbers into memory
     
     // Sets num 1
     mem[0] = 16'b0000000000000111;
     mem[1] = 16'b1110110000010000;
     mem[2] = 16'b0000000000000000;
     mem[3] = 16'b1110001100001000;
     
     // Sets num 2
     mem[4] = 16'b0000000000000100;
     mem[5] = 16'b1110110000010000;
     mem[6] = 16'b0000000000000001;
     mem[7] = 16'b1110001100001000;
     
     // set ram[2] = 0
     mem[8] = 16'b0000000000000010;
     mem[9] = 16'b1110101010001000;
     
     // @time 105 (Next instruction occurs)
     // set ram[3] = 1
     mem[10] = 16'b0000000000000011;
     mem[11] = 16'b1110111111001000;
     
     // setting D=ram[0]
     mem[12] = 16'b0000000000000000;
     mem[13] = 16'b1111110000010000;
     
     mem[14] = 16'b0000000000000010;
     mem[15] = 16'b1111000010001000;
     mem[16] = 16'b0000000000000011;
     mem[17] = 16'b1111110111001000;
     
     // @time = 185
     mem[18] = 16'b1111110000010000;
     mem[19] = 16'b0000000000000001;
     
     // @time = 205  -> D=D-M
     mem[20] = 16'b1111010011010000;
     
     // @WHILE, jump if D <= 0
     mem[21] = 16'b0000000000001100;
     mem[22] = 16'b1110001100000110;
     
     // end loop
     mem[23] = 16'b0000000000010111;
     mem[24] = 16'b1110101010000111;
 
     
     
     
     /* // SUM from 1-100
     mem[0] = 16'b0000000000010000;
     mem[1] = 16'b1110111111001000;
     mem[2] = 16'b0000000000010001;
     mem[3] = 16'b1110101010001000;
     mem[4] = 16'b0000000000010000;
     mem[5] = 16'b1111110000010000;
     mem[6] = 16'b0000000001100100;
     mem[7] = 16'b1110010011010000;
     mem[8] = 16'b0000000000010010;
     mem[9] = 16'b1110001100000001;
     mem[10] = 16'b0000000000010000;
     mem[11] = 16'b1111110000010000;
     mem[12] = 16'b0000000000010001;
     mem[13] = 16'b1111000010001000;
     mem[14] = 16'b0000000000010000;
     mem[15] = 16'b1111110111001000;
     mem[16] = 16'b0000000000000100;
     mem[17] = 16'b1110101010000111;
     
     mem[18] = 16'b0000000000010010;
     mem[19] = 16'b1110101010000111;
     */
     
   end
  
  
  assign q = mem[read_address];
  
  
  
endmodule
