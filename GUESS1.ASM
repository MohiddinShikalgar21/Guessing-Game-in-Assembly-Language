
.model small
.stack 100h
.data

    number      db  134d    ;variable 'number' stores the random value
 
    ;declarations used to add LineBreak to strings
    CR          equ 10d
    LF          equ 13d
 
    ;String messages used through the application
    prompt      db  CR, LF, "Please enter a valid number (0 to 255) : $"
    lessMsg     db  CR, LF, "Try a smaller number $"
    moreMsg     db  CR, LF, "Try a greater number $"
    equalMsg    db  CR, LF, "You have made a fine Guess! $"
    overflowMsg db  CR, LF, "Error - Number out of range! $"
    retry       db  CR, LF, "Retry [y/n] ? $"
 
    guess       db  0d      ;variable user to store value user entered
    errorChk    db  0d      ;variable user to check if entered value is in range

 
.code
 
start:
 
    ; --- BEGIN
    MOV ax, 0h  ; accumulator register: used in data transfer, logic and arithematic instructions
    MOV bx, 0h  ; base register: address register that contain a data pointer
    MOV cx, 0h  ; count register: serves as a loop counter
    MOV dx, 0h  ; data register; used as port no. in I/O operations
 
    LEA BX, guess    ; get address of 'guess' variable in BX.
    MOV BYTE PTR [BX], 0d   ; set 'guess' to 0 (decimal)
 
    LEA BX, errorChk ; get address of 'errorChk' variable in BX.
    MOV BYTE PTR [BX], 0d   ; set 'errorChk' to 0 (decimal)
    ; --- END resting
 
    MOV ax, @data           ; get address of data to AX
    MOV ds, ax              ; set 'data segment' to value of AX which is 'address of data'
    LEA dx, prompt          ; load address of 'prompt' message to DX
 
    MOV ah, 09h             ; Write string to STDOUT (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
 
    MOV cl, 0h              ; set CL to 0  (Counter)
    MOV dx, 0h              ; set DX to 0  (Data register used to store user input)
 
; -- BEGIN reading user input

while1:
 
    CMP     cl, 5d          ; compare CL with 5d (5 is the maximum number of digits allowed)
    JG      endwhile1       ; IF CL > 5 then JUMP to 'endwhile1' label

    MOV     ah, 01h         ; Read character from STDIN into AL (for DOS interrupt)
    INT     21h             ; DOS INT 21h (DOS interrupt)
 
    CMP     al, 0Dh         ; compare read value with 0Dh which is ASCII code for ENTER key
    JE      endwhile1       ; IF AL = 0Dh, Enter key pressed, JUMP to 'endwhile1'
 
    SUB     al, 30h         ; Substract 30h from input ASCII value to get actual number. (Because ASCII 30h = number '0')
    MOV     dl, al          ; Move input value to DL
    PUSH    dx              ; Push DL into stack, to get it read to read next input
    INC     cl              ; Increment CL (Counter)
 
    JMP while1              ; JUMP back to label 'while' if reached


endwhile1:
; -- END reading user input
 
    DEC cl                  ; decrement CL by one to reduce increament made in last iteration
 
    CMP cl, 02h             ; compare CL with 02, because only 3 numbers can be accepted as IN RANGE
    JG  overflow            ; IF CL (number of input characters) is greater than 3 JUMP to 'overflow' label
 
    LEA BX, errorChk ; get address of 'errorChk' variable in BX.
    MOV BYTE PTR [BX], cl   ; set 'errorChk' to value of CL
 
    MOV cl, 0h              ; set CL to 0, because counter is used in next section again
 

; -- BEGIN processing user input
; -- Create actual NUMERIC representation of
;--   number read from user as three characters
while2:
 
    CMP cl,errorChk         ; compare errorChk with Cl
    JG endwhile2            ; IF Cl > errorChk, JUMP to 'endwhile2'
 
    POP dx                  ; POP DX value stored in stack, (from least-significant-digit to most-significant-digit)
 
    MOV ch, 0h              ; clear CH which is used in inner loop as counter
    MOV al, 1d              ; initially set AL to 1   (decimal)
    MOV dh, 10d             ; set DH to 10  (decimal)
 

 ; -- BEGIN loop to create power of 10 for related possition of digit
 ; --  IF CL is 2
 ; --   1st loop will produce  10^0
 ; --   2nd loop will produce  10^1
 ; --   3rd loop will produce  10^2
 while3:
 
    CMP ch, cl              ; compare CH with CL
    JGE endwhile3           ; IF CH >= CL, JUMP to 'endwhile3
 
    MUL dh                  ; AX = AL * DH whis is = to (AL * 10)
 
    INC ch                  ; increment CH
    JMP while3
 
 endwhile3:
 ; -- END power calculation loop
 
    ; now AL contains 10^0, 10^1 or 10^2 depending on the value of CL
 
    MUL dl                  ; AX = AL * DL, which is actual positional value of number
 
    JO  overflow            ; If there is an overflow JUMP to 'overflow' label (for values above 300)
 
    MOV dl, al              ; move result of multiplication to DL
    ADD dl, guess           ; add result (actual positional value of number) to value in 'guess' variable
 
    JC  overflow            ; If there is an overflow JUMP to 'overflow'label (for values above 255 to 300)
 
    LEA BX, guess           ; get address of 'guess' variable in BX.
    MOV BYTE PTR [BX], dl   ; set 'guess' to value of DL
 
    INC cl                  ; increment CL counter
 
    JMP while2              ; JUMP back to label 'while2'


endwhile2:
; -- END processing user input
 
    MOV ax, @data           ; get address of data to AX
    MOV ds, ax              ; set 'data segment' to value of AX which is 'address of data'
 
    MOV dl, number          ; load original 'number' to DL
    MOV dh, guess           ; load guessed 'number' to DH
 
    CMP dh, dl              ; compare DH and DL (DH - DL)
 
    JL greater              ; if DH (GUESS) > DL (NUMBER) cmparision will cause a Carry. Becaus of that if carry has been occured print that 'number is more'
    JE equal                ; IF DH (GUESS) = DL (NUMBER) print that guess is correct
    JG lower                ; IF DH (GUESS) < DL (NUMBER) print that number is less
 
equal:
 
    LEA dx, equalMsg ; load address of 'equalMsg' message to DX
    MOV ah, 09h              ; Write string to STDOUT (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    JMP exit                ; JUMP to end of the program
 
greater:

    LEA dx, moreMsg         ; load address of 'moreMsg' message to DX
    MOV ah, 09h             ; Write string to STDOUT (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    JMP start               ; JUMP to beginning of the program
 
lower:
 
    LEA dx, lessMsg         ; load address of 'lessMsg' message to DX
    MOV ah, 09h             ; Write string to STDOUT (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    JMP start               ; JUMP to beginning of the program
 
overflow:
 
    LEA dx, overflowMsg     ; load address of 'overflowMsg' message to DX
    MOV ah, 09h             ; Write string to STDOUT (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    JMP start               ; JUMP to beginning of the program


exit:
; -- Ask user if he needs to try again if guess was successful
retry_while:
 
    LEA dx, retry    ; load address of 'retry' message to DX
 
    MOV ah, 09h              ; Write string to STDOUT (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
 
    MOV ah, 01h              ; Read character from STDIN into AL (for DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
 
    CMP al, 6Eh             ; check if input is 'n'
    JE return_to_DOS        ; call 'return_to_DOS' label is input is 'n'
 
    CMP al, 79h             ; check if input is 'y'
    JE restart              ; call 'restart' label is input is 'y' ..
                            ;   "JE start" is not used because it is translated as NOP by emu8086
 
    JMP retry_while         ; if input is neither 'y' nor 'n' re-ask the same question
 
retry_endwhile:
 
restart:

    mov dl,number
    add dl,03h
    mov number,dl
    int 21h

    JMP start               ; JUMP to begining of program

return_to_DOS:
    MOV ax, 4c00h           ; Return to ms-dos
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    end start
 
RET
