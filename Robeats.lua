local autoplayer = true;
local multiplier = 10000000;

local perfect,great,okay,miss = '_AJxlbJ3waLRsSmjuubwJ','_l8k3myHt9CHqwzwtxRse','_iEfBGevsTgbPot1itdWF','_lWwCI406LrYzxZaqJVOa'
local _game;
local game_script;
    
for i,v in next, getloadedmodules() do
    if (v.Parent == nil) then
        local req = require(v)

        if (type(req) == 'table' and rawget(req, 'type_to_name')) then
            writefile('hax_script.lua', decompile(v));
        end

        if (type(req) == 'table' and type(rawget(req, 'new')) == 'function') then
            local finding = {'is_tutorial', 'get_spectate_manager', 'set_as_tutorial', 'set_local_game_slot'};
            local found = 0;
            for x,c in next, debug.getconstants(req.new) do
                if (table.find(finding, c)) then -- score manager uwuuu
                    found = found + 1
                end
            end
            if (found >= #finding) then
                _game = req;
                game_script = v;
            end
        end
    end
end

if (not _game) then print('bru') repeat wait(1000000) until nil end;

local function determine(key, constants, should_debug)

    local found = 0;
    local finding = {};

    if (key == 'get_fever_fill_base') then
        finding = {'Type','FeverFillRate'}
    elseif (key == 'get_powerbar_noteresult_drain') then
        finding = { 0.25, 'get_fever_miss_drain_pct' };
    elseif (key == 'get_powerbar_multiplier') then
        finding = { 'Type', 'FeverMultiplier' };
    elseif (key == 'get_powerbar_base_decay_time_seconds') then
        finding = { 1000, 'get_base_decay_rate' }
    end

    if (finding == nil) then print(key) return false end;

    for i,v in next, constants do
        if should_debug then
            print(i,v, table.find(finding, v))
        end

        if (table.find(finding, v)) then
            found = found + 1;
        end
    end

    return found >= #finding;

end

for i,v in next, debug.getupvalues(_game.new) do
    if (type(v) == 'table') then
        for i2, v2 in next, v do
            
            local consts = type(v2) == 'function' and debug.getconstants(v2) or {};

            --print(i2,v2)

            local function set_function(func)
                rawset(v, i2, func)
            end
            
            local function set(key, ...)
                local xd = ...
                if (determine(key, consts)) then
                    print('done ' .. key)
                    if (type(rawget(v, i2)) == 'function') then
                        set_function(function(...)
                            return xd;
                        end)
                    else
                        rawset(v, i2, ({xd})[1])
                    end
                end
            end
            
            local function set_constant(key, value)
                debug.setconstant(v2, key, value)
            end
            
            local fill_target = 1*10^-76
            set('get_fever_fill_base', fill_target, fill_target, fill_target)
            set('get_powerbar_multiplier', multiplier)
            set('get_powerbar_noteresult_drain', 0);
            set('get_powerbar_base_decay_time_seconds', math.huge)

            local suc = determine('get_powerbar_noteresult_drain', consts)
            if (suc and autoplayer) then
                local note_result = debug.getupvalue(v2, 1);
                local myes = note_result[perfect]
                note_result[great] = myes
                note_result[okay] = myes
                note_result[miss] = myes
                set_constant(1, note_result)
            end
            
        end
        --print()
    end
end