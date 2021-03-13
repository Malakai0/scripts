-- must use autoexec script

local Folder = 'Robeats_Songs'
if not isfolder(Folder) then makefolder(Folder) end

local DifficultySeparator = ".DIFF_SEPARATE."

local NOT_ALLOWED = {
    "<";">";":";"\"";"/";"\\";"|";"?";"*"
}

local function SaveDirectory(Directory, IsRemix)
    for i,v in next, Directory:GetChildren() do
        if (v:IsA('ModuleScript') and type(require(v)) == 'table') then
            pcall(coroutine.wrap(function()
                local Loaded = require(v)
                local Encoded = game:GetService'HttpService':JSONEncode(Loaded)
                local Difficulty = Loaded.AudioDifficulty;
                local Name = Loaded.AudioFilename;
                
                for _,c in next, NOT_ALLOWED do
                    Name = Name:gsub(c, "")
                end
                
                local Extra = IsRemix and '.REMIX.' or ''
                Name = Name .. DifficultySeparator .. Extra .. Difficulty
                
                writefile(Folder..'/'..Name..'.txt', Encoded)
            end))
        end
    end
end

SaveDirectory(game:GetService'ReplicatedStorage'.NewSong)