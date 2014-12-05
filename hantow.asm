%include "asm_io.inc"

SECTION .data

arrL: dd 0,0,0,0,0,0,0,0,9
arrM: dd 0,0,0,0,0,0,0,0,9
arrR: dd 0,0,0,0,0,0,0,0,9
xs: db "XXXXXXXXXXXXXXXXXXX",0
nineSpaces: db "         ",0
plus: db '+'
space: db ' '
done: db "Done",10,0
err1: db "Too many arguments",10,0
err2: db "Incorrect argument",10,0
err3: db "Argument out of range",10,0

SECTION .bss

i: resd 1
j: resd 1
a1: resd 1
a2: resd 1
a3: resd 1
hPeg: resd 1

SECTION .text
   global  asm_main
   extern printf

; The putChar function draws n number of some character passed into it
; i.e. passing 3 and '+' into it will output +++
; note: push character first, then push the repeat number
putChar:
   enter 0,0
   pusha
   
   mov ebx, dword [ebp+8]		; the number (amount of characters)
   mov ecx, dword [ebp+12]		; the character (' ' or '+')
   
   cmp ebx, 0
   je exitPutChar
   
   mov [j], dword 0
   myloop2:
	mov eax, ecx
	call print_char
	add [j], dword 1
		
	cmp [j], ebx
	jne myloop2

exitPutChar:	
   popa
   leave
   ret

; The putTower function draws a single disc based on the values passed into it
; i.e. passing 3, this function would draw:
;       +++|+++
putTower:
   enter 0,0
   pusha
   
   mov ebx, dword [ebp+8]
   
	mov ecx, dword 9
	sub ecx, ebx
	
	mov edx, [space]
	push edx
	push ecx
	call putChar
	add esp, 8
	
	mov edx, [plus]
	push edx
	push ebx
	call putChar
	add esp, 8
	
	mov eax, '|'
	call print_char
	
	mov edx, [plus]
	push edx
	push ebx
	call putChar
	add esp, 8
	
	mov edx, [space]
	push edx
	push ecx
	call putChar
	add esp, 8
   
   popa
   leave
   ret
   
; The makePeg function draws the towers in the required format based on the array values of arrL, arrM and arrR
makePeg:
   enter 0,0
   pusha
   
   ;mov ebx, dword [ebp+16]			; first array pushed (arrL)
   ;mov ecx, dword [ebp+12]			; second array pushed (arrM)
   ;mov edx, dword [ebp+8]			; third array pushed (arrR)
   
   mov [a1], dword arrL				; arrL pointer
   mov [a2], dword arrM				; arrM pointer
   mov [a3], dword arrR				; arrR pointer
   
   mov [i], dword 0
   
myloop:
	mov ebx, dword [a1]				; print current element of arrL
	mov eax, dword [ebx]
	push eax
	call putTower
	add esp, 4
	
	mov eax, nineSpaces
	call print_string
	
	mov ebx, dword [a2]				; print current element of arrM
	mov eax, dword [ebx]
	push eax
	call putTower
	add esp, 4
	
	mov eax, nineSpaces
	call print_string
	
	mov ebx, dword [a3]				; print current element of arrR
	mov eax, dword [ebx]
	push eax
	call putTower
	add esp, 4
   
	call print_nl
	add [i], dword 1				; increment loopCount
	add [a1], dword 4				; increment array pointers
	add [a2], dword 4
	add [a3], dword 4
	
	cmp [i], dword 8
	jne myloop
   
   mov [i], dword 0					; put the base of 9 X's
loopXs:
	mov eax, xs
	call print_string
   
	mov eax, nineSpaces
	call print_string
	
	add [i], dword 1
	
	cmp [i], dword 2
	jne loopXs
   
   mov eax, xs
   call print_string
   
   call print_nl
   
   popa
   leave
   ret

; The checkPegNum function checks which of the three towers is the starting position and which one is the ending position
; Puts base address of starting position in a1, and ending position in a2
checkPegNum:
   enter 0,0
   pusha

   mov ebx, dword [ebp + 12]		; start/end peg value
   mov ecx, dword [ebp + 8]			; 0 means start peg, 1 means end peg
   
   cmp ebx, 1						; check starting/ending peg
   je check1
   cmp ebx, 2
   je check2
   
   cmp ecx, 0						; 0 means starting peg
   jne threeA2
   
   mov [a1], dword arrR				; starting peg is 3
   jmp finishCheck
   
threeA2: 
   mov [a2], dword arrR				; ending peg is 3
   jmp finishCheck
   
check2:
   cmp ecx, 0						; 0 means starting peg
   jne twoA2
   
   mov [a1], dword arrM				; starting peg is 2
   jmp finishCheck

twoA2:
   mov [a2], dword arrM				; ending peg is 2
   jmp finishCheck
   
check1: 
   cmp ecx, 0						; 0 means starting peg
   jne oneA2
   
   mov [a1], dword arrL				; starting peg is 1
   jmp finishCheck

oneA2:
   mov [a2], dword arrL				; ending peg is 1

finishCheck:
   
   popa
   leave
   ret   

; The moveDisc function moves the top most disc from starting tower above the top most disc of the ending tower
moveDisc:
   enter 0,0
   pusha
   
   mov ecx, dword [ebp+12]			; start tower base pointer 
   mov edx, dword [ebp+8]			; end tower base pointer 
   
   ;mov a1, eax
   ;mov a2, ebx
   
   ;call print_int
   ;call print_nl
   
discStart:							; get the top most disc from starting tower (first non-zero number)
   mov eax, ecx
   mov eax, dword [eax]
   
   add ecx, dword 4
   cmp eax, 0
   je discStart   
   
   mov ebx, eax						; store the top most disc value in ebx
   mov eax, ecx						; remove that disc from starting tower
   mov [eax-4], dword 0
   
discEnd:							; get the top most disc location from ending tower (first non-zero number)
   mov eax, edx
   ;mov eax, dword [eax]
   
   add edx, dword 4
   cmp [eax], dword 0
   je discEnd
   
   mov [eax-4], ebx					; put the top most disc from starting tower above the top most disc of the ending tower
  
   popa
   leave
   ret
   
; The hanoi function calculates the moves required to solve the problem and updates the arrays accordingly   
hanoi:
   enter 0,0
   pusha

   mov ebx, dword [ebp+16]			; num of discs in ebx
   mov ecx, dword [ebp+12]			; starting peg in ecx
   mov edx, dword [ebp+8]			; ending peg in edx
   
   cmp ebx, 1
   jne notBaseCase

   push ecx							; check the starting peg position, set a1 to the base address of that array
   push 0
   call checkPegNum
   add esp, 8
   
   push edx							; check the ending peg position, set a2 to the base address of that array
   push 1
   call checkPegNum
   add esp, 8
   
   push dword [a1]					; move nth disc from starting peg to ending peg
   push dword [a2]
   call moveDisc
   add esp, 8
   
   call makePeg						; draw the towers
   call read_char					; get user input
   call print_nl
   
   ;mov eax, ecx					; instructions to move nth disc from starting peg to ending peg
   ;call print_int
   ;mov eax, '>'
   ;call print_char
   ;mov eax, edx
   ;call print_int
   ;call print_nl
   
   jmp endBaseCase
   
notBaseCase:
   mov eax, dword 6					; helping peg in eax (6 - start - end)
   sub eax, ecx
   sub eax, edx
   mov [hPeg], eax					; helping peg in hPeg
   		
   sub ebx, 1						; ebx = n-1 discs
   
   push ebx							; move n-1 discs from starting peg to helping peg
   push ecx
   push dword [hPeg]
   call hanoi						; recursive call
   add esp, 12
   
   push ecx							; check the starting peg position, set a1 to the base address of that array
   push 0
   call checkPegNum
   add esp, 8
   
   push edx							; check the ending peg position, set a2 to the base address of that array
   push 1
   call checkPegNum
   add esp, 8

   push dword [a1]					; move nth disc from starting peg to ending peg
   push dword [a2]
   call moveDisc
   add esp, 8
   
   call makePeg						; draw the towers
   call read_char					; get user input
   call print_nl
   
   ;mov eax, ecx					; instructions to move nth disc from starting peg to ending peg
   ;call print_int
   ;mov eax, '>'
   ;call print_char
   ;mov eax, edx
   ;call print_int
   ;call print_nl
   
   ; reset [hPeg]
   mov eax, dword 6					; helping peg in eax (6 - start - end)
   sub eax, ecx
   sub eax, edx
   mov [hPeg], eax					; helping peg in hPeg
   
   push ebx							; move n-1 discs from helping peg to ending peg
   push dword [hPeg]
   push edx
   call hanoi						; recursive call
   add esp, 12
   
endBaseCase:   
   popa
   leave
   ret
   
; The main function
asm_main:
   enter 0,0	; enter subroutine
   pusha		; save all registers

   mov eax, dword[ebp+8]	; get number of arguments (argc)
   cmp eax, 2				; check it is 2
   jne error1				; if not display err1 and terminate asm_main

   ; get the second argument
   mov eax, 0
   mov eax, dword [ebp+12]
   add eax, 4
   mov ebx, dword [eax]		; ebx = 2nd arg, String

   mov eax, 0
   mov al, [ebx]
   sub eax, '0'				; eax = 2nd arg, int
   mov ebx, eax
   
   ; check the argument is an integer (i.e. number shouldn't be more than 9 - maximum 1 character number)
   ; if not display err2 and terminate asm_main
   cmp ebx, 10
   jge error2
   
   ; check the argument is b/w 2 and 8
   ; if not display err3 and terminate asm_main
   cmp ebx, 8
   jg error3
   
   cmp ebx, 2
   jl error3
   
   jmp noError

error3:
   mov eax, err3
   call print_string
   jmp Finish   
   
error2:
   mov eax, err2
   call print_string
   jmp Finish

error1:
   mov eax, err1
   call print_string
   jmp Finish

noError:
   mov edx, dword 28			; start with arrL[7] (i.e. second last element in arrL)
   mov eax, ebx					; put number of discs in eax
   
discLoop:						; put all n discs on to first peg (nth disc at the bottom)
	mov [a1], dword arrL
	mov ecx, dword [a1]
	mov [ecx+edx], ebx
	
	sub ebx, 1
	sub edx, dword 4
	
	cmp ebx, 0
	jne discLoop
   
   mov ebx, eax					; restore ebx
   
   call makePeg					; show how the towers initially look like
   call read_char				; get user input
   call print_nl
   
   ; solve the problem with...
   
   push ebx						; ebx number of discs
   push dword 1					; from tower (1)
   push dword 2					; to tower (2)
   call hanoi
   add esp, 12
   
   mov eax, [space]
   push eax
   push dword 35
   call putChar
   add esp, 8
   
   mov eax, done
   call print_string

Finish:
   mov eax, 0
   popa		; restore all registers
   leave	; leave the subroutine
   ret		; return control