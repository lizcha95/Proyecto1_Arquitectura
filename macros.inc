;; ******************************************
;; File: macros.asm
;; Authors: Elberth Adrian Garro Sanchez [2014088081]
;; Utility: Simple Macros for NASM
;; Built with NASM Linux 64 bits
;; Copyright 2016 TEC
;; ******************************************

;;
;; macros
;;
%macro write 2
	;; save registers values
	push rax
	push rdi
	push rsi
	push rdx
	;; sys_write syscall
	mov rax, SYS_WRITE
	;; file descritor, standard output
	mov rdi, STD_OUT
	;; buffer address
	mov rsi, %1
	;; length of buffer
	mov rdx, %2
	;; call write syscall
	syscall
	;; return register previous values
	pop rdx
	pop rsi
	pop rdi
	por rax
%endmacro

%macro read 2
	;; save registers values
	push rax
	push rdi
	push rsi
	push rdx
	;; sys_read syscall
	mov rax, SYS_READ
	;; file descritor, standard input
	mov rdi, STD_IN
	;; buffer address
	mov rsi, %1
	;; length of buffer
	mov rdx, %2
	;; call read syscall
	syscall
	;; save lenght of the input in r8
	mov r8, rax
	;; return register previous values
	pop rdx
	pop rsi
	pop rdi
	por rax
%endmacro
