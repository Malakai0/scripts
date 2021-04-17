local BizarreLibrary = {}
BizarreLibrary.__index = BizarreLibrary;

-- mute warnings
if not getgenv then
	getgenv = function()end;
	getsenv = function()end;
	getrenv = function()end;
	setreadonly = function()end;
	getrawmetatable = function()end;
	getcallingscript = function()end;
	getnamecallmethod = function()end;
end

-- Quick setup on some of the global variables.
local variations,objects,cache,current_object = 'BLVariations','BLObjects','ScriptCache','BLCurrentStand';
if (not getgenv()[variations]) then getgenv()[variations] = {}; end
if (not getgenv()[objects]) then getgenv()[objects] = {}; end;
if (not getgenv()[cache]) then getgenv()[cache] = {} end;

local Players = game:GetService("Players");
local Player = Players.LocalPlayer;

local GetUV = getgenv().debug.getupvalues;
local SetUV = getgenv().debug.setupvalue;
local GetCON = getgenv().debug.getconstants;
local SetCON = getgenv().debug.setconstant;
local GetPRO = getgenv().debug.getprotos;
local SetPRO = getgenv().debug.setproto;
local GetSTK = getgenv().debug.getstack;
local SetSTK = getgenv().debug.setstack;

local GetSenv = getgenv().getsenv;

local CO_CRE = coroutine.create;
local CO_RES = coroutine.resume;

local function FindFirstChildOfClassAndName(Parent, Name, ClassName)
	for i,v in next, Parent:GetChildren() do
		if v.Name == Name and v.ClassName == ClassName then
			return v
		end
	end
end

local function Wrap(func,...)
	return CO_RES(CO_CRE(func),...)
end

local function VisiblePlayer(targetPlayer)
	local Character = targetPlayer.Character;
	if (not Character) then return end;
	for _,Part in next, Character:GetChildren() do
		if (not Part.Name:lower():find('rootpart')) then
			Part.Transparency = 0
			if (Part.Name:lower():find('head')) then
				Part.CanCollide = true;
			end
		else
			Part.CanCollide = true;
		end
	end
end

function BizarreLibrary.LogUpvalues(Key, Function)
	print(); -- new line!
	for i,v in next, GetUV(Function) do
		print(Key..':',i,v)
	end
end

function BizarreLibrary.LogConstants(Key, Function)
	print(); -- new line!
	for i,v in next, GetCON(Function) do
		print(Key..':',i,v)
	end
end

function BizarreLibrary.LogProtos(Key, Function)
	print()
	for i,v in next, GetPRO(Function) do
		print(Key..':',i,v)
	end
end

function BizarreLibrary.LogStack(Key, Function)
	print()
	for i,v in next, GetSTK(Function) do
		print(Key..':',i,v)
	end
end

function BizarreLibrary.GetPlayerScripts(method, ABDCopy)
	local Scripts = {};
	local Directory = ABDCopy and Player.Backpack or Player.Character;
	for _,Inst in next, Directory:GetChildren() do
		if (Inst:IsA("LocalScript")) then
			if (method == 'GET') then
				Scripts[Inst] = true;
			elseif (method == 'PRINT') then
				print('Found script in character: ' .. Inst.Name)
			end
		end
	end
	return Scripts;
end

function BizarreLibrary.FindPlayerStand(ABDCopy)
	local Scripts = BizarreLibrary.GetPlayerScripts('GET', ABDCopy);
	local VariationType = ABDCopy and 'Modded' or 'ABD'
	if not getgenv()[variations][VariationType] then return end;

	for Scr, _ in next, Scripts do
		if ( getgenv()[variations][VariationType][Scr.Name] ) then
			return Scr.Name;
		end
	end
end

function BizarreLibrary.SetDamageMultiplier(Multiplier)
	getgenv().DamageMultiplier = tonumber(math.floor(Multiplier)) or 1;
end

function BizarreLibrary.SetPlayersVisible(AreVisible)
	if (type(AreVisible) == 'boolean') then
		getgenv().PlayersVisible = AreVisible
	else
		warn('Error: SetPlayersVisible must get a boolean!')
	end
end

function BizarreLibrary.WalkInTS(ShouldWalk)
	getgenv().WalkingInTS = ShouldWalk;
end

function BizarreLibrary.RemoveJumpCooldown(enable)
	getgenv().JumpCoolEnabled = enable

	if not getgenv().JumpCoolHooked then
		local rblx_time = getrenv().time;

		getgenv().OldJumpValue = {}
		getrenv().time = function(...)
			local fenv = getfenv(2)
			if (not getgenv().OldJumpValue[fenv]) then
				getgenv().OldJumpValue[fenv] = fenv.Cooldown
			end
			fenv.Cooldown = getgenv().JumpCoolEnabled and 0 or getgenv().OldJumpValue[fenv];
			setfenv(2, fenv);
			return rblx_time()
		end
		getgenv().JumpCoolHooked = true;
	end

end

function BizarreLibrary.RemoveHitCooldown(enabled)
	getgenv().HitCoolEnabled = enabled;

	local old_delay = getgenv().rblxdelay or getrenv().delay;
	getgenv().rblxdelay = old_delay

	getrenv().delay = function(...)
		if (getgenv().HitCoolEnabled) then -- stand script
			return ((function(...) return ({...})[2] end)(...))();
		end
		return old_delay(...)
	end
end

function BizarreLibrary.HookWaitFunction(newFunc)
	local rblx_wait = getgenv().OriginalWaitFunction or getrenv().wait;
	getgenv().OriginalWaitFunction = rblx_wait;

	getrenv().wait = function(a, ...)
		local func = type(newFunc) == 'function' and newFunc or (function(a,b)
			return a(b);
		end)
		return func(rblx_wait, a);
	end
end

function BizarreLibrary.AddStandVariant(Version, ScriptName, Variant)
	assert(type(Variant) == 'table', 'Variant must be a table!');
	assert(type(Variant['Moves']) == 'table', "Variant must have a table with key 'Moves'!" );
	assert(type(Variant['Misc']) == 'table', "Variant must have a table with key 'Misc'!" );
	
	assert(type(Variant['Misc']['Global_Variables']) == 'table', "Variant's Misc must have a table with key 'Global_Variables'!" )
	assert(type(Variant['Misc']['Global_Functions']) == 'table', "Variant's Misc must have a table with key 'Global_Functions'!" )
	assert(type(Variant['Misc']['Global_Tables']) == 'table', "Variant's Misc must have a table with key 'Global_Tables'!" )

	if not getgenv()[variations][Version] then
		getgenv()[variations][Version] = {}
	end

	getgenv()[variations][Version][ScriptName] = Variant;
end

function BizarreLibrary.LoadStandVariants(ABD, Modded)
	local Combined = {ABD,Modded}
	for VersionIndex,Version in next, Combined do
		for Name, Variant in next, Version do
			local VersionName = VersionIndex == 1 and 'ABD' or VersionIndex == 2 and 'Modded';
			BizarreLibrary.AddStandVariant(VersionName, Name, Variant)
		end
	end
end


function BizarreLibrary.new(ABDCopy, ScriptName)

	if (getgenv()[current_object]) then
		getgenv()[current_object]:Destroy();
	end

	local FindIn = ABDCopy and Player.Backpack or Player.Character;
	ScriptName = ScriptName or BizarreLibrary.FindPlayerStand(ABDCopy);

	if (not ScriptName) then
		error('No variant for current stand.');
	end

	local Stand = FindIn:FindFirstChild(ScriptName);

	if ( getgenv()[objects][ScriptName] ) then
		if (getgenv()[objects][ScriptName].CurrentConnections['RenderStepped'] ~= nil) then
			getgenv()[objects][ScriptName].CurrentConnections['RenderStepped']:Disconnect();
			getgenv()[objects][ScriptName].CurrentConnections['RenderStepped'] = nil;
		end
		if (getgenv()[objects][ScriptName].CurrentConnections['CharacterAdded'] ~= nil) then
			getgenv()[objects][ScriptName].CurrentConnections['CharacterAdded']:Disconnect();
			getgenv()[objects][ScriptName].CurrentConnections['CharacterAdded'] = nil;
		end
	end

	if (not Stand) then
		error('Could not find the stand script in your player. Use the GetPlayerScripts function to view all scripts in the character.')
	end

	if (not GetUV or not SetUV or not GetCON or not SetCON or not GetPRO or not SetPRO or not GetSTK or not SetSTK or not GetSenv) then
		error('This script does not support your exploit.');
	end

	local self = setmetatable({
		StandScript = Stand;
		CurrentConnections = {
			RenderStepped = nil;
			CharacterAdded = nil;
		};
		Name = ScriptName; -- Hold onto it for when the player respawns.
		LoggedMoves = {};
		FindIn = FindIn;
		ABDCopy = ABDCopy;
	}, BizarreLibrary)

	getgenv()[objects][ScriptName] = self;
	getgenv()[current_object] = self;

	return self;

end

function BizarreLibrary:GetDirectory()
	return self.ABDCopy and Player.Backpack or Player.Character;
end

function BizarreLibrary:LogEnvironment()
	local Environment = GetSenv(self.StandScript);
	for I,V in next, Environment do
		print(I,V)
	end;
end

function BizarreLibrary:GetEnvironment()
	return GetSenv(self.StandScript);
end

function BizarreLibrary:Update()
	local varKey = self.ABDCopy and 'Modded' or 'ABD'
	local Variant = getgenv()[variations][varKey][self.Name];
	if (not Variant) then return end;

	local Environment = getsenv(self.StandScript)

	local _self = self;

	local LogMethods = {
		['constants'] = BizarreLibrary.LogConstants;
		['upvalues'] = BizarreLibrary.LogUpvalues;
		['protos'] = BizarreLibrary.LogProtos;
		['stack'] = BizarreLibrary.LogStack;
	}

	if (getgenv().PlayersVisible) then
		Wrap(function()

			for _,OtherPlayer in next, Players:GetPlayers() do
				if (OtherPlayer ~= Player) then
					Wrap(VisiblePlayer, OtherPlayer)
				end
			end

		end)
	end

	Wrap(function()
		for Key,TargetVal in next, Variant.Misc.Global_Variables do
			-- Be careful with this.
			Environment[Key] = TargetVal;
		end;
	end)

	self = Wrap(function()
		for Key,Data in next, Variant.Moves do
			local Func,FuncKey;
			for EnvKey,EnvVal in next, Environment do
				if (EnvKey == Data.Function and type(EnvVal) == 'function') then
					Func = EnvVal;
					FuncKey = EnvKey;
					break;
				end
			end
			if ( Func ) then
				-- Important to note that it holds the exact table.
				local hasLogged = getgenv()[objects][_self.Name].LoggedMoves[Data] ~= nil
				if (Data.ShouldLog ~= false and hasLogged == false) then
					getgenv()[objects][_self.Name].LoggedMoves[Data] = true;
					local Method = LogMethods[Data.ShouldLog:lower()];
					if (Method) then
						Method(Key, Func)
					end
				elseif (Data.ShouldLog == false) then

					for Key2,Data2 in next, Data.Debug do
						Key2 = tostring(Key2):lower()
						local SetFunc = Key2 == 'upvalues' and SetUV or
										Key2 == 'constants' and SetCON or
										Key2 == 'protos' and SetPRO or
										Key2 == 'stack' and SetSTK;
						if (SetFunc) then
							for Key3, Data3 in next, Data2 do
								SetFunc(Func, Data3.Key, Data3.Target);
							end
						end
					end
				end
			end
		end
		return _self;
	end);

	self = Wrap(function()
		if (not Environment['GLOBAL_FUNCTIONS_SET_BM']) then

			Wrap(function()
				Environment = GetSenv(_self.StandScript)
				for FuncKey, NewFunc in next, Variant.Misc.Global_Functions do

					local function modify(key)
						local oldFunc = Environment[key];
						Wrap(function()
							local function try(tries)
								if (oldFunc) then return; end;
								if (tries >= 10) then return; end;
								Environment = getsenv(_self.StandScript);
								oldFunc = Environment[FuncKey]
								if (not oldFunc) then return try(tries + 1); end
							end
							try(1)
							if (oldFunc) then
								Environment[FuncKey] = function(...)
									return ( NewFunc(oldFunc, ...) );
								end;
							end;
						end);
					end

					if (tostring(FuncKey):lower() == 'hito') then
						for x,c in next, Environment do
							local bruh = tostring(x)
							local found = string.find(bruh, 'hito') ~= nil or string.find(bruh, 'healo')
							if (type(c) == 'function' and found) then
								modify(bruh);
							end
						end
					else
						modify(FuncKey);
					end;
				end;
				Environment['GLOBAL_FUNCTIONS_SET_BM'] = true;
			end);
		end;

		return _self;
	end);
	
	self = Wrap(function()
		if (not Environment['GLOBAL_TABLES_SET_BM']) then
			for Key,TargetVal in next, Variant.Misc.Global_Tables do
				local TABLE = Environment[Key]
				if (TABLE and type(TABLE) == 'table') then
					setreadonly(Environment[Key], false);
					setreadonly(TABLE, false);
					for valKey, newVal in next, TargetVal do
						local oldVal = TABLE[valKey]
						if (type(oldVal) == 'function') then
							TABLE[valKey] = function(...)
								return ( newVal(oldVal,...) )
							end;
						else
							TABLE[valKey] = newVal
						end
					end;
					Environment[Key] = TABLE;
				end
			end;
			Environment['GLOBAL_TABLES_SET_BM'] = true;
		end
		return _self;
	end);
end;

function BizarreLibrary:Stepped()
	if (Player.Character and Player.Character:FindFirstChild("Humanoid") and
		Player.Character.Humanoid.Health > 0) then do
			self.StandScript = self:GetDirectory():FindFirstChild(self.Name);
			local preSuccess,Environment = pcall(getsenv, self.StandScript)
			local Working = type(Environment) == 'table' and preSuccess == true;
			if (self.StandScript and self.StandScript.Parent == self:GetDirectory() and self.StandScript.Disabled == false and Working) then
				self:Update();
			end
		end
	end
end

-- This is called every time a player respawns by the Start method.
function BizarreLibrary:InternalStart()
	local _self = self;

	getgenv()[objects][self.Name].LoggedMoves = {}; -- Empty table so it can re-log.
   
	local playerStand;
 
	for i = 1, 10 do
		playerStand = self:GetDirectory():FindFirstChild(self.Name);
		if (playerStand) then break end;
		wait(.5)
	end -- wait 5 seconds to load script.
	 
	if (playerStand == nil) then
		warn(string.format("Cannot find stand, disabling modification: %s", self.Name))
		warn(string.format("You can re-enable %s by calling :Enable again.", self.Name));
		self:Disable()
		return;
	end
	
	self.StandScript = playerStand;
	if (not getgenv()[cache][playerStand]) then
		getgenv()[cache][playerStand] = true;
	end

	local TSHandler = Player.Character:FindFirstChild('TSclientHandler');
	if (TSHandler) then
		getgenv()[cache][TSHandler] = true;
	end
	if (getgenv().WalkingInTS and TSHandler) then
		Wrap(function()
			repeat wait() until game:GetService('Lighting').TS.Value == false;
			TSHandler.Disabled = true;
		end)
	end

	local old_delay = getsenv(self.StandScript).delay;

	getsenv(self.StandScript).delay = function(...)
		if (getgenv().HitCoolEnabled) then -- stand script
			return ({...})[2]();
		end
		return old_delay(...)
	end
 
	if (self.CurrentConnections['RenderStepped'] ~= nil) then
		self.CurrentConnections['RenderStepped']:Disconnect()
	end
	self.CurrentConnections['RenderStepped'] = game:GetService('RunService')['RenderStepped']:Connect(function()
		if (getgenv()[objects][_self.Name]) then
			getgenv()[objects][_self.Name]:Stepped();
		end
	end)
end

function BizarreLibrary:Start()
	local _self = self;

	self.CurrentConnections['CharacterAdded'] = Player.CharacterAdded:Connect(function(Char)

		getgenv()[objects][_self.Name]:InternalStart();

	end)

	getgenv()[objects][_self.Name]:InternalStart();

	if not getgenv().died then
		Player.Character:BreakJoints() -- Required for some hooked functions
		getgenv().died = true
	end

end

function BizarreLibrary:Disable(isReset)
	for _,Connection in next, self.CurrentConnections do
		if (Connection ~= nil) then
			Connection:Disconnect()
		end
	end;
	local Additional = isReset and ", reset for changes to take effect." or "."
	warn(string.format('Disabled %s%s', self.Name, Additional));
end
 
function BizarreLibrary:Enable()
	self:Start();
end

function BizarreLibrary:Destroy()
	for Key,Connection in next, self.CurrentConnections or {} do
		if (Connection ~= nil) then
			Connection:Disconnect()
			self.CurrentConnections[Key] = nil;
		end
	end;
	self.CurrentConnections = {};
	getgenv()[objects][self.Name] = nil;
	if (self.StandScript and getgenv()[cache][self.StandScript]) then
		getgenv()[cache][self.StandScript] = nil;
	end
end

if (not getgenv().MTHook) then
	local anchor = FindFirstChildOfClassAndName(game:GetService("ReplicatedStorage"),
				   "Anchor", "RemoteEvent");
	local ts_value = FindFirstChildOfClassAndName(game:GetService('Lighting'),
					 "TS", 'BoolValue');

	local finding = {
		'damage';'heal';'combatremote';'starplatinum';'barrage';'vampirefreeze','tuskact4';'rush';'requiemhandler';
	};

	local function did_find(a,b)
		return type(a) == 'string' and a:find(b)
	end

	local function correctremote(a)
		for i,v in next, finding do
			if did_find(a,v) then
				return true
			end
		end
		return false
	end

	if (not anchor) then
		warn("Failed to find Anchor remote. Walking in TS will not work.");
	end

	-- Just in case this is ran during a TS.
	repeat wait() until game:GetService("Lighting").TS.Value == false;

	local game_mt = getrawmetatable(game);
	setreadonly(game_mt, false);

	local index = game_mt.__index
	game_mt.__index = function(self, key, ...)

		if (self == ts_value and tostring(key) == 'Value') then
			local calling = getcallingscript()
			if (calling and getgenv()[cache][calling] and getgenv().WalkingInTS) then
				return false;
			end
		end

		return index(self, key, ...)

	end

	local namecall = game_mt.__namecall
	game_mt.__namecall = function(self,...)

		local exploit_key = 'awesome_legit_script_call_definitely_for_an_exploit_shhh'

		local Args = {...}
		local method = tostring(getnamecallmethod())
		local called_remote = method == 'FireServer' or method == 'InvokeServer'

		local is_instance = typeof(self) == 'Instance'
		local name_to_lower = is_instance and string.lower(self.Name)
		local valid_attack = correctremote(name_to_lower);
		local not_exploit_call = Args[#Args] ~= exploit_key
		if ( is_instance and name_to_lower and valid_attack and called_remote and not_exploit_call) then

			local is_attack = type(Args[2]) == 'table' and (typeof(Args[2][1]) == 'Instance')
			if name_to_lower == 'chariotrequiemhandler' and (is_attack and Args[2][1]:IsA('Humanoid')) then
				Args[1] = 'Charge'
			end

			local Multiplier = getgenv().DamageMultiplier or 1;

			Args[#Args+1] = exploit_key
			for i = 1, math.max(Multiplier, 1) do
				local r = self;
				Wrap(function()
					r[method](r, unpack(Args))
				end)
			end
			return nil;

		end

		if (anchor and self == anchor and getgenv().WalkingInTS == true) then
			Args[2] = false
		end

		return namecall(self,unpack(Args));
	end

	setreadonly(game_mt, true)

	getgenv().MTHook = true;
end

return BizarreLibrary
