# Hack-Computer

This is a personal project to build a computer from scratch with a hack based instruction set with multiprocessing. 

This project started from the first part of "The Elements of Computing Systems" which can also be found at https://www.nand2tetris.org/

The goal is to create a working hack-based cpu with multiprocessing that can run on an fpga. The I/O is memory mapped in this design, so it there won't be any emphasis on I/O except for debugging.

### To see logisim examples: 
Download the .circ files in Logisim folder and open them in logisim. You can replace the multiplication program with anything you want, just load it into the ROM.

### Simulated Examples on Eda Playground
* Hack Single Core Computer: https://www.edaplayground.com/x/2fWX

### For writing new programs:
They are written in an assembly language defined in the book, then compiled with the assembler tool which can be downloaded at the nand2tetris website. Load the program into ROM using the logisim HEX editor either by tying in the commands, or you can convert the binary numbers in the file to Logisim's hex format (right click the ROM component).

### How CPU Works:

* In CPU there are 2 registers (A & D).
* Outside CPU is RAM for storage and ROM for instructions.
* CPU takes 16 Bit instructions.
    + A load instruction loads a 15 bit number into A register
        - 0### #### #### ####   (spaces added for clarity)
    + A compute instruction has the following format
        - 111a cccc ccdd djjj
        - 'a' specifies the second ALU input (Either register A or ram[A])
        - 'c' is the op code for the ALU
        - 'd' specifies where to store ALU output (A,D,ram[A])
        - 'j' specifies jump instruction to rom[A] (ALU output <0 ==0 or >0 )
* More information on the instruction set can be found in Chapter 4 of the book.
  

### Hack CPU Core
![Hack CPU in Logisim](Images/hack-cpu.png?raw=true "CPU Core")

### Single Core Computer Running Multiplication Program in Logisim:
![Hack Computer in Logisim](Images/hack-multiply.gif?raw=true "Multiplication Program")
