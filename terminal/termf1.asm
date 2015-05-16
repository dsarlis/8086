INCLUDE MACROS.TXT
STACK SEGMENT 
	DB 80 DUP(?)
STACK ENDS
DATA SEGMENT
   MSG1 DB "GIVE 0 FOR 'ECHO off' OR 1 FOR 'ECHO on': $"
   MSG2 DB 0AH,0DH,"GIVE 1-6 FOR BAUD RATE : $"
   MSG3 DB 0AH,0DH," [1] 300, [2] 600 , [3] 1200, [4] 2400, [5] 4800, [6] 9600 : $"
   NEW_LINE DB 0AH,0DH,"$"
   FREM DB 00
   FLOC	DB 00
   ROW  DB 00
   COL  DB 09
   REMROW DB 13
   REMCOL DB 09
   EMOD DB 00
   VAR 	DB ?
   LOC DB "[LOCAL] :$"
   REM DB "[REMOTE]:$"
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE , DS:DATA 
MAIN PROC FAR
	MOV AX,DATA
	MOV DS,AX
START :
	MOV AH,00H		;set video mode
	MOV AL,02H
	INT 10H
    PRINT_STR MSG1
ECHO: 
	READ 
	CMP AL,1BH          ;AN DWSEI 'ESCAPE' TELOS
	JNE CONT
	EXIT
CONT:
	CMP AL,30H
	JE ECHO_OK			;an dwsei 0 tote echo "off"
	CMP AL,31H
	JNE ECHO			;an dwsei otidhpote allo to agnooume
ECHO_OK:
	PRINT AL			
	PRINT_STR NEW_LINE
	SUB AL,30H
	MOV EMOD,AL        	; apothikeusi tou echo mode   
	PRINT_STR MSG2
	PRINT_STR MSG3
	
BAUD:	
	READ
	CMP AL,031H			;elegxos an dothike mia apo tis times 1-6
	JL BAUD_OK 			;gia to baud rate
	CMP AL,036H			;an oxi to agnooume
	JLE BAUD_OK			;alliws vazoume to baud rate sth swsth thesi tou AL
	JMP BAUD
	
BAUD_OK:
	PRINT AL 
	SUB AL,30H          ;Ston AL to BAUD
	INC AL		
	SHL AL,01H		    ;metafora tis epithumitis timis sta 3 msb tou AL 
	SHL AL,01H          ;gia na xrhsimopoihthoun ws parametros apo thn OPEN
	SHL AL,01H
	SHL AL,01H
	SHL AL,01H
	ADD AL,03H			;mhkos leksis 8 bit, 1 stop bit kai oxi isotimia
	CALL OPEN_RS232		;arxikopoihsh ths portas
	MOV AH,00H		;set video mode
	MOV AL,02H
	INT 10H
	MOV AH,02H			;topothetisi tou kersora sthn prwth grammh kai prwth sthlh
	MOV DX,0000H		;gia na grapsoume thn etiketa [LOCAL] :
	MOV BH,00H
	INT 10H
	PRINT_STR LOC
	MOV AH,02H			;topothetisi tou ketrsora sthn 13h grammh kai prwth sthlh
	MOV DX,0D00H		;gia na grapsoume thn etiketa [REMOTE]:
	MOV BH,00H
	INT 10H
	PRINT_STR REM
DIAVASMA:	
	CALL RXCH_RS232		 ;elegxos ths seiriakhs eisodou
	CMP AL,00H			 ;an AL = 0 tote den yparxei kati sthn eisodo
	JE KEYBOARD 		 ;kai pame na tsekaroume to plhktrologio
	CALL SET_CURSOR_REM	 ;alliws thetoume ton cursora sthn epomenh thesh
NPREM:	
	CMP AL,0DH			 ;alliws den einai o prwtos xarakthras
	JE ENTER_REM		 ;elegxoume an patithike enter
	CMP AL,08H			 ;elegxos an einai BACKSPACE
	JNE PRINT_INPUT		 ;an oxi proxwrame
	CALL BACKSPC		 ;alliws kaloume th routina
	JMP DIAVASMA
PRINT_INPUT:
	PRINT AL			;an oxi apla typwnoume to xarakthra
	CALL GET_CURSOR		;pairnoume th thesi tou kersora
	CMP DL,4FH			;elegxoume an ftasame sthn teleytaia sthlh
	JNE REF_REM			;an oxi apothikeuoume thn trexousa grammh kai sthlh
ENTER_REM:
	INC DH				;an exei patithei enter ayksanoume to deitkh grammhs
	CMP DH,18H			;kai elegxoume an ftasame sto telos tou parathirou
	JLE  EX				;an oxi apothikeuoume thn kainouria grammh kai sthlh
	CALL UPDATE_REM		;alliws kanoume scroll up thn othonh
	MOV REMROW,18H		;kai apothikeuoume oti eimaste sthn teleutaia grammh
	MOV REMCOL,09H
	CALL SET_CURSOR_REM
	JMP ADV
EX:	MOV REMROW,DH
	MOV REMCOL,09H
	CALL SET_CURSOR_REM			;thetoume ton cursora sthn epomenh grammh
	JMP ADV
HELP: 
	JMP DIAVASMA		
REF_REM:
	MOV REMCOL,DL			;apothikeush trexousas grammhs kai sthlhs
	MOV REMROW,DH
ADV:	
	MOV FREM,01H		;thetoume flag remote = 1
	MOV FLOC,00H		;kai flag local = 0 giati mas erxontai dedomena apo ton allo
KEYBOARD:			;local readings 
	MOV AH,06H      ;elegxos an exei patithei plhktro
	MOV DL,0FFH
	INT 21H
	JZ HELP
	CMP AL,1BH      ;an exei patithei, elegxoume an einai ESCAPE
	JNE CONT2		;an oxi proxwrame alliws eksodos apo to programma
	EXIT
CONT2:
	CMP EMOD,1		;an echo "off" tote apla prowthoume to xarakthra sth seiriakh eksodo
	JNE SEND
	MOV VAR,AL		;alliws proxwrame sth diadikasia typwshs
	CALL SET_CURSOR_LOC
CON:CMP DH,0CH		;elegxos an eimaste sthn teleutaia grammh
	JE HA			;an nai pame th sthlh sto 10
HA:	MOV DL,09H
NEXT:
	CMP AL,0DH		;elegxos an patithike enter
	JE ENTER_LOC	;an nai jump parakatw
	CMP AL,08H		;elegxos an einai backspace
	JNE PRINT_CHAR	;an oxi proxwrame
	CALL BACKSPC	;alliws kaloume th routina
	JMP SEND
	
PRINT_CHAR:
	PRINT AL		;alliws apla typwnoume to xarakthra
	MOV AH,03H		;pairnoume th thesi tou kersora
	MOV BH,00H
	INT 10H
	CMP DL,4FH		
	JNE REF_LOC     ;an den exoume ftasei sthn teleutaia sthlh apothikeuoume grammh kai sthlh
ENTER_LOC:
	INC DH			;an patithei enter h ftasoume sthn teleutaia sthlh auksanoume th grammh kata 1
	CMP DH,0DH		;elegxos an einai h teleutaia grammh
	JGE CLEAR_SCR	;an nai jump parakatw
	MOV ROW,DH		;alliws apothikeusi grammhs
	MOV COL,09H		;topothetisi ths sthlhs sth thesi 10
	CALL SET_CURSOR_LOC
	JMP SEND		;apostolh xarakthra
REF_LOC:
	MOV COL,DL		;apothikeusi ths trexousas grammhs kai sthlhs
	MOV ROW,DH
FIN:
	MOV AL,VAR
SEND:	
	MOV FLOC,01H		;flag local = 1
	MOV FREM,00H		;flag remote = 0 giati plhktrologoume xarakthres
	CALL TXCH_RS232     ;an oxi, ton prowthoume
	JMP DIAVASMA		
CLEAR_SCR:
	CALL UPDATE_LOC		;scroll up window kata 1
	MOV ROW,0CH			;thetoume th grammh sto telos
	MOV COL,09H			;kai th sthlh sth thesi 10
	CALL SET_CURSOR_LOC
	JMP FIN				;proxwrame sthn apostolh tou xarakthra
QUIT:
	EXIT
MAIN ENDP

;*****************************************************************************
OPEN_RS232 PROC NEAR
JMP START1	
	
BAUD_RATE LABEL WORD 	
	DW 1047 	; 110 baud rate
	DW 768 		; 150 baud rate
	DW 384 		; 300 baud rate
	DW 192 		; 600 baud rate
	DW 96 		; 1200 baud rate
	DW 48 		; 2400 baud rate
	DW 24 		; 4800 baud rate
	DW 12 		; 9600 baud rate
	
START1: 	
	STI 			; Set interrupt flag		
					 
	MOV AH,AL 		; Save in it parameters in AH
	MOV DX,3FBH 	 
	MOV AL,80H
	OUT DX,AL
					
	MOV DL,AH 		
	MOV CL,4
	ROL DL,CL
	AND DX,0EH
	MOV DI,OFFSET BAUD_RATE
	ADD DI,DX 		
	MOV DX,03F9H 		
	MOV AL,CS:[DI]+1 	
	OUT DX,AL 		
	
	MOV DX,03F8H		
	MOV AL,CS:[DI] 
	OUT DX,AL 		
	
	MOV DX,3FBH 	
	MOV AL,AH 		
	AND AL,01FH 	
	OUT DX,AL 		

	MOV DX,03F9H 
	MOV AL,0H
	OUT DX,AL 
	RET
OPEN_RS232 ENDP	
	

RXCH_RS232 PROC NEAR
	MOV DX,3FDH		
	IN AL,DX 		
	TEST AL,1 		
	JZ NOTH		
	SUB DX,5 		
	IN AL,DX 		
	JMP EXIT2
NOTH: MOV AL,0
EXit2: RET
RXCH_RS232 ENDP
	
	
TXCH_RS232 PROC NEAR
	PUSH AX 	
	MOV DX,03FDH 	

TXCH_RS232_2:
	IN AL,DX 		
	TEST AL,20H 	
	JZ TXCH_RS232_2
	SUB DX,5 		
	POP AX 			
	OUT DX,AL 		
RET
TXCH_RS232 ENDP	   

SET_CURSOR_LOC PROC NEAR
	MOV AH,02H	     ;set cursor	
	MOV DH,ROW
	MOV DL,COL
	MOV BH,00H
	INT 10H
	RET
SET_CURSOR_LOC ENDP


SET_CURSOR_REM PROC NEAR
	MOV AH,02H	     ;set cursor	
	MOV DH,REMROW
	MOV DL,REMCOL
	MOV BH,00H
	INT 10H
	RET
SET_CURSOR_REM ENDP

GET_CURSOR PROC NEAR 
	MOV AH,03H		;get cursor position
	MOV BH,00H		;page number
	INT 10H
	RET
GET_CURSOR ENDP

BACKSPC PROC NEAR
	PUSH AX
	CALL GET_CURSOR		;pairnoume th thesi tou kersora
	CMP DL,09H			;elegxos an eimaste sth sthlh 10
	JE ADDRR 			;an nai menoume ekei kai den gyrizoume allo pisw
	PRINT AL			;typwnoume backspace (ousiastika pame mia thesi pisw)
	MOV AL,20H		
	PRINT AL			;typwnoume keno
	DEC DL				;meiwnoume th sthlh kata 1 giati me to print proxwrhse o kersoras
	CMP FREM,00H
	JE LOC1
	MOV REMCOL,DL			;enhmerwnoume th sthlh
	CALL SET_CURSOR_REM	;thetoume ton kersora
	JMP ADDRR
LOC1:
	MOV COL,DL
	CALL SET_CURSOR_LOC
ADDRR:
	POP AX
	RET
BACKSPC ENDP

UPDATE_REM PROC NEAR
	MOV AX,0601H	;scroll up remote window by 1 line
	MOV CX,0D09H	
	MOV DX,184FH
	MOV BH,07H
	INT 10H
	RET
UPDATE_REM ENDP

UPDATE_LOC PROC NEAR
	MOV AX,0601H	;scroll up local window by 1 line
	MOV CX,0009H	
	MOV DX,0C4FH
	MOV BH,07H
	INT 10H
	RET
UPDATE_LOC ENDP

CODE ENDS
END MAIN
