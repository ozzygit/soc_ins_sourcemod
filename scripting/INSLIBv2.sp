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

/*

This is a reworked version of the INS Insurgency Support Library originally developed by JBallou
and then maintained by Daimyo81. That version had numerous bugs and so a new version was developed.
Some features of the Sernix plugin may not work, this was developed primarily for medics and respawn.
The stats and/or web features are untested and may not work.
For best effort support, feedback etc, reach out to Ozzy or Bot Chris at the SOC Gaming discord - https://discord.gg/3BbGmZR
Ozzy Github - https://github.com/ozzygit/Insurgency_Sourcemod
*/

#define PLUGIN_LOG_PREFIX "INSLIB"
#include <insurgencydy>
#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_NAME "[INS] Insurgency Support Library v2"
#define PLUGIN_AUTHOR "Bot Chris and [SOC] Ozzy. New Syntax by clug"
#define PLUGIN_DESCRIPTION "Insurgency support library required for some custom plugins.  Credits to JBallou and Daimyo81 for previous similar version."
#define PLUGIN_VERSION "2.0"
#define PLUGIN_WORKING "1"


public Plugin myinfo =
{
	name            = PLUGIN_NAME,
	author          = PLUGIN_AUTHOR,
	description     = PLUGIN_DESCRIPTION,
	version         = PLUGIN_VERSION,
};

Handle hGameConf = null;
int g_iObjResEntity;
char g_iObjResEntityNetClass[32];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Ins_GetWeaponGetMaxClip1", Native_Weapon_GetMaxClip1);
	CreateNative("Ins_GetMaxClip1", Native_Weapon_GetMaxClip1);
	CreateNative("Ins_ObjectiveResource_GetProp", Native_ObjectiveResource_GetProp);
	CreateNative("Ins_ObjectiveResource_GetPropVector", Native_ObjectiveResource_GetPropVector);
	CreateNative("Ins_InCounterAttack", Native_InCounterAttack);
	return APLRes_Success;
}

public void OnPluginStart()
{
	hGameConf = LoadGameConfigFile("insurgency.games");
}

public int Native_ObjectiveResource_GetProp(Handle plugin, int numParams)
{
	int len;
	GetNativeStringLength(1, len);
	if (len <= 0) {
        return false;
	}

	char[] prop = new char[len+1];
	GetNativeString(1, prop, len+1);

	int size = GetNativeCell(2);
	int element = GetNativeCell(3);
	GetEntity_ObjectiveResource();

	int retval = -1;
	if (g_iObjResEntity > 0) {
		retval = GetEntData(g_iObjResEntity, FindSendPropInfo(g_iObjResEntityNetClass, prop) + (size * element));
	}

	return retval;
}

public int Native_ObjectiveResource_GetPropVector(Handle plugin, int numParams)
{
	int len;
	GetNativeStringLength(1, len);
	if (len <= 0) {
        return false;
	}

	char[] prop = new char[len + 1];
	int size = 12; // Size of data slice - 3x4-byte floats
	GetNativeString(1, prop, len + 1);

	int element = GetNativeCell(3);
	GetEntity_ObjectiveResource();

	float result[3];
	if (g_iObjResEntity > 0) {
		GetEntDataVector(g_iObjResEntity, FindSendPropInfo(g_iObjResEntityNetClass, prop) + (size * element), result);
		SetNativeArray(2, result, 3);
	}

	return 1;
}

int GetEntity_ObjectiveResource(int always=0)
{
	if ((g_iObjResEntity < 1 || ! IsValidEntity(g_iObjResEntity)) || always)
	{
		g_iObjResEntity = FindEntityByClassname(0,"ins_objective_resource");
		GetEntityNetClass(g_iObjResEntity, g_iObjResEntityNetClass, sizeof(g_iObjResEntityNetClass));
		InsLog(DEBUG,"g_iObjResEntityNetClass %s",g_iObjResEntityNetClass);
	}

	if (g_iObjResEntity) {
		return g_iObjResEntity;
    }

	InsLog(WARN,"GetEntity_ObjectiveResource failed!");

	return -1;
}

bool InCounterAttack()
{
	return view_as<bool>(GameRules_GetProp("m_bCounterAttack"));
}

public int Native_InCounterAttack(Handle plugin, int numParams)
{
	return InCounterAttack();
}

public int Native_Weapon_GetMaxClip1(Handle plugin, int numParams)
{
	Handle weapon = GetNativeCell(1);
	return Weapon_GetMaxClip1(weapon);
}

public int Weapon_GetMaxClip1(Handle weapon)
{
	StartPrepSDKCall(SDKCall_Entity);
	if(! PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "GetMaxClip1")) {
		SetFailState("PrepSDKCall_SetFromConf GetMaxClip1 failed");
	}

	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	Handle hCall = EndPrepSDKCall();
	int value = SDKCall(hCall, weapon);
	CloseHandle(hCall);

	return value;
}