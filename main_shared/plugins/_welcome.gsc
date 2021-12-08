//███╗   ███╗ █████╗ ██╗      █████╗ ██╗   ██╗ █████╗  |
//████╗ ████║██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔══██╗ |
//██╔████╔██║███████║██║     ███████║ ╚████╔╝ ███████║ |
//██║╚██╔╝██║██╔══██║██║     ██╔══██║  ╚██╔╝  ██╔══██║ |
//██║ ╚═╝ ██║██║  ██║███████╗██║  ██║   ██║   ██║  ██║ |
//╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ |
//-----------------------------------------------------|

// Format:
//*********************
// 'Quote'
// Name: <rank>. Name
// Location: Map Name
// Time: HH:MM:SS
//*********************


#include plugins\_common;

WelcomeMessage(){
	self endon("disconnect");

	self waittill("spawned_player");
	welcomeText = "'Welcome'\n'" +getRankAbr() +self.name +"'\n" +getMapNameString(getDvar("mapname"));

	while(isDefined(self.doingNotify) && self.doingNotify)
		wait 0.1;

	self.welcome[0] = addTextHud(self, 5, 20, 0, "left", "top", "left", "middle", 1.7, 900);
	self.welcome[0].glowColor = (0.3, 0.8, 0.3);
	self.welcome[0].glowAlpha = 1;
	self.welcome[0].font = "objective";
	self.welcome[0] setText(welcomeText);

	self.welcome[1] = addTextHud(self, 5, 80, 0, "left", "top", "left", "middle", 1.7, 900);
	self.welcome[1].glowColor = (0.3, 0.8, 0.3);
	self.welcome[1].glowAlpha = 1;
	self.welcome[1].font = "objective";
	self thread WelcomeClock();

	self.welcome[0] setPulseFX( 90, int(5000 + (welcomeText.size * 90)), 1500 );
	self.welcome[0].alpha = 1;

	wait welcomeText.size * 0.09;

	self.welcome[1] setPulseFX( 70, 5000, 1500 );
	self.welcome[1].alpha = 1;
	
	wait 7;

	self notify("Welcome_over");
	self.welcome[0] Destroy();
	self.welcome[1] Destroy();
}

WelcomeClock(){
	self endon("Welcome_over");
	self endon("disconnect");

	while(1){
		CurrentTime = TimeToString( getRealTime(), 0, "%X"); //Why does this return undefined sometimes?
		if(isDefined(CurrentTime)){
			self.welcome[1] setText(CurrentTime);
			wait 1;
		}
		else
			wait 0.05;	//Prevent Infinite loop without wait.
	}
}

//For time Formats (%X) - https://www.tutorialspoint.com/c_standard_library/c_function_strftime.htm