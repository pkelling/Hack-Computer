Hack-Computer

This is a personal project to build a computer from scratch with a hack based instruction set with multiprocessing. 

This project starts from the first part of "The Elements of Computing Systems" which can also be found at https://www.nand2tetris.org/

The goal is to create a working hack-based cpu with multiprocessing that can run on an fpga. The I/O is memory mapped in this design, so it there won't be any emphasis on I/O except for debugging.

To see logisim examples, download the .circ files and open them in logisim. You can replace the multiplication program with anything you want, just load it into the ROM.

For writing new programs:
They are written in an assembly language defined in the book, then compiled with the assembler tool which can be downloaded at the nand2tetris website. Load the program into ROM using the logisim HEX editor (right click the ROM component).

How CPU Works
  *
  *		In CPU there are 2 registers (A & D).
  *		Outside CPU is RAM for storage and ROM for instructions.
  *
  *		CPU takes 16 Bit instruction:
  *
  *		If most significant bit instr[0] is 0, set register A to next 15 bits instruction[1:15].
  *			-This is the only way to put a value into CPU, RAM, registers, etc.
  * 
  *		If MSB instr[0] is 1, the instruction is a compute instruction:
  *			
  *			-register D is x (for ALU input)
  *			
  *			-the 'a' bit is bit [3] 
  *				if instr[3] = 0, use A register as y into ALU
  *				if instr[3] = 1, use RAM[A] as y into ALU
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
  *				Note: This jumps to line [A] in ROM
  *
