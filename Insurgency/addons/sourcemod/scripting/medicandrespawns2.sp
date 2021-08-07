//Pragmas
#pragma semicolon 1
#pragma newdecls required
#pragma dynamic 131072

//Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <insurgencydy>

//Defines
#define REVIVE_INDICATOR_RADIUS	100.0
#define TEAM_1_SEC	2
#define TEAM_2_INS	3
#define MAX_OBJECTIVES 13

//ConVars
ConVar sm_respawn_enabled;
ConVar sm_revive_enabled;
ConVar sm_ai_director_setdiff_chance_base;
ConVar sm_respawn_delay_team_ins;
ConVar sm_respawn_delay_team_sec;
ConVar sm_respawn_mode_team_sec;
ConVar sm_respawn_mode_team_ins;
ConVar sm_respawn_wave_int_team_ins;
ConVar sm_respawn_type_team_ins;
ConVar sm_respawn_type_team_sec;
ConVar sm_respawn_lives_team_sec;
ConVar sm_respawn_lives_team_ins;
ConVar sm_respawn_fatal_chance;
ConVar sm_respawn_fatal_head_chance;
ConVar sm_respawn_fatal_limb_dmg;
ConVar sm_respawn_fatal_head_dmg;
ConVar sm_respawn_fatal_burn_dmg;
ConVar sm_respawn_fatal_explosive_dmg;
ConVar sm_respawn_fatal_chest_stomach;
ConVar sm_respawn_counterattack_type;
ConVar sm_respawn_counterattack_vanilla;
ConVar sm_respawn_final_counterattack_type;
ConVar sm_respawn_security_on_counter;
ConVar sm_respawn_counter_chance;
ConVar sm_respawn_min_counter_dur_sec;
ConVar sm_respawn_max_counter_dur_sec;
ConVar sm_respawn_final_counter_dur_sec;
ConVar sm_respawn_dynamic_distance_multiplier;
ConVar sm_respawn_dynamic_spawn_counter_percent;
ConVar sm_respawn_dynamic_spawn_percent;
ConVar sm_respawn_reset_type;
//ConVar sm_respawn_enable_track_ammo;
ConVar sm_respawn_reinforce_time;
ConVar sm_respawn_reinforce_time_subsequent;
ConVar sm_respawn_reinforce_multiplier;
ConVar sm_respawn_reinforce_multiplier_base;
//ConVar sm_respawn_enable_donor_tag;
//ConVar sm_revive_seconds;
ConVar sm_revive_distance_metric;
ConVar sm_heal_cap_for_bonus;
ConVar sm_revive_cap_for_bonus;
ConVar sm_reward_medics_enabled;
ConVar sm_heal_amount_medpack;
ConVar sm_heal_amount_paddles;
ConVar sm_non_medic_heal_amt;
ConVar sm_non_medic_revive_hp;
ConVar sm_medic_minor_revive_hp;
ConVar sm_medic_moderate_revive_hp;
ConVar sm_medic_critical_revive_hp;
ConVar sm_minor_wound_dmg;
ConVar sm_moderate_wound_dmg;
ConVar sm_medic_heal_self_max;
ConVar sm_non_medic_max_heal_other;
ConVar sm_minor_revive_time;
ConVar sm_moderate_revive_time;
ConVar sm_critical_revive_time;
ConVar sm_non_medic_revive_time;
ConVar sm_non_medic_heal_self_max;
//ConVar sm_elite_counter_attacks;
ConVar sm_enable_bonus_lives;
ConVar sm_finale_counter_spec_enabled;
ConVar sm_finale_counter_spec_percent;
//ConVar cvarSpawnMode;
ConVar cvarMinPlayerDistance;
ConVar cvarBackSpawnIncrease;
ConVar cvarSpawnAttackDelay;
ConVar cvarMinObjectiveDistance;
//ConVar cvarMaxObjectiveDistance;
//ConVar cvarMaxObjectiveDistanceNav;
ConVar cvarCanSeeVectorMultiplier;
ConVar cvarMaxPlayerDistance;

//Globals

StringMap hSpawnZone;
StringMapSnapshot hSpawnZoneKeys;

//float g_DeathOrigin[MAXPLAYERS + 1][3];
Handle g_hForceRespawn;
Handle fPointInSpawnZone;
Handle fToggleSpawnZone;
Handle fGetBaseEntity;
int g_counterAttack_min_dur_sec;
int g_counterAttack_max_dur_sec;
int g_iCvar_respawn_reset_type;
float g_respawn_counter_chance;
int g_dynamicSpawnCounter_Perc;
int g_iReinforceTime;
int g_iReinforceTime_AD_Temp;
int g_iReinforceTimeSubsequent_AD_Temp;
int g_iRemaining_lives_team_sec;
int g_iRemaining_lives_team_ins;
int g_iRespawn_lives_team_sec;
int g_iRespawn_lives_team_ins;
int g_iRespawnSeconds;
int g_secWave_Timer;
int g_medicHealSelf_max;
int g_nonMedicHealSelf_max;
int g_nonMedic_maxHealOther;
bool g_botsReady;
bool g_isCheckpoint;
//int	g_bot_attack_aimpenalty_amt_close_mult;
//int	g_bot_attack_aimpenalty_amt_far_mult;
//int	g_coop_delay_penalty_base = 800;
//int	g_isEliteCounter;
int	m_hMyWeapons;
int	m_flNextPrimaryAttack;
int	m_flNextSecondaryAttack;
//float g_bot_attack_aimtolerance_newthreat_amt_mult;
//float g_bot_attackdelay_frac_difficulty_impossible_mult;
//float g_bot_attack_aimpenalty_time_close_mult;
//float g_bot_attack_aimpenalty_time_far_mult;
//float g_bot_aim_aimtracking_base;
//float g_bot_aim_aimtracking_frac_impossible;
//float g_bot_aim_angularvelocity_frac_impossible;
//float g_bot_aim_angularvelocity_frac_sprinting_target;
//float g_bot_aim_attack_aimtolerance_frac_impossible;
int g_iStatRevives[MAXPLAYERS + 1];
int g_iStatHeals[MAXPLAYERS + 1];
int g_iBeaconBeam;
int g_iBeaconHalo;



int g_AIDir_TeamStatus = 50;
int g_AIDir_TeamStatus_min;
int g_AIDir_TeamStatus_max = 100;
int g_AIDir_BotsKilledReq_mult = 4;
int g_AIDir_BotsKilledCount;
int g_AIDir_ChangeCond_Counter;
int g_AIDir_ChangeCond_Min = 60;
int g_AIDir_ChangeCond_Max = 180;
int g_AIDir_AmbushCond_Counter;
int g_AIDir_AmbushCond_Min = 120;
int g_AIDir_AmbushCond_Max = 300;
int g_AIDir_AmbushCond_Rand = 240;
int g_AIDir_AmbushCond_Chance = 10;
int g_AIDir_ChangeCond_Rand = 180;
int g_AIDir_ReinforceTimer_Orig;
bool g_AIDir_BotReinforceTriggered;


bool g_playersReady;
float g_fRespawnPosition[3];
float g_badSpawnPos_Track[MAXPLAYERS + 1][3];
float g_fDeadPosition[MAXPLAYERS + 1][3];
float g_fRagdollPosition[MAXPLAYERS + 1][3];
float g_vecOrigin[MAXPLAYERS + 1][3];
bool g_iEnableRevive;
int g_iRespawnTimeRemaining[MAXPLAYERS + 1];
int g_iReviveRemainingTime[MAXPLAYERS + 1];
int g_iReviveNonMedicRemainingTime[MAXPLAYERS + 1];
int g_iPlayerRespawnTimerActive[MAXPLAYERS + 1];
int g_iSpawnTokens[MAXPLAYERS + 1];
int g_iHurtFatal[MAXPLAYERS + 1];
int g_clientRagdolls[MAXPLAYERS + 1];
int g_iNearestBody[MAXPLAYERS + 1];
int g_iRespawnCount[4];
int g_iPlayerBGroups[MAXPLAYERS + 1];
int g_spawnFrandom[MAXPLAYERS + 1];
//int playerClip[MAXPLAYERS + 1][2];
//int playerAmmo[MAXPLAYERS + 1][4];
float m_vCPPositions[MAX_OBJECTIVES][3];
bool g_isMapInit;
bool g_iRoundStatus;
int g_clientDamageDone[MAXPLAYERS + 1];
int playerPickSquad[MAXPLAYERS + 1];
int g_playerMedicHealsAccumulated[MAXPLAYERS + 1];
int g_playerMedicRevivessAccumulated[MAXPLAYERS + 1];
int g_playerNonMedicHealsAccumulated[MAXPLAYERS + 1];
int g_playerNonMedicRevive[MAXPLAYERS + 1];
int g_playerWoundType[MAXPLAYERS + 1];
int g_playerWoundTime[MAXPLAYERS + 1];
int g_playerActiveWeapon[MAXPLAYERS + 1];
int g_playerFirstJoin[MAXPLAYERS + 1];
bool playerRevived[MAXPLAYERS + 1];
bool playerInRevivedState[MAXPLAYERS + 1];
bool g_preRoundInitial;
char g_client_last_classstring[MAXPLAYERS + 1][64];
char g_client_org_nickname[MAXPLAYERS + 1][64];
ArrayList g_playerArrayList;

//plugin info
public Plugin myinfo =
{
	name = "[INS] Medics and Respawns",
	author = "Jared Ballou, Daimyo, naong, ozzy, rewritten by Drixevel",
	version = "1.0.0",
	description = "A plugin at which involves medical personnel and respawnerations if that's a word.",
	url = ""
};

//plugin start
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("respawn.phrases");
	LoadTranslations("nearest_player.phrases.txt");

	sm_respawn_enabled = CreateConVar("sm_respawn_enabled", "1", "Automatically respawn players when they die; 0 - disabled, 1 - enabled");
	sm_respawn_enabled.AddChangeHook(EnableChanged);
	
	sm_revive_enabled = CreateConVar("sm_revive_enabled", "1", "Reviving enabled from medics?  This creates revivable ragdoll after death; 0 - disabled, 1 - enabled");
	sm_revive_enabled.AddChangeHook(EnableChanged);
	
//	cvarSpawnMode = CreateConVar("sm_botspawns_spawn_mode", "1", "Only normal spawnpoints at the objective, the old way (0), spawn in hiding spots following rules (1)", FCVAR_NOTIFY);
//	cvarSpawnMode.AddChangeHook(CvarChange);
	
	cvarMinPlayerDistance = CreateConVar("sm_botspawns_min_player_distance", "240.0", "Min distance from players to spawn", FCVAR_NOTIFY);
	cvarMinPlayerDistance.AddChangeHook(CvarChange);
	
	cvarMaxPlayerDistance = CreateConVar("sm_botspawns_max_player_distance", "16000.0", "Max distance from players to spawn", FCVAR_NOTIFY);
	cvarMaxPlayerDistance.AddChangeHook(CvarChange);
	
	cvarCanSeeVectorMultiplier = CreateConVar("sm_botpawns_can_see_vect_mult", "1.5", "Divide this with sm_botspawns_max_player_distance to get CanSeeVector allowed distance for bot spawning in LOS", FCVAR_NOTIFY);
	cvarCanSeeVectorMultiplier.AddChangeHook(CvarChange);
	
	cvarMinObjectiveDistance = CreateConVar("sm_botspawns_min_objective_distance", "240", "Min distance from next objective to spawn", FCVAR_NOTIFY);
	cvarMinObjectiveDistance.AddChangeHook(CvarChange);
	
	//cvarMaxObjectiveDistance = CreateConVar("sm_botspawns_max_objective_distance", "12000", "Max distance from next objective to spawn", FCVAR_NOTIFY);
	//cvarMaxObjectiveDistance.AddChangeHook(CvarChange);
	
	//cvarMaxObjectiveDistanceNav = CreateConVar("sm_botspawns_max_objective_distance_nav", "2000", "Max distance from next objective to spawn", FCVAR_NOTIFY);
	//cvarMaxObjectiveDistanceNav.AddChangeHook(CvarChange);
	
	cvarBackSpawnIncrease = CreateConVar("sm_botspawns_backspawn_increase", "1400.0", "Whenever bot spawn on last point, this is added to minimum player respawn distance to avoid spawning too close to player.", FCVAR_NOTIFY);	
	cvarBackSpawnIncrease.AddChangeHook(CvarChange);
	
	cvarSpawnAttackDelay = CreateConVar("sm_botspawns_spawn_attack_delay", "2", "Delay in seconds for spawning bots to wait before firing.", FCVAR_NOTIFY);

	sm_respawn_delay_team_ins = CreateConVar("sm_respawn_delay_team_ins", "1.0", "How many seconds to delay the respawn (bots)", _, true, 0.0);
	sm_respawn_delay_team_ins.AddChangeHook(CvarChange);
	
	sm_respawn_delay_team_sec = CreateConVar("sm_respawn_delay_team_sec", "30.0", "How many seconds to delay the respawn (If not set 'sm_respawn_delay_team_sec_player_count_XX' uses this value)");
	sm_respawn_delay_team_sec.AddChangeHook(CvarChange);
	
	sm_respawn_type_team_sec = CreateConVar("sm_respawn_type_team_sec", "1", "1 - individual lives, 2 - each team gets a pool of lives used by everyone, sm_respawn_lives_team_sec must be > 0");
	sm_respawn_type_team_sec.AddChangeHook(CvarChange);
	
	sm_respawn_type_team_ins = CreateConVar("sm_respawn_type_team_ins", "2", "1 - individual lives, 2 - each team gets a pool of lives used by everyone, sm_respawn_lives_team_ins must be > 0");
	sm_respawn_type_team_ins.AddChangeHook(CvarChange);
	
	sm_respawn_lives_team_sec = CreateConVar("sm_respawn_lives_team_sec", "-1", "Respawn players this many times (-1: Disables player respawn)");
	sm_respawn_lives_team_sec.AddChangeHook(CvarChange);
	
	sm_respawn_lives_team_ins = CreateConVar("sm_respawn_lives_team_ins", "10", "If 'sm_respawn_type_team_ins' set 1, respawn bots this many times. If 'sm_respawn_type_team_ins' set 2, total bot count (If not set 'sm_respawn_lives_team_ins_player_count_XX' uses this value)");
	sm_respawn_lives_team_ins.AddChangeHook(CvarChange);
	
	sm_respawn_fatal_chance = CreateConVar("sm_respawn_fatal_chance", "0.20", "Chance for a kill to be fatal, 0.6 default = 60% chance to be fatal (To disable set 0.0)");
	sm_respawn_fatal_head_chance = CreateConVar("sm_respawn_fatal_head_chance", "0.30", "Chance for a headshot kill to be fatal, 0.6 default = 60% chance to be fatal");
	sm_respawn_fatal_limb_dmg = CreateConVar("sm_respawn_fatal_limb_dmg", "80", "Amount of damage to fatally kill player in limb");
	sm_respawn_fatal_head_dmg = CreateConVar("sm_respawn_fatal_head_dmg", "100", "Amount of damage to fatally kill player in head");
	sm_respawn_fatal_burn_dmg = CreateConVar("sm_respawn_fatal_burn_dmg", "50", "Amount of damage to fatally kill player in burn");
	sm_respawn_fatal_explosive_dmg = CreateConVar("sm_respawn_fatal_explosive_dmg", "200", "Amount of damage to fatally kill player in explosive");
	sm_respawn_fatal_chest_stomach = CreateConVar("sm_respawn_fatal_chest_stomach", "100", "Amount of damage to fatally kill player in chest/stomach");
	
	sm_respawn_counter_chance = CreateConVar("sm_respawn_counter_chance", "0.5", "Percent chance that a counter attack will happen def: 50%");
	sm_respawn_counterattack_type = CreateConVar("sm_respawn_counterattack_type", "2", "Respawn during counterattack? (0: no, 1: yes, 2: infinite)");
	sm_respawn_final_counterattack_type = CreateConVar("sm_respawn_final_counterattack_type", "2", "Respawn during final counterattack? (0: no, 1: yes, 2: infinite)");
	sm_respawn_security_on_counter = CreateConVar("sm_respawn_security_on_counter", "1", "0/1 When a counter attack starts, spawn all dead players and teleport them to point to defend");
	sm_respawn_min_counter_dur_sec = CreateConVar("sm_respawn_min_counter_dur_sec", "66", "Minimum randomized counter attack duration");
	sm_respawn_max_counter_dur_sec = CreateConVar("sm_respawn_max_counter_dur_sec", "126", "Maximum randomized counter attack duration");
	sm_respawn_final_counter_dur_sec = CreateConVar("sm_respawn_final_counter_dur_sec", "180", "Final counter attack duration");
	sm_respawn_counterattack_vanilla = CreateConVar("sm_respawn_counterattack_vanilla", "0", "Use vanilla counter attack mechanics? (0: no, 1: yes)");
	
	sm_respawn_dynamic_distance_multiplier = CreateConVar("sm_respawn_dynamic_distance_multiplier", "2", "This multiplier is used to make bot distance from points on/off counter attacks more dynamic by making distance closer/farther when bots respawn");
	sm_respawn_dynamic_distance_multiplier.AddChangeHook(CvarChange);
	
	sm_respawn_dynamic_spawn_counter_percent = CreateConVar("sm_respawn_dynamic_spawn_counter_percent", "40", "Percent of bots that will spawn farther away on a counter attack (basically their more ideal normal spawns)");
	sm_respawn_dynamic_spawn_counter_percent.AddChangeHook(CvarChange);
	
	sm_respawn_dynamic_spawn_percent = CreateConVar("sm_respawn_dynamic_spawn_percent", "5", "Percent of bots that will spawn farther away NOT on a counter (basically their more ideal normal spawns)");
	sm_respawn_dynamic_spawn_percent.AddChangeHook(CvarChange);
	
	sm_respawn_reset_type = CreateConVar("sm_respawn_reset_type", "0", "Set type of resetting player respawn counts: each round or each objective (0: each round, 1: each objective)");
	sm_respawn_reset_type.AddChangeHook(CvarChange);
	
//	sm_respawn_enable_track_ammo = CreateConVar("sm_respawn_enable_track_ammo", "1", "0/1 Track ammo on death to revive (may be buggy if using a different theatre that modifies ammo)");
	
	sm_respawn_reinforce_time = CreateConVar("sm_respawn_reinforce_time", "200", "When enemy forces are low on lives, how much time til they get reinforcements?");
	sm_respawn_reinforce_time.AddChangeHook(CvarChange);
	
	sm_respawn_reinforce_time_subsequent = CreateConVar("sm_respawn_reinforce_time_subsequent", "140", "When enemy forces are low on lives and already reinforced, how much time til they get reinforcements on subsequent reinforcement?");
	sm_respawn_reinforce_time_subsequent.AddChangeHook(CvarChange);
	
	sm_respawn_reinforce_multiplier = CreateConVar("sm_respawn_reinforce_multiplier", "4", "Division multiplier to determine when to start reinforce timer for bots based on team pool lives left over");
	sm_respawn_reinforce_multiplier.AddChangeHook(CvarChange);
	
	sm_respawn_reinforce_multiplier_base = CreateConVar("sm_respawn_reinforce_multiplier_base", "10", "This is the base int number added to the division multiplier, so (10 * reinforce_mult + base_mult)");
	sm_respawn_reinforce_multiplier_base.AddChangeHook(CvarChange);	
	
//	sm_respawn_enable_donor_tag = CreateConVar("sm_respawn_enable_donor_tag", "1", "If player has an access to reserved slot, add [DONOR] tag.");
	
	//sm_revive_seconds = CreateConVar("sm_revive_seconds", "5", "Time in seconds medic needs to stand over body to revive");
	//sm_revive_seconds.AddChangeHook(CvarChange);
	
	sm_revive_distance_metric = CreateConVar("sm_revive_distance_metric", "1", "Distance metric (0: meters / 1: feet)");
	sm_heal_cap_for_bonus = CreateConVar("sm_heal_cap_for_bonus", "5000", "Amount of health given to other players to gain a life");
	sm_revive_cap_for_bonus = CreateConVar("sm_revive_cap_for_bonus", "50", "Amount of revives before medic gains a life");
	sm_reward_medics_enabled = CreateConVar("sm_reward_medics_enabled", "1", "Enabled rewarding medics with lives? 0 = no, 1 = yes");
	sm_heal_amount_medpack = CreateConVar("sm_heal_amount_medpack", "5", "Heal amount per 0.5 seconds when using medpack");
	sm_heal_amount_medpack.AddChangeHook(CvarChange);
	
	sm_heal_amount_paddles = CreateConVar("sm_heal_amount_paddles", "3", "Heal amount per 0.5 seconds when using paddles");
	sm_non_medic_heal_amt = CreateConVar("sm_non_medic_heal_amt", "2", "Heal amount per 0.5 seconds when non-medic");
	sm_non_medic_heal_amt.AddChangeHook(CvarChange);
	
	sm_non_medic_revive_hp = CreateConVar("sm_non_medic_revive_hp", "10", "Health given to target revive when non-medic reviving");
	sm_non_medic_revive_hp.AddChangeHook(CvarChange);
	
	sm_medic_minor_revive_hp = CreateConVar("sm_medic_minor_revive_hp", "75", "Health given to target revive when medic reviving minor wound");
	sm_medic_minor_revive_hp.AddChangeHook(CvarChange);
	
	sm_medic_moderate_revive_hp = CreateConVar("sm_medic_moderate_revive_hp", "50", "Health given to target revive when medic reviving moderate wound");
	sm_medic_moderate_revive_hp.AddChangeHook(CvarChange);
	
	sm_medic_critical_revive_hp = CreateConVar("sm_medic_critical_revive_hp", "25", "Health given to target revive when medic reviving critical wound");
	sm_medic_critical_revive_hp.AddChangeHook(CvarChange);
	
	sm_minor_wound_dmg = CreateConVar("sm_minor_wound_dmg", "100", "Any amount of damage <= to this is considered a minor wound when killed");
	sm_minor_wound_dmg.AddChangeHook(CvarChange);
	
	sm_moderate_wound_dmg = CreateConVar("sm_moderate_wound_dmg", "200", "Any amount of damage <= to this is considered a minor wound when killed.  Anything greater is CRITICAL");
	sm_moderate_wound_dmg.AddChangeHook(CvarChange);
	
	sm_medic_heal_self_max = CreateConVar("sm_medic_heal_self_max", "75", "Max medic can heal self to with med pack");
	sm_medic_heal_self_max.AddChangeHook(CvarChange);
	
	sm_non_medic_heal_self_max = CreateConVar("sm_non_medic_heal_self_max", "25", "Max non-medic can heal self to with med pack");
	sm_non_medic_heal_self_max.AddChangeHook(CvarChange);
	
	sm_non_medic_max_heal_other = CreateConVar("sm_non_medic_max_heal_other", "25", "Heal amount per 0.5 seconds when using paddles");
	sm_non_medic_max_heal_other.AddChangeHook(CvarChange);
	
	sm_minor_revive_time = CreateConVar("sm_minor_revive_time", "4", "Seconds it takes medic to revive minor wounded");
	sm_minor_revive_time.AddChangeHook(CvarChange);
	
	sm_moderate_revive_time = CreateConVar("sm_moderate_revive_time", "7", "Seconds it takes medic to revive moderate wounded");
	sm_moderate_revive_time.AddChangeHook(CvarChange);
	
	sm_critical_revive_time = CreateConVar("sm_critical_revive_time", "10", "Seconds it takes medic to revive critical wounded");
	sm_critical_revive_time.AddChangeHook(CvarChange);
	
	sm_non_medic_revive_time = CreateConVar("sm_non_medic_revive_time", "30", "Seconds it takes non-medic to revive minor wounded, requires medpack");
	sm_non_medic_revive_time.AddChangeHook(CvarChange);
	
	//sm_elite_counter_attacks = CreateConVar("sm_elite_counter_attacks", "1", "Enable increased bot skills, numbers on counters?");
	//sm_elite_counter_attacks.AddChangeHook(CvarChange);
	
	sm_enable_bonus_lives = CreateConVar("sm_enable_bonus_lives", "1", "Give bonus lives based on X condition? 0|1 ");
	sm_enable_bonus_lives.AddChangeHook(CvarChange);
	
	sm_finale_counter_spec_enabled = CreateConVar("sm_finale_counter_spec_enabled", "0", "Enable specialized finale spawn percent? 1|0");
	sm_finale_counter_spec_enabled.AddChangeHook(CvarChange);
	
	sm_finale_counter_spec_percent = CreateConVar("sm_finale_counter_spec_percent", "40", "What specialized finale counter percent for this map?");
	sm_finale_counter_spec_percent.AddChangeHook(CvarChange);
	
	sm_ai_director_setdiff_chance_base = CreateConVar("sm_ai_director_setdiff_chance_base", "10", "Base AI Director Set Hard Difficulty Chance");
	sm_ai_director_setdiff_chance_base.AddChangeHook(CvarChange);
	
	sm_respawn_mode_team_sec = CreateConVar("sm_respawn_mode_team_sec", "1", "Security: 0 = Individual spawning | 1 = Wave based spawning");
	sm_respawn_mode_team_sec.AddChangeHook(CvarChange);
	
	sm_respawn_mode_team_ins = CreateConVar("sm_respawn_mode_team_ins", "0", "Insurgents: 0 = Individual spawning | 1 = Wave based spawning");
	sm_respawn_mode_team_ins.AddChangeHook(CvarChange);
	
	sm_respawn_wave_int_team_ins = CreateConVar("sm_respawn_wave_int_team_ins", "1", "Time in seconds bots will respawn in waves");
	sm_respawn_wave_int_team_ins.AddChangeHook(CvarChange);
	
	AutoExecConfig(true);
	
	FindConVar("sv_tags").AddChangeHook(TagsChanged);
	g_playerArrayList = new ArrayList();

	RegAdminCmd("sm_respawn", Command_Respawn, ADMFLAG_SLAY, "sm_respawn <#userid|name>");
	RegAdminCmd("sm_respawn_reload", Command_Reload, ADMFLAG_SLAY, "sm_respawn_reload");

	HookEvent("player_spawn", Event_Spawn, EventHookMode_Pre);
	HookEvent("player_spawn", Event_SpawnPost);
	HookEvent("player_hurt", Event_PlayerHurt_Pre, EventHookMode_Pre);
//	HookEvent("player_death", Event_PlayerDeath_Pre, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd_Pre, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_pick_squad", Event_PlayerPickSquad_Post);
	HookEvent("object_destroyed", Event_ObjectDestroyed_Pre, EventHookMode_Pre);
	HookEvent("object_destroyed", Event_ObjectDestroyed_Post);
	HookEvent("controlpoint_captured", Event_ControlPointCaptured_Pre, EventHookMode_Pre);
	HookEvent("controlpoint_captured", Event_ControlPointCaptured_Post);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_connect", Event_PlayerConnect);
	HookEvent("weapon_reload", Event_PlayerReload_Pre, EventHookMode_Pre);

	Handle g_hGameConfig = LoadGameConfigFile("insurgency.games");
	
	if (g_hGameConfig == null)
		SetFailState("Fatal Error: Missing File \"insurgency.games\"!");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "ForceRespawn");
	
	if ((g_hForceRespawn = EndPrepSDKCall()) == null)
		SetFailState("Fatal Error: Unable to find signature for \"ForceRespawn\"!");
		
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CINSSpawnZone::PointInSpawnZone");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, 0, VENCODE_FLAG_COPYBACK);
	
	if ((fPointInSpawnZone = EndPrepSDKCall()) == null)
		SetFailState("Fatal Error: Unable to find CINSSpawnZone::PointInSpawnZone");
		
	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "CINSRules::ToggleSpawnZone");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	
	if ((fToggleSpawnZone = EndPrepSDKCall()) == null)
		SetFailState("Fatal Error: Unable to find CINSRules::ToggleSpawnZone");
		
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Virtual, "CINSSpawnZone::GetBaseEntity");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Plain);
	
	if ((fGetBaseEntity = EndPrepSDKCall()) == null)
		SetFailState("Fatal Error: Unable to find CINSSpawnZone::GetBaseEntity");
	
	delete g_hGameConfig;
	
	if ((m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons")) == -1)	
		SetFailState("Fatal Error: Unable to find property offset \"CBasePlayer::m_hMyWeapons\" !");
	
	if ((m_flNextPrimaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack")) == -1) 
		SetFailState("Fatal Error: Unable to find property offset \"CBaseCombatWeapon::m_flNextPrimaryAttack\" !");
	
	if ((m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack")) == -1) 	
		SetFailState("Fatal Error: Unable to find property offset \"CBaseCombatWeapon::m_flNextSecondaryAttack\" !");
	
	hSpawnZone = new StringMap();
	hSpawnZoneKeys = hSpawnZone.Snapshot();
	BuildSpawnZoneList();
}

void EnableChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	int intNewValue = StringToInt(newValue);
	int intOldValue = StringToInt(oldValue);

	if (intNewValue == 1 && intOldValue == 0)
		TagsCheck("respawntimes");
	else if (intNewValue == 0 && intOldValue == 1)
		TagsCheck("respawntimes", true);
}

void CvarChange(ConVar cvar, const char[] oldvalue, const char[] newvalue)
{
	UpdateRespawnCvars();
}

void UpdateRespawnCvars()
{
	g_respawn_counter_chance = sm_respawn_counter_chance.FloatValue;
	g_counterAttack_min_dur_sec = sm_respawn_min_counter_dur_sec.IntValue;
	g_counterAttack_max_dur_sec = sm_respawn_max_counter_dur_sec.IntValue;

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	if (ncp < 6)
	{
		g_counterAttack_min_dur_sec += GetRandomInt(15, 30);
		g_counterAttack_max_dur_sec += GetRandomInt(6, 12);
		g_respawn_counter_chance += 0.2;
	}
	else if (ncp >= 6 && ncp <= 8)
	{
		g_counterAttack_min_dur_sec += GetRandomInt(10, 20);
		g_counterAttack_max_dur_sec += GetRandomInt(4, 8);
		g_respawn_counter_chance += 0.1;
	}
	
	g_iRespawnCount[2] = sm_respawn_lives_team_sec.IntValue;
	g_iRespawnCount[3] = sm_respawn_lives_team_ins.IntValue;
	
	if (sm_enable_bonus_lives.BoolValue && g_iCvar_respawn_reset_type == 0)
		SecTeamLivesBonus();
	
	g_iCvar_respawn_reset_type = sm_respawn_reset_type.IntValue;

	if (!g_isCheckpoint) 
		g_iCvar_respawn_reset_type = 0;
	
	g_dynamicSpawnCounter_Perc = sm_respawn_dynamic_spawn_counter_percent.IntValue;
	
	g_medicHealSelf_max = sm_medic_heal_self_max.IntValue;
	g_nonMedicHealSelf_max = sm_non_medic_heal_self_max.IntValue;
	g_nonMedic_maxHealOther = sm_non_medic_max_heal_other.IntValue;
	
	g_iRespawnSeconds = -1;
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/medicandrespawns/respawns.cfg");
	
	KeyValues kv = new KeyValues("respawns");
	
	if (kv.ImportFromFile(sPath))
	{
		char sCount[32];
		IntToString(GetTeamSecCount(), sCount, sizeof(sCount));
		g_iRespawnSeconds = kv.GetNum(sCount);
	}
	else
		LogError("Couldn't find: configs/medicandrespawns/respawns.cfg");
	
	delete kv;

	if (g_iRespawnSeconds == -1)
		g_iRespawnSeconds = sm_respawn_delay_team_sec.IntValue;
	
	if (sm_respawn_type_team_sec.IntValue == 2)
		g_iRespawn_lives_team_sec = sm_respawn_lives_team_sec.IntValue;

	else if (sm_respawn_type_team_ins.IntValue == 2)
	{
		g_iRespawn_lives_team_ins = -1;
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "configs/medicandrespawns/bots.cfg");
		
		kv = new KeyValues("bots");
		
		if (kv.ImportFromFile(sPath))
		{
			char sCount[32];
			IntToString(GetTeamSecCount(), sCount, sizeof(sCount));
			g_iRespawn_lives_team_ins = kv.GetNum(sCount);
		}
		else
			LogError("Couldn't find: configs/medicandrespawns/bots.cfg");
		
		delete kv;
		
		if (g_iRespawn_lives_team_ins == -1)
			g_iRespawn_lives_team_ins = sm_respawn_lives_team_ins.IntValue;
	}
}

void TagsChanged(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	if (sm_respawn_enabled.BoolValue) 
		TagsCheck("respawntimes");
	else
		TagsCheck("respawntimes", true);
}

public void OnMapStart()
{	
	ClearArray(g_playerArrayList);
	
	g_iBeaconBeam = PrecacheModel("sprites/laserbeam.vmt");
	g_iBeaconHalo = PrecacheModel("sprites/halo01.vmt");
	
	g_playersReady = false;
	g_botsReady = false;

	CreateTimer(2.0, Timer_MapStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_preRoundInitial = true;
	
	BuildSpawnZoneList();
}

public void OnConfigsExecuted()
{
	ServerCommand("exec betterbots.cfg");
	
	if (sm_respawn_enabled.BoolValue)
		TagsCheck("respawntimes");
	else
		TagsCheck("respawntimes", true);
}

public void OnMapEnd()
{
	ResetSecurityLives();
	ResetInsurgencyLives();
	g_isMapInit = false;
	g_botsReady = false;
	g_iRoundStatus = false;
	g_iEnableRevive = false;
}

/*
public void OnPluginEnd()
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "healthkit")) > MaxClients && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
}
*/

public void OnClientPutInServer(int client)
{
	playerPickSquad[client] = 0;
	g_iHurtFatal[client] = -1;
	g_playerFirstJoin[client] = 1;
	g_iPlayerRespawnTimerActive[client] = 0;

	char sNickname[64];
	Format(sNickname, sizeof(sNickname), "%N", client);
	g_client_org_nickname[client] = sNickname;
}

public Action Timer_MapStart(Handle timer)
{
	if (g_isMapInit)
		return;
	
	g_isMapInit = true;

	//g_AIDir_ReinforceTimer_Orig = FindConVar("sm_respawn_reinforce_time").IntValue;

	g_iReinforceTime = sm_respawn_reinforce_time.IntValue;

	UpdateRespawnCvars();
	
	char sGameMode[32];
	FindConVar("mp_gamemode").GetString(sGameMode, sizeof(sGameMode));
	g_isCheckpoint = StrEqual(sGameMode, "checkpoint");

	g_iEnableRevive = false;
	
	ResetSecurityLives();
	ResetInsurgencyLives();
	
	CreateTimer(1.0, Timer_EnemyReinforce, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(15.0, Timer_Enemies_Remaining, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_ReviveMonitor, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.5, Timer_MedicMonitor, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.1, Timer_NearestBody, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
//	CreateTimer(60.0, Timer_AmbientRadio, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_AIDirector_Main, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

//	g_bot_attack_aimtolerance_newthreat_amt_mult = 0.8;
//	g_bot_attack_aimpenalty_amt_close_mult = 15;
//	g_bot_attack_aimpenalty_amt_far_mult = 40;
//	g_bot_attackdelay_frac_difficulty_impossible_mult = 0.03;
//	g_bot_attack_aimpenalty_time_close_mult = 0.15;
//	g_bot_attack_aimpenalty_time_far_mult = 2.0;
//	g_bot_aim_aimtracking_base = 0.05;
//	g_bot_aim_aimtracking_frac_impossible =  0.05;
//	g_bot_aim_angularvelocity_frac_impossible =  0.05;
//	g_bot_aim_angularvelocity_frac_sprinting_target =  0.05;
//	g_bot_aim_attack_aimtolerance_frac_impossible =  0.05;
}

public void Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	playerPickSquad[client] = 0;
	g_iHurtFatal[client] = -1;
	g_playerFirstJoin[client] = 1;
	g_iPlayerRespawnTimerActive[client] = 0;

	UpdateRespawnCvars();
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (client > 0) 
	{
		playerPickSquad[client] = 0;
	
		g_client_last_classstring[client][0] = '\0';
	
		int playerRag = EntRefToEntIndex(g_clientRagdolls[client]);
		
		if (playerRag > 0 && IsValidEdict(playerRag) && IsValidEntity(playerRag)) 
			RemoveRagdoll(client);
		
		UpdateRespawnCvars();
	}
	
	return Plugin_Continue;
}

public Action Command_Reload(int client, int args)
{
	ServerCommand("exec sourcemod/medicandrespawns.plugin.cfg");

	ResetSecurityLives();
	ResetInsurgencyLives();
	
	ReplyToCommand(client, "[SM] Reloaded 'sourcemod/medicandrespawns.plugin.cfg' file.");
	return Plugin_Handled;
}

public Action Command_Respawn(int client, int args) 
{
	if (args < 1) 
	{
		ReplyToCommand(client, "[SM] Usage: sm_player_respawn <#userid|name>");
		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	int[] target_list = new int[MaxClients];
	char target_name[MAX_TARGET_LENGTH];
	bool tn_is_ml;

	int target_count;
	if ((target_count = ProcessTargetString(arg, client, target_list, MaxClients, COMMAND_FILTER_DEAD, target_name, sizeof(target_name), tn_is_ml)) <= COMMAND_TARGET_NONE)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	int new_target_count;

	for (int i = 0; i < target_count; i++) 
	{
		if (GetClientTeam(target_list[i]) >= 2) 
		{
			target_list[new_target_count] = target_list[i];
			new_target_count++;
		}
	}

	if (new_target_count == COMMAND_TARGET_NONE) 
	{
		ReplyToTargetError(client, new_target_count);
		return Plugin_Handled;
	}

	target_count = new_target_count;

	if (tn_is_ml) 
		ShowActivity2(client, "[SM] ", "%t", "Toggled respawn on target", target_name);
	else 
		ShowActivity2(client, "[SM] ", "%t", "Toggled respawn on target", "_s", target_name);

	for (int i = 0; i < target_count; i++) 
		RespawnPlayer(client, target_list[i]);
		
	return Plugin_Handled;
}

void RespawnPlayer(int client, int target)
{
	int team = GetClientTeam(target);
	if (IsClientInGame(target) && !IsFakeClient(target) && !IsClientTimingOut(target) && g_client_last_classstring[target][0] && playerPickSquad[target] == 1 && !IsPlayerAlive(target) && team == TEAM_1_SEC)
	{
		LogAction(client, target, "\"%L\" respawned \"%L\"", client, target);
		SDKCall(g_hForceRespawn, target);
	}
}

public Action Timer_Enemies_Remaining(Handle timer)
{
	if (!g_iRoundStatus)
		return Plugin_Continue;

	int alive_insurgents;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i) && IsFakeClient(i))
			alive_insurgents++;
	
	char textToPrint[32];
	Format(textToPrint, sizeof(textToPrint), "[INTEL]Enemies alive: %d", alive_insurgents);
	PrintHintTextToAll(textToPrint);

	int timeReduce = (GetTeamSecCount() / 3);
	
	if (timeReduce <= 0)
		timeReduce = 3;

	return Plugin_Continue;
}


int AI_Director_SetMinMax(int t_AIDir_TeamStatus, int t_AIDir_TeamStatus_min, int t_AIDir_TeamStatus_max)
{
	if (t_AIDir_TeamStatus < t_AIDir_TeamStatus_min)
		t_AIDir_TeamStatus = t_AIDir_TeamStatus_min;
	else if (t_AIDir_TeamStatus > t_AIDir_TeamStatus_max)
		t_AIDir_TeamStatus = t_AIDir_TeamStatus_max;
	
	return t_AIDir_TeamStatus;
}

Action AI_Director_RandomEnemyReinforce()
{
	char textToPrint[64];
	
	if (g_iRemaining_lives_team_ins > 0)
	{
		int minBotCount = (g_iRespawn_lives_team_ins / 5);
		g_iRemaining_lives_team_ins += minBotCount;
		Format(textToPrint, sizeof(textToPrint), "[INTEL]Ambush Reinforcements Added to Existing Reinforcements!");
		
		g_AIDir_BotReinforceTriggered = true;
		g_AIDir_TeamStatus -= 5;
		g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);

		PrintHintTextToAll(textToPrint);
		g_iReinforceTime = g_iReinforceTimeSubsequent_AD_Temp;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsFakeClient(i) || IsPlayerAlive(i) || GetClientTeam(i) != TEAM_2_INS)
				continue;
			
			g_iRemaining_lives_team_ins++;
			CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		int minBotCount = (g_iRespawn_lives_team_ins / 5);
		g_iRemaining_lives_team_ins += minBotCount;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsFakeClient(i) || IsPlayerAlive(i) || GetClientTeam(i) != TEAM_2_INS)
				continue;
			
			g_iRemaining_lives_team_ins++;
			CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		g_iReinforceTime = g_iReinforceTimeSubsequent_AD_Temp;

		Format(textToPrint, sizeof(textToPrint), "[INTEL]Enemy Ambush Reinforcement Incoming!");

		g_AIDir_BotReinforceTriggered = true;
		g_AIDir_TeamStatus -= 5;
		g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);

		PrintHintTextToAll(textToPrint);
	}
}

public Action Timer_EnemyReinforce(Handle timer)
{
	if (!g_iRoundStatus)
		return Plugin_Continue;
	
	if (g_iRemaining_lives_team_ins <= (g_iRespawn_lives_team_ins / sm_respawn_reinforce_multiplier.IntValue) + sm_respawn_reinforce_multiplier_base.IntValue)
	{
		g_iReinforceTime--;
		char textToPrint[64];

		if (g_iReinforceTime % 10 == 0 && g_iReinforceTime > 10)
		{
			Format(textToPrint, sizeof(textToPrint), "Allied forces spawn on counter-attacks, capture the point!");
			PrintHintTextToAll(textToPrint);
		}

		if (g_iReinforceTime <= 10)
		{
			Format(textToPrint, sizeof(textToPrint), "Enemies reinforce in %d seconds | capture point soon!", g_iReinforceTime);
			PrintHintTextToAll(textToPrint);
		}

		if (g_iReinforceTime <= 0)
		{
			if (g_iRemaining_lives_team_ins > 0)
			{
				if (g_iRemaining_lives_team_ins < (g_iRespawn_lives_team_ins / sm_respawn_reinforce_multiplier.IntValue) + sm_respawn_reinforce_multiplier_base.IntValue)
				{
					int minBotCount = (g_iRespawn_lives_team_ins / 4);
					g_iRemaining_lives_team_ins += minBotCount;
					Format(textToPrint, sizeof(textToPrint), "Enemy Reinforcements have arrived!");
					
					g_AIDir_BotReinforceTriggered = true;
					g_AIDir_TeamStatus -= 5;
					g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);

					PrintHintTextToAll(textToPrint);
					g_iReinforceTime = g_iReinforceTimeSubsequent_AD_Temp;

					for (int i = 1; i <= MaxClients; i++)
					{
						if (!IsClientInGame(i) || !IsFakeClient(i) || IsPlayerAlive(i) || GetClientTeam(i) != TEAM_2_INS)
							continue;
						
						g_iRemaining_lives_team_ins++;
						CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				else
					g_iReinforceTime = g_iReinforceTime_AD_Temp;
			}
			else
			{
				int minBotCount = (g_iRespawn_lives_team_ins / 4);
				g_iRemaining_lives_team_ins += minBotCount;
				
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsFakeClient(i) || IsPlayerAlive(i) || GetClientTeam(i) != TEAM_2_INS)
						continue;
					
					g_iRemaining_lives_team_ins++;
					CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
				}
				
				g_iReinforceTime = g_iReinforceTimeSubsequent_AD_Temp;
				
				Format(textToPrint, sizeof(textToPrint), "ISIS terrorists have now arrived!");

				g_AIDir_BotReinforceTriggered = true;
				g_AIDir_TeamStatus -= 5;
				g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);

				PrintHintTextToAll(textToPrint);
			}
		}
	}
	
	return Plugin_Continue;
}


/*
void SetPlayerAmmo(int client)
{
	if (!IsClientInGame(client) || IsFakeClient(client))
		return;
	
	int primaryWeapon = GetPlayerWeaponSlot(client, 0);
	int secondaryWeapon = GetPlayerWeaponSlot(client, 1);
	int playerGrenades = GetPlayerWeaponSlot(client, 3);

	if (IsValidEntity(primaryWeapon))
	{
		SetPrimaryAmmo(client, primaryWeapon, playerClip[client][0], 0);
		Client_SetWeaponPlayerAmmoEx(client, primaryWeapon, playerAmmo[client][0]);
	}
	
	if (IsValidEntity(secondaryWeapon))
	{
		SetPrimaryAmmo(client, secondaryWeapon, playerClip[client][1], 1);
		Client_SetWeaponPlayerAmmoEx(client, secondaryWeapon, playerAmmo[client][1]);
	}
	
	if (IsValidEntity(playerGrenades))
	{
		while (IsValidEntity(playerGrenades))
		{
			playerGrenades = GetPlayerWeaponSlot(client, 3);
			
			if (IsValidEntity(playerGrenades))
			{
				char weapon[32];
				GetEntityClassname(playerGrenades, weapon, sizeof(weapon));
				RemovePlayerItem(client,playerGrenades);
				AcceptEntityInput(playerGrenades, "kill");
			}
		}
	}
	
	if (!IsFakeClient(client))
		playerRevived[client] = false;
}
*/

public Action Event_PlayerReload_Pre(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (client == 0)
		return Plugin_Continue;
	
	if (IsFakeClient(client) && playerInRevivedState[client] == false)
		return Plugin_Continue;
	
	g_playerActiveWeapon[client] = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	return Plugin_Continue;
}

float GetInsSpawnGround(int spawnPoint, float vecSpawn[3]) 
{
	float fGround[3];
	vecSpawn[2] += 15.0;
	
	TR_TraceRayFilter(vecSpawn, view_as<float>({90.0, 0.0, 0.0}), MASK_PLAYERSOLID, RayType_Infinite, TRDontHitSelf, spawnPoint);
	
	if (TR_DidHit()) 
	{
		TR_GetEndPosition(fGround);
		return fGround;
	}
	
	return vecSpawn;
}

int CheckSpawnPoint(float vecSpawn[3], int client, float tObjectiveDistance, int m_nActivePushPointIndex) 
{
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	float tMinPlayerDistMult = 0.0;

	int acp = (Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex") - 1);
	int acp2 = m_nActivePushPointIndex;
	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	
	if (acp == acp2 && !Ins_InCounterAttack()) 
		tMinPlayerDistMult = cvarBackSpawnIncrease.FloatValue;
	
	UpdatePlayerOrigins();
	
	int m_iTeam = GetClientTeam(client);
	float distance;
	float furthest;
	float closest = -1.0;

	for (int iTarget = 1; iTarget < MaxClients; iTarget++) 
	{
		if (!IsValidClient(iTarget) || !IsClientInGame(iTarget) || !IsPlayerAlive(iTarget) || GetClientTeam(iTarget) != TEAM_1_SEC)
			continue;

		distance = GetVectorDistance(vecSpawn, g_vecOrigin[iTarget]);
		
		if (distance > furthest) 
			furthest = distance;
		
		if ((distance < closest) || (closest < 0))
			closest = distance;

		if (GetClientTeam(iTarget) != m_iTeam) 
		{
			if (distance < (cvarMinPlayerDistance.FloatValue + tMinPlayerDistMult)) 
				return 0;
			
			if (ClientCanSeeVector(iTarget, vecSpawn, (cvarMinPlayerDistance.FloatValue * cvarCanSeeVectorMultiplier.FloatValue)))
				return 0;
			
			if (closest > cvarMaxPlayerDistance.FloatValue) 
				return 0;
		}
	}

	Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);
	
	distance = GetVectorDistance(vecSpawn, m_vCPPositions[m_nActivePushPointIndex]);
	
	if (distance > (tObjectiveDistance) && (((acp + 1) != ncp) || !Ins_InCounterAttack())) 
		return 0;
	else if (distance > (tObjectiveDistance * sm_respawn_dynamic_distance_multiplier.IntValue) && (((acp + 1) != ncp) || !Ins_InCounterAttack())) 
		return 0;

	if ((0 < client <= MaxClients) || !IsClientInGame(client))
		return 0;

	if ((((acp + 1) == ncp) || Ins_InCounterAttack()) && GetRandomInt(1, 100) <= 10) 
	{
		int m_nActivePushPointIndexFinal = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
		m_nActivePushPointIndexFinal -= 1;
		distance = GetVectorDistance(vecSpawn, m_vCPPositions[m_nActivePushPointIndexFinal]);
		
		if (distance > (tObjectiveDistance))
			return 0;
		else if (distance > (tObjectiveDistance * sm_respawn_dynamic_distance_multiplier.IntValue))
			return 0;
	}
	
	return 1;
}


int CheckSpawnPointPlayers(float vecSpawn[3], int client, float tObjectiveDistance) 
{
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	UpdatePlayerOrigins();

	int m_nActivePushPointIndex = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
	
	int m_iTeam = GetClientTeam(client);
	float distance;
	float furthest;
	float closest = -1.0;
	float objDistance;

	for (int iTarget = 1; iTarget < MaxClients; iTarget++) 
	{
		if (!IsValidClient(iTarget) || !IsClientInGame(iTarget) || !IsPlayerAlive(iTarget) || GetClientTeam(iTarget) != TEAM_1_SEC)
			continue;

		m_nActivePushPointIndex = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

		if (Ins_InCounterAttack() && m_nActivePushPointIndex > 0) 
			m_nActivePushPointIndex -= 1;

		Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);

		objDistance = GetVectorDistance(g_vecOrigin[iTarget], m_vCPPositions[m_nActivePushPointIndex]);
		distance = GetVectorDistance(vecSpawn, g_vecOrigin[iTarget]);
		
		if (distance > furthest) 
			furthest = distance;
		
		if ((distance < closest) || (closest < 0)) 
			closest = distance;

		if (GetClientTeam(iTarget) != m_iTeam) 
		{
			if (distance < cvarMinPlayerDistance.FloatValue) 
				return 0;
			
			if (ClientCanSeeVector(iTarget, vecSpawn, (cvarMinPlayerDistance.FloatValue * cvarCanSeeVectorMultiplier.FloatValue))) 
				return 0;

			if (objDistance < 2500 && GetRandomInt(1, 100) < 30 && !Ins_InCounterAttack()) 
				return 0;
		}
	}
	
	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	if (closest > cvarMaxPlayerDistance.FloatValue)
		return 0;

	m_nActivePushPointIndex = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	if (Ins_InCounterAttack() && m_nActivePushPointIndex > 0)
		m_nActivePushPointIndex -= 1;
	
	if (m_nActivePushPointIndex == -1)
		return 0;

	Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);
	objDistance = GetVectorDistance(vecSpawn, m_vCPPositions[m_nActivePushPointIndex]);
	
	int fRandomInt = GetRandomInt(1, 100);
	
	if (objDistance > (tObjectiveDistance) && (((acp + 1) != ncp) || !Ins_InCounterAttack()) && fRandomInt < 25)
		return 0;
	else if (objDistance > (tObjectiveDistance * sm_respawn_dynamic_distance_multiplier.IntValue) && (((acp + 1) != ncp) || !Ins_InCounterAttack()) && fRandomInt < 25)
		return 0;
	
	if ((0 < client <= MaxClients) || !IsClientInGame(client))
		return 0;

	if ((((acp + 1) == ncp) || Ins_InCounterAttack()) && GetRandomInt(1, 100) < 25) 
	{
		int m_nActivePushPointIndexFinal = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
		
		if (m_nActivePushPointIndexFinal < 0)
			return 0;
		
		m_nActivePushPointIndexFinal -= 1;
		objDistance = GetVectorDistance(vecSpawn, m_vCPPositions[m_nActivePushPointIndexFinal]);
		
		if (objDistance > (tObjectiveDistance))
			return 0;
		
		if (objDistance > (tObjectiveDistance * sm_respawn_dynamic_distance_multiplier.IntValue))
			return 0;
	}
	
	return 1;
}

int GetPushPointIndex(float fRandomFloat, int client) 
{
	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
	int m_nActivePushPointIndex = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	if (((acp + 1) == ncp && Ins_InCounterAttack()) || g_spawnFrandom[client] < g_dynamicSpawnCounter_Perc || (Ins_InCounterAttack()) || (m_nActivePushPointIndex > 1))
	{
		if ((acp + 1) == ncp && Ins_InCounterAttack()) 
		{
			if (g_spawnFrandom[client] < g_dynamicSpawnCounter_Perc) 
				m_nActivePushPointIndex--;
		}
		else
		{
			if (Ins_InCounterAttack() && (acp + 1) != ncp) 
			{
				if (fRandomFloat <= 0.5 && m_nActivePushPointIndex > 0) 
					m_nActivePushPointIndex--;
				else
					m_nActivePushPointIndex++;
			}
			else if (!Ins_InCounterAttack()) 
			{
				if (m_nActivePushPointIndex > 0) 
					if (g_spawnFrandom[client] < sm_respawn_dynamic_spawn_percent.IntValue) 
						m_nActivePushPointIndex--;
			}
		}
	}
	
	return m_nActivePushPointIndex;
}

stock float GetSpawnPoint_SpawnPoint(int client) 
{
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	int m_nActivePushPointIndex = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
	if (((acp + 1) == ncp) || (Ins_InCounterAttack() && g_spawnFrandom[client] < g_dynamicSpawnCounter_Perc) || (!Ins_InCounterAttack() && g_spawnFrandom[client] < sm_respawn_dynamic_spawn_percent.IntValue && acp > 1))
		m_nActivePushPointIndex = GetPushPointIndex(GetRandomFloat(0.0, 1.0), client);

	int point = FindEntityByClassname(-1, "ins_spawnpoint");
	float tObjectiveDistance = cvarMinObjectiveDistance.FloatValue;
	
	float vecSpawn[3];
	if ((0 < client <= MaxClients) || !IsClientInGame(client))
	{
		while (point != -1)
		{
			GetEntPropVector(point, Prop_Send, "m_vecOrigin", vecSpawn);
			Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);

			if (CheckSpawnPoint(vecSpawn, client, tObjectiveDistance, m_nActivePushPointIndex)) 
			{
				vecSpawn = GetInsSpawnGround(point, vecSpawn);
				return vecSpawn;
			}
			else
				tObjectiveDistance += 4.0;
			
			point = FindEntityByClassname(point, "ins_spawnpoint");
		}
	}

	int point2 = FindEntityByClassname(-1, "ins_spawnpoint");
	tObjectiveDistance = ((cvarMinObjectiveDistance.FloatValue + 100) * 4);
	while (point2 != -1) 
	{
		GetEntPropVector(point2, Prop_Send, "m_vecOrigin", vecSpawn);

		Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);
		if (CheckSpawnPoint(vecSpawn, client, tObjectiveDistance, m_nActivePushPointIndex)) 
		{
			vecSpawn = GetInsSpawnGround(point2, vecSpawn);
			return vecSpawn;
		}
		else
			tObjectiveDistance += 4.0;
		
		point2 = FindEntityByClassname(point2, "ins_spawnpoint");
	}

	int point3 = FindEntityByClassname(-1, "ins_spawnpoint");
	tObjectiveDistance = ((cvarMinObjectiveDistance.FloatValue + 100) * 10);
	while (point3 != -1) 
	{
		GetEntPropVector(point3, Prop_Send, "m_vecOrigin", vecSpawn);
		Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);
		if (CheckSpawnPoint(vecSpawn, client, tObjectiveDistance, m_nActivePushPointIndex)) 
		{
			vecSpawn = GetInsSpawnGround(point3, vecSpawn);
			return vecSpawn;
		}
		else 
			tObjectiveDistance += 4.0;
		
		point3 = FindEntityByClassname(point3, "ins_spawnpoint");
	}
	
	int pointFinal = FindEntityByClassname(-1, "ins_spawnpoint");
	tObjectiveDistance = ((cvarMinObjectiveDistance.FloatValue + 100) * 4);
	m_nActivePushPointIndex = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
	
	if (m_nActivePushPointIndex > 1) 
	{
		if ((acp + 1) >= ncp) 
			m_nActivePushPointIndex--;
		else 
			m_nActivePushPointIndex++;
	}

	while (pointFinal != -1) 
	{
		GetEntPropVector(pointFinal, Prop_Send, "m_vecOrigin", vecSpawn);
		Ins_ObjectiveResource_GetPropVector("m_vCPPositions", m_vCPPositions[m_nActivePushPointIndex], m_nActivePushPointIndex);
		if (CheckSpawnPoint(vecSpawn, client, tObjectiveDistance, m_nActivePushPointIndex)) 
		{
			vecSpawn = GetInsSpawnGround(pointFinal, vecSpawn);
			return vecSpawn;
		}
		else 
			tObjectiveDistance += 4.0;
		
		pointFinal = FindEntityByClassname(pointFinal, "ins_spawnpoint");
	}
	
	return vecOrigin;
}

public Action Event_Spawn(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (client > 0 && IsClientInGame(client))
	{
		if (!IsFakeClient(client)) 
		{
			g_iPlayerRespawnTimerActive[client] = 0;

			int playerRag = EntRefToEntIndex(g_clientRagdolls[client]);
			
			if (playerRag > 0 && IsValidEdict(playerRag) && IsValidEntity(playerRag))
				RemoveRagdoll(client);
			
			g_iHurtFatal[client] = 0;
		}
	}
	
	if (g_playerFirstJoin[client] == 1 && !IsFakeClient(client)) 
	{
		g_playerFirstJoin[client] = 0;
	
		char steamId[64];
		GetClientAuthId(client, AuthId_Steam3, steamId, sizeof(steamId));
		
		if (g_playerArrayList.FindString(steamId) == -1) 
			g_playerArrayList.PushString(steamId);
	}
	
	if (!sm_respawn_enabled.BoolValue || !IsClientConnected(client) || !IsClientInGame(client) || !IsValidClient(client) || !IsFakeClient(client) || !g_isCheckpoint) 
		return Plugin_Continue;
	
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);

	if  ((0 < client <= MaxClients) || !IsClientInGame(client) && g_playersReady && g_botsReady) 
	{
		float vecSpawn[3];
		GetClientAbsOrigin(client, vecOrigin);
		
		int point = FindEntityByClassname(-1, "ins_spawnpoint");
		float tObjectiveDistance = cvarMinObjectiveDistance.FloatValue;
		int iCanSpawn = CheckSpawnPointPlayers(vecOrigin, client, tObjectiveDistance);
		
		while (point != -1) 
		{
			if (iCanSpawn < 0) 
				return Plugin_Continue;
			
			GetEntPropVector(point, Prop_Send, "m_vecOrigin", vecSpawn);
			iCanSpawn = CheckSpawnPointPlayers(vecOrigin, client, tObjectiveDistance);
			
			if (iCanSpawn == 1) 
				break;
			else 
				tObjectiveDistance += 6.0;
			
			point = FindEntityByClassname(point, "ins_spawnpoint");
		}

		g_spawnFrandom[client] = GetRandomInt(0, 100);
		
		if (iCanSpawn == 0 || (Ins_InCounterAttack() && g_spawnFrandom[client] < g_dynamicSpawnCounter_Perc) || (!Ins_InCounterAttack() && g_spawnFrandom[client] < sm_respawn_dynamic_spawn_percent.IntValue && acp > 1)) 
		{
			/*if (g_DeathOrigin[client][0] != 0.0 || g_DeathOrigin[client][1] != 0.0 || g_DeathOrigin[client][2] != 0.0)
			{
				if ((0 < client <= MaxClients) && IsClientInGame(client)) 
				{
					TeleportEntity(client, g_DeathOrigin[client], NULL_VECTOR, NULL_VECTOR);
					SetNextAttack(client);
				}
			}
			else
			{
				float vecSpawn2[3];
				vecSpawn2 = GetSpawnPoint_SpawnPoint(client);
		
				if ((0 < client <= MaxClients) && IsClientInGame(client)) 
				{
					TeleportEntity(client, vecSpawn2, NULL_VECTOR, NULL_VECTOR);
					SetNextAttack(client);
				}
			}*/
		}
	}
	
	return Plugin_Continue;
}

public void Event_SpawnPost(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!IsFakeClient(client)) 
		return;
	
	//g_DeathOrigin[client][0] = 0.0;
	//g_DeathOrigin[client][1] = 0.0;
	//g_DeathOrigin[client][2] = 0.0;
	
	SetNextAttack(client);
	
	if (GetRandomInt(1, 100) >= 50 || Ins_InCounterAttack())
		return;
	
	int botGrenades = GetPlayerWeaponSlot(client, 3);

	if (!IsValidEntity(botGrenades))  
		return;
	
	while (IsValidEntity(botGrenades))  
	{
		botGrenades = GetPlayerWeaponSlot(client, 3);

		if (IsValidEntity(botGrenades))
		{
			RemovePlayerItem(client, botGrenades);
			AcceptEntityInput(botGrenades, "kill");
		}
	}
}

void UpdatePlayerOrigins() 
{
	for (int i = 1; i < MaxClients; i++) 
		if (IsValidClient(i)) 
			GetClientAbsOrigin(i, g_vecOrigin[i]);
}

void SetNextAttack(int client)
{
	float flTime = GetGameTime();
	float flDelay = cvarSpawnAttackDelay.FloatValue;

	int weapon;
	for (int offset = 0; offset < 128; offset += 4)
	{
		if ((weapon = GetEntDataEnt2(client, m_hMyWeapons + offset)) < 0)
			continue;

		SetEntDataFloat(weapon, m_flNextPrimaryAttack, flTime + flDelay);
		SetEntDataFloat(weapon, m_flNextSecondaryAttack, flTime + flDelay);
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_AIDir_TeamStatus = 50;
	g_AIDir_BotReinforceTriggered = false;
	g_iReinforceTime = sm_respawn_reinforce_time.IntValue;
	g_secWave_Timer = g_iRespawnSeconds;

/*
	if (sm_elite_counter_attacks.BoolValue)
	{
		g_isEliteCounter = 0;
		EnableDisableEliteBotCvars(0, 0);
	}
*/

	g_fRespawnPosition[0] = 0.0;
	g_fRespawnPosition[1] = 0.0;
	g_fRespawnPosition[2] = 0.0;

	ResetInsurgencyLives();
	ResetSecurityLives();

	char sGameMode[32];
	FindConVar("mp_gamemode").GetString(sGameMode, sizeof(sGameMode));
	
	g_iEnableRevive = false;
	int iPreRoundFirst = FindConVar("mp_timer_preround_first").IntValue;
	int iPreRound = FindConVar("mp_timer_preround").IntValue;
	
	if (g_preRoundInitial)
	{
		CreateTimer(float(iPreRoundFirst), PreReviveTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		iPreRoundFirst = iPreRoundFirst + 5;
		CreateTimer(float(iPreRoundFirst), BotsReady_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
		g_preRoundInitial = false;
	}
	else
	{
		CreateTimer(float(iPreRound), PreReviveTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		iPreRoundFirst = iPreRound + 5;
		CreateTimer(float(iPreRound), BotsReady_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

void SecTeamLivesBonus()
{
	int secTeamCount = GetTeamSecCount();
	
	if (secTeamCount <= 9)
		g_iRespawnCount[2] += 1;
}

void SecDynLivesPerPoint()
{
	int secTeamCount = GetTeamSecCount();
	
	if (secTeamCount <= 9)
		g_iRespawnCount[2] += 1;
}

public Action PreReviveTimer(Handle timer)
{
	g_iRoundStatus = true;
	g_iEnableRevive = true;
}

public Action BotsReady_Timer(Handle timer)
{
	g_botsReady = true;
}

public Action Event_RoundEnd_Pre(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_1_SEC)
			continue;
		
		if ((g_iStatRevives[i] > 0 || g_iStatHeals[i] > 0) && StrContains(g_client_last_classstring[i], "medic") > -1)
		{
			char sBuf[255];
			Format(sBuf, 255,"[MEDIC STATS] for %N: HEALS: %d | REVIVES: %d", i, g_iStatHeals[i], g_iStatRevives[i]);
			PrintHintText(i, "%s", sBuf);
		}

		playerInRevivedState[i] = false;
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
/*
	if (sm_elite_counter_attacks.BoolValue)
	{
		g_isEliteCounter = 0;
		EnableDisableEliteBotCvars(0, 0);
	}
*/	
	//for (int i = 1; i <= MaxClients; i++)
	//{
	//	g_DeathOrigin[i][0] = 0.0;
	//	g_DeathOrigin[i][1] = 0.0;
	//	g_DeathOrigin[i][2] = 0.0;
	//}

	g_fRespawnPosition[0] = 0.0;
	g_fRespawnPosition[1] = 0.0;
	g_fRespawnPosition[2] = 0.0;

	g_iEnableRevive = false;
	g_iRoundStatus = false;
	g_botsReady = false;

	ResetInsurgencyLives();
	ResetSecurityLives();
}

public Action Event_ControlPointCaptured_Pre(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 0; i < MaxClients; i++) 
	{
		if (!IsValidClient(i) || !IsClientInGame(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_2_INS)
			continue;
		
		g_badSpawnPos_Track[i][0] = 0.0;
		g_badSpawnPos_Track[i][1] = 0.0;
		g_badSpawnPos_Track[i][2] = 0.0;
	}

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	int secTeamCount = GetTeamSecCount();
	int secTeamAliveCount = Team_CountAlivePlayers(TEAM_1_SEC);

	if (g_iRespawn_lives_team_ins > 0)
		g_AIDir_TeamStatus += 10;
	
	if (secTeamAliveCount >= (secTeamCount * 0.8))
		g_AIDir_TeamStatus += 10;
	else if (secTeamAliveCount >= (secTeamCount * 0.5))
		g_AIDir_TeamStatus += 5;
	else if (secTeamAliveCount <= (secTeamCount * 0.2))
		g_AIDir_TeamStatus -= 10;
	else if (secTeamAliveCount <= (secTeamCount * 0.5))
		g_AIDir_TeamStatus -= 5;

	if (g_AIDir_BotReinforceTriggered)
		g_AIDir_TeamStatus -= 5;
	else
		g_AIDir_TeamStatus += 10;

	g_AIDir_BotReinforceTriggered = false;

	g_counterAttack_min_dur_sec = sm_respawn_min_counter_dur_sec.IntValue;
	g_counterAttack_max_dur_sec = sm_respawn_max_counter_dur_sec.IntValue;
	int final_ca_dur = sm_respawn_final_counter_dur_sec.IntValue;

	int fRandomInt = GetRandomInt(g_counterAttack_min_dur_sec, g_counterAttack_max_dur_sec);
	int fRandomIntCounterLarge = GetRandomInt(1, 100);
	bool largeCounterEnabled;
	
	if (fRandomIntCounterLarge <= 15)
	{
		fRandomInt *= 2;
		final_ca_dur = (final_ca_dur + GetRandomInt(60, 90));
		largeCounterEnabled = true;
	}
	
	ConVar cvar_ca_dur;
	
	if ((acp + 1) == ncp)
	{
		g_iRemaining_lives_team_ins = 0;
		
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && IsFakeClient(i))
				ForcePlayerSuicide(i);
		
		cvar_ca_dur = FindConVar("mp_checkpoint_counterattack_duration_finale");
		cvar_ca_dur.SetInt(final_ca_dur, true, false);
		g_dynamicSpawnCounter_Perc += 10;

		if (sm_finale_counter_spec_enabled.BoolValue)
			g_dynamicSpawnCounter_Perc = sm_finale_counter_spec_percent.IntValue;
		
		if (sm_respawn_final_counterattack_type.IntValue == 2)
			CreateTimer(FindConVar("mp_checkpoint_counterattack_delay_finale").FloatValue, Timer_FinaleCounterAssignLives, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
//		g_AIDir_TeamStatus -= 5;
		cvar_ca_dur = FindConVar("mp_checkpoint_counterattack_duration");
		cvar_ca_dur.SetInt(fRandomInt, true, false);
	}
	
	if (GetRandomFloat(0.0, 1.0) < g_respawn_counter_chance && ((acp + 1) != ncp))
	{
		FindConVar("mp_checkpoint_counterattack_disable").SetInt(0, true, false);
		FindConVar("mp_checkpoint_counterattack_always").SetInt(1, true, false);
		
		if (largeCounterEnabled)
			PrintHintTextToAll("[INTEL]: Enemy forces are sending a large counter-attack your way!  Get ready to defend!");
		
		//g_AIDir_TeamStatus -= 5;

//		g_isEliteCounter = 1;
		CreateTimer(cvar_ca_dur.FloatValue + 1.0, Timer_CounterAttackEnd, _, TIMER_FLAG_NO_MAPCHANGE);

/*
		if (sm_elite_counter_attacks.BoolValue) 
		{
			EnableDisableEliteBotCvars(1, 0);
			ConVar tCvar = FindConVar("ins_bot_count_checkpoint_max");
			int tCvarIntValue = tCvar.IntValue;
			tCvarIntValue += 3;
			tCvar.SetInt(tCvarIntValue, true, false);
		}

*/		
	}
	else if (g_isCheckpoint && ((acp + 1) == ncp)) 
	{
		FindConVar("mp_checkpoint_counterattack_disable").SetInt(0, true, false);
		FindConVar("mp_checkpoint_counterattack_always").SetInt(1, true, false);

		//g_isEliteCounter = 1;
		CreateTimer((cvar_ca_dur.FloatValue + 1.0), Timer_CounterAttackEnd, _, TIMER_FLAG_NO_MAPCHANGE);

		/*
		if (sm_elite_counter_attacks.BoolValue) 
		{
			EnableDisableEliteBotCvars(1, 1);
			ConVar tCvar = FindConVar("ins_bot_count_checkpoint_max");
			int tCvarIntValue = tCvar.IntValue + 3;
			tCvar.SetInt(tCvarIntValue, true, false);
		}
		*/
	}
	else
		FindConVar("mp_checkpoint_counterattack_disable").SetInt(1, true, false);
	
	g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);
}

public void Event_ControlPointCaptured_Post(Event event, const char[] name, bool dontBroadcast)
{
	//for (int i = 1; i <= MaxClients; i++)
	//{
	//	g_DeathOrigin[i][0] = 0.0;
	//	g_DeathOrigin[i][1] = 0.0;
	//	g_DeathOrigin[i][2] = 0.0;
	//}
	
	//g_iReinforceTime = g_iReinforceTime_AD_Temp;
	
	ResetInsurgencyLives();
	//if (g_iCvar_respawn_reset_type && g_isCheckpoint)
	if (g_iCvar_respawn_reset_type)
		ResetSecurityLives();
	
	if (sm_respawn_security_on_counter.BoolValue)
	{
		char cappers[512];
		event.GetString("cappers", cappers, sizeof(cappers));
		
		int clientCapper;
		for (int i = 0 ; i < strlen(cappers); i++) 
		{
			if ((clientCapper = cappers[i]) > 0 && IsPlayerAlive(clientCapper) && !IsFakeClient(clientCapper)) 
			{
				float capperPos[3];
				GetClientAbsOrigin(clientCapper, capperPos);

				g_fRespawnPosition = capperPos;
				break;
			}
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || playerPickSquad[i] != 1 || IsPlayerAlive(i) || GetClientTeam(i) != TEAM_1_SEC)
				continue;
			
			if (IsFakeClient(i))
			{
				if (!IsClientTimingOut(i))
					CreateTimer(0.0, RespawnPlayerCounter, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
				CreateTimer(0.0, RespawnPlayerCounter, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	UpdateRespawnCvars();

	g_secWave_Timer = g_iRespawnSeconds;

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	if (((acp + 1) == ncp))
	{
		g_secWave_Timer = g_iRespawnSeconds;
		g_secWave_Timer += (GetTeamSecCount() * 4);
	}
	else if (Ins_InCounterAttack())
		g_secWave_Timer += (GetTeamSecCount() * 3);
}

public Action Event_ObjectDestroyed_Pre(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 0; i < MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientInGame(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_2_INS)
			continue;
		
		g_badSpawnPos_Track[i][0] = 0.0;
		g_badSpawnPos_Track[i][1] = 0.0;
		g_badSpawnPos_Track[i][2] = 0.0;
	}

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	int secTeamCount = GetTeamSecCount();
	int secTeamAliveCount = Team_CountAlivePlayers(TEAM_1_SEC);


	if (g_iRespawn_lives_team_ins > 0)
		g_AIDir_TeamStatus += 10;
	if (secTeamAliveCount >= (secTeamCount * 0.8))
		g_AIDir_TeamStatus += 10;
	else if (secTeamAliveCount >= (secTeamCount * 0.5))
		g_AIDir_TeamStatus += 5;
	else if (secTeamAliveCount <= (secTeamCount * 0.2))
		g_AIDir_TeamStatus -= 10;
	else if (secTeamAliveCount <= (secTeamCount * 0.5))
		g_AIDir_TeamStatus -= 5;

	if (g_AIDir_BotReinforceTriggered)
		g_AIDir_TeamStatus += 10;
	else
		g_AIDir_TeamStatus -= 5;

	g_AIDir_BotReinforceTriggered = false;


	g_counterAttack_min_dur_sec = sm_respawn_min_counter_dur_sec.IntValue;
	g_counterAttack_max_dur_sec = sm_respawn_max_counter_dur_sec.IntValue;
	int final_ca_dur = sm_respawn_final_counter_dur_sec.IntValue;

	int fRandomInt = GetRandomInt(g_counterAttack_min_dur_sec, g_counterAttack_max_dur_sec);
	int fRandomIntCounterLarge = GetRandomInt(1, 100);
	//bool largeCounterEnabled;
	
	if (fRandomIntCounterLarge <= 15)
	{
		fRandomInt *= 2;
		final_ca_dur = (final_ca_dur + GetRandomInt(90, 180));
		//largeCounterEnabled = true;
	}

	ConVar cvar_ca_dur;

	if ((acp + 1) == ncp)
	{
		cvar_ca_dur = FindConVar("mp_checkpoint_counterattack_duration_finale");
		cvar_ca_dur.SetInt(final_ca_dur, true, false);
		g_dynamicSpawnCounter_Perc += 10;

		if (sm_finale_counter_spec_enabled.BoolValue)
			g_dynamicSpawnCounter_Perc = sm_finale_counter_spec_percent.IntValue;
	}
	else
	{
//		g_AIDir_TeamStatus -= 5;
		cvar_ca_dur = FindConVar("mp_checkpoint_counterattack_duration");
		cvar_ca_dur.SetInt(fRandomInt, true, false);
	}

	if (sm_respawn_counterattack_vanilla.BoolValue)
		return Plugin_Continue;
	
	if (GetRandomFloat(0.0, 1.0) < g_respawn_counter_chance && ((acp + 1) != ncp))
	{
		FindConVar("mp_checkpoint_counterattack_disable").SetInt(0, true, false);
		FindConVar("mp_checkpoint_counterattack_always").SetInt(1, true, false);
		
		//if (largeCounterEnabled)
		//	PrintHintTextToAll("[INTEL]: Enemy forces are sending a large counter-attack your way!  Get ready to defend!");
		
//		g_AIDir_TeamStatus -= 5;

//		g_isEliteCounter = 1;
		CreateTimer(cvar_ca_dur.FloatValue + 1.0, Timer_CounterAttackEnd, TIMER_FLAG_NO_MAPCHANGE);

/*		
		if (sm_elite_counter_attacks.BoolValue)
		{
			EnableDisableEliteBotCvars(1, 0);
			ConVar tCvar = FindConVar("ins_bot_count_checkpoint_max");
			int tCvarIntValue = tCvar.IntValue + 3;
			tCvar.SetInt(tCvarIntValue, true, false);
		}

*/
	}
	else if (((acp + 1) == ncp))
	{
		FindConVar("mp_checkpoint_counterattack_disable").SetInt(0, true, false);
		FindConVar("mp_checkpoint_counterattack_always").SetInt(1, true, false);

		//g_isEliteCounter = 1;
		CreateTimer(cvar_ca_dur.FloatValue + 1.0, Timer_CounterAttackEnd, TIMER_FLAG_NO_MAPCHANGE);

/*
		if (sm_elite_counter_attacks.BoolValue) 
		{
			EnableDisableEliteBotCvars(1, 1);
			ConVar tCvar = FindConVar("ins_bot_count_checkpoint_max");
			int tCvarIntValue = tCvar.IntValue + 3;
			tCvar.SetInt(tCvarIntValue, true, false);
		}
*/
	}
	else
		FindConVar("mp_checkpoint_counterattack_disable").SetInt(1, true, false);

	g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);
	
	return Plugin_Continue;
}

public void Event_ObjectDestroyed_Post(Event event, const char[] name, bool dontBroadcast)
{
	//g_iReinforceTime = g_iReinforceTime_AD_Temp;

	ResetInsurgencyLives();
	
	if (g_iCvar_respawn_reset_type)
		ResetSecurityLives();
	
	if (sm_respawn_security_on_counter.BoolValue) 
	{
		char cappers[512];
		event.GetString("cappers", cappers, sizeof(cappers));
		
		int clientCapper;
		for (int i = 0 ; i < strlen(cappers); i++) 
		{
			if ((clientCapper = cappers[i]) > 0 && IsPlayerAlive(clientCapper) && !IsFakeClient(clientCapper)) 
			{
				float capperPos[3];
				GetClientAbsOrigin(clientCapper, capperPos);

				g_fRespawnPosition = capperPos;
				break;
			}
		}

		for (int i = 1; i <= MaxClients; i++) 
		{
			if (!IsClientInGame(i) || playerPickSquad[i] != 1 || IsPlayerAlive(i) || GetClientTeam(i) != TEAM_1_SEC) 
				continue;
			
			if (!IsFakeClient(i)) 
			{
				//if (!IsClientTimingOut(i)) 
				//	CreateTimer(0.0, RespawnPlayerCounter, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			}
			//else
				//CreateTimer(0.0, RespawnPlayerCounter, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	if (((acp + 1) == ncp))
	{
		g_secWave_Timer = g_iRespawnSeconds;
		g_secWave_Timer += (GetTeamSecCount() * 4);
	}
	else if (Ins_InCounterAttack())
		g_secWave_Timer += (GetTeamSecCount() * 3);
}

/*
void EnableDisableEliteBotCvars(int tEnabled, int isFinale) 
{
	float tCvarFloatValue;
	int tCvarIntValue;
	ConVar tCvar;
	
	if (tEnabled == 1) 
	{
		if (isFinale == 1) 
		{
			FindConVar("mp_player_resupply_coop_delay_max").SetInt(g_coop_delay_penalty_base, true, false);
			FindConVar("mp_player_resupply_coop_delay_penalty").SetInt(g_coop_delay_penalty_base, true, false);
			FindConVar("mp_player_resupply_coop_delay_base").SetInt(g_coop_delay_penalty_base, true, false);
		}

		tCvar = FindConVar("bot_attackdelay_frac_difficulty_impossible");
		tCvarFloatValue = tCvar.FloatValue - g_bot_attackdelay_frac_difficulty_impossible_mult;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		tCvar = FindConVar("bot_attack_aimpenalty_amt_close");
		tCvarIntValue = tCvar.IntValue - g_bot_attack_aimpenalty_amt_close_mult;
		tCvar.SetInt(tCvarIntValue, true, false);

		tCvar = FindConVar("bot_attack_aimpenalty_amt_far");
		tCvarIntValue = tCvar.IntValue - g_bot_attack_aimpenalty_amt_far_mult;
		tCvar.SetInt(tCvarIntValue, true, false);

		tCvar = FindConVar("bot_attack_aimpenalty_time_close");
		tCvarFloatValue = tCvar.FloatValue - g_bot_attack_aimpenalty_time_close_mult;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		tCvar = FindConVar("bot_attack_aimpenalty_time_far");
		tCvarFloatValue = tCvar.FloatValue - g_bot_attack_aimpenalty_time_far_mult;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		ConVar cv = FindConVar("bot_attack_aimtolerance_newthreat_amt");
		cv.FloatValue -= cv.FloatValue - g_bot_attack_aimtolerance_newthreat_amt_mult;

		tCvar = FindConVar("bot_aim_aimtracking_base");
		tCvarFloatValue = tCvar.FloatValue - g_bot_aim_aimtracking_base;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		tCvar = FindConVar("bot_aim_aimtracking_frac_impossible");
		tCvarFloatValue = tCvar.FloatValue - g_bot_aim_aimtracking_frac_impossible;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		tCvar = FindConVar("bot_aim_angularvelocity_frac_impossible");
		tCvarFloatValue = tCvar.FloatValue + g_bot_aim_angularvelocity_frac_impossible;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		tCvar = FindConVar("bot_aim_angularvelocity_frac_sprinting_target");
		tCvarFloatValue = tCvar.FloatValue + g_bot_aim_angularvelocity_frac_sprinting_target;
		tCvar.SetFloat(tCvarFloatValue, true, false);

		tCvar = FindConVar("bot_aim_attack_aimtolerance_frac_impossible");
		tCvarFloatValue = tCvar.FloatValue - g_bot_aim_attack_aimtolerance_frac_impossible;
		tCvar.SetFloat(tCvarFloatValue, true, false);
	}
	else 
	{
		FindConVar("ins_bot_count_checkpoint_max").RestoreDefault(true, false);
		FindConVar("mp_player_resupply_coop_delay_max").RestoreDefault(true, false);
		FindConVar("mp_player_resupply_coop_delay_penalty").RestoreDefault(true, false);
		FindConVar("mp_player_resupply_coop_delay_base").RestoreDefault(true, false);
		FindConVar("bot_attackdelay_frac_difficulty_impossible").RestoreDefault(true, false);
		FindConVar("bot_attack_aimpenalty_amt_close").RestoreDefault(true, false);
		FindConVar("bot_attack_aimpenalty_amt_far").RestoreDefault(true, false);
		FindConVar("bot_attack_aimpenalty_time_close").RestoreDefault(true, false);
		FindConVar("bot_attack_aimpenalty_time_far").RestoreDefault(true, false);
		FindConVar("bot_attack_aimtolerance_newthreat_amt").RestoreDefault(true, false);
		FindConVar("bot_aim_aimtracking_base").RestoreDefault(true, false);
		FindConVar("bot_aim_aimtracking_frac_impossible").RestoreDefault(true, false);
		FindConVar("bot_aim_angularvelocity_frac_impossible").RestoreDefault(true, false);
		FindConVar("bot_aim_angularvelocity_frac_sprinting_target").RestoreDefault(true, false);
		FindConVar("bot_aim_attack_aimtolerance_frac_impossible").RestoreDefault(true, false);
	}
}
*/

public Action Timer_FinaleCounterAssignLives(Handle timer)
{
	if (sm_respawn_final_counterattack_type.IntValue == 2)
		g_iRemaining_lives_team_ins = g_iRespawn_lives_team_ins;
}

public Action Timer_CounterAttackEnd(Handle timer) 
{
	//if (g_isEliteCounter == 1 && sm_elite_counter_attacks.BoolValue) 
	//{
	//	g_isEliteCounter = 0;
	//	EnableDisableEliteBotCvars(0, 0);
	//}

	ResetInsurgencyLives();
	
	//if (g_iCvar_respawn_reset_type && g_isCheckpoint) 
	if (g_iCvar_respawn_reset_type) 
		ResetSecurityLives();

	FindConVar("mp_checkpoint_counterattack_always").SetInt(0, true, false);

	for (int i = 0; i < MaxClients; i++) 
	{
		if (!IsValidClient(i) || !IsClientInGame(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_2_INS) 
			continue;
		
		g_badSpawnPos_Track[i][0] = 0.0;
		g_badSpawnPos_Track[i][1] = 0.0;
		g_badSpawnPos_Track[i][2] = 0.0;
	}
	
	return Plugin_Stop;
}

void ResetSecurityLives() 
{
	if (!sm_respawn_enabled.BoolValue) 
		return;

	UpdateRespawnCvars();

	if (g_iCvar_respawn_reset_type == 1) 
		SecDynLivesPerPoint();
	
	if (sm_respawn_type_team_sec.IntValue == 1) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;
			
			g_playerMedicRevivessAccumulated[i] = 0;
			g_playerMedicHealsAccumulated[i] = 0;
			g_playerNonMedicHealsAccumulated[i] = 0;
		}
	}

	if (sm_respawn_type_team_sec.IntValue == 2) 
		g_iRemaining_lives_team_sec = g_iRespawn_lives_team_sec;
}

void ResetInsurgencyLives()
{
	if (!sm_respawn_enabled.BoolValue)
		return;

	UpdateRespawnCvars();

	if (sm_respawn_type_team_ins.IntValue == 1)
	{
		int team;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || (team = GetClientTeam(i)) != TEAM_2_INS)
				continue;
			
			g_iSpawnTokens[i] = g_iRespawnCount[team];
		}
	}

	if (sm_respawn_type_team_ins.IntValue == 2)
		g_iRemaining_lives_team_ins = g_iRespawn_lives_team_ins;
}

public void Event_PlayerPickSquad_Post(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client == 0 || !IsClientInGame(client) || IsFakeClient(client))
		return;
	
	playerPickSquad[client] = 1;

	char class_template[64];
	event.GetString("class_template", class_template, sizeof(class_template));

	g_client_last_classstring[client] = class_template;

	int team = GetClientTeam(client);
	if (client > 0 && IsClientInGame(client) && IsClientObserver(client) && !IsPlayerAlive(client) && g_iHurtFatal[client] == 0 && team == TEAM_1_SEC)
	{
		int playerRag = EntRefToEntIndex(g_clientRagdolls[client]);
		
		if (playerRag > 0 && IsValidEdict(playerRag) && IsValidEntity(playerRag))
			RemoveRagdoll(client);

		g_iHurtFatal[client] = -1;
	}

	/*
	char sNewNickname[64];
	if (IsClientConnected(client) && team == TEAM_1_SEC && sm_respawn_enable_donor_tag.BoolValue)
	{
		if (GetUserFlagBits(client) & ADMFLAG_CUSTOM3)
			Format(sNewNickname, sizeof(sNewNickname), "[ADMIN] %s", g_client_org_nickname[client]);
		else if (GetUserFlagBits(client) & ADMFLAG_CUSTOM2)
			Format(sNewNickname, sizeof(sNewNickname), "[LDR] %s", g_client_org_nickname[client]);
		else if (GetUserFlagBits(client) & ADMFLAG_CUSTOM1)
			Format(sNewNickname, sizeof(sNewNickname), "[DONOR] %s", g_client_org_nickname[client]);
		else
			Format(sNewNickname, sizeof(sNewNickname), "%s", g_client_org_nickname[client]);
	}
	*/

	/*
	char sCurNickname[64];
	Format(sCurNickname, sizeof(sCurNickname), "%N", client);
	
	if (!StrEqual(sCurNickname, sNewNickname))
		SetClientName(client, sNewNickname);
	*/

	g_playersReady = true;

	if (g_iRoundStatus && g_playerFirstJoin[client] == 1 && !IsPlayerAlive(client) && team == TEAM_1_SEC)
	{
		char steamId[64];
		GetClientAuthId(client, AuthId_Steam3, steamId, sizeof(steamId));
		
		if (g_playerArrayList.FindString(steamId) == -1)
		{
			g_playerArrayList.PushString(steamId);

			if (sm_respawn_type_team_sec.IntValue == 1)
			{
				if (g_isCheckpoint && g_iCvar_respawn_reset_type == 0)
				{
					int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
					int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
					int tLiveSec = sm_respawn_lives_team_sec.IntValue;

					if (acp <= (ncp / 2))
						g_iSpawnTokens[client] = tLiveSec;
					else
						g_iSpawnTokens[client] = (tLiveSec / 2);

					if (tLiveSec < 1)
					{
						tLiveSec = 1;
						g_iSpawnTokens[client] = tLiveSec;
					}
				}
				else
					g_iSpawnTokens[client] = sm_respawn_lives_team_sec.IntValue;

			}
			
			CreatePlayerRespawnTimer(client);
		}
	}

	UpdateRespawnCvars();
}

public Action Event_PlayerHurt_Pre(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	if (IsClientInGame(victim) && IsFakeClient(victim))
		return Plugin_Continue;

	int victimHealth = event.GetInt("health");
	int dmg_taken = event.GetInt("dmg_health");

	if (sm_respawn_fatal_chance.FloatValue > 0.0 && dmg_taken > victimHealth)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		int hitgroup = event.GetInt("hitgroup");

		g_clientDamageDone[victim] = dmg_taken;

		char weapon[32];
		event.GetString("weapon", weapon, sizeof(weapon));

		int attackerTeam;
		if (attacker > 0 && IsClientInGame(attacker) && IsClientConnected(attacker))
			attackerTeam = GetClientTeam(attacker);

		float fRandom = GetRandomFloat(0.0, 1.0);

		if (IsClientInGame(victim))
		{
			if (hitgroup == 0)
			{
				if (StrEqual(weapon, "grenade_anm14", false) || StrEqual(weapon, "grenade_molotov", false))
				{
					if (dmg_taken >= sm_respawn_fatal_burn_dmg.IntValue && (fRandom <= sm_respawn_fatal_chance.FloatValue))
						g_iHurtFatal[victim] = 1;
				}
				else if (StrEqual(weapon, "grenade_m67", false) || StrEqual(weapon, "grenade_f1", false) || StrEqual(weapon, "grenade_ied", false) || StrEqual(weapon, "grenade_c4", false) || StrEqual(weapon, "rocket_rpg7", false) || StrEqual(weapon, "rocket_at4", false) || StrEqual(weapon, "grenade_gp25_he", false) || StrEqual(weapon, "grenade_m203_he", false))
				{
					if (dmg_taken >= sm_respawn_fatal_explosive_dmg.IntValue && (fRandom <= sm_respawn_fatal_chance.FloatValue))
						g_iHurtFatal[victim] = 1;
				}
			}
			else if (hitgroup == 1) {
				if (dmg_taken >= sm_respawn_fatal_head_dmg.IntValue && (fRandom <= sm_respawn_fatal_head_chance.FloatValue) && attackerTeam != TEAM_1_SEC)
					g_iHurtFatal[victim] = 1;
			}
			else if (hitgroup == 2 || hitgroup == 3) {
				if (dmg_taken >= sm_respawn_fatal_chest_stomach.IntValue && (fRandom <= sm_respawn_fatal_chance.FloatValue))
					g_iHurtFatal[victim] = 1;
			}
			else if (hitgroup == 4 || hitgroup == 5  || hitgroup == 6 || hitgroup == 7) {
				if (dmg_taken >= sm_respawn_fatal_limb_dmg.IntValue && (fRandom <= sm_respawn_fatal_chance.FloatValue))
					g_iHurtFatal[victim] = 1;
			}
		}
	}

	if (g_iHurtFatal[victim] != 1)
	{
		if (dmg_taken <= sm_minor_wound_dmg.IntValue)
		{
			g_playerWoundTime[victim] = sm_minor_revive_time.IntValue;
			g_playerWoundType[victim] = 0;
		}
		else if (dmg_taken > sm_minor_wound_dmg.IntValue && dmg_taken <= sm_moderate_wound_dmg.IntValue)
		{
			g_playerWoundTime[victim] = sm_moderate_revive_time.IntValue;
			g_playerWoundType[victim] = 1;
		}
		else if (dmg_taken > sm_moderate_wound_dmg.IntValue) {
			g_playerWoundTime[victim] = sm_critical_revive_time.IntValue;
			g_playerWoundType[victim] = 2;
		}
	}
	else
	{
		g_playerWoundTime[victim] = -1;
		g_playerWoundType[victim] = -1;
	}

	return Plugin_Continue;
}

/*
public Action Event_PlayerDeath_Pre(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (g_iEnableRevive && g_iRoundStatus && sm_respawn_enable_track_ammo.BoolValue)
	{
		int primaryWeapon = GetPlayerWeaponSlot(client, 0);
		int secondaryWeapon = GetPlayerWeaponSlot(client, 1);
		
		playerClip[client][0] = GetPrimaryAmmo(client, primaryWeapon, 0);
		playerClip[client][1] = GetPrimaryAmmo(client, secondaryWeapon, 1);

		if (!playerInRevivedState[client])
		{
			if (primaryWeapon != -1 && IsValidEntity(primaryWeapon))
				Client_GetWeaponPlayerAmmoEx(client, primaryWeapon, playerAmmo[client][0]);
			if (secondaryWeapon != -1 && IsValidEntity(secondaryWeapon))
				Client_GetWeaponPlayerAmmoEx(client, secondaryWeapon, playerAmmo[client][1]);
		}
		
		playerInRevivedState[client] = false;
	}
}
*/

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	//if (client > 0 && IsClientInGame(client))
	//	GetClientAbsOrigin(client, g_DeathOrigin[client]);
	
	if (!(0 < attacker <= MaxClients) || !IsClientInGame(client)) 
		return;
	
	g_iPlayerBGroups[client] = GetEntProp(client, Prop_Send, "m_nBody");

	int dmg_taken = event.GetInt("damagebits");
	
	if (dmg_taken <= 0) 
	{
		g_playerWoundTime[client] = sm_minor_revive_time.IntValue;
		g_playerWoundType[client] = 0;
	}

	int team = GetClientTeam(client);
	int attackerTeam = GetClientTeam(attacker);

	if (team == TEAM_2_INS && g_iRoundStatus && attackerTeam == TEAM_1_SEC) 
	{
		g_AIDir_BotsKilledCount++;
		
		if (g_AIDir_BotsKilledCount > (GetTeamSecCount() / g_AIDir_BotsKilledReq_mult)) 
		{
			g_AIDir_BotsKilledCount = 0;
			g_AIDir_TeamStatus += 1;
		}
	}

	if (team == TEAM_1_SEC && g_iRoundStatus) 
	{
		if (g_iHurtFatal[client] == 1)
			g_AIDir_TeamStatus -= 3;
		else 
			g_AIDir_TeamStatus -= 2;
		
		if ((StrContains(g_client_last_classstring[client], "medic") > -1)) 
			g_AIDir_TeamStatus -= 3;
	}
	
	g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);

	if (sm_revive_enabled.BoolValue) 
	{
		if (team == TEAM_1_SEC) 
		{
			GetClientAbsOrigin(client, g_fDeadPosition[client]);
			
			if (g_iEnableRevive && g_iRoundStatus) 
				CreateTimer(5.0, ConvertDeleteRagdoll, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	if (sm_respawn_enabled.BoolValue) 
	{
		if ((team == TEAM_1_SEC) || (team == TEAM_2_INS)) 
		{
			int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
			int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

			if (g_isCheckpoint && Ins_InCounterAttack() && (((acp + 1) == ncp &&  sm_respawn_final_counterattack_type.IntValue == 2) || ((acp + 1) != ncp && sm_respawn_counterattack_type.IntValue == 2))) 
			{
				if ((sm_respawn_type_team_ins.IntValue == 1 && team == TEAM_2_INS) && (((acp + 1) == ncp &&  sm_respawn_final_counterattack_type.IntValue == 2) || ((acp + 1) != ncp && sm_respawn_counterattack_type.IntValue == 2))) 
				{
					if ((g_iSpawnTokens[client] < g_iRespawnCount[team])) 
						g_iSpawnTokens[client] = (g_iRespawnCount[team] + 1);

					CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (sm_respawn_type_team_sec.IntValue == 1 && team == TEAM_1_SEC) 
				{
					if (g_iSpawnTokens[client] > 0) 
					{
						if (team == TEAM_1_SEC) 
							CreatePlayerRespawnTimer(client);
					}
					else if (g_iSpawnTokens[client] <= 0 && g_iRespawnCount[team] > 0) 
					{
						char sChat[128];
						Format(sChat, 128,"You cannot be respawned anymore. (out of lives)");
						PrintToChat(client, "%s", sChat);
					}
				}
				else if (team == TEAM_1_SEC && sm_respawn_type_team_sec.IntValue == 2 && g_iRespawn_lives_team_sec > 0) 
				{
					g_iRemaining_lives_team_sec = g_iRespawn_lives_team_sec + 1;
					CreateTimer(0.0, RespawnPlayerCounter, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (team == TEAM_2_INS && sm_respawn_type_team_ins.IntValue == 2 && (g_iRespawn_lives_team_ins > 0 || ((acp + 1) == ncp && sm_respawn_final_counterattack_type.IntValue == 2) || ((acp + 1) != ncp && sm_respawn_counterattack_type.IntValue == 2))) 
				{
					g_iRemaining_lives_team_ins = g_iRespawn_lives_team_ins + 1;
					CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else if ((sm_respawn_type_team_sec.IntValue == 1 && team == TEAM_1_SEC) || (sm_respawn_type_team_ins.IntValue == 1 && team == TEAM_2_INS)) 
			{
				if (g_iSpawnTokens[client] > 0) 
				{
					if (team == TEAM_1_SEC) 
						CreatePlayerRespawnTimer(client);
					else if (team == TEAM_2_INS) 
						CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
				else if (g_iSpawnTokens[client] <= 0 && g_iRespawnCount[team] > 0) 
				{
					char sChat[128];
					Format(sChat, 128,"You cannot be respawned anymore. (out of lives)");
					PrintToChat(client, "%s", sChat);
				}
			}
			else if (sm_respawn_type_team_sec.IntValue == 2 && team == TEAM_1_SEC) 
			{
				if (g_iRemaining_lives_team_sec > 0) 
					CreatePlayerRespawnTimer(client);
				else if (g_iRemaining_lives_team_sec <= 0 && g_iRespawn_lives_team_sec > 0) 
				{
					char sChat[128];
					Format(sChat, 128,"You cannot be respawned anymore. (out of team lives)");
					PrintToChat(client, "%s", sChat);
				}
			}
			else if (sm_respawn_type_team_ins.IntValue == 2 && g_iRemaining_lives_team_ins >  0 && team == TEAM_2_INS) 
				CreateTimer(sm_respawn_delay_team_ins.FloatValue, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	char wound_hint[64];
	char fatal_hint[64];
	char woundType[64];
	
	if (g_playerWoundType[client] == 0) 
		woundType = "MINORLY WOUNDED";
	else if (g_playerWoundType[client] == 1) 
		woundType = "MODERATELY WOUNDED";
	else if (g_playerWoundType[client] == 2) 
		woundType = "CRITCALLY WOUNDED";

	if (sm_respawn_fatal_chance.FloatValue > 0.0) 
	{
		if (g_iHurtFatal[client] == 1 && !IsFakeClient(client)) 
		{
			Format(fatal_hint, 255,"You were fatally killed for %i damage", g_clientDamageDone[client]);
			//PrintHintText(client, "%s", fatal_hint);
			//PrintToChat(client, "%s", fatal_hint);
		}
		else 
		{
			Format(wound_hint, 255,"You're %s for %i damage, call a medic for revive!", woundType, g_clientDamageDone[client]);
			//PrintHintText(client, "%s", wound_hint);
			//PrintToChat(client, "%s", wound_hint);
		}
	}
	else 
	{
		Format(wound_hint, 255,"You're %s for %i damage, call a medic for revive!", woundType, g_clientDamageDone[client]);
		//PrintHintText(client, "%s", wound_hint);
		//PrintToChat(client, "%s", wound_hint);
	}
}

public Action ConvertDeleteRagdoll(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) > 0 && IsClientInGame(client) && g_iRoundStatus && !IsPlayerAlive(client)) 
	{
		int clientRagdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		
		if (clientRagdoll > 0 && IsValidEdict(clientRagdoll) && IsValidEntity(clientRagdoll) && g_iEnableRevive)
		{
			int ref = EntIndexToEntRef(clientRagdoll);
			
			if (ref != INVALID_ENT_REFERENCE)
			{
				int entity = EntRefToEntIndex(ref);
				
				if (IsValidEntity(entity))
				{
					AcceptEntityInput(entity, "Kill");
					clientRagdoll = INVALID_ENT_REFERENCE;
				}
			}
		}
		
		if (g_iHurtFatal[client] != 1)
		{
			int tempRag = CreateEntityByName("prop_ragdoll");
			
			if (IsValidEntity(tempRag))
			{
				g_clientRagdolls[client]  = EntIndexToEntRef(tempRag);
				g_fDeadPosition[client][2] += 50;
				
				char sModelName[64];
				GetClientModel(client, sModelName, sizeof(sModelName));
				
				SetEntityModel(tempRag, sModelName);
				DispatchSpawn(tempRag);
				
				SetEntProp(tempRag, Prop_Send, "m_CollisionGroup", 17);
				
				SetEntProp(tempRag, Prop_Send, "m_nBody", g_iPlayerBGroups[client]);
				
				TeleportEntity(tempRag, g_fDeadPosition[client], NULL_VECTOR, NULL_VECTOR);
				
				GetEntPropVector(tempRag, Prop_Send, "m_vecOrigin", g_fRagdollPosition[client]);
				
				g_iReviveRemainingTime[client] = g_playerWoundTime[client];
				g_iReviveNonMedicRemainingTime[client] = sm_non_medic_revive_time.IntValue;
			}
		}
	}
}

void RemoveRagdoll(int client)
{
	int entity = EntRefToEntIndex(g_clientRagdolls[client]);
	
	if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "Kill");
		g_clientRagdolls[client] = INVALID_ENT_REFERENCE;
	}	
}

void CreatePlayerRespawnTimer(int client)
{
	if (g_iPlayerRespawnTimerActive[client] == 0)
	{
		g_iPlayerRespawnTimerActive[client] = 1;
		int timeReduce = (GetTeamSecCount() / 3);
		
		if (timeReduce <= 0)
			timeReduce = 3;

		int jammerSpawnReductionAmt = (g_iRespawnSeconds / timeReduce);
		g_iRespawnTimeRemaining[client] = (g_iRespawnSeconds - jammerSpawnReductionAmt);
		
		if (g_iRespawnTimeRemaining[client] < 5)
			g_iRespawnTimeRemaining[client] = 5;
		else
			g_iRespawnTimeRemaining[client] = g_iRespawnSeconds;
		
		if (sm_respawn_mode_team_sec.BoolValue)
			g_iRespawnTimeRemaining[client] = g_secWave_Timer;

		CreateTimer(1.0, Timer_PlayerRespawn, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action RespawnPlayerRevive(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) == 0 || IsPlayerAlive(client) || !IsClientInGame(client) || !g_iRoundStatus)
		return;
	
	SDKCall(g_hForceRespawn, client);
	
	
/*
	if (playerRevived[client] && sm_respawn_enable_track_ammo.BoolValue)
	{
		playerInRevivedState[client] = true;
		SetPlayerAmmo(client);
	}
*/	
	
	int iHealth = GetClientHealth(client);
	if (g_playerNonMedicRevive[client] == 0)
	{
		if (g_playerWoundType[client] == 0)
			iHealth = sm_medic_minor_revive_hp.IntValue;
		else if (g_playerWoundType[client] == 1)
			iHealth = sm_medic_moderate_revive_hp.IntValue;
		else if (g_playerWoundType[client] == 2)
			iHealth = sm_medic_critical_revive_hp.IntValue;
	}
	else if (g_playerNonMedicRevive[client] == 1)
		iHealth = sm_non_medic_revive_hp.IntValue;

	SetEntityHealth(client, iHealth);
	
	int playerRag = EntRefToEntIndex(g_clientRagdolls[client]);
	
	if (playerRag > 0 && IsValidEdict(playerRag) && IsValidEntity(playerRag))
		RemoveRagdoll(client);
	
	RespawnPlayerRevivePost(null, client);
	


	if ((StrContains(g_client_last_classstring[client], "medic") > -1))
		g_AIDir_TeamStatus += 2;
	else
		g_AIDir_TeamStatus += 1;
	
	g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);
}


public Action RespawnPlayerRevivePost(Handle timer, any client)
{
	if (!IsClientInGame(client))
		return;
	
	TeleportEntity(client, g_fRagdollPosition[client], NULL_VECTOR, NULL_VECTOR);
	
	int m_iTeam = GetClientTeam(client);
	
	if ((IsClientConnected(client)) && (IsPlayerAlive(client)) && m_iTeam == TEAM_1_SEC)
	{	
		int iHealth = GetClientHealth(client);
		
		if (iHealth < 100)
			SetEntityHealth(client, 100);
		
		playerInRevivedState[client] = false;
	}
	
	g_fRagdollPosition[client][0] = 0.0;
	g_fRagdollPosition[client][1] = 0.0;
	g_fRagdollPosition[client][2] = 0.0;
}

public Action RespawnPlayerCounter(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) == 0 || !IsClientInGame(client) || IsPlayerAlive(client) || !g_iRoundStatus)
		return;
	
	SDKCall(g_hForceRespawn, client);

	int playerRag = EntRefToEntIndex(g_clientRagdolls[client]);
	
	if (playerRag > 0 && IsValidEdict(playerRag) && IsValidEntity(playerRag))
		RemoveRagdoll(client);

	if (g_fRespawnPosition[0] != 0.0 && g_fRespawnPosition[1] != 0.0 && g_fRespawnPosition[2] != 0.0)
		TeleportEntity(client, g_fRespawnPosition, NULL_VECTOR, NULL_VECTOR);

	g_fRagdollPosition[client][0] = 0.0;
	g_fRagdollPosition[client][1] = 0.0;
	g_fRagdollPosition[client][2] = 0.0;
}

public Action RespawnBot(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) == 0 || !IsClientInGame(client) || IsPlayerAlive(client) || !g_iRoundStatus)
		return;	
	
	char sModelName[64];
	GetClientModel(client, sModelName, sizeof(sModelName));
	
	if (strlen(sModelName) == 0)
		return;	
	
	if (sm_respawn_type_team_ins.IntValue == 1 && g_iSpawnTokens[client] > 0)
		g_iSpawnTokens[client]--;
	else if (sm_respawn_type_team_ins.IntValue == 2)
	{
		if (g_iRemaining_lives_team_ins > 0)
		{
			g_iRemaining_lives_team_ins--;
			
			if (g_iRemaining_lives_team_ins <= 0)
				g_iRemaining_lives_team_ins = 0;
		}
	}
	
	SDKCall(g_hForceRespawn, client);
	FixSpawnPoint(client);
	//TeleportEntity(client, g_DeathOrigin[client], NULL_VECTOR, NULL_VECTOR);
}

public Action Timer_PlayerRespawn(Handle timer, any data)
{
	int client;
	if ((client = GetClientOfUserId(data)) == 0 || !IsClientInGame(client))
		return Plugin_Stop;
	
	char sRemainingTime[256];
	if (!IsPlayerAlive(client) && g_iRoundStatus)
	{
		if (g_iRespawnTimeRemaining[client] > 0)
		{   
			if (g_playerFirstJoin[client] == 1)
			{
				char woundType[128];
				bool tIsFatal;
			   
				if (g_iHurtFatal[client] == 1)
				{
					woundType = "fatally killed";
					tIsFatal = true;
				}
				else
				{
					woundType = "WOUNDED";
					if (g_playerWoundType[client] == 0)
						woundType = "MINORLY WOUNDED";
					else if (g_playerWoundType[client] == 1)
						woundType = "MODERATELY WOUNDED";
					else if (g_playerWoundType[client] == 2)
						woundType = "CRITCALLY WOUNDED";
				}

				if (!IsFakeClient(client))
				{
					if (tIsFatal)
						Format(sRemainingTime, sizeof(sRemainingTime),"Reinforcing in %d second%s (%d lives left) ", woundType, g_clientDamageDone[client], g_iRespawnTimeRemaining[client], (g_iRespawnTimeRemaining[client] > 1 ? "s" : ""), g_iSpawnTokens[client]);
					else
						Format(sRemainingTime, sizeof(sRemainingTime),"%s for %d damage | wait patiently for a medic\n\n reinforcing in %d second%s (%d lives left) ", woundType, g_clientDamageDone[client], g_iRespawnTimeRemaining[client], (g_iRespawnTimeRemaining[client] > 1 ? "s" : ""), g_iSpawnTokens[client]);
					
					PrintCenterText(client, sRemainingTime);
				}
			}
			
			g_iRespawnTimeRemaining[client]--;
		}
		else
		{
			if (sm_respawn_type_team_sec.IntValue == 1)
				g_iSpawnTokens[client]--;
			else if (sm_respawn_type_team_sec.IntValue == 2)
				g_iRemaining_lives_team_sec--;
			
			SDKCall(g_hForceRespawn, client);

			if ((StrContains(g_client_last_classstring[client], "medic") > -1))
				g_AIDir_TeamStatus += 2;
			else
				g_AIDir_TeamStatus += 1;

			g_AIDir_TeamStatus = AI_Director_SetMinMax(g_AIDir_TeamStatus, g_AIDir_TeamStatus_min, g_AIDir_TeamStatus_max);
			
			if (!IsFakeClient(client))
				PrintCenterText(client, "You reinforced! (%d lives left)", g_iSpawnTokens[client]);
			
			int playerRag = EntRefToEntIndex(g_clientRagdolls[client]);
			
			if (playerRag > 0 && IsValidEdict(playerRag) && IsValidEntity(playerRag))
				RemoveRagdoll(client);
			
			g_fRagdollPosition[client][0] = 0.0;
			g_fRagdollPosition[client][1] = 0.0;
			g_fRagdollPosition[client][2] = 0.0;

			if (!sm_respawn_mode_team_sec.BoolValue)
				PrintToChatAll("\x05%N\x01 reinforced..", client);

			g_iPlayerRespawnTimerActive[client] = 0;
			return Plugin_Stop;
		}
	}
	else
	{
		g_iPlayerRespawnTimerActive[client] = 0; 
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}


public Action Timer_ReviveMonitor(Handle timer, any data)
{
	if (!g_iRoundStatus)
		return Plugin_Continue;
	
	float fReviveDistance = 65.0;
	int iInjured;
	int iInjuredRagdoll;
	float fRagPos[3];
	float fMedicPos[3];
	float fDistance;
	
	for (int iMedic = 1; iMedic <= MaxClients; iMedic++)
	{
		if (!IsClientInGame(iMedic) || IsFakeClient(iMedic))
			continue;
		
		if (IsPlayerAlive(iMedic) && (StrContains(g_client_last_classstring[iMedic], "medic") > -1))
		{
			iInjured = g_iNearestBody[iMedic];
			
			if (iInjured > 0 && IsClientInGame(iInjured) && !IsPlayerAlive(iInjured) && g_iHurtFatal[iInjured] == 0  && iInjured != iMedic && GetClientTeam(iMedic) == GetClientTeam(iInjured))
			{
				GetClientAbsOrigin(iMedic, fMedicPos);
				
				iInjuredRagdoll = EntRefToEntIndex(g_clientRagdolls[iInjured]);
				
				if (iInjuredRagdoll > 0 && iInjuredRagdoll != INVALID_ENT_REFERENCE && IsValidEdict(iInjuredRagdoll) && IsValidEntity(iInjuredRagdoll))
				{
					GetEntPropVector(iInjuredRagdoll, Prop_Send, "m_vecOrigin", fRagPos);
					
					g_fRagdollPosition[iInjured] = fRagPos;
					
					fDistance = GetVectorDistance(fRagPos,fMedicPos);
				}
				else
					continue;
				
				int ActiveWeapon = GetEntPropEnt(iMedic, Prop_Data, "m_hActiveWeapon");
				
				if (ActiveWeapon < 0)
					continue;
				
				char sWeapon[32];
				GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));
				
				if (fDistance < fReviveDistance && (ClientCanSeeVector(iMedic, fRagPos, fReviveDistance))  && ((StrContains(sWeapon, "weapon_defib") > -1) || (StrContains(sWeapon, "weapon_knife") > -1) || (StrContains(sWeapon, "weapon_kabar") > -1)))
				{
					char sBuf[255];
					
					if (g_iReviveRemainingTime[iInjured] > 0)
					{
						char woundType[64];
						if (g_playerWoundType[iInjured] == 0)
							woundType = "Minor wound";
						else if (g_playerWoundType[iInjured] == 1)
							woundType = "Moderate wound";
						else if (g_playerWoundType[iInjured] == 2)
							woundType = "Critical wound";

						Format(sBuf, 255,"Reviving %N in: %i seconds (%s)", iInjured, g_iReviveRemainingTime[iInjured], woundType);
						PrintHintText(iMedic, "%s", sBuf);
						
						Format(sBuf, 255,"%N is reviving you in: %i seconds (%s)", iMedic, g_iReviveRemainingTime[iInjured], woundType);
						PrintHintText(iInjured, "%s", sBuf);
						
						g_iReviveRemainingTime[iInjured]--;
						
						g_iRespawnTimeRemaining[iInjured]++;
					}
					else if (g_iReviveRemainingTime[iInjured] <= 0)
					{	
						char woundType[64];
						if (g_playerWoundType[iInjured] == 0)
							woundType = "minor wound";
						else if (g_playerWoundType[iInjured] == 1)
							woundType = "moderate wound";
						else if (g_playerWoundType[iInjured] == 2)
							woundType = "critical wound";
						
						Format(sBuf, 255,"You revived %N", iInjured, woundType);
						PrintHintText(iMedic, "%s", sBuf);
						
						Format(sBuf, 255,"%N revived you", iMedic, woundType);
						PrintHintText(iInjured, "%s", sBuf);
						g_iStatRevives[iMedic]++;
			
						g_playerMedicRevivessAccumulated[iMedic]++;
						int iReviveCap = sm_revive_cap_for_bonus.IntValue;

						Format(sBuf, 255,"You revived %N ", iInjured, woundType, (iReviveCap - g_playerMedicRevivessAccumulated[iMedic]));
						PrintHintText(iMedic, "%s", sBuf);
						
						if (g_playerMedicRevivessAccumulated[iMedic] >= iReviveCap)
						{
							g_playerMedicRevivessAccumulated[iMedic] = 0;
							g_iSpawnTokens[iMedic]++;
						}

						g_fRagdollPosition[iInjured] = fRagPos;
						
						playerRevived[iInjured] = true;
						
						g_playerNonMedicRevive[iInjured] = 0;
						CreateTimer(0.0, RespawnPlayerRevive, GetClientUserId(iInjured), TIMER_FLAG_NO_MAPCHANGE);
						continue;
					}
				}
			}
		}
		else if (IsPlayerAlive(iMedic) && !(StrContains(g_client_last_classstring[iMedic], "medic") > -1))
		{
			iInjured = g_iNearestBody[iMedic];
			
			if (iInjured > 0 && IsClientInGame(iInjured) && !IsPlayerAlive(iInjured) && g_iHurtFatal[iInjured] == 0 && iInjured != iMedic && GetClientTeam(iMedic) == GetClientTeam(iInjured))
			{
				GetClientAbsOrigin(iMedic, fMedicPos);
				
				iInjuredRagdoll = EntRefToEntIndex(g_clientRagdolls[iInjured]);
				
				if (iInjuredRagdoll > 0 && iInjuredRagdoll != INVALID_ENT_REFERENCE && IsValidEdict(iInjuredRagdoll) && IsValidEntity(iInjuredRagdoll))
				{
					GetEntPropVector(iInjuredRagdoll, Prop_Send, "m_vecOrigin", fRagPos);
					
					g_fRagdollPosition[iInjured] = fRagPos;
					
					fDistance = GetVectorDistance(fRagPos,fMedicPos);
				}
				else
					continue;
				
				int ActiveWeapon = GetEntPropEnt(iMedic, Prop_Data, "m_hActiveWeapon");
				
				if (ActiveWeapon < 0)
					continue;
				
				char sWeapon[32];
				GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));
				
				if (fDistance < fReviveDistance && (ClientCanSeeVector(iMedic, fRagPos, fReviveDistance)) && ((StrContains(sWeapon, "healthkit") > -1)))
				{
					char sBuf[255];
					
					if (g_iReviveNonMedicRemainingTime[iInjured] > 0)
					{
						if (g_playerWoundType[iInjured] == 0 || g_playerWoundType[iInjured] == 1 || g_playerWoundType[iInjured] == 2)
						{
							char woundType[64];
							if (g_playerWoundType[iInjured] == 0)
								woundType = "Minor wound";
							else if (g_playerWoundType[iInjured] == 1)
								woundType = "Moderate wound";
							else if (g_playerWoundType[iInjured] == 2)
								woundType = "Critical wound";

							Format(sBuf, 255,"Reviving %N in: %i seconds (%s)", iInjured, g_iReviveNonMedicRemainingTime[iInjured], woundType);
							PrintHintText(iMedic, "%s", sBuf);
							
							Format(sBuf, 255,"%N is reviving you in: %i seconds (%s)", iMedic, g_iReviveNonMedicRemainingTime[iInjured], woundType);
							PrintHintText(iInjured, "%s", sBuf);
							
							g_iReviveNonMedicRemainingTime[iInjured]--;
						}

						g_iRespawnTimeRemaining[iInjured]++;
					}
					else if (g_iReviveNonMedicRemainingTime[iInjured] <= 0)
					{	
						char woundType[64];
						if (g_playerWoundType[iInjured] == 0)
							woundType = "minor wound";
						else if (g_playerWoundType[iInjured] == 1)
							woundType = "moderate wound";
						else if (g_playerWoundType[iInjured] == 2)
							woundType = "critical wound";

						Format(sBuf, 255,"\x05%N\x01 revived \x03%N from a %s", iMedic, iInjured, woundType);
						
						Format(sBuf, 255,"You revived %N from a %s", iInjured, woundType);
						PrintHintText(iMedic, "%s", sBuf);
						
						Format(sBuf, 255,"%N revived you from a %s", iMedic, woundType);
						PrintHintText(iInjured, "%s", sBuf);
						
						g_iStatRevives[iMedic]++;
						
						g_playerMedicRevivessAccumulated[iMedic]++;
						int iReviveCap = sm_revive_cap_for_bonus.IntValue;

						if (g_playerMedicRevivessAccumulated[iMedic] >= iReviveCap)
						{
							g_playerMedicRevivessAccumulated[iMedic] = 0;
							g_iSpawnTokens[iMedic]++;
						}
						
						g_fRagdollPosition[iInjured] = fRagPos;
						
						playerRevived[iInjured] = true;
						
						g_playerNonMedicRevive[iInjured] = 1;
						CreateTimer(0.0, RespawnPlayerRevive, GetClientUserId(iInjured), TIMER_FLAG_NO_MAPCHANGE);
						RemovePlayerItem(iMedic,ActiveWeapon);
						ChangePlayerWeaponSlot(iMedic, 2);
						continue;
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_MedicMonitor(Handle timer, any data)
{
	if (!g_iRoundStatus)
		return Plugin_Continue;
	
	for (int medic = 1; medic <= MaxClients; medic++)
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(medic) || IsFakeClient(medic))
			continue;
		
		int iTeam = GetClientTeam(medic);
		
		if (iTeam == TEAM_1_SEC && IsPlayerAlive(medic) && StrContains(g_client_last_classstring[medic], "medic") > -1)
		{
			int iTarget = TraceClientViewEntity(medic);
			if (iTarget > 0 && iTarget <= MaxClients && IsClientInGame(iTarget) && IsPlayerAlive(iTarget) && iTeam == GetClientTeam(iTarget))
			{
				bool bCanHealPaddle;
				bool bCanHealMedpack;
				float fReviveDistance = 80.0;
				
				float vecMedicPos[3];
				GetClientAbsOrigin(medic, vecMedicPos);
				
				float vecTargetPos[3];
				GetClientAbsOrigin(iTarget, vecTargetPos);
				float tDistance = GetVectorDistance(vecMedicPos,vecTargetPos);
				
				if (tDistance < fReviveDistance && ClientCanSeeVector(medic, vecTargetPos, fReviveDistance))
				{
					int ActiveWeapon = GetEntPropEnt(medic, Prop_Data, "m_hActiveWeapon");
					
					if (ActiveWeapon < 0)
						continue;
					
					char sWeapon[32];
					GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));
					
					if ((StrContains(sWeapon, "weapon_defib") > -1) || (StrContains(sWeapon, "weapon_knife") > -1) || (StrContains(sWeapon, "weapon_kabar") > -1))
						bCanHealPaddle = true;
					
					if ((StrContains(sWeapon, "healthkit") > -1))
						bCanHealMedpack = true;
				}

				int iHealth = GetClientHealth(iTarget);

				if (tDistance < 750.0)
					PrintHintText(medic, "%N\nHP: %i", iTarget, iHealth);

				if (bCanHealPaddle)
				{
					if (iHealth < 100)
					{
						iHealth += sm_heal_amount_paddles.IntValue;
						
						g_playerMedicHealsAccumulated[medic] += sm_heal_amount_paddles.IntValue;
						
						int iHealthCap = sm_heal_cap_for_bonus.IntValue;
						int iRewardMedicEnabled = sm_reward_medics_enabled.IntValue;

						if (g_playerMedicHealsAccumulated[medic] >= iHealthCap && iRewardMedicEnabled == 1)
						{
							g_playerMedicHealsAccumulated[medic] = 0;
							g_iSpawnTokens[medic]++;
						}
						
						if (iHealth >= 100)
						{
							g_iStatHeals[medic]++;
							
							iHealth = 100;
							
							PrintHintText(iTarget, "You were healed by %N (HP: %i)", medic, iHealth);
							
							char sBuf[255];
							Format(sBuf, 255,"You fully healed %N | Health points remaining til bonus life: %d", iTarget, (iHealthCap - g_playerMedicHealsAccumulated[medic]));
							PrintHintText(medic, "%s", sBuf);
						}
						else
							PrintHintText(iTarget, "DON'T MOVE! %N is healing you.(HP: %i)", medic, iHealth);
						
						SetEntityHealth(iTarget, iHealth);
						PrintHintText(medic, "%N\nHP: %i\n\nHealing with paddles for: %i", iTarget, iHealth, sm_heal_amount_paddles.IntValue);
					}
					else
						PrintHintText(medic, "%N\nHP: %i", iTarget, iHealth);
				}
				else if (bCanHealMedpack)
				{
					if (iHealth < 100)
					{
						iHealth += sm_heal_amount_medpack.IntValue;
						
						g_playerMedicHealsAccumulated[medic] += sm_heal_amount_medpack.IntValue;
						
						int iHealthCap = sm_heal_cap_for_bonus.IntValue;
						int iRewardMedicEnabled = sm_reward_medics_enabled.IntValue;
						
						if (g_playerMedicHealsAccumulated[medic] >= iHealthCap && iRewardMedicEnabled == 1)
						{
							g_playerMedicHealsAccumulated[medic] = 0;
							g_iSpawnTokens[medic]++;
						}
						
						if (iHealth >= 100)
						{
							g_iStatHeals[medic]++;
							iHealth = 100;
							PrintHintText(iTarget, "You were healed by %N (HP: %i)", medic, iHealth);
							
							char sBuf[255];
							Format(sBuf, 255,"You fully healed %N | Health points remaining til bonus life: %d", iTarget, (iHealthCap - g_playerMedicHealsAccumulated[medic]));
							PrintHintText(medic, "%s", sBuf);
						}
						else
							PrintHintText(iTarget, "DON'T MOVE! %N is healing you.(HP: %i)", medic, iHealth);
						
						SetEntityHealth(iTarget, iHealth);
						PrintHintText(medic, "%N\nHP: %i\n\nHealing with medpack for: %i", iTarget, iHealth, sm_heal_amount_medpack.IntValue);
					}
					else
						PrintHintText(medic, "%N\nHP: %i", iTarget, iHealth);
				}
			}
			else
			{
				bool bCanHealMedpack;
				bool bCanHealPaddle;
				
				int ActiveWeapon = GetEntPropEnt(medic, Prop_Data, "m_hActiveWeapon");
				
				if (ActiveWeapon < 0)
					continue;
				
				char sWeapon[32];
				GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));

				if ((StrContains(sWeapon, "weapon_defib") > -1) || (StrContains(sWeapon, "weapon_knife") > -1) || (StrContains(sWeapon, "weapon_kabar") > -1))
					bCanHealPaddle = true;
				if ((StrContains(sWeapon, "healthkit") > -1))
					bCanHealMedpack = true;
				
				int iHealth = GetClientHealth(medic);
				
				if (bCanHealMedpack || bCanHealPaddle)
				{
					if (iHealth < g_medicHealSelf_max)
					{
						if (bCanHealMedpack)
							iHealth += sm_heal_amount_medpack.IntValue;
						else
							iHealth += sm_heal_amount_paddles.IntValue;

						if (iHealth >= g_medicHealSelf_max)
						{
							iHealth = g_medicHealSelf_max;
							PrintHintText(medic, "You healed yourself (HP: %i) | MAX: %i", iHealth, g_medicHealSelf_max);
						}
						else 
						{
							PrintHintText(medic, "Healing Self (HP: %i) | MAX: %i", iHealth, g_medicHealSelf_max);
						}
						
						SetEntityHealth(medic, iHealth);
					}
				}
			}
		}
		else if (iTeam == TEAM_1_SEC && IsPlayerAlive(medic) && !(StrContains(g_client_last_classstring[medic], "medic") > -1))
		{
			int ActiveWeapon = GetEntPropEnt(medic, Prop_Data, "m_hActiveWeapon");
			
			if (ActiveWeapon < 0)
				continue;
			
			char checkWeapon[32];
			GetEdictClassname(ActiveWeapon, checkWeapon, sizeof(checkWeapon));
			
			if ((StrContains(checkWeapon, "healthkit") > -1))
			{
				int iTarget = TraceClientViewEntity(medic);
				
				if (iTarget > 0 && iTarget <= MaxClients && IsClientInGame(iTarget) && IsPlayerAlive(iTarget) && iTeam == GetClientTeam(iTarget))
				{
					bool bCanHealMedpack;
					float fReviveDistance = 80.0;
					
					float vecMedicPos[3];
					GetClientAbsOrigin(medic, vecMedicPos);
					
					float vecTargetPos[3];
					GetClientAbsOrigin(iTarget, vecTargetPos);
					
					float tDistance = GetVectorDistance(vecMedicPos,vecTargetPos);
					
					if (tDistance < fReviveDistance && ClientCanSeeVector(medic, vecTargetPos, fReviveDistance))
					{
						if (ActiveWeapon < 0)
							continue;
						
						char sWeapon[32];
						GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));
						
						if ((StrContains(sWeapon, "healthkit") > -1))
							bCanHealMedpack = true;
					}
					int iHealth = GetClientHealth(iTarget);
					if (tDistance < 750.0) 
						PrintHintText(medic, "%N\nHP: %i", iTarget, iHealth);
					if (bCanHealMedpack)
					{
						if (iHealth < g_nonMedic_maxHealOther)
						{
							iHealth += sm_non_medic_heal_amt.IntValue;
							
							g_playerNonMedicHealsAccumulated[medic] += sm_non_medic_heal_amt.IntValue;
							
							int iHealthCap = sm_heal_cap_for_bonus.IntValue;
							int iRewardMedicEnabled = sm_reward_medics_enabled.IntValue;
							
							if (g_playerNonMedicHealsAccumulated[medic] >= iHealthCap && iRewardMedicEnabled == 1)
							{
								g_playerNonMedicHealsAccumulated[medic] = 0;
								g_iSpawnTokens[medic]++;
							}

							if (iHealth >= g_nonMedic_maxHealOther)
							{
								g_iStatHeals[medic]++;
								iHealth = g_nonMedic_maxHealOther;
								PrintHintText(iTarget, "Non-Medic %N can only heal you for %i HP!)", medic, iHealth);
								char sBuf[255];
								Format(sBuf, 255,"You max healed %N | Health points remaining til bonus life: %d", iTarget, (iHealthCap - g_playerNonMedicHealsAccumulated[medic]));
								PrintHintText(medic, "%s", sBuf);
							}
							else
								PrintHintText(iTarget, "DON'T MOVE! %N is healing you.(HP: %i)", medic, iHealth);
							
							SetEntityHealth(iTarget, iHealth);
							PrintHintText(medic, "%N\nHP: %i\n\nHealing.", iTarget, iHealth);
						}
						else
						{
							if (iHealth < g_nonMedic_maxHealOther)
								PrintHintText(medic, "%N\nHP: %i", iTarget, iHealth);
							else if (iHealth >= g_nonMedic_maxHealOther)
								PrintHintText(medic, "%N\nHP: %i (MAX YOU CAN HEAL)", iTarget, iHealth);
						}
					}
				}
				else
				{
					bool bCanHealMedpack;
					
					if (ActiveWeapon < 0)
						continue;
					
					char sWeapon[32];
					GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));
					
					if ((StrContains(sWeapon, "healthkit") > -1))
						bCanHealMedpack = true;

					int iHealth = GetClientHealth(medic);
					
					if (bCanHealMedpack)
					{
						if (iHealth < g_nonMedicHealSelf_max)
						{
							iHealth += sm_non_medic_heal_amt.IntValue;
							
							if (iHealth >= g_nonMedicHealSelf_max)
							{
								iHealth = g_nonMedicHealSelf_max;
								PrintHintText(medic, "You healed yourself (HP: %i) | MAX: %i", iHealth, g_nonMedicHealSelf_max);
							}
							else
								PrintHintText(medic, "Healing Self (HP: %i) | MAX: %i", iHealth, g_nonMedicHealSelf_max);
							
							SetEntityHealth(medic, iHealth);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue; 
}

public Action Timer_AIDirector_Main(Handle timer, any data)
{
	g_AIDir_ChangeCond_Counter++;
	g_AIDir_AmbushCond_Counter++;
	
	if (g_AIDir_ChangeCond_Counter >= g_AIDir_ChangeCond_Rand)
	{
		g_AIDir_ChangeCond_Counter = 0;
		g_AIDir_ChangeCond_Rand = GetRandomInt(g_AIDir_ChangeCond_Min, g_AIDir_ChangeCond_Max);
		AI_Director_SetDifficulty();
	}

	if (g_AIDir_AmbushCond_Counter >= g_AIDir_AmbushCond_Rand)
	{
		if (GetRandomInt(0, 100) <= g_AIDir_AmbushCond_Chance)
		{
			g_AIDir_AmbushCond_Counter = 0;
			g_AIDir_AmbushCond_Rand = GetRandomInt(g_AIDir_AmbushCond_Min, g_AIDir_AmbushCond_Max);
			AI_Director_RandomEnemyReinforce();
		}
		else
		{
			g_AIDir_AmbushCond_Counter = 0;
			g_AIDir_AmbushCond_Rand = GetRandomInt(g_AIDir_AmbushCond_Min, g_AIDir_AmbushCond_Max);
		}
	}

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");
	
	if ((acp + 1) == ncp && sm_finale_counter_spec_enabled.BoolValue)
		g_dynamicSpawnCounter_Perc = sm_finale_counter_spec_percent.IntValue;
	
	return Plugin_Continue;
}

/*public Action Timer_AmbientRadio(Handle timer, any data)
{
	if (!g_iRoundStatus)
		return Plugin_Continue;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i))
			continue;
		
		if (((StrContains(g_client_last_classstring[i], "squadleader") > -1) || (StrContains(g_client_last_classstring[i], "teamleader") > -1)) && GetClientTeam(i) == TEAM_1_SEC && GetRandomInt(1, 100) < 50)
			CreateTimer(GetRandomFloat(1.0, 30.0), Timer_PlayAmbient, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Continue;

}*/

/*public Action Timer_PlayAmbient(Handle timer, any data) 
{
	int client;
	if ((client = GetClientOfUserId(data)) == 0)
		return Plugin_Continue;

	switch (GetRandomInt(1, 10)) 
	{
		case 1: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_01.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 2: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_02.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 3: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_03.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 4: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_04.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 5: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_oneshot_01.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 6: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_oneshot_02.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 7: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_oneshot_03.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 8: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_oneshot_04.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 9: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_oneshot_05.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
		case 10: EmitSoundToAll("soundscape/emitters/oneshot/mil_radio_oneshot_06.ogg", client, SNDCHAN_VOICE, _, _, 1.0);
	}
	
	return Plugin_Continue;
}*/

public Action Timer_NearestBody(Handle timer, any data)
{
	if (!g_iRoundStatus)
		return Plugin_Continue;
	
	float fMedicPosition[3];
	float fMedicAngles[3];
	float fInjuredPosition[3];
	float fNearestDistance;
	float fTempDistance;

	char iNearestInjured;
	char sDirection[64];
	char sDistance[64];
	char sHeight[6];

	for (int medic = 1; medic <= MaxClients; medic++)
	{
		if (!IsClientInGame(medic) || IsFakeClient(medic) || !IsPlayerAlive(medic))
			continue;
		
		if (StrContains(g_client_last_classstring[medic], "medic") > -1)
		{
			iNearestInjured = 0;
			fNearestDistance = 0.0;
			
			GetClientAbsOrigin(medic, fMedicPosition);

			for (int search = 1; search <= MaxClients; search++)
			{
				if (!IsClientInGame(search) || IsFakeClient(search) || IsPlayerAlive(search))
					continue;
				
				if (g_iHurtFatal[search] == 0 && search != medic && GetClientTeam(medic) == GetClientTeam(search))
				{
					int clientRagdoll = EntRefToEntIndex(g_clientRagdolls[search]);
					
					if (clientRagdoll > 0 && IsValidEdict(clientRagdoll) && IsValidEntity(clientRagdoll) && clientRagdoll != INVALID_ENT_REFERENCE)
					{
						fInjuredPosition = g_fRagdollPosition[search];
						
						fTempDistance = GetVectorDistance(fMedicPosition, fInjuredPosition);

						if (fNearestDistance == 0.0)
						{
							fNearestDistance = fTempDistance;
							iNearestInjured = search;
						}
						else if (fTempDistance < fNearestDistance)
						{
							fNearestDistance = fTempDistance;
							iNearestInjured = search;
						}
					}
				}
			}
			
			if (iNearestInjured != 0)
			{
				g_iNearestBody[medic] = iNearestInjured;
				
				GetClientAbsAngles(medic, fMedicAngles);
				
				sDirection = GetDirectionString(fMedicAngles, fMedicPosition, fInjuredPosition);
				sDistance = GetDistanceString(fNearestDistance);
				sHeight = GetHeightString(fMedicPosition, fInjuredPosition);
				
				PrintCenterText(medic, "Nearest dead: %N ( %s | %s | %s )", iNearestInjured, sDistance, sDirection, sHeight);
				
				float beamPos[3];
				beamPos = fInjuredPosition;
				beamPos[2] += 0.3;
				
				if (fTempDistance >= 140)
				{
					TE_SetupBeamRingPoint(beamPos, 1.0, REVIVE_INDICATOR_RADIUS, g_iBeaconBeam, g_iBeaconHalo, 0, 15, 5.0, 3.0, 5.0, {255, 0, 0, 255}, 1, (FBEAM_FADEIN, FBEAM_FADEOUT));
					TE_SendToClient(medic);
				}
			}
			else
				g_iNearestBody[medic] = -1;
		}
		else if (!(StrContains(g_client_last_classstring[medic], "medic") > -1))
		{
			iNearestInjured = 0;
			fNearestDistance = 0.0;
			
			GetClientAbsOrigin(medic, fMedicPosition);
			
			int clientRagdoll;
			for (int search = 1; search <= MaxClients; search++)
			{
				if (!IsClientInGame(search) || IsFakeClient(search) || IsPlayerAlive(search) || g_iHurtFatal[search] != 0 || search == medic || GetClientTeam(medic) != GetClientTeam(search))
					continue;
				
				if ((clientRagdoll = EntRefToEntIndex(g_clientRagdolls[search])) > 0 && IsValidEdict(clientRagdoll) && IsValidEntity(clientRagdoll) && clientRagdoll != INVALID_ENT_REFERENCE)
				{
					fInjuredPosition = g_fRagdollPosition[search];
					fTempDistance = GetVectorDistance(fMedicPosition, fInjuredPosition);

					if (fNearestDistance == 0.0)
					{
						fNearestDistance = fTempDistance;
						iNearestInjured = search;
					}
					else if (fTempDistance < fNearestDistance)
					{
						fNearestDistance = fTempDistance;
						iNearestInjured = search;
					}
				}
			}
			
			if (iNearestInjured != 0)
				g_iNearestBody[medic] = iNearestInjured;
			else
				g_iNearestBody[medic] = -1;
		}
	}
	
	return Plugin_Continue;
}

char[] GetDirectionString(float fClientAngles[3], float fClientPosition[3], float fTargetPosition[3])
{
	float fTempAngles[3], fTempPoints[3];
	char sDirection[64];

	MakeVectorFromPoints(fClientPosition, fTargetPosition, fTempPoints);
	GetVectorAngles(fTempPoints, fTempAngles);
	
	float fDiff = fClientAngles[1] - fTempAngles[1];
	
	if (fDiff < -180)
		fDiff = 360 + fDiff;

	if (fDiff > 180)
		fDiff = 360 - fDiff;
	
	if (fDiff >= -22.5 && fDiff < 22.5)
		Format(sDirection, sizeof(sDirection), "FWD");
	else if (fDiff >= 22.5 && fDiff < 67.5)
		Format(sDirection, sizeof(sDirection), "FWD-RIGHT");
	else if (fDiff >= 67.5 && fDiff < 112.5)
		Format(sDirection, sizeof(sDirection), "RIGHT");
	else if (fDiff >= 112.5 && fDiff < 157.5)
		Format(sDirection, sizeof(sDirection), "BACK-RIGHT");
	else if (fDiff >= 157.5 || fDiff < -157.5)
		Format(sDirection, sizeof(sDirection), "BACK");
	else if (fDiff >= -157.5 && fDiff < -112.5)
		Format(sDirection, sizeof(sDirection), "BACK-LEFT");
	else if (fDiff >= -112.5 && fDiff < -67.5)
		Format(sDirection, sizeof(sDirection), "LEFT");
	else if (fDiff >= -67.5 && fDiff < -22.5)
		Format(sDirection, sizeof(sDirection), "FWD-LEFT");
	
	return sDirection;
}

char GetDistanceString(float fDistance)
{
	float fTempDistance = fDistance * 0.01905;
	char sResult[64];

	if (sm_revive_distance_metric.BoolValue)
	{
		fTempDistance = fTempDistance * 3.2808399;
		Format(sResult, sizeof(sResult), "%.0f feet", fTempDistance);
	}
	else
		Format(sResult, sizeof(sResult), "%.0f meter", fTempDistance);
	
	return sResult;
}

char[] GetHeightString(float fClientPosition[3], float fTargetPosition[3]) 
{
	char s[6];

	if (fClientPosition[2]+64 < fTargetPosition[2]) 
		s = "ABOVE";
	else if (fClientPosition[2]-64 > fTargetPosition[2]) 
		s = "BELOW";
	else 
		s = "LEVEL";

	return s;
}

void TagsCheck(const char[] tag, bool remove = false) 
{
	ConVar hTags = FindConVar("sv_tags");
	
	char tags[255];
	hTags.GetString(tags, sizeof(tags));

	if (StrContains(tags, tag, false) == -1 && !remove) 
	{
		char newTags[255];
		Format(newTags, sizeof(newTags), "%s,%s", tags, tag);
		ReplaceString(newTags, sizeof(newTags), ",,", ",", false);
		hTags.SetString(newTags);
		hTags.GetString(tags, sizeof(tags));
	}
	else if (StrContains(tags, tag, false) > -1 && remove) 
	{
		ReplaceString(tags, sizeof(tags), tag, "", false);
		ReplaceString(tags, sizeof(tags), ",,", ",", false);
		hTags.SetString(tags);
	}
}

int GetTeamSecCount()
{
	int clients;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && IsClientConnected(i) && GetClientTeam(i) == TEAM_1_SEC)
			clients++;
	
	return clients;
}

int TraceClientViewEntity(int client) 
{
	float m_vecOrigin[3];
	GetClientEyePosition(client, m_vecOrigin);
	
	float m_angRotation[3];
	GetClientEyeAngles(client, m_angRotation);
	
	Handle tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_VISIBLE, RayType_Infinite, TRDontHitSelf, client);
	int pEntity = -1;

	if (TR_DidHit(tr))
		pEntity = TR_GetEntityIndex(tr);
	
	delete tr;
	return pEntity;
}

public bool TRDontHitSelf(int entity, int mask, any data)
{
	return (1 <= entity <= MaxClients) && (entity != data);
}


void AI_Director_ResetReinforceTimers() 
{
	g_iReinforceTime_AD_Temp = (g_AIDir_ReinforceTimer_Orig);
	g_iReinforceTimeSubsequent_AD_Temp = sm_respawn_reinforce_time_subsequent.IntValue;
}

void AI_Director_SetDifficulty()
{
	AI_Director_ResetReinforceTimers();

	int AID_ReinfAdj_med = 20;
	int AID_ReinfAdj_high = 30;
	int AID_ReinfAdj_pScale = 0;
	int AID_AmbChance_vlow = 10;
	int AID_AmbChance_low = 15;
	int AID_AmbChance_med = 20;
	int AID_AmbChance_high = 25;
	int AID_AmbChance_pScale = 0;
	int AID_SetDiffChance_pScale = 0;

	int tTeamSecCount = GetTeamSecCount();
	if (tTeamSecCount <= 6)
	{
		AID_ReinfAdj_pScale = 8;
	}
	else if (tTeamSecCount >= 7 && tTeamSecCount <= 12)
	{
		AID_ReinfAdj_pScale = 4;
		AID_AmbChance_pScale = 5;
		AID_SetDiffChance_pScale = 5;
	}
	else if (tTeamSecCount >= 13)
	{
		AID_ReinfAdj_pScale = 8;
		AID_AmbChance_pScale = 10;
		AID_SetDiffChance_pScale = 10;
	}

	int ncp = Ins_ObjectiveResource_GetProp("m_iNumControlPoints");
	int acp = Ins_ObjectiveResource_GetProp("m_nActivePushPointIndex");

	int tAmbScaleMult = 2;
	
	if (ncp <= 5)
	{
		tAmbScaleMult = 3;
		AID_SetDiffChance_pScale += 5;
	}

	AID_AmbChance_pScale += (acp * tAmbScaleMult);
	AID_SetDiffChance_pScale += (acp * tAmbScaleMult);
	
	if (GetRandomInt(0, 100) <= (sm_ai_director_setdiff_chance_base.IntValue + AID_SetDiffChance_pScale))
	{
		AI_Director_ResetReinforceTimers();

		g_iReinforceTime_AD_Temp = ((g_AIDir_ReinforceTimer_Orig - AID_ReinfAdj_high) - AID_ReinfAdj_pScale);
		g_iReinforceTimeSubsequent_AD_Temp = ((sm_respawn_reinforce_time_subsequent.IntValue - AID_ReinfAdj_high) - AID_ReinfAdj_pScale);
		
		g_AIDir_AmbushCond_Chance = AID_AmbChance_high + AID_AmbChance_pScale;
	}
	else if (g_AIDir_TeamStatus < (g_AIDir_TeamStatus_max / 4))
	{
		g_iReinforceTime_AD_Temp = ((g_AIDir_ReinforceTimer_Orig + AID_ReinfAdj_high) + AID_ReinfAdj_pScale);
		g_iReinforceTimeSubsequent_AD_Temp = ((sm_respawn_reinforce_time_subsequent.IntValue + AID_ReinfAdj_high) + AID_ReinfAdj_pScale);

		g_AIDir_AmbushCond_Chance = AID_AmbChance_vlow + AID_AmbChance_pScale;
	}
	else if (g_AIDir_TeamStatus >= (g_AIDir_TeamStatus_max / 4) && g_AIDir_TeamStatus < (g_AIDir_TeamStatus_max / 2))
	{
		AI_Director_ResetReinforceTimers();

		if (g_AIDir_TeamStatus >= (g_AIDir_TeamStatus_max / 4) && g_AIDir_TeamStatus < (g_AIDir_TeamStatus_max / 3) && GetTeamSecCount() <= 9)
		{
			g_iReinforceTime_AD_Temp = ((g_AIDir_ReinforceTimer_Orig + AID_ReinfAdj_med) + AID_ReinfAdj_pScale);
			g_iReinforceTimeSubsequent_AD_Temp = ((sm_respawn_reinforce_time_subsequent.IntValue + AID_ReinfAdj_med) + AID_ReinfAdj_pScale);

			g_AIDir_AmbushCond_Chance = AID_AmbChance_low + AID_AmbChance_pScale;
		}
		else
		{
			g_iReinforceTime_AD_Temp = (g_AIDir_ReinforceTimer_Orig);
			g_iReinforceTimeSubsequent_AD_Temp = (sm_respawn_reinforce_time_subsequent.IntValue);

			g_AIDir_AmbushCond_Chance = AID_AmbChance_low + AID_AmbChance_pScale;
		}
	}
	else if (g_AIDir_TeamStatus >= (g_AIDir_TeamStatus_max / 2) && g_AIDir_TeamStatus < ((g_AIDir_TeamStatus_max / 4) * 3))
	{
		AI_Director_ResetReinforceTimers();

		g_iReinforceTime_AD_Temp = ((g_AIDir_ReinforceTimer_Orig - AID_ReinfAdj_med) - AID_ReinfAdj_pScale);
		g_iReinforceTimeSubsequent_AD_Temp = ((sm_respawn_reinforce_time_subsequent.IntValue - AID_ReinfAdj_med) - AID_ReinfAdj_pScale);
		
		g_AIDir_AmbushCond_Chance = AID_AmbChance_med + AID_AmbChance_pScale;
	}
	else if (g_AIDir_TeamStatus >= ((g_AIDir_TeamStatus_max / 4) * 3))
	{
		AI_Director_ResetReinforceTimers();

		g_iReinforceTime_AD_Temp = ((g_AIDir_ReinforceTimer_Orig - AID_ReinfAdj_high) - AID_ReinfAdj_pScale);
		g_iReinforceTimeSubsequent_AD_Temp = ((sm_respawn_reinforce_time_subsequent.IntValue - AID_ReinfAdj_high) - AID_ReinfAdj_pScale);
		
		g_AIDir_AmbushCond_Chance = AID_AmbChance_high + AID_AmbChance_pScale;
	}
}

public void OnClientDisconnect_Post(int client)
{
	//g_DeathOrigin[client][0] = 0.0;
	//g_DeathOrigin[client][1] = 0.0;
	//g_DeathOrigin[client][2] = 0.0;
}

/*
void Client_GetWeaponPlayerAmmoEx(int client, int weapon, int &primaryAmmo=-1, int &secondaryAmmo=-1)
{
	int offset_ammo = FindDataMapInfo(client, "m_iAmmo");
	
	if (primaryAmmo != -1)
	{
		int offset = offset_ammo + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
		primaryAmmo = GetEntData(client, offset);
	}

	if (secondaryAmmo != -1)
	{
		int offset = offset_ammo + (GetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoType") * 4);
		secondaryAmmo = GetEntData(client, offset);
	}
}*/


/*
void Client_SetWeaponPlayerAmmoEx(int client, int weapon, int primaryAmmo=-1, int secondaryAmmo=-1)
{
	int offset_ammo = FindDataMapInfo(client, "m_iAmmo");
	
	if (primaryAmmo != -1)
	{
		int offset = offset_ammo + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
		SetEntData(client, offset, primaryAmmo, 4, true);
	}

	if (secondaryAmmo != -1)
	{
		int offset = offset_ammo + (GetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoType") * 4);
		SetEntData(client, offset, secondaryAmmo, 4, true);
	}
}
*/

int GetCurrentCPIndex() {
	int res = FindEntityByClassname(-1, "ins_objective_resource");
	if (res == -1)
		return -1;

	int CP = GetEntProp(res, Prop_Send, "m_nActivePushPointIndex");

	return CP;
}

void FixSpawnPoint(int client) {
	float pos[3];
	GetClientAbsOrigin(client, pos);
	if (!EnemyInSightOrClose(client, pos))
		return;

	int cp = GetCurrentCPIndex();
	int team = GetClientTeam(client);
	char key[4];
	ArrayList list;
	Format(key, sizeof(key), "%s%d", ((team == TEAM_1_SEC) ? "S" : "I"), cp);
	if (hSpawnZone.GetValue(key, list)) {
		for(int i = 0; i < list.Length; ++i) {
			GetEntPropVector(list.Get(i), Prop_Send, "m_vecOrigin", pos);
			if (!EnemyInSightOrClose(client, pos)) {
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				return;
			}
		}
	}

	Format(key, sizeof(key), "%s%d", ((team == TEAM_1_SEC) ? "S" : "I"), cp - 2);
	if (hSpawnZone.GetValue(key, list)) {
		for(int i = 0; i < list.Length; ++i) {
			GetEntPropVector(list.Get(i), Prop_Send, "m_vecOrigin", pos);
			if (!EnemyInSightOrClose(client, pos)) {
				TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
				return;
			}
		}
	}
}

bool EnemyInSightOrClose(int client, float pos[3]) {
	int team = GetClientTeam(client);
	int eteam = (team == TEAM_1_SEC) ? TEAM_2_INS : TEAM_1_SEC;
	float minDist = Pow(100.0, 2.0);
	float org[3];
	for(int i = 1; i <= MaxClients; ++i) {
		if (i != client && IsClientInGame(i) && IsPlayerAlive(i)) {
			GetClientEyePosition(i, org);
			if (GetVectorDistance(pos, org, true) <= minDist) {
				return true;
			}

			if (GetClientTeam(i) == eteam) {
				if (NothingBetweenClient(client, i, pos, org)) {
					return true;
				}
			}
		}
	}

	return false;
}

bool NothingBetweenClient(int client1, int client2, float c1Vec[3], float c2Vec[3]) {
	Handle tr = TR_TraceRayFilterEx(c1Vec, c2Vec, MASK_PLAYERSOLID, RayType_EndPoint, Filter_Caller, client1);
	if (TR_DidHit(tr)) {
		if (TR_GetEntityIndex(tr) == client2) {
			CloseHandle(tr);
			return true;
		}

		CloseHandle(tr);
		return false;
	}
	CloseHandle(tr);
	return true;
}

bool Filter_Caller(int entity, int contentsMask, int client) {
	if (entity == client) {
		return false;
	}

	return true;
}

int FindSpawnZone(int spawnpoint) {
	Address pSpawnZone = Address_Null;
	float absOrigin[3];
	GetEntPropVector(spawnpoint, Prop_Data, "m_vecAbsOrigin", absOrigin);
	SDKCall(fPointInSpawnZone, absOrigin, spawnpoint, pSpawnZone);
	if (pSpawnZone == Address_Null) {
		return -1;
	}
	return SDKCall(fGetBaseEntity, pSpawnZone);
}

void BuildSpawnZoneList() {
	ArrayList listIns;
	ArrayList listSec;
	char key[4];
	for(int i = 0; i < hSpawnZoneKeys.Length; ++i) {
		hSpawnZoneKeys.GetKey(i, key, sizeof(key));
		if (hSpawnZone.GetValue(key, listIns)) {
			delete listIns;
		}
	}
	hSpawnZone.Clear();

	int objective = FindEntityByClassname(-1, "ins_objective_resource");
	if (objective == -1)
		return;
	int numOfSpawnZone = GetEntProp(objective, Prop_Send, "m_iNumControlPoints");
	for(int i = 0; i <= numOfSpawnZone; ++i) {
		SDKCall(fToggleSpawnZone, i, false);
	}

	int point = -1;
	int zone = -1;
	int team = 1;
	for(int i = 0; i <= numOfSpawnZone; ++i) {
		SDKCall(fToggleSpawnZone, i, true);
		
		listIns = new ArrayList();
		listSec = new ArrayList();
		point = FindEntityByClassname(-1, "ins_spawnpoint");
		while(point != -1) {
			zone = FindSpawnZone(point);
			if (zone != -1) {
				team = GetEntProp(point, Prop_Send, "m_iTeamNum");
				float pos[3];
				GetEntPropVector(point, Prop_Send, "m_vecOrigin", pos);
				if (team == TEAM_1_SEC)
					listSec.Push(point);
				else if (team == TEAM_2_INS)
					listIns.Push(point);
			}
			point = FindEntityByClassname(point, "ins_spawnpoint");
		}
		Format(key, sizeof(key), "I%d", i);
		hSpawnZone.SetValue(key, listIns, true);
		Format(key, sizeof(key), "S%d", i);
		hSpawnZone.SetValue(key, listSec, true);

		SDKCall(fToggleSpawnZone, i, false);
	}
	
	hSpawnZoneKeys = hSpawnZone.Snapshot();
	SDKCall(fToggleSpawnZone, GetCurrentCPIndex(), true);
}