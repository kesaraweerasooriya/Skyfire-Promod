#include codxql\common;

//This should be init through <gametype>.gsx
init(){
	level thread initVariables();
	level thread setTables();
}

initModels(){
	//Core model to handel players. Registering and get player data stuff. 
	level thread codxql\player::init();

	//Custom Models. Every custom model should define here.
	// XLR Stats
	if(getDvarInt("plug_xlrRating"))
		level thread codxql\models\xlrstats::init();

	// Player Aliases
	if(getDvarInt("plug_aliases"))
		level thread codxql\models\aliases::init();

	// Player BANS
	if(getDvarInt("plug_banSys"))
		level thread codxql\models\bans::init();
}

//Every variable should be define here.
//They will be created as level.vars[<variable name>]
initVariables(){
	  //Variable Types : string, int, float, bool
	
	  //Syntax
	  //addVar(Var Name,					Var Type, 	Default, 		  Min, 		Max );

		addVar("xlr_playerstatTable", 		"string", 	"xlr_playerstats" 	  );
		addVar("clientsTable", 				"string", 	"clients" 	  		  );
		addVar("aliasesTable", 				"string", 	"aliases" 	  		  );
		addVar("bansTable", 				"string", 	"player_bans" 		  );

		addVar("need_register", 			"bool", 	false 	  		  	  );
		addVar("player_min_power", 			"int", 		5, 					1,		  5 ); //Dont give more than Power 10 for non-admins

		FixPlayerMinPow();

	//Variables for xlr ratings.
	if(getDvarint("plug_xlrRating")){
		addVar("xlr_status", 				"bool", 	false 				  );
		addVar("xlr_debug", 				"bool", 	true 				  );
		addVar("xlr_verbose", 				"bool", 	false 				  );
		addVar("xlr_weapon_fact_conf", 		"string", 	"weaponFactors.ini"   );
		addVar("xlr_verboseFile", 			"string", 	"xlrLog.log" 		  );

		addVar("_minKills", 				"int", 		100, 				0 );
		addVar("_minRounds", 				"int", 		10, 				0 );
		addVar("_maxDays", 					"int", 		14, 				0 );
		addVar("topPlayersCount", 			"int", 		3, 					1 );
		addVar("topListShow_Interval", 		"int", 		5, 					1 );

		addVar("assist_min_dmg", 			"int", 		20, 				0 );
		addVar("action_skilladd", 			"float", 	1.0, 				0 );
		addVar("defaultskill", 				"float", 	1000, 				0 );
		addVar("kill_bonus", 				"float", 	1.5, 				0 );
		addVar("Kswitch_confrontations", 	"int", 		50, 				0 );
		addVar("provisional_ranking", 		"bool", 	true 				  );
		addVar("tk_penalty", 				"float", 	0.1, 				0 );
		addVar("suicide_penalty", 			"float", 	0.05, 				0 );
		addVar("assist_max_time", 			"float", 	10, 				0 );
		addVar("assist_bonus", 				"float", 	0.5, 				0 );
		addVar("kfactor_low", 				"int", 		4, 					0 );
		addVar("kfactor_high", 				"int", 		16, 				0 );
		addVar("min_players", 				"int", 		0, 					0 );
		addVar("auto_correct_ignore_days",	"int", 		60, 				0 );
		addVar("auto_correct", 				"bool", 	true 				  );
		addVar("steepness", 				"int", 		600, 				0 );
	}

	if(getDvarint("plug_aliases")){
		addVar("lokedNamesKick", 			"bool", 	true 				  );		
	}

	if(getDvarint("plug_banSys")){
		addVar("announceBan", 				"bool", 	true 				  );
		addVar("ban_max_days",				"int", 		30, 				1 );
	}	
}

FixPlayerMinPow(){
	if(!level.vars["need_register"])
		level.vars["player_min_power"] = 1;
}

setTables(){
	level.tables = [];
	
	level.tables[level.tables.size] = codxql\player::initStorage;

	if(getDvarInt("plug_xlrRating"))
		level.tables[level.tables.size] = codxql\models\xlrstats::initStorage;

	if(getDvarInt("plug_aliases"))
		level.tables[level.tables.size] = codxql\models\aliases::initStorage;

	if(getDvarInt("plug_banSys"))
		level.tables[level.tables.size] = codxql\models\bans::initStorage;
}

// Function of OpenWarfare
addVar(dvarName, dvarType, dvarDefault, minValue, maxValue)
{
	// Initialize the return value just in case an invalid dvartype is passed
	dvarValue = "";

	// Assign the default value if the dvar is empty
	if(getdvar(dvarName) == "") 
	{
		dvarValue = dvarDefault;
		setDvar(dvarName, dvarValue); // initialize the dvar if it isn't in config file
	} 
	else 
	{
		// If the dvar is not empty then bring the value
		switch(dvarType) 
		{
			case "int":
				dvarValue = getdvarint(dvarName);
				break;
				
			case "float":
				dvarValue = getdvarfloat(dvarName);
				break;
				
			case "string":
				dvarValue = getdvar(dvarName);
				break;

			case "bool":
				if(getDvarint(dvarName) == 1)
					dvarValue = true;
				else
					dvarValue = false;
				break;
		}
	}

	// Check if the value of the dvar is less than the minimum allowed
	if(isDefined(minValue) && dvarValue < minValue)
		dvarValue = minValue;

	// Check if the value of the dvar is less than the maximum allowed
	if(isDefined(maxValue) && dvarValue > maxValue) 
		dvarValue = maxValue;
	
	level.vars[ dvarName ] = dvarValue;
}