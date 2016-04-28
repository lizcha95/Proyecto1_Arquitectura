#******************************************
# File: makefile
# Author: Elberth Adrian Garro Sanchez [2014088081]
# Utility: simple makefile for analyzer
#******************************************

#program to use as the assembler
ASM=nasm
#flags for the assember
ASM_F=-f elf64
#program to use as linker
LINKER=ld
#link executable
analyzer: analyzer.o
	$(LINKER) -o analyzer analyzer.o
#assemble source code
analyzer.o: analyzer.asm
	$(ASM) $(ASM_F) -o analyzer.o analyzer.asm
