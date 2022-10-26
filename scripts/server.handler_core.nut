dofile("store/script/JSONParser.nut"); // Source: https://github.com/electricimp/JSONParser
dofile("store/script/JSONEncoder.nut"); // Source: https://github.com/electricimp/JSONEncoder

local events = {};

local native_events = {
	"onCheckpointEntered": "player, checkpoint",
	"onCheckpointExited": "player, checkpoint",
	"onObjectShot": "object, player, weapon",
	"onObjectBump": "object, player",
	"onPickupClaimPicked": "player, pickup",
	"onPickupPickedUp": "player, pickup",
	"onPickupRespawn": "pickup",
	"onPlayerJoin": "player",
	"onPlayerPart": "player, reason",
	"onPlayerRequestClass": "player, classID, team, skin",
	"onPlayerRequestSpawn": "player",
	"onPlayerSpawn": "player",
	"onPlayerDeath": "player, reason",
	"onPlayerKill": "killer, player, reason, bodypart",
	"onPlayerTeamKill": "killer, player, reason, bodypart",
	"onPlayerChat": "player, message",
	"onPlayerCommand": "player, command, arguments",
	"onPlayerPM": "player, playerTo, message",
	"onPlayerBeginTyping": "player",
	"onPlayerEndTyping": "player",
	"onLoginAttempt": "playerName, password, ipAddress",
	"onPlayerMove": "player, lastX, lastY, lastZ, newX, newY, newZ",
	"onPlayerHealthChange": "player, lastHP, newHP",
	"onPlayerArmourChange": "player, lastArmour, newArmour",
	"onPlayerWeaponChange": "player, oldWep, newWep",
	"onKeyDown": "player, bindID",
	"onKeyUp": "player, bindID",
	"onPlayerAwayChange": "player, newStatus",
	"onPlayerSpectate": "player, target",
	"onPlayerCrashDump": "player, crashReport",
	"onPlayerNameChange": "player, oldName, newName",
	"onPlayerActionChange": "player, oldAction, newAction",
	"onPlayerStateChange": "player, oldState, newState",
	"onPlayeronFireChange": "player, isonFireNow",
	"onPlayerCrouchChange": "player, isCrouchingNow",
	"onPlayerGameKeysChange": "player, oldKeys, newKeys",
	"onPlayerModuleList ": "player, string",
	"onServerStart": "",
	"onServerStop": "",
	"onScriptLoad": "",
	"onScriptUnload": "",
	"onSphereEntered": "player, sphere",
	"onSphereExited": "player, sphere",
	"onPlayerEnteringVehicle": "player, vehicle, door",
	"onPlayerEnterVehicle": "player, vehicle, door",
	"onPlayerExitVehicle": "player, vehicle",
	"onVehicleExplode": "vehicle",
	"onVehicleRespawn": "vehicle",
	"onVehicleHealthChange": "vehicle, oldHP, newHP",
	"onVehicleMove": "vehicle, lastX, lastY, lastZ, newX, newY, newZ",
}

foreach (name, args in native_events) {
	local str = "function " + name + "(" + args + ") {";
	if (args == "") str += "	local ret = triggerEvent(\"" + name + "\");"
	else str += "	local ret = triggerEvent(\"" + name + "\", " + args + ");"
	str += "	if (ret.rawin(\"" + name + "\")) return ret = ret.rawget(\"" + name + "\");";
	str += "	return true;";
	str += "}"
	
	local arr = {
		Name = name,
		Func = [],
		Native = true,
		AllowRemote = false
	}
	
	events.rawset(name, arr);

	compilestring(str)();
}

function addEvent(name, AllowRemote = true) {
	if (!events.rawin(name)) {
		local arr = {
			Name = name,
			Func = [],
			Native = false,
			AllowRemote = AllowRemote
		}
		events.rawset(name, arr);
	}
	else {
		throw "the event '" + name + "' already exists";
	}
}

function removeEvent(name) {
	if (events.rawin(name)) {
		if (events.rawget(name).Native == false) events.rawdelete(name);
		else throw "error trying to remove event '" + name + "': native events cannot be removed";
	}
	else {
		throw "the event '" + name + "' does not exists";
	}
}

function addEventHandler(name, func) {
	if (events.rawin(name)) {
		if (typeof(func) == "function") {
			local e = events.rawget(name);	
			e.Func.push(func);
		}
		else {
			throw "trying to add invalid handler in event '" + name + "', expected 'function', got '" + typeof(func) + "'";
		}
	}
	else {
		throw "the event '" + name + "' does not exists";
	}
}

function removeEventHandler(name, func) {
	if (events.rawin(name)) {
		local e = events.rawget(name);	
		foreach(fi, fe in e.Func) {
			if (func == fe) {
				e.Func.remove(fi);
			}
			else {
				throw("the event '" + name + "' does not have a handler");
			}
		}
	}
	else {
		throw("the event '" + name + "' does not exists");
	}
}

function triggerEvent(name, ...) {
	local return_ = {}
	if (events.rawin(name)) {
		local e = events.rawget(name);	
		
		vargv.insert(0, this);
		
		foreach(fi, fe in e.Func) {		
			try {
				local result = fe.acall(vargv);
			
				result = (result == null ? true : result);
			
				return_.rawset(name, result);
			}
			catch (e) {
			}
		}
		
		return return_;
	}
	else {
		throw("the event '" + name + "' does not exists");
	}
}

local function triggerEvent_(name, args) {
	local return_ = {}
	if (events.rawin(name)) {
		local e = events.rawget(name);	
		
		if (e.AllowRemote == true) {
			foreach(fi, fe in e.Func) {		
				try {
					local result = fe.acall(args);
				
					result = (result == null ? true : result);
				
					return_.rawset(name, result);
				}
				catch (err) {
					print(args.len() + " - " + e.Func.len());
					throw err;
				}
			}
		}
		else {
			throw("failed to trigger event '" + name + "': remote trigger denied");
		}
		
		return return_;
	}
	else {
		throw("the event '" + name + "' does not exists");
	}
}

function triggerClientEvent(player, name, ... ) {
	local arg = [null], str;
	
	for (local i = 0; i < vargv.len(); i++) {
		arg.push(vargv[i]);
	}
	
	str = JSONEncoder.encode(arg);
	
	Stream.StartWrite();
	Stream.WriteInt(0);
	Stream.WriteString(name + "\n" + str);
	Stream.SendStream(player);
}

function getEventHandlers(name) {
	local return_ = {};
	if (events.rawin(name)) {
		local e = events.rawget(name);	
		
		foreach(fi, fe in e.Func) {		
			return_.rawset(name, fe);
		}
		
		return return_;
	}
	else {
		throw("the event '" + name + "' does not exists");
	}
}

function onClientScriptData(player) {
	local type = Stream.ReadInt(), readString = Stream.ReadString(), byte = Stream.ReadByte();

	local str = split(readString, ":"), name = str[0], arr = JSONParser.parse(str[1]);
	arr[0] = this;
	arr[1] = FindPlayer(arr[1]);
	
	triggerEvent_(str[0], arr);
}