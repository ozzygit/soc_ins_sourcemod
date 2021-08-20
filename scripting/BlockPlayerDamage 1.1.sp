 /*
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

#include <sourcemod>
#include <sdkhooks>
#include <insurgencydy>
#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME "[INS] Block player damage"
#define PLUGIN_AUTHOR "[SOC]Ozzy"
#define PLUGIN_DESCRIPTION "Block damage when a player throws/detonates an explosive device or falls from roof. May work with other games."
#define PLUGIN_VERSION "1.1"

/*
CREDITS: 
	Taken from https://forums.alliedmods.net/archive/index.php/t-248095.html and https://forums.alliedmods.net/showthread.php?p=2316188
 	JoinedSenses and backwards for cleaning up and fixing code
	Bot Chris for his input
*/

// This will be used for checking which team the player is on before repsawning them
// This will be used for checking which team the player is on before repsawning them
#define SPECTATOR_TEAM	0
#define TEAM_SPEC 	1
#define TEAM_1_SEC	2
#define TEAM_2_INS	3
#define DMG_BURN    (1 << 3)						// heat burned
#define DMG_FALL    (1 << 5)						// fell too far
#define DMG_BLAST   (1 << 6)  						// explosive blast damage
#define DMG_PREVENT_PHYSICS_FORCE	(1 << 11)		// Prevent a physics force

public Plugin myinfo =
{
	name            = PLUGIN_NAME,
	author          = PLUGIN_AUTHOR,
	description     = PLUGIN_DESCRIPTION,
	version         = PLUGIN_VERSION,
};

public void OnPluginStart()
{ 
	AddNormalSoundHook(SoundHook);

	for(int i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);   
}

public Action SoundHook(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) 
{
	if(StrContains(sound, "player/damage", false) >= 0)
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype) 
{

	if (GetClientTeam(client) != TEAM_1_SEC) 
	{
        return Plugin_Continue;
    }
	
	//if player throws an explosive or burn device or falls from a building it will do 0 dmg
	//if ((damagetype & DMG_FALL || damagetype & DMG_BURN || damagetype & DMG_BLAST) && GetClientTeam(client) == TEAM_1_SEC) // changed by backwards // before maxclients
	/*if ((damagetype & DMG_FALL || damagetype & DMG_BURN || damagetype & DMG_BLAST) && GetClientTeam(client) == TEAM_1_SEC)
	{
		damage = 0.0;
		return Plugin_Changed;
	}*/

	//if ((IsValidClient(client) && GetClientTeam(client) == TEAM_1_SEC && (damagetype & (DMG_BURN|DMG_BLAST))) || damagetype & DMG_FALL) 
	if ((IsValidClient(attacker) && GetClientTeam(attacker) == TEAM_1_SEC && (damagetype & (DMG_BURN|DMG_BLAST))) || damagetype & DMG_FALL || damagetype & DMG_PREVENT_PHYSICS_FORCE) 
	{
        damage = 0.0;
        return Plugin_Changed;
	}
	
	return Plugin_Continue;
}