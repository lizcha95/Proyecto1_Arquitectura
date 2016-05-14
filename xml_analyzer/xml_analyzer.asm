;; **********************************************************************
;; File: xml_analyzer.asm
;; Authors: Liza Chaves Carranza [2013016573]
;;			Marisol González Coto [2014160604]
;;          Elberth Adrián Garro Sanchez [2014088081]
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
	;; numeric constants
	MAX_FILE_SZ equ 800 ; 4256
	;; two dots
	DOTS db ':'
	;; new line
	NEW_LINE db 10
	;; test1 strings
	test1_init: db 'Ejecutando verificación de tags individuales en xml...', 10
		.len: equ $-test1_init
	error1_test1: db 'Error: falta < antes de > en '
		.len: equ $-error1_test1
	error2_test1: db 'Error: falta > después de < en '
		.len: equ $-error2_test1
	test1_end: db 'La verificación de tags individuales en xml ha finalizado.', 10
		.len: equ $-test1_end
	;; test2 strings
	test2_init: db 'Ejecutando verificación de comillas dobles en xml...', 10
		.len: equ $-test2_init
	error_test2: db 'Error: Ausencia de pareja de comillas en '
		.len equ $-error_test2
	test2_end: db 'La verificación de comillas dobles en xml ha finalizado.', 10
		.len: equ $-test2_end
	;; test3 strings
	test3_init: db 'Ejecutando verificación de comillas simples en xml...', 10
		.len: equ $-test3_init
	error_test3: db 'Error: Ausencia de pareja de comillas en '
		.len equ $-error_test3
	test3_end: db 'La verificación de comillas simples en xml ha finalizado.', 10
		.len: equ $-test3_end

;; **********************************************************************
;; section containing non initialized data
;; **********************************************************************

section .bss
	in_file resb MAX_FILE_SZ
	file_to_parse resb MAX_FILE_SZ
	out_file resb MAX_FILE_SZ

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
	run_test1:
		;call individual_tag_test
	run_test2:
		;call complex_quotes_test
	run_test3:
		call simple_quotes_test
	finish_analyzing:
		exit

;; **********************************************************************
;; Procedures
;; **********************************************************************

;;
;; get_curr_line: get the current line where r12 buffer index is
;;				  r11 will contain the result
;;

get_curr_line:
	;; auxiliar buffer index
	mov r10, r12
	;; contain the number of new lines
	mov r11, 1
	.loop:
		;; increment and compare
		dec r10
		;; test aux buffer index (r10) against 0
		cmp r10, 0
		if e
			;; end count
			ret
		endif
	.count_new_lines:
		;; test the current byte on buffer against '\n'
		cmp byte [file_to_parse+r10], 10
		if e
			;; store lines quant
			inc r11
		endif
		jmp .loop

;;
;; get_curr_col: get the current column where r12 buffer index is
;;               r11 will have the result
;;

get_curr_col:
	;; auxiliar buffer index
	mov r10, r12
	;; contain the number of columns
	mov r11, 1
	.loop:
		;; decrement and compare
		dec r10
		;; test aux buffer index (r10) against new line (\n)
		cmp byte [file_to_parse+r10], 10
		if e
			;; end count
			ret
		endif
	.count_cols:
		inc r11
		jmp .loop

;;
;; write_int: write on display the ascii representation of integer
;; params: rax is register with a number to be writed
;;

write_int:
	;; save stack pointer
	mov r15, rsp
    ;; number counter
    mov rcx, 0
    itoa:
        ;; reminder from division
        mov	rdx, 0
        ;; base
        mov	rbx, 10
        ;; rax = rax / 10
        div	rbx
        ;; add \0
        add	rdx, 48
        add	rdx, 0x0
        ;; push reminder to stack
        push rdx
        ;; go next
        inc	rcx
        ;; check factor with 0
        cmp	rax, 0
        ;; loop again
        jne	itoa
    write_result:
        ;; calculate number length
        lea rdx, [rcx * 8]
        ;; write number in ascii representation
        write rsp, rdx
    restore_stack:
		mov rsp, r15
		ret

;;
;; individual_tag_test: check individual tags candidates in xml file
;;

individual_tag_test:
	;; write init message
	write test1_init, test1_init.len
	;; buffer index
	mov r8, -1
	;; flag to check_tag_candidate
	mov r9, 0
	.loop:
		;; increment and compare
		inc r8
		cmp r8, MAX_FILE_SZ
		if e
			;; write end message
			write test1_end, test1_end.len
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
			;; turn on check_tag_candidate
			mov r9, 1
		else
			cmp byte [file_to_parse+r8], '>'
			if e
				;; save index of error
				mov r12, r8
				;; write error
				write error1_test1, error1_test1.len
				call get_curr_line
				mov rax, r11
				call write_int
				write DOTS, 1
				call get_curr_col
				mov rax, r11
				call write_int
				write NEW_LINE, 1
			endif
		endif
		;; keep searching...
		jmp .loop
	.check_tag_candidate:
		cmp byte [file_to_parse+r8], '>'
		if e
			;; turn off check_tag_candidate
			mov r9, 0
			;; save index of possible error
			mov r12, r8
		else
			cmp byte [file_to_parse+r8], '<'
			if e
				;; write error
				write error2_test1, error2_test1.len
				call get_curr_line
				mov rax, r11
				call write_int
				write DOTS, 1
				call get_curr_col
				mov rax, r11
				call write_int
				write NEW_LINE, 1
			endif
		endif
		;; keep searching...
		jmp .loop

;;
;; complex_quotes_test: verify quotes candidates in xml file
;;

complex_quotes_test:
	;; write init message
	write test2_init, test2_init.len
	;; buffer index
	mov r12, -1
	;; flag to check_quote_candidate
	mov r9, 0
	.loop:
		;; increment and compare
		inc r12
		cmp r12, MAX_FILE_SZ
		if e
			;; write end message
			write test2_end, test2_end.len
			;; end test
			ret
		endif
		;; goto search_quote or check_quote
		cmp r9, 0
		if e
			jmp .search_quote_candidate
		else
			jmp .check_quote_candidate
		endif
	.search_quote_candidate:
		;; compare current char against "
		cmp byte [file_to_parse+r12], '"'
		if e
			;; turn on check_quote_candidate
			mov r9, 1
		endif
		;; keep searching...
		jmp .loop
	.check_quote_candidate:
		;; compare current char against "
		cmp byte [file_to_parse+r12], '"'
		if e
			;; turn off check_quote_candidate
			mov r9, 0
		else
			;; test the byte on buffer against '-'
			;; if char < 'a'
			cmp byte [file_to_parse+r12], 45
			if b
				;; write error
				write error_test2, error_test2.len
				call get_curr_line
				mov rax, r11
				call write_int
				write DOTS, 1
				call get_curr_col
				mov rax, r11
				call write_int
				write NEW_LINE, 1
			else
				;; test the byte on buffer against 'z'
				;; if char > 'z'
				cmp byte [file_to_parse+r12], 'z'
				if a
					;; write error
					write error_test2, error_test2.len
					call get_curr_line
					mov rax, r11
					call write_int
					write DOTS, 1
					call get_curr_col
					mov rax, r11
					call write_int
					write NEW_LINE, 1
				endif
			endif
		endif
		;; keep searching...
		jmp .loop

;;
;; simple_quotes_test: verify quotes candidates in xml file
;;

simple_quotes_test:
	;; write init message
	write test3_init, test3_init.len
	;; buffer index
	mov r12, -1
	;; flag to check_quote_candidate
	mov r9, 0
	.loop:
		;; increment and compare
		inc r12
		cmp r12, MAX_FILE_SZ
		if e
			;; write end message
			write test3_end, test3_end.len
			;; end test
			ret
		endif
		;; goto search_quote or check_quote
		cmp r9, 0
		if e
			jmp .search_quote_candidate
		else
			jmp .check_quote_candidate
		endif
	.search_quote_candidate:
		;; compare current char against '
		cmp byte [file_to_parse+r12], 39
		if e
			;; turn on check_quote_candidate
			mov r9, 1
		endif
		;; keep searching...
		jmp .loop
	.check_quote_candidate:
		;; compare current char against '
		cmp byte [file_to_parse+r12], 39
		if e
			;; turn off check_quote_candidate
			mov r9, 0
		else
			;; test the byte on buffer against '-'
			;; if char < 'a'
			cmp byte [file_to_parse+r12], 45
			if b
				;; write error
				write error_test3, error_test3.len
				call get_curr_line
				mov rax, r11
				call write_int
				write DOTS, 1
				call get_curr_col
				mov rax, r11
				call write_int
				write NEW_LINE, 1
			else
				;; test the byte on buffer against 'z'
				;; if char > 'z'
				cmp byte [file_to_parse+r12], 'z'
				if a
					;; write error
					write error_test3, error_test3.len
					call get_curr_line
					mov rax, r11
					call write_int
					write DOTS, 1
					call get_curr_col
					mov rax, r11
					call write_int
					write NEW_LINE, 1
				endif
			endif
		endif
		;; keep searching...
		jmp .loop
