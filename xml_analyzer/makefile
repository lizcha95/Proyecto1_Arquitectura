#******************************************
# File: makefile
# Author: Elberth Adrian Garro Sanchez [2014088081]
# Utility: simple makefile for xml_analyzer
#******************************************

#program to use as the assembler
ASM=nasm
#flags for the assember
ASM_F=-f elf64
#program to use as linker
LINKER=ld
#link executable
xml_analyzer: xml_analyzer.o
	@$(LINKER) -o xml_analyzer xml_analyzer.o
#assemble source code
xml_analyzer.o: xml_analyzer.asm
	@$(ASM) $(ASM_F) -o xml_analyzer.o xml_analyzer.asm
