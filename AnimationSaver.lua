local Animations = {};
local MarketplaceService = game:GetService("MarketplaceService");
local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name;
local Folder = string.format("%s_Animations", GameName);
local Prefix = "https://assetdelivery.roblox.com/v1/asset/?id=";

local Character = game:GetService('Players').LocalPlayer.Character

local function GrabNumbers(str)
    return tonumber(string.match(str, '%d+'));
end

if (Character and Character:FindFirstChildOfClass'Humanoid') then
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
    for _,Track in next, Humanoid:GetPlayingAnimationTracks() do
        local KEY = Prefix .. tostring(GrabNumbers(Track.Animation.AnimationId))
        if (not Animations[KEY]) then -- duplicates
            Animations[KEY] = Track.Animation.Name
        end
    end
end

function Wrap(func,...)
    return coroutine.resume(coroutine.create(func), ...);
end

if ( not syn_io_isfolder(Folder) ) then
    syn_io_makefolder(Folder);
end

wait(1.5)

local Saved = {};

for URL, Name in next, Animations do
    spawn(function()
        Saved[Name] = (Saved[Name] or 0) + 1
        local Count = Saved[Name]
        local FileName = string.format("%s_%s.rbxm", Name, tostring(Count));
        local Path = string.format("%s/%s", Folder, FileName);
        local File = game:HttpGet(URL);
        syn_io_write(Path, File);
    end)
end