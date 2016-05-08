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
;; and finally write ./xml_analyzer < file.xml
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
		;; file read and process...
		read in_file, MAX_FILE_SZ
		copy_buffer in_file, file_to_parse
		to_lower file_to_parse
	individual_tag_test:
		mov dl, '<'
		call find_char
	debug:
		;; write file
		write r9, MAX_FILE_SZ
		;; write new line
		write new_line, new_line.len
	exit
;; find_char: search a char in a buffer
;; params: al reg has the character that is required to find
;;
find_char:
    ;; r8 will know if the search was succesful
    ;; 0 means that the search was not ok
    ;; 1 means that the search was ok
    mov r8, 0
    ;; for (int i=0; i<MAX_FILE_SZ; ++i)
    %assign i 0
    %rep MAX_FILE_SZ
        ;; test the byte on buffer against the search char
        cmp byte [file_to_parse+i], dl
        ;; if current char is equal to search char
        if e
            ;; save search status
            mov r8, 1
            ;; r9 saves the current char adress
            mov r9, file_to_parse+i
            ret
        endif
    %assign i i+1
    %endrep
