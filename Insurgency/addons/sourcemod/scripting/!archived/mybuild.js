#pragma semicolon 1

#include <clientprefs>
#include <sourcemod>
#include <sdktools>
#include <build>
#include <build_stocks>
#include <vphysics>

#define DEBUG 0
#define MSGTAG "\x05SaveSystem\x01:"

new bool:g_bClientLang[MAXPLAYERS];
new Handle:g_hCookieClientLang;

new Handle:g_hFile[MAXPLAYERS];
new String:g_szFileName[128][MAXPLAYERS];
new String:g_szListName[128];

new bool:g_bListExist = true;
new bool:g_bIsRunning[MAXPLAYERS] = false;
new g_iCount[MAXPLAYERS];
new g_iError[MAXPLAYERS];
new g_iTryCount[MAXPLAYERS];

new Symbol[] = {
    '    ',
    '\\',
    '/',
    ' ',
    '~',
    '`',
    '?',
    '!',
    '@',
    '#',
    '$',
    '%',
    '^',
    '&',
    '*',
    '|',
    ':',
    ';',
    ',',
    '.',
    '<',
    '>',
    '(',
    ')',
    '{',
    '}',
    '[',
    ']'
};

public Plugin:myinfo = {
    name = "[BuildMod] - SaveSystem",
    author = "[BuildMod]",
    version = BUILDMOD_VER
};

public OnPluginStart() {
    RegAdminCmd("sm_ss", Command_SaveSystem, ADMFLAG_CUSTOM1, "Save system ftw.");
    g_hCookieClientLang = RegClientCookie("cookie_BuildModClientLang", "BuildMod Client Language.", CookieAccess_Private);
    BuildPath(Path_SM, g_szListName, sizeof(g_szListName), "data/BuildModSave/list.txt");
    if (!FileExists(g_szListName)) {
        g_bListExist = false;
        LogError("list.txt is not exist!");
    }
}

public Action:OnClientCommand(Client, args) {
    if (Client > 0) {
        if (Build_IsClientValid(Client, Client)) {
            new String:Lang[8];
            GetClientCookie(Client, g_hCookieClientLang, Lang, sizeof(Lang));
            if (StrEqual(Lang, "1"))
                g_bClientLang[Client] = true;
            else
                g_bClientLang[Client] = false;
        }
    }
}

public Action:Command_SaveSystem(Client, args) {
    if (!g_bListExist) {
        LogError("list.txt is not exist!");
        if (g_bClientLang[Client]) {
            Build_PrintToChat(Client, "錯誤: 0x00005E");
            Build_PrintToChat(Client, "請通知管理員解決問題");
        } else {
            Build_PrintToChat(Client, "Error: 0x00005E");
            Build_PrintToChat(Client, "Please notify the admin");
        }
        return Plugin_Handled;
    }
    
    if (g_bIsRunning[Client]) {
        if (g_bClientLang[Client])
            Build_PrintToChat(Client, "%s 程序已經在執行中. 請稍後...", MSGTAG);
        else
            Build_PrintToChat(Client, "%s Process is already running. Please Wait...", MSGTAG);
        return Plugin_Handled;
    }
    if (!Build_AllowToUse(Client) || Build_IsBlacklisted(Client) && Build_IsClientValid(Client, Client))
        return Plugin_Handled;
    
    new String:szMode[16], String:szSaveName[32], String:szSteamID[32];
    GetCmdArg(1, szMode, sizeof(szMode));
    GetCmdArg(2, szSaveName, sizeof(szSaveName));
    GetClientAuthString(Client, szSteamID, sizeof(szSteamID));
    ReplaceString(szSteamID, sizeof(szSteamID), ":", "-");
    ReplaceString(szSteamID, sizeof(szSteamID), "STEAM_", "");
    g_szFileName[Client] = "";
    BuildPath(Path_SM, g_szFileName[Client], sizeof(g_szFileName), "data/BuildModSave/%s@%s", szSteamID, szSaveName);
    g_hFile[Client] = INVALID_HANDLE;
    g_iTryCount[Client] = 0;
    g_iCount[Client] = 0;
    g_iError[Client] = 0;
    
    if ((StrEqual(szMode, "save") || StrEqual(szMode, "load") || StrEqual(szMode, "delete")) && args > 1) {
        if (!Save_CheckSaveName(Client, szSaveName))
            return Plugin_Handled;
            
        if (StrEqual(szMode, "save")) {
            if (FileExists(g_szFileName[Client])) {
                if (g_bClientLang[Client])
                    Build_PrintToChat(Client, "%s 該存檔已存在. 取代中...", MSGTAG);
                else
                    Build_PrintToChat(Client, "%s The save already exists. Replacing old save...", MSGTAG);
                    
                if (!DeleteFile(g_szFileName[Client])) {
                    if (g_bClientLang[Client])
                        Build_PrintToChat(Client, "%s 取代檔案失敗! 存檔程序放棄!", MSGTAG);
                    else
                        Build_PrintToChat(Client, "%s Replace failed! Save process abort!", MSGTAG);
                    return Plugin_Handled;
                }
            }
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 開始儲存. 請稍後...", MSGTAG);
            else
                Build_PrintToChat(Client, "%s Saving the content. Please Wait...", MSGTAG);
            g_bIsRunning[Client] = true;
            
            new Handle:hSavePack;
            CreateDataTimer(0.001, Timer_Save, hSavePack);
            WritePackCell(hSavePack, Client);
            WritePackString(hSavePack, szMode);
            WritePackString(hSavePack, szSaveName);
            WritePackString(hSavePack, szSteamID);
            return Plugin_Handled;
        } else if (StrEqual(szMode, "load")) {
            if (!FileExists(g_szFileName[Client])) {
                if (g_bClientLang[Client])
                    Build_PrintToChat(Client, "%s 該存檔不存在.", MSGTAG);
                else
                    Build_PrintToChat(Client, "%s The save does not exist.", MSGTAG);
            } else {
                if (g_bClientLang[Client])
                    Build_PrintToChat(Client, "%s 開始讀取. 請稍後...", MSGTAG);
                else
                    Build_PrintToChat(Client, "%s Loading the content. Please Wait...", MSGTAG);
                g_bIsRunning[Client] = true;
                
                new Handle:hLoadPack;
                CreateDataTimer(0.01, Timer_Load, hLoadPack);
                WritePackCell(hLoadPack, Client);
                WritePackString(hLoadPack, szSteamID);
            }
            return Plugin_Handled;
        } else if (StrEqual(szMode, "delete")) {
            if (FileExists(g_szFileName[Client])) {
                if (DeleteFile(g_szFileName[Client])) {
                    if (g_bClientLang[Client])
                        Build_PrintToChat(Client, "%s 存檔刪除成功.", MSGTAG);
                    else
                        Build_PrintToChat(Client, "%s Delete save successfully.", MSGTAG);
                    CheckSaveList(Client, szMode, szSaveName, szSteamID);
                } else {
                    if (g_bClientLang[Client])
                        Build_PrintToChat(Client, "%s 存檔刪除失敗!", MSGTAG);
                    else
                        Build_PrintToChat(Client, "%s Delete save failed!", MSGTAG);
                }
            } else {
                if (g_bClientLang[Client])
                    Build_PrintToChat(Client, "%s 該存檔不存在.", MSGTAG);
                else
                    Build_PrintToChat(Client, "%s The save does not exist.", MSGTAG);
            }
            return Plugin_Handled;
        }
        return Plugin_Handled;
    } else if (StrEqual(szMode, "list")) {
        new Handle:hListPack;
        CreateDataTimer(0.01, Timer_List, hListPack);
        WritePackCell(hListPack, Client);
        WritePackString(hListPack, szSteamID);
        return Plugin_Handled;
    }
    if (g_bClientLang[Client]) {
        Build_PrintToChat(Client ,"%s 用法:", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss save <存檔名稱>   = 存檔", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss load <存檔名稱>   = 讀取", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss delete <存檔名稱> = 刪除", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss list  = 列出你的存檔清單", MSGTAG);
    } else {
        Build_PrintToChat(Client ,"%s Usage:", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss save <SaveName>", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss load <SaveName>", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss delete <SaveName>", MSGTAG);
        Build_PrintToChat(Client ,"%s !ss list", MSGTAG);
    }
    return Plugin_Handled;
}

public Action:Timer_Save(Handle:Timer, Handle:hDataPack) {
    ResetPack(hDataPack);
    new String:szMode[16], String:szSaveName[32], String:szSteamID[32];
    ResetPack(hDataPack);
    new Client = ReadPackCell(hDataPack);
    ReadPackString(hDataPack, szMode, sizeof(szMode));
    ReadPackString(hDataPack, szSaveName, sizeof(szSaveName));
    ReadPackString(hDataPack, szSteamID, sizeof(szSteamID));
    
    if (!Build_IsClientValid(Client, Client))
        return;
    
    if (g_hFile[Client] == INVALID_HANDLE) {
        g_hFile[Client] = OpenFile(g_szFileName[Client], "w");
        g_iTryCount[Client]++;
        if (g_iTryCount[Client] < 3) {
            new Handle:hNewPack;
            CreateDataTimer(0.2, Timer_Save, hNewPack);
            WritePackCell(hNewPack, Client);
            WritePackString(hNewPack, szMode);
            WritePackString(hNewPack, szSaveName);
            WritePackString(hNewPack, szSteamID);
        } else {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 無法建立存檔! 程序放棄!", MSGTAG);
            else
                Build_PrintToChat(Client, "%s Unable to create the save! Process abort!", MSGTAG);
            g_hFile[Client] = INVALID_HANDLE;
            g_iTryCount[Client] = 0;
        }
    } else {
        new String:szTime[16], String:szClass[32], String:szModel[128], Float:fOrigin[3], Float:fAngles[3];
        new iOrigin[3], iAngles[3], iHealth, iCount = 0;
        FormatTime(szTime, sizeof(szTime), "%Y/%m/%d");
        WriteFileLine(g_hFile[Client], ";---------- File Create : [%s] ----------||", szTime);
        WriteFileLine(g_hFile[Client], ";---------- BY: %N <%s> ----------||", Client, szSteamID);
        for (new i = 0; i < MAX_HOOK_ENTITIES; i++) {
            if (IsValidEdict(i)) {
                GetEdictClassname(i, szClass, sizeof(szClass));
                if ((StrContains(szClass, "prop_dynamic") >= 0 || StrContains(szClass, "prop_physics") >= 0) && !StrEqual(szClass, "prop_ragdoll") && Build_ReturnEntityOwner(i) == Client) {
                    GetEntPropString(i, Prop_Data, "m_ModelName", szModel, sizeof(szModel));
                    GetEntPropVector(i, Prop_Send, "m_vecOrigin", fOrigin);
                    GetEntPropVector(i, Prop_Data, "m_angRotation", fAngles);
                    for (new j = 0; j < 3; j++) {
                        iOrigin[j] = RoundToNearest(fOrigin[j]);
                        iAngles[j] = RoundToNearest(fAngles[j]);
                    }
                    iHealth = GetEntProp(i, Prop_Data, "m_iHealth", 4);
                    if (iHealth > 100000000)
                        iHealth = 2;
                    else if (iHealth > 0)
                        iHealth = 1;
                    else
                        iHealth = 0;
                    g_iCount[Client]++;
                    WriteFileLine(g_hFile[Client], "ent%i %s %s %i %i %i %i %i %i %i", g_iCount[Client], szClass, szModel, iOrigin[0], iOrigin[1], iOrigin[2], iAngles[0], iAngles[1], iAngles[2], iHealth);
                }
            }
        }
        WriteFileLine(g_hFile[Client], ";---------- File End | %i Props ----------||", iCount);
        
        FlushFile(g_hFile[Client]);
        CloseHandle(g_hFile[Client]);
        g_bIsRunning[Client] = false;
        if (g_iCount[Client] > 0) {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 儲存了 %i 個物件", MSGTAG, g_iCount[Client]);
            else
                Build_PrintToChat(Client, "%s Saved %i prop(s)", MSGTAG, g_iCount[Client]);
            g_iCount[Client] = 0;
            CheckSaveList(Client, szMode, szSaveName, szSteamID);
        } else {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 未儲存任何物件.", MSGTAG);
            else
                Build_PrintToChat(Client, "%s No prop has been saved.", MSGTAG);
            DeleteFile(g_szFileName[Client]);
        }
    }
    return;
}

public Action:Timer_Load(Handle:Timer, Handle:hDataPack) {
    ResetPack(hDataPack);
    new String:szSteamID[32];
    new Client = ReadPackCell(hDataPack);
    ReadPackString(hDataPack, szSteamID, sizeof(szSteamID));
    
    if (!Build_IsClientValid(Client, Client))
        return;
    
    if (g_hFile[Client] == INVALID_HANDLE) {
        g_hFile[Client] = OpenFile(g_szFileName[Client], "r");
        g_iTryCount[Client]++;
        if (g_iTryCount[Client] < 3) {
            new Handle:hNewPack;
            CreateDataTimer(0.2, Timer_Load, hNewPack);
            WritePackCell(hNewPack, Client);
            WritePackString(hNewPack, szSteamID);
        } else {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 無法讀取存檔! 程序放棄!", MSGTAG);
            else
                Build_PrintToChat(Client, "%s Unable to read the save! Process abort!", MSGTAG);
            g_hFile[Client] = INVALID_HANDLE;
            g_iTryCount[Client] = 0;
            return;
        }
    } else {
        new String:szLoadString[255], bool:bRegOwnerError = false;
        if (ReadFileLine(g_hFile[Client], szLoadString, sizeof(szLoadString))) {
            if (StrContains(szLoadString, "ent") != -1) {
                new Obj_LoadEntity = -1, String:szBuffer[10][255], String:szClass[32], String:szModel[128], Float:fOrigin[3], Float:fAngles[3], iHealth;
                ExplodeString(szLoadString, " ", szBuffer, 10, 255);
                Format(szClass, sizeof(szClass), "%s", szBuffer[1]);
                Format(szModel, sizeof(szModel), "%s", szBuffer[2]);
                fOrigin[0] = StringToFloat(szBuffer[3]);
                fOrigin[1] = StringToFloat(szBuffer[4]);
                fOrigin[2] = StringToFloat(szBuffer[5]);
                fAngles[0] = StringToFloat(szBuffer[6]);
                fAngles[1] = StringToFloat(szBuffer[7]);
                fAngles[2] = StringToFloat(szBuffer[8]);
                iHealth = StringToInt(szBuffer[9]);
                if (iHealth == 2)
                    iHealth = 999999999;
                if (iHealth == 1)
                    iHealth = 50;
                if (StrContains(szClass, "prop_dynamic") >= 0) {
                    Obj_LoadEntity = CreateEntityByName("prop_dynamic_override");
                    SetEntProp(Obj_LoadEntity, Prop_Send, "m_nSolidType", 6);
                    SetEntProp(Obj_LoadEntity, Prop_Data, "m_nSolidType", 6);
                } else if (StrEqual(szClass, "prop_physics"))
                    Obj_LoadEntity = CreateEntityByName("prop_physics_override");
                else if (StrContains(szClass, "prop_physics") >= 0)
                    Obj_LoadEntity = CreateEntityByName(szClass);
                else
                    g_iError[Client]++;
                
                if (Obj_LoadEntity != -1) {
                    if (Build_RegisterEntityOwner(Obj_LoadEntity, Client)) {
                        if (!IsModelPrecached(szModel))
                            PrecacheModel(szModel);
                        DispatchKeyValue(Obj_LoadEntity, "model", szModel);
                        TeleportEntity(Obj_LoadEntity, fOrigin, fAngles, NULL_VECTOR);
                        DispatchSpawn(Obj_LoadEntity);
                        SetVariantInt(iHealth);
                        AcceptEntityInput(Obj_LoadEntity, "sethealth", -1);
                        AcceptEntityInput(Obj_LoadEntity, "disablemotion", -1);
                        g_iCount[Client]++;
                    } else {
                        RemoveEdict(Obj_LoadEntity);
                        bRegOwnerError = true;
                    }
                }
            }
        }
    }
    if (!IsEndOfFile(g_hFile[Client]) && !bRegOwnerError) {
        new Handle:hNewPack;
        CreateDataTimer(0.05, Timer_Load, hNewPack);
        WritePackCell(hNewPack, Client);
        WritePackString(hNewPack, szSteamID);
    } else {
        CloseHandle(g_hFile[Client]);
        g_bIsRunning[Client] = false;
        if (g_bClientLang[Client])
            Build_PrintToChat(Client, "%s 讀取了 %i 個物件, %i 個物件讀取失敗", MSGTAG, g_iCount[Client], g_iError[Client]);
        else
            Build_PrintToChat(Client, "%s Loaded %i props, failed to load %i props", MSGTAG, g_iCount[Client], g_iError[Client]);
        g_iCount[Client] = 0;
        g_iError[Client] = 0;
    }
    return;
}

public Action:Timer_List(Handle:Timer, Handle:hDataPack) {
    ResetPack(hDataPack);
    new String:szSteamID[32];
    new Client = ReadPackCell(hDataPack);
    ReadPackString(hDataPack, szSteamID, sizeof(szSteamID));
    
    if (!Build_IsClientValid(Client, Client))
        return;
    
    if (g_hFile[Client] == INVALID_HANDLE) {
        g_hFile[Client] = OpenFile(g_szListName, "r");
        g_iTryCount[Client]++;
        if (g_iTryCount[Client] < 3) {
            new Handle:hNewPack;
            CreateDataTimer(0.2, Timer_List, hNewPack);
            WritePackCell(hNewPack, Client);
            WritePackString(hNewPack, szSteamID);
        } else {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 無法列出清單! 程序放棄!", MSGTAG);
            else
                Build_PrintToChat(Client, "%s Unable to list the save! Process abort!", MSGTAG);
            g_hFile[Client] = INVALID_HANDLE;
            g_iTryCount[Client] = 0;
            return;
        }
    } else {
        new String:szListString[255], String:szBuffer[3][128], String:szSaveName[32], String:szTime[16];
        if (g_bClientLang[Client])
            PrintToChat(Client, "|| [存檔名稱] | [存檔日期]");
        else
            PrintToChat(Client, "|| [SaveName] | [Date]");
        
        while (!IsEndOfFile(g_hFile[Client])) {
            if (ReadFileLine(g_hFile[Client], szListString, sizeof(szListString))) {
                if (StrContains(szListString, szSteamID) != -1) {
                    ExplodeString(szListString, " ", szBuffer, 3, 128);
                    Format(szSaveName, sizeof(szSaveName), "%s", szBuffer[1]);
                    Format(szTime, sizeof(szTime), "%s", szBuffer[2]);
                    PrintToChat(Client, "|| %s | %s", szSaveName, szTime);
                    g_iCount[Client]++;
                }
            }
        }
        CloseHandle(g_hFile[Client]);
        g_bIsRunning[Client] = false;
        if (g_iCount[Client] == 0) {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 你沒有任何存檔.", MSGTAG);
            else
                Build_PrintToChat(Client, "%s You don't have any save.", MSGTAG);
        } else {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 你總共有 %i 個存檔.", MSGTAG, g_iCount[Client]);
            else
                Build_PrintToChat(Client, "%s You have %i save(s).", MSGTAG, g_iCount[Client]);
            g_iCount[Client] = 0;
        }
    }
    return;
}

stock Save_CheckSaveName(Client, String:Check[32]) {
    if (strlen(Check) > 32) {
        if (g_bClientLang[Client])
            Build_PrintToChat(Client, "%s 存檔名字數上限是 32 個英文或數字不含中文及特殊符號!", MSGTAG);
        else
            Build_PrintToChat(Client, "%s The max SaveName length is 32 and does not allow symbols!", MSGTAG);
        return false;
    }
        
    for (new i = 0; i < sizeof(Symbol); i++) {
        if (FindCharInString(Check, Symbol[i]) != -1) {
            if (g_bClientLang[Client])
                Build_PrintToChat(Client, "%s 存檔名不可含有特殊符號!", MSGTAG);
            else
                Build_PrintToChat(Client, "%s Symbols is not allowed in SaveName!", MSGTAG);
            return false;
        }
    }
    return true;
}

public CheckSaveList(Client, String:szMode[], String:szSaveName[], String:szSteamID[]) {
    g_hFile[Client] = OpenFile(g_szListName, "a+");
    if (g_hFile[Client] == INVALID_HANDLE)
        return -1;
    if (StrEqual(szMode, "save")) {
        new String:szListString[255], String:szBuffer[3][255];
        while (!IsEndOfFile(g_hFile[Client]))    {
            if (ReadFileLine(g_hFile[Client], szListString, sizeof(szListString))) {
                ExplodeString(szListString, " ", szBuffer, 3, 255);
                if (StrEqual(szSteamID, szBuffer[0]) && StrEqual(szSaveName, szBuffer[1])) {
                    CloseHandle(g_hFile[Client]);
                    return true;
                }
            }
        }
        new String:szTime[64];
        FormatTime(szTime, sizeof(szTime), "%Y/%m/%d");
        WriteFileLine(g_hFile[Client], "%s %s %s \t\t//%N", szSteamID, szSaveName, szTime, Client);
        PrintToConsole(Client, "%s %s %s \t\t//%N", szSteamID, szSaveName, szTime, Client);
        FlushFile(g_hFile[Client]);
        CloseHandle(g_hFile[Client]);
        return false;
    } else if (StrEqual(szMode, "delete")) {
        new String:szArrayString[64][128], String:szArrayBuffer[64][3][128];
        for (new i = 0; i < 64; i++) {
            ReadFileLine(g_hFile[Client], szArrayString[i], sizeof(szArrayString));
            ExplodeString(szArrayString[i], " ", szArrayBuffer[i], 3, sizeof(szArrayBuffer));
            if (StrEqual(szSteamID, szArrayBuffer[i][0]) && StrEqual(szSaveName, szArrayBuffer[i][1]))
                szArrayString[i] = "";
                
            if (IsEndOfFile(g_hFile[Client]))
                break;
        }
        CloseHandle(g_hFile[Client]);
        if (!DeleteFile(g_szListName))
            return -1;
        
        SortStrings(szArrayString, sizeof(szArrayString));
        g_hFile[Client] = OpenFile(g_szListName, "w+");
        for (new i = 0; i < 64; i++) {
            if (StrContains(szArrayString[i], "0-") == 0)
                WriteFileLine(g_hFile[Client], "%s", szArrayString[i]);
        }
        FlushFile(g_hFile[Client]);
        CloseHandle(g_hFile[Client]);
        return true;
    }
    CloseHandle(g_hFile[Client]);
    return -1;
}