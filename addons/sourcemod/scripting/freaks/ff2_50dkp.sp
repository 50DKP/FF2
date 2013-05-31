//CHANGELOG:
//----------
//v1.0 (5/30/2013 A.D.):  Re-created ff2_50dkp because it got deleted somewhere (Wliu).

//Current bosses that use this:  Fempyro

#pragma semicolon 1

#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>
#define MB 3

new bEnableSuperDuperJump[MB];

public Plugin:myinfo = {
	name = "50DKP-FF2 Plugin",
	author = "Wliu",
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
	return Plugin_Continue;
}

public Action:event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	for(new i=0;i<MB;i++)
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