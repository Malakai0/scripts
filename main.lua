local base_url = "https://raw.githubusercontent.com/Whomever0/exploit-scripts/master/scripts/%s.lua"

local function convert(c)
    return string.format("%%%02X", string.byte(c))
end
  
local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w _%%%-%.~])", convert)
    url = url:gsub(" ", "+")
    return url
end

return function(dad)
    local url = urlencode(string.format(base_url, dad));
    return loadstring(game:HttpGet(url))();
end