;; **********************************************************************
;; File: xml_analyzer.asm
;; Authors: Elberth Adrian Garro Sanchez [2014088081]
;; Utility: Analyze XML Code
;; Built with NASM Linux 64 bits
;; Copyright 2016 TEC
;; **********************************************************************
;; Instructions for run this code:
;; Open terminal
;; Locate the code with cd, in my case:
;; cd '/media/psf/Home/Proyectos/NASM x64/Proyecto1_Arquitectura/xml_analyzer'
;; then write make
;; and finally write ./xml_analyzer < test.xml
;; **********************************************************************
;;
;; include macros library
;;
%include 'macros.mac'
;;
;; section containing initialized data
;;
section .data
	MAX_FILE_SZ equ 35 ; 4256
	new_line: db 10
		.len: equ $-new_line
	;; debug byte
	dbg: db 'error'
		.len: equ $-dbg
;;
;; section containing non initialized data
;;
section .bss
	in_file resb MAX_FILE_SZ
	file_to_parse resb MAX_FILE_SZ
;;
;; section containing code
;;
section .text
	global _start
_start:
	input:
		;; file read and process...
		read in_file, MAX_FILE_SZ
		copy_buffer in_file, file_to_parse
		to_lower file_to_parse
	first_test:
		call individual_tag_test
	exit
;;
;; individual_tag_test: check individual tags candidates in xml file
;;
individual_tag_test:
	;; buffer index
	mov rcx, -1
	;; boolean check_tag
	mov r8, 0
	.loop:
		;; increment and compare
		inc rcx
		cmp rcx, MAX_FILE_SZ
		if e
			;; end test
			ret
		endif
		;; goto search_tag or check_tag
		cmp r8, 0
		if e
			jmp .search_tag_candidate
		else
			jmp .check_tag_candidate
		endif
	.search_tag_candidate:
		cmp byte [file_to_parse+rcx], '<'
		if e
			mov r8, 1
			jmp .loop
		else
			cmp byte [file_to_parse+rcx], '>'
			if e
				;; error: falta '<' antes de '>' en línea: x,y
				write dbg, dbg.len
				jmp .loop
			else
				jmp .loop
			endif
		endif
	.check_tag_candidate:
		cmp byte [file_to_parse+rcx], '>'
		if e
			mov r8, 0
			jmp .loop
		else
			cmp byte [file_to_parse+rcx], '<'
			if e
				;; error: falta '>' despues de '<' en línea: x,y
				write dbg, dbg.len
				write new_line, new_line.len
				mov r8, 0
				jmp .loop
			else
				jmp .loop
			endif
		endif
