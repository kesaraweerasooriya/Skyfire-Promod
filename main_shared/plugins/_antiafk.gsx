//███╗   ███╗ █████╗ ██╗      █████╗ ██╗   ██╗ █████╗  |
//████╗ ████║██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔══██╗ |
//██╔████╔██║███████║██║     ███████║ ╚████╔╝ ███████║ |
//██║╚██╔╝██║██╔══██║██║     ██╔══██║  ╚██╔╝  ██╔══██║ |
//██║ ╚═╝ ██║██║  ██║███████╗██║  ██║   ██║   ██║  ██║ |
//╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ |
//-----------------------------------------------------|

#include plugins\_common;

init() {
	level thread KickAFKPlayers();
	addSpawnThread(::AntiAFK);	
}

AntiAFK(){
    self endon("disconnect");
	self endon( "spawned_player" );
	self endon("joined_spectators");
	self endon("death");
    level endon("game_ended");
	level endon("mapvote");
	
	counts = 0;

	if(isDefined(self.pers["isBot"]) && self.pers["isBot"])
		return;
	
	while(isAlive(self) && self.sessionteam != "spectator"){
		OldAngle = self.angles;
		OldOrigin = self.origin;
		
		wait 1;
		
		if(OldAngle == self.angles && OldOrigin == self.origin)
			counts++;
		else{
			if(counts >= 15){
				self notify("guy_moved");
				self.afkNotify[0].alpha = 0;
				self.afkNotify[1].alpha = 0;
			}
			counts = 0;			
			continue;
		}
			
		if(counts == 15){
			self thread AFKWarning();
		}
	}
}

AFKWarning(){
	self endon("disconnect");
	self endon("guy_moved");
	self endon("joined_spectators");
	level endon("game_ended");
	level endon("mapvote");
	
	if(!isDefined(self.afkNotify)){
		self.afkNotify[0] = NewClientHudElem(self);
		self.afkNotify[0].y = -15;
		self.afkNotify[0].horzAlign = "center";
		self.afkNotify[0].vertAlign = "middle";
		self.afkNotify[0].alignX = "center";
		self.afkNotify[0].alignY = "middle";
		self.afkNotify[0].fontscale = 1.7;
		self.afkNotify[0].hidewheninmenu = true;
		self.afkNotify[0].Glowcolor = (1, 0, 0);
		self.afkNotify[0].GlowAlpha = 1;
		self.afkNotify[0] settext("Seems you are AFK. Please response");
		
		self.afkNotify[1] = NewClientHudElem(self);
		self.afkNotify[1].y = 10;
		self.afkNotify[1].horzAlign = "center";
		self.afkNotify[1].vertAlign = "middle";
		self.afkNotify[1].alignX = "center";
		self.afkNotify[1].alignY = "middle";
		self.afkNotify[1].fontscale = 1.7;
		self.afkNotify[1].hidewheninmenu = true;
		self.afkNotify[1].Glowcolor = (1, 0, 0);
		self.afkNotify[1].GlowAlpha = 1;
	}
	else{
		self.afkNotify[0].alpha = 1;
		self.afkNotify[1].alpha = 1;
	}
	
	self.afkNotify[1] settimer(10);
	wait 10;
	
	self.afkNotify[0].alpha = 0;
	self.afkNotify[1].alpha = 0;
	
	if(self.sessionteam == "spectator")
		return;
	
	self.sessionteam = "spectator";
	self.sessionstate = "spectator";
	self.pers["team"] = "spectator";
	self [[level.spawnSpectator]]();

	game["afkplayers"][game["afkplayers"].size] = self;
}

KickAFKPlayers(){
    level endon("game_ended");
	level endon("mapvote");
	
	while(1){
		wait 10;
		
		if(level.players.size < level.maxplayers)
			continue;
		
		if(!isDefined(game["afkplayers"]) || game["afkplayers"].size == 0)
			continue;
		
		players = game["afkplayers"];
	
		for(i=0; i < players.size; i++){
			player = players[i];
			
			if(!isDefined(player) || !isPlayer(player)){
				game["afkplayers"] = deleteArrayItem(game["afkplayers"], i);
				continue;			
			}
			
			if(player.sessionstate != "playing" && (player.pers["team"] != "axis" || player.pers["team"] != "allies")){
				player thread dropPlayer("kick","Seems you are ^1AFK. ^7You have kicked because the Server is FULL. (AutoKick).");
				game["afkplayers"] = deleteArrayItem(game["afkplayers"], i);
				break;
			}
		}
	}
}