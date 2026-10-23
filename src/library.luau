local services = require("@utils/services")
local config = require("@core/config")
local entities = require("@core/entities")
local projection = require("@core/projection")
local drawing = require("@renderers/drawing")
local box = require("@components/box")

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
