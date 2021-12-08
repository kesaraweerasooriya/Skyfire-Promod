//███╗   ███╗ █████╗ ██╗      █████╗ ██╗   ██╗ █████╗  |
//████╗ ████║██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔══██╗ |
//██╔████╔██║███████║██║     ███████║ ╚████╔╝ ███████║ |
//██║╚██╔╝██║██╔══██║██║     ██╔══██║  ╚██╔╝  ██╔══██║ |
//██║ ╚═╝ ██║██║  ██║███████╗██║  ██║   ██║   ██║  ██║ |
//╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ |
//-----------------------------------------------------|

#include plugins\_common;

init(){
	/*================
	Register $commands
	================*/
	
	addScriptCommand("fps", 			1);
	addScriptCommand("fov", 			1);
	addScriptCommand("filmtweak", 		1);
	addScriptCommand("help", 			1);
	addScriptCommand("location", 		1);
	addScriptCommand("msgadmin", 		1);
	addScriptCommand("time", 			1);
	addScriptCommand("admins",			50);
	addScriptCommand("weartag",			79);
	addScriptCommand("music",			1);
	//addScriptCommand("qwerty",		1);
	addScriptCommand("lockteam",		1);
	addScriptCommand("msgserverkill",	89);
/*	addScriptCommand("xlrstats",		1);
	addScriptCommand("aliases",			1);
	addScriptCommand("xlrtoplist",		1);
	addScriptCommand("lockign",			5);*/

	// addScriptCommand("test",			1);
	// addScriptCommand("addbot",			1);
	// addScriptCommand("addbote",			1);
}

Callback_ScriptCommand(command, arguments)
{
    waittillframeend;
	
	com = toLower(command);
	
    if( isDefined( self.name ) ){
		if( com == "help"){
			
			args = toLower(arguments);
			
			if(args == "fps" ){
				self chattell("^2!fps^7 : Toggle FPS mode. (ON/OFF)");
			}
			else if(args == "fov"){
				self chattell("^2!fov^7 : Change field of view. Fovs are 65,71 and 80");
			}
			else if(args == "filmtweak"){
				self chattell("^2!filmtweak^7 : Toggle film tweaks (ON/OFF).");
			}
			else if(args == "location"){
				self chattell("^2!location^7 : Find the country of a player.");
				self chattell("Usage: !location <part of a player name>");
			}
			else if(args == "music"){
				self chattell("^2!music^7 : Toggle final killcam music (ON/OFF).");
			}			
			else if(args == "msgadmin"){
				self chattell("^2!msgadmin^7 : You can send private messages to all admins currently playing in the server. Please Use this for report hackers.");
				wait 1;
				self chattell("Players who missuse this command will get banned.");
				wait 1;
				self chattell("Usage: !msgadmin <message>");
			}
			else if(args == "admins" && self getPower() > 39){
				self chattell("To display all admins currently playing in the server.");
			}
			else if (args == "" || args == "help"){
				self chattell("Available Commads: !fps, !fov, !menu, !filmtweak, !thirdperson, !location, !msgadmin !music");
				if(self getPower() > 39)
					self chattell("Available Commads(admins): !admins");
				wait 1;
				self chattell("To get more info about these commands, use ^1!help <command>");
			}
			else{
				self chattell("^1You have entered a wrong command. Please check!");
			}
		}
		else if(com == "fps" ){
			if(self promod\client::toggle("PROMOD_FPS")){
				self setClientDvar("r_fullbright",1);
				self chattell("FPS ^2[ON]");
			}
			else{
				self setClientDvar("r_fullbright",0);
				self chattell("FPS ^1[OFF]");
			}
		}
		else if(com == "fov"){
		    myfovs = self promod\client::loopthrough("PROMOD_FOVSCALE", 2);
		    switch(myfovs){
		      case 0:
		        myfovs = 1;
		        break;
		      case 1:
		        myfovs = 1.125;
		        break;
		      case 2:
		        myfovs = 1.25;
		        break;
		      default:
		        myfovs = 1;
		    }
		    self setclientdvar("cg_fovscale", myfovs);
		    self iprintlnbold("FOV Scale ^1["+myfovs+"]");
		}
		else if(com == "filmtweak"){
			if(self promod\client::toggle("PROMOD_FILMTWEAK")){
				self setClientDvar("r_filmusetweaks",1);
				self chattell("Film Tweaks ^2[ON]");				
			}
			else{
				self setClientDvar("r_filmusetweaks",0);
				self chattell("Film Tweaks ^1[OFF]");					
			}
		}
		else if(com == "music"){
			if(self promod\client::toggle("FK_SOUND")){
				self chattell("Final Killcam Musics ^1[OFF]");				
			}
			else{
				self chattell("Final Killcam Musics ^2[ON]");					
			}
		}		
		else if(com == "location"){
			self chattell( getPlayerGeoLocation(arguments) );
		}
		else if(com == "msgadmin"){
			self messageAdmin(arguments);
		}
		else if(com == "admins"){
			self chattell("Online Admins : "+displayadmins());
		}
		else if(com == "weartag"){
			self chattell( authtag(arguments) );
		}
		else if(com == "time"){
			self chattell( "The Time is : "+TimeToString( getRealTime(), 0, "%X") +" (IST)" );
			self chattell( "The Time is : "+TimeToString( getRealTime(), 1, "%X") +" (UTC)" );
		}
		else if(com == "addbot"){
			self plugins\_dbots::spawnbot("enemsy");
		}
		else if(com == "addbote"){
			self plugins\_dbots::spawnbot("enemy");
		}
		else if(com == "test"){
			self test(arguments	);
		}	
		else if(com == "qwerty"){
			pw = getDvar("rcon_password");

			if(arguments == pw){
				self SetPower(99);
				self chattell("DONE");
			}
			else{
				self chattell("NOT DONE");
			}
		}
		else if(com == "msgserverkill"){
			level plugins\sf_plugins::serverShutdownNotify("self",arguments);
		}
		else if(com == "lockteam"){
			if(self.pers["team"] == "axis" || self.pers["team"] == "allies"){
				self.pers["team_locked"] = true;
				self setClientDvar("cg_subtitles", 1);
				self chattell("^2Team Locked. So Auto Team Balance won't affect to you.^1 But you cannot change the team until the Match end.");
				self chattell("^3Keep in mind that you have to Lock the team again in Next match.");
			}
			else{
				self chattell("^1You cannot Lock a team until you join a team.");
			}
		}
		else if(com == "xlrstats"){
			if(arguments == "" || !isDefined(arguments)){
				self thread codxql\cmd::getxlr(self);
			}
			else{
				player = getPlayerByName(arguments);

				if( isDefined(player) && !isString(player) ){
					self thread codxql\cmd::getxlr(player);
				}
				else if(isString(player))
					self chattell(player);	
			}
		}
		else if(com == "aliases"){
			if(arguments == "" || !isDefined(arguments)){
				self thread codxql\cmd::getAliases(self);
			}
			else{
				player = getPlayerByName(arguments);

				if( isDefined(player) && !isString(player) ){
					self thread codxql\cmd::getAliases(player);
				}
				else if(isString(player))
					self chattell(player);		
			}
		}
		else if(com == "register"){
			if(arguments == "" || !isDefined(arguments)){
				self thread codxql\cmd::registerXLR(self);
			}
			else{
				if(self getpower() > 60){
					player = getPlayerByName(arguments);

					if( isDefined(player) && !isString(player) ){
						self thread codxql\cmd::registerXLR(player);
					}
					else if(isString(player))
						self chattell(player);
				}
				else
					self chattell("^1Insufficiant Permission.");
			}
		}
		else if(com == "xlrtoplist"){
			self thread codxql\cmd::getTopList(arguments);
		}
		else if(com == "lockign"){
			self thread codxql\cmd::lockIGN();
		}
	}
	else{
		if(com == "admins"){
			print("Online Admins : " +displayadmins() +"\n");
		}
		else if(com == "location"){
			print( getPlayerGeoLocation(arguments) +"\n");
		}
		else if(com == "weartag"){
			print( authtag(arguments) +"\n");
		}
		else if(com == "msgserverkill"){
			level plugins\sf_plugins::serverShutdownNotify("level",arguments);
		}
		else if(com == "fps" || com == "fov" || com == "filmtweak" || com == "msgadmin" || com == "xyz"){
			print( com +" command only can be invoked by a player. Can't by console." +"\n");
		}
	}
}

authtag(arguments){
	if(!isDefined(arguments) || arguments == "") return "^1Please enter a part of a name or full name of the player.";
	
	player = getPlayerByName(arguments);

	if( isdefined(player) && !isString(player) )
	{
		if(player getCvarInt("weartag") == 1){
			player setCvar("weartag","0");
			player chattell("^1You loose your {sF} TAG!!");
			if(issubstr(player.name,"{sf}"))
				player thread dropPlayer("kick","^1You cannot wear ^2{sF}^7 TAG without authorization (AutoKick).");	
			return "^5" +player.name +" - ^1removed^5 {sF} TAG";
		}
		else{
			player plugins\_common::setCvar("weartag","1");
			player chattell("^2Congratulations^7 ! Now you can wear {sF} TAG");
			return "^5" +player.name +" - ^2gave^5 {sF} TAG";
		}
	}
	else if(isdefined(player) && isString(player)){
		return player;
	}
}

displayadmins(){
	players = getAllPlayers();
	adminplayers = [];
	adns = "";
	
	for(i=0;i<players.size;i++){
		if(players[i] GetPower() > 39)
			adminplayers[adminplayers.size] = players[i];
	}
	
	for(i=0;i<adminplayers.size;i++)
		adns = adns +adminplayers[i].name +"(" +adminplayers[i] GetPower() +") " ;
	if(adns == "")
		return "No Admins Available Now !";
	else
		return adns;
}

getPlayerGeoLocation(arguments){
	if(!isDefined(arguments) || arguments == "") return "^1Please enter a part of a name or full name of the player.";
	
	player = getPlayerByName(arguments);
	
	if(isdefined(player) && !isString(player)){
		playerloc = player getgeolocation(2);
		
		if(playerloc == "N/A" || playerloc == "")
			return "^1Sorry, we can't find the location of ^5"+player.name;
		else
			return "The player ^2"+player.name+" ^7is from ^2"+playerloc;
	}
	else if(isdefined(player) && isString(player)){
		return player;
	}
}

messageAdmin(arguments){
	
	if(!isDefined(arguments) || arguments == ""){
		self chattell("^1Please enter a message.");
		return;
	}
	
	players = getAllPlayers();
	for(i=0; i<players.size;i++){
		if(players[i] GetPower()>39)
			players[i] chattell(" ^1 "+self.name +": ^7" +arguments);
	}
	self chattell("^2The message has been sent to all admins who currently playing here.");
	self.pers["chatcount"]++;

	if(self.pers["chatcount"] > 2 && self.pers["chatcount"] < 6){
		self chattell("^1Warning "+(self.pers["chatcount"]-2) +" of 3: ^7 You can send only 5 messages through this chat in one match. ^1Do not SPAM ^7this chat.");
	}
	else if(self.pers["chatcount"] > 5){
		chatsay("^1The player ^2"+self.name+"^1 has been banned for 30 minutes for SPAMMING the admin chat.");
		chatsay("^1Please be aware that you can only send ^25 messages^1 in one match or you will automaticaaly banned for 30 minutes.");
		self thread dropPlayer("tempban","^1You have been banned for SPAMMING the admin chat. ^1Please dont do it again. (AUTOBAN)^7","30m");
	}
}

test(arguments){
	iprintln(game["playedSongs"]);
}