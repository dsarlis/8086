;**********************************************************
; PRINT_DEC 
;	INPUT: 		DX
;	MODIFIED:	AX 
;**********************************************************
INCLUDE MACROS.TXT

PUBLIC PRINT_DEC
PUBLIC PRINT_HEX
PUBLIC SCAN_KEY
PUBLIC CALCULATE

STACK SEGMENT 
	DB 80 DUP(?)
STACK ENDS

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
	CMP DX,0
	JNE LAB
	PRINT '0'
	JMP EX
LAB:
	MOV BX,DX       ;metafora arithmou ston BX
	SHL DX,1
	JNC POSITIVE
	PRINT '-'
	NEG BX
	
POSITIVE:	
	MOV CX,4        ;metritis psifiwn
ADDR2:
	ROL BX,1        ;4 aristeres peristrofes wste ta 4 epomena bit
	ROL BX,1        ;na erthoun stis 4 dexioteres theseis
	ROL BX,1
	ROL BX,1
	
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
EX:	POP BP
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
    READ            ;anagnwsi pliktrologiou
	CMP AL,'Q'		;an einai 'Q' , termatismos
	JE ADDRR2
    CMP AL,'+'		;elegxos an einai '+'
    JNE CHECK_MINUS	;an oxi elegxos an einai '-'
    CMP CX,4		;an einai '+'
    JE IGNORE		;elegxoume an exei dothei pshfio
    JMP HEL			;an oxi to agnooume alliws teleiwse h eisagwgh tou prwtou arithmou
CHECK_MINUS:
    CMP AL,'-'		;elegxos an einai '-'
    JNE CHECK_ENTER	;an oxi elegxos an einai enter
    CMP CX,4		;an einai meion elegxos an exei dothei pshfio
    JE NEGAT		;an oxi pame na doume an einai to prwto meion wste na epitrepsoume arnhtikous arithmous
HEL:CMP BP,0		
	JNE IGNORE
	PRINT AL
    JMP ADDRR2
NEGAT:
    CMP SI,0		;an einai 0 tote einai to prwto meion kai to kratame
    JNE IGNORE		;alliws to agnooume giati exoume parei hdh ena meion
    PRINT AL
    MOV SI,1		;allazoume th shmaia meta to prwto meion
    JMP IGNORE    
CHECK_ENTER:
    CMP AL,0DH		;elegxos gia enter
    JNE CHECK_NUM	;an oxi tote pame ston elegxo an einai pshfio
    CMP CX,4		;an nai elegxoume an exei dothei toulaxiston ena pshfio alliws
    JE IGNORE		;to agnooume
    JMP ADDRR2
CHECK_NUM:    
    CMP AL,30H		;elegxos an einai pshfio 
    JL IGNORE
    CMP AL,39H
    JG IGNORE
    CMP CX,0		;an exoun dothei 4 pshfia 
    JE IGNORE		;agnooume ola ta ypoloipa
    PRINT AL		;to typwnoume sthn othoni
    SUB AL,30H
    AND AX,000FH
    PUSH AX			;kai to apothikeuoume ston DX
    MOV AX,DX
    MUL BX
    MOV DX,AX
    POP AX
    ADD DX,AX
    LOOP IGNORE
    JMP IGNORE
ADDRR2:
	CMP SI,0		;an dothike arnhtikos arithmos
	JE ADDRR3	
	NEG DX			;pairnoume to symplhrwma tou ws pros 2
ADDRR3:
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
    CMP AL,'+'	;elegxos an einai prosthesi
    JNE MINUS	;an oxi afairoume tous arithmous
    ADD BX,DX	;alliws tous prosthetoume
    JMP ADDRR1
MINUS:
    SUB BX,DX
ADDRR1:        
    MOV DX,BX	;to apotelesma ston DX
    RET
CALCULATE ENDP

CODE_SEG ENDS

END