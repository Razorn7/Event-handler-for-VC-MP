/* -----------------------------------------------
	Squirrel event handler resource (server-side)	
	Version: v1.0
	Author: Razor#7311
------------------------------------------------ */

local events = {}, rfile, lines;

function addEvent(name) {
	if (!events.rawin(name)) {
		local arr = {
			Name = name,
			Func = [],
			Native = false
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
		else throw "error trying to remove event '" + name + "': native events cannot be deleted";
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
			local result = fe.pacall(vargv);
			
			result = (result == null ? true : result);
			
			return_.rawset(name, result);
		}
		
		return return_;
	}
	else {
		throw("the event '" + name + "' does not exists");
	}
}

function ReadTextFromFile(path) {
    local f = file(path,"rb"), s = "", n = 0;
    f.seek(0, 'e');
    n = f.tell();
    if (n == 0)
        return s;
    f.seek(0, 'b');
    local b = f.readblob(n+1);
    f.close();
    for (local i = 0; i < n; ++i)
        s += format(@"%c", b.readn('b'));
    return s;
}

rfile = ReadTextFromFile("scripts/server.handler_events.nut");
lines = split(rfile, "\n");

foreach(i, e in lines) {
	local args = split(e, "("), func;
	func = "" + args[0];
	args = args[1];
	
	args = args.slice(0, args.len()-3);
	
	try {
		local str = func;
		compilestring(str)();
	}
	catch(e) {
		local str = func + " <- function(" + args + ");";
		compilestring(str)();
	}

	local arr = {
		Name = func,
		Func = [],
		Native = true
	}
	
	events.rawset(func, arr);
	
	//local str = "local old_func = " + func + ";"
	local str = "" + func + " = function(" + args + ")";
	str += "{";
	//str += "old_func(" + args + ");"
	local line_five;
	if (args != "") str += "local ret = triggerEvent(\"" + func + "\", " + args + ");"
	else str += "local ret = triggerEvent(\"" + func + "\");"
	str += ""; 
	str += "if (ret.rawin(\"" + func + "\")) return ret = ret.rawget(\"" + func + "\");";
	str += "return true;";
	str += "}"

	
	compilestring(str)();
}