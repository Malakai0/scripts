local Folder = 'RobeatsCS_Songs'
if not isfolder(Folder) then makefolder(Folder) end

local DifficultySeparator = ".DIFF_SEPARATE."

local NOT_ALLOWED = {
    "<";">";":";"\"";"/";"\\";"|";"?";"*"
}

for i,v in next, game:GetService'ReplicatedStorage'.Songs:GetChildren() do
    if (v:IsA('ModuleScript') and type(require(v)) == 'table') then
        pcall(coroutine.wrap(function()
            local Loaded = require(v)
            local Encoded = game:GetService'HttpService':JSONEncode(Loaded)
            local Difficulty = v.SongDiff.Value;
            local Name = Loaded.AudioFilename;
            
            for i,v in next, NOT_ALLOWED do
                Name = Name:gsub(v, "")
            end
            
            Name = Name .. DifficultySeparator .. Difficulty
            
            writefile(Folder..'/'..Name..'.txt', Encoded)
        end))
    end
end