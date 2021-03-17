-- cause im lazy

local hooker = {}
getgenv().hook_connections = getgenv().hook_connections or {
    Namecall = {};
    Index = {};
};

function hooker.AddNamecall(key, func)
    getgenv().hook_connections.Namecall[key] = func;
    return {
        Disconnect = function()
            getgenv().hook_connections.Namecall[key] = nil;
        end
    }
end

function hooker.AddFunction(key, hooking, func)
    local h;
    local enabled = true;
    h = hookfunction(hooking, function(...)
        if (enabled == false) then
            return h(...);
        end
        return func(h, ...);
    end);
    return {
        Disconnect = function()
            enabled = false;
        end;
    };
end

function hooker.AddIndex(key, func)
    getgenv().hook_connections.Index[key] = func;
    return {
        Disconnect = function()
            getgenv().hook_connections.Index[key] = nil;
        end
    }
end

if (not getgenv().hookApplied) then
    getgenv().hookApplied = true;

    local Player = game:GetService'Players'.LocalPlayer;

    local mt = getrawmetatable(game);
    local namecall = mt.__namecall
    local index = mt.__index;

    setreadonly(mt, false);

    mt.__index = function(self, key)
        
        local connections = rawget(rawget(getgenv(), 'hook_connections'), 'Index');

        for key2,connection in next, connections do
            if (type(connection) == 'function') then
                local info = {
                    Player = Player;
                    CallingScript = getcallingscript();
                    Environment = getfenv(2);
                    Self = self;
                    Key = key;
                    Index = key2;
                }
                local ret = connection(info);
                if (ret ~= nil) then
                    return ret;
                end
            end;
        end

        return index(self, key);

    end

    mt.__namecall = function(self, ...)

        for key,connection in next, getgenv().hook_connections.Namecall do
            if (type(connection) == 'function') then
                local info = {
                    Player = Player;
                    Method = getnamecallmethod();
                    CallingScript = getcallingscript();
                    Environment = getfenv(2);
                    Caller = self;
                    Args = {...};
                    Index = key;
                }
                local ret = connection(info);
                if (ret ~= nil) then
                    return ret;
                end
            end;
        end

        return namecall(self, ...)
    end
end

return hooker;