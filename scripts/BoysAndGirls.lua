local Tool;
local Name = 'PompousTheCloud';
local Player = game:GetService'Players'.LocalPlayer;
local Backpack = Player.Backpack;

local Cash = Player:WaitForChild('leaderstats'):WaitForChild'Cash'.Value;
if Cash < 0 then print('Unable to execute.') repeat wait(600) until nil end

function CharacterAdded()
	Tool = Backpack:FindFirstChild(Name) or Player.Character:FindFirstChild(Name);
	if (not Tool) then
		game:GetService("Workspace").Buy:FireServer(0,'PompousTheCloud');
		repeat
            Tool = Backpack:FindFirstChild(Name) or Player.Character:FindFirstChild(Name);
            wait()
        until Tool
	end
end

CharacterAdded()

Player.CharacterAdded:Connect(CharacterAdded)

local function Fire(O,P,V,KE) -- Object, Property, Value, KeepEquipped
	if (not Tool) then return end;
	local Humanoid = Player.Character and Player.Character:FindFirstChildOfClass('Humanoid')
	if (Humanoid and not Player.Character:FindFirstChild(Tool)) then
		Humanoid:EquipTool(Tool)
	end
	local Event = Tool:WaitForChild'ServerControl';
	Event:InvokeServer("SetProperty", {Object = O; Property = P; Value = V;});
	if (not KE) then
		Tool.Parent = Backpack;
	end
end

local function MassFire(O,List,KE)
	for P,V in next, List do
		Fire(O, P, V, true)
	end
	if (not KE) then
		Tool.Parent = Backpack;
	end
end

Fire(Tool.Handle.Mesh, 'MeshId', '', true)

MassFire(Tool.Handle.Wind, {
	EmitterSize = 10000;
	PlaybackSpeed = 1;
	Volume = 3;
	SoundId = 'rbxassetid://4556139946';
	Pitch = 1;
}, true);

Fire(Tool.Handle.Wind, 'Name', 'daddy_music', true)

Fire(Tool.Handle.daddy_music, 'Parent', workspace, true);

workspace.daddy_music:Play()