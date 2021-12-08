#include codxql\mysql;
#include codxql\common;

init(){
	thread countCurrentPlayers();
	thread initLog();
	thread initWeaponFactors();
	thread doTopList();
	addThreadOnce(::initOnce);

	addConnectThread(::OnJoin, true);
}

initOnce(){
	thread calculateKillBonus();
	thread correctStats();
}

initStorage(){
	query =  "CREATE TABLE IF NOT EXISTS `"+level.vars[ "xlr_playerstatTable" ]+"` (";
	query += 	"`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,";
	query += 	"`client_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`kills` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`deaths` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`teamkills` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`teamdeaths` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`suicides` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"`ratio` FLOAT NOT NULL DEFAULT '0',";
	query += 	"`skill` FLOAT NOT NULL DEFAULT '0',";
	query += 	"`assists` MEDIUMINT(8) NOT NULL DEFAULT '0',";
	query += 	"`assistskill` FLOAT NOT NULL DEFAULT '0',";
	query += 	"`curstreak` SMALLINT(6) NOT NULL DEFAULT '0',";
	query += 	"`winstreak` SMALLINT(6) NOT NULL DEFAULT '0',";
	query += 	"`losestreak` SMALLINT(6) NOT NULL DEFAULT '0',";
	query += 	"`rounds` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',";
	query += 	"PRIMARY KEY (`id`),";
	query += 	"UNIQUE KEY `client_id` (`client_id`)";
	query += ") ENGINE=MyISAM DEFAULT CHARSET=utf8";

	a[0] = level.vars["xlr_playerstatTable"];
	a[1] = query;

	return a;
}

initLog(){
	if(!level.vars["xlr_verbose"])
		return;
	
	level.varsverbose = FS_FOpen(level.vars["xlr_verboseFile"], "append");
}

xlrStatus(){
	if(isDefined(game["sqlTable"][level.vars["xlr_playerstatTable"]]) && (isDefined(level.vars["xlr_status"]) && level.vars["xlr_status"])){
		return true;
	}
	else{
		self chattell("^1XLR Stats is currently turned off. Please check back later.");
		return false;
	}
}

doTopList(){
	for(;;){
		last_time = getDvarInt("topListShow_last_time");

		if(last_time == 0){
			setDvar("topListShow_last_time", getRealTime());
			continue;
		}

		if(getRealTime() - last_time >= level.vars["topListShow_Interval"] * 60){
			list = getTopPlayers(level.vars["topPlayersCount"]);

			if(isDefined(list) && list.size == level.vars["topPlayersCount"]){
				chatsay("XLR Stats Top "+level.vars["topPlayersCount"]+" Players:");
				for(i=1; i<=list.size; i++){
					wait .5;
					chatsay("^3#"+i+" ^7: ^3Name^7: "+list[i-1]["name"]+" ^3Skill^7: "+list[i-1]["skill"]+" ^3Kills^7: "+list[i-1]["kills"]+" ^3Ratio^7: "+round(list[i-1]["ratio"], 2));
				}
			}
			else
				chatsay("Qualify for the toplist by making at least "+level.vars["_minKills"]+" kills and playing "+level.vars["_minRounds"]+" rounds");

			setDvar("topListShow_last_time", getRealTime());
		}
		last_time = undefined;
		list = undefined;

		wait 1;
	}
}

OnJoin(){
	if(isBot(self))
		return;

	waitTillPlayerID(self);

	playerStats = getPlayerStats(self);

	if(isDefined(playerStats)){
		playerStats["rounds"]++;

		save_PlayerStat(playerStats);
	}
}

OnAction(player, action){
	if(!isDefined(player))
		return;

	if(isBot(player))
		return;

	playerStats = getPlayerStats(player);
	if(!isDefined(playerStats))
		return;

	action_skilladd = getConfig(action);
	if(!isDefined(action_skilladd))
		action_skilladd = level.vars["action_skilladd"];

	playerStats["skill"] += action_skilladd;
	save_PlayerStat(playerStats);
}

OnDamage(victim, attacker, idamage, sWeapon, sMeansOfDeath){
	if(!isDefined(attacker) || !isDefined(victim))
		return;

	if(attacker == victim)
		return;
	
	if(isBot(victim) || isBot(attacker))
		return;

	if(idamage < level.vars["assist_min_dmg"])
		return;
	
	if(!isDefined(victim.assister))
		victim.assister = [];

	if(victim.assister.size > 0){
		for(i=0; i<victim.assister.size; i++)
			if(victim.assister[i][0] == attacker)
				return;
	}

	weapon_factor = getConfig(sMeansOfDeath);
	if(!isDefined(weapon_factor))
		weapon_factor = getConfig(sWeapon);
	if(!isDefined(weapon_factor))
		weapon_factor = 1.0;

	s = victim.assister.size;
	victim.assister[s][0] = attacker;
	victim.assister[s][1] = getTime();
	victim.assister[s][2] = weapon_factor;	
}

Onkilled(victim, attacker, sWeapon, sMeansOfDeath){
	if(!isDefined(attacker) || !isDefined(victim))
		return;
	
	if(isBot(victim) || isBot(attacker))
		return;

	anonymous = "";
	both_provisional = 0;
	
	//Find about Assists
	assist = check_Assists(attacker, victim);
	
	attackerStats = getPlayerStats(attacker); //Get registered player stats.
	victimStats   = getPlayerStats(victim);
	
	if(!isDefined(attackerStats) && !isDefined(victimStats))
		return;
	if(!isDefined(attackerStats)){
		anonymous = "attacker";
		attackerStats = getPlayerStats(); //Get default stat when we dont pass anything.
		if(!isDefined(attackerStats))
			return;
		attackerStats["skill"] = level.vars["defaultskill"];
	}
	
	if(!isDefined(victimStats)){
		anonymous = "victim";
		victimStats = getPlayerStats();
		if(!isDefined(victimStats))
			return;
	}
	
	attacker_winProb = winProb(attackerStats["skill"], victimStats["skill"]); //Get winning probabilities for attacker
	victim_winProb = 1 - attacker_winProb;
	
	weapon_factor = getConfig(sMeansOfDeath);
	if(!isDefined(weapon_factor))
		weapon_factor = getConfig(sWeapon);
	if(!isDefined(weapon_factor))
		weapon_factor = 1.0;
	
	if(isDefined(anonymous) && anonymous != "attacker"){
		oldskill = attackerStats["skill"];
		skilladdition = level.vars["kill_bonus"] * attackerStats["kfactor"] * weapon_factor * (1 - attacker_winProb);

		if(assist["assists_sum"] != 0){
			if(assist["assists_sum"] >= (skilladdition/2))
				skilladdition /=2;
			else
				skilladdition -= assist["assists_sum"];
		}

		attackerStats["skill"] += float(skilladdition);
		attackerStats["kills"]++;

		if(attackerStats["deaths"] != 0)
			attackerStats["ratio"] = attackerStats["kills"] / attackerStats["deaths"];
		else
			attackerStats["ratio"] = 0.0;

		if(attackerStats["curstreak"] > 0)
			attackerStats["curstreak"]++;
		else
			attackerStats["curstreak"] = 1;

		if(attackerStats["curstreak"] > attackerStats["winstreak"])
			attackerStats["winstreak"] = attackerStats["curstreak"];

		if((victimStats["kills"] + victimStats["deaths"]) < level.vars["Kswitch_confrontations"] && (attackerStats["kills"] + attackerStats["deaths"]) < level.vars["Kswitch_confrontations"] && level.vars["provisional_ranking"])
			both_provisional = 1;

		if(both_provisional || (victimstats["kills"] + victimstats["deaths"]) > level.vars["Kswitch_confrontations"] || !level.vars["provisional_ranking"] || anonymous == "victim")
			save_PlayerStat(attackerStats);
	}

	if(isDefined(anonymous) && anonymous != "victim"){
		oldskill = victimStats["skill"];
		skilldeduction = victimStats["kfactor"] * weapon_factor * (0 - victim_winProb);

		if(assist["victim_sum"] != 0){
			if(assist["victim_sum"] >= (skilldeduction/2))
				skilldeduction /=2;
			else
				skilldeduction -= assist["victim_sum"];
		}

		victimStats["skill"] += float(skilldeduction);
		victimStats["deaths"]++;

		victimStats["ratio"] = float(victimStats["kills"]) / float(victimStats["deaths"]);

		if(victimStats["curstreak"] < 0)
			victimStats["curstreak"]--;
		else
			victimStats["curstreak"] = -1;

		if(victimStats["curstreak"] < victimStats["losestreak"])
			victimStats["losestreak"] = victimStats["curstreak"];

		if((victimStats["kills"] + victimStats["deaths"]) < level.vars["Kswitch_confrontations"] && (attackerStats["kills"] + attackerStats["deaths"]) < level.vars["Kswitch_confrontations"] && level.vars["provisional_ranking"])
			both_provisional = 1;

		if(both_provisional || (attackerStats["kills"] + attackerStats["deaths"]) > level.vars["Kswitch_confrontations"] || !level.vars["provisional_ranking"] || anonymous == "attacker")
			save_PlayerStat(victimStats);
	}

	if(isDefined(anonymous)){
		if(anonymous == "attacker" && isDefined(attackerStats["new"]))
			save_PlayerStat(attackerStats);
		else if(anonymous == "victim" && isDefined(victimStats["new"]))
			save_PlayerStat(victimStats);
	}
}

OnTeamKill(victim, attacker){
	if(!isDefined(attacker) || !isDefined(victim)) //what if attacker == victim
		return;

	if(isBot(victim) || isBot(attacker))
		return;

	anonymous = "";
	
	check_Assists(attacker, victim);
	
	attackerStats = getPlayerStats(attacker); //Get registered player stats.
	victimStats   = getPlayerStats(victim);
	
	if(!isDefined(attackerStats) && !isDefined(victimStats))
		return;

	if(!isDefined(attackerStats)){
		anonymous = "attacker";
		attackerStats = getPlayerStats(); //Get default stat when we dont pass anything.
		if(!isDefined(attackerStats))
			return;
		attackerStats["skill"] = level.vars["defaultskill"];
	}
	
	if(!isDefined(victimStats)){
		anonymous = "victim";
		victimStats = getPlayerStats();	//Get default stat when we dont pass anything.
		if(!isDefined(victimStats))
			return;
		victimStats["skill"] = level.vars["defaultskill"];
	}

	if(isDefined(anonymous) && anonymous != "attacker"){
		oldskill = attackerStats["skill"];
		attackerStats["skill"] = (1 - (level.vars["tk_penalty"] / 100.0)) * attackerStats["skill"];
		attackerStats["teamkills"] += 1;
		attackerStats["curstreak"] = 0;

		//Announcement

		save_PlayerStat(attackerStats);
	}

	if(isDefined(anonymous) && anonymous != "victim"){
		victimStats["teamdeaths"] += 1;
		save_PlayerStat(victimStats);
	}
}

OnSuicide(victim){
	if(!isDefined(victim))
		return;
	
	if(isBot(victim))
		return;	

	check_Assists(undefined ,victim);

	victimStats = getPlayerStats(victim);

	if(!isDefined(victimStats)) //Anonymous player
		return;

	victimStats["suicides"] += 1;
	if(victimStats["curstreak"] < 0)
		victimStats["curstreak"] -= 1;
	else
		victimStats["curstreak"] = -1;

	if(victimStats["curstreak"] < victimStats["losestreak"])
		victimStats["losestreak"] = victimStats["curstreak"];

	oldskill = victimStats["skill"];
	victimStats["skill"] = (1 - (level.vars["suicide_penalty"] / 100.0)) * victimStats["skill"];

	//Announce

	save_PlayerStat(victimStats);
}

check_Assists(attacker, victim){
	a=[];
	a["count"] = 0;
	a["assists_sum"] = 0;
	a["victim_sum"] = 0;

	// If victim.assister.size = 1 means the killer was the assister. So no need to go to the loop.
	if(!isDefined(victim.assister) || (isDefined(victim.assister) && victim.assister.size <= 1))
		return a;

	for(i=0; i < victim.assister.size; i++){
		assister = victim.assister[i][0];

		if(!isDefined(assister) || (isDefined(attacker) && assister == attacker))
			continue;

		if((getTime() - victim.assister[i][1]) > level.vars["assist_max_time"])
			continue;

		anonymous = "";

		victimStats = getPlayerStats(victim);
		attackerStats = getPlayerStats(assister);

		if(!isDefined(victimStats) && !isDefined(attackerStats))
			continue;

		if(!isDefined(victimStats)){
			anonymous = "victim";

			victimStats = getPlayerStats();
			if(!isDefined(victimStats))
				continue;
		}

		if(!isDefined(attackerStats)){
			anonymous = "attacker";

			attackerStats = getPlayerStats();
			if(!isDefined(attackerStats))
				continue;
		}

		attacker_winProb = winProb(attackerStats["skill"], victimStats["skill"]);
		victim_winProb = 1 - attacker_winProb;

		weapon_factor = victim.assister[i][2];

		if(isDefined(anonymous) && anonymous != "attacker"){
			oldskill = attackerStats["skill"];

			if((victim.pers["team"] == assister.pers["team"]) && level.teamBased) {
				skilladdition = level.vars["assist_bonus"] * attackerStats["kfactor"] * weapon_factor * (0 - attacker_winProb);
				attackerStats["skill"] += skilladdition;
				attackerStats["assistskill"] += skilladdition;
				attackerStats["assists"]--;

				a["count"]++;
				a["assists_sum"] += skilladdition;
				//Announcement
			}
			else{
				skilladdition = level.vars["assist_bonus"] * attackerStats["kfactor"] * weapon_factor * (1 - attacker_winProb);
				attackerStats["skill"] += skilladdition;
				attackerStats["assistskill"] += skilladdition;
				attackerStats["assists"]++;

				//Verbose

				a["count"]++;
				a["assists_sum"] += skilladdition;
				//Announce
			}

			save_PlayerStat(attackerStats);

			oldskill = victimStats["skill"];

			if((victim.pers["team"] != assister.pers["team"]) || !level.teamBased){
				skilladdition = level.vars["assist_bonus"] * victimStats["kfactor"] * weapon_factor * (0 - victim_winProb);
				victimStats["skill"] += skilladdition;
				//Verbose
				a["victim_sum"] += skilladdition;
			}

			save_PlayerStat(victimStats);
		}
	}

	victim.assister = undefined;
	return a;
}

getPlayerStats(player){	
	if(isDefined(player))
		client_id = player.pers["cxID"];
	else
		client_id = level.vars["server_id"];

	query = "SELECT * FROM `"+level.vars["xlr_playerstatTable"]+"` WHERE client_id = '"+client_id+"' LIMIT 1";
	row = getRow(query);

	if(isDefined(row)){
		p["id"] 		 = row["id"];
		p["client_id"]	 = row["client_id"];
		p["kills"]		 = int(row["kills"]);
		if(p["kills"] > level.vars["Kswitch_confrontations"])
			p["kfactor"] = level.vars["kfactor_low"];
		else
			p["kfactor"] = level.vars["kfactor_high"];
		p["deaths"]		 = int(row["deaths"]);
		p["teamkills"]	 = int(row["teamkills"]);
		p["teamdeaths"]	 = int(row["teamdeaths"]);
		p["suicides"]	 = int(row["suicides"]);
		p["ratio"]		 = float(row["ratio"]);
		p["skill"]		 = float(row["skill"]);
		p["assists"]	 = int(row["assists"]);
		p["assistskill"] = float(row["assistskill"]);
		p["curstreak"]   = int(row["curstreak"]);
		p["winstreak"]	 = int(row["winstreak"]);
		p["losestreak"]	 = int(row["losestreak"]);
		p["rounds"]		 = int(row["rounds"]);

		return p;
	}
	else if(!isDefined(player) || (isDefined(player) && player getPower() >= level.vars["player_min_power"])){
		p = definePlayer();
		p["client_id"]	= client_id;
		p["new"]		= true;
		p["skill"]		= level.vars["defaultskill"];
		p["kfactor"]	= level.vars["kfactor_high"];

		return p;
	}
	else
		return;
}

getPlayerRank(player){
	waitTillPlayerID(player);

	query =  "SELECT count(1) as cnt ";
	query += "FROM (";
	query += 	"SELECT * ";
	query += 	"FROM `"+level.vars["xlr_playerstatTable"]+"` ";
	query += 	"WHERE skill >= (SELECT skill FROM `"+level.vars["xlr_playerstatTable"]+"` WHERE client_id = '"+player.pers["cxID"]+"')";
	query += ") AS t LIMIT 1";

	row = getRow(query);

	if(isDefined(row))
		return row["cnt"];
	else
		return "-1";
}

getTopPlayers(count){
	if(!isDefined(count))
		count = 3;

	query =  "SELECT cli.name, cli.time_last_seen, xlr.kills, xlr.ratio, xlr.skill ";
	query += "FROM `"+level.vars["xlr_playerstatTable"]+"` AS xlr, `"+level.vars["clientsTable"]+"` AS cli ";
	query += "WHERE (cli.id = xlr.client_id) ";
	query += "AND ((xlr.kills > "+level.vars["_minKills"]+") AND (xlr.rounds > "+level.vars["_minRounds"]+")) ";
	query += "AND "+getRealTime()+" - cli.time_last_seen <= "+level.vars["_maxDays"]+" * 86400 "; //86400 = seconds for a day (60 * 60 * 24)
	query += "ORDER BY xlr.skill DESC LIMIT "+count;

	rows = getRows(query);

	if(isDefined(rows))
		return rows;
	else
		return;
}

save_PlayerStat(playerstat){
	if(isDefined(playerstat["new"])){
		query =  "INSERT INTO `"+level.vars["xlr_playerstatTable"]+"` (client_id, kills, deaths, teamkills, teamdeaths, suicides, ratio, skill, assists, assistskill, curstreak, winstreak, losestreak, rounds) ";
		query += "VALUES('"+playerstat["client_id"]+"', '"+playerstat["kills"]+"', '"+playerstat["deaths"]+"', '"+playerstat["teamkills"]+"', '"+playerstat["teamdeaths"]+"', '"+playerstat["suicides"]+"', '" +playerstat["ratio"]+"', '"+playerstat["skill"]+"', '"+playerstat["assists"]+"', '"+playerstat["assistskill"]+"', '"+playerstat["curstreak"]+"', '"+playerstat["winstreak"]+"', '"+playerstat["losestreak"]+"', '"+playerstat["rounds"]+"')";
	}
	else{
		query =  "UPDATE `"+level.vars["xlr_playerstatTable"]+"` "; 
		query += "SET "+"kills='"+playerstat["kills"]+"', deaths='"+playerstat["deaths"]+"', teamkills='"+playerstat["teamkills"]+"', teamdeaths='"+playerstat["teamdeaths"]+"', suicides='"+playerstat["suicides"]+"', ratio='"+playerstat["ratio"]+"', skill='"+playerstat["skill"]+"', assists='"+playerstat["assists"]+"', assistskill='"+playerstat["assistskill"]+"', curstreak='"+playerstat["curstreak"]+"', winstreak='"+playerstat["winstreak"]+"', losestreak='"+playerstat["losestreak"]+"', rounds='"+playerstat["rounds"]+"' "; 
		query += "WHERE client_id='"+playerstat["client_id"]+"'";
	}

	qexec(query);
}

definePlayer(){
	p = [];	

	p["id"] 		= 0;
	p["client_id"]	= 0;
	p["kfactor"] 	= 1;
	p["kills"]		= 0;
	p["deaths"]		= 0;
	p["teamkills"]	= 0;
	p["teamdeaths"]	= 0;
	p["suicides"]	= 0;
	p["ratio"]		= 0;
	p["skill"]		= 0;
	p["assists"]	= 0;
	p["assistskill"]= 0;
	p["curstreak"]	= 0;
	p["winstreak"]	= 0;
	p["losestreak"]	= 0;
	p["rounds"]		= 0;

	return p;
}

initWeaponFactors(){
	if(isDefined(level.weaponMultipliers))
		return;

	test = FS_TestFile(level.vars["xlr_weapon_fact_conf"]);
	if(test)
		FS_FClose(test);
	else
		return;

	fileHandle = FS_FOpen(level.vars["xlr_weapon_fact_conf"], "read");

	level.weaponMultipliers = [];
	while(1){
		string = FS_ReadLine(fileHandle);

		if(!isDefined(string))
			break;

		if(string != "" && string[0] != "#"){
			string = removeSpaces(string);
			config = strTok(string, ":");

			if(config.size > 1){
				size = level.weaponMultipliers.size;
				level.weaponMultipliers[size][0] = config[0];
				level.weaponMultipliers[size][1] = config[1];
			}
		}
	}

	FS_FClose(fileHandle);
}

getConfig(attribute){
	if(!isDefined(attribute) || !isDefined(level.weaponMultipliers))
		return;

	for(i=0; i<level.weaponMultipliers.size; i++){
		if(toLower(level.weaponMultipliers[i][0]) == toLower(attribute) || isSubStr(attribute, level.weaponMultipliers[i][0]))
			return strToIF(level.weaponMultipliers[i][1]);
	}

	return;
}

countCurrentPlayers(){
 	while(!isDefined(level.players))
 		wait .05;

	while(1){
		if(level.players.size > level.vars["min_players"])
			level.vars["xlr_status"] = true;
		else
			level.vars["xlr_status"] = false;

		level waittill("connected", player);
	}
}

calculateKillBonus(){
	oldKillBonus = level.vars["kill_bonus"];
	minDaysSec = 20 *86400;

	query =  "SELECT "+level.vars["clientsTable"]+".time_last_seen, MAX("+level.vars["xlr_playerstatTable"]+".skill) AS max_skill ";
	query += "FROM `"+level.vars["clientsTable"]+"`, `"+level.vars["xlr_playerstatTable"]+"` ";
	query += "WHERE "+getRealTime()+" - " +level.vars["clientsTable"]+".time_last_seen <= "+minDaysSec;

	row = getRow(query);
	
	if(!isDefined(row))
		return;

	maxSkill = row["max_skill"];

	if(!isDefined(maxSkill) || maxSkill == "")
		maxSkill = level.vars["defaultskill"];

	difference = float(maxSkill) - level.vars["defaultskill"];
	if(difference < 0)
		level.vars["kill_bonus"] = 2.0;
	else if(difference < 400)
		level.vars["kill_bonus"] = 1.5;
	else{
		c = 200.0 / difference + 1;
		level.vars["kill_bonus"] = round(c, 1);
	}

	level.vars["assist_bonus"] = level.vars["kill_bonus"] / 3;

	//Verbose
}

correctStats(){
	if(getdvarint("last_corrected_time") != 0 && (getRealTime() - getdvarint("last_corrected_time") <= 7200))
		return;

	setDvar("last_corrected_time", getRealTime());

	ignoreDays = level.vars["auto_correct_ignore_days"] * 86400;

	xlrT = level.vars["xlr_playerstatTable"];
	clientT = level.vars["clientsTable"];

	query =  "SELECT MAX("+xlrT+".skill) AS max_skill, MIN("+xlrT+".skill) AS min_skill, SUM("+xlrT+".skill) AS sum_skill, AVG("+xlrT+".skill) AS avg_skill, COUNT("+clientT+".id) AS cnt ";
	query += "FROM `"+clientT+"`, `"+xlrT+"` ";
	query += "WHERE "+clientT+".id = "+xlrT+".client_id ";
	query += "AND "+xlrT+".client_id <> "+level.vars["server_id"]+" ";
	query += "AND ("+xlrT+".kills + "+xlrT+".deaths) > "+level.vars["Kswitch_confrontations"]+" ";
	query += "AND "+getRealTime() +" - "+clientT+".time_last_seen <= "+ignoreDays;

	row = getRow(query);
	if(!isDefined(row))
		return;

	if(int(row["cnt"]) == 0)
		return;

	min_avg = level.vars["defaultskill"] + 100;
	//factor_decimals = 5; //Default xlr factor_decimal is 6 But in cod4 gsc's, max decimal point is 5. If some number has more than 5 decimal points it will rounded to 5. Will this affect to the correction??
	surplus = float(row["sum_skill"]) - (int(row["cnt"]) * min_avg);
	correction = surplus / int(row["cnt"]);
	correction_factor = (int(row["cnt"]) * min_avg) / float(row["sum_skill"]);

	//Verbose

	if(level.vars["auto_correct"] && correction_factor < 1){
		query = "UPDATE `"+level.vars["xlr_playerstatTable"]+"` SET skill=(SELECT skill * "+correction_factor +") WHERE "+level.vars["xlr_playerstatTable"]+".client_id <> "+level.vars["server_id"];
		Qexec(query);
	}
}

winProb(player_skill, opponent_skill){
	return 1 / (pow(10, ((opponent_skill - player_skill) / level.vars["steepness"])) + 1);
}

//***********************
//	UTILITY FUNCTIONS
//-----------------------

debugxlr(text){
	if(level.vars["xlr_debug"])
		logprint("XLR Rating Debug:: " +text +"\n");
}
verbose(logstr){
	if(level.vars["xlr_verbose"]){
		if(isDefined(level.varsverbose))
			FS_WriteLine(level.varsverbose, logstr);
	}
}