-- Client-side 3D player boxes with a click/touch GUI.
-- Uses standard Roblox APIs; no downloads or executor-specific hooks.
-- Delta runtime compatibility has not been tested.
-- Only displays characters currently replicated to the client.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
assert(localPlayer, "Player ESP requires a Roblox client context.")

local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
assert(playerGui, "PlayerGui was not available within 10 seconds.")

local GUI_NAME = "XyroPlayerBoxesGUI"
local oldGui = playerGui:FindFirstChild(GUI_NAME)
if oldGui then
    local stop = oldGui:FindFirstChild("Stop")
    if stop and stop:IsA("BindableFunction") then
        stop:Invoke()
    else
        oldGui:Destroy()
    end
end

local COLOR = Color3.fromRGB(0, 235, 170)
local THICKNESS = 0.06
local PADDING = Vector3.new(0.2, 0.2, 0.2)
local UPDATE_INTERVAL = 0.1
local enabled = false
local stopped = false
local elapsed = UPDATE_INTERVAL
local boxes = {}
local connections = {}

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    connections[#connections + 1] = connection
    return connection
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local container = Instance.new("Folder")
container.Name = "Boxes"
container.Parent = gui

local function rounded(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(240, 130)
panel.Position = UDim2.fromOffset(24, 80)
panel.BackgroundColor3 = Color3.fromRGB(21, 24, 31)
panel.BorderSizePixel = 0
panel.Parent = gui
rounded(panel, 12)

local title = Instance.new("TextLabel")
title.Name = "DragHandle"
title.Size = UDim2.new(1, -52, 0, 42)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "3D PLAYER ESP"
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(235, 240, 247)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Position = UDim2.new(1, -39, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextSize = 18
closeButton.TextColor3 = Color3.fromRGB(240, 120, 120)
closeButton.Parent = panel

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleESP"
toggleButton.Size = UDim2.new(1, -28, 0, 44)
toggleButton.Position = UDim2.fromOffset(14, 46)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold