local uis = game:GetService('UserInputService')
local mouse = game:GetService('Players').LocalPlayer:GetMouse()
local event = game:GetService("ReplicatedStorage").TuskAbilities

local toggles = {};

local keybinds = {binds={}}
function keybinds.new(key,btype,use_parent)
    keybinds.binds[btype] = {
        key = key;
        use_parent = use_parent;
        bullet_type = btype;
    };
end
function keybinds.get(input)
    local yes = keybinds.binds[input]
    if yes then return yes end

    for i,v in next, keybinds.binds do
        if v.key == input then
            return v
        end
    end
end

for i,v in next, {
    NailShoot = {Enum.KeyCode.E};
    TrackingBullet = {Enum.KeyCode.T};
    NailShotgun = {Enum.KeyCode.R, true};
    DrinkCoffee = {Enum.KeyCode.H};
} do
    keybinds.new(v[1],i,v[2] or false)
end

local function fire(bullet_type)
    local bind = keybinds.get(bullet_type);
    event:FireServer(bullet_type, bind.use_parent and mouse.Target.Parent or mouse.Hit,
                    'Normal')
end

local function start(btype)
    toggles[btype] = true;
    repeat
        fire(btype)
        wait(.01)
    until toggles[btype] == false;
end

uis.InputBegan:Connect(function(key,c)
    if c then return end;

    local bind = keybinds.get(key.KeyCode)
    if bind then
        coroutine.resume(coroutine.create(start), bind.bullet_type)
    end
end)

uis.InputEnded:Connect(function(key,c)
    if c then return end;
    
    local bind = keybinds.get(key.KeyCode)
    if bind then
        toggles[bind.bullet_type] = false;
    end
end)