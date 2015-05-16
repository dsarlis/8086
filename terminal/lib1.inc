;**********************************************************
; PRINT_DEC 
;	INPUT: 		DX
;	MODIFIED:	AX 
;**********************************************************

PUBLIC PRINT_DEC
PUBLIC PRINT_HEX
PUBLIC SCAN_KEY
PUBLIC CALCULATE

CODE_SEG SEGMENT 
	ASSUME CS:CODE_SEG


PRINT_DEC PROC FAR
    PUSH DX
    PUSH CX
    PUSH BX
	MOV CX,0        ;upologismos twn BCD psifiwn kai 
    MOV AX,DX       ;apothikeusi sti stoiba
    SHL DX,1
    JNC ADDR1
    PRINT '-'
    NEG AX
    
ADDR1:
    MOV DX,0        
    MOV BX,10
    DIV BX          ;diairesi arithmou me 10 
    PUSH DX         ;apothikeusi upoloipou sti stoiba
    INC CX          ;metritis psifiwn++
    CMP AX,0        ;elegxos an uparxei allo psifio
    JNZ ADDR1
ADDR5:
    POP DX          ;anagnwsi apo tin stoiba
    ADD DX,30H      ;upologismos ASCII kwdikou     
    PRINT DL        ;ektupwsi antistoixou psifiou stin othoni
    LOOP ADDR5
    POP BX
    POP CX
    POP DX
    RET
PRINT_DEC ENDP

;**********************************************************
; PRINT_HEX
;	INPUT: 		DX
;	MODIFIED:	NONE 
;**********************************************************	
	
PRINT_HEX PROC FAR
	PUSH DX         ;apothikeusi kataxwritwn sti stoiba
	PUSH CX 
	PUSH BX 
	PUSH BP
	MOV BP,0
	MOV BX,DX       ;metafora arithmou ston BX
	SHL DX,1
	JNC POSITIVE
	PRINT '-'
	NEG BX
	
POSITIVE:	
	MOV CX,4        ;metritis psifiwn
ADDR2:
	ROL BX,4        ;4 aristeres peristrofes wste ta 4 epomena bit
	                ;na erthoun stis 4 dexioteres theseis 
	MOV DX,BX
	AND DX,000FH    ;apomonwsi twn 4 LSB's
	CMP DL,00
	JNE CONT
	CMP BP,0
	JE  NO_PRINT
CONT:
	CMP DL,09       ;elegxos an einai psifio 0-9
	JLE ADDR3       ;elegxos an einai gramma A-F 
	ADD DL,37H      ;metatropi se ASCII
	JMP ADDR4  
ADDR3:
	ADD DL,30H      ;metatropi se ASCII gia psifio
ADDR4:
	PRINT DL        ;ektupwsi hex psifiou
	MOV BP,1
NO_PRINT:
	LOOP ADDR2
	POP BP
	POP BX          ;epanafora periexomenou kataxwritwn
	POP CX
	POP DX
	RET
PRINT_HEX ENDP 


;**********************************************************
; SCAN_KEYB
;	INPUT: 		NONE
;	MODIFIED:	AX,DX
;	OUTPUT:		DX[NUM],AX[OPERATOR]
; 
;**********************************************************	

SCAN_KEY PROC FAR
    PUSH SI
    MOV CX,4		;metritis psifiwn arithmou
    MOV SI,0
    
IGNORE:
    READ
    CMP AL,'+'
    JNE CHECK_MINUS
    CMP CX,4
    JE IGNORE
    PRINT AL
    JMP ADDRR2
CHECK_MINUS:
    CMP AL,'-'
    JNE CHECK_ENTER
    CMP CX,4
    JE NEGAT
    PRINT AL
    JMP ADDRR2
NEGAT:
    CMP SI,0
    JNE IGNORE
    PRINT AL
    MOV SI,1
    JMP IGNORE    
;IGNORE:    
 ;   READ			;anagnwsi pliktrologiou
	;CMP AL,'Q'		;an einai 'Q' , termatismos
	;JE ADDRR2	
 ;   CMP AL,'+'		;
  ;  JNE CHECK_MINUS
   ; JMP OPER
;CHECK_MINUS:
 ;   CMP AL,'-'
  ;  JNE CHECK_ENTER
;OPER:
 ;   CMP CX,4
  ;  JE IGNORE
   ; PRINT AL
    ;JMP ADDRR2
CHECK_ENTER:
    CMP AL,0DH
    JNE CHECK_NUM
    CMP CX,4
    JE IGNORE
    JMP ADDRR2
CHECK_NUM:    
    CMP AL,30H
    JL IGNORE
    CMP AL,39H
    JG IGNORE
    CMP CX,0
    JE IGNORE
    PRINT AL
    SUB AL,30H
    AND AX,000FH
    PUSH AX
    MOV AX,DX
    MUL BX
    MOV DX,AX
    POP AX
    ADD DX,AX
    LOOP IGNORE
    JMP IGNORE
ADDRR2:

	CMP SI,0
	JE ADDRR3
	NEG DX
ADDR3:
    POP SI    
    RET    
SCAN_KEY ENDP

;**********************************************************
; CALCULATE
;	INPUT: 		AX,BX,DX
;	MODIFIED:	BX,DX
;	OUTPUT:		DX
; 
;**********************************************************	

CALCULATE PROC FAR
    CMP AL,'+'
    JNE MINUS
    ADD BX,DX
    JMP ADDRR1
MINUS:
    SUB BX,DX
ADDRR1:        
    MOV DX,BX
    RET
CALCULATE ENDP

CODE_SEG ENDS

END