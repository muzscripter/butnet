--// author @graverealm

local ButnetLibrary = {};
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Internal Storage
local Queue = {};
local Connections = {};
local Networks = {};
local AttributeQueues = {};

local ButNetScopes = ReplicatedStorage:FindFirstChild("ButnetLibrary") or Instance.new("Configuration", ReplicatedStorage);
ButNetScopes.Name = "ButnetLibrary"

--// Helper Functions
local function ProcessQueue(Name)
	if AttributeQueues[Name] then
		local Value = ButNetScopes:GetAttribute(Name)
		for _, Callback in ipairs(AttributeQueues[Name]) do
			task.spawn(Callback, Value, Name)
		end
		AttributeQueues[Name] = nil
	end
end

local function GetInstanceAttributes(Obj)
	local AttributeList = Obj:GetAttributes()
	if #AttributeList > 0 then
		return AttributeList, true
	else
		warn("[ButnetLibrary]: Failed to fetch attributes for Instance " .. Obj.Name)
		return nil, false
	end
end

local function CreateSignalConnection(Name, Callback)
	task.defer(function()
		if not Connections[Name] then
			Connections[Name] = ButNetScopes:GetAttributeChangedSignal(Name):Connect(function()
				local AttributeValue = ButNetScopes:GetAttribute(Name)
				if Callback then
					Callback(AttributeValue, Name)
				end
			end)
		end
	end)
end


function ButnetLibrary:CreateNetworkScope(NetworkName: string, Data)
	assert(NetworkName, "[ButnetLibrary]: NetworkName is required")

	local NetworkScope = {}
	NetworkScope.__index = NetworkScope

	function NetworkScope.new()
		local self = setmetatable({}, NetworkScope)
		self.Name = NetworkName
		self.Data = Data or {}
		
		if ButNetScopes:GetAttribute(NetworkName) == nil then
			ButNetScopes:SetAttribute(NetworkName, nil)
		end

		self.Connection = CreateSignalConnection(NetworkName, self.Data.Func)
		return self
	end

	return NetworkScope.new()
end

function ButnetLibrary:SetAttribute(Name: string, Value)
	assert(Name, "[ButnetLibrary]: Attribute name is required")
	if not ButNetScopes:GetAttribute(Name) then
		warn("[ButnetLibrary]: Attribute '" .. Name .. "' not found, creating new attribute.")
	end
	ButNetScopes:SetAttribute(Name, Value)
	ProcessQueue(Name)
end

function ButnetLibrary:FireOnce(Name: string, Data)
	assert(Name, "[ButnetLibrary]: Attribute name is required")
	assert(Data, "[ButnetLibrary]: Data is required")

	local EncodedData = game:GetService('HttpService'):JSONEncode(Data)
	local DataAttributeName = Name .. "_Data"


	if ButNetScopes:GetAttribute(Name) == nil then
		ButNetScopes:SetAttribute(Name, 0)
	end

	ButNetScopes:SetAttribute(DataAttributeName, EncodedData)

	ButNetScopes:SetAttribute(Name, 1)
	task.defer()
	
	ButNetScopes:SetAttribute(Name, 0)
	ButNetScopes:SetAttribute(DataAttributeName, nil)
end

function ButnetLibrary:GetAttribute(Name: string)
	assert(Name, "[ButnetLibrary]: Attribute name is required")
	return ButNetScopes:GetAttribute(Name)
end

function ButnetLibrary:RemoveAttribute(Name: string)
	assert(Name, "[ButnetLibrary]: Attribute name is required")
	ButNetScopes:SetAttribute(Name, nil)
	if Connections[Name] then
		Connections[Name]:Disconnect()
		Connections[Name] = nil
	end
end

function ButnetLibrary:QueueAttribute(Name: string, Callback)
	assert(Name and Callback, "[ButnetLibrary]: Attribute name and callback are required")
	if not AttributeQueues[Name] then
		AttributeQueues[Name] = {}
	end
	table.insert(AttributeQueues[Name], Callback)

	local Value = ButNetScopes:GetAttribute(Name)
	if Value ~= nil then
		ProcessQueue(Name)
	end
end

function ButnetLibrary:WaitForAttribute(Name: string, Timeout)
	assert(Name, "[ButnetLibrary]: Attribute name is required")
	local StartTime = os.clock()
	while not ButNetScopes:GetAttribute(Name) do
		if Timeout and (os.clock() - StartTime) > Timeout then
			return nil, "Timeout exceeded while waiting for attribute: " .. Name
		end
		task.wait()
	end
	return ButNetScopes:GetAttribute(Name)
end

local Dependencies = {}

function ButnetLibrary:AddDependency(Target: string, Dependency: string)
	assert(Target and Dependency, "[ButnetLibrary]: Both target and dependency names are required")
	if not Dependencies[Target] then
		Dependencies[Target] = {}
	end
	table.insert(Dependencies[Target], Dependency)
end

function ButnetLibrary:ResolveDependencies(Target: string)
	assert(Target, "[ButnetLibrary]: Target name is required")
	if Dependencies[Target] then
		for _, Dep in ipairs(Dependencies[Target]) do
			self:WaitForAttribute(Dep)
		end
		Dependencies[Target] = nil
	end
end

if RunService:IsClient() then
	function ButnetLibrary:ConnectToAttribute(Name: string, Callback)
		assert(Name, "[ButnetLibrary]: Attribute name is required")
		local DataAttributeName = Name .. "_Data"

		CreateSignalConnection(Name, function(AttributeValue, AttributeName)
			if AttributeValue == 1 then
				local EncodedData = ButNetScopes:GetAttribute(DataAttributeName)
				local DecodedData = EncodedData and game:GetService('HttpService'):JSONDecode(EncodedData) or nil
				Callback(DecodedData, AttributeName)
			end
		end)
	end
end

return ButnetLibrary
