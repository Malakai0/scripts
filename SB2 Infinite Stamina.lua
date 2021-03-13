getgenv().replace_only_skills = true;

if getgenv().sb2_exploit_called then repeat wait(600) until nil end
getgenv().sb2_exploit_called = true

local Player = game:GetService'Players'.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerProfile = ReplicatedStorage:WaitForChild'Profiles':WaitForChild(Player.Name)
local Database = ReplicatedStorage.Database;

local Event = ReplicatedStorage.Event;
local Function = ReplicatedStorage.Function;

local WhitelistedSkills = {
    ['Leaping Slash'] = 'Katana';
    ['Sweeping Strike'] = '1HSword';
}

local WhitelistedClasses = {
    ['Katana'] = 'Leaping Slash';
    ['1HSword'] = 'Sweeping Strike';
}

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
                if WhitelistedClasses[Item.Class.Value] then
                    return true,WhitelistedClasses[Item.Class.Value], true, v;
                end
            end
        end
        return false
    end)

    if not Success then
        warn('Failed initialization! Get a Longsword or katana and try again!')
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

PerformEpic();

local m = getrawmetatable(game)
local nm = m.__namecall
setreadonly(m,false)

m.__namecall = function(e,...)
    
    local Args = {...}
    if e == Event and string.lower(getnamecallmethod()) == 'fireserver' then
        local Action = Args[1] == 'Actions'
        local Step = type(Args[2]) == 'table' and Args[2][2] == 'Step'
        if Action and Step then
            return;
        end
        
        local Combat = Args[1] == 'Combat'
        local Attack = type(Args[3]) == 'table' and Args[3][1] == 'Attack'
        local IsSpecialAttack = type(Args[3]) == 'table' and Args[3][2] ~= nil
        local ReplaceSkills = getgenv().replace_only_skills
        if Combat and Attack and (ReplaceSkills and IsSpecialAttack or not ReplaceSkills) then
            Args[3][2] = UsedToFuck;
        end
        
    end
    
    return nm(e, unpack(Args))
end