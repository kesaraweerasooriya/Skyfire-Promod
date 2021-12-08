//███╗   ███╗ █████╗ ██╗      █████╗ ██╗   ██╗ █████╗  |
//████╗ ████║██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔══██╗ |
//██╔████╔██║███████║██║     ███████║ ╚████╔╝ ███████║ |
//██║╚██╔╝██║██╔══██║██║     ██╔══██║  ╚██╔╝  ██╔══██║ |
//██║ ╚═╝ ██║██║  ██║███████╗██║  ██║   ██║   ██║  ██║ |
//╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ |
//-----------------------------------------------------|
// Credits for some functions goes to Braxi and Duffy  |
//-----------------------------------------------------|

#include plugins\_common;

init()
{
	level thread advertisementschat();

	addConnectThread(::NameCheck);
	addConnectThread(::gscAdmins, true);
	addConnectThread(plugins\_welcome::WelcomeMessage,true);
	addConnectThread(::advertisements);
	addConnectThread(::setVariables);
}

setVariables(){
	if(!isDefined(self.pers["team_locked"])){
		self.pers["team_locked"] = false;
		self setClientDvar("cg_subtitles", 0);
	}
	self.pers["chatcount"] = 0;
}

//To check unauthorized names with {sF} part.
NameCheck() {
	self endon("disconnect");
	wait 5;
	name = toLower(self.name);
	
	if(issubstr(name,"admin")){
		self thread dropPlayer("tempban","^1You cannot name yourself as an ADMIN. Comeback after 15 minutes (AUTOBAN)^7","15m");
	}
	
	if(issubstr(name,"{sf}") || issubstr(name,"|sf|") || issubstr(name,"[sf]")){
		if(!self getCvarInt("weartag") && self getPower() < 70)
			self thread dropPlayer("kick","^1You cannot wear ^2{sF}^7 TAG without authorization (AutoKick).");	
	}	
}

//All the server messages in message bar goes by this function.
advertisements()
{
	self endon("disconnect");
	
	self setClientDvar("promod_hud_website", "Welcome "+self.name +" to sF:Alpha SnD");
	wait 20;
	for(;;){
		self setClientDvar("promod_hud_website", "Our FB Group: ^2SkyFire");
		wait 10;
		self setClientDvar("promod_hud_website", "Ban Appeal & Unban Requests At Our FB Group");
		wait 10;
		self setClientDvar("promod_hud_website", "Join our clan site ^5sfalpha.wowalliances.com");
	}
}

advertisementschat(){
	while(1){
		for(i=1;i<6;i++){
			if(getdvar("adscmd_"+i) != "" || getdvar("adscmd_"+i) != "NA"){
				wait 30;
				exec("say "+getdvar("adscmd_"+i));
			}
		}
		wait 1;
	}
}

gscAdmins(){
	if(self getPower() < 10)
		if(self getCvarInt("weartag"))
			self setPower(6);
}

//Player Commands Functions.

serverShutdownNotify(cmder,reason){
	if(!isDefined(reason) || reason == ""){
		if(cmder == "level")
			print("Reason Need");
		else
			self iprintln("^1Reason Need");

		return;
	}

	level.shutdownNoti = newHudElem();
	level.shutdownNoti.x = 0;
	level.shutdownNoti.y = -150;
	level.shutdownNoti.alignX = "Center";
	level.shutdownNoti.alignY = "Middle";
	level.shutdownNoti.horzAlign = "Center";
	level.shutdownNoti.vertAlign = "Middle";
	level.shutdownNoti.alpha = 1;
	level.shutdownNoti.sort = 1000;
	level.shutdownNoti.fontScale = 1.9;
	level.shutdownNoti.Color = (1,0.27,0.27);
	level.shutdownNoti.glowAlpha = 0.7;
	level.shutdownNoti.glowColor = (1,0,0);

	level.shutdownNoti setText("The Server will shutdown for " +reason +" after this match. Sorry for the inconvenience.");

	while(1){
		level waittill("game_ended");

		wait 5;

		level thread kickall(reason);
	}
}

kickall(reason){
	exec("kick all ^1The server has shutdown for " +reason +". Please check later. (Auto kick)");

	wait 2;
	exec("killserver");
}