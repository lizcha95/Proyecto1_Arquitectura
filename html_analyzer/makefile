#******************************************
# File: makefile
# Author: Elberth Adrian Garro Sanchez [2014088081]
# Utility: simple makefile for html_analyzer
#******************************************

#program to use as the assembler
ASM=nasm
#flags for the assember
ASM_F=-f elf64
#program to use as linker
LINKER=ld
#link executable
html_analyzer: html_analyzer.o
	$(LINKER) -o html_analyzer html_analyzer.o
#assemble source code
html_analyzer.o: html_analyzer.asm
	$(ASM) $(ASM_F) -o html_analyzer.o html_analyzer.asm
