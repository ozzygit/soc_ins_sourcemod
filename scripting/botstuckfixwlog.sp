#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define LOG_FOLDER									"logs"
#define LOG_PREFIX									"botstuckfix_"
#define LOG_EXT										"log"

#define CONVAR_LOG_WARNINGS							6
#define BotStuck_LogFile

// Arrays
char AFKM_LogFile[PLATFORM_MAX_PATH];				// Log File

int g_Delay[MAXPLAYERS + 1] = {-1, ...};

public Plugin myinfo = 
{
	name = "[INS] Bot Stuck Fix", 
	author = "Drixevel", 
	description = "Fix bots being stuck in geometry.", 
	version = "1.0.0", 
	url = "https://drixevel.dev/"
};

public void OnPluginStart()
{
    BuildLogFilePath();
}

// Log Functions
void BuildLogFilePath() // Build Log File System Path
{
	char sLogPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sLogPath, sizeof(sLogPath), LOG_FOLDER);

	if ( !DirExists(sLogPath) ) // Check if SourceMod Log Folder Exists Otherwise Create One
		CreateDirectory(sLogPath, 511);

	char cTime[64];
	FormatTime(cTime, sizeof(cTime), "%Y%m%d");

	char sLogFile[PLATFORM_MAX_PATH];
	sLogFile = BotStuck_LogFile;

	BuildPath(Path_SM, BotStuck_LogFile, sizeof(BotStuck_LogFile), "%s/%s%s.%s", LOG_FOLDER, LOG_PREFIX, cTime, LOG_EXT);

	if (!StrEqual(BotStuck_LogFile, sLogFile))
		LogAction(0, -1, "[Bot Stuck] Log File: %s", BotStuck_LogFile);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || !IsFakeClient(client))
		return Plugin_Continue;
	
	int time = GetTime();
	
	if (g_Delay[client] != -1 && g_Delay[client] > time)
		return Plugin_Continue;
	
	g_Delay[client] = time + 5;
	
	if (IsPlayerStuck(client))
	{
		float origin[3];
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || !IsFakeClient(i) || GetClientTeam(i) != GetClientTeam(client))
				continue;
			
			GetClientAbsOrigin(i, origin);
			TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
			//PrintToChatAll("Teleporting bot %N to bot %N at coordinates %.0f/%.0f/%.0f.", client, i, origin[0], origin[1], origin[2]);
			//PrintToServer("Teleporting bot %N to bot %N at coordinates %.0f/%.0f/%.0f.", client, i, origin[0], origin[1], origin[2]);
            //LogToFile("Teleporting bot %N to bot %N at coordinates %.0f/%.0f/%.0f.");
            LogToFile("Teleporting bot %N to bot %N at coordinates %.0f/%.0f/%.0f.", client, i, origin[0], origin[1], origin[2]);
			break;
		}
	}	
	return Plugin_Continue;
}

bool IsPlayerStuck(int client)
{
	float vecMin[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", vecMin);
	
	float vecMax[3];
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", vecMax);
	
	float vecOrigin[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_SOLID, TraceEntityFilterNone, client);
	return (TR_DidHit());
}

public bool TraceEntityFilterNone(int entity, int contentsMask, any data)
{
	return entity != data;
}

public void OnClientDisconnect_Post(int client)
{
	g_Delay[client] = -1;
}