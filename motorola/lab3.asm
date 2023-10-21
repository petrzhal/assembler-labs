 ldaa #%01111111
 ldx #$8200
start_loop
 staa ,x
 deca
 inx
 cpx #$8300
 bmi start_loop

 ldx #$8200

main_loop
 ldy #$8200
sec_loop
 ldaa ,y
 ldab 1,y
 cba
 bmi skip_exchange
 staa $8199
 tba
 ldab $8199
 staa ,y
 stab 1,y
skip_exchange

 iny
 cpy #$82ff
 bmi sec_loop

 inx
 cpx #$82ff
 bmi main_loop