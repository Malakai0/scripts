local Player = game:GetService('Players').LocalPlayer

local Settings = {
    ABDCopy = false;
    LogEnvironment = false;
    WriteStandFile = false;

    WalkInTS = true;
    DamageMultiplier = 5;
    RemoveJumpCooldown = true;
    RemoveHitCooldown = true;
    SetPlayersVisible = true;
    Hook = function(old, p1)
        p1 = p1 or 0
        if (p1 == .75 and getfenv(2).script:IsDescendantOf(Player.Character)) then
            return true
        end
        return old(p1)
    end
};

local Defaults = {
    ABDCopy = false;
    LogEnvironment = false;
    WriteStandFile = false;

    WalkInTS = true;
    DamageMultiplier = 1;
    RemoveHitCooldown = false;
    RemoveJumpCooldown = false;
    SetPlayersVisible = false;
    Hook = function(a,b)
        return a(b)
    end;
}

local BizarreLibrary = loadstring(game:HttpGet('https://pastebin.com/raw/kqvHxq9s', true))()

local LogEnum = {
    PROTOS = 'protos';
    CONSTANTS = 'constants';
    UPVALUES = 'upvalues';
    STACK = 'stack';
    NULL = false;
}

local function MakeDebug(K,T)
    return {Key=K;Target=T};
end;

local function MakeMove(F,L,U,C,P,S)
    return {
        Function = F or 'N/A??';
        ShouldLog = L ~= nil and L or LogEnum.NULL;
        Debug = {
            Upvalues = U or {};
            Constants = C or {};
            Protos = P or {};
            Stack = S or {};
        }
    }
end

BizarreLibrary.LoadStandVariants({

    ChariotRequiem = {
        Moves = {


            Heal = MakeMove('regenerate', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(12, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            StrongerPunch = MakeMove('reconstruct', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(4, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            StrongPunch = MakeMove('strongpunch', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(4, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            Charge = MakeMove('chargein', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {});

            Slash = MakeMove('slash', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
            }, {
                WaitFunc = MakeDebug(11, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            Barrage = MakeMove('barrage', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
                Hits = MakeDebug(6, 0);
            }, {
                WaitFunc = MakeDebug(23, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });


        };
        Misc = {
            Global_Variables = {
                dodgecooldown = false;
            };
            Global_Functions = {};
            Global_Tables = {};
        };
    };

    Vampire = {

        Moves = {

            Barrage = MakeMove('barrage', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
                BarrageHits = MakeDebug(8, 0);
            }, {
                WaitFunc = MakeDebug(38, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end);
                Color = MakeDebug(33, function()
                    return Color3.fromRGB(0,0,0)
                end);
                Sound = MakeDebug(34, 'rbxassetid://5134271503');
                Size = MakeDebug(16, 2);
            });

            StrongPunch = MakeMove('strongpunch', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(7, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            BloodSuck = MakeMove('bloodsuck', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(8, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            Freeze = MakeMove('freeze', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(9, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

            Laser = MakeMove('spaceripperstingyeyes', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                CD = MakeDebug(2, false);
            }, {
                WaitFunc = MakeDebug(4, function()
                    return game:GetService('RunService').RenderStepped:Wait()
                end)
            });

        };

        Misc = {
            Global_Variables = {
                dashcooldown = false;
                dodgecooldown = false;
            };
            Global_Functions = {};
            Global_Tables = {};
        };

    };

    SilverChariot = {
        Moves = {};
        Misc = {
            Global_Variables = {};
            Global_Functions = {};
            Global_Tables = {};
        };
    };

    Standless = {
        Moves = {

            Punch = MakeMove("punch", LogEnum.NULL, {
                Activu = MakeDebug(1, false);
            }, {}, {}, {});

            StrongPunch = MakeMove('strongpunch', LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                Cooldown = MakeDebug(2, false);
            }, {}, {}, {});

            Push = MakeMove("push", LogEnum.NULL, {
                Activu = MakeDebug(1, false);
                Cooldown = MakeDebug(2, false);
            }, {}, {}, {});

        };
        Misc = {
            Global_Variables = {
                dodgecooldown = false;
            };
            Global_Functions = {};
            Global_Tables = {};
        };
    };

}, {})

local function ObtainSetting(Key)
    return Settings[Key] == nil and Defaults[Key] or Settings[Key];
end

BizarreLibrary.WalkInTS(ObtainSetting("WalkInTS"));
BizarreLibrary.SetDamageMultiplier(ObtainSetting("DamageMultiplier"));
BizarreLibrary.RemoveJumpCooldown(ObtainSetting("RemoveJumpCooldown"));
BizarreLibrary.RemoveHitCooldown(ObtainSetting("RemoveHitCooldown"));
BizarreLibrary.SetPlayersVisible(ObtainSetting("SetPlayersVisible"));
BizarreLibrary.HookWaitFunction(ObtainSetting("Hook"));

local BizarreObject = BizarreLibrary.new(Settings.ABDCopy);

if (ObtainSetting("LogEnvironment")) then BizarreObject:LogEnvironment() end

if (ObtainSetting("WriteStandFile")) then
    local Script = BizarreObject.StandScript;
    writefile('stand_'..Script.Name..'.lua', decompile(Script));
end

BizarreObject:Start()