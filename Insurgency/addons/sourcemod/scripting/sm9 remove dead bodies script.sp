#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "0.1"

public Plugin myinfo =  {
    name = "Ragdoll Cleanup", 
    author = "SM9", 
    description = "Removes dead bodies", 
    version = PLUGIN_VERSION, 
};


public void OnPluginStart() {
    HookEvent("player_death", Event_PlayerDeath);
}

public void Event_PlayerDeath(Event evEvent, const char[] szName, bool bDontBroadcast) {
    CreateTimer(1.0, RemoveRagdoll, evEvent.GetInt("userid")); // Remove ragdoll 1sec after death.
}

public Action RemoveRagdoll(Handle hTimer, int iUserId)
{
    int iClient = GetClientOfUserId(iUserId);
    
    if(iClient < 1 || iClient > MaxClients || !IsValidEntity(iClient)) {
        return Plugin_Stop;
    }
    
    int iRagDoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
    
    if(!IsValidEntity(iRagDoll)) {
        return Plugin_Stop;
    }
    
    AcceptEntityInput(iRagDoll, "kill");
    
    return Plugin_Stop;
}