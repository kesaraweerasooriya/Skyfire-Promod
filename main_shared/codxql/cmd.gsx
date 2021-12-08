#include codxql\mysql;
#include codxql\common;

//MAX chars per chat: 126

/*========================================
   Client commands for general system
========================================*/
registerXLR(player){
	if(!isDefined(player))
		return;

	clientData = codxql\player::getClientData(player);

	if(isDefined(clientData)){
		if(clientData["registered"] == "0"){
			query = "UPDATE `"+level.vars["clientsTable"]+"` SET registered = '1' WHERE id = '"+clientData["id"]+"'";
			Qexec(query);
			player setPower(level.vars["player_min_power"]);
			player chattell("^2The player has successfully registered to the server. ^3ID: "+clientData["id"]);
		}
		else{
			player chattell("^1The player has already registered to the server. ^3ID: "+clientData["id"]);
		}
	}
}

showXlrID(client){
	if(isDefined(client.pers["cxID"]))
		self chattell("^2Player ID: ^1"+client.pers["cxID"]);
	else
		self chattell("^1Sorry. There is an error with the systerm. Please contact an admin.");
}

getPlayerInfo(player){
	if(!isDefined(player))
		return;

	query = "SELECT * FROM `"+level.vars["clientsTable"]+"` WHERE id = '"+player.pers["cxID"]+"' LIMIT 1";
	row = getRow(query);

	if(isDefined(row)){
		self iPrintLnBoth("Player Info of ^3"+player.name);
		self iPrintLnBoth("Player ID: "+row["id"]);
		self iPrintLnBoth("Player GUID: "+row["guid"]);
		self iPrintLnBoth("Is Registered: "+row["registered"]);		
		self iPrintLnBoth("No of connections: "+row["connections"]);
		self iPrintLnBoth("Last seen time: "+row["guid"]);
	}
	else{
		self chattell("Error: Please contact an admin and check back later.");
	}
}

/*========================================
   Client commands for XLR Stats Plugin
========================================*/
getxlr(player){
	if(!isDefined(player))
		return;

	if(!self codxql\player::isRegistered())
		return;

	if(!self codxql\models\xlrstats::xlrstatus())
		return;

	playerStats = codxql\models\xlrstats::getPlayerStats(player);
	rank = codxql\models\xlrstats::getPlayerRank(player);
	strArray = []; 

	if(isDefined(playerStats)){
		strArray[0] = "^2XLR Stats ^1(BETA v3)";
		strArray[1] = "^2Name   : "+player.name+" (Rank #"+rank+")";
		strArray[2] = "^3Kills  : "+playerStats["kills"];
		strArray[3] = "^3Deaths : "+playerStats["deaths"];
		strArray[4] = "^3Ratio  : "+round(playerStats["ratio"], 2);
		strArray[5] = "^3Skill  : "+playerStats["skill"];	

		self chatTellMStr(strArray);
	}
	else
		self chattell("^1The player should play first in order to create stats.");
}

getTopList(count){
	if(!codxql\player::isRegistered(self))
		return;

	if(isDefined(count) && count != ""){
		if(!isANumber(count)){
			self chattell("^1Invalid count. ^3Usage: !toplist <int>");
			return;
		}

		count = int(count);

		if(!isBetween(count, 1, 10)){
			self chattell("^1The count should be between 1 and 10");
			return;
		}
	}
	else
		count = 3;

	list = codxql\models\xlrstats::getTopPlayers(count);

	if(isDefined(list)){
		self chattell("XLR Stats Top "+count+" Players:");
		for(i=1; i<=list.size; i++){
			wait .4;
			self chattell("^3#"+i+" ^7: ^3Name^7: "+indent(list[i-1]["name"], 15)+" ^3Skill^7: "+indent(list[i-1]["skill"],7)+" ^3Kills^7: "+indent(list[i-1]["kills"], 4)+" ^3Ratio^7: "+round(list[i-1]["ratio"], 2));
		}
	}
	else
		self chattell("^1No player has qualified for the Top players list. Please try again later.");
}

/*========================================
   Client commands for Aliases Plugin
========================================*/
getAliases(player){
	if(!isDefined(player))
		return;

	aliases = player codxql\models\aliases::getPlayerAliases();

	if(isDefined(aliases)){
		if(aliases.size == 1){
			self chattell("There is no other aliases except the current name of the player.");
			return;
		}
		self iPrintLnBoth("Aliases of ^3"+player.name);
		self iPrintLnBoth("|`````````````````````````|`````````````|");
		self iPrintLnBoth("|          Name           | Num_of_uses |");
		self iPrintLnBoth("|_________________________|_____________|");

		for(i=0; i<aliases.size && i<51; i++){
			self iPrintLnBoth("|"+indent(aliases[i]["alias"], 25)+"| "+indent(aliases[i]["num_uses"], 12)+"|");
		}
		self iPrintLnBoth("|_________________________|_____________|");

		self chattell("^2All aliases for "+player.name+" has printed.");
		self chattell("Press shift + console_button( ` ) to view all aliases.");
	}
}

lockIGN(player){
	query = "SELECT * FROM `"+level.vars["aliasesTable"]+"` WHERE alias = '"+player.name+"' LIMIT 1";
	row = getRow(query);

	if(isDefined(row)){
		if(row["client_id"] == player.pers["cxID"]){
			if(row["locked"] == "0"){
				codxql\models\aliases::toggelLock(row["id"], 1);
				self chattell("^2Locked the IGN: "+player.name);
			}
			else{
				codxql\models\aliases::toggelLock(row["id"], 0);
				self chattell("^2Unlocked the IGN: "+player.name);
			}
		}
		else{
			if(row["locked"] == "0"){
				codxql\models\aliases::updateAliasOwner(row["id"], player.pers["cxID"]);
				codxql\models\aliases::toggelLock(row["id"], 1);
				self chattell("^2Lokced the IGN: "+player.name);
			}
			else
				self chattell("^1Failed to lock the IGN \""+player.name+"\". Reason: Someone has already locked it.");
		}
	}
	else
		self chattell("^1There is an error in aliases system. Please contact an admin.");
}

/*========================================
    Client commands for Bans Plugin
========================================*/

//It is better to add two different commands for both types. Reason for two types is to prevent codxql ID mixed with slot ID.
//This applies to tempBan too.
//Ex: If an admin bans a client in slot 10, maybe he wont get banned. Instead the client with codxql ID 10 will get banned.
    
// Command | function structure to execute
// $cBan   - cmdBan("client", cleint, cheater, reason) To BAN a client by his slot or name.
// $cIDBan - cmdBan("id", cleint, cheater, reason) To BAN a client by his codxql ID.

cmdBan(type, client, cheater, reason){
	if(!isDefined(client))
		client = level;

	if(!hasStrValue(reason)){
		client chattell("^1Please enter a reason for the BAN");
		return;
	}

	if(isDefined(type) && type == "id"){
		if(!client isValidID(cheater))
			return;
		
		clientData = codxql\player::getClientDataByID(cheater);
		//Not really need to check clientdata existence cause we verified the ID in isValidID func. In case of something happend with the db its better to keep this.
		if(!isDefined(clientData))
			return;

		cheaterID = clientData["id"];
		cheaterName = clientData["name"];
	}
	else if(isDefined(type) && type == "client"){
		if(!hasStrValue(cheater)){
			client chattell("^1Please enter the Cheater's name or his slot ID");
			return;
		}

		if(hasOnlyInt(cheater))
			cPlayer = getPlayerByNum(cheater);
		else
			cPlayer = getPlayerByName(cheater);
		
		if(!client getPlayerVali(cPlayer))
			return;

		cheaterID = cPlayer.pers["cxID"];
		cheaterName = cPlayer.name;
	}
	else{
		client chattell("Error: Incorrect or Undefined type");
		return;	
	}

	if(client == level)
		clientID = level.vars["server_id"];
	else
		clientID = client.pers["cxID"];

	codxql\models\bans::notifyBan(client, "permenent", cheaterName, reason);
	codxql\models\bans::banClient(cheaterID, clientID, reason);
}

cmdTempBan(type, client, cheater, duration, reason){
	if(!isDefined(client))
		client = level;

	if(!hasStrValue(duration)){
		client chattell("^1Please enter the duration for the BAN");
		return;
	}

	if(!hasStrValue(reason)){
		client chattell("^1Please enter a reason for the BAN");
		return;
	}

	if(isDefined(type) && type == "id"){
		if(!client isValidID(cheater))
			return;
		
		clientData = codxql\player::getClientDataByID(cheater);
		if(!isDefined(clientData)){
			client chattell("^1Invalid CODXQL ID. Try again.");
			return;
		}
		cheaterID = clientData["id"];
		cheaterName = clientData["name"];
	}
	else if(isDefined(type) && type == "client"){
		if(!hasStrValue(cheater)){
			client chattell("^1Please enter the Cheater's name or his match ID");
			return;
		}

		if(hasOnlyInt(cheater))
			cPlayer = getPlayerByNum(cheater);
		else
			cPlayer = getPlayerByName(cheater);
		
		if(!client getPlayerVali(cPlayer))
			return;

		cheaterID = cPlayer.pers["cxID"];
		cheaterName = cPlayer.name;
	}
	else{
		client chattell("Error: Incorrect or Undefined type");
		return;	
	}

	if(client == level)
		clientID = level.vars["server_id"];
	else
		clientID = client.pers["cxID"];

	durationSec = (level.vars["ban_max_days"] * 86400)+1;
	durationStr = "";

	if(!hasOnlyInt(duration)){
		durationInt = getSubStr(duration, 0, duration.size-1);
		if(!hasOnlyInt(durationInt)){
			client chattell("^1Please enter a valid duration.");
			return;
		}

		if(isSubStr(duration,"d")){
			durationSec = dateToSec(durationInt);
			durationStr = durationInt+" Day(s)";
		}
		else if(isSubStr(duration,"h")){
			durationSec = dateToSec(undefined, durationInt);
			durationStr = durationInt+" Hour(s)";
		}
		else if(isSubStr(duration,"m")){
			durationSec = dateToSec(undefined, undefined, durationInt);
			durationStr = durationInt+" Minute(s)";
		}
		else if(isSubStr(duration,"s")){
			durationSec = dateToSec(undefined, undefined, undefined, durationInt);
			durationStr = durationInt+" Second(s)";
		}
	}
	else{
		durationSec = int(duration);
		durationStr = durationSec+" Second(s)";
	}

	if(durationSec > level.vars["ban_max_days"] * 86400){
		client chattell("^1Error: Maximum duration is "+level.vars["ban_max_days"]+" Day(s).");
		return;
	}

	codxql\models\bans::notifyBan(client, "temporary", cheaterName, reason, durationStr);
	codxql\models\bans::TempBanClient(cheaterID, clientID, durationSec, reason);
}

getBansList(){
	bans = codxql\models\bans::banList();

	if(isDefined(bans)){
		self iPrintLnBoth("Ban List");
		self iPrintLnBoth("|`````````|`Cheater`|`````````|````````````````|`````````|`````````````````````````|`````````````````````````|");
		self iPrintLnBoth("|  Ban ID |    ID   | Admin ID|      Name      |   Type  |         Reason          |      Ban Expire On      |");
		self iPrintLnBoth("|_________|_________|_________|________________|_________|_________________________|_________________________|");

		for(i=0; i<bans.size && i<51; i++){
			time = int(bans[i]["time_expire"]);
			str_expTime = TimeToString(time, 0, "%d")+"-"+TimeToString(time, 0, "%b")+"-"+TimeToString(time, 0, "%Y")+" "+TimeToString(time, 0, "%I")+":"+TimeToString(time, 0, "%M")+TimeToString(time, 0, "%p")+" (IST)";
			self iPrintLnBoth("|"+indent(bans[i]["id"], 9)+"|"+indent(bans[i]["client_id"], 9)+"|"+indent(bans[i]["admin_id"], 9)+"|"+indent(bans[i]["name"], 16)+"|"+indent(bans[i]["type"], 9)+"|"+indent(bans[i]["reason"], 25)+"|"+indent(str_expTime, 25)+"|");
		}
		self iPrintLnBoth("|_________|_________|_________|________________|_________|_________________________|_________________________|");

		self chattell("^2All current Bans printed.");
		self chattell("Press shift + console_button( ` ) to view them.");
	}
	else if(!isDefined(bans))
		self chattell("There is not active BANS yet.");
}

cmdUnban(BID){
	if(!hasStrValue(BID))
		return;

	if(hasOnlyInt(BID)){
		self chattell("The BID should only contain integers.");
		return;
	}

	banDet = codxql\models\bans::getBanDetails(BID);

	if(isDefined(banDet)){
		if(banDet["status"] == "0"){
			self chattell("This Ban ID is already unbanned");
			return;
		}
		codxql\models\bans::unbanClient(BID);
		self chattell("The Ban ID "+BID+" has successfully unbanned.");
	}
	else
		self chattell("Error: Incorrect BAN ID. Please check.");
}

getBanHistory(player){
	if(!self isValidID(player))
		return;
	
	banDet = codxql\models\bans::getBanHistory(player);
	if(isDefined(banDet)){
		self iPrintLnBoth("Ban history of ");
		self iPrintLnBoth("|`````````|`````````|````````````````|````````|`````````````````````````|`````````````````````````|");
		self iPrintLnBoth("|   BID   |   PID   |      Name      |  Type  |         Reason          |      Ban Expire On      |");
		self iPrintLnBoth("|_________|_________|________________|________|_________________________|_________________________|");

		for(i=0; i<banDet.size && i<51; i++){
			time = int(banDet[i]["time_expire"]);
			str_expTime = TimeToString(time, 0, "%d")+"-"+TimeToString(time, 0, "%b")+"-"+TimeToString(time, 0, "%Y")+" "+TimeToString(time, 0, "%I")+":"+TimeToString(time, 0, "%M")+TimeToString(time, 0, "%p")+" (IST)";
			self iPrintLnBoth("|"+indent(banDet[i]["id"], 9)+"| "+indent(banDet[i]["client_id"], 8)+"| "+indent(banDet[i]["name"], 15)+"| "+indent(banDet[i]["type"], 7)+"| "+indent(banDet[i]["reason"], 24)+"| "+indent(str_expTime, 24)+"|");
		}
		self iPrintLnBoth("|_________|_________|________________|________|_________________________|_________________________|");		
	}
	else if(!isDefined(banDet)){
		self chattell("^2A clean player. No BAN history for now.");
		return;
	}


}