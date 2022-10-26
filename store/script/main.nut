dofile("client.handler_core.nut");

addEvent("testClientEvent");
addEventHandler("testClientEvent", function(text) {

	Console.Print(text);
	triggerServerEvent("testServerEvent", text);
});

addEvent("execute");
addEventHandler("execute", function(cmd, text) {
	if (!text) {
		Console.Print("/" + cmd + " <string>");
	}
	else {
		try {
			compilestring(text)();
			Console.Print("Compiled: [" + text + "]");
		}
		catch (e) {
			Console.Print(e);
		}
	}
});

addEventHandler("Script::ScriptLoad", function() {
	Console.Print("bro");
});

function loadScript() {
	local events_arr = getEventHandlers("Script::ScriptLoad");
	foreach (i, e in events_arr) {
		Console.Print(typeof e + " - " + typeof this)
		if (e == loadScript) {
			Console.Print("true");
		}
	}
}


addEventHandler("Script::ScriptLoad", loadScript);