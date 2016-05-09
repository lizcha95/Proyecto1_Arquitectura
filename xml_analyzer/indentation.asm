;;
;; Procedure to correct indentation, creation of new file
;;

test_errores: db 'Hay errores', 10
	.len: equ $-test_errores
rows: db "Hay x filas", 10
	.len: equ $-rows

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
					;; to do: multiplicar r12 por 3, para hacer un ciclo que agregue los espacios en blanco
	jmp .loop
