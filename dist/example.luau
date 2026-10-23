--[[
    @author quit (quit.xyz)
    @description a standalone modular roblox esp library
    @version "0.1.0"
    @build "example"
    @date "2026-10-23"
]]

local __DARKLUA_BUNDLE_MODULES={cache={}::any}do do local function __modImpl()local cloneRef = cloneref or function(reference)
    return reference
end

return {
    Players = cloneRef(game:GetService("Players")),
    RunService = cloneRef(game:GetService("RunService")),
    Workspace = cloneRef(game:GetService("Workspace")),
}
end function __DARKLUA_BUNDLE_MODULES.a():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.a if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.a=v end return v.c end end do local function __modImpl()
local defaults = {
    enabled = true,
    maxDistance = 2000,
    deadPolicy = "hide",
    selection = "all",
    renderPriority = Enum.RenderPriority.Camera.Value + 1,
    box = {
        enabled = true,
        style = "corner",
        color = Color3.fromRGB(198, 198, 200),
        opacity = 1,
        thickness = 1,
        padding = 3,
        cornerLength = 0.25,
        outline = {
            enabled = true,
            color = Color3.fromRGB(5, 5, 5),
            opacity = 1,
            thickness = 1,
        },
        fill = {
            enabled = false,
            color = Color3.fromRGB(198, 198, 200),
            opacity = 0.15,
        },
    },
}

local groupSchema = {
    enabled = defaults.enabled,
    maxDistance = defaults.maxDistance,
    deadPolicy = defaults.deadPolicy,
    box = defaults.box,
}

local choices = {
    selection = { all = true, enemies = true, teammates = true },
    deadPolicy = { hide = true, show = true, only = true },
    style = { full = true, corner = true },
}

local function merge(current, changes, schema, path)
    assert(type(changes) == "table", "ESP settings must be a table")
    local result = table.clone(current)

    for key, value in changes do
        local name = path == "" and tostring(key) or path .. "." .. tostring(key)
        local expected = schema[key]

        if path == "" and schema == defaults and key == "groups" then
            assert(type(value) == "table", "ESP groups must be a table")
            local groups = table.clone(current.groups or {})
            for group, overrides in value do
                assert(group == "enemy" or group == "friendly", "Unknown ESP group: " .. tostring(group))
                groups[group] = merge(groups[group] or {}, overrides, groupSchema, "groups." .. group)
            end
            result.groups = groups
            continue
        end

        assert(expected ~= nil, "Unknown ESP setting: " .. name)
        assert(typeof(value) == typeof(expected), "Invalid type for ESP setting: " .. name)

        if typeof(expected) == "table" then
            result[key] = merge(current[key] or {}, value, expected, name)
            continue
        end

        if choices[key] then
            assert(choices[key][value], "Invalid value for ESP setting: " .. name)
        elseif type(value) == "number" then
            assert(value == value and value > -math.huge, "Invalid number for ESP setting: " .. name)
            assert(value < math.huge or key == "maxDistance", "Invalid number for ESP setting: " .. name)

            if key == "opacity" then
                assert(value >= 0 and value <= 1, name .. " must be between 0 and 1")
            elseif key == "cornerLength" then
                assert(value > 0 and value <= 0.5, name .. " must be greater than 0 and at most 0.5")
            elseif key == "thickness" then
                assert(value > 0, name .. " must be greater than 0")
            elseif key == "renderPriority" then
                assert(value % 1 == 0, name .. " must be an integer")
            else
                assert(value >= 0, name .. " must be non-negative")
            end
        end
        result[key] = value
    end

    return result
end

local function resolve(settings, overrides)
    local result = table.clone(settings)

    for key, value in overrides do
        result[key] = typeof(value) == "table" and resolve(settings[key], value) or value
    end

    return result
end

local config = {}

function config.new(settings)
    if settings == nil then
        settings = {}
    end

    return merge(defaults, settings, defaults, "")
end

function config.update(settings, changes)
    return merge(settings, changes, defaults, "")
end

function config.resolve(settings)
    local groups = settings.groups or {}
    return {
        enemy = resolve(settings, groups.enemy or {}),
        friendly = resolve(settings, groups.friendly or {}),
    }
end

return config
end function __DARKLUA_BUNDLE_MODULES.b():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.b if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.b=v end return v.c end end do local function __modImpl()
local bodyNames = {
    Head = true,
    Torso = true,
    UpperTorso = true,
    LowerTorso = true,
    ["Left Arm"] = true,
    ["Right Arm"] = true,
    ["Left Leg"] = true,
    ["Right Leg"] = true,
    LeftUpperArm = true,
    LeftLowerArm = true,
    LeftHand = true,
    RightUpperArm = true,
    RightLowerArm = true,
    RightHand = true,
    LeftUpperLeg = true,
    LeftLowerLeg = true,
    LeftFoot = true,
    RightUpperLeg = true,
    RightLowerLeg = true,
    RightFoot = true,
}

local function disconnect(connections)
    for _, connection in connections do
        connection:Disconnect()
    end
    table.clear(connections)
end

local function refresh(entity)
    local Character = entity.Character
    table.clear(entity.parts)
    entity.Humanoid = nil
    entity.Root = nil

    if not Character then
        return
    end

    entity.Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root and Root:IsA("BasePart") then
        entity.Root = Root
    end

    for _, child in Character:GetChildren() do
        if bodyNames[child.Name] and child:IsA("BasePart") then
            entity.parts[#entity.parts + 1] = child
        end
    end
end

local function setCharacter(entity, Character)
    disconnect(entity.characterConnections)
    for _, component in entity.components do
        component:Hide()
    end

    entity.Character = Character
    refresh(entity)

    if Character then
        local function changed()
            if entity.Character == Character then
                refresh(entity)
            end
        end
        entity.characterConnections[1] = Character.ChildAdded:Connect(changed)
        entity.characterConnections[2] = Character.ChildRemoved:Connect(changed)
    end
end

local entities = {}
entities.__index = entities

function entities.new(Players, LocalPlayer)
    return setmetatable({
        Players = Players,
        LocalPlayer = LocalPlayer,
        items = {},
        connections = {},
        started = false,
        destroyed = false,
    }, entities)
end

function entities:Add(Player)
    if self.destroyed or Player == self.LocalPlayer or self.items[Player] then
        return
    end

    local entity = {
        Player = Player,
        parts = {},
        components = {},
        bounds = {},
        connections = {},
        characterConnections = {},
    }
    self.items[Player] = entity
    entity.connections[1] = Player.CharacterAdded:Connect(function(Character)
        setCharacter(entity, Character)
    end)
    entity.connections[2] = Player.CharacterRemoving:Connect(function(Character)
        if entity.Character == Character then
            setCharacter(entity, nil)
        end
    end)
    setCharacter(entity, Player.Character)
end

function entities:Remove(Player)
    local entity = self.items[Player]
    if not entity then
        return
    end

    self.items[Player] = nil
    disconnect(entity.connections)
    setCharacter(entity, nil)
    for _, component in entity.components do
        component:Destroy()
    end
    table.clear(entity.components)
end

function entities:Start()
    if self.started or self.destroyed then
        return
    end

    self.started = true
    self.connections[1] = self.Players.PlayerAdded:Connect(function(Player)
        self:Add(Player)
    end)
    self.connections[2] = self.Players.PlayerRemoving:Connect(function(Player)
        self:Remove(Player)
    end)
    for _, Player in self.Players:GetPlayers() do
        self:Add(Player)
    end
end

function entities:Destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    disconnect(self.connections)
    for Player in self.items do
        self:Remove(Player)
    end
end

return entities
end function __DARKLUA_BUNDLE_MODULES.c():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.c if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.c=v end return v.c end end do local function __modImpl()
local vertices = {
    Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1),
    Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1),
    Vector3.new(-1, -1, 1), Vector3.new(1, -1, 1),
    Vector3.new(-1, 1, 1), Vector3.new(1, 1, 1),
}

local edges = {
    { 1, 2 }, { 1, 3 }, { 2, 4 }, { 3, 4 },
    { 5, 6 }, { 5, 7 }, { 6, 8 }, { 7, 8 },
    { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 },
}

local projection = {}

function projection.getBounds(parts, Root)
    local basis = Root.CFrame
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

    for _, Part in parts do
        if Part.Parent ~= Root.Parent then
            continue
        end

        local relative = basis:ToObjectSpace(Part.CFrame)
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = relative:GetComponents()
        local half = Part.Size * 0.5
        local extentX = math.abs(r00) * half.X + math.abs(r01) * half.Y + math.abs(r02) * half.Z
        local extentY = math.abs(r10) * half.X + math.abs(r11) * half.Y + math.abs(r12) * half.Z
        local extentZ = math.abs(r20) * half.X + math.abs(r21) * half.Y + math.abs(r22) * half.Z

        minX = math.min(minX, x - extentX)
        minY = math.min(minY, y - extentY)
        minZ = math.min(minZ, z - extentZ)
        maxX = math.max(maxX, x + extentX)
        maxY = math.max(maxY, y + extentY)
        maxZ = math.max(maxZ, z + extentZ)
    end

    if minX == math.huge then
        return
    end

    local center = Vector3.new((minX + maxX) * 0.5, (minY + maxY) * 0.5, (minZ + maxZ) * 0.5)
    return basis * CFrame.new(center), Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)
end

function projection.project(Camera, boundsCFrame, boundsSize, result)
    local viewport = Camera.ViewportSize
    if viewport.X <= 0 or viewport.Y <= 0 then
        return false
    end

    local points = result.points or table.create(8)
    local depths = result.depths or table.create(8)
    result.points, result.depths = points, depths
    local nearDepth = math.max(0.01, -Camera.NearPlaneZ)
    local left, top = math.huge, math.huge
    local right, bottom = -math.huge, -math.huge
    local inFront = 0
    local halfSize = boundsSize * 0.5

    for index, vertex in vertices do
        local worldPosition = boundsCFrame:PointToWorldSpace(halfSize * vertex)
        local screen = Camera:WorldToViewportPoint(worldPosition)
        points[index], depths[index] = worldPosition, screen.Z

        if screen.Z >= nearDepth then
            inFront += 1
            left, top = math.min(left, screen.X), math.min(top, screen.Y)
            right, bottom = math.max(right, screen.X), math.max(bottom, screen.Y)
        end
    end

    if inFront == 0 then
        return false
    end

    if inFront < 8 then
        for _, edge in edges do
            local a, b = edge[1], edge[2]
            local depthA, depthB = depths[a], depths[b]
            if (depthA >= nearDepth) ~= (depthB >= nearDepth) then
                local alpha = (nearDepth - depthA) / (depthB - depthA)
                local screen = Camera:WorldToViewportPoint(points[a]:Lerp(points[b], alpha))
                left, top = math.min(left, screen.X), math.min(top, screen.Y)
                right, bottom = math.max(right, screen.X), math.max(bottom, screen.Y)
            end
        end
    end

    if right <= left or bottom <= top
        or right < 0 or bottom < 0
        or left > viewport.X or top > viewport.Y then
        return false
    end

    result.left, result.top = left, top
    result.right, result.bottom = right, bottom
    return true
end

return projection
end function __DARKLUA_BUNDLE_MODULES.d():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.d if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.d=v end return v.c end end do local function __modImpl()
local drawing = {}

function drawing.check()
    assert(Drawing and type(Drawing.new) == "function", "ESP requires the Drawing API")
end

function drawing.create(className, properties)
    local object = Drawing.new(className)
    local success, message = pcall(function()
        for key, value in properties do
            object[key] = value
        end
    end)

    if not success then
        drawing.remove(object)
        error("ESP could not configure " .. className .. ": " .. tostring(message), 2)
    end

    return object
end

function drawing.remove(object)
    local removed = pcall(function()
        object:Remove()
    end)

    if not removed then
        local destroyed, message = pcall(function()
            object:Destroy()
        end)
        if not destroyed then
            warn("ESP could not release a drawing: " .. tostring(message))
        end
    end
end

return drawing
end function __DARKLUA_BUNDLE_MODULES.e():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.e if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.e=v end return v.c end end do local function __modImpl()
local drawing = __DARKLUA_BUNDLE_MODULES.e()

local function create(self, className, properties)
    local object = drawing.create(className, properties)
    self.resources[#self.resources + 1] = object
    return object
end

local function setSegment(self, index, x1, y1, x2, y2)
    local from = Vector2.new(x1, y1)
    local to = Vector2.new(x2, y2)
    self.lines[index].From = from
    self.lines[index].To = to
    self.outlines[index].From = from
    self.outlines[index].To = to
end

local box = {}
box.__index = box

function box.new()
    local self = setmetatable({
        resources = {},
        lines = {},
        outlines = {},
        visible = false,
        destroyed = false,
    }, box)

    local success, message = pcall(function()
        self.fill = create(self, "Square", {
            Visible = false,
            Filled = true,
            ZIndex = 0,
        })

        for index = 1, 8 do
            self.outlines[index] = create(self, "Line", { Visible = false, ZIndex = 1 })
            self.lines[index] = create(self, "Line", { Visible = false, ZIndex = 2 })
        end
    end)

    if not success then
        self:Destroy()
        error(message, 2)
    end

    return self
end

function box:Update(bounds, settings)
    if self.destroyed then
        return
    end
    if not settings.enabled then
        self:Hide()
        return
    end

    local changed = self.settings ~= settings
    local count = settings.style == "corner" and 8 or 4

    if changed then
        for index = 1, 8 do
            local line = self.lines[index]
            local outline = self.outlines[index]
            line.Color = settings.color
            line.Thickness = settings.thickness
            line.Transparency = settings.opacity
            outline.Color = settings.outline.color
            outline.Thickness = settings.thickness + settings.outline.thickness * 2
            outline.Transparency = settings.outline.opacity
        end
        self.fill.Color = settings.fill.color
        self.fill.Transparency = settings.fill.opacity
        self.settings = settings
    end

    local left = bounds.left - settings.padding
    local top = bounds.top - settings.padding
    local right = bounds.right + settings.padding
    local bottom = bounds.bottom + settings.padding
    local width = right - left
    local height = bottom - top

    if settings.style == "full" then
        setSegment(self, 1, left, top, right, top)
        setSegment(self, 2, right, top, right, bottom)
        setSegment(self, 3, right, bottom, left, bottom)
        setSegment(self, 4, left, bottom, left, top)
    else
        local horizontal = width * settings.cornerLength
        local vertical = height * settings.cornerLength
        setSegment(self, 1, left, top + vertical, left, top)
        setSegment(self, 2, left, top, left + horizontal, top)
        setSegment(self, 3, right - horizontal, top, right, top)
        setSegment(self, 4, right, top, right, top + vertical)
        setSegment(self, 5, left, bottom - vertical, left, bottom)
        setSegment(self, 6, left, bottom, left + horizontal, bottom)
        setSegment(self, 7, right - horizontal, bottom, right, bottom)
        setSegment(self, 8, right, bottom, right, bottom - vertical)
    end

    if settings.fill.enabled then
        self.fill.Position = Vector2.new(left, top)
        self.fill.Size = Vector2.new(width, height)
    end

    if changed or not self.visible then
        for index = 1, 8 do
            self.lines[index].Visible = index <= count
            self.outlines[index].Visible = index <= count and settings.outline.enabled
        end
        self.fill.Visible = settings.fill.enabled
        self.visible = true
    end
end

function box:Hide()
    if not self.visible then
        return
    end

    for _, object in self.resources do
        object.Visible = false
    end
    self.visible = false
end

function box:Destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    for _, object in self.resources do
        drawing.remove(object)
    end
    table.clear(self.resources)
    table.clear(self.lines)
    table.clear(self.outlines)
    self.fill = nil
    self.settings = nil
    self.visible = false
end

return box
end function __DARKLUA_BUNDLE_MODULES.f():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.f if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.f=v end return v.c end end do local function __modImpl()
local services = __DARKLUA_BUNDLE_MODULES.a()
local config = __DARKLUA_BUNDLE_MODULES.b()
local entities = __DARKLUA_BUNDLE_MODULES.c()
local projection = __DARKLUA_BUNDLE_MODULES.d()
local drawing = __DARKLUA_BUNDLE_MODULES.e()
local box = __DARKLUA_BUNDLE_MODULES.f()

local Players = services.Players
local RunService = services.RunService
local Workspace = services.Workspace
local LocalPlayer = Players.LocalPlayer

local function hide(entity)
    if entity.components.box then
        entity.components.box:Hide()
    end
end

local function isFriendly(Player)
    return not Player.Neutral and not LocalPlayer.Neutral
        and Player.Team ~= nil and Player.Team == LocalPlayer.Team
end

local library = {}
library.__index = library

function library.new(settings)
    assert(RunService:IsClient() and LocalPlayer, "ESP must run on the client")
    drawing.check()

    local self = setmetatable({
        settings = config.new(settings),
        entities = entities.new(Players, LocalPlayer),
        destroyed = false,
        bound = false,
    }, library)
    self.bindingName = "esp-library:" .. tostring(self)
    self.resolved = config.resolve(self.settings)
    return self
end

function library:stop()
    if self.bound then
        RunService:UnbindFromRenderStep(self.bindingName)
        self.bound = false
    end
    for _, entity in self.entities.items do
        hide(entity)
    end
end

function library:start()
    if self.bound or not self.settings.enabled or not self.entities.started then
        return
    end

    RunService:BindToRenderStep(self.bindingName, self.settings.renderPriority, function()
        local success, message = pcall(self.render, self)
        if not success then
            self:stop()
            self.settings.enabled = false
            warn("ESP paused after a rendering error: " .. tostring(message))
        end
    end)
    self.bound = true
end

function library:render()
    local Camera = Workspace.CurrentCamera
    local selection = self.settings.selection

    for Player, entity in self.entities.items do
        local friendly = isFriendly(Player)
        local settings = self.resolved[friendly and "friendly" or "enemy"]
        local Root, Humanoid = entity.Root, entity.Humanoid

        if not Camera or not settings.enabled or not settings.box.enabled
            or not Root or not Root.Parent or not Humanoid or not Humanoid.Parent
            or (selection == "enemies" and friendly)
            or (selection == "teammates" and not friendly) then
            hide(entity)
            continue
        end

        local dead = Humanoid.Health <= 0
        if (settings.deadPolicy == "hide" and dead)
            or (settings.deadPolicy == "only" and not dead)
            or (Camera.CFrame.Position - Root.Position).Magnitude > settings.maxDistance then
            hide(entity)
            continue
        end

        local boundsCFrame, boundsSize = projection.getBounds(entity.parts, Root)
        if not boundsCFrame or not projection.project(Camera, boundsCFrame, boundsSize, entity.bounds) then
            hide(entity)
            continue
        end

        if not entity.components.box then
            entity.components.box = box.new()
        end
        entity.components.box:Update(entity.bounds, settings.box)
    end
end

function library:AddPlayers()
    assert(not self.destroyed, "ESP instance has been destroyed")
    self.entities:Start()
    self:start()
    return self
end

function library:Set(settings)
    assert(not self.destroyed, "ESP instance has been destroyed")
    local nextSettings = config.update(self.settings, settings)
    local rebind = nextSettings.renderPriority ~= self.settings.renderPriority
    self.settings = nextSettings
    self.resolved = config.resolve(nextSettings)

    if rebind or not nextSettings.enabled then
        self:stop()
    end
    self:start()
    return self
end

function library:SetEnabled(enabled)
    return self:Set({ enabled = enabled })
end

function library:Destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    self:stop()
    self.entities:Destroy()
    self.resolved = nil
    self.settings = nil
end

return library
end function __DARKLUA_BUNDLE_MODULES.g():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.g if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.g=v end return v.c end end end
local library = __DARKLUA_BUNDLE_MODULES.g()

local esp = library.new({
    enabled = true,
    selection = "all",
    maxDistance = 2000,
    deadPolicy = "hide",

    box = {
        enabled = true,
        style = "corner",
        thickness = 1,
        padding = 3,
        cornerLength = 0.25,
        opacity = 1,

        outline = {
            enabled = true,
            color = Color3.fromRGB(5, 5, 5),
            thickness = 1,
            opacity = 1,
        },

        fill = {
            enabled = false,
            color = Color3.fromRGB(198, 198, 200),
            opacity = 0.15,
        },
    },

    groups = {
        enemy = {
            box = {
                color = Color3.fromRGB(220, 100, 100),
            },
        },
        friendly = {
            box = {
                color = Color3.fromRGB(100, 180, 220),
            },
        },
    },
})

esp:AddPlayers()

return esp
