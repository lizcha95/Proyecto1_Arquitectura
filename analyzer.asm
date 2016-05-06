;; **********************************************************************
;; File: analyzer.asm
;; Authors: Liza Chaves Carranza [2013]
;;          Marisol González Coto [2014]
;;          Elberth Adrian Garro Sanchez [2014088081]
;; Utility: Analyze XML Code
;; Built with NASM Linux 64 bits
;; Copyright 2016 TEC
;; **********************************************************************
;; Instructions for run this code:
;; Open terminal
;; Locate the code with cd, in my case:
;; cd '/media/psf/Home/Proyectos/NASM x64/Proyecto1_Arquitectura'
;; then write make
;; and finally write ./analyzer < file.extension
;; **********************************************************************
;;
;; include macros library
;;
%include 'macros.mac'
;;
;; section containing initialized data
;;
section .data
	MAX_FILE_SZ equ 15 ; 4256
	new_line: db 10
		.len: equ $-new_line
	dbg: db 'xD'
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
		;; file read and process
		read in_file, MAX_FILE_SZ
		copy_buffer in_file, file_to_parse
		to_lower file_to_parse
	tag_test:
		find_char file_to_parse, '<'
	debug:
		;; write file
		write r9, MAX_FILE_SZ
		;; write new line
		write new_line, new_line.len
	exit
