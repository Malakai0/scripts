local A,D = 0x41, 0x44
local Holding = nil;
local Toggle = false;

local function ReleaseCurrent()
    if (Holding) then
        keyrelease(Holding)
        Holding = nil;
    end
end

local function StimulatePress(Key)
    if (Holding ~= Key) then
        ReleaseCurrent()
        Holding = Key;
        keypress(Holding)
    end
end

game:GetService'RunService'.Heartbeat:Connect(function()
    local Delta = game:GetService'UserInputService':GetMouseDelta()
    local Movement = Delta.X;
    local Normal = Movement < 0 and -1 or Movement > 0 and 1 or 0;
    
    if (game:GetService'UserInputService':IsKeyDown(Enum.KeyCode.E)) then
        if (Normal == 0 and Holding) then
            StimulatePress(Holding)
        elseif (Normal == 1) then -- right
            StimulatePress(D)
        elseif (Normal == -1) then -- left
            StimulatePress(A)
        end
    else
        ReleaseCurrent()
    end
end)