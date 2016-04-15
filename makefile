#******************************************
# File: makefile
# Author: Elberth Adrian Garro Sanchez [2014088081]
# Utility: simple makefile for test
#******************************************

#program to use as the assembler
ASM=nasm
#flags for the assember
ASM_F=-f elf64
#program to use as linker
LINKER=ld
#link executable
test: test.o
	$(LINKER) -o test test.o
#assemble source code
test.o: test.asm
	$(ASM) $(ASM_F) -o test.o test.asm
