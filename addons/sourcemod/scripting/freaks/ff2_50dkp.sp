/*CHANGELOG:
----------
v1.5 (July 21, 2013 A.D.):  Added Gaben_Ban for Gaben when he kills somebody (Wliu).
v1.4 (June 28, 2013 A.D.):  Fixed Fempyro's airblast cost and ammo pickup again (Wliu).
v1.3 (June 25, 2013 A.D.):  Fixed Fempyro picking up ammo (Wliu).
v1.2 (June 18, 2013 A.D.):  Removed rage_freeze (separate plugin) and fixed Fempyro's airblast cost (Wliu).
v1.1 (June 3, 2013 A.D.):  Added rage_freeze to freeze raged players (Wliu).
v1.0 (May 30, 2013 A.D.):  Re-created ff2_50dkp because it got deleted somewhere (Wliu).

Current bosses that use this:  Fempyro, Gaben
*/

#pragma semicolon 1

#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>
#include <morecolors>
#include <sdktools>
#include <sdkhooks>
#include <sourcemod>
#include <tf2_stocks>
#include <tf2items>

#define PLUGIN_VERSION	"1.5"

new bEnableSuperDuperJump[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "50DKP-FF2 Plugin",
	author = "Wliu",
	description = "A FF2 plugin for the 50DKP community",
	version = PLUGIN_VERSION,
};

public OnPluginStart2()
{
	HookEvent("teamplay_round_start", event_round_start);
	HookEvent("player_death", event_player_death, EventHookMode_Pre);
}

public OnMapStart()
{
	PrecacheSound("replay\\exitperformancemode.wav",true);
	PrecacheSound("replay\\enterperformancemode.wav",true);
}

public Action:FF2_OnAbility2(index,const String:plugin_name[],const String:ability_name[],action)
{
	if(!strcmp(ability_name,"rage_fempyro"))
	{
		Rage_Fempyro(index);
	}
	else if(!strcmp(ability_name,"gaben_ban"))
	{
		Gaben_Ban();
	}
	return Plugin_Continue;
}

public Action:event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	for(new i=0;i<MaxClients;i++)
	{
		bEnableSuperDuperJump[i]=false;
	}
	return Plugin_Continue;
}

stock SpawnWeapon(client,String:name[],index,level,qual,String:att[])
{
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	if(count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2 = 0;
		for(new i = 0; i < count; i+=2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hWeapon, 0);
	}

	if(hWeapon==INVALID_HANDLE)
	{
		return -1;
	}
	new entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}

stock SetAmmo(client, slot, ammo)
{
	new weapon = GetPlayerWeaponSlot(client, slot);
	if(IsValidEntity(weapon))
	{
		new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}

/*=========RAGES START=========*/
Rage_Fempyro(index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
	SetEntPropEnt(Boss, Prop_Send, "m_hActiveWeapon", SpawnWeapon(Boss, "tf_weapon_flamethrower", 741, 101, 5, "422 ; 1 ; 445 ; 1 ; 165 ; 1 ; 171 ; 0.5 ; 77 ; 0 ; 258 ; 1 ; 37 ; 0"));
		//Weapon:  Rainblower
		//Level:  101
		//Quality:  Unique
		//422:  Only visible in Pyrovision
		//445:  Forces player to enter Pyrovision
		//165:  Charged airblast
		//171:  -50% airblast cost
		//77:  Clip size is 0
		//258:  All ammo becomes health
		//37:  No ammo
	SetAmmo(Boss, TFWeaponSlot_Primary, 30);
}

/*=========ABILITIES START=========*/
Gaben_Ban()
{
/*	public Action:event_player_death(Handle:event, const String:name[], bool:dontBroadcast)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if(client && GetClientHealth(client) <= 0)
		{
			OnPlayerDeath(client,GetClientOfUserId(GetEventInt(event, "attacker")),(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER) != 0);
		}
		return Plugin_Continue;
	}*/
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client && GetClientHealth(client) <= 0)
	{
		OnPlayerDeath(client,(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER) != 0);
	}
}

/*==========MISCELLANEOUS========*/
OnPlayerDeath(client,bool:fake = false)  //For Gaben Ban
{
	if(fake==true)
	{
		PrintToChatAll("Player %s has been banned (Banned by Gabe Newell) Reason:  You are not worthy of fighting me",client);
	}
}

public Action:FF2_OnTriggerHurt(index,triggerhurt,&Float:damage)
{
	bEnableSuperDuperJump[index]=true;
	if(FF2_GetBossCharge(index,1) < 0)
	{
		FF2_SetBossCharge(index, 1, 0.0);
	}
	return Plugin_Continue;
}