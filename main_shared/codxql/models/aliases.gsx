#include codxql\mysql;
#include codxql\common;

init(){
	addConnectThread(::OnPlayerConnect, true);
}

initStorage(){
	query =  "CREATE TABLE IF NOT EXISTS `"+level.vars[ "aliasesTable" ]+"` (";
	query += 	"`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,";
	query += 	"`client_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`alias` VARCHAR(32) NOT NULL DEFAULT '',";
	query += 	"`num_uses` INT(10) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`locked` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"PRIMARY KEY (`id`),";
	query += 	"UNIQUE KEY `alias` (`alias`, `client_id`),";
	query += 	"KEY `client_id` (`client_id`)";
	query += ") ENGINE=MyISAM DEFAULT CHARSET=utf8";

	a[0] = level.vars["aliasesTable"];
	a[1] = query;

	return a;
}

OnPlayerConnect(){
	if(isBot(self))
		return;
	
	waitTillPlayerID(self);

	query = "SELECT * FROM `"+level.vars["aliasesTable"]+"` WHERE alias = '"+self.name+"' LIMIT 1";
	alias = getRow(query);

	if(isDefined(alias)){
		if(alias["client_id"] != self.pers["cxID"]){
			if(level.vars["lokedNamesKick"] && int(alias["locked"]))
				self thread kickForLockedNames();
		}
		else
			self updatePlayerAlias(alias["id"]);
	}
	else
		self updatePlayerAlias();
}

getPlayerAliases(){
	waitTillPlayerID(self);

	query = "SELECT * FROM `"+level.vars["aliasesTable"]+"` WHERE client_id = '"+self.pers["cxID"]+"' ORDER BY num_uses DESC";
	playerAliases = getRows(query);

	if(isDefined(playerAliases))
		return playerAliases;
	else
		return;
}

updatePlayerAlias(id){
	waitTillPlayerID(self);

	if(isDefined(id))
		query = "UPDATE `"+level.vars["aliasesTable"]+"` SET num_uses = num_uses + 1 WHERE id = '"+id+"'";
	else
		query = "INSERT INTO `"+level.vars["aliasesTable"]+"`(client_id, alias, num_uses) VALUES ('"+self.pers["cxID"]+"', '"+self.name+"', '1')";

	Qexec(query);
}

kickForLockedNames(){
	wait 3;
	exec("clientkick " + self getEntityNumber() + " ^1You cannot use admin names. (Auto Kick)");
}

updateAliasOwner(id, cid){
	query = "UPDATE "+level.vars["aliasesTable"]+" SET client_id = "+cid+" WHERE id = "+id;
	Qexec(query);	
}

toggelLock(id,t){
	query = "UPDATE "+level.vars["aliasesTable"]+" SET locked = "+t+" WHERE id = "+id;
	Qexec(query);
}