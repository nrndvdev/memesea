-- Roblox Studio: insert as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- Private Studio test only. B toggles the boxes. Use a multi-client playtest.
-- Only characters replicated to this client can be displayed.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsStudio() then
    warn("PlayerBoxes: this visualization is restricted to Studio playtests.")
    return
end

local localPlayer = Players.LocalPlayer
assert(localPlayer, "PlayerBoxes must run as a LocalScript.")

local COLOR = Color3.fromRGB(0, 255, 180)
local THICKNESS = 0.055
local PADDING = Vector3.new(0.15, 0.15, 0.15)
local UPDATE_INTERVAL = 0.1

local container = Instance.new("Folder")
container.Name = "PlayerBoxes"
container.Parent = localPlayer:WaitForChild("PlayerGui")

local boxes = {}
local enabled = true
local elapsed = UPDATE_INTERVAL

local function removeBox(player)
    local record = boxes[player]
    if record then
        record.folder:Destroy()
        boxes[player] = nil
    end
end

local function clearBoxes()
    for player in pairs(boxes) do
        removeBox(player)
    end
end

local function createBox(player, character, root)
    local folder = Instance.new("Folder")
    folder.Name = tostring(player.UserId)
    folder.Parent = container

    local edges = {}
    for i = 1, 12 do
        local edge = Instance.new("BoxHandleAdornment")
        edge.Name = "Edge" .. i
        edge.Adornee = root
        edge.AlwaysOnTop = true
        edge.ZIndex = 5
        edge.Color3 = COLOR
        edge.Transparency = 0
        edge.Parent = folder
        edges[i] = edge
    end

    local record = {
        folder = folder,
        character = character,
        root = root,
        edges = edges,
    }
    boxes[player] = record
    return record
end

local function updateBox(record)
    -- Includes the character's currently replicated accessories and tools.
    local boundsFrame, boundsSize = record.character:GetBoundingBox()
    local size = boundsSize + PADDING
    local half = size * 0.5
    local relative = record.root.CFrame:ToObjectSpace(boundsFrame)
    local index = 0

    local function edge(position, dimensions)
        index = index + 1
        local adornment = record.edges[index]
        adornment.Size = dimensions
        adornment.CFrame = relative * CFrame.new(position)
    end

    -- Four edges along each of the three axes form a wireframe cuboid.
    for _, a in ipairs({ -1, 1 }) do
        for _, b in ipairs({ -1, 1 }) do
            edge(Vector3.new(0, a * half.Y, b * half.Z),
                Vector3.new(size.X, THICKNESS, THICKNESS))
            edge(Vector3.new(a * half.X, 0, b * half.Z),
                Vector3.new(THICKNESS, size.Y, THICKNESS))
            edge(Vector3.new(a * half.X, b * half.Y, 0),
                Vector3.new(THICKNESS, THICKNESS, size.Z))
        end