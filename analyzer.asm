;; ******************************************
;; File: analyzer.asm
;; Authors: Liza Chaves Carranza [2013]
;;          Marisol González [2014]
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
;; and finally write ./analyzer
;; ******************************************

;;
;; Include Macros Library
;;
%include "macros.inc"
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
