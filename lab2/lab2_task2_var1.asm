 ORG $8000
 LDX #$8200

LOOP:
 LDAA $0,X
 ANDA #%00010001
 CMPA #%00010001
 BEQ BITSET
 BNE BITCLEAR

BITSET:
 BSET $0,X,#%00000010
 BRA STORE�

BITCLEAR:
 BCLR $0,X,#%00000010
 BRA STORE

STORE:
 INX
 CPX #$8220
 BNE LOOP