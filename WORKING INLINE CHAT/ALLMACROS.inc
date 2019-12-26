transfertodecimal macro hex,d1,d2
        local convert
        local store	
        local halt		
        convert:
		cmp d2,39h
		jz store
		inc d2
		dec hex
        jnz convert
		jmp halt
        store:
		inc d1
		mov d2,2fh
		jmp convert

halt:		


endm transfertodecimal
;----------------MACROS--------------
SHOWMESSAGE MACRO MYMESSAGE
				PUSHA
				MOV AH,9H
				MOV DX,OFFSET MYMESSAGE
				INT 21H
				POPA
ENDM SHOWMESSAGE
;----------------------------------------------------------------------------------------
DELAY MACRO MYMESSAGE
LOCAL LOOOP		 
		 PUSHA
		MOV BX,0FFFFH
		LOOOP:
		DEC BX
		JNZ LOOOP
        POPA
ENDM DELAY
;----------------------------------------------------------------------------------------
STOPFORKEY MACRO  MYMESSAGE	
				MOV AH,07
				INT 21H
ENDM STOPFORKEY
;-----------------------------------------------------------------------------------------
DISPLAYCHARACTER MACRO CHARACTER 
				
				MOV AH,2
				MOV DL,CHARACTER 
				INT 21H
				
ENDM DISPLAYCHARACTER
;------------------------------------------------------------------------------------------
CHANGECOLOR MACRO COLOR,NUMBER 
				PUSHA
				MOV AH,9         
				MOV BH,0 
				MOV AL,0			
				MOV CX,NUMBER       
				MOV BL,COLOR 
				INT 10H 
				POPA	
ENDM CHANGECOLOR
;------------------------------------------------------------------------------------------
SETCURSOR MACRO CURSORLOCATION
				PUSHA
				MOV BX,0
				MOV AH,2   
				MOV DX,CURSORLOCATION 
				INT 10H
                POPA				
                
ENDM CURSORLOCATION
;-------------------------------------------------------------------------------------------
GETKEY MACRO    
	 mov ah,0   
     int 16h
ENDM GETKey  
;--------------------------------------------------------------------------------------------
CLEARSCREEN MACRO
     PUSHA
	 mov ax,0600h   
     mov bh,07
     mov cx,0
     mov dx,184FH      
     int 10h
     POPA
ENDM CLEARSCREEN  
CMPRANGE MACRO R1,R2
        LOCAL CHECK1
		LOCAL CHECK2
		LOCAL CHECK3
         CMP AL,R1
		 JNAE CHECK3
		 
		 CHECK1:
         CMP AL,R2
         JNBE CHECK3
         
         CHECK2: MOV AH,0		 
         CHECK3:		 
 
ENDM CMPRANGE 
;---------------------------------------------------------------------------------------------------------
CMPRANGE1 MACRO I1,R1,R2
        LOCAL CHECK1
		LOCAL CHECK2
		LOCAL CHECK3
		LOCAL CHECK4
		PUSHA
         MOV AL,R1
 		 CMP I1,AL
		 JNAE CHECK3
		 
		 CHECK1:
         MOV AL,R2
		 CMP I1,AL
         JNBE CHECK3
         
         CHECK2:
         POPA
		 MOV AH,0
JMP CHECK4		 
         CHECK3:		 
 POPA 
 CHECK4:
ENDM CMPRANGE1 
;------------------------
TAKELETTER MACRO
          LOCAL TFL
		  LOCAL LAST
		  TFL:
		  GETKEY
          CMPRANGE 41H,5AH
          CMP AH,0 
          JZ LAST
          CMPRANGE 61H,7AH
          CMP AH,0 
          JNZ TFL
          LAST:		  
ENDM TAKELETTER
;-------------------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------------------
CLEARBUFFER MACRO
MOV AH,0CH
MOV AL,0
INT 21H
ENDM CLEARBUFFER

;----------------------------------------------------------------------------------------
	  
;-----------------------------------------------------------------------------

;-------------------------------------------------------------------------------
POWERUPS MACRO TYP,POWERPOS
	LOCAL FREEZE
	LOCAL WAVE
	LOCAL CONT
	LOCAL MOVE
	LOCAL INCR
	LOCAL LOOOP1
	LOCAL LOOOP2
	LOCAL ENDD
	LOCAL P1
	LOCAL P2
	PUSHA

	
	    MOV AH,2CH   ;TAKE SYSTEM TIME
        INT 21H
     
        CMP DL,5H    ;TO ENSURE NOT TO DRAW IT IN LEFT BORDER
        JL INCR 
        CMP DL,4BH
        JG MOVE
     
CONT:   MOV DH,0AH       ;SET Y-AXIS TO CENTER OF THE PAGE
        mov ah,2         ;MOVE CRUSOR TO THE RANDOM POSITION
        int 10h
        MOV POWERPOS ,DX       ;SAVE POSITION TO USE IT TO HIDE THE POWER
     
     
       ;;;;;;;;;DRAW POWER;;;;;;;;;;;
     
     CMP TYP,1H 
     JZ FREEZE 
     CMP TYP,2H
	 JZ INVERT
     WAVE:
     mov ah,9 
     mov bh,0 
     mov al, 1Dh     ; SHAPE <->
     mov cx,1h 
     mov bl,04Fh     ;RED + WHITE BACKGROUND
     int 10h 
     JMP ENDD 

     FREEZE:
     mov ah,9 
     mov bh,0 
     mov al, 02Ah     ; SHAPE SNOW
     mov cx,1h 
     mov bl,4Fh     ;RED + WHITE BACKGROUND
     int 10h
     JMP ENDD
       
	 INVERT: 
     mov ah,9 
     mov bh,0 
     mov al, 0Fh     ; SHAPE SNOW
     mov cx,1h 
     mov bl,4Fh     ;RED + WHITE BACKGROUND
     int 10h
     JMP ENDD

	
	 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
 	INCR:
	ADD DL,DL      ;ADD DL WITH IT SELF TO CHANGE THE X-AXIS 
   	JMP CONT            ;RETURN TO DRAW
    	
	MOVE:
	SUB DL,DH      ;SUBTRACT FROM DL RABDOM VALUE LIKE DH WHICH CHANGE WITH TIME 
    	JMP CONT            ;RETURN TO DRAW
	 	
	ENDD: 

	POPA  

ENDM POWERUPS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
REPEAT MACRO VALUE
	PUSHA
	ADD VALUE,1H
	mov ah,9 ;Display
	mov bh,0 ;Page 0
	mov al,00H ;Letter D
	mov cx,VALUE ;5 times
	mov bl,0000h ;Green (A) on white(F) background
	int 10h
	POPA

ENDM REPEAT
PRINTCOLOR MACRO COLOR,CHARACTER
				PUSHA
				MOV AH,9         
				MOV BH,0 
				MOV AL,CHARACTER			
				MOV CX,1       
				MOV BL,COLOR 
				INT 10H 
				POPA	
ENDM PRINTCOLOR
;----------------------
GETKEYCHAT MACRO  
		LOCAL REEEED
	REEEED: CALL RECEIVINGCHAT
	 mov ah,1  
     int 16h
	 CMP AH,1
	 JZ REEEED
ENDM GETKEYCHAT 

