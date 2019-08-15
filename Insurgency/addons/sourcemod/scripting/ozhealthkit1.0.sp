 /*
 *	[INS] Healthkit Script
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
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define REQUIRE_EXTENSIONS
#define PLUGIN_DESCRIPTION "Healthkit plugin"
#define PLUGIN_VERSION "2.0"

//LUA Healing define values
#define Healthkit_Timer_Tickrate			0.8		// Basic Sound has 0.8 loop
#define Healthkit_Timer_Timeout				360.0 //6 minutes
#define Healthkit_Radius					350.0
#define Healthkit_Remove_Type				"1"
#define Healthkit_Healing_Per_Tick_Min		1
#define Healthkit_Healing_Per_Tick_Max		3
#define MAX_ENTITIES 2048

float g_fLastHeight[2048] = {0.0, ...};
float g_fTimeCheck[2048] = {0.0, ...};
float g_iTimeCheckHeight[2048] = {0.0, ...};

int g_iBeaconBeam;
int g_iBeaconHalo;

// Plugin info
public Plugin myinfo =
{
	name = "[INS] Healthkit",
	author = "ozzy, original D.Freddo",
	version = PLUGIN_VERSION,
	description = PLUGIN_DESCRIPTION
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "healthkit"))
	{
		Handle hDatapack;
		CreateDataTimer(Healthkit_Timer_Tickrate, Healthkit, hDatapack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(hDatapack, entity);
		WritePackFloat(hDatapack, GetGameTime()+Healthkit_Timer_Timeout);
		g_fLastHeight[entity] = -9999.0;
		g_iTimeCheckHeight[entity] = -9999.0;
		SDKHook(entity, SDKHook_VPhysicsUpdate, HealthkitGroundCheck);
		CreateTimer(0.1, HealthkitGroundCheckTimer, entity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action HealthkitGroundCheckTimer(Handle timer, any entity)
{
	if (entity > MaxClients && IsValidEntity(entity))
	{
		float fGameTime = GetGameTime();
		if (fGameTime-g_fTimeCheck[entity] >= 1.0)
		{
			float fOrigin[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fOrigin);
			int iRoundHeight = RoundFloat(fOrigin[2]);
			if (iRoundHeight == g_iTimeCheckHeight[entity])
			{
				g_fTimeCheck[entity] = GetGameTime();
				SDKUnhook(entity, SDKHook_VPhysicsUpdate, HealthkitGroundCheck);
				SDKHook(entity, SDKHook_VPhysicsUpdate, OnEntityPhysicsUpdate);
			}
		}
	}
}

public Action HealthkitGroundCheck(int entity, int activator, int caller, UseType type, float value) 
{
	float fOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fOrigin);
	float iRoundHeight = (fOrigin[2]);
	if (iRoundHeight != g_iTimeCheckHeight[entity]) 
	{
		g_iTimeCheckHeight[entity] = iRoundHeight;
		g_fTimeCheck[entity] = GetGameTime();
	}
}

public Action OnEntityPhysicsUpdate(int entity, int activator, int caller, UseType type, float value)
{
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, view_as<float> ({0.0, 0.0, 0.0}));
}

public Action Healthkit(Handle timer, Handle hDatapack)
{
	ResetPack(hDatapack);
	int entity = ReadPackCell(hDatapack);
	float fEndTime = ReadPackFloat(hDatapack);
	float fGameTime = GetGameTime();
	if (entity > 0 && IsValidEntity(entity) && fGameTime <= fEndTime)
	{
		float fOrigin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fOrigin);
		if (g_fLastHeight[entity] == -9999.0)
		{
			g_fLastHeight[entity] = 0.0;
		}
		fOrigin[2] += 1.0;
		TE_SetupBeamRingPoint(fOrigin, 15.0, Healthkit_Radius*0.55, g_iBeaconBeam, g_iBeaconHalo, 0, 5, 1.0, 1.0, 2.0, {0, 204, 100, 255},1,0);
		TE_SendToAll();
		fOrigin[2] -= 16.0;
		if (fOrigin[2] != g_fLastHeight[entity])
		{
			g_fLastHeight[entity] = fOrigin[2];
		}
		else
		{
			float fAng[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", fAng);
			if (fAng[1] > 89.0 || fAng[1] < -89.0)
				fAng[1] = 90.0;
			if (fAng[2] > 89.0 || fAng[2] < -89.0)
			{
				fAng[2] = 0.0;
				fOrigin[2] -= 6.0;
				TeleportEntity(entity, fOrigin, fAng, view_as<float>({0.0, 0.0, 0.0}));
				fOrigin[2] += 6.0;
			}
		}
		for (int iPlayer = 1;iPlayer <= MaxClients;iPlayer++)
		{
			if (IsClientInGame(iPlayer) && IsPlayerAlive(iPlayer) && GetClientTeam(iPlayer) == 2)
			{
				float fPlayerOrigin[3];
				GetClientEyePosition(iPlayer, fPlayerOrigin);
				if (GetVectorDistance(fPlayerOrigin, fOrigin) <= Healthkit_Radius)
				{
					DataPack hData = CreateDataPack();
					WritePackCell(hData, entity);
					WritePackCell(hData, iPlayer);
					fOrigin[2] += 32.0;
					Handle trace = TR_TraceRayFilterEx(fPlayerOrigin, fOrigin, MASK_SOLID, RayType_EndPoint, Filter_ClientSelf, hData);
					delete hData;
					if (!TR_DidHit(trace))
					{
						int iMaxHealth = GetEntProp(iPlayer, Prop_Data, "m_iMaxHealth");
						int iHealth = GetEntProp(iPlayer, Prop_Data, "m_iHealth");
						if (iMaxHealth > iHealth)
						{
							iHealth += GetRandomInt(Healthkit_Healing_Per_Tick_Min, Healthkit_Healing_Per_Tick_Max);
							if (iHealth >= iMaxHealth)
							{
								iHealth = iMaxHealth;
								PrintCenterText(iPlayer, "Healed !\n\n \n %d %%\n \n \n \n \n \n \n \n", iMaxHealth);
							}
							else PrintCenterText(iPlayer, "Healing...\n\n \n   %d %%\n \n \n \n \n \n \n \n", iHealth);
							SetEntProp(iPlayer, Prop_Data, "m_iHealth", iHealth);
						}
					}
				}
			}
		}
	}
}

public bool Filter_ClientSelf(int entity, int contentsMask, DataPack dp) 
{
	dp.Reset();
	int client = dp.ReadCell();
	int player = dp.ReadCell();
	return (entity != client && entity != player);
}