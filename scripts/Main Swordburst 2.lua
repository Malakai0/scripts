local UILibrary = loadstring(game:HttpGet"https://gist.githubusercontent.com/Whomever0/0fad2d925349ea6e2806da00cb9b3a93/raw/1fbf36b4077ff0f0589d7068ef7f353eb7ae583f/UILib.lua")()
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

getgenv().Multiplier = 1; -- default idk

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game:GetService'Players'.LocalPlayer
local PlayerProfile = ReplicatedStorage:WaitForChild'Profiles':WaitForChild(Player.Name)

local Database = ReplicatedStorage.Database;

local Event = ReplicatedStorage.Event;
local Function = ReplicatedStorage.Function;

local SwordMethod = '';
local ExploitCallKey = tostring(math.random(0,999)) .. string.char(math.random(0,100))
local CombatModule, UtilModule;

local HitInfo = {
    HitCounter = {};
    Waiting = {};
};

local WhitelistedSkills = {
    ['Leaping Slash'] = 'Katana';
    ['Sweeping Strike'] = '1HSword';
}

local WhitelistedClasses = {
    ['Katana'] = 'Leaping Slash';
    ['1HSword'] = 'Sweeping Strike';
}

local function SetModules()
    for i,v in next, getgc(true) do
        if type(v) == 'table' and rawget(v, 'DamageArea') then
            CombatModule = v;
        elseif (type(v) == 'table' and rawget(v, 'LevelFromExp')) then
            UtilModule = v;
        end
    end
end
SetModules()

if not CombatModule then
    repeat
        wait(1)
        SetModules()
    until CombatModule
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

if (TypeChosen == 2) then
    PerformEpic()
else
    Event:FireServer('Skills',{
        'UseSkill','Summon Pistol'
    })
end

local ToggleValue = false;
local SwordSkillsValue = false;

local MainWindow = UILibrary:MakeWindow('Main')

local Toggled = MainWindow:addCheckbox('Multiplier Toggle')
local MultiplierTextbox = MainWindow:addTextBoxF('Damage Multiplier', function(Text)
    getgenv().Multiplier = tonumber(Text) and math.max(tonumber(Text), 1) or 1;
end)
local KillAura = MainWindow:addCheckbox('Kill Aura')
local InfStamina = MainWindow:addCheckbox('Infinite Stamina')
local SwordSkills = MainWindow:addCheckbox('Use Sword Skills')
MainWindow:addLabel("Made by malakai#1962", 'Center');

if (not getrawmetatable or not setreadonly) then
    print("Exploit isn't supported.");
    repeat wait(5) until nil;
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

    if (Player.Character.Entity.Health.Value <= Player.Character.Entity.Health.MinValue) then
        return true
    end

    if (Target.Entity.Health.Value <= Target.Entity.Health.MinValue) then
        return true
    end

    return false
end

local function HitMob(Target)

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

    coroutine.wrap(Event.FireServer)(Event, unpack(Arguments))
    return true
end

local function AuraHit()
    local Root = Player.Character:WaitForChild('LowerTorso', 2)
    local Hits = ToggleValue and math.clamp(getgenv().Multiplier, 1, 50) or 1;
    for _ = 1, Hits do -- not too laggy
        for _,Mob in next, workspace.Mobs:GetChildren() do
            local PrimaryPart = Mob:IsA'Model' and Mob.PrimaryPart
            local Distance = PrimaryPart and (Root.Position - PrimaryPart.Position).Magnitude
            local Waiting = SwordSkillsValue == false and HitInfo.Waiting[Mob]
            if (Distance and Distance <= 20 and (not Invalid(Mob)) and (not Waiting)) then
                coroutine.wrap(HitMob)(Mob)
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    ToggleValue = Toggled.Checked.Value
    SwordSkillsValue = SwordSkills.Checked.Value

    if (KillAura.Checked.Value) then
        spawn(AuraHit);
    end

    if (InfStamina.Checked.Value) then
        if Player.Character then
            Player.Character:WaitForChild("Entity").Stamina.Value = 100
        end
        coroutine.wrap(Event.FireServer)(Event, 'Actions', {'Sprint','Disabled'})
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
            for _ = 1, Hits do -- not too laggyz
                if Invalid(Mob) then break end;
                if (not HitMob(Mob)) then
                    break;
                end
            end

            return nil;
        end
    elseif (self == Event and IsActionService and IsSprintStep) then
        return;
    end

    return Namecall(self,...)
end