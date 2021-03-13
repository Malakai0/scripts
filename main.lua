local base_url = "https://raw.githubusercontent.com/Whomever0/exploit-scripts/master/scripts/%s.lua"
return function(n)
    return loadstring(game:HttpGet(string.format(base_url, n)))()
end