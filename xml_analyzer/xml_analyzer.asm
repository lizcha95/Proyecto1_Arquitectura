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
	test_errores: db 'Hay errores', 10
		.len: equ $-test_errores
	rows: db "Hay x filas", 10
		.len: equ $-rows

;; **********************************************************************
;; section containing non initialized data
;; **********************************************************************

section .bss
	in_file resb MAX_FILE_SZ
	file_to_parse resb MAX_FILE_SZ
	file_to_ident resb 792

;; **********************************************************************
;; section containing code
;; **********************************************************************

section .text
	global _start
_start:

	xor r11, r11

	input_file:
		read in_file, MAX_FILE_SZ
		copy_buffer in_file, file_to_parse
		to_lower file_to_parse
	test1:
		call individual_tag_test
		call indentation
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
	;; flag to see if there is any error in the file
	mov r10, 0

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
				mov r10, 1
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
				mov r10, 1
			endif
		endif
		jmp .loop

;;
;; Procedure to correct indentation, creation of new file
;;

indentation:

	;; counter for file_to_parse buffer
	xor r11, r11
	;; counter for tags
	xor r12, r12
	;; counter for file_to_ident buffer
	xor r13, r13

	.comprobar:
		cmp r10, 1
			if e
				write test_errores, test_errores.len
			endif		
		ret

	.loop:

	;; Revisa si el file_to_parse llegó al final
	cmp byte[file_to_parse+r11], 0
	;; Si llegó al final, imprime file_to_ident
	if e
		write file_to_indent, r13
	;; Sino entonces sigue comparando todos los caracteres de file_to_parse
	else
		cmp byte[file_to_parse+r11], '<'
		if e
			;; Si es un tag, incrementa el contador de tags, y lo agrega a file_to_ident
			inc r12
			mov byte[file_to_indent+r13], [file_to_parse+r11]
			
			;; Ciclo para encontrar donde se cierra el tag
			.find_end_tag:
				inc r11
				inc r13
				cmp byte[file_to_parse+r11], '>'
				;; Si encuentra el tag que cierra, lo agrega a file_to_ident y agrega un cambio de línea
				if e
					mov byte[file_to_indent+r13], [file_to_parse+r11]
					inc r11
					inc r13
					mov byte[file_to_indent+r13], 10
					inc r13
					;; TODO: multiplicar r12 por 3, para hacer un ciclo que agregue los espacios en blanco



	jmp .loop

