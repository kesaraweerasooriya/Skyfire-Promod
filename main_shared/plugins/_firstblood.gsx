//  ________/\\\\\\\\\__________________________________________________________        
//   _____/\\\////////___________________________________________________________       
//    ___/\\\/_________________________________________________________/\\\__/\\\_      
//     __/\\\______________/\\/\\\\\\\___/\\\\\\\\\_____/\\\\\\\\\\\___\//\\\/\\\__     
//      _\/\\\_____________\/\\\/////\\\_\////////\\\___\///////\\\/_____\//\\\\\___    
//       _\//\\\____________\/\\\___\///____/\\\\\\\\\\_______/\\\/________\//\\\____   
//        __\///\\\__________\/\\\__________/\\\/////\\\_____/\\\/_______/\\_/\\\_____  
//         ____\////\\\\\\\\\_\/\\\_________\//\\\\\\\\/\\__/\\\\\\\\\\\_\//\\\\/______ 
//          _______\/////////__\///___________\////////\//__\///////////___\////________

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include plugins\_common;

Firstblood(attacker)
{	
	if(isDefined(level.firstblood) && level.firstblood)
	{
		if(isplayer(attacker))
		{
			level thread plugins\notification::modNotify(attacker,"First Blood");
		}
		level.firstblood = undefined;
	}
}


FirstbloodCard(attacker)
{
	level.FirstbloodNotify = [];

	level thread playSoundOnAllPlayers("mp_firstblood");

	level.FirstbloodNotify[0] = newHudElem();
	level.FirstbloodNotify[0].x = -150;
	level.FirstbloodNotify[0].y = 125;
	level.FirstbloodNotify[0].alignX = "left";
	level.FirstbloodNotify[0].horzAlign = "left";
	level.FirstbloodNotify[0].alignY = "top";
	level.FirstbloodNotify[0] setShader( "gradient_top", 150, 25 );
	level.FirstbloodNotify[0].alpha = 0;
	level.FirstbloodNotify[0].sort = 900;
	level.FirstbloodNotify[0].hideWhenInMenu = true;
	level.FirstbloodNotify[0].archived = false;

	level.FirstbloodNotify[1] = newHudElem();
	level.FirstbloodNotify[1].x = -150;
	level.FirstbloodNotify[1].y = 156;
	level.FirstbloodNotify[1].alignX = "left";
	level.FirstbloodNotify[1].horzAlign = "left";
	level.FirstbloodNotify[1].alignY = "top";
	level.FirstbloodNotify[1] setShader( "camo_1", 150, 37 );
	level.FirstbloodNotify[1].alpha = 0;
	level.FirstbloodNotify[1].sort = 901;
	level.FirstbloodNotify[1].hideWhenInMenu = true;
	level.FirstbloodNotify[1].archived = false;

	level.FirstbloodNotify[2] = newHudElem();
	level.FirstbloodNotify[2].x = -150;
	level.FirstbloodNotify[2].y = 130;
	level.FirstbloodNotify[2].alignX = "left";
	level.FirstbloodNotify[2].horzAlign = "left";
	level.FirstbloodNotify[2].alignY = "top";
	level.FirstbloodNotify[2].alpha = 0;
	level.FirstbloodNotify[2] setShader( getIconByTeam(attacker), 50, 50 );
	level.FirstbloodNotify[2].sort = 902;
	level.FirstbloodNotify[2].hideWhenInMenu = true;
	level.FirstbloodNotify[2].archived = false;

	level.FirstbloodNotify[3] = addTextHud( level, -100, 130, 1, "left", "top", undefined, undefined, 1.4, 903 ); 
	level.FirstbloodNotify[3].horzAlign = "left";
	level.FirstbloodNotify[3].alpha = 0;
	level.FirstbloodNotify[3] setText( attacker.name );
	level.FirstbloodNotify[3].color = getColorByTeam(attacker);
	level.FirstbloodNotify[3].hideWhenInMenu = true;
	level.FirstbloodNotify[3].archived = false;

	level.FirstbloodNotify[4] = addTextHud( level, -100, 145, 1, "left", "top", undefined, undefined, 1.4, 904 );
	level.FirstbloodNotify[4].horzAlign = "left";
	level.FirstbloodNotify[4].alpha = 0;
	level.FirstbloodNotify[4] setText("First Blood");
	level.FirstbloodNotify[4].hideWhenInMenu = true;
	level.FirstbloodNotify[4].archived = false;


	for(i = 0 ; i < level.FirstbloodNotify.size && isDefined(level.FirstbloodNotify[i]); i++){
		level.FirstbloodNotify[i] moveOverTime(0.3);
		level.FirstbloodNotify[i] fadeOverTime(0.25);
	}
		
	level.FirstbloodNotify[0].x = 5;
	level.FirstbloodNotify[1].x = 100;
	level.FirstbloodNotify[2].x = 5;
	level.FirstbloodNotify[3].x = 55;
	level.FirstbloodNotify[4].x = 55;

	level.FirstbloodNotify[0].alpha = 0.5;
	level.FirstbloodNotify[1].alpha = 1;
	level.FirstbloodNotify[2].alpha = 1;
	level.FirstbloodNotify[3].alpha = 1;
	level.FirstbloodNotify[4].alpha = 1;

	wait 4;

	for(i=0;i<level.FirstbloodNotify.size;i++){
		level.FirstbloodNotify[i] moveOverTime(0.3);
	}

	level.FirstbloodNotify[0].x = -150;
	level.FirstbloodNotify[1].x = -150;
	level.FirstbloodNotify[2].x = -150;
	level.FirstbloodNotify[3].x = -100;
	level.FirstbloodNotify[4].x = -100;

	wait .05;

	for(i = 0 ; i < level.FirstbloodNotify.size && isDefined(level.FirstbloodNotify[i]); i++){
		level.FirstbloodNotify[i] fadeOverTime(0.25);
	}

	level.FirstbloodNotify[0].alpha = 0;
	level.FirstbloodNotify[1].alpha = 0;
	level.FirstbloodNotify[2].alpha = 0;
	level.FirstbloodNotify[3].alpha = 0;
	level.FirstbloodNotify[4].alpha = 0;

	wait 1;

	for(i=0;i<level.FirstbloodNotify.size;i++)
		level.FirstbloodNotify[i] destroy();

	level.FirstbloodNotify = undefined;
}

getColorByTeam(player)
{
	if(player.team == "allies" || player.team == "axis"){
		color = strTok( getDvar("g_TeamColor_" +player.team), " " );
		return (float(color[0]), float(color[1]), float(color[2]));
	}
}

getIconByTeam(tplayer){
	return "headicon_dead_1";

	if(tplayer.team == "allies"){
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