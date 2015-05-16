INCLUDE MACROS.TXT
INCLUDE LIB_EXTR.TXT

DATA SEGMENT
   MSG DB "HIT ME!",0AH,0DH,"$" 
   NEW_LINE DB 0AH,0DH,"$"
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE , DS:DATA
MAIN PROC FAR
	MOV AX,DATA
	MOV DS,AX
START :
    PRINT_STR MSG			;ektupwsi minumatos
    MOV DX,0				;o 1os arithmos tha dimiourgithei ston DX
    MOV BX,10				;basi (10) tou sustimatos arithmisis
	MOV BP,0
    CALL SCAN_KEY			;anagnwsi 1ou arithmou kai telesti (+/-)
	CMP AL,'Q'
	JE QUIT
    MOV BP,DX				;metafora 1ou arithmou ston BP
    PUSH AX					;apothikeusi telesti(+/-) stin stoiba
    MOV DX,0				;o 2os arithmos tha dimiourgithei ston DX
    CALL SCAN_KEY			;anagnwsi 2ou arithmou
	CMP AL,'Q'
	JE QUIT
    POP AX					;epanafora telesti
    MOV BX,BP				;metafora 1ou arithmou ston BX
    PRINT '='
    CALL CALCULATE			;upologismos praksis(+/-)
    CALL PRINT_HEX			;ektupwsi se HEX morfi
    PRINT '='
    CALL PRINT_DEC			;ektupwsi se DEC morfi
    PRINT_STR NEW_LINE		;ektupwsi neas grammis 
    JMP START				;epanalipsi diadikasias
QUIT:
	EXIT
MAIN ENDP
CODE ENDS 
END MAIN