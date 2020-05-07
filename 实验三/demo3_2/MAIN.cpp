#define _CRT_SECURE_NO_WARNINGS
#pragma comment(linker, "/INCLUDE:_mainCRTStartup")
#include<stdio.h>
#include<stdlib.h>
extern "C" {
	int MENU(void);
	int INPUTNAME(void);
	int FINDGOOD(void);
	int BUYGOOD(void);
	int COUNT(void);
	int CHANGEINFO(void);
	int CHANGEEN(void);
	int DISPLAY(void);
	int ARRAY(void);
	int EXIT(void);
}
int main(void)
{
	
	int op = 1;
	while (op) {
		//system("cls");
		printf("\nMENU\n");
		printf("1. LOG IN\n");
		printf("2. FIND GOOD\n");
		printf("3. BUY GOOD\n");
		printf("4. COUNT POPULATION\n");
		printf("5. ARRAY\n");
		printf("6. CHANGE INFORMATION\n");
		printf("7. CHANGE ENVIRONMENT\n");
		printf("8. DISPLAY ADDRESS\n");
		printf("9. EXIT\n");
		MENU();
		printf("please input your option £»");
		scanf("%d", &op);
		switch (op) {
		case 1:
			INPUTNAME();
			break;
		case 2:
			FINDGOOD();
			break;
		case 3:
			BUYGOOD();
			break;
		case 4:
			COUNT();
			break;
		case 5:
			ARRAY();
			break;
		case 6:
			CHANGEINFO();
			break;
		case 7:
			CHANGEEN();
			break;
		case 8:
			DISPLAY();
			break;
		case 9:
			EXIT();
			op = 0;
			break;
		default:
			printf("Input error!\n");
			break;
		}
	}
}