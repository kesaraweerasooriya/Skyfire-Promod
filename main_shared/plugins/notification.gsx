init(){
	precacheShader("camo_1");
	precacheShader("line_vertical");

	level.notifying = false;
	level.notiQueue = [];
}

modNotify(player, notification){
	if(!level.notifying){
		level thread notification(player, notification);
		return;
	}
	n = level.notiQueue.size;
	level.notiQueue[n][0] = player;
	level.notiQueue[n][1] = notification;
}

notification(player, text){
	level.notifying = true;

	if(!isDefined(player) || !isPlayer(player)){
		level.notifying = false;
		return;
	}

	if(!isDefined(level.notification)){
		level.notification = [];

		level.notification[0] = NewHudElem();
		level.notification[0].x = -577; // -421
		level.notification[0].y = -18;  // -18
		level.notification[0].horzAlign = "center";
		level.notification[0].vertAlign = "middle";
		level.notification[0].alignX = "left";
		level.notification[0].alignY = "top";
		level.notification[0].alpha = 0; //D 0.3
		level.notification[0].sort = 900;
		level.notification[0] setShader( "white", 150, 34 );
		level.notification[0].hidewheninmenu = 1;
		 
		level.notification[1] = NewHudElem();
		level.notification[1].x = -575; //-419
		level.notification[1].y = -16;	//-16
		level.notification[1].horzAlign = "center";
		level.notification[1].vertAlign = "middle";
		level.notification[1].alignX = "left";
		level.notification[1].alignY = "top";
		level.notification[1].alpha = 0; //D 1
		level.notification[1].sort = 901;
		level.notification[1].hidewheninmenu = 1;
		 
		level.notification[2] = NewHudElem();
		level.notification[2].x = -573; //-417
		level.notification[2].y = -14;  //-14
		level.notification[2].horzAlign = "center";
		level.notification[2].vertAlign = "middle";
		level.notification[2].alignX = "left";
		level.notification[2].alignY = "top";
		level.notification[2].alpha = 0; //D 1
		level.notification[2].sort = 903;
		level.notification[2].hidewheninmenu = 1;
		 	 
		level.notification[3] = NewHudElem();
		level.notification[3].x = -540; // -384``
		level.notification[3].y = -9;  //-9
		level.notification[3].horzAlign = "center";
		level.notification[3].vertAlign = "middle";
		level.notification[3].alignX = "left";
		level.notification[3].alignY = "top";
		level.notification[3].color = (1, 1, 1);
		level.notification[3].alpha = 0; //D 1
		level.notification[3].sort = 904;
		level.notification[3].fontScale = 1.4;
		level.notification[3].hidewheninmenu = 1;

		level.notification[4] = NewHudElem();
		level.notification[4].x = -540; //-420
		level.notification[4].y = -9; //21
		level.notification[4].horzAlign = "center";
		level.notification[4].vertAlign = "middle";
		level.notification[4].alignX = "left";
		level.notification[4].alignY = "top";
		level.notification[4].color = (0, 0.042, 1);
		level.notification[4].alpha = 0;  //D 0.6
		level.notification[4].sort = 902;
		//level.notification[4] setShader( "black", 146, 30 );
		level.notification[4].hidewheninmenu = 1;
		 
		level.notification[5] = NewHudElem();
		level.notification[5].x = -576; //-420
		level.notification[5].y = 21; //21
		level.notification[5].horzAlign = "center";
		level.notification[5].vertAlign = "middle";
		level.notification[5].alignX = "left";
		level.notification[5].alignY = "top";
		level.notification[5].color = (1, 1, 1);
		level.notification[5].alpha = 0;  //D 1
		level.notification[5].sort = 900;
		level.notification[5].font = "objective";
		level.notification[5].fontScale = 1.5;
		level.notification[5].hidewheninmenu = 1;
	}

	level.notification[1] setShader( player getPlayerCamo(), 146, 30 );
	level.notification[2] setShader( player getTeamIcon(), 30, 30 );
	level.notification[3] setText( player.name );
	level.notification[4] setShader("black", int(player.name.size * 6.51), 17 );
	level.notification[5] setText( text );

	//FADE IN
	for(i=0; i<level.notification.size; i++){
		level.notification[i] moveOverTime(0.3);
		level.notification[i] fadeOverTime(0.3);		
	}

	for(i=0; i<level.notification.size; i++){
		level.notification[i].x += 156;
	}
	level.notification[0].alpha = 0.4;
	level.notification[1].alpha = 1;
	level.notification[2].alpha = 1;
	level.notification[3].alpha = 1;
	level.notification[4].alpha = 0.4;
	level.notification[5].alpha = 1;

	wait 4;

	//FADE OUT
	for(i=0; i<level.notification.size; i++){
		level.notification[i] moveOverTime(0.3);
		level.notification[i] fadeOverTime(0.3);		
	}

	for(i=0; i<level.notification.size; i++)
		level.notification[i].x -= 156;

	for(i=0; i<level.notification.size; i++)
		level.notification[i].alpha = 0;

	wait 0.4;

	level.notifying = false;
	if ( level.notiQueue.size > 0 )
	{
		nextNotifyData = level.notiQueue[0];
		
		for ( i = 1; i < level.notiQueue.size; i++ )
			level.notiQueue[i-1] = level.notiQueue[i];
		level.notiQueue[i-1] = undefined;
		
		level thread notification(nextNotifyData[0], nextNotifyData[1]);
	}
}

getPlayerCamo(){
	camo = self promod\client::get_config("PLAYER_CAMO");

	return "camo_1";
}

getTeamIcon(){
	if(self.team == "allies"){
		if(game["allies"]=="sas")
			return "faction_128_sas";
		else
			return "faction_128_usmc";
	}
	else if(self.team == "axis"){
		if(game["axis"]=="opfor" || game["axis"]=="arab")
			return "faction_128_arab";
		else
			return "faction_128_ussr";			
	}
	else
		return "faction_128_ussr";
}

getNameSize(name){
	
}