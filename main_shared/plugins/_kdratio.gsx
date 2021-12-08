//███╗   ███╗ █████╗ ██╗      █████╗ ██╗   ██╗ █████╗  |
//████╗ ████║██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔══██╗ |
//██╔████╔██║███████║██║     ███████║ ╚████╔╝ ███████║ |
//██║╚██╔╝██║██╔══██║██║     ██╔══██║  ╚██╔╝  ██╔══██║ |
//██║ ╚═╝ ██║██║  ██║███████╗██║  ██║   ██║   ██║  ██║ |
//╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ |
//-----------------------------------------------------|
// Credits for most functions goes to Braxi and Duffy  |
//-----------------------------------------------------|

#include plugins\_common;


init() {	
	addConnectThread(::ShowKDRatio);
	wait .05;
	
	for(;;wait 1) {
		if( game["state"] == "playing" && !level.fk) continue;
		
		players = getAllPlayers();
		for(i=0;i<players.size;i++) {
			if(isDefined(players[i])) {
				if(isDefined(players[i].mc_kdratio))
					players[i].mc_kdratio thread FadeOut(1);
				if(isDefined(players[i].hp))
					players[i].hp thread FadeOut(1);
				if(isDefined(players[i].mc_kills))
					players[i].mc_kills thread FadeOut(1);	
				if(isDefined(players[i].mc_deaths))
					players[i].mc_deaths thread FadeOut(1);	
			}
		}				
	}
}

ShowKDRatio()
{
	self notify( "new_KDRRatio" );
	self endon( "new_KDRRatio" );
	self endon( "disconnect" );
	
	if( IsDefined( self.mc_kdratio ) )	self.mc_kdratio Destroy();
	if( IsDefined( self.mc_kills ) )	self.mc_kills Destroy();
	if( IsDefined( self.mc_deaths ) )	self.mc_deaths Destroy();
	if( isDefined(self.hp) )			self.hp Destroy();
	
	self.mc_kdratio = NewClientHudElem(self);
	self.mc_kdratio.x = 115;
	self.mc_kdratio.y = -465;
	self.mc_kdratio.horzAlign = "left";
	self.mc_kdratio.vertAlign = "bottom";
	self.mc_kdratio.alignX = "left";
	self.mc_kdratio.alignY = "middle";
	self.mc_kdratio.alpha = 0;
	self.mc_kdratio.fontScale = 1.4;
	self.mc_kdratio.hidewheninmenu = true;
	self.mc_kdratio.label = &"K/D Ratio: &&1";
	self.mc_kdratio FadeOverTime(.5);
	self.mc_kdratio.alpha = 0.8;
	self.mc_kdratio.color = ( 0.93, 0.90, 0.18 );
	
	self.mc_kills = NewClientHudElem(self);
	self.mc_kills.x = 115;
	self.mc_kills.y = -441;
	self.mc_kills.horzAlign = "left";
	self.mc_kills.vertAlign = "bottom";
	self.mc_kills.alignX = "left";
	self.mc_kills.alignY = "middle";
	self.mc_kills.alpha = 0;
	self.mc_kills.fontScale = 1.4;
	self.mc_kills.hidewheninmenu = true;
	self.mc_kills.label = &"Kills: &&1";
	self.mc_kills FadeOverTime(.5);
	self.mc_kills.alpha =0.8;
	self.mc_kills.color = ( 1.00, 0.30, 0.30 );
	
	self.mc_deaths = NewClientHudElem(self);
	self.mc_deaths.x = 115;
	self.mc_deaths.y = -429;
	self.mc_deaths.horzAlign = "left";
	self.mc_deaths.vertAlign = "bottom";
	self.mc_deaths.alignX = "left";
	self.mc_deaths.alignY = "middle";
	self.mc_deaths.fontScale = 1.4;
	self.mc_deaths.hidewheninmenu = true;
	self.mc_deaths.label = &"Deaths: &&1";
	self.mc_deaths FadeOverTime(.5);
	self.mc_deaths.alpha = 0.8;
	self.mc_deaths.color = ( 1.00, 0.30, 0.30 );
	
	self.hp = NewClientHudElem(self);
	self.hp.x = 115;
	self.hp.y = -405;
	self.hp.horzAlign = "left";
	self.hp.vertAlign = "bottom";
	self.hp.alignX = "left";
	self.hp.alignY = "middle";
	self.hp.fontscale = 1.4;
	self.hp.hidewheninmenu = true;
	self.hp.label = &"^2Health:^7 &&1";	
	self.hp.alpha = 0;
	self.hp fadeOverTime(.5);
	self.hp.alpha = 0.8;
	
	self thread numerical_health();
	
	first = true;
	for(;;) {
		if(first)
			first = 0;
		else 
			wait .5;
		
		if(!isDefined(self) || !isDefined(self.pers) || !isDefined(self.pers[ "kills" ]) || !isDefined(self.pers[ "deaths" ]) || !isDefined(self.mc_kdratio))
			return;
		
		if( IsDefined( self.pers[ "kills" ] ) && IsDefined( self.pers[ "deaths" ] ) ) {
			if( self.pers[ "deaths" ] < 1 ) 
				ratio = self.pers[ "kills" ];
			else 
				ratio = int( self.pers[ "kills" ] / self.pers[ "deaths" ] * 100 ) / 100;
			self.mc_kdratio setValue(ratio);
		}
		
		if(isdefined( self.pers["kills"]))
			self.mc_kills setValue(self.pers["kills"]);
		else self.mc_kills setValue(0);

		if(isdefined( self.pers["deaths"]))
			self.mc_deaths setValue(self.pers["deaths"]);
		else
			self.mc_deaths setValue(0);	
		
		self common_scripts\utility::waittill_any("disconnect","death","weapon_fired","weapon_change","player_killed");
	}
}

numerical_health()
{
	self endon( "disconnect" );
	
	for(;;wait .3)
	{
		if(!isdefined( self.hp )) continue;
		
		if(self.health > 0){
			hpc = self.health / self.maxhealth;
			self.hp setValue(self.health);
			self.hp.color = ((1-hpc), hpc, 0);
		}	
		else{
			self.hp setText( "^1KIA" );
		}
	}
}

showhud(){
	if(isDefined(self.hp)) 			self.hp.alpha = 1;
	if(isDefined(self.mc_kdratio)) 	self.mc_kdratio.alpha = 1;
	if(isDefined(self.mc_kills)) 	self.mc_kills.alpha = 1;
	if(isDefined(self.mc_deaths)) 	self.mc_deaths.alpha = 1;
}

hidehud(){
	if(isDefined(self.hp)) 			self.hp.alpha = 0;
	if(isDefined(self.mc_kdratio)) 	self.mc_kdratio.alpha = 0;
	if(isDefined(self.mc_kills)) 	self.mc_kills.alpha = 0;
	if(isDefined(self.mc_deaths)) 	self.mc_deaths.alpha = 0;
}
