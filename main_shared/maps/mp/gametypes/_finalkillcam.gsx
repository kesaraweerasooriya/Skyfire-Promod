#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
    level.fk = false;
    level.showFinalKillcam = false;
    level.waypoint = false;
    
    level.doFK["axis"] = false;
    level.doFK["allies"] = false;
    
    OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread beginFK();
    }
}    
        
beginFK()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("beginFK", winner);
        
        self notify ( "reset_outcome" );
        
        if(level.TeamBased)
        {
            self finalkillcam(level.KillInfo[winner]["attacker"], level.KillInfo[winner]["attackerNumber"], level.KillInfo[winner]["deathTime"], level.KillInfo[winner]["victim"]);
        }
        else
        {
            self finalkillcam(winner.KillInfo["attacker"], winner.KillInfo["attackerNumber"], winner.KillInfo["deathTime"], winner.KillInfo["victim"]);
        }
    }
}

finalkillcam( attacker, attackerNum, deathTime, victim)
{
    self endon("disconnect");
    level endon("end_killcam");

    camtime = 5;
    predelay = getTime()/1000 - deathTime;
    postdelay = 2;
    killcamlength = camtime + postdelay;
    killcamoffset = camtime + predelay;
    
    visionSetNaked( getdvar("mapname") );
    
    self notify ( "begin_killcam", getTime() );
    
    self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);
    
    self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.killcamentity = -1;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = 0;
    
    self.killcam = true;
    
    wait 0.05;
    
    if(!isDefined(self.team_logo))
    {
        self CreateFKMenu(attacker);
    }
    else
    {
	    self.fk_title.alpha = 0;
	    self.fk_title_low.alpha = 0;
		self.team_logo.alpha = 0;
    }
    
    self thread WaitEnd(killcamlength);
    
    wait 0.05;
    
    self waittill("end_killcam");
    
    self thread CleanFK();
    
    self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
    
    wait 0.05;
    
    self.sessionstate = "spectator";
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	assert( spawnpoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self spawn(spawnpoint.origin, spawnpoint.angles);

    wait 0.05;
    
    self.killcam = undefined;
    self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

    level notify("end_killcam");

    level.fk = false;  
}

CleanFK()
{
    self.fk_title.alpha = 0;
    self.fk_title_low.alpha = 0;
	self.team_logo.alpha = 0;
    
    visionSetNaked( "mpOutro", 1.0 );
}

WaitEnd( killcamlength )
{
    self endon("disconnect");
	self endon("end_killcam");
    
    wait killcamlength;
    
    self notify("end_killcam");
}

CreateFKMenu(attacker)
{
    self.team_logo = NewHudElem();
    self.team_logo.elemType = "shader";
    self.team_logo.y = 0;
    self.team_logo.x = 10;
    self.team_logo.archived = false;
    self.team_logo.horzAlign = "left";
    self.team_logo.vertAlign = "top";
    self.team_logo.sort = 0; 
    self.team_logo.foreground = true;
    self.team_logo setShader(getIconByTeam(attacker),90,90);
    
    self.fk_title = NewHudElem();
    self.fk_title.archived = false;
    self.fk_title.y = 22;
    self.fk_title.alignX = "center";
    self.fk_title.alignY = "middle";
    self.fk_title.horzAlign = "center";
    self.fk_title.vertAlign = "top";
    self.fk_title.sort = 1; // force to draw after the bars
    self.fk_title.font = "default";
    self.fk_title.fontscale = 2.8;
    self.fk_title.foreground = true;
    
    self.fk_title_low = NewHudElem();
    self.fk_title_low.archived = false;
    self.fk_title_low.x = 0;
    self.fk_title_low.y = -34;
    self.fk_title_low.alignX = "center";
    self.fk_title_low.alignY = "bottom";
    self.fk_title_low.horzAlign = "center_safearea";
    self.fk_title_low.vertAlign = "bottom";
    self.fk_title_low.sort = 2; // force to draw after the bars
    self.fk_title_low.font = "objective";
    self.fk_title_low.fontscale = 1.6;
    self.fk_title_low.glowcolor = (0,0,1);
    self.fk_title_low.glowAlpha = 1;
    self.fk_title_low.foreground = true;
        
    self.fk_title.alpha = 1;
    self.fk_title_low.alpha = 1;
    self.team_logo.alpha = 1;

    if(isDefined(attacker))
        self.fk_title_low setText(attacker.name);
    
    if(maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit())
        self.fk_title setText("GAME WINNING KILL");
    else
        self.fk_title setText("ROUND WINNING KILL");
}

onPlayerKilled(attacker)
{
    if(isDefined(attacker) && isPlayer(attacker) && attacker != self)
    {
        level.showFinalKillcam = true;
        
        team = attacker.team;
        
        level.doFK[team] = true;
        
        if(level.teamBased)
        {
            level.KillInfo[team]["attacker"] = attacker;
            level.KillInfo[team]["attackerNumber"] = attacker getEntityNumber();
            level.KillInfo[team]["victim"] = self;
            level.KillInfo[team]["deathTime"] = GetTime()/1000;
        }
        else
        {
            attacker.KillInfo["attacker"] = attacker;
            attacker.KillInfo["attackerNumber"] = attacker getEntityNumber();
            attacker.KillInfo["victim"] = self;
            attacker.KillInfo["deathTime"] = GetTime()/1000;
        }
    }
}

startFK( winner )
{
    level endon("end_killcam");
    
    if(!level.showFinalKillcam)
        return;
    
    if(!level.doFK[winner])
        return;
    
    level.fk = true;
    song = getKillCamSong();
    
    for( i = 0; i < level.players.size; i ++)
    {
        player = level.players[i];

        player thread playKillCamSound( "endround" +song );        
        player notify("beginFK", winner);
    }
}

playKillCamSound(song){
    if(!self promod\client::get_config("FK_SOUND"))
        self playLocalSound(song);
}

getIconByTeam(attacker){
    if(attacker.team == "allies"){
        if(game["allies"]=="sas")
            return "faction_128_sas";
        else
            return "faction_128_usmc";
    }
    else{
        if(game["axis"]=="opfor" || game["axis"]=="arab")
            return "faction_128_arab";
        else
            return "faction_128_ussr";          
    }
}

getKillCamSong(){
    song = 1;
    if( maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit()){
        songNum = (1+randomInt(9));
        
        if(songNum == 1 || songNum == 3 || songNum == 5 || songNum == 7 || songNum == 9 )
            song = "s1";
        else
            song = "s2";
    }   
    else{
        if(!isDefined(game["playedSongs"]))
            game["playedSongs"] = "";

        song = (1+randomInt(8));

        while(isSubStr(game["playedSongs"], song+" "))   // "",1
            song = (1+randomInt(8));

        game["playedSongs"] += song+" ";
        if(strTok(game["playedSongs"], " ").size > 7)
            game["playedSongs"] = "";
    } 

    return song;
}