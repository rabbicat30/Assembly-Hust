

.386
.model flat,c
PUBLIC MENU,INPUTNAME,FINDGOOD,BUYGOOD,COUNT,CHANGEINFO,CHANGEEN,ARRAY,DISPLAY,EXIT
INCLUDELIB UCRT.LIB
includelib legacy_stdio_definitions.lib
printf PROTO C:dword,:vararg
scanf proto C:dword,:vararg
_getch proto c:vararg
.DATA	

BNAME  DB	'LIUMEI',0  ;�ϰ�����
BPASS  DB	'358666',0,0,0  ;����
AUTH  DB		0  ;��ǰ��¼״̬
GOOD  DD 0
N  EQU	3  ;��Ʒ������
SNAME  DB	'LMSHOP',0  ;�������ƣ���0����
GA1  DB		'PEN',7 DUP(0),10  ;��Ʒ���Ƽ��ۿ�
         DW  	35,56,70,25,?  ;�Ƽ��Ȼ�δ����
GA2  DB		'BOOK', 6 DUP(0),9
         DW		12,30,25,5,?
GAN  DB		N-2 DUP('TempValue',0,8,15,0,20,0,30,0,2,0,?,?)
C1 DD 0;���������
C2 DD 2
C3 DD 128
OUTBUF DB 45 DUP(0)
PUTNAME   DB		'Please Input Your Name: ',0
PUTPASSWORD  DB	'Please Inout Your Password: ',0
INERR  DB	'Input Error!Try Aggain!',0
LOGIN DB	0AH,0DH,'Login Successfully!',0
GOODNAME  DB	'Input the Name of Goods You Look Up And End With 0: ',0
NOTLOG  DB	0AH,0DH,'Please Log In First!',0
NOGOOD DB	0AH,0DH,'No Good Left',0
FINDSUC DB 0AH,0DH,'Find Successfully!',0
YOURNAME DB 0AH,0DH,'NAME: ',0
BROWSE_GOOD DB 0AH,0DH,'GOOD: ',0
HAVELOGINED DB 'You Have Logged In',0
CSCONTENT DW 0
strFormat db "%s",0
M  EQU 1
IN_NAME DB  7 dup(0)
IN_PWD 	DB  7 dup(0)
IN_GOOD DB  11 dup(0)
CRLF DB 0AH,0DH
kong DB ' '
tmp db 4 dup(0)

.CODE	
;�˵��ӳ���
MENU PROC
	invoke printf,addr YOURNAME
	CMP AUTH,0
	JE CUSTOMER
	invoke printf,addr IN_NAME;��ʾ��ǰ�û���
	
CUSTOMER:
	invoke printf,addr CRLF	 
	
LP1:	
	invoke printf,addr BROWSE_GOOD
	 
	
	CMP GOOD,0
	JE DISPLAYNOGOOD;�������Ʒ
	invoke printf,addr IN_GOOD;��ƫ�Ƶ�ַ�͵�BX

DISPLAYNOGOOD:
	invoke printf,addr CRLF 
	RET 

MENU ENDP

ERR:
	invoke printf,addr INERR
	 
	RET
	
NOTLOGIN:
	invoke printf,addr NOTLOG
	 
	 RET

;��¼�˵��ӳ���	
INPUTNAME PROC
	CMP AUTH,0
	JNE LOGGED
	invoke printf,addr PUTNAME;��ʾ�����û�������
	 

	invoke scanf,addr strFormat,addr IN_NAME;�����û�����
	
	LEA ebx,IN_NAME	
L0:	CMP BYTE PTR [ebx+2],0DH;�ͻس��Ƚ�
	JE ERR	;�ǻس����������Ϣ
	
	LEA esi,BNAME
	MOV edi,OFFSET IN_NAME 
	MOV AL,BYTE PTR [esi]
	MOV CX,6
L1:	CMP CX,0
	JE NAMEEXIT
	MOV AL,BYTE PTR [esi];��仰����ŵ�ѭ������
	CMP AL,BYTE PTR [edi]
	JNE ERR;����ȣ���������
	INC esi
	INC edi
	DEC CX
	JMP L1

NAMEEXIT :
	CMP BYTE PTR [edi],0
	JNE ERR
	MOV AUTH,1;����ɹ�
	;MOV BYTE PTR [edi],0;�����������붨���������

INPUTPASSWORD:
	invoke printf,addr PUTPASSWORD;��ʾ�����û�������
	 

	invoke scanf,addr strFormat,addr IN_PWD;��������
	
	LEA esi,BPASS
	MOV edi,OFFSET IN_PWD
	MOV AL,BYTE PTR [esi]
	MOV CX,6
L2:	CMP CX,0
	JE PWDEXIT
	MOV AL,BYTE PTR [esi]
	CMP AL,BYTE PTR [edi]
	JNE L0;����ȣ���������
	INC esi
	INC edi
	DEC CX
	JMP L2
	
PWDEXIT:
	cmp byte ptr [edi],0
	jne err
	invoke printf,addr LOGIN;	��¼�ɹ���ʾ
	 
	RET;	��¼�ɹ��󷵻����˵�

INPUTNAME ENDP

;��ѯ��Ʒ�ӳ���
FINDGOOD PROC 
	invoke printf,addr GOODNAME;����������Ʒ����
	 

	invoke scanf ,addr strFormat,addr IN_GOOD

	LEA esi,GA1
	LEA ebx,GA1
	MOV edi,OFFSET IN_GOOD
	MOV CX,3
L3:	CMP CX,0
	JE ERR	;�����㣬ȫ������Ҳû�ҵ�����ʾʧ��
L4:	MOV AL,BYTE PTR [esi]
	CMP AL,0
	JE FINDSUS	;������������ҳɹ������ز˵�
	CMP AL,BYTE PTR [edi]
	JNE FINDFAITH	;���Ʋ������������һ��
	INC esi
	INC edi
	JMP L4
	 
FINDSUS:
	CMP BYTE PTR [edi],'0';�ַ�0��
	JNE ERR;��Ҫȷ����Ʒ���Ʋ���������ַ������Ӵ�
	MOV BYTE PTR [edi],0
	MOV GOOD,ebx;����ַ��Ϣ��ŵ�good��,ֱ�Ӵ�žͿ���
	invoke printf,addr FINDSUC
	 
	invoke printf,addr CRLF
	 
	;invoke printf,addr IN_GOOD;��ʾָ����Ʒ������
	 
	invoke printf,addr kong
	 
	
	;CALL F2T10
	;invoke printf,addr CRLF
	 
	;invoke printf,addr OUTBUF
	 
	RET

FINDFAITH:
	ADD ebx,21;����ʧ�ܣ�ƫ�Ƶ�ַ��21���ֽ�,��ת����һ����Ʒ
	MOV esi,ebx
	MOV edi,OFFSET IN_GOOD
	DEC CX
	JMP L3

FINDGOOD ENDP

;������Ʒ�ӳ���
BUYGOOD PROC 
	MOV ecx,M;���ܺ�N����CX
	CMP GOOD,0
	JE NO_GOOD
	MOV  ebx,GOOD
L7:
	MOV SI,[ebx+15];��ý�������,����д��BX+15
	MOV DI,[ebx+17];���������Ŀ
	CMP SI,DI
	JZ NO_GOOD
	INC DI
	MOV [ebx+17],DI
	call COUNT

	DEC ecx
	CMP ecx,0
	JE	LOOPOVER
	JMP L7
	
LOOPOVER:
    invoke printf,addr CRLF
	 
	RET 
BUYGOOD ENDP

;�����Ƽ����ӳ���
COUNT PROC 
	pushad
	MOV ebx,OFFSET GA1
	MOV ecx,N
L5:	CMP ecx,0
	JE L6;ȫ���������
	MOV EAX,[EBX+17];���������Ŀ
	AND EAX,0FFFFH
	SHL EAX,6;�ȳ���64
	MOV EDX,0
	MOV EDI,[EBX+15];��ý�������	
	AND EDI,0FFFFH;ע������EDIӦ�ú�0FFFFH����
	DIV EDI;�ٳ��Խ�������
	MOV C1,EAX;��->C1
	MOV EAX,[EBX+13];�õ����ۼ�
	AND EAX,0FFFFH
	MUL BYTE PTR [EBX+10];���ۼ۳����ۿ�
	MOV EDI,10
	MOV EDX,0;��Ҫ���ǽ���λ��0
	DIV EDI;�ٳ���10�õ�ʵ�����ۼ�
	MOV EDI,EAX;�õ��Ľ������EDI��
	MOV EAX,[EBX+11];�õ�����
	AND EAX,0FFFFH
	MOV EDX,0
	SHL EAX,7;�����۳���128
	DIV EDI;�õ���ʽ��ǰ�벿��(����/ʵ�����ۼ۸�
	ADD EAX,C1
	MOV WORD PTR [EBX+19],AX
	ADD EBX,21
	DEC ecx
	JMP L5
L6:
	popad
	RET 
COUNT ENDP
	
ARRAY PROC 
	RET 
ARRAY ENDP

;�޸���Ϣ�ӳ���
;ʵ������һ������ڶ�����
;�޸���Ʒ��Ϣ
CHANGEINFO PROC
;	CALL F10T2
;	CMP AUTH,0
;	JE MENU
;	CMP GOOD,0
;	JMP CUSTOMER;�������תֻ����һ��ʵ�ֽ����ӳ�������ã��ñ��ֻ�������һ���س����о�ret��
;	CALL F2T10
;	invoke printf,addr CRLF
;	invoke printf,addr OUTBUF
	RET 
CHANGEINFO ENDP

CHANGEEN PROC
	RET 
CHANGEEN ENDP

DISPLAY PROC 
	invoke printf,addr CRLF
	 
	MOV ecx,4
	MOV ebx,CS
LOOP1:
	ROL BX,4
	MOV AL,BL
	AND AL,0FH
	ADD AL,30H
	CMP AL,3AH
	JL DISP
	ADD AL,7
DISP:
	
	lea edx,tmp
	add edx,4
	sub edx,ecx
	mov byte ptr [edx],al
	DEC ecx
	JNZ LOOP1
	invoke printf,addr tmp
	RET
DISPLAY ENDP
	
NO_GOOD:
	invoke printf,addr  NOGOOD
	 
	
	invoke printf,addr CRLF
	 
	
;	MOV AX,1
;	CALL TIMER
	RET 
	
LOGGED: 
	invoke printf,addr HAVELOGINED
	 
	RET 

EXIT PROC 
	RET 
EXIT ENDP
end