#include codxql\common;

//**********************************************************
//Calls the functions which connects with desired callbacks.
//**********************************************************

//Calls every functions for actions like Planting Bomb, Defusing Bomb, Capture Flag etc.
CallBack_OnAction(){

}

//Calls every functions for damage.
CallBack_OnDamage(victim, attacker, idamage, sWeapon, sMeansOfDeath){
	attacker = checkIfPlayer(attacker);

	if(codxql\models\xlrstats::xlrStatus())
		if(isDefined(attacker) && isPlayer(attacker))
			codxql\models\xlrstats::OnDamage(victim, attacker, idamage, sWeapon, sMeansOfDeath);
}

//Calls every functions for kills.
CallBack_OnKill(victim, attacker, sWeapon, sMeansOfDeath){
	attacker = checkIfPlayer(attacker);

	//If attacker isn't a player after the check, it means the attacker is world. So we won't calculate Skill for world kills.
	if(codxql\models\xlrstats::xlrStatus()){	
		if(isDefined(attacker) && isPlayer(attacker)){	
			if(attacker == victim || sMeansOfDeath == "MOD_SUICIDE"){
				codxql\models\xlrstats::OnSuicide(victim);
			}
			else if(victim.team == attacker.team && level.teamBased){
				codxql\models\xlrstats::OnTeamKill(victim, attacker);
			}
			else{
				codxql\models\xlrstats::Onkilled(victim, attacker, sWeapon, sMeansOfDeath);
			}
		}	
	}
}