;; **********************************************************************
;; File: xml_analyzer.asm
;; Authors: Elberth Adrián Garro Sanchez [2014088081]
;; Utility: Analyzes XML Code
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
	error1_test1: db 'Error: falta < antes de > en: x,y', 10
		.len: equ $-error1_test1
	error2_test1: db 'Error: falta > después de < en: x,y', 10
		.len: equ $-error2_test1

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
	test1:
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
		;; go to search_tag or check_tag
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
				write error1_test1, error1_test1.len
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
				write error2_test1, error2_test1.len
				mov r9, 0
			endif
		endif
		jmp .loop

;;
;; Proc 2
;;
