local cloneRef = cloneref or function(reference)
    return reference
end

return {
    Players = cloneRef(game:GetService("Players")),
    RunService = cloneRef(game:GetService("RunService")),
    Workspace = cloneRef(game:GetService("Workspace")),
}
