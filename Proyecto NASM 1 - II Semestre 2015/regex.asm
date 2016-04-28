;****************************************************
;       INSTITUTO TECNOLÓGICO DE COSTA RICA         *
;                                                   *
;           Arquitectura de Computadores            *
;                                                   *
;         Profesor: Erick Hernández Bonilla         *
;                                                   *
;            Primer Proyecto NASM: REGEX            *
;                                                   *
;          Estudiantes: Kevin Lobo Chinchilla       *
;                       Victor Chaves Díaz          *
;                       Jorge González Rodríguez    *
;                                                   *
;                    Semestre II                    *
;                                                   *
;                       2015                        *
;           Nota: Se utilizó Sublime Text           *
;****************************************************

section .data
    ; Tal vez sirvan de algo para los grupos extras
    alpha: db ":alpha:"
    alnum: db ":alnum:"
    digit: db ":digit:"


section .bss

    inputBuffer: resb 4256        ; Reserva 80b para regex, 80b para texto a reemplazar y 4K para el texto en el cual buscar.
    outputBuffer: resb 4000        ; Buffer de salida
    replacedTextBuffer: resb 4000
    directionsBuffer: resq 8

    dollar1: resb 4000
    dollar2: resb 4000
    dollar3: resb 4000
    dollar4: resb 4000
    dollar5: resb 4000
    dollar6: resb 4000
    dollar7: resb 4000
    dollar8: resb 4000

    frontTrackSuccess: resb 1    ; Reserve un byte para indicar si el front tracking fue exitoso
    nextCharDirection: resq 8    ; Direccion del siguiente caracter con el que se deberia hacer match

    boolCrossMadeMatch: resb 1
    
section .text

;********************************************************************************************************
; El registro rdi se usará para contar los "(" que se han encontrado                                                                    *
; El registro rsi se usará como bandera para determinar si se esta haciendo match dentro de "( )"               *
; El registro r8 se utilizará como bandera para determinar si hubo match o no en casos particulares.    *
; El registro r9 se utilizará en write para saber cuántos caracteres escribir.                                                  *
; El registro r10 contendrá el inicio de la regex y el final será \n.                                                                   *                                               
; El registro r11 se usará para buscar: ?, *, +, $                                                                                                              *
; Los registros r12 contendrá el inicio del texto reemplazo y el final será \n.                                                 *
; Los registros r14 y r15 contendrán el inicio del texto donde buscar y el final, respectivamente.      *
;                                                                                                                                                                                                               *
;********************************************************************************************************

; NOTA SOBRE RDI: rdi == 0 corresponde a dollar1, rdi == 7 corresponde a dollar8
global _start

; Proc para seleccionar buffer sobre el cual escribir
dollarBufferSelection:
    push r9                             ; Se usará r9 en el proc, se guarda su contenido anterior
    inc qword [directionsBuffer+rdi*8]  ; Se incrementa la longitud del buffer correspondiente (según valor de rdi)
    cmp rdi, 0                          ; De aquí en adelante es una estructura similar a switch en alto nivel
    je .dollar1
    cmp rdi, 1
    je .dollar2
    cmp rdi, 2
    je .dollar3
    cmp rdi, 3
    je .dollar4
    cmp rdi, 4
    je .dollar5
    cmp rdi, 5
    je .dollar6
    cmp rdi, 6
    je .dollar7
    cmp rdi, 7
    je .dollar8

    ; Se agrega al buffer dollar correspondiente el caracter actual del que se hizo match, y que se encuentra almacenado en cl
    .dollar1:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar1+r9-1], cl
        jmp .exit


    .dollar2:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar2+r9-1], cl
        jmp .exit

    .dollar3:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar3+r9-1], cl
        jmp .exit

    .dollar4:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar4+r9-1], cl
        jmp .exit

    .dollar5:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar5+r9-1], cl
        jmp .exit

    .dollar6:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar6+r9-1], cl
        jmp .exit

    .dollar7:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar7+r9-1], cl
        jmp .exit

    .dollar8:
        mov r9, [directionsBuffer+rdi*8]
        mov [dollar8+r9-1], cl
        jmp .exit

    .exit:
        pop r9
        ret


; Proc para limpiar todos los buffers de dollar. Se utiliza cuando se reinicia el match (Algun char falló)
clearDollarBuffers1:
    call clearDollarBuffers2
    dec rdi
    cmp rdi, 0
    jge clearDollarBuffers1

; Proc Auxiliar a clearDollarBuffers1
clearDollarBuffers2:
    push r9
    cmp rdi, 0
    je .dollar1
    cmp rdi, 1
    je .dollar2
    cmp rdi, 2
    je .dollar3
    cmp rdi, 3
    je .dollar4
    cmp rdi, 4
    je .dollar5
    cmp rdi, 5
    je .dollar6
    cmp rdi, 6
    je .dollar7
    cmp rdi, 7
    je .dollar8
    cmp rdi, 8
    je .exit

    .dollar1:
        mov r9, [directionsBuffer+rdi*8]                ; Se mueve a r9 la longitud del buffer
        mov qword [directionsBuffer+rdi*8], 0   ; Se reinicia el contador de caracteres del buffer correspondiente
        push r11                                                                ; Evitar modificaciones de r11 (Extrañamente el siguiente código lo modifica)
        push rdi
        std                                                                     ; Se recorre el buffer de atrás hacia adelante (Direction Flag en 1)
        mov rcx, r9                                                     ; Rcx es utilizado por scasb, r9 contiene el tamaño actual del buffer 
        lea rdi, [dollar1 + rcx]                                ; Se carga en rdi la dirección desde donde limpiar (scasb así lo requiere)
        mov al, 0x0                                                             ; Se carga en al un caracter null (Estándar de scasb)
        rep stosb                                               
        mov [dollar1+rcx], byte 0xA                     ; Se agrega un salto de linea al final
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    ; Lo anterior aplica para todos los buffers
    .dollar2:
        mov r9, [directionsBuffer+rdi*8]
        mov qword [directionsBuffer+rdi*8], 0
        push r11                                
        push rdi
        std                                     
        mov rcx, r9                     
        lea rdi, [dollar2 + rcx] 
        mov al, 0x0                             
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .dollar3:
        mov r9, [directionsBuffer+rdi*8]
        mov qword[directionsBuffer+rdi*8], 0
        push r11                                                
        push rdi
        std                                                     
        mov rcx, r9                                      
        lea rdi, [dollar3 + rcx]   
        mov al, 0x0                                             
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .dollar4:
        mov r9, [directionsBuffer+rdi*8]
        mov qword[directionsBuffer+rdi*8], 0
        push r11                                                
        push rdi
        std                                                     
        mov rcx, r9                                     
        lea rdi, [dollar4 + rcx]   
        mov al, 0x0                                             
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .dollar5:
        mov r9, [directionsBuffer+rdi*8]
        mov qword[directionsBuffer+rdi*8], 0
        push r11                                        
        push rdi
        std                                             
        mov rcx, r9                              
        lea rdi, [dollar5 + rcx]        
        mov al, 0x0                                     
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .dollar6:
        mov r9, [directionsBuffer+rdi*8]
        mov qword[directionsBuffer+rdi*8], 0
        push r11                                        
        push rdi
        std                                             
        mov rcx, r9                              
        lea rdi, [dollar6 + rcx] 
        mov al, 0x0                             
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .dollar7:
        mov r9, [directionsBuffer+rdi*8]
        mov qword[directionsBuffer+rdi*8], 0
        push r11                
        push rdi
        std                     
        mov rcx, r9     
        lea rdi, [dollar7 + rcx]
        mov al, 0x0             
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .dollar8:
        mov r9, [directionsBuffer+rdi*8]
        mov qword[directionsBuffer+rdi*8], 0
        push r11                
        push rdi
        std                     
        mov rcx, r9                     
        lea rdi, [dollar8 + rcx]
        mov al, 0x0                             
        rep stosb
        xor r9, r9
        pop rdi
        pop r11
        jmp .exit

    .exit:
        pop r9
        ret

; Proc que inicia cuando la regex hace match. Se encarga de agregar los buffer dollars al texto de reemplazo
addMatchesToText:
    push rcx
    push rax
    push r12
    xor rax, rax
    xor rcx, rcx

    .startAdding:
        cmp [r12], byte 0xA                     ; r12 es el inicio del texto en el cual reemplazar. Si apunta a salto de linea, termina de reemplazar
        je .exit                                                
        cmp [r12], byte 0x24                    ; Si r12 apunta a un "$" se debe identificar que número le sigue y agregar el buffer dollar correspondiente.
        je .callAddDollarBuffer
        mov al, [r12]                           ; Se mueve el caracter al que apunta r12 a al
        mov [replacedTextBuffer+rcx], al        ; Se almacena el caracter en el buffer de salida del texto
        inc r12
        inc rcx
        jmp .startAdding                        ; No se ha terminado de recorrer el texto sobre el cual reemplazar


    .callAddDollarBuffer:
        inc r12                                 ; r12 ahora apunta al número después de "$"
        call addDollarBuffer
        jmp .startAdding                        ; Se sigue verificando si todavía queda texto


    ; Ya no queda texto por revisar en el texto por reemplazar
    .exit:
        inc rcx                                 ; Se incrementa rcx para agregar un salto de línea                                      
        mov al, [r12]
        mov [replacedTextBuffer+rcx], al
        call printReplacedText                  ; Se llama al proc para imprimir el texto con los reemplazos adecuados
        call clearReplacedTextBuffer            ; Se llama al proc para limpiar el buffer con el nuevo texto
        pop r12                                 ; Se devuelve r12 al inicio del texto por reemplazar
        pop rax                                                 
        pop rcx
        ret

addDollarBuffer:
    push rax
    push rdx
    push rdi
    
    xor rdx, rdx
    xor rax, rax
    xor rdi, rdi
    
    cld
    cmp [r12], byte 0x31    ; Se verifica a cuál número apunta r12
    je .addDollar1
    
    cmp [r12], byte 0x32
    je .addDollar2
    
    cmp [r12], byte 0x33
    je .addDollar3
    
    cmp [r12], byte 0x34
    je .addDollar4
    
    cmp [r12], byte 0x35
    je .addDollar5
    
    cmp [r12], byte 0x36
    je .addDollar6
    
    cmp [r12], byte 0x37
    je .addDollar7
    
    cmp [r12], byte 0x38
    je .addDollar8
    
    jmp .addDollarsToOutput ; Si viene algo como "$9" o mayor, simplemente se agrega el "$9". No se trabaja con él

    .addDollar1:
        cmp qword [directionsBuffer], 0         ; Se verifica que el buffer contenga caracteres
        je .addDollarsToOutput                          ; Si no hay significa que no hubo paréntesis, simplemente se imprime "$#"
        mov al, [dollar1+rdx]                           ; Se mueve a al el caracter correspondiente del buffer dollar
        lea rdi, [replacedTextBuffer+rcx]       ; Se carga a rdi la posición donde agregar el caracter
        stosb
        inc rdx                                                         
        inc rcx
        cmp rdx, [directionsBuffer]                     ; Se compara rdx (caracter agregado), con la longitud del string almacenado en el buffer
        jne .addDollar1                                         ; Si no son iguales, todavía quedan caracteres por copiar
        je .exit

    ; Lo anterior aplica para todos los buffer dollar
    .addDollar2:
        cmp qword [directionsBuffer+8], 0
        je .addDollarsToOutput
        mov al, [dollar2+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+8]
        jne .addDollar2
        je .exit

    .addDollar3:
        cmp qword [directionsBuffer+16], 0
        je .addDollarsToOutput
        mov al, [dollar3+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+16]
        jne .addDollar3
        je .exit

    .addDollar4:
        cmp qword [directionsBuffer+24], 0
        je .addDollarsToOutput
        mov al, [dollar4+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+24]
        jne .addDollar4
        je .exit

    .addDollar5:
        cmp qword [directionsBuffer+32], 0
        je .addDollarsToOutput
        mov al, [dollar5+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+32]
        jne .addDollar5
        je .exit

    .addDollar6:
        cmp qword [directionsBuffer+40], 0
        je .addDollarsToOutput
        mov al, [dollar6+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+40]
        jne .addDollar6
        je .exit

    .addDollar7:
        cmp qword [directionsBuffer+48], 0
        je .addDollarsToOutput
        mov al, [dollar7+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+48]
        jne .addDollar7
        je .exit

    .addDollar8:
        cmp qword [directionsBuffer+56], 0
        je .addDollarsToOutput
        mov al, [dollar8+rdx]
        lea rdi, [replacedTextBuffer+rcx]
        stosb
        inc rdx
        inc rcx
        cmp rdx, [directionsBuffer+56]
        jne .addDollar8
        je .exit

    .addDollarsToOutput:
        dec r12
        mov al, [r12]
        inc rcx
        mov [replacedTextBuffer+rcx], al
        inc r12
        mov al, [r12]
        inc rcx
        mov [replacedTextBuffer+rcx], al
        inc rcx

    .exit:
        inc r12
        pop rdi
        pop rdx
        pop rax
        ret

; Imprime el texto con los reemplazos. Simple.
printReplacedText:
    push rax
    push rdi
    push rsi
    push rdx
    push r11
    
    inc rcx
    mov [replacedTextBuffer+rcx], byte 0xA
    mov rax, 1              ; sys_write
    mov rdi, 1              ;Stdout
    mov rsi, replacedTextBuffer ; A partir de donde hay que imprimir
    mov rdx, rcx    ; Cuántos caracteres hay que imprimir
    syscall
    
    pop r11
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; Limpia el buffer de texto de reemplazo, para evitar conflictos al volver a llenar.
clearReplacedTextBuffer:
    push rcx
    push rdi
    push rax
    
    xor rcx, rcx
    mov rcx, 4000
    
    cld
    mov rdi, replacedTextBuffer
    mov al, 0x0
    rep stosb
    
    pop rax
    pop rdi
    pop rcx
    ret


setMatchChars:

    ; Basicamente recorre todo el regex hasta el ] y va comparando
    ; Si hay un match, se pone rbx en 1
    push rax
    push rdx
    push rcx
    mov rcx, 2            ; Tiene que estar en 2
    
    inc r10               ; Movemos al primer caracter del grupo
    mov al, [r10]         ; Movemos a AL el caracter en el match
    mov dl, [r14]         ; Movemos al DL el caracter con el que hacemos match
    mov rbx, 0            ; Hasta que no encontramos, es falso
    
    ; Y empezamos con la diversion
    .loopCycle:
        cmp al, 92
        je .foundBackslash
        
        cmp al, 93        ; Comparamos el R10 con ]
        je .exit          ; Si son iguales, nos salimos
        
        .loopCycle2:
        cmp dl, al        ; Comparamos
        je .matchSuccess  ; Si son iguales, ponemos un true
        
        inc r10           ; Nos movemos al siguiente caracter del grupo
        mov al, [r10]     ; Y cargamos el caracter en AL
        mov rcx, 2        ; Si nada de esto pasó, volvemos a poner rcx en 2
        loop .loopCycle
    
    .matchSuccess:
        mov rbx, 1
        inc r10
        mov al, [r10]
        jmp .loopCycle
    
    .foundBackslash:
        inc r10
        mov al, [r10]
        jmp .loopCycle2
    .exit:
        lea r11, [r10 + 1] ; Dejamos el r11 a la par del r10
        pop rcx
        pop rdx
        pop rax
        ret

setNotMatchChars:

    ; Basicamente recorre todo el regex hasta el ] y va comparando
    ; Si hay un match, se pone rbx en 0
    push rax
    push rdx
    push rcx

    mov rcx, 2            ; Tiene que estar en 2
    
    lea r10, [r11 + 1]    ; Movemos al primer caracter del grupo
    mov al, [r10]         ; Movemos a AL el caracter en el match
    mov dl, [r14]         ; Movemos al DL el caracter con el que hacemos match
    mov rbx, 1            ; Hasta que encontremos, es verdadero
    
    ; Y empezamos con la diversion
    .loopCycle:
        cmp al, 92
        je .foundBackslash
        
        cmp al, 93           ; Comparamos el R10 con ]
        je .exit             ; Si son iguales, nos salimos
        .loopCycle2:
        cmp dl, al           ; Comparamos
        je .matchNotSuccess  ; Si son iguales, ponemos un false
        
        inc r10              ; Nos movemos al siguiente caracter del grupo
        mov al, [r10]        ; Y cargamos el caracter en AL
        mov rcx, 2           ; Si nada de esto pasó, volvemos a poner rcx en 2
        loop .loopCycle
    
    .matchNotSuccess:
        mov rbx, 0
        inc r10
        mov al, [r10]
        jmp .loopCycle
        
    .foundBackslash:
        inc r10
        mov al, [r10]
        jmp .loopCycle2
    
    .exit:
        lea r11, [r10 + 1]

        pop rcx
        pop rdx
        pop rax
        ret

; LOS SIGUIENTES DOS PROCEDIMIENTOS QUEDAN EN ESTE CODIGO
; COMO UN LEGADO, SIN EMBARGO, SOLO OCUPAN ESPACIO
setNotMatchHyphen:
    push rax             ; RAX para los caracteres del regex
    
    xor rax, rax
    xor rcx, rcx
    
    mov al, [r10 + 1]        ; Movemos al AL el primer caracter
    mov cl, [r14]    ; Y metemos al CL el primer caracter (se asume que ningun proceso tocó el R14 previo a esta llamada)
    cmp cl, al           ; Comparamos para determinar si el caracter esta por debajo del rango
    jl .notSuccesful    ; LO CAMBIE, SI ES MENOR HACE MATCH (POR EJEMPLO 1)
    
    lea r10, [r10 + 3]   ; Nos brincamos el - y pasamos al ultimo caracter del grupo
    mov al, [r10]        ; Cargamos en AL
    cmp cl, al           ; Comparamos   
    jg .notSuccesful    ; LO CAMBIE, SI ES MAYOR HACE MATCH, como usted lo tenía antes, con 1 se caía porque siempre es menor que z, por ejemplo.
    
    ; Si todo salio bien, le indicamos al programa principal por medio del RBX que hubo match
    mov rbx, 0
    lea r10, [r10 + 1]   ; Movemos el R10 al caracter "]" que finaliza el grupo, deberia de imprimir un newline y un pedazo del texto de reemplazo
    
    pop rax
    ret
    
    ; Si no me equivoco, deberiamos de empezar el regex de nuevo
    ; Por lo tanto, ponemos el R10 al principio del regex
    .notSuccesful:           ; Todo salio mal
        lea r10, [r11]           ; AQUI HAY QUE PONER R10 EN "["
        mov rbx, 1           ; Ponemos un "false"        
        pop rax
        ret
        
setMatchHyphen:
    push rax             ; RAX para los caracteres del rege
    
    xor rax, rax
    xor rcx, rcx
    
    mov al, [r10]        ; Movemos al AL el primer caracter
    mov cl, [r14]        ; Y metemos al CL el primer caracter (se asume que ningun proceso tocó el R14 previo a esta llamada)
    cmp cl, al           ; Comparamos para determinar si el caracter esta por debajo del rango
    jl .notSuccesful     ; Si está por debajo, no hay match y nos salimos
    
    
    lea r10, [r10 + 2]   ; Nos brincamos el - y pasamos al ultimo caracter del grupo
    mov al, [r10]        ; Cargamos en AL
    cmp cl, al           ; Comparamos   
    jg .notSuccesful    ; Si está por encima, no hay match y nos salimos
    
    ; Si todo salio bien, le indicamos al programa principal por medio del RBX que si hubo match
    mov rbx, 1
    lea r10, [r10 + 1]   ; Movemos el R10 al caracter "]" que finaliza el grupo, deberia de imprimir un newline y un pedazo del texto de reemplazo
    lea r11, [r10 + 1]   ; Movemos el R11 a la par de R10

    pop rax
    ret
    
    ; Si no me equivoco, deberiamos de empezar el regex de nuevo
    ; Por lo tanto, ponemos el R10 al principio del regex
    .notSuccesful:           ; Todo salio mal
        mov rbx, 0           ; Ponemos un "false"        
        pop rax
        ret

setMatch:
    ; Revisamos si lo que sigue es un ^, hay que llamar a setNotMatchHyphen
    lea r11, [r10+1]
    cmp [r11], byte 94          ; Comparamos con ^
    je .callNoChars             ; Y si son iguales, llamamos al set negado
    
    call setMatchChars          ; Si no, llamamos al normal
    ret
    
    .callNoChars:
        call setNotMatchChars
        ret

clearOutput:
    push r11                            ; Evitar modificaciones de r11 (Extrañamente el siguiente código lo modifica)
    push rdi
    
    std                                 ; Se recorre el buffer de atrás hacia adelante (Direction Flag en 1)
    mov rcx, r9                         ; Rcx es utilizado por scasb, r9 contiene el tamaño actual del buffer 
    lea rdi, [outputBuffer + rcx - 1]   ; Se carga en rdi la dirección desde donde limpiar (scasb así lo requiere)
    mov al, 0x0                         ; Se carga en al un caracter null (Estándar de scasb)
    rep stosb
    
    xor r9, r9
    pop rdi
    pop r11
    ret

startLineMatch:
    cmp [r14 - 1], byte 0xA ; Si lo anterior a r14 actual es un \n
    jne .notSuccessful
    je .successful

    .notSuccessful:
        mov rbx, 0                      ; Se retorna "false"
        ret

    .successful:
        mov rbx, 1                      ; Se retorna "True"
        ret

questionMatch:
    cmp al, cl                              
    je .appears                         ; No match
    jne .doesNotAppear                  ; Match

    .set:                               ; Se llama solamente si desde matchCheck se encontró un grupo antes de ? (Ver proc "lookForSpecials")
        call setMatch   
        cmp rbx, 1                      ; setMatch retorna 1 si hubo match, 0 si no
        je .appears
        jne .doesNotAppear

    .appears:
        mov rbx, 1                      ; Si hubo match en cualquier caso, rbx se pone en 1
        inc r10                         ; Desde aquí se incrementa r10 y r11 para saltarnos el signo de pregunta en próximas instrucciones
        inc r11
        ret

    .doesNotAppear:
        mov rbx, 0                      ; 0 a rcx, no apareció el caracter (No hubo match)
        add r10, 2                      ; Se mueve r10 justo después del ?, aquí es diferente a appears ya que no se llamará a .match en matchCheck
        lea r11, [r10+1]                        ; Debido a eso, es necesario aumentar más los registros
        ret

; Proc para determinar si se llama a dollarBufferSelection
callDBS:
    cmp rsi, 1              ; Si rsi esta en 1, significa que estamos dentro de "( )"
    je .yes
    jne .no

    .yes:
        call dollarBufferSelection
    .no:
        ret



matchCheck:
    push r10
    push r14
    push rax
    push rcx
    push rdx
    push rdi
    push rsi
    push r9
    push r8               ; R8 va a servir como caracter a la par del r14
    push 0                ; Se almacenarán en el stack los valores de la longitud de los buffers dollar.
    push 0
    push 0
    push 0
    push 0
    push 0
    push 0
    push 0

    xor rcx, rcx

    ; Proc local, guarda las direcciones de las longitudes de los buffer dollar en otro buffer de direcciones
    ; Podría hacerse un proc por fuera
    .saveDirections:
        mov rax, [rsp+rcx*8+8]
        mov [directionsBuffer+rcx*8], rax
        inc rcx
        cmp rcx, 8
        jb .saveDirections
    
        xor rcx, rcx
        xor r9, r9
        xor rdi, rdi
        xor rsi, rsi

        lea r8, [r14 + 1]     ; Movemos a R8 el caracter a la par del R14
    
        .checking:
            mov al, [r10]   ; Se mueve a al el caracter de la regex
            mov bl, [r11]   ; Se mueve a bl el caracter siguiente al actual de la regex
            mov cl, [r14]   ; Se mueve a cl el caracter por revisar

            cmp al, 0x5C
            je .backSlashFound

            cmp al, 0x28    ; Se compara r10 con "("
            je .initialParenthesisFound

            cmp al, 0x29    ; Se compara r10 con "(" (Creo que aquí arriba no tiene utilidad)
            je .finalParenthesisFound
            jne .normalFlow

            .initialParenthesisFound:
                mov rsi, 1                      ; Se marca que estamos haciendo match dentro de "( )"
                inc r10                         ; Se debe incrementar r10 y r11
                inc r11
                mov al, [r10]           ; Se deben almacenar los valores de r10 y r11 de nuevo.
                mov bl, [r11]
                cmp al, 0x5C
                je .backSlashFound
                jmp .normalFlow


            .finalParenthesisFound:
                inc rdi                         ; Incrementamos rdi, para que la proxima vez que encontremos un "(" inicie el guardado en el buffer siguiente
                mov rsi, 0                      ; Ya salimos del paréntesis
                inc r10                         
                inc r11
                mov al, [r10]
                mov bl, [r11]
                jmp .salir


            .backSlashFound:
                inc r10    ; R10 apunta al caracter escapado
                inc r11    ; Usamos r11 en caso de que venga un multiplicador
                
                mov al, [r10]
                mov cl, [r14]
                cmp [r11], byte 0x3F   ; Revisamos si el caracter escapado viene con un ? al frente
                je .backslashQuestion
                
                ;cmp [r11], byte 0x2A   ; Revisamos si el caracter escapado viene con un * al frente
                ;je .backslashAsterisk
                
                ;cmp [r11], byte 0x2B   ; Revisamos si el caracter escapado viene con un + al frente
                ;je .backslashCross
                
                cmp cl, al
                je .matchInBackSlash
                jne .noMatch
            
            .matchInBackSlash:
                cmp al, 0x24
                je .endLineMatchBackSlash
                jne .match
                
            .backslashQuestion:
                ; Aprovechamos la existencia de questionMatch
                call questionMatch
                cmp rbx, 1
                je .match
                jne .salir
            
            ;.backslashAsterisk:
                ; Aprovechamos que existe questionMatch aqui tambien
            ;    call questionMatch
            ;    cmp rbx, 1
            ;    je .endLineMatchBackSlash
            ;    jne .salir
            
            ;.backslashAsteriskSuccess:
                ;mov cl, [r14]
            ;    call callDBS
            ;    inc r14
            ;    mov cl, [r14]
            ;    jmp .backslashAsterisk
                
            .normalFlow:
                cmp al, 0x24
                je .endLine

                cmp al, 46              ; Se revisa si el caracter actual de la regex es un punto.
                je .dotMatch            ; Como es punto, siempre habrá match.

                cmp bl, 0x2A            ; Se compara a lo que apunta r11 con "*"
                je .firstAsteriskMatch

                cmp al, 0x5B            ; Se revisa si el caracter actual de la regex es un bracket.
                je .setMatch            ; Se salta para llamar al proc setMatch

                cmp al, 0x5E            ; Se revisa si r10 apunta a "^"
                je .startLine

                cmp bl, 0x3F            ; Se revisa si r11 apunta "?"
                je .questionMatch

                cmp cl, 0xA             ; Se revisa si r14 es un \n, si lo es, hay que moverlo
                je .moveTextRegister

                cmp cl, al              ; Se compara un caracter de la regex con el caracter actual
                je .match               ; Si son iguales, se salta a match
                jne .noMatch            ; Si no lo son, se salta a noMatch

        .salir:
            cmp [r10], byte 0xA                     ; Se compara r10 con \n, al serlo se acaba la regex, por lo que hay match completo
            je .printCompleteMatch
            
            cmp [r10], byte 0x24                    ; Se compara r10 con "$" Si lo es, es como si estuviera en un \n (final regex)
            je .checkForEnd                         ; Se revisa si ya se terminó el texto donde se busca
            
            cmp [r10], byte 0x29                    ; Se debe verificar antes que nada si r10 apunta a un ")" para ignorarlo y seguir con el flujo normal
            je .finalParenthesisFound
            
            cmp r14, r15                            ; Si son iguales, no hay más donde buscar.
            je .checkForQuestionOrAsterisk          ; Esto por si llegamos al final del texto donde buscar y había un ? o * (Si no se encuentra el caracter)
            jne .checking

            .checkForEnd:
                cmp qword [directionsBuffer], 0
                jne .printCompleteMatch
                
                cmp r14, r15
                je .exit
                jne .checking

            .checkForQuestionOrAsterisk:
                cmp [r11], byte 0x3F
                je .foundQuestionOrAsterisk

                cmp [r11], byte 0x2A
                je .foundQuestionOrAsterisk

                jne .checkForEnd

            .foundQuestionOrAsterisk:
                    add r10, 2
                    lea r11, [r10+1]
                    jmp .checking

        .moveTextRegister:
            inc r14
            jmp .salir

        .match:
            cmp [r10], byte 0x24    ; Se compara r10 con "$", si son iguales, hay que saltarse las siguientes líneas hasta la etiqueta
            je .endLineMatch        
            cmp [r14], byte 0xA     ; Se revisa que un punto no haga match con "\n"
            je .noMatchPoint

        .endLineMatchBackSlash:
            inc r14                     ; Se avanza una posición en el texto donde buscar
            mov [outputBuffer + r9], cl ; Se almacena el caracter que coincide en el buffer de salida
            call callDBS
            mov cl, [r14]
            inc r9                      ; Se incrementa r9 para controlar el tamaño del buffer de salida

        .endLineMatch:                  ; Lo siguiente es el flujo normal de .match, la etiqueta es para saltar en caso de encontrar "$"
            cmp [r11], byte 0x2B
            je .crossMatchFromStartLine ; Se revisa si hay un + después del char actual que ya hizo match por lo menos una vez y viene después de "^"
            cmp [r11], byte 0x2A
            je .asteriskMatch
            inc r10    ; Se avanza una posición en la regex
            inc r11    ; Se avanza una posición del r11
            jmp .salir

        .crossMatchFromStartLine:
            cmp r9, 1                       ; Sinceramente, ni idea de esta mica, pero mejor no tocar xD
            je .cmfContinue
            jne .crossMatch

        .cmfContinue:
            cmp [inputBuffer], byte 0x5E
            je .firstCrossMatch
            jne .crossMatch

        .noMatchPoint:
            cmp [r11], byte 0x2B ; Si no está en "$" y el "."" encuentra un \n, no hay match
            jne .noMatch
            add r10, 2                       
            lea r11, [r10 + 1]
            jmp .salir

        .noMatch:
            call clearDollarBuffers1
            xor rdi, rdi
            xor rsi, rsi
            lea r10, [inputBuffer] ; Como no hubo match, se devuelve el r10 al inicio del regex
            lea r11, [r10 + 1]
            lea r14, [r8]        ; Movemos a R8
            inc r8
            call clearOutput
            jmp .salir ; Se devuelve a checking

        .setMatch:
            .lookForSpecials:
                inc r11
                cmp [r11], byte 0x5D
                jne .lookForSpecials
                inc r11
                cmp [r11], byte 0x3F
                je .questionMatchSet
                cmp [r11], byte 0x2B
                je .firstCrossMatchSet
                cmp [r11], byte 0x2A
                je .firstAsteriskMatchSet
                
            .noSpecials:
                lea r11, [r10 + 1]
                call setMatch
                cmp rbx, 1
                je .match
                jne .noMatch

        .startLine:
            call startLineMatch
            cmp rbx, 1
            je .startLineMatch
            jne .noMatch

            .startLineMatch:
                inc r10
                inc r11
                jmp .salir

        .questionMatch:
            call questionMatch
            jmp .next

            .questionMatchSet:
                lea r11, [r10 + 1]
                call questionMatch.set

            .next:
                cmp rbx, 1
                je .match
                jne .salir



; ****************************************************** ;
; *              PROCESOS DEL ASTERISCO                * ;
; ****************************************************** ;

    .firstAsteriskMatch:
        mov al, [r10]
        mov r13, r14
        ; Primero revisamos si se puede continuar, se debe hacer front tracking
        call frontTracking.dotMultipler
        
        ; Si NO se puede continuar, inmediatamente llamamos a noMatch
        cmp [frontTrackSuccess], byte 0
        je .noMatch

    .asteriskMatch:
        cmp al, 46                ; Si en r10 lo que habia era un punto, seguimos con ese ciclo
        je .canDoMatchWithAsterisk
        
        ; Caso contrario, revisamos el texto
        cmp r14, qword [nextCharDirection]
        je .matchInEndLine
        
        cmp [r14], byte 0xA       ; Revisa si hace match en un salto de linea
        je .matchInEndLine
        
        cmp [r14], al             ; Hacemos la comparacion entre el regex y el texto
        je .match
        inc r14
        jmp .asteriskMatch

    .matchInEndLine:
        add r10, 2
        lea r11, [r10+1]
        jmp .salir

    .firstAsteriskMatchSet:
        mov r13, r14
        call frontTracking.setMultiplier

        ; Si esto esta en 0, indica que no se hace match del todo   
        cmp [frontTrackSuccess], byte 0
        je .noMatch
        
    .asteriskMatchSet:
        mov rdx, r10
        cmp r14, qword [nextCharDirection]
        je .asteriskMatchSetExit
        call setMatch
        cmp rbx, 1
        je .asteriskMatchSetSuccessful
        jne .asteriskMatchSetNotSuccessful

    .asteriskMatchSetExit:
        call .moveToSetEnd
        jmp .asteriskMatchSetNotSuccessful
            
    .asteriskMatchSetSuccessful:
        mov r10, rdx
        lea r11, [r10 + 1]
        mov cl, [r14]
        inc r14
        mov [outputBuffer + r9], cl
        call callDBS
        inc r9
        jmp .asteriskMatchSet

    .asteriskMatchSetNotSuccessful:
        add r10, 2
        lea r11, [r10 + 1]
        cmp r13, r14
        je .noMatchSetAsterisk
        jne .salir

        
    .noMatchSetAsterisk:
        ;call clearDollarBuffers1
        ;xor rdi, rdi
        lea r10, [inputBuffer] ; Como no hubo match, se devuelve el r10 al inicio del regex
        lea r11, [r10 + 1]
        inc r14
        ;call clearOutput
        jmp .salir ; Se devuelve a checking
        
        .firstCrossMatch:
            mov al, [r10]
            mov r13, r14

        .crossMatch:
            cmp al, 46
            je .canDoMatchWithCross
            
            cmp [r14], al                   ; Comparamos r14 con AL, que tiene el contenido de r10
            je .match                       ; Basicamente, si son iguales
            
            add r10, 2
            lea r11, [r10 + 1]
            cmp r13, r14
            je .noMatch
            jne .salir

        .firstCrossMatchSet:
            mov r13, r14
            call frontTracking.setMultiplier

            ; Si esto esta en 0, indica que no se hace match del todo   
            cmp [frontTrackSuccess], byte 0
            je .noMatch

        .crossMatchSet:
            mov rdx, r10
            cmp r14, qword [nextCharDirection]
            je .crossMatchSetExit
            call setMatch
            cmp rbx, 1
            je .crossMatchSetSuccessful
            jne .crossMatchSetNotSuccessful

        .crossMatchSetExit:
            cmp [boolCrossMadeMatch], byte 0   ; Si esta variable está en 0, significa que no se hizo match y hay que brincar a noMatch
            je .noMatch
            call .moveToSetEnd
            jmp .crossMatchSetNotSuccessful

        .crossMatchSetSuccessful:
            mov [boolCrossMadeMatch], byte 1
            mov r10, rdx
            lea r11, [r10 + 1]
            mov cl, [r14]
            inc r14
            mov [outputBuffer + r9], cl
            call callDBS
            inc r9
            jmp .crossMatchSet

        .crossMatchSetNotSuccessful:
            cmp [boolCrossMadeMatch], byte 0   ; Si esta variable está en 0, significa que no se hizo match y hay que brincar a noMatch
            je .noMatch         
            add r10, 2
            lea r11, [r10 + 1]
            cmp r13, r14
            je .noMatch
            jne .salir

        .moveToSetEnd:
            inc r10
            cmp [r10], byte 93
            jne .moveToSetEnd
            ret

        .dotMatch:
            cmp [r11], byte 0x2B    ; Esto es importante, se revisa si es el caso .+
            je .dotMatchWithCross
            
            cmp [r11], byte 0x2A    ; Esto es importante, se revisa si es el caso .*
            je .dotMatchWithAsterisk
            
            cmp [r11], byte 0x3F    ; Compara con ?, ejecuta el .?
            je .dotMatchWithQuestion
            
            jmp .match

            .dotMatchWithAsterisk:
                ; Primero revisamos si se puede continuar, se debe hacer front tracking
                call frontTracking.dotMultipler
                
                ; Si NO se puede continuar, inmediatamente llamamos a noMatch
                cmp [frontTrackSuccess], byte 0
                je .noMatch
                
            .canDoMatchWithAsterisk:
                ; Caso contrario, revisamos el texto
                cmp r14, qword [nextCharDirection]
                je .salirHere
                jne .match
                
                .salirHere:
                lea r10, [r11 + 1]
                lea r11, [r10 + 1]
                jmp .salir


            .dotMatchWithCross:
                mov [boolCrossMadeMatch], byte 0

                ; Primero revisamos si se puede continuar, se debe hacer front tracking
                call frontTracking.dotMultipler

                ; Si NO se puede continuar, inmediatamente llamamos a noMatch
                cmp [frontTrackSuccess], byte 0
                je .noMatch
                    
            .canDoMatchWithCross:
                ; Caso contrario, revisamos el texto
                cmp r14, qword [nextCharDirection]
                je .salirYay
                mov [boolCrossMadeMatch], byte 1
                jne .match

                .salirYay:
                cmp [boolCrossMadeMatch], byte 0   ; Si esta variable está en 0, significa que no se hizo match y hay que brincar a noMatch
                je .noMatch

                lea r10, [r11 + 1]
                lea r11, [r10 + 1]
                jmp .salir

            .endLine:
                cmp [r14], byte 0xA
                je .match
                cmp [r14], byte 0x0
                je .match
                jne .noMatch
                
            .dotMatchWithQuestion:
                ; Revisamos el front tracking
                call frontTracking.dotQuestion
                
                ; Revisamos si se puede hacer match (esto no deberia estar en 0)
                cmp [frontTrackSuccess], byte 0
                je .noMatch
                
                cmp r14, qword [nextCharDirection]
                je .noMatchQuestion
                inc r10
                jne .match
            
            .noMatchQuestion:
                add r10, 2                      ; Se mueve r10 justo después del ?, aquí es diferente a appears ya que no se llamará a .match en matchCheck
                lea r11, [r10+1]                        ; Debido a eso, es necesario aumentar más los registros
                jmp .salir
                    
                    
        .printCompleteMatch: 
            call addMatchesToText
            mov [outputBuffer + r9], byte 0xA
            inc r9
            lea r8, [r14 + 1]     ; Movemos a R8 el caracter a la par del R14
            
            ; DESCOMENTAR PARA DEBUGGING
            ; call printMatch
            
            call clearOutput
            call clearDollarBuffers1
            lea r10, [inputBuffer]
            lea r11, [inputBuffer + 1]
            xor r9, r9
            xor rdi, rdi
            
            cmp r14, r15   ; Existe la posibilidad de que r14 sea un salto de linea, por lo que hay que incrementarlo
            jne .revisarFinal
            je .exit
            
            .revisarFinal:
                cmp [r14], byte 10
                je .incrementarR14
                jmp .salir
            
        .incrementarR14:
            lea r14, [r14 + 1]
            jmp .salir


        .exit:
            ;call printMatch
            pop r10
            pop r10
            pop r10
            pop r10
            pop r10
            pop r10
            pop r10
            pop r10
            pop r8
            pop r9
            pop rsi
            pop rdi
            pop rdx
            pop rcx
            pop rax
            pop r14
            pop r10
            ret

; Esta funcion hace el front tracking al PRIMER caracter que haga match
frontTracking:
    ; Se usa para .+ y .*
    ; Al momento solo está implementado para un caracter cualquiera en frente del + o el *
    .dotMultipler:
        push r14
        push r11
        push rax
        push rbx
        push r10
        push rcx
        inc r11         ; Movemos R11 al caracter despues del +
        mov al, [r11]   ; Y lo cargamos a AL
        call .checkForChar  
        pop rcx
        pop r10
        pop rbx
        pop rax
        pop r11
        pop r14
        ret
        
    .setMultiplier:
        push r14
        push r11
        push rax
        push rbx
        push rcx
        inc r11
        mov al, [r11]
        call .checkForChar
        pop rcx
        pop rbx
        pop rax
        pop r11
        pop r14
        ret
    
    .dotQuestion:
        push r14
        push r11
        push rax
        push rbx
        push rcx
        inc r11
        mov al, [r11]
        call .checkForChar
        pop rcx
        pop rbx
        pop rax
        pop r11
        pop r14
        ret
        
        .checkForChar:
            mov bl, [r14]
            mov rcx, r14
            
            cmp al, 92     ; Si es un backslash, hay que tratar el siguiente caracter como un especial
            je .checkWithBackslash
            
            cmp bl, al     ; Revisamos si lo que hay en r14 es igual a lo que hay en r11
            je .success
            
            cmp [r11 + 1], byte 0x2A
            je .checkForQuestionMatch
            
            cmp [r11 + 1], byte 0x3F
            je .checkForQuestionMatch
            
            cmp al, byte 91
            je .checkForSetMatch
            
            cmp al, byte 40
            je .checkAfterParen
            
            cmp al, byte 41
            je .checkAfterParen

            cmp al, byte 36
            je .findEndNewline  ; Asumimos que hay un fin de linea, si no, explosiona esto
            
            cmp al, byte 41
            je .checkAfterParen
            
            cmp bl, byte 10 ; O si es un salto de linea, nos salimos
            je .fail
            
            inc r14
            jmp .checkForChar
            
        .success:
            ; Si encontramos el caracter, usamos estos dos pseudoregistros para indicar que lo encontramos y en donde deberia estar
            mov [frontTrackSuccess], byte 1
            mov qword [nextCharDirection], r14
            ret
        
        .fail:
            mov [frontTrackSuccess], byte 0
            ret
        
        .checkAfterParen:
            inc r11
            mov al, [r11]
            jmp .checkForChar
        
        .findEndNewline:
            inc r14
            cmp [r14], byte 10   ; Compara con el salto de linea
            jne .findEndNewline
            jmp .success
        
        .checkForSetMatch:
            mov r10, r11
            call .checkIfAsteriskOrQuestion
            
            .checkForSetMatch2:
            mov r10, r11
            push r11
            call setMatch
            pop r11
            cmp rbx, 1
            je .success
            cmp [r14], byte 10
            je .failSetMatch
            inc r14
            jmp .checkForSetMatch2
        
        .checkIfAsteriskOrQuestion:
            call .moveToEndBracket
            inc r10
            
            cmp [r10], byte 0x2A ; Asterisco
            je .indicarSpecial
            
            cmp [r10], byte 0x3F ; Signo de pregunta
            je .indicarSpecial
            
            mov [frontTrackSuccess], byte 0x2  ; 2 significa que no hay especial
            ret
            
            .indicarSpecial:
            mov [frontTrackSuccess], byte 0x3  ; 3 significa que hay un especial
            ret
        
        .failSetMatch:
            cmp [frontTrackSuccess], byte 0x2
            je .fail
            mov r10, r11
            call .moveToEndBracket
            mov r11, r10
            lea r11, [r11 + 2]
            mov al, [r11]
            mov r14, rcx
            jmp .checkForChar
            
        .moveToEndBracket:
            inc r10
            cmp [r10], byte 93
            jne .moveToEndBracket
            ret
            
    
    .checkForQuestionMatch:
        cmp bl, al     ; Revisamos si lo que hay en r14 es igual a lo que hay en r11
        je .successQuestion
        
        cmp bl, byte 0xA ; Si llegamos al cambio de linea, no hubo match con el ?
        je .noQuestionMatch
        
        inc r14
        mov bl, [r14]
        jmp .checkForQuestionMatch
        
    .noQuestionMatch:
        mov r14, rcx
        lea r11, [r11 + 2]
        mov al, [r11]
        jmp .checkForChar
    
    .successQuestion:
        je .success
    
    .checkWithBackslash:
        inc r11
        mov al, [r11]
        
    .checkBackslash:   ; Esto es un clon modificado de checkForChar
        mov bl, [r14]
        mov rcx, r14
            
        cmp bl, al     ; Revisamos si lo que hay en r14 es igual a lo que hay en r11
        je .success
        
        ; Para * y ? se maneja el mismo caso
        cmp [r11 + 1], byte 0x2A
        je .checkForQuestionMatch
            
        cmp [r11 + 1], byte 0x3F
        je .checkForQuestionMatch
        
        cmp bl, byte 10 ; O si es un salto de linea, nos salimos
        je .fail
        
        inc r14
        jmp .checkBackslash
        
printRegex:
    push rax
    push rdi
    push rsi
    push rdx
    push r10
    push r11
    mov r10, inputBuffer
    mov rax, 1              ; sys_write
    mov rdi, 1              ;Stdout
    mov rsi, r10 ; A partir de donde hay que imprimir
    mov rdx, r9     ; Cuántos caracteres hay que imprimir
    syscall
    pop r11
    pop r10
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

printReplace:
    push rax
    push rdi
    push rsi
    push rdx

    mov rax, 1              ; sys_write
    mov rdi, 1              ;Stdout
    mov rsi, r12    ; A partir de donde hay que imprimir
    mov rdx, r9     ; Cuántos caracteres hay que imprimir
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

printMatchText:
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 1              ; sys_write
    mov rdi, 1              ;Stdout
    mov rsi, r14    ; A partir de donde hay que imprimir
    mov rdx, r9     ; Cuántos caracteres hay que imprimir
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

printMatch:
    push rax
    push rdi
    push rsi
    push rdx
    push r11
    mov rax, 1              ; sys_write
    mov rdi, 1              ;Stdout
    mov rsi, outputBuffer    ; A partir de donde hay que imprimir
    mov rdx, r9     ; Cuántos caracteres hay que imprimir
    syscall
    pop r11
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

_start:
    ;Proc para entrada de texto
    read:
        mov rax, 0              ; sys_read
        mov rdi, 0              ; stdin
        mov rsi, inputBuffer    ; Direccion donde guardar el caracter que guardó
        mov rdx, 4256           ; Bytes por leer
        syscall                 ; Estas llamadas devuelven cosas a RAX y RDX (RAX devuelve la cantidad de chars leidos)
                                ; RAX devuelve 1 si se logra leer un char o un 0 cuando terminan los caracteres.

    cmp rax, 0                      ; Para saber cuando se dejó de leer caracteres
    je separateInputs               ; Si no hay nada más que leer, se separan las entradas

    xor rcx, rcx                    ; Se limpia el registro rcx
    xor r9, r9                      ; Se limpia el registro r9
    mov rcx, rax                    ; Se mueve la cantidad de caracteres leídos (RAX) a RCX
    mov rdx, rax
    xor rax, rax                    ; Se limpia rax para evitar errores
    mov al, 0xA                     ; Se mueve un salto de línea a al, para utilizar scasb
    mov rdi, inputBuffer            ; Se mueve a rdi el inicio del texto leído para utilizar scasb
    mov r10, inputBuffer            ; Se mueve a r10 el inicio de la expresión regular


separateInputs:             ; Se inicia la separación de entradas: regex, reemplazo y texto
    cld
    mov r9, rcx             ; Se almacena en r9 el total de caracteres leídos
    repne scasb             ; Se busca un salto de línea
    lea r11, [r10 + 1]
    mov r12, rdi            ; RDI quedó apuntando al inicio del texto por reemplazar
    sub r9, rcx             ; Como rcx disminuyó con repne, se le resta a r9 para obtener la longitud de la regex.
    ;call printRegex        ; Se imprime solo la regex, puro testeo. BORRAR AL FINAL
    mov r9, rcx             ; Se mueve a r9 la cantidad de caracteres restantes por leer.
    repne scasb             ; Se busca otro salto de línea
    sub r9, rcx             
    ;call printReplace      ; Se imprime el texto por reemplazar. BORRAR AL FINAL.

    mov r9, rcx 
    mov r14, rdi                                            ; RDI quedó apuntando al inicio del texto donde buscar matches
    lea r15, [inputBuffer + rdx - 1]                        ; Se almacena la dirección del caracter final a r15
    cmp [r15], byte 0xA                                     ; Comparamos si es un salto de linea, si no, hay que incluirlo
    jne .addNewLine
    je .runMatch
    
    .addNewLine:
        inc r15
        mov [r15], byte 0xA
        
    .runMatch:
        call matchCheck



    ; Label de salida del programa
    exit:
        mov rax, 60             ;sys_exit
        mov rdi, 0              ;Código de error 0. No hubo errores.
        syscall

