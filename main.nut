dofile("scripts/server.handler_core.nut");

function main_load() {
	SetServerName("[0.4] Squirrel Server");
	
	print("Server started!");
	print("Name: " + GetServerName() + ".");
}

addEventHandler("onScriptLoad", main_load);

function connectPlayer(player) {
	MessagePlayer("Welcome back, " + player.Name + "!", player);
}

addEventHandler("onPlayerJoin", connectPlayer);

function spawnHandler1(player) {
	player.Spawn();
	player.Cash += 1000000;
}

function spawnHandler2(player) {
	Message(player.Name + " spawned.");
}

addEventHandler("onPlayerSpawn", spawnHandler1);
addEventHandler("onPlayerSpawn", spawnHandler2);

function playerCommands(player, cmd, text) {
	if (cmd == "command") {
		MessagePlayer("Command!", player);
	}
}

function adminCommands(player, cmd, text) {
	if (cmd == "admin_command") {
		MessagePlayer("Admin Command!", player);
	}
}

addEventHandler("onPlayerCommand", playerCommands);
addEventHandler("onPlayerCommand", adminCommands);

function onChat(player, text) {
	MessagePlayer("You can't chat because the function is returning \"false\"!", player);
	
	return false;
}

addEventHandler("onPlayerChat", onChat)