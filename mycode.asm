
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; this maro is copied from emu8086.inc ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this macro prints a char in AL and advances
; the current cursor position:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   



org 000
jmp intro ;3lshan ybda2 mn 3nda bdet el code  


print0 db 0Dh,0Ah,"Hellooo! =)$"
print1 db 0Dh,0Ah,"Enter Card number: $"
print2 db 0Dh,0Ah,"Enter the Password: $" 
print3 db 0Dh,0Ah,"Processing.....................$"
print4 db 0Dh,0Ah,"1--->(ACCEPTED)$"
print5 db 0Dh,0Ah,"0--->(DENIED)$"
print6 db 0Dh,0Ah,"Card number not found$ "
print7 db 0Dh,0Ah,"Incorrect Password$" 
print8 db 0Dh,0Ah,"press 0 to Exit:$"
print9 db 0Dh,0Ah,"press 1 to check another Card: $"
print10 db 0Dh,0Ah,"Please enter a valid password!!!$"  
  
x dw ? ;Card no
y db ? ;Password 
i dw 0   ;3lshan yb2a index lel loop

;STATIC DATABASE of 20 customers
DATABASE dw 6053,2387,4700,7448,7603,7356,1287,7878,5792,3571,0096,1567,6050,9012,8845,1358,3250,1111,1357,7893 ;16 bit(word)
PASSWORD db 8,2,6,1,0,3,11,7,14,9,12,5,13,9,15,4,0,12,10,3    ;4 bit(byte)

 

intro:      ;for the other times   
mov ah, 0Eh       ;print new line sequence
mov al, 0Dh
int 10h
mov al, 0Ah
int 10h
  
lea dx,print0
mov ah, 09h   
int 21h
run:       
mov ah, 0Eh       ;print new line sequence
mov al, 0Dh
int 10h
mov al, 0Ah
int 10h

lea dx,print1      ;load effective address in DX
mov ah, 09h   
int 21h


call scan_num      ;;takes input until ENTER (subroutine built in)--> stores in CX

; store card number:
mov x, cx        ;CX because it's 2 bytes(word) 

pass:

    lea dx, print2
    mov ah, 09h
    int 21h  

    call scan_num  


; store password:
mov y, cl   ; only 1 byte so we use CL

cmp y,15
ja wrong


lea dx, print3
mov ah, 09h
int 21h
mov ah, 0Eh       ;print new line sequence
mov al, 0Dh
int 10h
mov al, 0Ah
int 10h

mov cx,20            ;Array siz =20 so ier =20
mov bx,0             ;index on array                  
mov i,0          ; 3lshan a3raf a-access el password b3den  

loopData:   ;loops on card no.    
    mov dx,x    
    cmp dx,DATABASE[bx]
    je  checkPass
    inc bx 
    inc bx      ;increase twice bec memory is byte addressable 
    inc i
    loop loopData     ;breaks when CX = 0
    jmp  WrongCard ;3lshan myd5olsh 3la checkPass
     
     
checkPass:       ;check password
    mov dl,y
    mov bx,i  
    cmp dl,PASSWORD[bx] 
    je  found
    jmp WrongPass
    
found:
      lea dx, print4
      mov ah, 09h   
      int 21h 
      jmp Continue
      
WrongCard:    
      lea dx,print6
      mov ah, 09h   
      int 21h
      lea dx, print5
      mov ah, 09h   
      int 21h
      jmp Continue
WrongPass:
      lea dx, print7
      mov ah, 09h   
      int 21h
      lea dx, print5
      mov ah, 09h   
      int 21h
      jmp Continue
wrong:
  lea dx, print10
  mov ah, 09h   
  int 21h 
  jmp pass
  
         
Continue:
    mov ah, 0Eh       ;print new line sequence
    mov al, 0Dh
    int 10h
    mov al, 0Ah
    int 10h
    lea dx,print8
    mov ah,09h 
    int 21h
    lea dx,print9
    mov ah,09h 
    int 21h 
    mov ah, 0Eh       ;print new line sequence
    mov al, 0Dh
    int 10h
    mov al, 0Ah
    int 10h
    call SCAN_NUM
    cmp cx,1
    je run
    jz  Break
    
Break:
    mov ah,4ch 
    int 21h
     
  
  
  ;<<<<<<<<<<<<<<<<<<Default>>>>>>>>>>>.
  
  
  
              
; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP




ten             DW      10      ; used as multiplier/divider by SCAN_NUM