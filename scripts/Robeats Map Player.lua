local DefaultSettings = {
    SongName = 'Altale'; -- Has to be perfect to the one in the directory.
    Difficulty = 31; -- Song difficulty.
    IsCommunityServer = true; -- If it's from the community server.
    IsRemix = false; -- If it's from REMIX Robeats.

    ResetToDefaultSong = false;
}

return function(Settings)
    Settings = Settings or DefaultSettings;
    local DifficultySeparator = ".DIFF_SEPARATE."
    local RemixSeparator = '.REMIX.'

    local Folder = Settings.IsCommunityServer and 'RobeatsCS_Songs' or 'Robeats_Songs';
    local Extra = Settings.IsRemix and RemixSeparator or ''
    local Name = Settings.SongName .. DifficultySeparator .. Extra .. Settings.Difficulty

    local File = Folder.."/"..Name..'.txt'
    local Table = game:GetService'HttpService':JSONDecode(readfile(File) or '[]')

    if not (getgenv().SongDB) then
        for i,v in next, getgc(true) do
            local T = type(v);
            local RG = rawget
            if T == 'table' and RG(v, 'key_has_combineinfo') then
                getgenv().SongDB = v;
            end
        end
    end

    local all = getupvalue(getgenv().SongDB.add_key_to_data, 1);
    local key = getgenv().SongDB:get_tutorial_songkey()

    if not getgenv().ORIGINAL_TUTORIAL then
        getgenv().ORIGINAL_TUTORIAL = {};
        for Key, Value in next, all._table[key] do
            getgenv().ORIGINAL_TUTORIAL[Key] = Value;
        end
    end

    if (Settings.ResetToDefaultSong) then
        for i,v in next, getgenv().ORIGINAL_TUTORIAL do
            Table[i] = v;
        end
    else
        Table.__key = getgenv().SongDB:get_tutorial_songkey()
        for i,v in next, all._table[getgenv().SongDB:get_tutorial_songkey()] do
            if not Table[i] then
                Table[i] = v
            end
        end
        
        Table.AudioCoverImageAssetId = "rbxassetid://6370803424" 
    end

    all._table[key] = Table

    setupvalue(getgenv().SongDB.add_key_to_data, 1, all)
end