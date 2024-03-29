/* put the line below after all of the includes!
#pragma newdecls required
*/

/**
 *	[INS] RoundEndBlock Script - Prevent round end.
 *	
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"
#define PLUGIN_DESCRIPTION "Prevent round end."

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <insurgencydy>
#define REQUIRE_EXTENSIONS

// This will be used for checking which team the player is on before repsawning them
#define SPECTATOR_TEAM	0
#define TEAM_SPEC  1
#define TEAM_1_SEC 2
#define TEAM_2_INS 3

enum FX
{
	FxNone = 0,
	FxPulseFast,
	FxPulseSlowWide,
	FxPulseFastWide,
	FxFadeSlow,
	FxFadeFast,
	FxSolidSlow,
	FxSolidFast,
	FxStrobeSlow,
	FxStrobeFast,
	FxStrobeFaster,
	FxFlickerSlow,
	FxFlickerFast,
	FxNoDissipation,
	FxDistort,               // Distort/scale/translate flicker
	FxHologram,              // kRenderFxDistort + distance fade
	FxExplode,               // Scale up really big!
	FxGlowShell,             // Glowing Shell
	FxClampMinScale,         // Keep this sprite from getting very small (SPRITES only!)
	FxEnvRain,               // for environmental rendermode, make rain
	FxEnvSnow,               //  "        "            "    , make snow
	FxSpotlight,     
	FxRagdoll,
	FxPulseFastWider,
};

enum Render
{
	Normal = 0, 		// src
	TransColor, 		// c*a+dest*(1-a)
	TransTexture,		// src*a+dest*(1-a)
	Glow,				// src*a+dest -- No Z buffer checks -- Fixed size in screen space
	TransAlpha,			// src*srca+dest*(1-srca)
	TransAdd,			// src*a+dest
	Environmental,		// not drawn, used for environmental effects
	TransAddFrameBlend,	// use a fractional frame value to blend between animation frames
	TransAlphaAdd,		// src + dest*(1-a)
	WorldGlow,			// Same as kRenderGlow but not fixed size in screen space
	None,				// Don't render.
};

public Plugin info = {
	name = "RoundEnd Block",
	author = "naong",
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION
};

ConVar sm_roundendblock_enabled = null;
ConVar sm_roundendblock_times = null;
ConVar sm_roundendblock_revive_delay = null;
ConVar sm_roundendblock_reset_each_round = null;
ConVar sm_roundendblock_debug = null;
float g_iRoundEndBlockEnabled;
int g_iRoundEndBlockTimes;
int g_iRoundEndBlockResetRound;
int g_iRoundEndBlockDebug;
int playerPickSquad[MAXPLAYERS + 1];

Handle g_hGameConfig;
Handle g_hPlayerRespawn;
float g_fSpawnPoint[3];
int g_iIsRoundStarted = 0; 	//0 is over, 1 is active
int g_iIsRoundStartedPost = 0; //0 is over, 1 is active
int g_iIsGameEnded = 0;		//0 is not ended, 1 is ended
int g_iRoundStatus = 0;
int g_iRoundBlockCount;
int g_max_AnnounceTime = 480;
int g_announceTick;

// Cvars for caupture point speed
bool g_bIsCounterAttackTimerActive = false;

public void OnPluginStart() 
{
	// cvars
	sm_roundendblock_enabled = CreateConVar("sm_roundendblock_enabled", "1", "Coop bot Enabled", FCVAR_NOTIFY);
	sm_roundendblock_times = CreateConVar("sm_roundendblock_times", "1", "How many times block rounds.");
	sm_roundendblock_revive_delay = CreateConVar("sm_roundendblock_revive_delay", "10", "When blocks RoundEnd, wait for reviving players.");
	sm_roundendblock_reset_each_round = CreateConVar("sm_roundendblock_reset_each_round", "1", "Reset block counter each round. (1 is reset / 0 is don't reset)");
	sm_roundendblock_debug = CreateConVar("sm_roundendblock_debug", "0", "1: Turn on debug mode, 0: Turn off");
	
	// register admin commands

	// hook events
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd_Pre, EventHookMode_Pre);	
	HookEvent("round_end", Event_RoundEnd_Post, EventHookMode_PostNoCopy);	
	HookEvent("game_start", Event_GameStart, EventHookMode_PostNoCopy);
	HookEvent("game_end", Event_GameEnd, EventHookMode_PostNoCopy);
	HookEvent("object_destroyed", Event_ObjectDestroyed_Post, EventHookMode_PostNoCopy);
	HookEvent("controlpoint_captured", Event_ControlPointCaptured_Pre, EventHookMode_Pre);
	HookEvent("controlpoint_captured", Event_ControlPointCaptured_Post, EventHookMode_PostNoCopy);
	HookEvent("player_death", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_pick_squad", Event_PlayerPickSquad_Post, EventHookMode_Post);
	HookEvent("player_connect", Event_PlayerConnect);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	
	// hook variables
	sm_roundendblock_enabled.AddChangeHook(CvarChange);
	sm_roundendblock_times.AddChangeHook(CvarChange);
	sm_roundendblock_reset_each_round.AddChangeHook(CvarChange);
	sm_roundendblock_debug.AddChangeHook(CvarChange);
	sm_roundendblock_revive_delay.AddChangeHook(CvarChange);
	
	// init respawn command
	g_hGameConfig = LoadGameConfigFile("insurgency.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "ForceRespawn");
	g_hPlayerRespawn = EndPrepSDKCall();
	
	// create config file
	AutoExecConfig(true, "plugin.roundendblock");
	
	// init var
	g_iRoundEndBlockEnabled = sm_roundendblock_enabled.FloatValue;
	g_iRoundEndBlockTimes = sm_roundendblock_times.IntValue;
	g_iRoundEndBlockResetRound = sm_roundendblock_reset_each_round.IntValue;
	g_iRoundEndBlockDebug = sm_roundendblock_debug.IntValue;
}

public void OnMapStart()
{	
	g_announceTick = g_max_AnnounceTime;
	CreateTimer(1.0, Timer_AnnounceSaves, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_AnnounceSaves(Handle timer, any data)
{

	g_announceTick--;
	if (g_announceTick <= 0)
	{
		g_announceTick = g_max_AnnounceTime;
	}
}

// When player connected server, intialize variable
public void OnClientPutInServer(int client)
{
		playerPickSquad[client] = 0;
}

public Action Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	playerPickSquad[client] = 0;

}

void CvarChange(ConVar cvar, const char[] oldvalue, const char[] newvalue)
{
	(g_iRoundEndBlockEnabled = sm_roundendblock_enabled.FloatValue);
	(g_iRoundEndBlockTimes = sm_roundendblock_times.IntValue);
	(g_iRoundEndBlockResetRound = sm_roundendblock_reset_each_round.IntValue);
	(g_iRoundEndBlockDebug = sm_roundendblock_debug.IntValue);
}

// When player picked squad, initialize variables
public Action Event_PlayerPickSquad_Post(Event event, const char[] name, bool dontBroadcast)
{

	int client = GetClientOfUserId( GetEventInt( event, "userid" ) );	
	if( client == 0 || !IsClientInGame(client) || IsFakeClient(client))
		return;	

	// Init variable
	playerPickSquad[client] = 1;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	// Reset respawn position
	g_fSpawnPoint[0] = 0.0;
	g_fSpawnPoint[1] = 0.0;
	g_fSpawnPoint[2] = 0.0;
	
	g_iIsRoundStarted = 1;
	g_iIsRoundStartedPost = 0;
	g_iRoundStatus = 0;
	if (g_iRoundEndBlockResetRound == 1)
		g_iRoundBlockCount = g_iRoundEndBlockTimes;
	
	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");

	if (ncp < 6)
	{
		g_iRoundBlockCount -= 1;
		if (g_iRoundBlockCount < 1)
			g_iRoundBlockCount = 1;
	}

	if (g_iRoundEndBlockDebug)
	{
		PrintToServer("[RndEndBlock] Round started.");
	}
	
	int iPreRound = GetConVarInt(FindConVar("mp_timer_preround"));
	CreateTimer(float(iPreRound) , Timer_RoundStartPost);
}
public Action Timer_RoundStartPost(Handle timer)
{
	g_iRoundStatus = 1;
	g_iIsRoundStartedPost = 1;
}
public Action Event_RoundEnd_Pre(Event event, const char[] name, bool dontBroadcast)
{
	// Reset respawn position
	g_fSpawnPoint[0] = 0.0;
	g_fSpawnPoint[1] = 0.0;
	g_fSpawnPoint[2] = 0.0;
	g_iIsRoundStarted = 0;
	g_iIsRoundStartedPost = 0;
	g_iRoundStatus = 0;
}

public Action Event_RoundEnd_Post(Event event, const char[] name, bool dontBroadcast)
{
	// Reset respawn position
	g_fSpawnPoint[0] = 0.0;
	g_fSpawnPoint[1] = 0.0;
	g_fSpawnPoint[2] = 0.0;
	g_iIsRoundStarted = 0;
	g_iIsRoundStartedPost = 0;
	g_iRoundStatus = 0;

	if (g_iRoundEndBlockResetRound == 1)
		g_iRoundBlockCount = g_iRoundEndBlockTimes;
}

public Action Event_GameStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iIsGameEnded = 0;
}

public Action Event_GameEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_iIsGameEnded = 1;
}

public Action Event_ObjectDestroyed_Post(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetEventInt(event, "attacker");

	if (attacker > 0 && IsValidClient(attacker))
	{
		float attackerPos[3];
		GetClientAbsOrigin(attacker, attackerPos);
		g_fSpawnPoint = attackerPos;
	}
	return Plugin_Continue;
}

public Action Event_ControlPointCaptured_Pre(Event event, const char[] name, bool dontBroadcast)
{
	int iTeam = GetEventInt(event, "team");
	
	if ((Ins_InCounterAttack()) && iTeam == 3)
	{
		// Call counter-attack end timer
		if (!g_bIsCounterAttackTimerActive)
		{
			g_bIsCounterAttackTimerActive = true;
			CreateTimer(1.0, Timer_CounterAttackEnd, _, TIMER_REPEAT);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

// When counter-attack end, reset reinforcement time
public Action Timer_CounterAttackEnd(Handle timer)
{
	// If round end, exit
	if (g_iRoundStatus == 0)
	{
		g_bIsCounterAttackTimerActive = false;
		return Plugin_Stop;
	}
	
	// Checkpoint
	// Check counter-attack end
	if (!Ins_InCounterAttack())
	{		
		g_bIsCounterAttackTimerActive = false;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
public Action Event_ControlPointCaptured_Post(Event event, const char[] name, bool dontBroadcast)
{
	char cappers[256];
	GetEventString(event, "cappers", cappers, sizeof(cappers));
	int cappersLength = strlen(cappers);
	for (int i = 0 ; i < cappersLength; i++)
	{
		int clientCapper = cappers[i];
		if(clientCapper > 0 && IsClientInGame(clientCapper) && IsValidClient(clientCapper) && IsPlayerAlive(clientCapper) && !IsFakeClient(clientCapper))
		{
			float capperPos[3];
			GetClientAbsOrigin(clientCapper, capperPos);

			g_fSpawnPoint = capperPos;
			
			if (g_iRoundEndBlockDebug)
			{
				PrintToServer("[RndEndBlock] Spawnpoint updated. (Control point captured)");
			}
			
			break;
		}
	}
	
}

// When player disconnected server, intialize variables
public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && IsClientInGame(client))
	{
	
		playerPickSquad[client] = 0;
	}
	return Plugin_Continue;
}

public Action Event_PlayerDeathPre(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_iRoundEndBlockEnabled == 0)
		return Plugin_Continue;
	int teamSecCount = GetSecTeamBotCount();
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		if (g_iIsRoundStarted == 1 && g_iIsRoundStartedPost == 1 && g_iIsGameEnded == 0)
		{
			int iAlivePlayers = GetAlivePlayers();
			int iAliveAllowed = 50;
			if (teamSecCount <= 2)
				iAliveAllowed = GetRandomInt(1, 2);
			if (teamSecCount > 1 && teamSecCount <= 4)
				iAliveAllowed = GetRandomInt(1, 4);
			else
				iAliveAllowed = GetRandomInt(2, 5);

			//Create buffer for counter attacks
			if (Ins_InCounterAttack())
			{
				if (teamSecCount <= 6)
					iAliveAllowed += GetRandomInt(1, 2);
				if (teamSecCount > 6 && teamSecCount <= 10)
					iAliveAllowed += GetRandomInt(1, 4);
				else
					iAliveAllowed += GetRandomInt(2, 4);
			}

			if (iAlivePlayers < iAliveAllowed && g_iRoundBlockCount > 0)
			{
				g_iRoundBlockCount--;
				RevivePlayers();
			}
			else if (iAlivePlayers == 1)
			{
				RevivePlayers();
			}
		}
	}
	
	return Plugin_Continue;
}

void RevivePlayers()
{
	if (GetRealClientCount() <= 0) return;
	static int iIsReviving = 0;
	
	if (iIsReviving == 1)
		return;
	else
		iIsReviving = 1;
	
	for (int client = 1; client <= MaxClients; client++)
    {
		if (client > 0 && IsClientInGame(client) && !IsFakeClient(client) && !IsPlayerAlive(client))
		{
			int iTeam = GetClientTeam(client);
			if (iTeam == TEAM_1_SEC && playerPickSquad[client] == 1)
			{
				SDKCall(g_hPlayerRespawn, client);
			
				// Get dead body
				int clientRagdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
				//int primaryRemove = 0;
				//int secondaryRemove = 0; 
				//int grenadesRemove = 0;
				//RemoveWeapons(client, primaryRemove, secondaryRemove, grenadesRemove);
				//This timer safely removes client-side ragdoll
				if(clientRagdoll > 0 && IsValidEdict(clientRagdoll) && IsValidEntity(clientRagdoll))
				{
					// Get dead body's entity
					int ref = EntIndexToEntRef(clientRagdoll);
					int entity = EntRefToEntIndex(ref);
					if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
					{
						// Remove dead body's entity
						AcceptEntityInput(entity, "Kill");
						clientRagdoll = INVALID_ENT_REFERENCE;
					}
				}
			}
		}
	}
	iIsReviving = 0;
	if (g_iRoundEndBlockDebug)
	{
		PrintToServer("[RndEndBlock] All players are revived.");
	}
}

stock void GetRemainingLife()
{
	ConVar hCvar = null;
	int iRemainingLife;
	hCvar = FindConVar("sm_remaininglife");
	iRemainingLife = GetConVarInt(hCvar);
	
	return iRemainingLife;
}

stock int GetSecTeamBotCount()
{
	int iTeam, iSecTeamCount;
	for (int client = 1; client <= MaxClients; client++)
    {
		if (client > 0 && IsClientInGame(client) && IsFakeClient(client))
		{
			iTeam = GetClientTeam(client);
			if (iTeam == TEAM_1_SEC)
				iSecTeamCount++;
		}
	}
	return iSecTeamCount;
}

// Get real client count
stock int GetRealClientCount(bool inGameOnly = true)
{
	int clients = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (((inGameOnly)?IsClientInGame(i):IsClientConnected(i)) && !IsFakeClient(i)) 
			clients++;
	}
	return clients;
}

stock int GetAlivePlayers() 
{
	int iCount = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (client > 0 && IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
		{
			iCount++;
		}
	}
	return iCount;
}

/*
//Respawn Script Specific
public void RemoveWeapons(int client, int primaryRemove, int secondaryRemove, int grenadesRemove)
{

	int primaryWeapon = GetPlayerWeaponSlot(client, 0);
	int secondaryWeapon = GetPlayerWeaponSlot(client, 1);
	int playerGrenades = GetPlayerWeaponSlot(client, 3);

	// Check and remove primaryWeapon
	if (primaryWeapon != -1 && IsValidEntity(primaryWeapon) && primaryRemove == 1) // We need to figure out what slots are defined#define Slot_HEgrenade 11, #define Slot_Flashbang 12, #define Slot_Smokegrenade 13
	{
		// Remove primaryWeapon
		char weapon[32];
		GetEntityClassname(primaryWeapon, weapon, sizeof(weapon));
		RemovePlayerItem(client,primaryWeapon);
		AcceptEntityInput(primaryWeapon, "kill");
	}
	// Check and remove secondaryWeapon
	if (secondaryWeapon != -1 && IsValidEntity(secondaryWeapon) && secondaryRemove == 1) // We need to figure out what slots are defined#define Slot_HEgrenade 11, #define Slot_Flashbang 12, #define Slot_Smokegrenade 13
	{
		// Remove primaryWeapon
		char weapon[32];
		GetEntityClassname(secondaryWeapon, weapon, sizeof(weapon));
		RemovePlayerItem(client,secondaryWeapon);
		AcceptEntityInput(secondaryWeapon, "kill");
	}
	// Check and remove grenades
	if (playerGrenades != -1 && IsValidEntity(playerGrenades) && grenadesRemove == 1) // We need to figure out what slots are defined#define Slot_HEgrenade 11, #define Slot_Flashbang 12, #define Slot_Smokegrenade 13
	{
		while (playerGrenades != -1 && IsValidEntity(playerGrenades)) // since we only have 3 slots in current theate
		{
			playerGrenades = GetPlayerWeaponSlot(client, 3);
			if (playerGrenades != -1 && IsValidEntity(playerGrenades)) // We need to figure out what slots are defined#define Slot_HEgrenade 11, #define Slot_Flashbang 12, #define Slot_Smokegrenade 1
			{
				// Remove grenades
				char weapon[32];
				GetEntityClassname(playerGrenades, weapon, sizeof(weapon));
				RemovePlayerItem(client,playerGrenades);
				AcceptEntityInput(playerGrenades, "kill");
				
			}
		}
	}
}*/