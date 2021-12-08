spawnbot(team){
	origin = self getOrigin();
	angles = self getPlayerAngles();	
	
	newBot = addTestClient();
	wait 0.05;
	if (isdefined(newBot)) {
		wait 0.5;
		if (distanceSquared(self.origin, origin) < 4096) {
			self iprintln("Move away to spawn dummy!");
			while (distanceSquared(self.origin, origin) < 4096) 
				wait 0.05;
		}
		if(team == "enemy")
			newBot notify("menuresponse", game["menu_team"], getOtherTeam(self.pers["team"]));
		else
			newBot notify("menuresponse", game["menu_team"], self.pers["team"]);
		
		while (newBot.pers["team"] != "axis" && newBot.pers["team"] != "allies") 
			wait 0.05;
		newBot notify("menuresponse", game["menu_changeclass_" + newBot.pers["team"]], "assault");
		
		while (!isDefined(newBot.pers["class"])) 
			wait 0.05;
		newBot notify("menuresponse", game["menu_changeclass"], "go");
		
		while (!isAlive(newBot)) 
			wait 0.05;

		newBot setOrigin(origin);
		newBot SetPlayerAngles(angles);
		wait 0.5;
		newBot thread BoiDoActions();
		newBot.maxhealth = 100;
	}
}
getOtherTeam( team )
{
	if ( team == "allies" )
		return "axis";
	else if ( team == "axis" )
		return "allies";
}

BoiDoActions(){
	while(1){
		self botAction("+fire");
		wait 2;
		self botAction("-fire");
		self botAction("+reload");
		wait 3;
	}
}