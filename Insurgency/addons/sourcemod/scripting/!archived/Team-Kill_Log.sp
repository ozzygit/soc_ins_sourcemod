#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

char g_sFilePath[256];

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sFilePath, sizeof(g_sFilePath), "logs/teamkill.log");
	
	if (!DirExists(g_sFilePath))
	{
		CreateDirectory(g_sFilePath, 511);
		
		if (!DirExists(g_sFilePath))
			SetFailState("Failed to create directory at /sourcemod/logs/teamkill - Please manually create that path and reload this plugin.");
	}
	HookEvent("player_death", Event_PlayerDeath);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dB)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("victim"));
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (client > 0 && IsClientInGame(attacker) && IsClientInGame(victim) && !IsFakeClient(client))
	{
		if (GetClientTeam(attacker) == GetClientTeam(victim))
		{
			LogToFile(g_sFilePath, "%N killed %N", attacker, victim);
		}
	}
}