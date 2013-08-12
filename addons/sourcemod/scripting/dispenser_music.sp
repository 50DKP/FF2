#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "0.2.0"

public Plugin:dispenser_music =
{
	name = "Dispenser Music",
	author = "Jeremy Rodi",
	description = "Adds music to dispensers.",
	version = PLUGIN_VERSION,
	url = ""
}

#define MAX_NUMBER_OF_SOUNDS 100

new String:soundArray[MAX_NUMBER_OF_SOUNDS][PLATFORM_MAX_PATH];
new soundNumber = 0;

public OnPluginStart()
{

	CreateConVar("sm_dispenser_music_version", PLUGIN_VERSION,
		"The version of the Dispenser Music plugin.", FCVAR_SPONLY | FCVAR_PLUGIN | FCVAR_NOTIFY | FCVAR_REPLICATED);

	RegAdminCmd("sm_dispenser_music_reload", Command_ReloadDispenserMusic, ADMFLAG_ROOT);

	HookEvent("player_builtobject", Event_player_builtobject);
	HookEvent("object_destroyed", Event_object_destroyed, EventHookMode_Pre);
	HookEvent("object_removed", Event_object_destroyed, EventHookMode_Pre);
	HookEvent("player_carryobject", Event_object_destroyed, EventHookMode_Pre);
}

public OnConfigsExecuted()
{
	SetupSounds();
}

public Action:Command_ReloadDispenserMusic(client, args)
{
	SetupSounds();

	return Plugin_Handled;
}

SetupSounds()
{
	new Handle:soundKeyValue = CreateKeyValues("dismusic");
	decl String:filePath[PLATFORM_MAX_PATH];
	decl String:keyName[7];
	decl String:value[PLATFORM_MAX_PATH];
	decl String:musicDir[PLATFORM_MAX_PATH];

	soundNumber = 0;
	IntToString(soundNumber, keyName, 7);
	BuildPath(Path_SM, filePath, PLATFORM_MAX_PATH, "configs/dispenser_music.cfg");

	if(!FileToKeyValues(soundKeyValue, filePath)) {
		SetFailState("Could not load file %s.", filePath);
		return;
	}

	KvJumpToKey(soundKeyValue, "Music");

	if(!KvGotoFirstSubKey(soundKeyValue)) {
		SetFailState("No songs in file %s.", filePath);
		return;
	}

	do {

		KvGetString(soundKeyValue, "file", value, PLATFORM_MAX_PATH);
		soundArray[soundNumber] = value;
		PrintToServer("Adding sound %s", value);
		musicDir = "sound/";
		StrCat(musicDir, PLATFORM_MAX_PATH, value);

		AddFileToDownloadsTable(musicDir);
		PrecacheSound(value);

		soundNumber++;
		IntToString(soundNumber, keyName, 7);
	} while(KvGotoNextKey(soundKeyValue))

	CloseHandle(soundKeyValue);

}
public Action:Event_player_builtobject(Handle:event, const String:name[], bool:dontBroadcast)
{

	if(GetEventInt(event, "object") != 0)
		return Plugin_Continue;

	new index = GetEventInt(event, "index");
	new Float:position[3];
	new sound = GetRandomInt(0, soundNumber - 1);
	GetEntPropVector(index, Prop_Send, "m_vecOrigin", position);

	EmitSoundToAll(soundArray[sound], index, SNDCHAN_USER_BASE, SNDLEVEL_NORMAL, SND_NOFLAGS,
		SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);

	return Plugin_Continue;
}

public Action:Event_object_destroyed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new i = 0;

	new String:buf[PLATFORM_MAX_PATH];

	for(i = 0; i < soundNumber; i++)
	{
		StopSound(GetEventInt(event, "index"), SNDCHAN_USER_BASE, soundArray[i]);
	}

	return Plugin_Continue;
}