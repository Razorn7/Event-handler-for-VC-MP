dofile("scripts/server.handler_core.nut");

addEventHandler("onPlayerJoin", function(player) {
	MessagePlayer("bro", player);
	
	triggerClientEvent(player, "testClientEvent", "hey, " + player.Name + "!");
});

addEvent("testServerEvent");
addEventHandler("testServerEvent", function(player, text) {
	MessagePlayer("A", player);
});

addEventHandler("onPlayerCommand", function(player, cmd, text) {
	if (cmd == "exec") {
		triggerClientEvent(player, "execute", cmd, text);
	}
});