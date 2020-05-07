

.386
.model flat,c
PUBLIC MENU,INPUTNAME,FINDGOOD,BUYGOOD,COUNT,CHANGEINFO,CHANGEEN,ARRAY,DISPLAY,EXIT
INCLUDELIB UCRT.LIB
includelib legacy_stdio_definitions.lib
printf PROTO C:dword,:vararg
scanf proto C:dword,:vararg
_getch proto c:vararg
.DATA	

BNAME  DB	'LIUMEI',0  ;老板姓名
BPASS  DB	'358666',0,0,0  ;密码
AUTH  DB		0  ;当前登录状态
GOOD  DD 0
N  EQU	3  ;商品的数量
SNAME  DB	'LMSHOP',0  ;网店名称，用0结束
GA1  DB		'PEN',7 DUP(0),10  ;商品名称及折扣
         DW  	35,56,70,25,?  ;推荐度还未计算
GA2  DB		'BOOK', 6 DUP(0),9
         DW		12,30,25,5,?
GAN  DB		N-2 DUP('TempValue',0,8,15,0,20,0,30,0,2,0,?,?)
C1 DD 0;用来存放商
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
;菜单子程序
MENU PROC
	invoke printf,addr YOURNAME
	CMP AUTH,0
	JE CUSTOMER
	invoke printf,addr IN_NAME;显示当前用户名
	
CUSTOMER:
	invoke printf,addr CRLF	 
	
LP1:	
	invoke printf,addr BROWSE_GOOD
	 
	
	CMP GOOD,0
	JE DISPLAYNOGOOD;无浏览商品
	invoke printf,addr IN_GOOD;把偏移地址送到BX

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

;登录菜单子程序	
INPUTNAME PROC
	CMP AUTH,0
	JNE LOGGED
	invoke printf,addr PUTNAME;提示输入用户的名字
	 

	invoke scanf,addr strFormat,addr IN_NAME;输入用户名字
	
	LEA ebx,IN_NAME	
L0:	CMP BYTE PTR [ebx+2],0DH;和回车比较
	JE ERR	;是回车输出错误信息
	
	LEA esi,BNAME
	MOV edi,OFFSET IN_NAME 
	MOV AL,BYTE PTR [esi]
	MOV CX,6
L1:	CMP CX,0
	JE NAMEEXIT
	MOV AL,BYTE PTR [esi];这句话必须放到循环体中
	CMP AL,BYTE PTR [edi]
	JNE ERR;不相等，重新输入
	INC esi
	INC edi
	DEC CX
	JMP L1

NAMEEXIT :
	CMP BYTE PTR [edi],0
	JNE ERR
	MOV AUTH,1;输入成功
	;MOV BYTE PTR [edi],0;将结束符放入定义的名称中

INPUTPASSWORD:
	invoke printf,addr PUTPASSWORD;提示输入用户的密码
	 

	invoke scanf,addr strFormat,addr IN_PWD;输入密码
	
	LEA esi,BPASS
	MOV edi,OFFSET IN_PWD
	MOV AL,BYTE PTR [esi]
	MOV CX,6
L2:	CMP CX,0
	JE PWDEXIT
	MOV AL,BYTE PTR [esi]
	CMP AL,BYTE PTR [edi]
	JNE L0;不相等，重新输入
	INC esi
	INC edi
	DEC CX
	JMP L2
	
PWDEXIT:
	cmp byte ptr [edi],0
	jne err
	invoke printf,addr LOGIN;	登录成功提示
	 
	RET;	登录成功后返回主菜单

INPUTNAME ENDP

;查询商品子程序
FINDGOOD PROC 
	invoke printf,addr GOODNAME;提醒输入商品名称
	 

	invoke scanf ,addr strFormat,addr IN_GOOD

	LEA esi,GA1
	LEA ebx,GA1
	MOV edi,OFFSET IN_GOOD
	MOV CX,3
L3:	CMP CX,0
	JE ERR	;等于零，全部找完也没找到，提示失败
L4:	MOV AL,BYTE PTR [esi]
	CMP AL,0
	JE FINDSUS	;名称相符，查找成功，返回菜单
	CMP AL,BYTE PTR [edi]
	JNE FINDFAITH	;名称不相符，查找下一个
	INC esi
	INC edi
	JMP L4
	 
FINDSUS:
	CMP BYTE PTR [edi],'0';字符0！
	JNE ERR;还要确定物品名称不是输入的字符串的子串
	MOV BYTE PTR [edi],0
	MOV GOOD,ebx;将地址信息存放到good中,直接存放就可以
	invoke printf,addr FINDSUC
	 
	invoke printf,addr CRLF
	 
	;invoke printf,addr IN_GOOD;显示指定商品的名称
	 
	invoke printf,addr kong
	 
	
	;CALL F2T10
	;invoke printf,addr CRLF
	 
	;invoke printf,addr OUTBUF
	 
	RET

FINDFAITH:
	ADD ebx,21;查找失败，偏移地址加21个字节,跳转到下一个商品
	MOV esi,ebx
	MOV edi,OFFSET IN_GOOD
	DEC CX
	JMP L3

FINDGOOD ENDP

;购买商品子程序
BUYGOOD PROC 
	MOV ecx,M;不能和N公用CX
	CMP GOOD,0
	JE NO_GOOD
	MOV  ebx,GOOD
L7:
	MOV SI,[ebx+15];获得进货总数,不能写成BX+15
	MOV DI,[ebx+17];获得已售数目
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

;计算推荐度子程序
COUNT PROC 
	pushad
	MOV ebx,OFFSET GA1
	MOV ecx,N
L5:	CMP ecx,0
	JE L6;全部计算完毕
	MOV EAX,[EBX+17];获得已售数目
	AND EAX,0FFFFH
	SHL EAX,6;先乘以64
	MOV EDX,0
	MOV EDI,[EBX+15];获得进货数量	
	AND EDI,0FFFFH;注意这里EDI应该和0FFFFH相与
	DIV EDI;再除以进货数量
	MOV C1,EAX;商->C1
	MOV EAX,[EBX+13];得到销售价
	AND EAX,0FFFFH
	MUL BYTE PTR [EBX+10];销售价乘以折扣
	MOV EDI,10
	MOV EDX,0;不要忘记将高位置0
	DIV EDI;再除以10得到实际销售价
	MOV EDI,EAX;得到的结果放入EDI中
	MOV EAX,[EBX+11];得到进价
	AND EAX,0FFFFH
	MOV EDX,0
	SHL EAX,7;进货价乘以128
	DIV EDI;得到公式的前半部分(进价/实际销售价格）
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

;修改信息子程序
;实验三第一个任务第二部分
;修改商品信息
CHANGEINFO PROC
;	CALL F10T2
;	CMP AUTH,0
;	JE MENU
;	CMP GOOD,0
;	JMP CUSTOMER;这里的跳转只是起到一个实现结束子程序的作用，该标号只是输出了一个回车换行就ret了
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