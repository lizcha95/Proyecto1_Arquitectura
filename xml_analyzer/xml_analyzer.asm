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
	;; numeric constants
	MAX_FILE_SZ equ 792 ; 4256
	;; new line
	NEW_LINE db 10
	;; test1 strings
	test1_init: db 'Ejecutando verificación de tags individuales en xml...', 10
		.len: equ $-test1_init
	error1_test1: db 'Error: falta < antes de > en: '
		.len: equ $-error1_test1
	error2_test1: db 'Error: falta > después de < en: '
		.len: equ $-error2_test1

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
		call individual_tag_test
	finish_analyzing:
		exit

;; **********************************************************************
;; Procedures
;;
;; Registers:
;;			r8: aux_buffer_index, rsp backups
;;			r9: line_error_location
;;			r10: column_error_location
;;			r11: main_buffer_index
;;			r12: flag check_tag_candidate
;; **********************************************************************

;;
;; get_curr_line: get the current line where r11 buffer index is
;;				  r9 will contain the result
;;

get_curr_line:
	;; auxiliar buffer index
	mov r8, -1
	;; contain the number of new lines
	mov r9, -1
	.loop:
		;; increment and compare
		inc r8
		;; test aux buffer index (r8) against buffer index (r9)
		cmp r8, r11
		if e
			;; end count
			ret
		endif
	.count_new_lines:
		;; test the current byte on buffer against '\n'
		cmp byte [file_to_parse+r8], 10
		if e
			;; store lines quant
			inc r9
		endif
		jmp .loop

;;
;; get_curr_col: get the current column where r11 buffer index is
;;               r10 will have the result
;;

get_curr_col:
	;; auxiliar buffer index
	mov r8, r11
	;; contain the number of columns
	mov r10, -1
	.loop:
		;; decrement and compare
		dec r8
		;; test aux buffer index (r8) against new line (\n)
		cmp r8, 10
		if e
			;; end count
			ret
		else
			;; store columns quant
			inc r10
		endif
		jmp .loop

;;
;; write_integer: write on display the ascii representation of integer
;; params: rax is register with a number to be writed
;;

write_integer:
	;; save stack pointer
	mov r8, rsp
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
    clean_stack:
		mov rsp, r8
		ret

;;
;; individual_tag_test: check individual tags candidates in xml file
;;

individual_tag_test:
	;; initial message
	write test1_init, test1_init.len
	;; start buffer index
	mov r11, -1
	;; start flag to check_tag_candidate
	mov r12, 0
	.loop:
		;; increment and compare
		inc r11
		cmp r11, MAX_FILE_SZ
		if e
			;; end test
			ret
		endif
		;; go to search_tag or check_tag
		cmp r12, 0
		if e
			jmp .search_tag_candidate
		else
			jmp .check_tag_candidate
		endif
	.search_tag_candidate:
		cmp byte [file_to_parse+r11], '<'
		if e
			mov r12, 1
		else
			cmp byte [file_to_parse+r11], '>'
			if e
				;; write error location
				write error1_test1, error1_test1.len

				call get_curr_line
				mov rax, r9
				call write_integer

				call get_curr_col
				mov rax, r10
				call write_integer

				write NEW_LINE, 1
			endif
		endif
		;; keep searching...
		jmp .loop
	.check_tag_candidate:
		cmp byte [file_to_parse+r11], '>'
		if e
			;; turn off check_tag_candidate
			mov r12, 0
		else
			cmp byte [file_to_parse+r11], '<'
			if e
				;; write error location
				write error2_test1, error2_test1.len

				call get_curr_line
				mov rax, r9
				call write_integer

				call get_curr_col
				mov rax, r10
				call write_integer

				write NEW_LINE, 1
				;; turn off check_tag_candidate
				mov r12, 0
			endif
		endif
		;; keep searching...
		jmp .loop
