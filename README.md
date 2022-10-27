## Event handler for VC:MP.
This feature aims to bring event handler similar to that of MTA SA.

The event handler allows you to attach functions to events in any part of the code, without having to put your functions in the same part of the code. This feature also provides the functions [triggerServerEvent](https://github.com/Razorn7/Event-handler-for-VC-MP/wiki/triggerServerEvent) and [triggerClientEvent](https://github.com/Razorn7/Event-handler-for-VC-MP/wiki/triggerClientEvent) that have the functionality to call events registered in both parts in a practical way.

### Important notes before usage
Important things before doing your first setup with the event handler:

1. If you want to use this on your server, you will have to adapt parts of the code that use native VC:MP events (like onPlayerJoin, onScriptLoad, onCheckpointEntered and etc), below is a simple example on how to do this:
	**Old event**:
	```js
	function onScriptLoad() {
		SetServerName("[0.4] Server");
		SetPassword("123");
	}
	```
	**New event**:
	```js
	addEventHandler("onScriptLoad", function() {
		SetServerName("[0.4] Server");
		SetPassword("123");
	});
	```
	**or**
	```js
	function onLoad() {
		SetServerName("[0.4] Server");
		SetPassword("123");
	}
	addEventHandler("onScriptLoad", onLoad);
	```
2. For compatibility reasons, you cannot create functions in code with the names of native VC:MP functions, ie something like `function onScriptLoad() {}` in your code can cause problems, try your best to use an alias like `onLoad` or `onServerInitialise`.
3. The event that will be called by the `triggerServerEvent` function on the server-side must have the first argument related to the player.

### Setup
1. Clone the [repository](https://github.com/Razorn7/Event-handler-for-VC-MP/)
2. Add `dofile("scripts/server.handler_core.nut")` and `dofile("client.handler_core.nut")` on the top of your main script (both sides, server and client).
3. Enjoy.
