# Hack-Computer

This is a personal project to build a computer from scratch with a hack based instruction set with multiprocessing. 

This project starts from the first part of "The Elements of Computing Systems" which can also be found at https://www.nand2tetris.org/

The goal is to create a working hack-based cpu with multiprocessing that can run on an fpga. The I/O is memory mapped in this design, so it there won't be any emphasis on I/O except for debugging.

### To see logisim examples: 
Download the .circ files and open them in logisim. You can replace the multiplication program with anything you want, just load it into the ROM.

### For writing new programs:
They are written in an assembly language defined in the book, then compiled with the assembler tool which can be downloaded at the nand2tetris website. Load the program into ROM using the logisim HEX editor (right click the ROM component).

### How CPU Works:

* In CPU there are 2 registers (A & D).
* Outside CPU is RAM for storage and ROM for instructions
* CPU takes 16 Bit instructions

For more information, check out the book. 
  
