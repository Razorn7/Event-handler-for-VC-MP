dofile("JSONParser.nut"); // Source: https://github.com/electricimp/JSONParser
dofile("JSONEncoder.nut"); // Source: https://github.com/electricimp/JSONEncoder

local events = {};

local native_events = {
	"Script::ScriptLoad": "",
	"Script::ScriptUnload": "",
	"Script::ScriptProcess": "",
	"Player::PlayerDeath": "player",
	"Player::PlayerShoot": "player, weapon, hitEntity, hitPosition",
	"GUI::ElementFocus": "element",
	"GUI::ElementBlur": "element",
	"GUI::ElementHoverOver": "element",
	"GUI::ElementHoverOut": "element",
	"GUI::ElementClick": "element, mouseX, mouseY",
	"GUI::ElementRelease": "element, mouseX, mouseY",
	"GUI::ElementDrag": "element, mouseX, mouseY",
	"GUI::CheckboxToggle": "checkbox, checked",
	"GUI::WindowClose": "window",
	"GUI::InputReturn": "editbox",
	"GUI::ListboxSelect": "listbox, text",
	"GUI::ScrollbarScroll": "scrollbar, position, change",
	"GUI::WindowResize": "window, width, height",
	"GUI::GameResize": "width, height",
	"GUI::KeyPressed": "key",
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

function triggerServerEvent(name, ... ) {
	local arg = [null, World.FindLocalPlayer().ID], str, data;
	
	for (local i = 0; i < vargv.len(); i++) {
		arg.push(vargv[i]);
	}
	
	str = ::getroottable().rawget("JSONEncoder").encode(arg);

	data = ::getroottable().rawget("Stream")();
	data.WriteInt(0);
	data.WriteString(name + ":" + str);
	::getroottable().rawget("Server").SendData(data);
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

function Server::ServerData(stream) {
	local type = stream.ReadInt(), readString = stream.ReadString(), byte = stream.ReadByte();

	local str = split(readString, "\n"), name = str[0], arr = JSONParser.parse(str[1]);
	
	arr[0] = this;
	
	triggerEvent_(str[0], arr);
}