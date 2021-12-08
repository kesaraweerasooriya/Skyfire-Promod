#include maps\mp\gametypes\_hud_util;
init() {
  precacheString( &"PLATFORM_PRESS_TO_SKIP");
  precacheString( &"PLATFORM_PRESS_TO_RESPAWN");
  precacheShader("white");
  level.killcam = maps\mp\gametypes\_tweakables::getTweakableValue("game", "allowkillcam");
  if (level.killcam) setArchive(true);
}
killcam(attackerNum, killcamentity, sWeapon, predelay, offsetTime, respawn, maxtime, perks, attacker) {
  self endon("disconnect");
  self endon("spawned");
  level endon("game_ended");
  if (attackerNum < 0) return;
  if (!respawn) camtime = 5;
  else if (sWeapon == "frag_grenade_mp" || sWeapon == "frag_grenade_short_mp") camtime = 4.5;
  else camtime = 2.5;
  if (isdefined(maxtime)) {
    if (camtime > maxtime) camtime = maxtime;
    if (camtime < 0.05) camtime = 0.05;
  }
  postdelay = 2;
  killcamlength = camtime + postdelay;
  if (isdefined(maxtime) && killcamlength > maxtime) {
    if (maxtime < 2) return;
    if (maxtime - camtime >= 1) postdelay = maxtime - camtime;
    else {
      postdelay = 1;
      camtime = maxtime - 1;
    }
    killcamlength = camtime + postdelay;
  }
  killcamoffset = camtime + predelay;
  self notify("begin_killcam", getTime());
  self.sessionstate = "spectator";
  self.spectatorclient = attackerNum;
  self.killcamentity = killcamentity;
  self.archivetime = killcamoffset;
  self.killcamlength = killcamlength;
  self.psoffsettime = offsetTime;
  self allowSpectateTeam("allies", true);
  self allowSpectateTeam("axis", true);
  self allowSpectateTeam("freelook", true);
  self allowSpectateTeam("none", true);
  wait 0.05;
  if (self.archivetime <= predelay) {
    self.sessionstate = "dead";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    return;
  }
  self.killcam = true;
  if (!isdefined(self.fk_title)) {
    self.fk_title = newClientHudElem(self);
    self.fk_title.archived = false;
    self.fk_title.y = 22;
    self.fk_title.alignX = "center";
    self.fk_title.alignY = "middle";
    self.fk_title.horzAlign = "center";
    self.fk_title.vertAlign = "top";
    self.fk_title.sort = 1;
    self.fk_title.font = "default";
    self.fk_title.fontscale = 2.8;
    self.fk_title.foreground = true;
  }
  self.fk_title setText( "KILLCAM" );
  self.fk_title.alpha = 1;
  
   if (!isdefined(self.kc_skiptext)) {
    self.kc_skiptext = newClientHudElem(self);
    self.kc_skiptext.archived = false;
    self.kc_skiptext.x = 0;
    self.kc_skiptext.alignX = "center";
    self.kc_skiptext.alignY = "bottom";
    self.kc_skiptext.horzAlign = "center_safearea";
    self.kc_skiptext.vertAlign = "bottom";
    self.kc_skiptext.sort = 999;
    self.kc_skiptext.font = "default";
    self.kc_skiptext.foreground = true;
    self.kc_skiptext.y = -34;
    self.kc_skiptext.fontscale = 1.7;

  }
  if (respawn) 
	self.kc_skiptext setText( &"PLATFORM_PRESS_TO_RESPAWN");
  else 
	self.kc_skiptext setText( &"PLATFORM_PRESS_TO_SKIP");

  self.kc_skiptext.alpha = 0.8;
  
  attacker thread plugins\_kdratio::hidehud();
  
  self thread spawnedKillcamCleanup();
  self thread endedKillcamCleanup();
  self thread waitSkipKillcamButton();
  self thread waitKillcamTime();
  self waittill("end_killcam");
  self endKillcam();
  attacker thread plugins\_kdratio::showhud();
  self.sessionstate = "dead";
  self.spectatorclient = -1;
  self.killcamentity = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
}
waitKillcamTime() {
  self endon("disconnect");
  self endon("end_killcam");
  wait(self.killcamlength - 0.05);
  self notify("end_killcam");
}
waitSkipKillcamButton() {
  self endon("disconnect");
  self endon("end_killcam");
  while (self useButtonPressed()) wait 0.05;
  while (!(self useButtonPressed())) wait 0.05;
  self notify("end_killcam");
}
endKillcam() {
  if (isDefined(self.fk_title)) self.fk_title.alpha = 0;
  if (isDefined(self.kc_skiptext)) self.kc_skiptext.alpha = 0;
  self.killcam = undefined;
  self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}
spawnedKillcamCleanup() {
  self endon("end_killcam");
  self endon("disconnect");
  self waittill("spawned");
  self endKillcam();
}
spectatorKillcamCleanup(attacker) {
  self endon("end_killcam");
  self endon("disconnect");
  attacker endon("disconnect");
  attacker waittill("begin_killcam", attackerKcStartTime);
  waitTime = max(0, (attackerKcStartTime - self.deathTime) - 50);
  wait waitTime;
  self endKillcam();
}
endedKillcamCleanup() {
  self endon("end_killcam");
  self endon("disconnect");
  level waittill("game_ended");
  self endKillcam();
}