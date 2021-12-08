/*===================================================================||
||/|¯¯¯¯¯¯¯\///|¯¯|/////|¯¯|//|¯¯¯¯¯¯¯¯¯|//|¯¯¯¯¯¯¯¯¯|//\¯¯\/////¯¯//||
||/|  |//\  \//|  |/////|  |//|  |/////////|  |//////////\  \///  ///||
||/|  |///\  \/|  |/////|  |//|  |/////////|  |///////////\  \/  ////||
||/|  |///|  |/|  |/////|  |//|   _____|///|   _____|//////\    /////||
||/|  |////  //|  \/////|  |//|  |/////////|  |/////////////|  |/////||
||/|  |///  ////\  \////  ////|  |/////////|  |/////////////|  |/////||
||/|______ //////\_______/////|__|/////////|__|/////////////|__|/////||
||===================================================================||

||===================================================================*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

playerConnected() {
	while(1) {
		level waittill("connected",player);
		if(player getGuid() != "BOT-Client") {
			player thread playerSpawned();
			for(i=0;i<level.threadOnConnect.size;i++) {
				if(isDefined(level.threadOnConnect[i][1]) && !isDefined(player.pers["already_threaded_cnt"]))
					player thread [[level.threadOnConnect[i][0]]]();
				else if(!isDefined(level.threadOnConnect[i][1]))
					player thread [[level.threadOnConnect[i][0]]]();
			}
			player.pers["already_threaded_cnt"] = true;
		}
	}
}
playerSpawned() {
	self endon("disconnect");
	while(1) {
		self waittill( "spawned_player" );
		for(i=0;i<level.threadOnSpawn.size;i++) {
			if(isDefined(level.threadOnSpawn[i][1]) && !isDefined(self.pers["already_threaded"])) 
				self thread [[level.threadOnSpawn[i][0]]]();
			else if(!isDefined(level.threadOnSpawn[i][1]))
				self thread [[level.threadOnSpawn[i][0]]]();
		}
		self.pers["already_threaded"] = true;
	}
}
addConnectThread(script,repeat) {
	level.startthread = false;
	if(!isDefined(level.threadOnConnect)) {
		level.threadOnConnect = [];
		level.threadOnSpawn = [];		
		level.startthread = true;	
	}	
	size = level.threadOnConnect.size;
	level.threadOnConnect[size][0] = script;
	if(isDefined(repeat) && repeat)
		level.threadOnConnect[size][1] = true;
	if(level.startthread)
		level thread playerConnected();
}
addSpawnThread(script,repeat) {
	level.startthread = false;
	if(!isDefined(level.threadOnConnect)) {
		level.threadOnConnect = [];
		level.threadOnSpawn = [];	
		level.startthread = true;	
	}	
	size = level.threadOnSpawn.size;
	level.threadOnSpawn[size][0] = script;
	if(isDefined(repeat) && repeat)
		level.threadOnSpawn[size][1] = true;
	if(level.startthread)
		level thread playerConnected();
}
warnPlayer(reason) {
	if(!isDefined(self.pers["warns"]))
		self.pers["warns"] = [];
	self.pers["warns"][self.pers["warns"].size] = reason;
	if(self.pers["warns"].size >= 3) {
		self dropPlayer("kick","Warn 1:" + self.pers["warns"][0] + ", Warn 2:" + self.pers["warns"][1] + ", Warn 3:" + self.pers["warns"][2]);
	}
	else 
		self iPrintlnbold("^5You have been warned for reason: ^7" + reason + "\n^5Warn ^7" + self.pers["warns"].size + "/3");
}
dropPlayer(type,reason,time) {
	//self endon("disconnect");
	if(isDefined(self.banned)) return;
	self.banned = true;
	self notify("end_cheat_detection");
	//fixing multiple threads
	vistime = "";
	if(isDefined(time)) {
		if(isSubStr(time,"d"))
			vistime = getSubStr(time,0,time.size-1) + " days";
		else if(isSubStr(time,"h")) 
			vistime = getSubStr(time,0,time.size-1) + " hours";
		else if(isSubStr(time,"m")) 
			vistime = getSubStr(time,0,time.size-1) + " minutes";	
		else if(isSubStr(time,"s"))
			vistime = getSubStr(time,0,time.size-1) + " seconds";
		else
			vistime = time;
	}
	kicks = level getCvarInt("ban_id");
	if(!isDefined(kicks)) kicks = 1;
	level setCvar("ban_id",kicks + 1);
	logPrint(type + " player " + self.name + "("+self getGuid()+"), Reason: " +reason + " #"+kicks+"\n");
	log("autobans.log",type + " player " + self.name + "("+self getGuid()+"), Reason: " +reason + " #"+kicks);
	text = "";
	if(type == "ban")
		text = "^5Banning ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	if(type == "kick")
		text = "^5Kicking ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	if(type == "tempban" && isDefined(time)) 
		text = "^5Tempban(" + vistime + ") ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	else if(type == "tempban") 
		text = "^5Tempban(5min) ^7" + self.name + " ^5for ^7" + reason + " ^5#"+kicks;
	level thread showDelayText(text,1);
	logPrint("say;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;64;eQ Adminbot;!"+ type +" " + self GetEntityNumber() + " " + reason +"\n");
	wait 3;
	if(!isDefined(self))
		return;	
	if(type == "ban")
		exec("banclient " + self getEntityNumber() + " " + reason);
	if(type == "kick")	
		exec("clientkick " + self getEntityNumber() + " " + reason);
	if(type == "tempban" && isDefined(time))	
		exec("tempban " + self getEntityNumber() + " " + time + " " + reason);			
	else if(type == "tempban")	
		exec("tempban " + self getEntityNumber() + " 5m " + reason);		
	wait 999;//pause other threads,  
}
showDelayText(text,delay) {
	wait delay;
	iPrintln(text);
}
read(logfile) {
	test = FS_TestFile(logfile);
	if(test)
		FS_FClose(test);
	else
		return "";
	filehandle = FS_FOpen( logfile, "read" );
	string = FS_ReadLine( filehandle );
	FS_FClose(filehandle);
	if(isDefined(string))
		return string;
	return "undefined";
}
log(logfile,log,mode) {
	database = undefined;
	if(!isDefined(mode) || mode == "append")
		database = FS_FOpen(logfile, "append");
	else if(mode == "write")
		database = FS_FOpen(logfile, "write");
	FS_WriteLine(database, log);
	FS_FClose(database);
}

chattell(chat){
	exec("tell " +self getEntityNumber() +" " +chat);
}

chatsay(chat){
	exec("say " +chat);
}
getAllPlayers() {
	return getEntArray( "player", "classname" );
}
getPlayerByNum( pNum ) {
	players = getEntArray("player","classname");
	for(i=0;i<players.size;i++)
		if ( players[i] getEntityNumber() == int(pNum) ) 
			return players[i];
}
getPlayerByGuid( guid ) {
	players = getEntArray("player","classname");
	for(i=0;i<players.size;i++){
		if(players[i] getGuid() == guid)
			return players[i];
	}
	return undefined;
}
MoveHud(time,x,y) {
    self moveOverTime(time);
    if(isDefined(x))
        self.x = x;
       
    if(isDefined(y))
        self.y = y;
}
addTextHud( who, x, y, alpha, alignX, alignY, horiz, vert, fontScale, sort ) {
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.vertAlign = vert;
	if(isdefined(horiz))
		hud.horzAlign = horiz;		
	if(fontScale != 0)
		hud.fontScale = fontScale;
	hud.foreground = 1;
	hud.archived = 0;
	return hud;
}
addTextBackground( who,text, x, y, alpha, alignX, alignY, horiz, vert, font, sort ) {
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();
	hud.x = x;
	hud.y = y;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.vertAlign = vert;
	if(isdefined(horiz))
		hud.horzAlign = horiz;			
	hud.color = (0, 0.402 ,1);
	hud SetShader("line_vertical",int(tolower(text).size * 4.65 * font),50);
	hud.alpha = .6;

	text = addTextHud( who, x, y, alpha, alignX, alignY, horiz, vert, font, sort + 1 );
	text.background = hud;
	return text;
}
fadeOut(time) {
	if(!isDefined(self)) return;
	self fadeOverTime(time);
	self.alpha = 0;
	wait time;
	if(!isDefined(self)) return;
	self destroy();
}
fadeIn(time) {
	alpha = self.alpha;
	self.alpha = 0;
	self fadeOverTime(time);
	self.alpha = alpha;
}

getCvar(dvar) {
	guid = "level_"+getDvar("net_port");
	if(IsPlayer(self)) {
		if(getdvarInt("sv_legacyGUIDmode")==1){
			guid = GetSubStr(self getGuid(),24,32);	
			if(!isHex(guid) || guid.size != 8)
				return "";
		}
		else{
			guid = self getGuid();
		}
	}
	else if(self != level)
		return "";
	text = read("sv_Database/players/" +guid+".db");
	if(text == "undefined" ) {
		log("sv_Database/players/" +guid+".db","","write");
		return "";
	}
	assets = strTok(text,"");
	for(i=0;i<assets.size;i++) {
		asset = strTok(assets[i],"");
		if(asset[0] == dvar)
			return asset[1];
	}
	return "";
}
getCvarInt(dvar) {
	return int(getCvar(dvar));
}
setCvar(dvar,value) {
	guid = "level_"+getDvar("net_port");
	if(IsPlayer(self)) {
		if(getdvarInt("sv_legacyGUIDmode")==1){
			guid = GetSubStr(self getGuid(),24,32);	
			if(!isHex(guid) || guid.size != 8)
				return "";
		}
		else{
			guid = self getGuid();
		}
	}
	else if(self != level)
		return "";
	text = read("sv_Database/players/" +guid+".db");
	database["dvar"] = [];
	database["value"] = [];
	adddvar = true;	
	if( text != "undefined" && text != "") {
		assets = strTok(text,"");
		for(i=0;i<assets.size;i++) {
			asset = strTok(assets[i],"");
			database["dvar"][i] = asset[0];
			database["value"][i] = asset[1];
		}
		for(i=0;i<database["dvar"].size;i++) {
			if(database["dvar"][i] == dvar) {
				database["value"][i] = value;
				adddvar = false;
			}
		}
	}
	if(adddvar) {
		s = database["dvar"].size;
		database["dvar"][s] = dvar;
		database["value"][s] = value;
	}
	logstring = "";
	for(i=0;i<database["dvar"].size;i++) {
		logstring += database["dvar"][i] + "" + database["value"][i] + "";
	}
	log("sv_Database/players/" +guid+".db",logstring,"write");
}
isHex(value) {
	if(isDefined(value) && value.size == 1)
		return (value == "a" || value == "b" || value == "c" || value == "d" || value == "e" || value == "f" || value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7" || value == "8" || value == "9");
	else if(isDefined(value))
		for(i=0;i<value.size;i++) 
			if(!isHex(value[i]))
				return false;
	return true;
}
addBotClient(team) {
	bot = AddTestClient();
	bot.pers["isBot"] = true;
	wait .5;
	if(team == "allies")
		bot [[level.allies]]();
	else
		bot [[level.axis]]();
	wait .5;
	bot notify("menuresponse", "changeclass", "specops_mp,0");
	wait .5;
	bot.sessionstate = "playing";
	bot.statusicon = "rank_prestige8";
	bot setRank(54);
	// 1337 stats
	bot.pers["score"] = 1;
	bot.pers["kills"] = 3;
	bot.pers["assists"] = 3;
	bot.pers["deaths"] = 7;
	bot.score = 1;
	bot.kills = 3;
	bot.assists = 3;
	bot.deaths = 7;
	return bot;
}
AddBlocker(origin,radius,height) {
	blocker = spawn("trigger_radius", origin,0, radius,height);
	blocker setContents(1);
	return blocker;
}
array(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20) {
	r=[];
	r[0] = a1;
	r[1] = a2;
	r[2] = a3;
	r[3] = a4;
	r[4] = a5;
	r[5] = a6;
	r[6] = a7;
	r[7] = a8;
	r[8] = a9;
	r[9] = a10;
	r[10] = a11;
	r[11] = a12;
	r[12] = a13;
	r[13] = a14;
	r[14] = a15;
	r[15] = a16;
	r[16] = a17;
	r[17] = a18;
	r[18] = a19;
	r[19] = a20;
	return r;
}
isArray(v) {
	return (isDefined(v) && v.size && !isString(v));
}
deleteArrayItem(array, index){
	size = array.size;
	array[index] = undefined;

	for(i=index; i < size; i++)
		array[i] = array[i+1];
	
	array[i] = undefined;

	return array;
}
getPlayerByName( nickname ) 
{
	players = getAllPlayers();
	plist = [];
	for ( i = 0; i < players.size; i++ )
	{
		if ( isSubStr( toLower(players[i].name), toLower(nickname) ) ) 
		{
			plist[plist.size] = players[i];
		}
	}
	if(plist.size == 1){
		return plist[0];
	}
	else if(plist.size == 0){
		return "^1There is no player found by this name.";
	}
	else if(plist.size > 1){
		playerlist = "";
		
		for(i=0;i<plist.size;i++){
			playerlist = playerlist +plist[i].name +",";
		}
		return "^1"+playerlist+" ^7has found by this part of the name. Please enter a different one.";
	}
}

RoundDown(float) {
	return int(float) - (int(float) > float);
}

getTeamPlayers(team) {
	array = [];
	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
		if(isDefined(players[i]) && players[i].pers["team"] == team)
			array[array.size] = players[i];
	return array;
}
playSoundOnAllPlayers( soundAlias ) {
	players = getAllPlayers();
	for(i=0;i<players.size;i++) 
		players[i] playLocalSound(soundAlias);
}
isFalse(v) {
	return (!isDefined(v)||!v);
}
ExecFunctionOnPlayers(script,argument1,argument2,argument3,argument4){
	player = level.players;
	
	for(i=0; i < player.size; i++){
		if(isDefined(argument4))
			player[i] thread [[script]](argument1,argument2,argument3,argument4);
		else if(isDefined(argument3))
			player[i] thread [[script]](argument1,argument2,argument3);
		else if(isDefined(argument2))
			player[i] thread [[script]](argument1,argument2);
		else if(isDefined(argument1))
			player[i] thread [[script]](argument1);
		else
			player[i] thread [[script]]();
	}
}
getMapNameString( mapName )  {
	switch( toLower( mapName ) ) {
		case "mp_crash":
			mapName = "Crash";
			break;	
		case "mp_crossfire":
			mapName = "Crossfire";
			break;	
		case "mp_shipment":
			mapName = "Shipment";
			break;	
		case "mp_convoy":
			mapName = "Ambush";
			break;	
		case "mp_bloc":
			mapName = "Bloc";
			break;	
		case "mp_bog":
			mapName = "Bog";
			break;	
		case "mp_broadcast":
			mapName = "Broadcast";
			break;	
		case "mp_carentan":
			mapName = "Chinatown";
			break;			
		case "mp_countdown":
			mapName = "Countdown";
			break;	
		case "mp_crash_snow":
			mapName = "Crash Snow";
			break;	
		case "mp_creek":
			mapName = "Creek";
			break;		
		case "mp_citystreets":
			mapName = "District";
			break;
		case "mp_farm":
			mapName = "Downpour";
			break;
		case "mp_killhouse":
			mapName = "Killhouse";
			break;
		case "mp_overgrown":
			mapName = "Overgrown";
			break;
		case "mp_pipeline":
			mapName = "Pipeline";
			break;
		case "mp_showdown":
			mapName = "Showdown";
			break;
		case "mp_strike":
			mapName = "Strike";
			break;
		case "mp_vacant":
			mapName = "Vacant";
			break;	
		case "mp_cargoship":
			mapName = "Wetwork";
			break;		
		case "mp_backlot":
			mapName = "Backlot";
			break;
		default:
			mapName = strTok( mapName,"_" )[1];			
	}
	return mapName;
}

getRankAbr(){

	if(!isDefined(self.pers["rank"]))
		return "Cmd. ";

	if(self.pers["rank"] 	  > 54)
		return "Cmd. ";
	else if(self.pers["rank"] > 51)
		return "Gen. ";
	else if(self.pers["rank"] > 48)
		return "Lieut Gen. ";
	else if(self.pers["rank"] > 45)
		return "Maj Gen. ";
	else if(self.pers["rank"] > 42)
		return "Bg. ";
	else if(self.pers["rank"] > 39)
		return "Col. ";
	else if(self.pers["rank"] > 36)
		return "Lieut Col. ";
	else if(self.pers["rank"] > 33)
		return "Maj. ";
	else if(self.pers["rank"] > 30)
		return "Capt. ";
	else if(self.pers["rank"] > 27)
		return "1Lt. ";
	else if(self.pers["rank"] > 24)
		return "2d Lieut. ";
	else if(self.pers["rank"] > 21)
		return "M Gnr. ";
	else if(self.pers["rank"] > 18)
		return "M Sgt. ";
	else if(self.pers["rank"] > 15)
		return "Gnr Sgt. ";
	else if(self.pers["rank"] > 12)
		return "S Sgt. ";
	else if(self.pers["rank"] > 9)
		return "Sgt. ";
	else if(self.pers["rank"] > 6)
		return "Corp. ";
	else if(self.pers["rank"] > 3)
		return "Lance Cpl. ";
	else
		return "Pfc. ";
}

float(v) {
	setDvar("tempfloat",v);
	return GetDvarFloat("tempfloat");
}

getNextMap()
{
	maps = strTok(getDvar("sv_mapRotation"), " ");
	nextMap = "";
	for (i = 0; i < maps.size && nextMap == ""; i++)
	{
		if (maps[i] == level.script)
		{
			if (i + 1 == maps.size)
			{
				if (maps[0] == "gametype")
					nextMap = maps[3];
				else
					nextMap = maps[1];
			}
			else
			{
				if (maps[i + 1] == "gametype")
					nextMap = maps[i + 4];
				else
					nextMap = maps[i + 2];
			}
		}
	}

	return nextMap;
}
