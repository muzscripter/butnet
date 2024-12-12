local ButnetLibrary = newproxy(true);
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Queue = {};
local Connections = {};
local Networks = {};
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

local function ButnetSignalConnection(Name, Func)
    task.defer(function()
        if not GetInstanceAttributes(ButNetScopes)[Name] or not Connections[Name] then
            ButNetScopes:SetAttribute(Name, nil)
            Connections[Name] = ButNetScopes:GetAttributeChangedSignal(Name):Connect(function()
                local AttributeValue = ButNetScopes:GetAttribute("Name")
                --TODO:  Fire Func to all network scopes returning attribute value and original attribute
            end)
        else
    
        end
    end)
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

--// Example

local ButnetLibrary = require(ReplicatedStorage.ButnetLibrary)

local TimerScope = ButnetLibrary:CreateNetworkScope("Time", {
    Func = function()
    end
})
