.386
.model flat,stdcall
option casemap: none

INCLUDE D:\masm32\INCLUDE\WINDOWS.inc
INCLUDE D:\masm32\INCLUDE\GDI32.inc
INCLUDE D:\masm32\INCLUDE\USER32.inc
INCLUDE D:\masm32\INCLUDE\KERNEL32.inc
INCLUDE D:\masm32\INCLUDE\COMCTL32.inc

;库文件
INCLUDELIB GDI32.lib
INCLUDELIB USER32.lib
INCLUDELIB KERNEL32.lib
INCLUDELIB COMCTL32.lib

;函数原型声明
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
szDisplayName db "Our Fist Window",0			;窗口标题名
CommandLine dd 0								;命令行位置
hWnd dd 0										;窗口句柄
hInstance dd 0									;实例句柄
hWndEdit dd 0									;编辑窗口句柄
szFileError db "Read or Write File Error.",0	;出错信息
szError db "Error!",0							;出错对话框标题名
szEditClass db "EDIT",0							;编辑窗口类名
szClassName db "MainWndClass",0					;主窗口的类名
AboutMsg db "CS1806 I'm LiuMei!",0;					"About"菜单显示信息
												
TheText db "Save the Text?",0					;保存文件菜单提示信息
TheExit db "Please Confirm Exit.",0				;EXIT菜单提示信息
MAXSIZE = 2000									;文件的最大长度
Buf db MAXSIZE+1 DUP(0)							;读/写文件时的缓冲区

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
outbuf db 10 DUP(0);存放二进制转换后的十进制数
.code
;------------------------主程序---------------------------
start :
invoke GetModuleHandle,NULL;获得实例句柄
mov hInstance,eax
invoke InitCommonControls;初始化与编辑控制类有关的公用软件
invoke GetCommandLine;获得命令行地址
mov CommandLine,eax
invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT;进入窗口主程序函数
invoke ExitProcess,eax;退出并返回操作系统

;---------------------窗口主程序--------------------------
WinMain proc hInst: dword,
		hPrevInst:dword,
		CmdLine :dword,
		CmdShow:dword
;以下定义局部变量
local wc : WNDCLASSEX;创建窗口是所需要的信息有该结构说明
local msg: MSG;消息结构变量用于存放获取的信息
local Wwd :dword ;这四个变量存放带创建主窗口的位置和大小信息
local Wht :dword 
local Wtx :dword 
local Wty :dword 
local rectClient :RECT;矩形坐标结构变量用于存放主窗口用户区的坐标

;给WNDCALSSEX结构变量wc的各字段赋值
mov wc.cbSize ,sizeof WNDCLASSEX
mov wc.style ,CS_VREDRAW + CS_HREDRAW + CS_DBLCLKS \
		+CS_BYTEALIGNCLIENT+ CS_BYTEALIGNWINDOW;窗口的风格
mov wc.lpfnWndProc , offset WndProc;窗口过程的入口地址（偏移地址）
mov wc.cbClsExtra,NULL
mov wc.cbWndExtra,NULL
push hInst
pop wc.hInstance
mov wc.hbrBackground,COLOR_WINDOW +1 ;颜色
mov wc.lpszMenuName,NULL
mov wc.lpszClassName,offset szClassName;窗口类名字符串的地址
mov wc.hIcon,0;未载入图标（不指定图标）
invoke LoadCursor,NULL,IDC_ARROW;装入一种系统预定义光标
mov wc.hCursor,eax
mov wc.hIconSm,0

invoke RegisterClassEx,addr wc;注册窗口类
mov Wwd,1000;窗口宽度
mov Wht,400;窗口高度
mov Wtx,10;窗口左上角x坐标
mov Wty,10;窗口左上角Y坐标
invoke CreateWindowEx,	;创建主窗口
		WS_EX_ACCEPTFILES +WS_EX_APPWINDOW,
		addr szClassName,
		addr szDisplayName,
		WS_OVERLAPPEDWINDOW + WS_VISIBLE,	;创建可显示窗口
		Wtx,Wty,Wwd,Wht,
		NULL,NULL,hInst,NULL
mov hWnd,eax;保存窗口句柄
invoke LoadMenu,hInst,600;读菜单的资源，资源标识符为600
invoke SetMenu,hWnd,eax;装配到主窗口上
invoke GetClientRect,hWnd,addr rectClient;获得主窗口中用户区的大小（坐标）
invoke CreateWindowEx,
	WS_EX_ACCEPTFILES or WS_EX_CLIENTEDGE,
	addr szEditClass,	;创建的为预定义的“EDIT"窗口
	NULL,
	WS_CHILD+WS_VISIBLE+WS_HSCROLL+WS_VSCROLL \
	+ES_MULTILINE+ES_AUTOVSCROLL+ES_AUTOHSCROLL,
	rectClient.left,	;编辑窗口在主窗口的用户区
	rectClient.top,
	rectClient.right,
	rectClient.bottom,
	hWnd,	;父窗口句柄
	0,hInst,0
mov hWndEdit,eax	;保存编辑窗口的句柄

StartLoop:					;进入消息循环
	invoke GetMessage,addr msg,NULL,0,0;获取消息
	cmp eax,0;是要退出吗？
	je ExitLoop
	invoke TranslateMessage,addr msg;转换消息
	invoke DispatchMessage,addr msg;分发到窗口消息处理程序
	jmp StartLoop
	
ExitLoop:
	mov eax,msg.wParam;设置返回码
	ret
WinMain endp

;--------------------窗口消息处理程序------------------
WndProc proc hWin : dword,
	uMsg : dword,
	wParam :dword,
	IParam: dword
.if uMsg==WM_COMMAND;判断是否为菜单命令产生的消息
	.if wParam==1000	;Exit命令标志码
		invoke SendMessage,hWnd,WM_CLOSE,0,0	;退出窗口
	.elseif wParam==1100	;Recommendation标识码
		mov ebx,offset GOOD	;计算商品的推荐度，不知道可不可以用jmp循环所以先全部写出啦
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation
		add ebx,21
		invoke Count_Recommendation;
	.elseif wParam==1200	;ListSort标识码
		invoke DISPLAY;显示信息
	.elseif wParam==1900	;about命令，显示提示信息
		invoke MessageBox,hWin,addr AboutMsg,addr szDisplayName,MB_OK;该消息下若还存在其他命令，则未做
	.endif
.elseif uMsg==WM_DESTROY;收到退出命令时，发推出消息
	invoke PostQuitMessage,NULL
.else
	invoke DefWindowProc ,hWin,uMsg,wParam,IParam
	ret
.endif
	mov eax,0
	ret
WndProc endp

;----------------------用户处理程序----------------------
;子程序名：Count_Recommendation
;实现功能：计算商品的推荐度的值
;入口参数：EBX存放商品的首地址，
;返回参数：
Count_Recommendation proc uses eax ebx ecx edx edi esi
	mov eax,[ebx+17];获得已售数目
	cmp eax,[ebx+15];获得进货数量
	jnl errcount;如果已售>=进货，返回计算错误
	and eax,0ffffh
	shl eax,6;先乘以64
	mov edx,0
	mov edi,[ebx+15]	
	and edi,0ffffh;注意这里EDI应该和0FFFFH相与
	div edi;再除以进货数量
	mov c1,eax;商->C1
	mov eax,[ebx+13];得到销售价
	and eax,0ffffh
	mul byte ptr [ebx+10];销售价乘以折扣
	mov edi,10
	mov edx,0;不要忘记将高位置0
	div edi;再除以10得到实际销售价
	mov edi,eax;得到的结果放入EDI中
	mov eax,[ebx+11];得到进价
	and eax,0ffffh
	mov edx,0
	shl eax,7;进货价乘以128
	div edi;得到公式的前半部分(进价/实际销售价格）
	add eax,c1
	mov word ptr [ebx+19],ax
errcount:
	ret;
Count_Recommendation endp
	
;子程序名:DISPLAY
;功能：将排好序的商品顺序输出
;入口参数：
;返回参数：
DISPLAY proc uses ecx eax edi
	local hdc: HDC	;获得设备上下文的句柄   
	y_add EQU 30
	y EQU 45
	invoke GetDC,hWnd	;根据窗口句柄设定上下文句柄
	mov hdc,EAX;保存设备上下文句柄
	
	invoke TextOut,hdc,10,15,offset outname,9	;从坐标为（10，15）的位置开始显示菜单栏
	invoke TextOut,hdc,110,15,offset outdiscount,8	;水平方向上间隔100个显示折扣
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
	add ecx,y	;ecx存放的纵坐标的值
	lea edi,GOOD[ebx].inname
	invoke TextOut,hdc,10,ecx,edi,10
	
	mov al,GOOD[ebx].discount
	movzx eax,al
	invoke F2T10;
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx存放的纵坐标的值
	invoke TextOut,hdc,110,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].cost
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx存放的纵坐标的值
	invoke TextOut,hdc,210,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].sales
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx存放的纵坐标的值
	invoke TextOut,hdc,310,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].purchase_amount
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx存放的纵坐标的值
	invoke TextOut,hdc,410,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].sale_amount
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx存放的纵坐标的值
	invoke TextOut,hdc,510,ecx,offset outbuf,3
	
	mov ax,GOOD[ebx].reco
	movzx eax,ax
	invoke F2T10
	mov ecx,count
	imul ecx,y_add
	add ecx,y	;ecx存放的纵坐标的值
	invoke TextOut,hdc,610,ecx,offset outbuf,3
	
	inc count
	mov ebx,count
	jmp lp1
end_dis:
		ret
DISPLAY ENDP
	
	
	
;子程序名：F2T10
;程序功能：将内存中的数以十进制的方式输出
;入口参数：EAX--带转换的数，EBX--转换数制的基数，SI--存放转换后的P进制的ASCII码的下一个字节处
;返回参数：
F2T10 proc 
	pushad
	MOV EBX,10
	LEA ESI,OFFSET outbuf
	XOR ECX,ECX;计数器清零,一定要是ECX
LOP1:
	XOR EDX,EDX
	DIV EBX
	PUSH DX;除以10，余数进栈
	INC ECX
	OR EAX,EAX
	JNZ LOP1
LOP2:
	POP AX;弹出一位10进制数，转化为ASCII码送入SI中
	CMP AL,10
	JB LOP3
	ADD AL,7
LOP3:	
	ADD AL,30H
	MOV [ESI],AL
	INC ESI;指针指向下一个单元
	LOOP LOP2
	MOV BYTE PTR [ESI],' '
	INC ESI
	MOV BYTE PTR [ESI],' '
	popad
	RET
F2T10 ENDP

;子程序名：RANNK
;实现功能：按照推荐度从高到低进行排序，将高的放在最后面
;入口参数
;返回参数
RANK PROC uses ecx eax edi esi ebx
	mov cl,0	;i
	
lp2:
	cmp cl,4
	jnb RANK_END	;如果i>=len-1，结束外层循环
	mov dl,0	;j
	mov bh,4
	sub bh,cl
	mov bl,bh	;bl=4-i
lp6:
	
	cmp dl,bl
	jnb lp3		;如果j>=len-1-i就结束内层循环
	movzx edi,dl
	imul edi,thesize
	mov ax,GOOD[edi].reco
	mov esi,edi
	add esi,21
	cmp ax,GOOD[esi].reco
	jnb lp4		;如果GOOD[j+1]>GOOD[j]就交换两个的值，j在自增一，否则j直接自增一
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

;子程序名：Change
;实现的功能：将结构体A的数据全部复制给结构体B中
;入口参数:esi--A的偏移地址,edi--B的偏移地址
;返回参数
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
			
	
	
	
	
			


	
	
	
	
	   





