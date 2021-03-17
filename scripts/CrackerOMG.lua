local fakeIP = "127.0.0.1";

if (not isfile(fakeIP)) then
    writefile(fakeIP, '')
end

local http = game.HttpGet;

local load = getgenv().LoadScript or loadstring(game:HttpGet("https://raw.githubusercontent.com/Whomever0/exploit-scripts/master/main.lua"))()
local hooker = load("NamecallHooker")

hooker.AddNamecall("WhitelistCrackerOMG", function(self)
    if (self.Method:lower() == 'httpget') then
        local Website = tostring(self.Args[1]);
        if (Website:lower():find('ipify')) then
            return fakeIP;
        end
        return http(game, unpack(self.Args));
    elseif (self.Caller == self.Player) then
        if (self.Method:lower() == 'destroy') then
            return true;
        elseif (self.Method:lower() == 'kick') then
            return true;
        end
    end
end)

hooker.AddIndex('AntiDestroy', function(self)
    if (self.Self == self.Player) then
        if (self.Key:lower() == 'destroy') then
            return function()end;
        elseif (self.Key:lower() == 'kick') then
            return function()end;
        end
    end
end)

coroutine.wrap(function()
    
    local f = getfenv(1)
    
    hooker.AddFunction('base64Encode', f.syn.crypt.base64.encode, function(old)
        return old(fakeIP)
    end)
    
    setfenv(1, f)
    
    local Players = game:service'Players';local Player = game:GetService("Players").LocalPlayer
    local ip1 = 'https://a'; local ip2 = 'pi.ipify.org/' -- encryption
    local realIpLinkAfterDecoding = ip1..ip2; -- Website owned by cron
    
    ipAddressAsync = game:HttpGet(realIpLinkAfterDecoding);
    
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
    -- encoding
    function enc(data) -- This is base64, uncrackable security to make sure data do not get leaked
        return ((data:gsub('.', function(x)
            local r,b='',x:byte()
            for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
            return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#data%3+1])
    end
    
    -- []d
    
    --Security Check 1 (anti EQ and hookfunction) -- Thx cron
    
    if enc(ipAddressAsync) == syn.crypt.base64.encode(ipAddressAsync) then
    
       --Security Check 2 (Is Whitelisted), credit to fiusen for the method
    
        local function whitelistCheck(arg1, ...)
           return isfile(ipAddressAsync)
        end
    
        if whitelistCheck() then
            print('success')
        else
            Player:Destroy() -- In case they forget to Namecall Hook (rookie mistake)
            Player.Destroy(Player) -- Anti Namecall Hook (Impossible to bypass)
        end
    else
        Player.Destroy(Player) -- Anti Namecall Hook (Impossible to bypass)
    end
    
end)()