## Event handler similar to Multi Theft Auto: San Andreas for VC:MP.

The event handler allows you to attach functions to events in any part of the code, without having to put your functions in the same part of the code. This feature also provides the functions [triggerServerEvent] and [triggerClientEvent] that have the functionality to call events registered in both parts in a practical way.

### Setup
Important things before doing your first setup with the event handler:

- If you want to use this on your server, you will have to adapt parts of the code that use native VC:MP events (like onPlayerJoin, onScriptLoad, onCheckpointEntered and etc), below is a simple example on how to do this:
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
- For compatibility reasons, you cannot create functions in code with the names of native VC:MP functions, ie something like `function onScriptLoad() {}` in your code can cause problems, try your best to use an alias like `onLoad` or `onServerInitialise`.
