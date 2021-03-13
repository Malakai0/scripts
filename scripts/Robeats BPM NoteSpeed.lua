local NOTE_SPEED = 20;

getgenv().NOTE_SPEED = NOTE_SPEED

if (getgenv().ran_notespeed_hooker) then
    repeat wait(600) until nil
end

getgenv().ran_notespeed_hooker = true

if not (getgenv().AudioManager) then
    for i,v in next, getgc(true) do
        if (getgenv().AudioManager and getgenv().CurveUtil) then break end
        local T = type(v);
        local RG = rawget
        if (T == 'table' and type(RG(v, 'Mode')) == 'table' and RG(v.Mode, 'PostPlaying')) then
            getgenv().AudioManager = v;
        elseif (T == 'table' and RG(v, 'YForPointOf2PtLine')) then
            getgenv().CurveUtil = v;
        end
    end
end

local AudioManager = getgenv().AudioManager;
local CurveUtil = getgenv().CurveUtil;
local SetUV = setupvalue;

local OldFunc = AudioManager.new;
AudioManager.new = function(...)
    local _self = OldFunc(...)
    local load_song = _self.load_song

    _self.load_song = function(...)
        local load_song_ret = load_song(...)
        local NewPrebuffer = 1000 * CurveUtil:YForPointOf2PtLine(Vector2.new(0, 1), Vector2.new(40, 0.2), getgenv().NOTE_SPEED);
        SetUV(_self.get_note_prebuffer_base_time_ms, 1, NewPrebuffer)
        return load_song_ret
    end
    
    return _self
end