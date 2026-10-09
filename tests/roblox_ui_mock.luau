-- Mały adapter do wykonywania prawdziwych fabryk GUI bez silnika.
-- Nie odwzorowuje renderera Roblox ani zachowania fizyki.
local function signal()
    return {
        listeners = {},
        Connect = function(self, callback) table.insert(self.listeners, callback); return { Disconnect = function() end } end,
        Fire = function(self, ...) for _, callback in ipairs(self.listeners) do callback(...) end end,
    }
end
local Enum = setmetatable({}, { __index = function(self, key)
    local group = setmetatable({}, { __index = function(t, value) rawset(t, value, value); return value end })
    rawset(self, key, group)
    return group
end })
local Color3 = { fromRGB = function(r, g, b) return { kind = "color", r = r, g = g, b = b } end }
local UDim = { new = function(scale, offset) return { Scale = scale, Offset = offset } end }
local UDim2 = {
    new = function(x, xo, y, yo) return { kind = "size", X = UDim.new(x, xo), Y = UDim.new(y, yo) } end,
    fromOffset = function(x, y) return { kind = "size", X = UDim.new(0, x), Y = UDim.new(0, y) } end,
    fromScale = function(x, y) return { kind = "size", X = UDim.new(x, 0), Y = UDim.new(y, 0) } end,
}
local Vector2 = { new = function(x, y) return { X = x, Y = y } end }
local NumberSequenceKeypoint = { new = function(time, value) return { Time = time, Value = value } end }
local NumberSequence = { new = function(value, finish)
    return type(value) == "table" and value or { { Time = 0, Value = value }, { Time = 1, Value = finish or value } }
end }
local TweenInfo = { new = function() return {} end }
local promptService = {
    PromptShown = signal(), PromptHidden = signal(),
    PromptButtonHoldBegan = signal(), PromptButtonHoldEnded = signal(),
}
local deferred = {}
local task = { delay = function(_, callback) table.insert(deferred, callback) end, spawn = function(callback) callback() end }
local function drain()
    local batch = deferred
    deferred = {}
    for _, callback in ipairs(batch) do callback() end
end
local assetMock = { attempts = 0, objects = {}, failAfter = nil }
local imageFactory
local Content = { fromObject = function(object) return { kind = "content", object = object } end }
local warn = function() end
local game = { GetService = function(_, name)
    if name == "ProximityPromptService" then return promptService end
    if name == "AssetService" then return { CreateEditableImage = function(_, options)
        assetMock.attempts += 1
        if assetMock.failAfter and assetMock.attempts > assetMock.failAfter then return nil end
        local object = imageFactory(options.Size)
        table.insert(assetMock.objects, object)
        return object
    end } end
    if name == "EncodingService" then return {
        Base64Decode = function(_, data) return data end,
        GetDecompressedBufferSize = function() return 4 end,
        DecompressBuffer = function() return buffer.fromstring("RGBA") end,
    } end
    if name == "RunService" then return { Heartbeat = { Wait = function() end } } end
    if name == "ContentProvider" then return { PreloadAsync = function(_, _, callback)
        callback("test-image", assetMock.publishedStatus or Enum.AssetFetchStatus.Success)
    end } end
    return { Create = function(_, object, _, props)
        return { Play = function() for key, value in pairs(props) do object[key] = value end end }
    end }
end }
local Instance = {}
local Node = {}
function Node:GetChildren() return table.clone(self.children) end
function Node:GetAttribute(name) return self.attributes[name] end
function Node:SetAttribute(name, value) self.attributes[name] = value end
function Node:IsA(class) return self.ClassName == class end
function Node:InputHoldBegin() self:SetAttribute("began", (self:GetAttribute("began") or 0) + 1) end
function Node:InputHoldEnd() self:SetAttribute("ended", (self:GetAttribute("ended") or 0) + 1) end
function Node:FindFirstChildOfClass(class)
    for _, child in ipairs(self.children) do if child.ClassName == class then return child end end
end
function Node:FindFirstChild(name, recursive)
    for _, child in ipairs(self.children) do
        if child.Name == name then return child end
        if recursive then local found = child:FindFirstChild(name, true); if found then return found end end
    end
end
function Node:Destroy()
    self:SetAttribute("Destroyed", true)
    if self.Parent then
        local index = table.find(self.Parent.children, self)
        if index then table.remove(self.Parent.children, index) end
    end
    self.properties.Parent = nil
end
function Node:WritePixelsBuffer(_, size, pixels)
    assert(buffer.len(pixels) == size.X * size.Y * 4)
    self:SetAttribute("Written", true)
end
function Instance.new(class)
    local node = { properties = { ClassName = class, Name = class, ZIndex = 1, Visible = true }, children = {}, attributes = {}, signals = {} }
    return setmetatable(node, {
        __index = function(self, key)
            if Node[key] then return Node[key] end
            if key == "Activated" or key == "MouseEnter" or key == "MouseLeave" or key == "SelectionGained" or key == "SelectionLost" then
                if not self.signals[key] then self.signals[key] = signal() end
                return self.signals[key]
            end
            return self.properties[key]
        end,
        __newindex = function(self, key, value)
            self.properties[key] = value
            if key == "Parent" and value then table.insert(value.children, self) end
        end,
    })
end
imageFactory = function(size)
    local object = Instance.new("EditableImage")
    object.Size = size
    return object
end

local function escape(value)
    return '"' .. value:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
end
local function json(value)
    if type(value) == "string" then return escape(value) end
    if type(value) == "number" or type(value) == "boolean" then return tostring(value) end
    if type(value) ~= "table" then return "null" end
    local pieces = {}
    if #value > 0 then
        for _, item in ipairs(value) do table.insert(pieces, json(item)) end
        return "[" .. table.concat(pieces, ",") .. "]"
    end
    for key, item in pairs(value) do table.insert(pieces, escape(tostring(key)) .. ":" .. json(item)) end
    return "{" .. table.concat(pieces, ",") .. "}"
end
local function tree(node)
    local props, children = {}, {}
    for key, value in pairs(node.properties) do if key ~= "Parent" then props[key] = value end end
    for _, child in ipairs(node.children) do table.insert(children, tree(child)) end
    return { props = props, children = children }
end
