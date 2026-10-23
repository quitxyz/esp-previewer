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
