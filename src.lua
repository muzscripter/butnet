local ButnetLibrary = newproxy(true);
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Queue = {};
local Connections = {};
local ButNetScopes = (ReplicatedStorage['ButnetLibrary'] or Instance.new("Configuration", ReplicatedStorage));

local function GetInstanceAttributes(Obj: Instance)
    local AttributeList = Obj:GetAttributes()
    if #AttributeList > 0 then
        return AttributeList, true
    else
        warn("[ButnetLibrary]: Failed to fetch attributes for Instance" .. Obj.Name)
        return nil, false 
    end
end

local function ButnetSignalConnection(Name)
    if not GetInstanceAttributes(ButNetScopes)[Name] or not Connections[Name] then

    else

    end
end

function ButnetLibrary:CreateNetworkScope(NetworkName: string, Data)
    local NetworkScope = {};
    NetworkScope.__index = NetworkScope

    function NetworkScope.new()
        local self = setmetatable({}, NetworkScope)
        self.Connection = ButnetSignalConnection(NetworkName);
    end

    return NetworkScope.new()
end

return ButnetLibrary
