

section .data

section .bss

inputstring: resb 10000



section .text


global jump_forward
global jump_backward




jump_forward:
	; rax is the string pointer and this will return the amount of steps taken forward inside rax and nothing else changed

	push rbx
	push rcx
	push rdx
	; rax is strpointer
	; rcx is offset
	; rbx is the get byte
	; rdx is the counter

	mov rcx, 0 ; intialize offset
	mov rdx, 0 ; initialize counter

	mov rdx, 0 ; reset counter to zero
loop_start:
	
	; get byte

	mov rbx, rax ; move string pointer to rbx
	add rbx, rcx ; add offset into the pointer

	mov bl, [rbx] ; get byte

	cmp bl, "[" ; add one

	je increment_one

	cmp bl, "]"
	je decrement_one
	jmp loop_end




increment_one:
	inc rdx
	jmp loop_end

decrement_one:
	dec rdx
loop_end:
	inc rcx
	cmp rdx, 0
	je func_end ; found the corresponding closing bracket

	jmp loop_start
func_end:
	mov rax, rcx ; move offset into rax
	pop rdx
	pop rcx
	pop rbx
	ret








jump_backward:
	; rax is the string pointer and this will return the amount of steps taken forward inside rax and nothing else changed

	push rbx
	push rcx
	push rdx
	; rax is strpointer
	; rcx is offset
	; rbx is the get byte
	; rdx is the counter

	mov rcx, 0 ; intialize offset
	mov rdx, 0 ; initialize counter

	mov rdx, 0 ; reset counter to zero
loop_start2:
	
	; get byte

	mov rbx, rax ; move string pointer to rbx
	sub rbx, rcx ; add offset into the pointer

	mov bl, [rbx] ; get byte

	cmp bl, "[" ; add one

	je increment_one2

	cmp bl, "]"
	je decrement_one2
	jmp loop_end2




increment_one2:
	dec rdx
	jmp loop_end2

decrement_one2:
	inc rdx
loop_end2:
	inc rcx
	cmp rdx, 0
	je func_end2 ; found the corresponding closing bracket

	jmp loop_start2
func_end2:
	sub rcx, 1
	mov rax, rcx ; move offset into rax
	pop rdx
	pop rcx
	pop rbx
	ret














