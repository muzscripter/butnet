local ButnetLibrary = newproxy(true);
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Queue = {};

local ButNetScopes = (ReplicatedStorage['ButnetLibrary'] or Instance.new("Configuration", ReplicatedStorage));

local function GetInstanceAttributes(Obj: Instance)
    
end

function ButnetLibrary:CreateNetworkScope()
    local NetworkScope = {};
    NetworkScope.__index = NetworkScope

    function NetworkScope.new()
        local self = setmetatable({}, NetworkScope)
        self.Connection = 
    end

    return NetworkScope.new()
end

return ButnetLibrary
