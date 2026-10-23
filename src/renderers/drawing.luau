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
