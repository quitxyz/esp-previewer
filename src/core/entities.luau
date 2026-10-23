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
