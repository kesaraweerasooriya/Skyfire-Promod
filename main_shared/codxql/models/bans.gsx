#include codxql\mysql;
#include codxql\common;

init(){
	addConnectThread(::OnPlayerConnect, true);
}

initStorage(){
	query =  "CREATE TABLE IF NOT EXISTS `"+level.vars[ "bansTable" ]+"` (";
	query += 	"`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,";
	query += 	"`client_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`admin_id` INT(11) NOT NULL DEFAULT '0',";
	query += 	"`type` ENUM('Permenent','Temporary') NOT NULL DEFAULT 'Permenent',";
	query += 	"`status` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1',";
	query += 	"`reason` VARCHAR(255) NOT NULL DEFAULT '',";
	query += 	"`time_add` INT(11) NOT NULL DEFAULT '0',";
	query += 	"`time_expire` INT(11) NOT NULL DEFAULT '0',";
	query += 	"`time_unban` INT(11) NOT NULL DEFAULT '0',";
	query += 	"PRIMARY KEY (`id`),";
	query += 	"KEY `client_id` (`client_id`),";
	query += 	"KEY `admin_id` (`admin_id`),";
	query += 	"KEY `type` (`type`),";
	query += 	"KEY `status` (`status`)";
	query += ") ENGINE=MyISAM DEFAULT CHARSET=utf8";

	a[0] = level.vars["bansTable"];
	a[1] = query;

	return a;
}


OnPlayerConnect(){
	if(isBot(self))
		return;

	waitTillPlayerID(self);

	banDet = getLastActiveBan(self.pers["cxID"]);

	if(isDefined(banDet)){
		timeNow = getRealTime();
		if(banDet["time_expire"] != "0" && timeNow > int(banDet["time_expire"])){
			unbanClient(banDet["id"]);
			//Two Factor punishment LOL.
			chatsayT("^2Welcome Back "+self.name+", after getting ^1 Temporary BANNED ^2for "+banDet["reason"], 10);
		}
		else{
			addReasonText = "";
			if(banDet["time_expire"] != "0"){
				time_expire = int(banDet["time_expire"]);
				expireTime = TimeToString(time_expire, 0, "%d")+"-"+TimeToString(time_expire, 0, "%b")+"-"+TimeToString(time_expire, 0, "%Y")+" "+TimeToString(time_expire, 0, "%I")+":"+TimeToString(time_expire, 0, "%M")+TimeToString(time_expire, 0, "%p")+" (IST)";
				addReasonText = "Ban Expire: "+expireTime+"\n";
			}
			reasonText =  "^1"+banDet["type"]+" BAN^7 (BID: "+banDet["id"]+")\n-\n";
			reasonText += addReasonText;
			reasonText += "Reason: "+banDet["reason"]+"\n";
			reasonText += "^3Use BID for UNBAN appeals.";

			wait 0.1;
			kickClient(self, reasonText);
		}
	}
}

//We should pass client ID instead of client because sometimes we need to ban offline clients.
//Ex: If some cheater has the hack which auto disconnect when he is beign getss ed, he needs to be ban too.
banClient(adminID, cheaterID, reason){
	time_add = getRealTime();

	query =  "INSERT INTO `"+level.vars["bansTable"]+"`(client_id, admin_id, type, reason, time_add)";
	query += "VALUES('"+cheaterID+"', '"+adminID+"', '1', '"+reason+"', '"+time_add+"')";
	qexec(query);

	player = getPlayerByID(cheaterID);
	if(isDefined(player)){
		banID = getLastBanID(cheaterID);

		//You need to minimize the character count because the kick function allows max 128 chars for the message.
		reasonText =  "^1Permenent BAN^7 (BID: "+banID+")\n-\n";
		reasonText += "Reason: "+reason+"\n";
		reasonText += "^3Use BID for UNBAN appeals.";

		kickClient(player, reasonText);
	}
}

//Duration should be in seconds
tempBanClient(cheaterID, adminID, duration, reason){
	time_add = getRealTime();
	time_expire = time_add + int(duration);

	query =  "INSERT INTO `"+level.vars["bansTable"]+"`(client_id, admin_id, type, reason, time_add, time_expire)";
	query += "VALUES('"+cheaterID+"', '"+adminID+"', '2', '"+reason+"', '"+time_add+"', '"+time_expire+"')";
	qexec(query);

	player = getPlayerByID(cheaterID);
	if(isDefined(player)){
		banID = getLastBanID(cheaterID);
		expireTime = TimeToString(time_expire, 0, "%d")+"-"+TimeToString(time_expire, 0, "%b")+"-"+TimeToString(time_expire, 0, "%Y")+" "+TimeToString(time_expire, 0, "%I")+":"+TimeToString(time_expire, 0, "%M")+TimeToString(time_expire, 0, "%p")+" (IST)";

		//You need to minimize the character count because the kick function allows max 128 chars for the message.
		reasonText =  "^1Temporary BAN^7 (BID: "+banID+")\n-\n";
		reasonText += "Ban Expire: "+expireTime+"\n";
		reasonText += "Reason: "+reason+"\n";
		reasonText += "^3Use BID for UNBAN Appeals.";

		kickClient(player, reasonText);
	}
}

unbanClient(BID){
		query =  "UPDATE `"+level.vars["bansTable"]+"` ";
		query += "SET status = '0', time_unban = '"+getRealTime()+"' ";
		query += "WHERE id = '"+BID+"'";
		qexec(query);
}

banList(type){
	ct = level.vars["clientsTable"];
	bt = level.vars["bansTable"];

	if(!isDefined(type) || type == "all")
		addQuery = "";
	else if(type == "ban")
		addQuery = "&& "+bt+".type = '1' ";
	else if(type == "tempban")
		addQuery = "&& "+bt+".type = '2' ";
	else
		addQuery = "";
	
	query =  "SELECT "+bt+".*, "+ct+".name";
	query += "FROM `"+bt+"` ";
	query += "INNER JOIN `"+ct+"` ";
	query += "ON "+ct+".id = "+bt+".client_id ";
	query += "WHERE "+bt+".status = '1' ";
	query += addQuery;
	query += "ORDER BY "+bt+".id ASC";
	banDet = getRows(query);

	return banDet;
}

getBanDetails(BID){
	if(!isDefined(BID))
		return;

	query = "SELECT * FROM `"+level.vars["bansTable"]+"` WHERE id = '"+BID+"' LIMIT 1";
	banDet = getRow(query);

	return banDet;
}

kickClient(cheater, reason){
	kick(cheater getEntityNumber(), reason);
}

notifyBan(client, type, cheaterName, reason, duration){
	banText = "";
	if(type == "permenent")
		banText = "^2The player \"^1"+cheaterName+"\"^2 has Permenently Banned from the server. Reason: \""+reason+"\".";
	else if(type == "temporary")
		banText = "The player \"^1"+cheaterName+"\"^2 has Temporary Banned from the server for "+duration+" Reason: \""+reason+"\".";

	if(level.vars["announceBan"]){
		chatsay(banText);
		return;
	}

	if(isDefined(client)){
		client chattell(banText);
	}
}

getLastBanID(clientID){
	banDet = getLastActiveBan(clientID);

	if(isDefined(banDet))
		return banDet["id"];
}

getLastActiveBan(clientID){
	query = "SELECT * FROM `"+level.vars["bansTable"]+"` WHERE client_id = '"+clientID+"' AND status = '1' ORDER BY id DESC LIMIT 1";
	banDet = getRow(query);

	return banDet;
}

getBanHistory(clientID){
	query = "SELECT * FROM `"+level.vars["bansTable"]+"` WHERE client_id = '"+clientID+"' ORDER BY id DESC";
	banDet = getRows(query);

	return banDet;
}

replaceServerID(id){
	if(id == level.vars["server_id"])
		id = "SERVER";

	return id;
}

unBanTempBans(){
	banDet = banList("tempban");
	timeNow = getRealTime();

	for(i=0; i<banDet.size; i++)
		if(banDet[i]["time_expire"] != "0" && timeNow > int(banDet[i]["time_expire"]))
			unbanClient(banDet[i]["id"]);
}