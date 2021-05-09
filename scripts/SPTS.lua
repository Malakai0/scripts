local luckyGui = 'https://gist.githubusercontent.com/Whomever0/31f9efd839096f9df385a83ae1c91352/raw/085bb7919506684dda35079e62efbd4f3f6f77d2/SPTS_LuckyMMB.lua'
loadstring(game:HttpGet(luckyGui, false))();

if (getgenv().executedSPTS) then repeat wait(600) until nil end
getgenv().executedSPTS = true;

local Player = game:GetService'Players'.LocalPlayer
local VirtualUser = game:GetService'VirtualUser'
VirtualUser:CaptureController()

local Respawning = false;
local Toggled = false;
local LastRespawn = 0;
local Position;

local function Respawn()
    game:GetService("ReplicatedStorage").RemoteEvent:FireServer({"Respawn"})
end

game:GetService'UserInputService'.InputBegan:Connect(function(Key,IC)
    if (IC) then return end

    if (Key.KeyCode == Enum.KeyCode.L) then
        Position = Player.Character:GetPrimaryPartCFrame().Position
    elseif (Key.KeyCode == Enum.KeyCode.P) then
        Toggled = not Toggled
    end
end)

game:GetService'RunService'.Heartbeat:Connect(function()

    if (not Toggled or not Position) then return end;

    local Character = Player.Character;
    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    local HumanoidRootPart = Character:FindFirstChild'HumanoidRootPart'

    if (tick() - LastRespawn >= 1.25 and (not Respawning)) then
        Respawning = true
	    Respawn()
        repeat wait() until Player.Character ~= Character;
        LastRespawn = tick()
        Respawning = false
        VirtualUser:CaptureController()
        VirtualUser:SetKeyDown(0x77)
        wait(.1)
        VirtualUser:SetKeyUp(0x77)
    end

    if (HumanoidRootPart and Position) then
        HumanoidRootPart.CFrame = CFrame.new(Position);
    end

end);
