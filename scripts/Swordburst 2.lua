if (not getrawmetatable or not setreadonly) then
    warn("Exploit isn't supported.");
    repeat wait(5) until nil;
end

local CurrentPlace = game.PlaceId;

local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/Whomever0/exploit-scripts/master/main.lua"))();
local UILibrary = Load("UILibrary")
local ChooseType = UILibrary:MakeWindow('Skill Type')
ChooseType:addLabel('CHOOSE YOUR SKILL TYPE', 'Center')
ChooseType:addLabel('OP does a lot more DMG', 'Center')

local TypeChosen = -1;

ChooseType:addButton('OP', function()
    TypeChosen = 1;
end)

ChooseType:addButton('Normal', function()
    TypeChosen = 2;
end)

repeat wait() until TypeChosen ~= -1;
ChooseType.Frame:Destroy()

getgenv().Multiplier = 1;

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game:GetService'Players'.LocalPlayer
local PlayerProfile = ReplicatedStorage:WaitForChild'Profiles':WaitForChild(Player.Name)
local Vel,Exp = PlayerProfile.Stats.Vel, PlayerProfile.Stats.Exp;
local Inventory = PlayerProfile.Inventory;

local Database = ReplicatedStorage.Database;

local Event = ReplicatedStorage.Event;
local Function = ReplicatedStorage.Function;

local ExploitCallKey = tostring(math.random(0,999)) .. string.char(math.random(0,100))
local UtilModule;

local ToggleValue = false;
local SwordSkillsValue = false;
local AutofarmToggle = false;

local SBInfo = Load("SwordburstInfo")
local PlaceInfo = SBInfo.Mobs[CurrentPlace];

local Priority = {
    ["Closest"] = 1;
    ["Boss"] = 2;
}

local CurrentPriority = Priority.Closest;

local HitInfo = {
    HitCounter = {};
    Waiting = {};
    HaveHit = {};
    Killed = {};
    TotalKills = 0;
};

local WhitelistedSkills = {
    ['Leaping Slash'] = 'Katana';
    ['Sweeping Strike'] = '1HSword';
}

local WhitelistedClasses = {
    ['Katana'] = 'Leaping Slash';
    ['1HSword'] = 'Sweeping Strike';
}

local InsideDoorP = SBInfo.Doors.Inside[CurrentPlace];
local OutsideDoorP = SBInfo.Doors.Outside[CurrentPlace];
local InsideDoor,OutsideDoor;
Player:RequestStreamAroundAsync(InsideDoorP.Position);
Player:RequestStreamAroundAsync(OutsideDoorP.Position);

for _,v in next, workspace:GetDescendants() do
    if v:IsA("BasePart") then
        if (v.CFrame == InsideDoorP) then
            InsideDoor = v;
        elseif (v.CFrame == OutsideDoorP) then
            OutsideDoor = v;
        end
    end
end

local MainWindow = UILibrary:MakeWindow('Main')

local function Separator()
    return MainWindow:addLabel("","Center")
end

local function SectionTitle(n,notfirst)
    if notfirst then Separator() end
    MainWindow:addLabel(n, "Center")
    --Separator()
end

local function SetModules()
    for i,v in next, getgc(true) do
        if (type(v) == 'table' and rawget(v, 'LevelFromExp')) then
            UtilModule = v;
            break;
        end
    end
end

local function TeleportToBossRoom()
    firetouchinterest(Player.Character.PrimaryPart, InsideDoor, 0)
    wait()
    firetouchinterest(Player.Character.PrimaryPart, InsideDoor, 1);
end

local function TeleportOutBossRoom()
    firetouchinterest(Player.Character.PrimaryPart, OutsideDoor, 0)
    wait()
    firetouchinterest(Player.Character.PrimaryPart, OutsideDoor, 1);
end

local function GetInventoryRarityStuff()
    local DATA = {
        ["Legendary"] = 0;
        ["Rare"] = 0;
        ["Uncommon"] = 0;
        ["Common"] = 0;
    }
    for _,Item in next, Inventory:GetChildren() do
        local DB = Database.Items:FindFirstChild(Item.Name);
        if (DB) then
            if (DATA[DB.Rarity.Value]) then
                DATA[DB.Rarity.Value] = DATA[DB.Rarity.Value] + 1;
            end
        end
    end
    return DATA;
end

local function GetSkill()
    local Style = getrenv()._G.CalculateCombatStyle()
    for i,v in pairs(Database.Skills:GetChildren()) do
        if v:FindFirstChild("Class") and v.Class.Value == Style then
            return v
        end
    end
end

local function CheckWhitelist(callback)
    local SwordStyle = GetSkill()
    local NotWhitelisted = WhitelistedSkills[SwordStyle] == nil
    if NotWhitelisted and type(callback) == 'function' then
        return callback();
    end
    return true, GetSkill(), false
end

local function GetItemFromInventoryIndex(index)
    for i,v in next, PlayerProfile.Inventory:GetChildren() do
        if v.Value == index then
            return v
        end
    end
end

local UsedToFuck;
local function PerformEpic()
    SetModules()
    local Success, ChosenSkill, ShouldSwap, SwapTo = CheckWhitelist(function()
        local Equipped = PlayerProfile.Equip
        local Left,Right = Equipped.Left.Value,Equipped.Right.Value
        for i,v in next, PlayerProfile.Inventory:GetChildren() do
            local Item = Database.Items:FindFirstChild(v.Name)
            if (Item and Item:FindFirstChild'Class') then
                local ItemLVL = Item.Level.Value;
                local PlrEXP = PlayerProfile.Stats.Exp.Value;
                local PlrLevel = UtilModule.LevelFromExp(PlrEXP);
                if WhitelistedClasses[Item.Class.Value] and PlrLevel >= ItemLVL then
                    return true,WhitelistedClasses[Item.Class.Value], true, v;
                end
            end
        end
        return false
    end)

    if not Success then
        warn('Failed initialization! Get a Longsword or katana (that you are able to wield) and try again!')
        repeat wait(600) until nil
    end

    if ShouldSwap then

        local Equipped = PlayerProfile.Equip
        local Left,Right = Equipped.Left.Value,Equipped.Right.Value

        Function:InvokeServer('Equipment', {'EquipWeapon', SwapTo, 'Right'})
        
        wait(.1)

        UsedToFuck = ChosenSkill
        Event:FireServer('Skills',{
            'UseSkill', ChosenSkill
        })

        wait(.1)
        
        if Left ~= 0 then
            coroutine.wrap(Function.InvokeServer)(Function, 'Equipment', 
                {'EquipWeapon', GetItemFromInventoryIndex(Left), 'Left'})
        end
        
        if Right ~= 0 then
            coroutine.wrap(Function.InvokeServer)(Function, 'Equipment', 
                {'EquipWeapon', GetItemFromInventoryIndex(Right), 'Right'})
        end

    else

        UsedToFuck = ChosenSkill
        Event:FireServer('Skills',{
            'UseSkill', ChosenSkill
        })

    end
end

local function GetCooldown()
    return getgenv().SB2_WAIT_TIME or 1.05;
end

local function GetSwordMethod()
    if (SwordSkillsValue == true) then
        return TypeChosen == 1 and 'Summon Pistol' or UsedToFuck;
    end
    return nil;
end

local function Invalid(Target)
    if (Target == nil) then
        return true
    end

    local PrimaryPartCF = Target:GetPrimaryPartCFrame()
    local Root = Player.Character:WaitForChild('HumanoidRootPart')

    if (PrimaryPartCF.Position - Root.Position).Magnitude > 20 then
        return true
    end

    if (not Target:FindFirstChild('Entity')) then
        return true;
    end

    if (Player.Character.Entity.Health.Value <= Player.Character.Entity.Health.MinValue) then
        return true
    end

    if (Target.Entity.Health.Value <= Target.Entity.Health.MinValue) then
        return true
    end

    return false
end

local function KilledMobCheck(Target)
    if (Invalid(Target) and HitInfo.Killed[Target]) then
        return true
    end
    if (Target.Entity.Health.Value <= 0) then
        if (HitInfo.HaveHit[Target] == true and HitInfo.Killed[Target] == nil) then
            HitInfo.Killed[Target] = true;
            HitInfo.TotalKills  = HitInfo.TotalKills + 1;
            return true
        end
    end
end

local function HitMob(Target)

    if (Invalid(Target)) then
        return false;
    end

    local Normal = (SwordSkillsValue == false)

    if (HitInfo.Waiting[Target] and Normal) then
        return false;
    end

    if (not HitInfo.HitCounter[Target]) then
        HitInfo.HitCounter[Target] = 0;
    end;

    local HitAmount = 6
    if (HitInfo.HitCounter[Target] % HitAmount == 0 and HitInfo.HitCounter[Target] > 0 and Normal) then
        HitInfo.Waiting[Target] = true;
        wait(GetCooldown())
        HitInfo.Waiting[Target] = false;
    end

    if (Normal) then
        HitInfo.HitCounter[Target] = HitInfo.HitCounter[Target] + 1
    else
        HitInfo.HitCounter[Target] = 0
    end

    local Arguments = {
        'Combat',
        {'\204','\214','\177','\251'},
        {
            'Attack',
            GetSwordMethod(),
            1,
            Target
        },
        ExploitCallKey
    }

    HitInfo.HaveHit[Target] = true;
    coroutine.wrap(function()
        Event:FireServer(unpack(Arguments));
        for i = 1, 500 do
            if (KilledMobCheck(Target)) then
                break
            end
            wait(0.01)
        end
    end)()
    return true
end

local function AuraHit()
    local Root = Player.Character:WaitForChild('LowerTorso', 2)
    local Hits = ToggleValue and math.clamp(getgenv().Multiplier, 1, 50) or 1;
    for _ = 1, Hits do
        for _,Mob in next, workspace.Mobs:GetChildren() do
            local PrimaryPart = Mob:IsA'Model' and Mob.PrimaryPart
            local Distance = PrimaryPart and (Root.Position - PrimaryPart.Position).Magnitude
            local Waiting = SwordSkillsValue == false and HitInfo.Waiting[Mob]
            if (Distance and Distance <= 30 and (not Invalid(Mob)) and (not Waiting)) then
                coroutine.wrap(HitMob)(Mob)
            end
        end
    end
end

local function GetTargetMob()
    if (CurrentPriority == Priority.Boss) then
        local BossMob = workspace.Mobs:FindFirstChild(PlaceInfo.Boss);
        local Ent = BossMob and BossMob:FindFirstChild'Entity'
        local PrimaryPart = BossMob and BossMob:IsA'Model' and BossMob.PrimaryPart
        if (PrimaryPart and Ent and Ent.Health.Value > 0) then
            return BossMob,true;
        end
    end

    local Closest,Dist = nil,math.huge;

    for _,Mob in next, workspace.Mobs:GetChildren() do
        local Ent = Mob and Mob:FindFirstChild'Entity'
        local PP = Mob:IsA'Model' and Mob.PrimaryPart
        if (PP and Ent and Ent.Health.Value > 0) then
            local Di = (Player.Character.PrimaryPart.Position - PP.Position).Magnitude
            if (Di < Dist) then
                Dist = Di;
                Closest = Mob;
            end
        end
    end

    return Closest,false;
end

local function GetWaypoints(A,B)
	local Waypoints = {}
	local Distance = (B - A).Magnitude;
	local Floored = math.floor(Distance);
	local Index = 1;
    local minDist = 8;
    if (Floored > minDist) then
        for i = minDist, Floored, minDist do
            Waypoints[Index] = A:Lerp(B, i/(Floored))
            Index = Index + 1;
        end
    end
	Waypoints[#Waypoints+1] = A:Lerp(B, 1)
	return Waypoints
end

local AutofarmPositionUpdate = true;
local function UpdateAutofarm()
    local CurrentFarmTarget,IsBoss = GetTargetMob();
    local PlayerP = Player.Character.PrimaryPart;
    PlayerP.Velocity = Vector3.new(0,2,0);
    Player.Character:WaitForChild'Humanoid':ChangeState(11)

    local TPP = CurrentFarmTarget and CurrentFarmTarget.PrimaryPart;
    local Validate = CurrentFarmTarget and TPP
    local Dist = TPP and (TPP.Position - PlayerP.Position).Magnitude
    local BossRoomWaiting = CurrentPriority == Priority.Boss and not Validate or (Validate and (Dist > 1000))
    if (not BossRoomWaiting and AutofarmPositionUpdate) then
        AutofarmPositionUpdate = false;
        if (Dist > 1000 and IsBoss) then
            TeleportToBossRoom()
        end

        local WaypointPosition;
        if (Dist < 20) then
            WaypointPosition = PlayerP.Position;
        else
            local L = GetWaypoints(PlayerP.Position, TPP.Position + Vector3.new(0,10.1,0))
            WaypointPosition = L[1];
        end

        PlayerP.CFrame = CFrame.new(WaypointPosition);

        local Hits = ToggleValue and math.clamp(getgenv().Multiplier, 1, 50) or 1;
        for _ = 1, Hits do
            if (not HitMob(CurrentFarmTarget)) then
                break;
            end
        end

        wait(0.1)
        AutofarmPositionUpdate = true
    elseif (BossRoomWaiting) then
        TeleportToBossRoom()
    end
end

if (TypeChosen == 2) then
    PerformEpic()
else
    Event:FireServer('Skills',{
        'UseSkill','Summon Pistol'
    })
end

SectionTitle("Combat")

local MultiplierTextbox = MainWindow:addTextBoxF('Damage Multiplier', function(Text)
    local formatted,_ = Text:gsub("%D", "");
    getgenv().Multiplier = tonumber(formatted) and math.max(tonumber(formatted), 1) or 1;
end)
local KillAura = MainWindow:addCheckbox('Kill Aura')
local InfStamina = MainWindow:addCheckbox('Infinite Stamina')
local SwordSkills = MainWindow:addCheckbox('Use Sword Skills')
MainWindow:addButton("Go Invisible (Until Death)", function()
    local Character = Player.Character;
    if (Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild('Root')) then
        local RootClone = Character.LowerTorso.Root:Clone();
        Character.LowerTorso.Root:Destroy()
        RootClone.Parent = Character.LowerTorso;
    end
end)

SectionTitle("Autofarm", true);
local FarmEnabled = MainWindow:addCheckbox('Autofarm Enabled')
MainWindow:addButton("Teleport into boss room", TeleportToBossRoom)
MainWindow:addButton("Teleport to end", TeleportOutBossRoom)
local PrioritizeBoss = MainWindow:addCheckbox("Prioritize boss")


SectionTitle("Stat Gains", true)

local velTracker = MainWindow:addLabel("Vel earned: 0", "Left");
local expTracker = MainWindow:addLabel("EXP Earned: 0", "Left");
local levelTracker = MainWindow:addLabel("Levels gained: 0", "Left");
local killsTracker = MainWindow:addLabel("Kills: 0", "Left");

SectionTitle("Inventory Gains", true)

local legendariesEarned = MainWindow:addLabel("Legendaries Earned: 0", "Left");
local raresEarned = MainWindow:addLabel("Rares Earned: 0", "Left");
local uncommonsEarned = MainWindow:addLabel("Uncommons Earned: 0", "Left");
local commonsEarned = MainWindow:addLabel("Commons Earned: 0", "Left");

Separator();
MainWindow:addLabel("Made by malakai#1962", 'Center');

local Rarities = {
    ["Legendary"] = legendariesEarned;
    ["Rare"] = raresEarned;
    ["Uncommon"] = uncommonsEarned;
    ["Common"] = commonsEarned;
};

local Pluralized = {
    ["Legendary"] = "Legendaries";
    ["Rare"] = "Rares";
    ["Uncommon"] = "Uncommons";
    ["Common"] = "Commons";
}

SetModules()
local FirstVals = {
    Vel = Vel.Value;
    Exp = Exp.Value;
    Level = math.floor(UtilModule.LevelFromExp(Exp.Value));
    InvRarities = GetInventoryRarityStuff();
}

repeat wait() until Player.Character and Player.Character.PrimaryPart;
local P = Player.Character.PrimaryPart.CFrame;
TeleportToBossRoom()
wait(.25)
Player.Character:BreakJoints();

game:GetService("RunService").Heartbeat:Connect(function()
    ToggleValue = true
    SwordSkillsValue = SwordSkills.Checked.Value
    AutofarmToggle = FarmEnabled.Checked.Value;
    CurrentPriority = PrioritizeBoss.Checked.Value and Priority.Boss or Priority.Closest

    if (AutofarmToggle) then
        spawn(UpdateAutofarm)
    end

    if (KillAura.Checked.Value) then
        spawn(AuraHit);
    end

    if (InfStamina.Checked.Value) then
        if Player.Character then
            Player.Character:WaitForChild("Entity").Stamina.Value = 100
        end
        coroutine.wrap(Event.FireServer)(Event, 'Actions', {'Sprint','Disabled'})
    end

    local currentLevel = math.floor(UtilModule.LevelFromExp(Exp.Value))
    levelTracker.Value = "Levels Gained: " .. currentLevel - FirstVals.Level;
    velTracker.Value = "Vel Earned: " .. Vel.Value - FirstVals.Vel;
    expTracker.Value = "Exp Earned: " .. Exp.Value - FirstVals.Exp;
    killsTracker.Value = "Kills: " .. HitInfo.TotalKills;

    local CurrentInventoryRarities = GetInventoryRarityStuff();
    for Rarity,Value in next, CurrentInventoryRarities do
        local Title = Pluralized[Rarity] .. " Earned: "
        Rarities[Rarity].Value =  Title .. Value - FirstVals.InvRarities[Rarity];
    end
end)

local Meta = getrawmetatable(game)
local Namecall = Meta.__namecall
setreadonly(Meta, false)

Meta.__namecall = function(self,...)
    local Args = {...};
    local Service = Args[1];
    local ActionInfo = Args[2];
    local AttackInfo = Args[3];

    local IsExploitCall = Args[4] == ExploitCallKey;

    local IsCombatService = (Service and Service == 'Combat');
    local IsAttack = ((AttackInfo and type(AttackInfo) == 'table') and AttackInfo[1] == 'Attack');

    local IsActionService = (Service and Service == 'Actions');
    local IsSprintStep = ((ActionInfo and type(ActionInfo) == 'table') and ActionInfo[2] == 'Step');

    local Method = getnamecallmethod()

    if (self == Event and IsCombatService and IsAttack) then
        local Mob = Args[3][4]
        local Waiting = SwordSkillsValue == false and HitInfo.Waiting[Mob]
        if (IsExploitCall == false and (not Waiting)) then
            local Hits = ToggleValue and math.clamp(getgenv().Multiplier, 1, 50) or 1;
            for _ = 1, Hits do
                if Invalid(Mob) then break end;
                if (not HitMob(Mob)) then
                    break;
                end
            end

            return nil;
        elseif (IsExploitCall == false and Waiting) then
            if Invalid(Mob) then return end;
            HitMob(Mob)
            return nil;
        end
    elseif (self == Event and IsActionService and IsSprintStep) then
        return;
    end

    return Namecall(self,...)
end;

return nil;