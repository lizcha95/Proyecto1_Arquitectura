;; **********************************************************************
;; File: xml_analyzer.asm
;; Authors: Elberth Adrian Garro Sanchez [2014088081]
;; Utility: Analyze XML Code
;; Built with NASM Linux 64 bits
;; Copyright 2016 TEC
;;
;; Instructions for run this code:
;; Open Linux terminal
;; Locate the code with cd, in my case:
;; cd '/media/psf/Home/Proyectos/NASM x64/Proyecto1_Arquitectura/xml_analyzer'
;; then write make
;; and finally write ./xml_analyzer < test.xml
;; **********************************************************************

;; **********************************************************************
;; include macros library
;; **********************************************************************
%include 'macros.mac'

;; **********************************************************************
;; section containing initialized data
;; **********************************************************************
section .data
	MAX_FILE_SZ equ 792 ; 4256
	err: db 'error de tag', 10
		.len: equ $-err

;; **********************************************************************
;; section containing non initialized data
;; **********************************************************************
section .bss
	in_file resb MAX_FILE_SZ
	file_to_parse resb MAX_FILE_SZ

;; **********************************************************************
;; section containing code
;; **********************************************************************
section .text
	global _start
_start:
	input_file:
		read in_file, MAX_FILE_SZ
		copy_buffer in_file, file_to_parse
		to_lower file_to_parse
	first_xml_test:
		call individual_tag_test
	end_test:
		exit

;; **********************************************************************
;; Procedures
;; **********************************************************************
;;
;; individual_tag_test: check individual tags candidates in xml file
;;
individual_tag_test:
	;; buffer index
	mov r8, -1
	;; boolean check_tag_candidate
	mov r9, 0
	.loop:
		;; increment and compare
		inc r8
		cmp r8, MAX_FILE_SZ
		if e
			;; end test
			ret
		endif
		;; goto search_tag or check_tag
		cmp r9, 0
		if e
			jmp .search_tag_candidate
		else
			jmp .check_tag_candidate
		endif
	.search_tag_candidate:
		cmp byte [file_to_parse+r8], '<'
		if e
			mov r9, 1
		else
			cmp byte [file_to_parse+r8], '>'
			if e
				;; error: falta '<' antes de '>' en línea: x,y
				write err, err.len
			endif
		endif
		jmp .loop
	.check_tag_candidate:
		cmp byte [file_to_parse+r8], '>'
		if e
			mov r9, 0
		else
			cmp byte [file_to_parse+r8], '<'
			if e
				;; error: falta '>' despues de '<' en línea: x,y
				write err, err.len
				mov r9, 0
			endif
		endif
		jmp .loop

;; **********************************************************************
