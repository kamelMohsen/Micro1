INCLUDE ALLMACROS.INC
.MODEL SMALL
.DATA 
; المعلومات و المتغيرات و الرسائل التي ستظهر بداخل اللعبه
MESS1 DB "Enter player name: $"
MESS2 DB "GAME IS PAUSED, PRESS ENTER TO CONTINUE$" 
MESS3 DB "                                       $" 
MESS4 DB "PRESS SPACE TO RESTART THE GAME$" 
P1NAME DB 15 DUP(?) 
P1POS DW 3920
P1ATT DW 3921
COLOR DB 0CH
LINE 80 DUP ("-"),"$" 
BARR1 DW 3998
BARR1ATT DW 3999 
BARR2 DW 3900
BARR2ATT DW 3901
BARR3 DW 3998
BARR3ATT DW 3999 
COUNTER DB 00
DELAYER DW 0000H
DELAYER1 DW 0000H  
DELAYER2 DW 0000H 
LEVEL DW 05FFFH 
UP DB 00
.CODE 

MAIN PROC FAR
    
    
    MOV AX,@DATA
    MOV DS,AX
    
    
    
    
          
 
    
       CALL INTIALIZEAPP
       RESTART:
       CLEARSCREEN     ; ماكرو يقوم بتنضيف الشاشه عبر تحريكها بالكامل الى اعلى
       SETCURSOR 0000H           ;ماكرو يقوم بتعيين مكان السهم الخاص بالفاره
       SHOWMESSAGE P1NAME         ;مكرو يعرض الرساله - في هذه الحاله اسم اللاعب       
       SETCURSOR 0200H           ;ماكرو يقوم بتعيين مكان السهم الخاص بالفاره
       SHOWMESSAGE LINE         ; يعرض ال"-"  80 مره لاعتباره كخط فاصل
 ;هذا الجزء يقوم بتعيين المعلومات من جديد لاعاده استخدامها في حالة الخساره
       MOV P1POS,3920   
       MOV P1ATT,3921 
       MOV BARR1,3998
       MOV BARR1ATT,3999 
       MOV BARR2,3900
       MOV BARR2ATT,3901
       MOV BARR3,3998
       MOV BARR3ATT,3999 
       MOV COUNTER,00
       MOV DELAYER,0000H
       MOV DELAYER1,0000H  
       MOV DELAYER2,0000H 
       MOV LEVEL,05FFFH 
       MOV UP,00
   
       CALL DRAWPLAYERONE    ;إجراء يقوم برسم الاعب في مكانه الافتراضي
       CALL DRAWOBS          ;اجراء يقوم برسم العوائق في مكانها الافتراضي
         MOV AH,0H           
         INT 16H             ; انتربت يقف و ينتظر ادخال او ضغط زر
         
         CMP AH,39H          ;اذا كان الزر هو زر المسافه سيقفز الى الحلقه INTIATAMOVE 
         JZ INTIATEMOVE         
       
    
     JMP MOVEPLAYER    
     PAUSE:
	 CLEARBUFFER              ; يقوم بتنضيف المخزن المؤقت للوحة المفاتيح   
	 SETCURSOR 0B18H     
     SHOWMESSAGE MESS2       ; هذه الحلقه هي مجرد ايقاف مؤقت للعبه في حال ضغط اللاعب على زر الانتر
	 MOV AH, 0H         
	 INT 16H            ; يستطيع اللاعب الخروج من الحلقه اذا ضغط على زر الانتر مره اخرى
	 CMP AH, 1CH         
	 JZ CLEARENTER        
     JMP PAUSE        
       
       
       
         MOVEPLAYER: 
         
         MOV AH,1H           
         INT 16H             
         
         CMP AH,39H          ;حلقه تنتظر من اللاعب ضغط زر المسافه و تقوم بتحديث العوائق و تجاهل اي ضغطه زر اخر
         JZ INTIATEMOVE          
          

         CMP AH, 1CH        
         JZ PAUSE
                     
         CMP AH,01H         
         JNE CLEARA           
         JMP UPDATEOBS    
         MP1:
         JMP UPDATEMOVE
         JMP MOVEPLAYER
         
    
       UPDATEOBS:

                                     
       SUB BARR1,02                ;حلقة تقوم باستعاء الاجراء لتحديث العوائق    
       SUB BARR1ATT,02             ;قبل الذهاب للاجراء تقوم بطرح مكان العائق ليصبح عل يسار المكان السابق 
       
       SUB BARR2,02
       SUB BARR2ATT,02
       CALL DRAWOBS
       JMP MP1 
       

       INTIATEMOVE:
       CMP COUNTER,00     ;حلقة تقوم ببدء حركة القفز للتنين
       JZ SKPS
       CLEARBUFFER
       JMP MOVEPLAYER
       SKPS:
       CLEARBUFFER
       MOV COUNTER,10    ; عدد قفزات التنين
       MOV UP,01   ; متغير لمعرفه اتجاه حركة التنين
       JMP MOVEPLAYER  
       
	   
       UPDATEMOVE:
       MOV CX,LEVEL     ; حلقة تقوم بتحديث حركة التنين
       INC DELAYER     ; متغير لابطاء حركة التنين و في نفس الوقت عدم ابطاب بقية اللعبه
       CMP DELAYER,CX  ; اذا وصل المتغير لقيمه معينه يقوم التنين بالتحديث غير ذلك ترجع اللعبه الى تحديث باقي الاشياء
       JNZ MP1
       MOV CX,LEVEL  ; هذا المتغير ينقص مع كل حركه للتنين لتصبح اللعبه اسرع مع الوقت 
       CMP CX,07FFFH   ; هذه المقارنه توقف الصعوبه عند حد معين
       JBE  SPIK
       SUB LEVEL,0FH 
       SPIK:
       MOV DELAYER,0000H
       CMP COUNTER,00
       JZ SKPP 
       CALL MOVEBARR
        
        SKPP:
        
        JMP MOVEPLAYER
       
       

    
    
     CLEARA:           
     CLEARBUFFER       ; حلقه مساعده لتنظيف المخزن المؤقت للوحه المفاتيح في حاله ضغط زر بالخطأ
     JMP MOVEPLAYER   
     CLEARENTER:
     SETCURSOR 0B18H   ; حلق تقوم بالتنظيف بعد ايقاف اللعبه مؤقتا   
     SHOWMESSAGE MESS3 
     JMP MOVEPLAYER
    
    
    
    
    
    
    
    
    
    
    
JMP HALT    
MAIN ENDP 

INTIALIZEAPP PROC 

    CLEARSCREEN               
    SETCURSOR 0A15H           
    SHOWMESSAGE MESS1         ;رسالة طلب اسم المستخدم
    SETCURSOR 0B15H           
    MOV BX,OFFSET P1NAME      
    TAKELETTER                ;ماكرو ياخذ حرف فقط
    MOV [BX],AL               ;ننقل اول حرف الى المكان في الذاكره المشار اليه ب بي اكس            
    DISPLAYCHARACTER AL       ; يعرض الحرف المأخوذ فقط
    INC BX                    ;ينتقل الى المكان القادم الذي يشير اليه بي اكس
    MOV CL,13                 ;عداد لاقصي عدد من الاحرف الممكنه
    TAKENAME1:                
    GETKEY                    ;ماكرو ياخذ حرف و يضعه في المسجل AL
    CMP AH,1CH                
    JZ ENDTN1                 
    MOV [BX], AL              
    DISPLAYCHARACTER AL       
    INC BX                   
    DEC CL                    ;ينقص العداد
    JNZ TAKENAME1            
    ENDTN1:                   
    MOV [BX],'$'              
    CLEARSCREEN
  
RET
INTIALIZEAPP ENDP



DRAWPLAYERONE PROC
      PUSHA
      mov ax,0b800h 
      mov es,ax
;ننسخ المعلومات الى الحافظات حتى منتسوحش و نغير مكان التنين     
      MOV BX,P1POS
      MOV DX,P1ATT
      MOV DI,DX
      MOV CL,COLOR
      
;بنرسم الجزء السفلي للتنين      
      ADD BX,0004
      ADD DI,0004
      
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL  
       
      
      SUB BX,0002
      SUB DI,0002  
      

      
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL  
       
      
      SUB BX,0002
      SUB DI,0002 
      
      mov es:[BX],0DBH      ;((الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL  
      
      SUB BX,0002
      SUB DI,0002  
      
      mov es:[BX],"-"      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL  
      
      SUB BX,0002
      SUB DI,0002  
      
      mov es:[BX],"-"      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL      
;بنرسم الجزء المتوسط للتنين     
      MOV BX,P1POS
      MOV DX,P1ATT
      MOV DI,DX
      
      
      
      SUB BX,156
      SUB DI,156
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL  
      
     
      
      
      MOV BX,P1POS
      MOV DX,P1ATT
      MOV DI,DX
      
;بنرسم الجزع الءلوي للتنين    
      
      SUB BX,316
      SUB DI,316
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL  
      
      ADD BX,2
      ADD DI,2
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL    
       
      ADD BX,2
      ADD DI,2
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],CL 
      
      
      POPA   
    
    
    
    
    
RET
DRAWPLAYERONE ENDP

MOVEBARR PROC
    
    
       CMP UP,01
       JZ SKP
       JMP DOWN 
       
       
       SKP:
       MOV COLOR,00
       CALL DRAWPLAYERONE
       SUB P1POS,160
       SUB P1ATT,160
       MOV COLOR,0CH
       CALL DRAWPLAYERONE
       DEC COUNTER
       CMP COUNTER,00
       JNZ SKPA 
       
       MOV COUNTER,10
       MOV UP,00
       
       
       
   
       DOWN:
       MOV COLOR,00
       CALL DRAWPLAYERONE
       ADD P1POS,160
       ADD P1ATT,160
       MOV COLOR,0CH
       CALL DRAWPLAYERONE
       DEC COUNTER
      
      
       SKPA:    
            
    
RET

MOVEBARR ENDP 

    
 
    
    



DRAWOBS PROC
      PUSHA
      mov ax,0b800h 
      mov es,ax  
      
       ;رسم العوائق عبر مسح المكان السابق عبر اعادة رسمها فوق المكان القديم بالاسود
       CMP BARR1,3844
       JNZ SKLP   
         MOV BX,BARR1
      MOV DX,BARR1ATT
      MOV DI,DX                        
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
          
       MOV BARR1,3998
       MOV BARR1ATT,3999
        
       SKLP: 
      
      MOV BX,BARR1
      MOV DX,BARR1ATT
      MOV DI,DX
      
      
      
      ;رسم العوائق المحدثه
                            
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;((الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;((الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
          
      MOV BX,BARR1
      MOV DX,BARR1ATT
      MOV DI,DX
        
                         
      SUB BX,02
      SUB DI,02                   
                         
                         
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH    
      ;اختبار الاصطدام----------------------
      
      
    MOV DX,P1POS
      CMP BX,DX
      JZ  LOSE
      ADD BX,2
      CMP BX,DX
      JZ  LOSE
      ADD BX,158
      CMP BX,DX
      JZ  LOSE
      ADD BX,2
      CMP BX,DX
      JZ  LOSE
      SUB DX,02
    
      

      
      ;العائق الثاني
      
      
      
      
        ;رسم العوائق عبر مسح المكان السابق عبر اعادة رسمها فوق المكان القديم بالاسود
       CMP BARR2,3844
       JNZ SKLP1   
         MOV BX,BARR2
      MOV DX,BARR2ATT
      MOV DI,DX                        
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
          
       MOV BARR2,3998
       MOV BARR2ATT,3999
        
       SKLP1: 
      
      MOV BX,BARR2
      MOV DX,BARR2ATT
      MOV DI,DX
      
      
      
      
                            
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
          
      MOV BX,BARR2
      MOV DX,BARR2ATT
      MOV DI,DX
        
                         
      SUB BX,02
      SUB DI,02                   
                         
      ;رسم العوائق المحدثه                   
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH 
      
           ;اختبار الاصطدام----------------------
    MOV DX,P1POS
      CMP BX,DX
      JZ  LOSE
      ADD BX,2
      CMP BX,DX
      JZ  LOSE
      ADD BX,158
      CMP BX,DX
      JZ  LOSE
      ADD BX,2
      CMP BX,DX
      JZ  LOSE
      SUB DX,02
         
                      
          ;العائق الثالث
      
       ;رسم العوائق عبر مسح المكان السابق عبر اعادة رسمها فوق المكان القديم بالاسود
       ;هذا العائق يرسم بعد فتره من بدئ اللعبه	   
       INC DELAYER2 
       CMP DELAYER2,085H  
       JNZ SKS1 
       
       MOV DELAYER2,084H
      
          
        SUB BARR3,02
       SUB BARR3ATT,02
        
       CMP BARR3,3844
       JNZ SKLP2   
         MOV BX,BARR3
      MOV DX,BARR3ATT
      MOV DI,DX                        
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;((الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
          
       MOV BARR3,3998
       MOV BARR3ATT,3999
        
       SKLP2: 
      
      MOV BX,BARR3
      MOV DX,BARR3ATT
      MOV DI,DX
      
      
      
      
                            
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],00H
          
      MOV BX,BARR3
      MOV DX,BARR3ATT
      MOV DI,DX
        
                         
      SUB BX,02
      SUB DI,02                   
                         
       ;رسم العوائق المحدثه                  
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH        
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH   
      
      SUB BX,158
      SUB DI,158 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH
      
      
      SUB BX,02
      SUB DI,02 
      
      mov es:[BX],0DBH      ;(الرقم الافقي * 80 + العمود)*2
      mov es:[DI],0AH   
    
          ;اختبار الاصطدام----------------------
        
    MOV DX,P1POS
      CMP BX,DX
      JZ  LOSE
      ADD BX,2
      CMP BX,DX
      JZ  LOSE
      ADD BX,158
      CMP BX,DX
      JZ  LOSE
      ADD BX,2
      CMP BX,DX
      JZ  LOSE
      SUB DX,02
    
      JMP SKS1
      
      
      
      
      
      
      LOSE:
      
      
      
   	 SETCURSOR 0B18H     
     SHOWMESSAGE MESS4  
      MOV AH,0H           
         INT 16H             
         CMP AH,39H
         JZ RESTART
     JMP LOSE 
      
      
      SKS1:                
       
       
       
       
      POPA   
    
    
    
    
    
RET
DRAWOBS ENDP


HALT:

END MAIN    