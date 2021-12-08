/*===================================================================||
||/|¯¯¯¯¯¯¯\///|¯¯|/////|¯¯|//|¯¯¯¯¯¯¯¯¯|//|¯¯¯¯¯¯¯¯¯|//\¯¯\/////¯¯//||
||/|  |//\  \//|  |/////|  |//|  |/////////|  |//////////\  \///  ///||
||/|  |///\  \/|  |/////|  |//|  |/////////|  |///////////\  \/  ////||
||/|  |///|  |/|  |/////|  |//|   _____|///|   _____|//////\    /////||
||/|  |////  //|  \/////|  |//|  |/////////|  |/////////////|  |/////||
||/|  |///  ////\  \////  ////|  |/////////|  |/////////////|  |/////||
||/|______ //////\_______/////|__|/////////|__|/////////////|__|/////||
||===================================================================||
||     DO NOT USE, SHARE OR MODIFY THIS FILE WITHOUT PERMISSION      ||
||===================================================================*/

#include plugins\_common;

init() {
	if(getDvar("g_gametype") == "dm")
		return;
	addConnectThread(::WatchTeamJoins);
	level thread AutoBalance();
}

WatchTeamJoins() {
	self endon("disconnect");
	while(1) {
		self waittill("joined_team");
		self.pers["team_join_time"] = getTime();
	}
}

AutoBalance() {
	wait .05;
	if(level.gametype != "sd")
		level endon("game_ended");
	wait 10;
	changeteam = "";
	player_change_team = [];
	while(game["state"] == "playing") {
		wait 10;
		team["axis"] = getTeamPlayers("axis");
		team["allies"] = getTeamPlayers("allies");
		if(team["axis"].size == team["allies"].size || !team["axis"].size || !team["allies"].size)
			continue;
		changeteam = "allies";
		if(team["axis"].size < team["allies"].size)
			changeteam = "axis";
		if(!RoundDown((team[level.otherTeam[changeteam]].size - team[changeteam].size) / 2))
			continue;
		iPrintLnBold("^2Teams will be Auto balanced at the end of this Round.");
		level waittill("game_ended");
		team["axis"] = getTeamPlayers("axis");
		team["allies"] = getTeamPlayers("allies");
		if(team["axis"].size == team["allies"].size || !team["axis"].size || !team["allies"].size)
			continue;
		changeteam = "allies";
		if(team["axis"].size < team["allies"].size)
			changeteam = "axis";
		players_to_add = RoundDown((team[level.otherTeam[changeteam]].size - team[changeteam].size) / 2);
		player_change_team = [];
		players = team[level.otherTeam[changeteam]];
		for(i=0;i<players_to_add;i++) {
			switchtime = -1;
			for(k=0;k<players.size;k++) {
				if(isDefined(players[k]) && players[k].pers["team_join_time"] > switchtime && !players[k].pers["team_locked"]){
					if(player_change_team.size == 0) {
						player_change_team[0] = players[k];
						switchtime = players[k].pers["team_join_time"];				
					}
					else {
						for(j=0;j<player_change_team.size;j++) {
							if(player_change_team[j] == players[k])
								j=100;
							else {
								player_change_team[i] = players[k];
								switchtime = players[k].pers["team_join_time"];
							}
						}
					}
				}
			}
		}
		for(j=0;j<player_change_team.size;j++) {
			if(changeteam == "axis")
				player_change_team[j] [[level.axis]]();
			else 
				player_change_team[j] [[level.allies]]();
		}
	}
}


START 
	GET player_skill
	GET AVERAGE  avg = all player_skill / player_count
	GET team eke player_skill > avg count eka
	IF(team_player_skill_morethan_avg_count - other_team_player_skill_morethan_avg_count > 1)
		BALANCE above_avg_players
	GET teams_avg 


