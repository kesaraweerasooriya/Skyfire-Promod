#include codxql\mysql;
#include codxql\common;

init(){
	level thread setServerID();
	level thread OnEndGame();

	addConnectThread(::OnDisconnect);
	addConnectThread(::recordPlayer, true);
}

//Initialize Table
initStorage(){
	query =  "CREATE TABLE IF NOT EXISTS `"+level.vars[ "clientsTable" ]+"` (";
	query += 	"`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,";
	query += 	"`connections` INT(11) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`guid` VARCHAR(36) NOT NULL DEFAULT '',";
	query += 	"`name` VARCHAR(32) NOT NULL DEFAULT '',";
	query += 	"`registered` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`time_add` INT(11) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`time_last_seen` INT(11) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"PRIMARY KEY (`id`),";
	query += 	"UNIQUE KEY `guid` (`guid`)";
	query += ") ENGINE=MyISAM DEFAULT CHARSET=utf8";

	a[0] = level.vars["clientsTable"];
	a[1] = query;

	return a;
}

//This will set an ID for the server. If the server is not in Players Database this will create one.
setServerID(){
	if(getDvar("server_id") != ""){
		level.vars["server_id"] = getDvar("server_id");
		return;
	}

	query = "SELECT * FROM `"+level.vars["clientsTable"]+"` WHERE guid = 'SERVER' LIMIT 1";
	row = getRow(query);

	if(!isDefined(row)){
		query =  "INSERT INTO `"+level.vars["clientsTable"]+"` (connections, guid, name, time_add) ";
		query += "VALUES ('1', 'SERVER' ,'SERVER', '"+getRealTime()+"')";

		Qexec(query);

		query = "SELECT * FROM `"+level.vars["clientsTable"]+"` WHERE guid = 'SERVER' LIMIT 1";
		row = getRow(query);
	}

	setDvar("server_id", row["id"]);
	level.vars["server_id"] = row["id"];
}

//This will record every player who connects to the server.
recordPlayer(){
	//No bots will be recorded in the server.
	if(isBot(self))
		return;

	row = getClientData(self);

	//If row isnt defined, that means the player isn't recorded to the server. So we should record him.
	if(!isDefined(row)){
		query =  "INSERT INTO '"+level.vars["clientsTable"]+"' (guid, time_add) ";
		query += "VALUES ('"+self getGuid()+"', '"+getRealTime()+"')";
		Qexec(query);

		connections = 1;

		row = getClientData(self);
	}
	else{
		//We can't connection++ in every map roatation. So we will give 2 minutes for player to load the next map.
		//This is to capture players who disconnect while map roatating. 
		//Suggest me a better way.
		if(getRealTime() - int(row["time_last_seen"]) > 60*2){
			connections = int(row["connections"]);
			connections++;
		}
		else
			connections = row["connections"];
	}

	if(self getPower() > level.vars["player_min_power"])
		registered = 1;	//Admins will auto register.
	else
		registered = int(row["registered"]);

	query = "UPDATE `"+level.vars["clientsTable"]+"` SET connections= '"+connections+"', name= '"+self.name+"', registered= '"+registered+"' WHERE id= '"+row["id"]+"'";
	Qexec(query);

	if(registered && self getPower() < level.vars["player_min_power"])
		self setPower(level.vars["player_min_power"]);
	
	self.pers["cxID"] = row["id"];
}

//Check if the player has register to the server.
isRegistered(){
	if(!level.vars["need_register"])
		return true;

	clientData = getClientData(self);

	if(isDefined(clientData)){
		if(clientData["registered"] == "0"){
			self chattell("^2You need to Register first. Use ^1!Register ^2Command");
			return false;
		}
		else
			return true;
	}
	else{
		self chattell("There is something wrong with the system. Please contact admin.");
		return false;
	}
}

//Get player data as an array.
getClientData(player){
	query = "SELECT * FROM `"+level.vars["clientsTable"]+"` WHERE guid = '"+player getGuid()+"' LIMIT 1";
	row = getRow(query);

	return row;	
}
getClientDataByID(playerID){
	query = "SELECT * FROM `"+level.vars["clientsTable"]+"` WHERE id = '"+playerID+"' LIMIT 1";
	row = getRow(query);

	return row;	
}

//Record last seen time on Player Disconnect.
OnDisconnect(){
	if(isBot(self))
		return;

	waitTillPlayerID(self);
	
	id = self.pers["cxID"];
	self waittill("disconnect");

	if(isDefined(id)){
		query = "UPDATE `"+level.vars["clientsTable"]+"` SET time_last_seen='"+getRealTime()+"' WHERE id='"+id+"'";
		Qexec(query);
	}
}

//Record the last seen time in every match end.
OnEndGame(){
	while(1){
		level waittill("game_ended");

		if(!maps\mp\gametypes\_globallogic::hitRoundLimit() && !maps\mp\gametypes\_globallogic::hitScoreLimit() && level.gametype == "sd")
			break;

		for (i = 0; i < level.players.size; i++) {
			player = level.players[i];
			if(isBot(player))
				continue;

			if(isDefined(player.pers["cxID"])){
				query = "UPDATE `"+level.vars["clientsTable"]+"` SET time_last_seen='"+getRealTime()+"' WHERE id='"+player.pers["cxID"]+"'";
				Qexec(query);
			}
		}
	}
}