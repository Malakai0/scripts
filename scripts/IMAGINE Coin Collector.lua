for i,v in next, workspace:GetChildren() do
    local Pos = v:IsA'BasePart' and v.Position;
    local Targ = Vector3.new(57.625, 5.00003, -166.567)
    local Different = Pos and (Targ - Pos).Magnitude or math.huge
    local Valid = Different < 2
    if Valid and v:FindFirstChild('Script') then
        for i = 1, 10 do
            coroutine.wrap(firetouchinterest)(game.Players.LocalPlayer.Character.Head, v, 0)
            coroutine.wrap(firetouchinterest)(game.Players.LocalPlayer.Character.Head, v, 1)
            wait(.8)
        end
        break
    end
end