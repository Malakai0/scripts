getgenv().Multiplier = 5; -- very very bad damage multiplier that doesn't really work
getgenv().MaxSpeed = 100; -- max odm speed

getgenv().DisableBackflip = true; -- when you press 'S' in the air it does some shit backflip thing
getgenv().UnlimitedGas = true -- odm gas
getgenv().UnlimitedBlades = true; -- odm blades
getgenv().InfiniteRange = true; -- odm range
getgenv().AntiGrab = false; -- titan grab
getgenv().AntiKick = true; -- some random exploit kicks i think
getgenv().AntiHurt = true; -- when titans ground pound you



-- Don't edit past this point.



local Player = game:GetService('Players').LocalPlayer
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Assets").Remotes

local StruggleEvent = Remotes.Struggle;
local HurtEvent = Remotes.Damage;
local KickEvent = Remotes.Naughty;
local AttackEvent = Remotes.Blade;
local RemoteExploitKey = tostring(math.random(-1000,1000)) .. string.char(50,100);

local ODM;
local CurrentConnection;
getgenv().ToDestroy = getgenv().ToDestroy or {}

local function CharAdded()
	repeat wait() until Player.Character.Parent ~= nil;
	local Controller = Player.Character:WaitForChild('Controller')
	wait(1)
	local Environment = getsenv(Controller)

	local Systems = Environment.Systems;
	ODM = Systems.ODMG;

	local HUD = Player.PlayerGui:WaitForChild'HUD'
	local Handler = HUD.Handler;


	HUD:WaitForChild'Buttons'.ChildAdded:Connect(function(Child)
		if getgenv().AntiGrab and Child.Name:lower() == 'letter' then
			Child.Visible = false;
			getgenv().ToDestroy[#getgenv().ToDestroy+1] = Child;
		end
	end)
end

if (getgenv().CurCA) then
	getgenv().CurCA:Disconnect()
end

CharAdded()
getgenv().CurCA = Player.CharacterAdded:Connect(CharAdded)

local function Update()
	ODM.idk = getgenv().DisableBackflip and (function() end) or ODM.idk; -- Remove stupid 'S' move.
	ODM.Equipment.Gas = getgenv().UnlimitedGas and 10000 or ODM.Equipment.Gas;
	ODM.Equipment.Blades = getgenv().UnlimitedBlades and 150 or ODM.Equipment.Blades;
	ODM.Properties.Range = getgenv().InfiniteRange and 100000 or 300;
	ODM.Properties.MaxSpeed = getgenv().MaxSpeed or 60;

	for i,v in next, getgenv().ToDestroy do
		v:Destroy()
		getgenv().ToDestroy[i] = nil;
	end
end

local function Attack()
	AttackEvent:FireServer(RemoteExploitKey)
end

if (not getgenv().RanMTHook) then
	getgenv().RanMTHook = true;
	local MT = getrawmetatable(game)
	local Namecall = MT.__namecall;

	setreadonly(MT,false)

	MT.__namecall = function(self, ...)
		local Method = getnamecallmethod()
		local IsRemote = string.lower(Method) == 'fireserver'
		local IsExploitCall = ({...})[1] == RemoteExploitKey
		if self == KickEvent and IsRemote and getgenv().AntiKick then return end -- anti-kick
		if self == HurtEvent and IsRemote and getgenv().AntiHurt then return end; -- hurty hurty go away come again another day
		if self == AttackEvent and IsRemote and (not IsExploitCall) then
			for i = 1, math.max((getgenv().Multiplier-1), 1) do
				spawn(Attack)
			end
		end
		return Namecall(self, ...);
	end

	if getgenv().AntiGrab then
		local LastCall = {}
		StruggleEvent.OnClientEvent:Connect(function(_,titan,_)
			LastCall[titan] = LastCall[titan] or 0;
			if (tick() - LastCall[titan] >= 1 and getgenv().AntiGrab) then 
				StruggleEvent:FireServer(titan)
				LastCall[titan] = tick()
			else
				wait()
			end
		end)
	end

	game:GetService('RunService').RenderStepped:Connect(Update)
end
