local library = require("@src/library")

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
