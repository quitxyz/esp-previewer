local drawing = require("@renderers/drawing")

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
