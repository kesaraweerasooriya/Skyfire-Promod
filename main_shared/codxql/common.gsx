//***************************
//Runs player related threads on connect and spawn. From Duffman's common.gsc. (Optimized)
//***************************
playerConnected() {
	while(1) {
		level waittill("connected",player);
		if(player getGuid() != "BOT-Client") {
			player thread playerSpawned();
			for(i=0;i<level.ConnectThread.size;i++) {
				if(isDefined(level.ConnectThread[i][1]) && !isDefined(player.pers["already_threaded_cnt_codxql"]))
					player thread [[level.ConnectThread[i][0]]]();
				else if(!isDefined(level.ConnectThread[i][1]))
					player thread [[level.ConnectThread[i][0]]]();
			}
			player.pers["already_threaded_cnt_codxql"] = true;
		}
	}
}
playerSpawned() {
	self endon("disconnect");
	while(1) {
		self waittill( "spawned_player" );
		for(i=0;i<level.PlayerSpawnThread.size;i++) {
			if(isDefined(level.PlayerSpawnThread[i][1]) && !isDefined(self.pers["already_threaded_codxql"])) 
				self thread [[level.PlayerSpawnThread[i][0]]]();
			else if(!isDefined(level.PlayerSpawnThread[i][1]))
				self thread [[level.PlayerSpawnThread[i][0]]]();
		}
		self.pers["already_threaded_codxql"] = true;
	}
}
addConnectThread(script,repeat) {
	startthread = false;
	if(!isDefined(level.ConnectThread)) {
		level.ConnectThread = [];
		level.PlayerSpawnThread = [];		
		startthread = true;	
	}	
	size = level.ConnectThread.size;
	level.ConnectThread[size][0] = script;
	if(isDefined(repeat) && repeat)
		level.ConnectThread[size][1] = true;
	if(startthread)
		level thread playerConnected();
}
addSpawnThread(script,repeat) {
	startthread = false;
	if(!isDefined(level.ConnectThread)) {
		level.ConnectThread = [];
		level.PlayerSpawnThread = [];	
		startthread = true;	
	}	
	size = level.PlayerSpawnThread.size;
	level.PlayerSpawnThread[size][0] = script;
	if(isDefined(repeat) && repeat)
		level.PlayerSpawnThread[size][1] = true;
	if(startthread)
		level thread playerConnected();
}

//***************************
//Thread server related functions for once, every map. Used for Search & Destroy gamemode.
//***************************
addThreadOnce(script){
	if(isDefined(game["already_threaded"]))
		return;

	started = false;
	if(!isDefined(level.OnGTS)){
		level.OnGTS = [];
		started = true;
	}

	size = level.OnGTS.size;
	level.OnGTS[size] = script;

	if(started)
		level thread threadOnce();
}
threadOnce(){
	if(!isDefined(game["already_threaded"])){
		game["already_threaded"] = true;

		while(1){
			if(level.OnGTS.size > 0){
				level thread [[level.OnGTS[0]]]();

				for(i=1; i<level.OnGTS.size; i++)
					level.OnGTS[i-1] = level.OnGTS[i];
				level.OnGTS[i-1] = undefined;
			}
			wait .05;
		}
	}
}

//***************************
//  Some common functions
//***************************
waitTillPlayerID(player){
	while(isDefined(player) && !isDefined(player.pers["cxID"]))
		wait .05;

	return;
}
getPlayerByID(id){
	players = getEntArray("player","classname");
	for(i=0;i<players.size;i++)
		if(players[i].pers["cxID"] == id)
			return players[i];
}
getPlayerByName( nickname ) 
{
	players = getEntArray("player","classname");
	plist = [];
	for ( i = 0; i < players.size; i++ ){
		if ( isSubStr( toLower(players[i].name), toLower(nickname) ) ) 
			plist[plist.size] = players[i];
	}
	
	if(plist.size == 1)
		return plist[0];
	else if(plist.size == 0)
		return;
	else if(plist.size > 1)
		return plist;
}
getPlayerByNum(pNum){
	players = getEntArray("player","classname");
	for(i=0;i<players.size;i++)
		if (players[i] getEntityNumber() == int(pNum)) 
			return players[i];
}
getPlayerVali(player){
	if(!isDefined(player)){
		self chattell("^1No player Found.");
		return false;
	}

	if(isPlayer(player)){
		return true;
	}
	else if(isArray(player)){
		if(player.size > 1){
			playerlist = "";
			sizeStr = "";

			if(player.size > 4){
				size = player.size - 4;
				sizeStr = " and "+size+" other players";
			}
			
			for(i=0;i<player.size && i<5;i++)
				playerlist = playerlist +player[i].name +", ";
			
			self chattell("^1"+playerlist+sizeStr+"^7have found by this part of the name. Please enter a different one.");
			return false;
		}
	}

	return false;
}
isValidID(id){
	if(!hasStrValue(id)){
		self chattell("^1Please enter the Cheater's CODXQL ID");
		return false;
	}

	if(!hasOnlyInt(id)){
		self chattell("^1Invalid CODXQL ID. Please check again. ^3(The ID can only include integers.)");
		return false;
	}

	definedID = codxql\player::getClientDataByID(id);
	if(!isDefined(definedID)){
		self chattell("^1No player has found by this CODXQL ID. Please check again.");
		return false;		
	}

	return true;
}

secToDate(s){
	d = [];
	sec = s % 60;
	min = (s % 3600) / 60;
	hrs = (s % 86400) / 3600;
	dys = (s % (86400 * 30)) / 86400;

	d["s"] = int(sec);
	d["m"] = int(min);
	d["h"] = int(hrs);
	d["d"] = int(dys);

	return d;
}
dateToSec(d, h, m, s){
	if(!isDefined(d))
		d = 0;
	if(!isDefined(h))
		h = 0;
	if(!isDefined(m))
		m = 0;
	if(!isDefined(s))
		s = 0;

	sec = (int(d) * 86400) + (int(h) * 3600) + (int(m) * 60) + int(s);

	return sec;
}
float(v){
	setDvar("temp",v);
	return GetDvarFloat("temp");
}

string(v){
	r = ""+v;
	return r;
}

//This function will convert string to int or float if the string have only integers.
strToIF(string){
	if(!isDefined(string) || string == "")
		return;

	string = ""+string;

	for(i=0; i<string.size; i++){
		if(!isSubStr("0123456789.", string[i]))
			return string;
	}

	if(isSubStr(string, "."))
		return float(string);
	else
		return int(string);

}
//This will strTok until NO(th) delimeter
strTokTill(str, delim, no){
	parts = [];
	strP = "";
	j = 0;

	for(i=0; i<str.size; i++){
		if(str[i] == delim && j < no){
			if(strP != ""){
				parts[parts.size] = strP;
				strP = "";
				j++;
			}
			continue;
		}
		strP += str[i];
	}
	parts[parts.size] = strP;
	return parts;
}
//Round a decimal Number.
round(floatNo, rounds){
	if(!isDefined(floatNo) || !isDefined(rounds))
		return;

	if(isInt(floatNo))
		return floatNo;

	floatNo = ""+floatNo;

	floatDecimal = strTok(floatNo, ".");
	decimalonly = floatDecimal[1];
	newDecimal = "";

	if(decimalonly.size < rounds){
		difference = rounds - decimalonly.size;

		for(i=0; i<difference; i++)
			decimalonly += "0";
	}
	else{
		difference = decimalonly.size - rounds;
		oldDecimal = decimalonly;

		for(i=0; i<difference; i++){
			num = oldDecimal[oldDecimal.size - 1];
			 if(int(num) > 4)
			 	n = int(oldDecimal[oldDecimal.size - 2]) + 1;
			 else
			 	n = int(oldDecimal[oldDecimal.size - 2]) - 1;

			 for(s=0; s<oldDecimal.size - 2; s++)
			 	newDecimal += oldDecimal[s];

			 newDecimal += n;
			 oldDecimal = newDecimal;
			 newDecimal = "";
		}
		decimalonly = oldDecimal;
	}
	roundedFloat = floatDecimal[0] +"." + decimalonly;
	return float(roundedFloat);
}
hasStrValue(v){
	if(isDefined(v) && v != "")
		return true;
	else
		return false;
}
isInt(v) {
	v = ""+v;

	for(i=0; i < v.size; i++){
		if(!isSubStr("0123456789", v[i]))
			return false;
		wait .05;
	}
	return true;
}
hasOnlyInt(v){
	if(isInt(v))
		return true;
	else
		return false;	
}
isArray(v) {
	return (isDefined(v) && v.size && !isString(v));
}
isANumber(v){
	v = ""+v;

	for(i=0; i < v.size; i++)
		if(!isSubStr("0123456789.", v[i]))
			return false;
	return true;	
}
hasMod(a, b){
	c = a % b;
	if(c == 0) 
		return false;
	else 
		return true;
}
isBot(player){
	if(!isDefined(player))
		return false;

	if(isDefined(player.pers) && isDefined(player.pers["isBot"]) && player.pers["isBot"])
		return true;
	else
		return false;
}
isBotGUID(player){
	if(!isDefined(player))
		return false;

	if(player getGuid() == "0")
		return true;	
	else
		return false;
}
isBetween(v , min, max){
	if(!isANumber(v))
		return false;

	if(v >= min && v <= max)
		return true;
	else
		return false;
}
checkIfPlayer(player){
	if(!isDefined(player))
		return;

	if(!isPlayer(player)){
		if(isDefined(player.owner)){
			if(isPlayer(player.owner))
				return player.owner;
		}
	}

	return player;
}
hasPower(cmd){
	power = self getPower();

	if(power >= level.cmdList[cmd])
		return true;
	else
		return false;
}
removeSpaces(string){
	if(!isDefined(string) || string == "")
		return "";

	oString = "";

	for(i=0; i<string.size; i++){
		if(string[i] != " ")
			oString += string[i];
	}
	return oString;
}

indent(string, spaces){
	if(!isDefined(string))
		string = "";
	
	size = spaces - string.size;
	newStr = "";

	if(size < 0){
		for(i=0; i<spaces; i++)
			newStr += string[i];

		return newStr;
	}
	else{
		if(hasMod(size, 2)){
			size = int(size / 2);
			frontS = size + 1;
		}
		else{
			size = size / 2;
			frontS = size;
		}

		for(i=0; i<frontS; i++)
			newStr += " ";

		newStr += string;

		for(i=0; i<size; i++)
			newStr += " ";

		return newStr;
	}
}

chattell(chat){
	if(self != level)
		exec("tell "+self getEntityNumber()+" "+chat);
	else{
		iprintln("^2RCON: ^7"+chat);
		print("^2RCON: ^7"+chat+"\n");
	}
}

chatsay(chat){
	exec("say " +chat);
}

chatsayT(chat, w){
	wait w;
	exec("say " +chat);
}

chatTellMStr(StrArray){
	for(i=0; i<StrArray.size; i++){
		exec("tell " +self getEntityNumber() +" " +StrArray[i]);
		wait 0.5;
	}
}

iPrintLnBoth(str){
	if(self != level){
		self iPrintLn(str);
	}
	else{
		print(str+"\n");
	}
}