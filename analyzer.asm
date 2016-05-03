;; ******************************************
;; File: analyzer.asm
;; Authors: Liza Chaves Carranza [2013]
;;          Marisol González Coto [2014]
;;          Elberth Adrian Garro Sanchez [2014088081]
;; Utility: Analyze XML-HTML Code
;; Built with NASM Linux 64 bits
;; Copyright 2016 TEC
;; ******************************************

;; ******************************************
;; Instructions for run this code:
;; Open terminal
;; Locate the code with cd, in my case:
;; cd '/media/psf/Home/Proyectos/NASM x64/Proyecto1_Arquitectura'
;; then write make
;; and finally write ./analyzer < file.extension
;; ******************************************

;;
;; Include Macros Library
;;
%include 'macros.mac'
;;
;; section containing initialized data
;;
section .data
	MAX_FILE_SZ equ 15 ; 4256
	new_line: db 0xa
		.len: equ $-new_line
;;
;; section containing non initialized data
;;
section .bss
	in_file resb MAX_FILE_SZ
;;
;; section containing code
;;
section .text
	global _start
_start:
	read in_file, MAX_FILE_SZ
	write in_file, MAX_FILE_SZ
	write new_line, new_line.len
	tolower in_file
	write in_file, MAX_FILE_SZ
	write new_line, new_line.len
	;; 03/05/16 4:19 pm continue here..
	exit
