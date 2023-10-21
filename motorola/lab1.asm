 ldx #$aa
 ldy #$ff

; 1 way
 stx $1
 sty $3
 ldx $3
 ldy $1

; 2 way
 xgdx
 xgdy
 xgdx

; 3 way
 pshx
 pshy
 pulx
 puly
 tsx