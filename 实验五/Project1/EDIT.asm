.386
.model flat,stdcall
option casemap: none

INCLUDE D:\masm32\INCLUDE\WINDOWS.inc
INCLUDE D:\masm32\INCLUDE\GDI32.inc
INCLUDE D:\masm32\INCLUDE\USER32.inc
INCLUDE D:\masm32\INCLUDE\KERNEL32.inc
INCLUDE D:\masm32\INCLUDE\COMCTL32.inc

;���ļ�
INCLUDELIB GDI32.lib
INCLUDELIB USER32.lib
INCLUDELIB KERNEL32.lib
INCLUDELIB COMCTL32.lib

;����ԭ������
WinMain proto:dword,: dword,:dword,:dword 
WndProc proto: dword,:dword,:dword,:dword
DISPLAY proto
RANK proto
Change proto
Count_Recommendation proto
F2T10 proto


item struct
	inname db 10 dup(' ')
	discount db 0
	cost dw 0
	sales dw 0
	purchase_amount dw 0
	sale_amount dw 0
	reco dw 0
item ends
;-----------------------------------------------------
.data
szDisplayName db "Our Fist Window",0			;���ڱ�����
CommandLine dd 0								;������λ��
hWnd dd 0										;���ھ��
hInstance dd 0									;ʵ�����
hWndEdit dd 0									;�༭���ھ��
szFileError db "Read or Write File Error.",0	;������Ϣ
szError db "Error!",0							;����Ի��������
szEditClass db "EDIT",0							;�༭��������
szClassName db "MainWndClass",0					;�����ڵ�����
AboutMsg db "CS1806 I'm LiuMei!",0;					"About"�˵���ʾ��Ϣ
												
TheText db "Save the Text?",0					;�����ļ��˵���ʾ��Ϣ
TheExit db "Please Confirm Exit.",0				;EXIT�˵���ʾ��Ϣ
MAXSIZE = 2000									;�ļ�����󳤶�
Buf db MAXSIZE+1 DUP(0)							;��/д�ļ�ʱ�Ļ�����

outname db 'item name',0
outdiscount db 'discount',0
outcost db 'cost',0
outsales db 'sales',0
outpuchase_num db 'purchase num',0
outsalesnum db 'sale num',0
outrec db 'recommendation',0
GOOD	item <'PEN',10,35,56,70,25,?>
		item <'BOOK',9,12,35,25,5,?>
		item <'PENCILE',8,2,3,100,66,?>
		item <'SWEET',8,20,40,68,32,?>
		item <'MILK',9,5,8,50,25,?>
N EQU 5
c1 dd 0
count dd 0
thesize EQU 21
outbuf db 10 DUP(0);��Ŷ�����ת�����ʮ������
.code
;------------------------������---------------------------
start :
invoke GetModuleHandle,NULL;���ʵ�����
mov hInstance,eax
invoke InitCommonControls;��ʼ����༭�������йصĹ������
invoke GetCommandLine;��������е�ַ
mov CommandLine,eax
invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT;���봰����������
invoke ExitProcess,eax;�˳������ز���ϵͳ

;---------------------����������--------------------------
WinMain proc hInst: dword,
		hPrevInst:dword,
		CmdLine :dword,
		CmdShow:dword
;���¶���ֲ�����
local wc : WNDCLASSEX;��������������Ҫ����Ϣ�иýṹ˵��
local msg: MSG;��Ϣ�ṹ�������ڴ�Ż�ȡ����Ϣ
local Wwd :dword ;���ĸ�������Ŵ����������ڵ�λ�úʹ�С��Ϣ
local Wht :dword 
local Wtx :dword 
local Wty :dword 
local rectClient :RECT;��������ṹ�������ڴ���������û���������

;��WNDCALSSEX�ṹ����wc�ĸ��ֶθ�ֵ
mov wc.cbSize ,sizeof WNDCLASSEX
mov wc.style ,CS_VREDRAW + CS_HREDRAW + CS_DBLCLKS \
		+CS_BYTEALIGNCLIENT+ CS_BYTEALIGNWINDOW;���ڵķ��
mov wc.lpfnWndProc , offset WndProc;���ڹ��̵���ڵ�ַ��ƫ�Ƶ�ַ��
mov wc.cbClsExtra,NULL
mov wc.cbWndExtra,NULL
push hInst
pop wc.hInstance
mov wc.hbrBackground,COLOR_WINDOW +1 ;��ɫ
mov wc.lpszMenuName,NULL
mov wc.lpszClassName,offset szClassName;���������ַ����ĵ�ַ
mov wc.hIcon,0;δ����ͼ�꣨��ָ��ͼ�꣩
invoke LoadCursor,NULL,IDC_ARROW;װ��һ��ϵͳԤ������
mov wc.hCursor,eax
mov wc.hIconSm,0

invoke RegisterClassEx,addr wc;ע�ᴰ����
mov Wwd,1000;���ڿ��
mov Wht,400;���ڸ߶�
mov Wtx,10;�������Ͻ�x����
mov Wty,10;�������Ͻ�Y����
invoke CreateWindowEx,	;����������
		WS_EX_ACCEPTFILES +WS_EX_APPWINDOW,
		addr szClassName,
		addr szDisplayName,
		WS_OVERLAPPEDWINDOW + WS_VISIBLE,	;��������ʾ����
		Wtx,Wty,Wwd,Wht,
		NULL,NULL,hInst,NULL
mov hWnd,eax;���洰�ھ��
invoke LoadMenu,hInst,600;���˵�����Դ����Դ��ʶ��Ϊ600
invoke SetMenu,hWnd,eax;װ�䵽��������
invoke GetClientRect,hWnd,addr rectClient;������������û����Ĵ�С�����꣩
invoke CreateWindowEx,
	WS_EX_ACCEPTFILES or WS_EX_CLIENTEDGE,
	addr szEditClass,	;������ΪԤ����ġ�EDIT"����
	NULL,
	WS_CHILD+WS_VISIBLE+WS_HSCROLL+WS_VSCROLL \
	+ES_MULTILINE+ES_AUTOVSCROLL+ES_AUTOHSCROLL,
	rectClient.left,	;�༭�����������ڵ��û���
	rectClient.top,
	rectClient.right,
	rectClient.bottom,
	hWnd,	;�����ھ��
	0,hInst,0
mov hWndEdit,eax	;����༭���ڵľ��

StartLoop:					;������Ϣѭ��
	invoke GetMessage,addr msg,NULL,0,0;��ȡ��Ϣ
	cmp eax,0;��Ҫ�˳���
	je ExitLoop
	invoke TranslateMessage,addr msg;ת����Ϣ
	invoke DispatchMessage,addr msg;�ַ���������Ϣ�������
	jmp StartLoop
	
ExitLoop:
	mov eax,msg.wParam;���÷�����
	ret
WinMain endp

;--------------------������Ϣ�������------------------
WndProc proc hWin : dword,
	uMsg : dword,
	wParam :dword,
	IParam: dword
.if uMsg==WM_COMMAND;�ж��Ƿ�Ϊ�˵������������Ϣ
	.if wParam==1000	;Exit�����־��
		invoke SendMessage,hWnd,WM_CLOSE,0,0	;�˳�����
	.elseif wParam==1100	;Recommendation��ʶ��
		mov ebx,offset GOOD	;������Ʒ���Ƽ��ȣ���֪���ɲ�������jmpѭ��������ȫ��д����
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation;
	.elseif wParam==1200	;ListSort��ʶ��
		invoke DISPLAY;��ʾ��Ϣ
	.elseif wParam==1900	;about�����ʾ��ʾ��Ϣ
		invoke MessageBox,hWin,addr AboutMsg,addr szDisplayName,MB_OK;����Ϣ�������������������δ��
	.endif
.elseif uMsg==WM_DESTROY;�յ��˳�����ʱ�����Ƴ���Ϣ
	invoke PostQuitMessage,NULL
.else
	invoke DefWindowProc ,hWin,uMsg,wParam,IParam
	ret
.endif
	mov eax,0
	ret
WndProc endp

;----------------------�û��������----------------------
;�ӳ�������Count_Recommendation
;ʵ�ֹ��ܣ�������Ʒ���Ƽ��ȵ�ֵ
;��ڲ�����EBX�����Ʒ���׵�ַ��
;���ز�����
Count_Recommendation proc uses eax ebx ecx edx edi esi
	mov eax,[ebx+17];���������Ŀ
	cmp eax,[ebx+15];��ý�������
	jnl errcount;�������>=���������ؼ������
	and eax,0ffffh
	shl eax,6;�ȳ���64
	mov edx,0
	mov edi,[ebx+15]	
	and edi,0ffffh;ע������EDIӦ�ú�0FFFFH����
	div edi;�ٳ��Խ�������
	mov c1,eax;��->C1
	mov eax,[ebx+13];�õ����ۼ�
	and eax,0ffffh
	mul byte ptr [ebx+10];���ۼ۳����ۿ�
	mov edi,10
	mov edx,0;��Ҫ���ǽ���λ��0
	div edi;�ٳ���10�õ�ʵ�����ۼ�
	mov edi,eax;�õ��Ľ������EDI��
	mov eax,[ebx+11];�õ�����
	and eax,0ffffh
	mov edx,0
	shl eax,7;�����۳���128
	div edi;�õ���ʽ��ǰ�벿��(����/ʵ�����ۼ۸�
	add eax,c1
	mov word ptr [ebx+19],ax
errcount:
	ret;
Count_Recommendation endp
	
;�ӳ�����:DISPLAY
;���ܣ����ź������Ʒ˳�����
;��ڲ�����
;���ز�����
DISPLAY proc uses ecx eax edi
	local hdc: HDC	;����豸�����ĵľ��   
	y_add EQU 30
	y EQU 45
	invoke GetDC,hWnd	;���ݴ��ھ���趨�����ľ��
	mov hdc,EAX;�����豸�����ľ��
	
	invoke TextOut,hdc,10,15,offset outname,9	;������Ϊ��10��15����λ�ÿ�ʼ��ʾ�˵���
	invoke TextOut,hdc,110,15,offset outdiscount,8	;ˮƽ�����ϼ��100����ʾ�ۿ�
	invoke TextOut,hdc,210,15,offset outcost,4
	invoke TextOut,hdc,310,15,offset outsales,5
	invoke TextOut,hdc,410,15,offset outpuchase_num,12
	invoke TextOut,hdc,510,15,offset outsalesnum,8
	invoke TextOut,hdc,610,15,offset outrec,14
	
	invoke RANK
	mov ebx,0
lp1:
	cmp ebx,4
	ja end_dis
	
	imul ebx,thesize
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	lea edi,GOOD[ebx].inname
	invoke TextOut,hdc,10,ecx,edi,10
	
	mov al,GOOD[ebx].discount
	movzx eax,al
	invoke F2T10;
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	invoke TextOut,hdc,110,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].cost
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	invoke TextOut,hdc,210,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].sales
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	invoke TextOut,hdc,310,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].purchase_amount
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	invoke TextOut,hdc,410,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].sale_amount
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	invoke TextOut,hdc,510,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].reco
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx��ŵ��������ֵ
	invoke TextOut,hdc,610,ecx,offset outbuf,3
	
	inc count
	mov ebx,count
	jmp lp1
end_dis:
		ret
DISPLAY ENDP
	
	
	
;�ӳ�������F2T10
;�����ܣ����ڴ��е�����ʮ���Ƶķ�ʽ���
;��ڲ�����EAX--��ת��������EBX--ת�����ƵĻ�����SI--���ת�����P���Ƶ�ASCII�����һ���ֽڴ�
;���ز�����
F2T10 proc 
	pushad
	MOV EBX,10
	LEA ESI,OFFSET outbuf
	XOR ECX,ECX;����������,һ��Ҫ��ECX
LOP1:
	XOR EDX,EDX
	DIV EBX
	PUSH DX;����10��������ջ
	INC ECX
	OR EAX,EAX
	JNZ LOP1
LOP2:
	POP AX;����һλ10��������ת��ΪASCII������SI��
	CMP AL,10
	JB LOP3
	ADD AL,7
LOP3:	
	ADD AL,30H
	MOV [ESI],AL
	INC ESI;ָ��ָ����һ����Ԫ
	LOOP LOP2
	MOV BYTE PTR [ESI],' '
	INC ESI
	MOV BYTE PTR [ESI],' '
	popad
	RET
F2T10 ENDP

;�ӳ�������RANNK
;ʵ�ֹ��ܣ������Ƽ��ȴӸߵ��ͽ������򣬽��ߵķ��������
;��ڲ���
;���ز���
RANK PROC uses ecx eax edi esi ebx
	mov cl,0	;i
	
lp2:
	cmp cl,4
	jnb RANK_END	;���i>=len-1���������ѭ��
	mov dl,0	;j
	mov bh,4
	sub bh,cl
	mov bl,bh	;bl=4-i
lp6:
	
	cmp dl,bl
	jnb lp3		;���j>=len-1-i�ͽ����ڲ�ѭ��
	movzx edi,dl
	imul edi,thesize
	mov ax,GOOD[edi].reco
	mov esi,edi
	add esi,21
	cmp ax,GOOD[esi].reco
	jnb lp4		;���GOOD[j+1]>GOOD[j]�ͽ���������ֵ��j������һ������jֱ������һ
	invoke	Change
lp4:
	inc  dl
	jmp lp6
lp3:
	inc cl
	jmp lp2
	
RANK_END:
	ret
RANK ENDP

;�ӳ�������Change
;ʵ�ֵĹ��ܣ����ṹ��A������ȫ�����Ƹ��ṹ��B��
;��ڲ���:esi--A��ƫ�Ƶ�ַ,edi--B��ƫ�Ƶ�ַ
;���ز���
Change proc 
	pushad
	mov ecx,21
lp5:
	cmp ecx,0
	je Change_End
	mov al,byte ptr GOOD[esi]
	xchg al,byte ptr GOOD[edi]
	mov byte ptr GOOD[esi],al
	inc esi
	inc edi
	dec ecx
	jmp lp5
Change_End:
	popad
	ret
Change endp
end start
			
	
	
	
	
			


	
	
	
	
	   





