-- cause im lazy

local hooker = {}
local connections = {}

function hooker.AddConnection(key, func)
    connections[key] = func;
    return {
        Disconnect = function()
            connections[key] = nil;
        end
    }
end

local mt = getrawmetatable(game);
local namecall = mt.__namecall

setreadonly(mt, false);

mt.__namecall = function(self, ...)

    for key,connection in next, connections do
        if (type(connection) == 'function') then
            local info = {
                Player = game:GetService'Players'.LocalPlayer;
                Method = getnamecallmethod();
                CallingScript = getcallingscript();
                Environment = getfenv(2);
                Caller = self;
                Args = {...};
                Key = key;
            }
            local ret = connection(info);
            if (ret ~= nil) then
                return ret;
            end
        end;
    end

    return namecall(self, ...)
end

return hooker;