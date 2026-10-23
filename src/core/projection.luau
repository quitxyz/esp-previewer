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
