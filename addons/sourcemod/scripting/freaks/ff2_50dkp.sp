//CHANGELOG:
//----------
//v1.1 (6/3/2013 A.D.):  Added rage_freeze to freeze raged players (Wliu).
//v1.0 (5/30/2013 A.D.):  Re-created ff2_50dkp because it got deleted somewhere (Wliu).

//Current bosses that use this:  Fempyro

#pragma semicolon 1

#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>

#define PLUGIN_VERSION 1.1

public Plugin:myinfo = {
	name = "50DKP-FF2 Plugin",
	author = "Wliu",
	description = "A FF2 plugin for the 50DKP community",
	version = PLUGIN_VERSION,
};

public OnPluginStart2()
{
	HookEvent("teamplay_round_start", event_round_start);
}

public OnMapStart()
{
	PrecacheSound("replay\\exitperformancemode.wav",true);
	PrecacheSound("replay\\enterperformancemode.wav",true);
}

public Action:FF2_OnAbility2(index,const String:plugin_name[],const String:ability_name[],action)
{
	if (!strcmp(ability_name,"rage_fempyro"))
	{
		Rage_Fempyro(index);
	}
	else if (!strcmp(ability_name,"rage_freeze"))
	{
		Rage_Freeze(index);
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
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2 = 0;
		for (new i = 0; i < count; i+=2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hWeapon, 0);
	}

	if (hWeapon==INVALID_HANDLE)
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
	if (IsValidEntity(weapon))
	{
		new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}

Rage_Fempyro(index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
	SetEntPropEnt(Boss, Prop_Send, "m_hActiveWeapon", SpawnWeapon(Boss, "tf_weapon_flamethrower", 741, 101, 5, "445 ; 1 ; 165 ; 1 ; 171 ; -50"));
	//Weapon:  Rainblower
	//Level:  101
	//Quality:  Unique
	//445:  Forces player to enter Pyrovision
	//165:  Charged airblast
	//171:  -50% airblast cost
	SetAmmo(Boss, TFWeaponSlot_Primary, 30);
}

Rage_Freeze(const String:ability_name[],index)
{
	decl Float:pos[3];
	decl Float:pos2[3];
	decl i;
	new Float:duration=FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0);
	decl String:s[64];
	FloatToString(duration,s,64);
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	GetEntPropVector(Boss, Prop_Send, "m_vecOrigin", pos);
	new Float:ragedist=FF2_GetRageDist(index,this_plugin_name,ability_name);
	for(i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i)!=BossTeam)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			if (!TF2_IsPlayerInCondition(i,TFCond_Ubercharged) && (GetVectorDistance(pos,pos2)<ragedist))
			{
				SetEntityMoveType(i, MOVETYPE_NONE);
				ColorizePlayer(i, COLOR_INVIS);
			}
			new iRagDoll = CreateRagdoll(i);
			if(iRagDoll > MaxClients && IsValidEntity(iRagDoll))
			{
				AddEntityToClient(i, iRagDoll);
				SetClientViewEntity(i, iRagDoll);
				SetThirdPerson(i, true);
			}
		}
	}
/*	for(i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i)!=BossTeam)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			if (!TF2_IsPlayerInCondition(i,TFCond_Ubercharged) && (GetVectorDistance(pos,pos2)<ragedist))
			{
				TF2_StunPlayer(i, duration, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, Boss);
				CreateTimer(duration, RemoveEnt, EntIndexToEntRef(AttachParticle(i,"yikes_fx",75.0)));	
			}
		}
	}*/
	/*
	SetEntityMoveType(client, MOVETYPE_NONE);
	ColorizePlayer(client, COLOR_INVIS);
	
	new iRagDoll = CreateRagdoll(client);
	if(iRagDoll > MaxClients && IsValidEntity(iRagDoll))
	{
		AddEntityToClient(client, iRagDoll);
		SetClientViewEntity(client, iRagDoll);
		SetThirdPerson(client, true);
	}
	*/
}