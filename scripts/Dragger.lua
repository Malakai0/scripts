local mouse = game:GetService("Players").LocalPlayer:GetMouse();
local inputService = game:GetService('UserInputService');
local heartbeat = game:GetService("RunService").Heartbeat;
return function(frame)
    local s, event = pcall(function()
        return frame.MouseEnter
    end)

    if s then
        frame.Active = true;

        event:connect(function()
            local input = frame.InputBegan:connect(function(key)
                if key.UserInputType == Enum.UserInputType.MouseButton1 then
                    local objectPosition = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y);
                    while heartbeat:wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        frame:TweenPosition(UDim2.new(0, mouse.X - objectPosition.X + (frame.Size.X.Offset * frame.AnchorPoint.X), 0, mouse.Y - objectPosition.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)), 'Out', 'Quad', 0.1, true);
                    end
                end
            end)

            local leave;
            leave = frame.MouseLeave:connect(function()
                input:disconnect();
                leave:disconnect();
            end)
        end)
    end
end
