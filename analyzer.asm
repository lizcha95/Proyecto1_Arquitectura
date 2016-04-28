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
;; and finally write ./analyzer
;; ******************************************

;;
;; Include Macros Library
;;
%include "macros.inc"
;;
;; section containing non initialized data
;;
section .bss
;;
;; section containing initialized data
;;
section .data
	msg: db 'Hello, world', 10
		.len: equ $-msg
;;
;; section containing code
;;
section .text
	global	_start
_start:
	;; your code here
	write msg, msg.len
	exit
