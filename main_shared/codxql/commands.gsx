#include codxql\common;

init(){
	level initCommands();
	level loadCommands();
}

initCommands(){
	if(!isDefined(level.cmdList))
		level.cmdList = [];

	reg = level.vars["player_min_power"];

	//level.cmdlist[<command Name>] = <minimum power>;

	level.cmdList["xlrstats"] 		= reg;
	level.cmdList["aliases"] 		= 20;
	level.cmdList["xlrtoplist"] 	= 1;
	level.cmdList["sayxlrtoplist"]	= 10;
	level.cmdList["lockign"]		= reg;
	level.cmdList["myid"]			= reg;
	level.cmdList["playerinfo"]		= 70;
	level.cmdList["cban"]			= 70;
	level.cmdList["ctempban"]		= 70;
	level.cmdList["iban"]			= 80;
	level.cmdList["itempban"]		= 80;
	level.cmdList["banlist"]		= 80;
	level.cmdList["cunban"]			= 80;
}

loadCommands(){
	keys = getArrayKeys(level.cmdList);
	for(i=0; i < keys.size; i++)
		addScriptCommand(keys[i], 1);
}

Callback_ScriptCommand(command, arguments){
	waittillframeend;
	cmd = toLower(command);

	if(self != level){
		if(!self hasPower(cmd)){
			if(level.cmdList[cmd] == level.vars["player_min_power"])
				self chattell("^1You need to Register to invoke this command. Use ^2!register^1 command");
			else
				self chattell("^1You don't have sufficiant permission to invoke this command.");

			return;
		}

		if(hasStrValue(arguments)){

		}

		switch(cmd){
			case "register":
				self codxql\cmd::registerXLR(self);
				break;

			case "xlrstats":
				if(hasStrValue(arg)){
					player = getPlayerByName(arg);
					if(!self getPlayerVali(player))
						return;

					self codxql\cmd::getAliases(player);
				}
				else
					self codxql\cmd::getxlr(self);

				break;

			case "aliases":	
				if(hasStrValue(arg)){
					player = getPlayerByName(arg);
					if(!self getPlayerVali(player))
						return;

					self codxql\cmd::getAliases(player);
				}
				else
					self codxql\cmd::getAliases(self);

				break;

			case "xlrtoplist":
				self codxql\cmd::getTopList(arg);
				break;

			case "lockign":
				self codxql\cmd::lockIGN(self);
				break;

			case "myid":
				self codxql\cmd::showXlrID();
				break;

			case "playerinfo":
				if(hasStrValue(arg)){
					player = getPlayerByName(arg);
					if(!self getPlayerVali(player))
						return;

					self codxql\cmd::getPlayerInfo(player);				
				}
				else
					self codxql\cmd::getPlayerInfo(self);
				break;

			case "cban":
				if(hasStrValue(arg)){
					args = strTokTill(arg, " ", 1);
					cheater = getPlayerByName(args[0]);
					if(!self getPlayerVali(cheater))
						return;

					codxql\cmd::cmdBan("client", self, cheater, args[1]);			
				}
				else
					self sayNeedInput("cban","cheater Name/match ID","reason");
				break;

			case "ctempban":
				if(hasStrValue(arg)){
					args = strTokTill(arg, " ", 2);
					cheater = getPlayerByName(args[0]);
					if(!self getPlayerVali(cheater))
						return;

					codxql\cmd::cmdTempBan("client", self, cheater, args[1], args[2]);			
				}
				else
					self sayNeedInput("ctempban","cheater Name/match ID","duration","reason");
				break;

			case "iban":
				if(hasStrValue(arg)){
					args = strTokTill(arg, " ", 1);
					cheater = getPlayerByName(args[0]);
					if(!self getPlayerVali(cheater))
						return;

					codxql\cmd::cmdBan("id", self, cheater, args[1]);			
				}
				else
					self sayNeedInput("iban","codxql ID","reason");
				break;

			case "itempban":
				if(hasStrValue(arg)){
					args = strTokTill(arg, " ", 2);
					cheater = getPlayerByName(args[0]);
					if(!self getPlayerVali(cheater))
						return;

					codxql\cmd::cmdTempBan("id", self, cheater, args[1], args[2]);			
				}
				else
					self sayNeedInput("itempban","codxql ID","duration","reason");
				break;

			case "banlist":
				self codxql\cmd::getBansList();
				break;

			case "cunban":
				if(hasStrValue(arg))
					self codxql\cmd::cmdUnban(arg);
				else
					self sayNeedInput("cunban","Ban ID");

				break;
		}
	}
}

sayNeedInput(cmd, arg, arg2, arg3, arg4){
	argStr = "";
	if(hasStrValue(arg))
		argStr += "<"+arg+"> ";
	if(hasStrValue(arg2))
		argStr += "<"+arg2+"> ";
	if(hasStrValue(arg3))
		argStr += "<"+arg3+"> ";
	if(hasStrValue(arg4))
		argStr += "<"+arg4+"> ";

	self chattell("Usage: !"+cmd+" "+argStr);
}