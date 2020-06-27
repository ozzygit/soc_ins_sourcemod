#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#pragma dynamic 131072 
#pragma semicolon 1

public void OnPluginStart()
{
	RegAdminCmd("sm_test_server", Command_Test_Server, ADMFLAG_SLAY, "sm_test_server");
}

public Action Command_Test_Server(int client, int args)
{
	ReplyToCommand(client, "Test Successful!");
	return Plugin_Handled;
}