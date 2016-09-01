//Amarjot Parmar
//1255668

#include "rex.h"
int exit = 1;
int buttonStateCounter =1;

void HexprintLeftSSD(int x){
	RexParallel->LeftSSD = x;
}
void HexprintRightSSD(int x){
	RexParallel->RightSSD = x;
}

void BaseTenprintSSD(int x){
	int Tens = 0;
	int singleDigit =0;
	
	Tens = x % 100; 	 	//e.g 112 % 100 = 12
	singleDigit = Tens % 10; 	//e.g 12 == 2
	Tens = Tens - singleDigit;	//e.g 12 - 2  = 10
	Tens = Tens / 10; 		//e.g 10 / 10 = 1

	RexParallel->LeftSSD  = Tens;		//e.g 1				
	RexParallel->RightSSD = singleDigit;	//e.g 2 
						//Result 12
}	

void buttonState(){
		int button = 0; // button 0 is pressed by default (print base 16)
		button   = RexParallel->Buttons;
		if(button == 1){ buttonStateCounter = 1;}
		if(button == 2){ buttonStateCounter = 2;}
		if(button == 3){ buttonStateCounter = 3;}
	 }

void  parallel_main() {
	int switches = 0;

	while(exit == 1){
		//Read current value from parallel switch register
		switches = RexParallel->Switches;
		
		buttonState();

		if(buttonStateCounter == 1){
			HexprintRightSSD(switches);	
			switches >>= 4;			
			HexprintLeftSSD(switches);
		}
		if(buttonStateCounter == 2){
			BaseTenprintSSD(switches);
		}
		if(buttonStateCounter == 3){exit = 0; break;}			
	}
}
	
	
