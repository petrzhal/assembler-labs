 ldaa #8
 staa $0

 ldaa #%11110000
 staa $1
 clrb

loop
 lsra
 rolb
 dec $0
 tst $0
 bne loop

 ldaa $1
 eorb #%10101010