;; ******************************************
;; File: test.asm
;; Authors: Elberth Adrian Garro Sanchez [2014088081]
;;		    Liza Chaves Carranza [2013]
;;
;; Utility:
;; Built with NASM Linux 64 bits
;; Copyright 2016 TEC
;; ******************************************

;; ******************************************
;; Instructions for run this code:
;; Open terminal
;; Locate the code with cd, in my case:
;; cd '/media/psf/Home/Proyectos/NASM x64/Proyecto1_Arquitectura/test'
;; then write make
;; and finally write ./stack_test
;; ******************************************

;;
;; section containing initialized data
;;
section .data
	SYS_READ  equ 0
	STD_IN    equ 0
	SYS_WRITE equ 1
	STD_OUT   equ 1
	SYS_EXIT  equ 60
	EXIT_CODE equ 0
;;
;; macros
;;
%macro print 2
	;; sys_write syscall
	mov rax, SYS_WRITE
	;; file descritor, standard output
	mov rdi, STD_OUT
	;; message address
	mov rsi, %1
	;; length of message
	mov rdx, %2
	;; call write syscall
	syscall
%endmacro
;;
;; section containing code
;;
section .text
	global	_start
_start:
	;; your code here
;;
;; Exit from program
;;
exit:
	;; syscall number
	mov	rax, SYS_EXIT
	;; exit code
	mov	rdi, EXIT_CODE
	;; call sys_exit
	syscall
