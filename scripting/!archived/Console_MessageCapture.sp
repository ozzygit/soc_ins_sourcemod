#include <sourcemod>
#include <regex>

ConVar CVAR_AllowBadCount = null

Regex RegexIP = null;
int BadCount[MAXPLAYERS+1];
char GetBadClientKeyWorks[][] = { 
	"CCLCMsg_VoiceData",    
}; 


public Plugin:myinfo = 
{
	name = "Console Message Capture",
	author = "Unknown",
	description = "<- Description ->",
	version = "1.0",
	url = "<- URL ->"
}
public void OnPluginStart()
{
	RegexIP = CompileRegex("\\d+\\.\\d+\\.\\d+\\.\\d+(:\\d+)?");
	CVAR_AllowBadCount = CreateConVar("sm_console_print_badcount", "3", "0 = Disable");
}



public void OnClientConnected(int client)
{
	BadCount[client] = 0;
}

public Action OnServerConsolePrint(const char[] pMessage)
{
	char sIp[32];
	
	if (MatchRegex(RegexIP, pMessage) > 0) {			
		GetRegexSubString(RegexIP, 0, sIp, 32);
	}

	for(int i=0;i<sizeof(GetBadClientKeyWorks);i++){ 
		if (StrContains(pMessage, GetBadClientKeyWorks[i],false) != -1){ 
			FindClientByIP(sIp,i);
		} 
	}
	
	return Plugin_Continue;
	
}

int FindClientByIP(const char[] sIP,int iError = 0)
{
	char TempIPPort[32];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			GetClientIP(i,TempIPPort,32,false);
			if(StrEqual(sIP,TempIPPort,false))
			{	
				char sauthid[64];
				GetClientAuthId(i,AuthId_Engine,sauthid,64);
				BadCount[i]++;
				LogMessage("client %N(%s) IP:%s BadCount:%d BadWordIndex:%d",i,sauthid,TempIPPort,BadCount[i],iError)
				
				if(BadCount[i] >= CVAR_AllowBadCount.IntValue && CVAR_AllowBadCount.IntValue != 0)
				{
					if (!IsClientInKickQueue(i)) {
						KickClient(i, "Voice Error");
					}
				}	
				
				break;
			}
		}
	}
}
