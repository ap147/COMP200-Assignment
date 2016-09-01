//Amarjot Parmar
//1255668	

#include "rex.h"
int counter = 0;
int quit = 0;
char userInput = 2;

void printChar(int c) {
	while(!(RexSp2->Stat & 2));
	RexSp2->Tx = c;
}

// ------------------------------ Total Intrupts
void print2Serial2(int c) {
int bit = 0;

	printChar('\r');
	printChar(0x30);	

	bit = c / 100000;
	bit = bit % 10;
	printChar(0x30+bit);	

	bit = c / 10000;
	bit = bit % 10;
	printChar(0x30+bit);

	bit = c / 1000;
	bit = bit % 10;
	printChar(0x30+bit);
	
	bit = c / 100;
	bit = bit % 10;
	printChar(0x30+bit);

	bit = c / 10;
	bit = bit % 10;
	printChar(0x30+bit);
	

	bit = c % 10;
	printChar(0x30+bit);
}
//--------------------------------- Minutes & Secounds
void printCounterMS(int c){
	int bit = 0;int mins = 0;int secounds =0; 

	c = c / 100; 

	secounds = c % 60;		//Getting Secounds
	mins     = c - secounds; 	//Getting Mins
	mins 	 = mins / 60; 

        printChar('\r');
	printChar(0x30);
	printChar(0x30);

//---------MINUTES
	bit = mins / 10;
	bit = bit % 10;
	printChar(0x30+bit);
	
	bit = mins % 10;
	printChar(0x30+bit);
//------------- :

	printChar(':');

//-----------SECOUNDS
	bit = secounds / 10;
	bit = bit % 10;
	printChar(0x30+bit);
	

	bit = secounds % 10;
	printChar(0x30+bit);
}
//--------------------------------- Secounds 
void printCounterSS(int c){
	int bit = 0;
	int PointSecounds = c % 100;	//Intrupts = 1022 --> 22 Mil Secounds
	int Secounds = c / 100; 	//Intrupts = 1022 --> 10 Secounds
	Secounds = Secounds % 10000;

	printChar('\r');

	bit = Secounds / 1000;
	bit = bit % 10;
	printChar(0x30+bit);

	bit = Secounds / 100;
	bit = bit % 10;
	printChar(0x30+bit);

	bit = Secounds / 10;
	bit = bit % 10;
	printChar(0x30+bit);
	
	
	bit = Secounds % 10;
	printChar(0x30+bit);


	printChar('.');

	bit = PointSecounds / 10;
	bit = bit % 10;
	printChar(0x30+bit);

	bit = PointSecounds % 10;
	printChar(0x30+bit);
}



void serial_main() {
	int clockType = 2;
	while(quit == 0) {

		if((RexSp2->Stat & 1)){ 
			userInput = RexSp2->Rx;
		}

		if(userInput == 'q'){quit = 1;}
		else if(userInput == '1'){ clockType = 1;} //MM:SS 
		else if(userInput == '2'){ clockType = 2;} //SSSS.SS
		else if(userInput == '3'){ clockType = 3;} //TTTTTT

		if     (clockType == 3){print2Serial2(counter);}
		else if(clockType == 1){printCounterMS(counter);} 
		else if(clockType == 2){printCounterSS(counter);} 
	}
}
