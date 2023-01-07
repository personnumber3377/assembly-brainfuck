
%include "jumps.asm"




section .data




section .bss
datasection: resb 10000
programsection: resb 10000



section .text


global _start


read_file_to_buf:
	
	push r10
	push rax
	push rbx
	push rcx
	push rdx
	push rdi
	push rsi
	push r11
	
	mov r11, rbx ; save buffer to r11
	
	mov rdi, rax ; save filename to rdi
	mov rsi, 0 ; readonly
	mov rax, 2 ; open
	syscall

	mov r10, rax ; save fd

	mov rdi, rax ; fd
	mov rax, 0 ; sys_read


	mov rsi, rbx ; buffer
	mov rdx, 10000
	syscall

	mov rdi, r10
	mov rax, 3
	syscall ; close
	pop r11
	pop rsi
	pop rdi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	pop r10
	ret





zero_out_section:
	; for i in range(10000):
	;	buf[i] = 0
	push rax
	push rbx
	mov rbx, 0

zero_out_section_loop:
	
	cmp rbx, 10000
	je zero_out_section_loop_done

	mov [rax+rbx], byte 0
	inc rbx
	jmp zero_out_section_loop


zero_out_section_loop_done:
	pop rbx
	pop rax
	ret



sub_data_pointer:
	dec rbx
	jmp instr_done
inc_data_pointer:
	inc rbx
	jmp instr_done

inc_what_is_at_data_pointer:
	push rax ; save the thing
	; rbx is the data pointer
	mov al, byte [datasection+rbx]
	
	inc al
	mov [datasection+rbx], al
	pop rax
	jmp instr_done


dec_what_is_at_data_pointer:
	push rax ; save the thing
	; rbx is the data pointer
	mov al, byte [datasection+rbx]
	
	dec al
	mov [datasection+rbx], al
	pop rax
	jmp instr_done


write_byte:
	
	; the writeable char is datasection[data_pointer] aka

	push rax
	push rbx
	; rbx is the datapointer
	push rdi
	push rsi
	push r11
	mov rax, 1 ; sys_write
	mov rdi, 1 ; fd
	mov rsi, datasection ; *buf
	add rsi, rbx
	mov rdx, 1 ; len

	syscall
	pop r11
	pop rsi
	pop rdi
	pop rbx
	pop rax
	jmp instr_done

read_byte:
	
	; the writeable char is datasection[data_pointer] aka

	push rax
	push rbx
	; rbx is the datapointer
	push rdi
	push rsi
	push r11
	push rdx
	push rcx

    ; read one byte from stdin into the buffer
    mov rax, 0 ; set rax to 0 to indicate that we are using syscall 0 (read)
    mov rdi, 0 ; set rdi to 0 to indicate that we are reading from stdin
    mov rsi, datasection ; set rsi to the address of the buffer
    add rsi, rbx
    mov rdx, 1 ; set rdx to the number of bytes we want to read
    syscall ; make the syscall

    pop rcx
    pop rdx
	pop r11
	pop rsi
	pop rdi
	pop rbx
	pop rax
	jmp instr_done



square_open:
	; first check if the byte at the data pointer is zero

	; push rax   ; do not push rax because we want to modify it
	push rbx
	push r11
	push rdi
	push r10
	; 
	push rax
	mov al, byte [datasection+rbx] ; get current data byte

	cmp al, 0 ; compare to zero
	pop rax
	jne not_zero ; if not zero at datapointer then just do nothing
	push rax
	;mov rax, programsection+rax ; get the current instruction thing
	
	add rax, programsection

	call jump_forward ; call the external function which returns how many steps to take forward in r10
	mov r10, rax
	pop rax

	add rax, r10 ; add the steps to the instruction pointer




not_zero:
	pop r10
	pop rdi
	pop r11
	pop rbx
	jmp instr_done








square_close:
		; first check if the byte at the data pointer is not zero

	; push rax   ; do not push rax because we want to modify it
	push rbx
	push r11
	push rdi
	push r10
	; 

	; mov al, byte [datasection+rbx] ; get current data byte

	push rax
	mov al, byte [datasection+rbx] ; get current data byte

	cmp al, 0 ; compare to zero
	pop rax
	je not_zero ; if not zero at datapointer then just do nothing
	

	push rax
	; mov rax, programsection+rax ; get the current instruction thing
	add rax, programsection
	call jump_backward ; call the external function which returns how many steps to take forward in r10
	
	mov r10, rax
	pop rax


	sub rax, r10 ; add the steps to the instruction pointer




not_zero_2:
	pop r10
	pop rdi
	pop r11
	pop rbx
	jmp instr_done
	




_start:
	

	; Zero out the program section and the data section
	; Read the program from the file to the program buffer


	pop rax
	pop rax
	mov rax, programsection
	call zero_out_section
	mov rax, datasection
	call zero_out_section

	pop rax ; the two first arguments are argc and argv[0] but argv[1] is actually the first argument to the program.

	; rax = filename
	; rbx = buffer which to fill
	mov rbx, programsection

	call read_file_to_buf

	mov rax, 0 ; rax is the instruction pointer
	mov rbx, 0 ; rbx is the data pointer
	mov r11, 0 ; current instruction





main_loop:
	
	cmp rax, 10000
	je exit
	cmp rbx, 10000
	;jge error_data_overflow
	jge exit
	; fetch instruction

	mov r11, [rax+programsection]
	and r11, 0xff
	cmp r11, "<"
	je sub_data_pointer
	cmp r11, ">"

	je inc_data_pointer
	cmp r11, "+"
	je inc_what_is_at_data_pointer

	cmp r11, "-"
	je dec_what_is_at_data_pointer

	cmp r11, "."
	je write_byte

	cmp r11, ","
	je read_byte

	cmp r11, "["
	je square_open

	cmp r11, "]"
	je square_close


	



	; which instruction is it and execute the program

instr_done:

	; increment instruction pointer
	inc rax


	jmp main_loop



exit:
	mov rax, 60
	mov rdi, 0
	syscall







