init() {
    switch (game["allies"]) {
    case "sas":
        precacheShader("faction_128_sas");
        setdvar("g_TeamIcon_Allies", "faction_128_sas");
        setdvar("g_TeamColor_Allies", "0 0.51 0.56");
        setdvar("g_ScoresColor_Allies", "0 0.51 0.56");
        break;
    default:
        precacheShader("faction_128_usmc");
        setdvar("g_TeamIcon_Allies", "faction_128_usmc");
        setdvar("g_TeamColor_Allies", "0 0.51 0.56");
        setdvar("g_ScoresColor_Allies", "0 0.51 0.56");
        break;
    }
    switch (game["axis"]) {
    case "russian":
        precacheShader("faction_128_ussr");
        setdvar("g_TeamIcon_Axis", "faction_128_ussr");
        setdvar("g_TeamColor_Axis", "0.95 0.14 0.08");
        setdvar("g_ScoresColor_Axis", "0.95 0.14 0.08");
        break;
    default:
        precacheShader("faction_128_arab");
        setdvar("g_TeamIcon_Axis", "faction_128_arab");
        setdvar("g_TeamColor_Axis", "0.95 0.14 0.08");
        setdvar("g_ScoresColor_Axis", "0.95 0.14 0.08");
        break;
    }
    if (game["attackers"] == "allies" && game["defenders"] == "axis") {
        setdvar("g_TeamName_Allies", "Attack");
        setdvar("g_TeamName_Axis", "Defence");
    } else {
        setdvar("g_TeamName_Allies", "Defence");
        setdvar("g_TeamName_Axis", "Attack");
    }
    setdvar("g_ScoresColor_Spectator", "0.36 0.36 0.36");
    setdvar("g_ScoresColor_Free", "0.95 0.56 0");
    setdvar("g_teamColor_MyTeam", "0.09 0.71 0.11");
    setdvar("g_teamColor_EnemyTeam", "0.78 0 0.05");
}