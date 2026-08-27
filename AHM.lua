-- AHM Script - Fully Decrypted & Unlocked
-- Controls: 
--   SHIFT = Auto Switch (Head ↔ Torso) - works ANYWHERE (car or on foot)
--   ALT = HEAD mode - works ANYWHERE (car or on foot)
--   G = Toggle CLUTCH mode (ON/OFF) - when ON, aim goes to HEAD in car
--   CLUTCH automatically turns OFF when you exit the vehicle
--   When you re-enter vehicle, you must press G again to turn it ON

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPack = game:GetService("StarterPack")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURATION =================
local espInventoryEnabled = true 
local MAX_DISTANCE = 2000 
local UPDATE_INTERVAL = 1 
local BillboardCache = {}
local nameCache = {} 

local RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(220, 220, 220),
    ["Uncommon"] = Color3.fromRGB(0, 255, 100),
    ["Rare"] = Color3.fromRGB(0, 170, 255),
    ["Epic"] = Color3.fromRGB(200, 0, 255),
    ["Legendary"] = Color3.fromRGB(255, 215, 0),
    ["Omega"] = Color3.fromRGB(255, 0, 0),
}

local function getRealName(t)
    if not t or not t.Name then return nil end
    
    local originalName = t.Name
    local lowerName = originalName:lower()

    local cleaned = lowerName
        :gsub("%d+$", "")
        :gsub("_%d+$", "")
        :gsub("%s*%d+%s*$", "")
        :gsub("[%s_]+", " ")
        :gsub("([^%w%s])", "")
        :match("^%s*(.-)%s*$")

    if cleaned:find("fishing") or cleaned:find("rod") or cleaned:find("canne") or cleaned:find("pأھche") then
        if cleaned:find("ultimate") or cleaned:find("ult") then
            return "Ultimate Fishing Rod"
        elseif cleaned:find("advanced") then
            return "Advanced Fishing Rod"
        elseif cleaned:find("pro") then
            return "Pro Fishing Rod"
        else
            return "Regular Fishing Rod"
        end
    end

    if nameCache[originalName] then 
        return nameCache[originalName] 
    end
    
    local h = t:FindFirstChild("Handle")
    local fallbackName = cleaned
    
    for _, folder in ipairs({ReplicatedStorage:FindFirstChild("Items"), StarterPack}) do
        if folder then
            for _, item in ipairs(folder:GetDescendants()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then
                    local match = true
                    if h then
                        for _, c in ipairs(h:GetChildren()) do
                            if not item.Handle:FindFirstChild(c.Name) then 
                                match = false 
                                break 
                            end
                        end
                    else
                        match = false
                    end
                    if match then 
                        nameCache[originalName] = item.Name 
                        return item.Name 
                    end
                end
            end
        end
    end
    
    nameCache[originalName] = fallbackName
    return fallbackName
end

local function updateESP(p)
    local bb = BillboardCache[p]
    if not bb then return end
    
    local char = p.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        bb.Enabled = false
        return 
    end
    
    local lChar = LocalPlayer.Character
    if lChar and lChar:FindFirstChild("HumanoidRootPart") then
        local dist = (lChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
        if dist > MAX_DISTANCE then
            bb.Enabled = false
            return
        end
    end

    local container = bb:FindFirstChild("EspContainer")
    if not container then return end
    container:ClearAllChildren()

    local layout = Instance.new("UIListLayout", container)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom 
    layout.Padding = UDim.new(0, 2)

    local tools = {}
    if p:FindFirstChild("Backpack") then
        for _, t in ipairs(p.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() ~= "fists" then table.insert(tools, t) end
        end
    end
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() ~= "fists" then table.insert(tools, t) end
        end
    end

    bb.Enabled = espInventoryEnabled and (#tools > 0)
    
   for _, tool in ipairs(tools) do
    local name = getRealName(tool)

    if name then
        local lbl = Instance.new("TextLabel", container)
        lbl.Size = UDim2.new(0, 180, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextStrokeTransparency = 0.5
        local rarity = tool:GetAttribute("RarityName") or tool:GetAttribute("Rarity")
lbl.TextColor3 = RARITY_COLORS[rarity] or Color3.fromRGB(255,255,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Center
    end
end

end
local function createESP(p)
    if p == LocalPlayer then return end
    
    local function setup(char)
        local root = char:WaitForChild("HumanoidRootPart", 15)
        if not root then return end
        
        if BillboardCache[p] then BillboardCache[p]:Destroy() end
    
        local bb = Instance.new("BillboardGui", root)
        bb.Name = "FixedUnderfootESP"
        bb.Size = UDim2.new(0, 200, 0, 150)
        bb.StudsOffset = Vector3.new(0, -3.5, 0) 
        bb.AlwaysOnTop = true
        bb.MaxDistance = MAX_DISTANCE
        
        local cont = Instance.new("Frame", bb)
        cont.Name = "EspContainer"
        cont.Size = UDim2.new(1, 0, 1, 0)
        cont.BackgroundTransparency = 1
        
        BillboardCache[p] = bb

        updateESP(p)
        
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.1); updateESP(p) end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.1); updateESP(p) end
        end)
        
        local backpack = p:WaitForChild("Backpack", 5)
        if backpack then
            backpack.ChildAdded:Connect(function() updateESP(p) end)
            backpack.ChildRemoved:Connect(function() updateESP(p) end)
        end

        task.spawn(function()
            while char.Parent and bb.Parent do
                updateESP(p)
                task.wait(UPDATE_INTERVAL)
            end
        end)
    end
    
    p.CharacterAdded:Connect(setup)
    if p.Character then setup(p.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

-- ================= INTERFACE =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AHM_HUB"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local Themes = {
    Navy = {
        Background = Color3.fromRGB(10, 20, 40),
        Panel = Color3.fromRGB(20, 35, 70),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(235, 245, 255),
        ON = Color3.fromRGB(0, 200, 0),
        OFF = Color3.fromRGB(200, 0, 0),
    }
}

local CurrentTheme = Themes.Navy

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.4, 0, 0.80, 0)
MainFrame.Position = UDim2.new(0.3, 0, 0.10, 0)
MainFrame.BackgroundColor3 = CurrentTheme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,8)

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(0.8,0,0.05,0)
TitleLabel.Position = UDim2.new(0.1,0,0.01,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ AHM HUB ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0,255,0)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.SourceSansBold

local MainDrag = Instance.new("Frame", MainFrame)
MainDrag.Size = UDim2.new(1,0,0.07,0)
MainDrag.BackgroundTransparency = 1

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0,100,0,40)
ToggleButton.Position = UDim2.new(0.9,0,0.05,0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
ToggleButton.Text = "Open"
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
ToggleButton.TextScaled = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0,8)
ToggleButton.Visible = true

local ToggleDrag = Instance.new("Frame", ToggleButton)
ToggleDrag.Size = UDim2.new(1,0,1,0)
ToggleDrag.BackgroundTransparency = 1

-- SMART MODE TOGGLE
local SmartToggle = Instance.new("TextButton", MainFrame)
SmartToggle.Size = UDim2.new(0.8,0,0.07,0)
SmartToggle.Position = UDim2.new(0.1,0,0.07,0)
SmartToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SmartToggle.Text = "SMART: ON"
SmartToggle.TextScaled = true
SmartToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SmartToggle).CornerRadius = UDim.new(0,8)

-- CLUTCH MODE TOGGLE (Fixes car aim to HEAD when ON)
local ClutchToggle = Instance.new("TextButton", MainFrame)
ClutchToggle.Size = UDim2.new(0.8,0,0.07,0)
ClutchToggle.Position = UDim2.new(0.1,0,0.15,0)
ClutchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ClutchToggle.Text = "CLUTCH: OFF"
ClutchToggle.TextScaled = true
ClutchToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ClutchToggle).CornerRadius = UDim.new(0,8)

-- AI LEAD TOGGLE
local AILeadToggle = Instance.new("TextButton", MainFrame)
AILeadToggle.Size = UDim2.new(0.8,0,0.07,0)
AILeadToggle.Position = UDim2.new(0.1,0,0.23,0)
AILeadToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
AILeadToggle.Text = "AI LEAD: OFF"
AILeadToggle.TextScaled = true
AILeadToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AILeadToggle).CornerRadius = UDim.new(0,8)

-- AI LEAD SLIDER
local AILabel = Instance.new("TextLabel", MainFrame)
AILabel.Size = UDim2.new(0.4,0,0.05,0)
AILabel.Position = UDim2.new(0.1,0,0.31,0)
AILabel.BackgroundTransparency = 1
AILabel.Text = "Lead Strength: 50%"
AILabel.TextColor3 = Color3.fromRGB(255,255,255)
AILabel.TextScaled = true
AILabel.Font = Enum.Font.SourceSansBold

local AILeadSlider = Instance.new("TextBox", MainFrame)
AILeadSlider.Size = UDim2.new(0.4,0,0.05,0)
AILeadSlider.Position = UDim2.new(0.5,0,0.31,0)
AILeadSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
AILeadSlider.Text = "50"
AILeadSlider.TextColor3 = Color3.fromRGB(255,255,255)
AILeadSlider.TextScaled = true
Instance.new("UICorner", AILeadSlider).CornerRadius = UDim.new(0,8)

local ESPInventoryToggle = Instance.new("TextButton", MainFrame)
ESPInventoryToggle.Size = UDim2.new(0.8,0,0.07,0)
ESPInventoryToggle.Position = UDim2.new(0.1,0,0.37,0)
ESPInventoryToggle.BackgroundColor3 = Color3.fromRGB(0,255,0)
ESPInventoryToggle.Text = "ESP Inventory: ON"
ESPInventoryToggle.TextScaled = true
Instance.new("UICorner", ESPInventoryToggle).CornerRadius = UDim.new(0,8)

local ESPToggle = Instance.new("TextButton", MainFrame)
ESPToggle.Size = UDim2.new(0.8,0,0.07,0)
ESPToggle.Position = UDim2.new(0.1,0,0.45,0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(255,0,0)
ESPToggle.Text = "ESP: ON"
ESPToggle.TextScaled = true
Instance.new("UICorner", ESPToggle).CornerRadius = UDim.new(0,8)

local AimbotToggle = Instance.new("TextButton", MainFrame)
AimbotToggle.Size = UDim2.new(0.8,0,0.07,0)
AimbotToggle.Position = UDim2.new(0.1,0,0.53,0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(255,0,0)
AimbotToggle.Text = "Aimbot: ON"
AimbotToggle.TextScaled = true
Instance.new("UICorner", AimbotToggle).CornerRadius = UDim.new(0,8)

local WallcheckToggle = Instance.new("TextButton", MainFrame)
WallcheckToggle.Size = UDim2.new(0.8,0,0.07,0)
WallcheckToggle.Position = UDim2.new(0.1,0,0.61,0)
WallcheckToggle.BackgroundColor3 = Color3.fromRGB(0,255,0)
WallcheckToggle.Text = "Wallcheck: ON"
WallcheckToggle.TextScaled = true
WallcheckToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", WallcheckToggle).CornerRadius = UDim.new(0,8)

local FOVSlider = Instance.new("TextBox", MainFrame)
FOVSlider.Size = UDim2.new(0.8,0,0.07,0)
FOVSlider.Position = UDim2.new(0.1,0,0.69,0)
FOVSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
FOVSlider.Text = "FOV: 150"
FOVSlider.TextColor3 = Color3.fromRGB(255,0,0)
FOVSlider.TextScaled = true
Instance.new("UICorner", FOVSlider).CornerRadius = UDim.new(0,8)

local AimPartToggle = Instance.new("TextButton", MainFrame)
AimPartToggle.Size = UDim2.new(0.8,0,0.07,0)
AimPartToggle.Position = UDim2.new(0.1,0,0.77,0)
AimPartToggle.BackgroundColor3 = Color3.fromRGB(100,100,255)
AimPartToggle.Text = "Target: Auto Switch (Head ↔ Torso)"
AimPartToggle.TextScaled = true
AimPartToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AimPartToggle).CornerRadius = UDim.new(0,8)

local FOVCircleToggle = Instance.new("TextButton", MainFrame)
FOVCircleToggle.Size = UDim2.new(0.8,0,0.07,0)
FOVCircleToggle.Position = UDim2.new(0.1,0,0.85,0)
FOVCircleToggle.BackgroundColor3 = Color3.fromRGB(0,255,0)
FOVCircleToggle.Text = "FOV Circle: ON"
FOVCircleToggle.TextScaled = true
FOVCircleToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FOVCircleToggle).CornerRadius = UDim.new(0,8)

local PlayerListFrame = Instance.new("ScrollingFrame", MainFrame)
PlayerListFrame.Size = UDim2.new(0.8,0,0.12,0)
PlayerListFrame.Position = UDim2.new(0.1,0,0.93,0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
PlayerListFrame.ScrollBarThickness = 6
PlayerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0,8)

local PlayerListLayout = Instance.new("UIListLayout", PlayerListFrame)
PlayerListLayout.Padding = UDim.new(0,4)

local function ApplyTheme()
    MainFrame.BackgroundColor3 = CurrentTheme.Background
    TitleLabel.TextColor3 = CurrentTheme.Accent

    for _, v in ipairs(MainFrame:GetDescendants()) do
        if v:IsA("TextButton") then
            v.BackgroundColor3 = CurrentTheme.Panel
            v.TextColor3 = CurrentTheme.Text
        end
    end
end

-- ================= VARIABLES =================
local espEnabledStatus = true
local AimbotOn = true
local FOVRadius = 150
local WallCheckEnabled = true
local FOVCircleVisible = true
local FOVCircleForcedOff = false
local ProtectedPlayers = {}
local PlayerButtons = {}
local AIM_SMOOTHNESS = 0.8
local PREDICTION_TIME = 0.04
local guiOpen = false

-- SMART MODE: ON by default
local smartMode = true

-- CLUTCH MODE: OFF by default
local clutchMode = false

-- AI LEAD: OFF by default
local aiLeadEnabled = false
local aiLeadStrength = 0.5
local lastDirection = nil

-- Force mode: 1 = Auto Switch, 2 = Head
local forceMode = 1

-- ================= COOLDOWN SYSTEM =================
local lastModeSwitchTime = 0
local MODE_SWITCH_COOLDOWN = 3

local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOVRadius
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255,0,0)
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Auto Switch: Head (0.7s) then Torso (0.7s)
local AIM_MODES = {
    {name = "Auto Switch (Head ↔ Torso)", parts = {"Head", "HumanoidRootPart"}},
    {name = "Head (fixed)",               part = "Head"},
}

local currentAutoIndex = 1
local lastSwitchTime = os.clock()
local SWITCH_INTERVAL = 0.7

-- ================= FUNCTIONS =================
local function IsAlive(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsInVehicle(char)
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local seatPart = humanoid.SeatPart
    return seatPart and seatPart.Parent and seatPart.Parent:FindFirstChild("VehicleSeat")
end

local function IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character or workspace, part.Parent}
    local result = workspace:Raycast(origin, direction, params)
    return not result
end

local function removeESP(char)
    if char then
        local head = char:FindFirstChild("Head")
        if head then 
            local b = head:FindFirstChild("AHMNameHP") 
            if b then b:Destroy() end 
        end
        local h = char:FindFirstChild("AHMHighlight") 
        if h then h:Destroy() end
    end
end

local function applyESP(char)
    local plr = Players:GetPlayerFromCharacter(char)
    if not plr or plr == LocalPlayer then return end
    removeESP(char)

    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum or not IsAlive(char) then return end

    local bill = Instance.new("BillboardGui", head)
    bill.Name = "AHMNameHP"
    bill.Adornee = head
    bill.Size = UDim2.new(0,160,0,35)
    bill.StudsOffset = Vector3.new(0,2.8,0)
    bill.AlwaysOnTop = true

    local name = Instance.new("TextLabel", bill)
    name.Size = UDim2.new(1,0,0,16)
    name.BackgroundTransparency = 1
    name.Text = plr.DisplayName ~= plr.Name and (plr.DisplayName .. " (@" .. plr.Name .. ")") or plr.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0
    name.Font = Enum.Font.SourceSansBold
    name.TextSize = 14

    local hpBg = Instance.new("Frame", bill)
    hpBg.Size = UDim2.new(1,-6,0,5)
    hpBg.Position = UDim2.new(0,3,0,16)
    hpBg.BackgroundColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0,3)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Size = UDim2.new(1,0,1,0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0,3)

    local hpText = Instance.new("TextLabel", hpBg)
    hpText.Size = UDim2.new(1,0,1,0)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.new(1,1,1)
    hpText.TextStrokeTransparency = 0
    hpText.TextSize = 8

    local function updateHP()
        if hum.Parent and IsAlive(char) then
            local r = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            hpFill.Size = UDim2.new(r, 0, 1, 0)
            hpText.Text = math.floor(hum.Health) .. "/" .. hum.MaxHealth
        else
            removeESP(char)
        end
    end

    hum.HealthChanged:Connect(updateHP)
    hum.Died:Connect(function() removeESP(char) end)
    updateHP()

    local hl = Instance.new("Highlight", char)
    hl.Name = "AHMHighlight"
    hl.OutlineColor = Color3.fromRGB(255,255,0)
    hl.OutlineTransparency = 0
    hl.FillTransparency = 1
end

local function onCharAdded(char)
    local plr = Players:GetPlayerFromCharacter(char)
    if not plr or plr == LocalPlayer then return end
    task.delay(0.6, function()
        removeESP(char)
        if espEnabledStatus then applyESP(char) end
    end)
end

for _, p in Players:GetPlayers() do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(onCharAdded)
        if p.Character then onCharAdded(p.Character) end
    end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(onCharAdded)
        if p.Character then onCharAdded(p.Character) end
    end
end)

RunService.Heartbeat:Connect(function()
    if espEnabledStatus then
        for _, p in Players:GetPlayers() do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("AHMNameHP") then
                    applyESP(p.Character)
                end
            end
        end
    end
end)

local function UpdateProtectedList()
    for _, b in PlayerButtons do b:Destroy() end
    PlayerButtons = {}
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", PlayerListFrame)
            btn.Size = UDim2.new(1,-10,0,30)
            local prot = ProtectedPlayers[p] or false
            btn.BackgroundColor3 = prot and Color3.fromRGB(0,100,255) or Color3.fromRGB(60,60,60)
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")" .. (prot and " ✔" or "")
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
            table.insert(PlayerButtons, btn)

            btn.MouseButton1Click:Connect(function()
                ProtectedPlayers[p] = not ProtectedPlayers[p]
                UpdateProtectedList()
            end)
        end
    end
    local count = 0 
    for _ in pairs(ProtectedPlayers) do count = count + 1 end
    TitleLabel.Text = "⚡ AHM HUB | Protected: " .. count .. " ⚡"
end

Players.PlayerAdded:Connect(UpdateProtectedList)
Players.PlayerRemoving:Connect(UpdateProtectedList)
UpdateProtectedList()

-- ================= GET TARGET PART WITH CLUTCH MODE =================
local function GetTargetPart(char)
    local targetPartName
    local useClutch = false
    
    -- Check if CLUTCH mode is ON and we are in a vehicle
    if clutchMode then
        local meInVehicle = IsInVehicle(LocalPlayer.Character)
        if meInVehicle then
            useClutch = true
            targetPartName = "Head"  -- CLUTCH fixes aim to HEAD in vehicle
        end
    end
    
    -- If CLUTCH is not active, use normal mode
    if not useClutch then
        if forceMode == 2 then
            targetPartName = "Head"
        else
            -- Auto Switch mode
            local mode = AIM_MODES[1]
            if os.clock() - lastSwitchTime >= SWITCH_INTERVAL then
                lastSwitchTime = os.clock()
                currentAutoIndex = currentAutoIndex % #mode.parts + 1
            end
            targetPartName = mode.parts[currentAutoIndex]
        end
    end
    
    local part = char:FindFirstChild(targetPartName)
    if not part then
        if targetPartName == "RightUpperArm" then part = char:FindFirstChild("Right Arm") end
        if targetPartName == "LeftUpperArm" then part = char:FindFirstChild("Left Arm") end
    end
    
    -- Update UI
    if useClutch then
        AimPartToggle.Text = "Target: CLUTCH (HEAD in car)"
        AimPartToggle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    elseif forceMode == 2 then
        AimPartToggle.Text = "Target: HEAD (ALT)"
        AimPartToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        local currentPart = (currentAutoIndex == 1) and "HEAD" or "TORSO"
        AimPartToggle.Text = "Target: Auto Switch (" .. currentPart .. ") [SHIFT]"
        AimPartToggle.BackgroundColor3 = Color3.fromRGB(100,100,255)
    end
    
    return part or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- ================= AI LEAD PREDICTION =================
local function GetPredictedPosition(char)
    local part = GetTargetPart(char)
    if not part then return nil end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return part.Position end
    
    if not aiLeadEnabled then
        return part.Position
    end
    
    local velocity = root.Velocity
    local speed = velocity.Magnitude
    
    if speed < 5 then
        return part.Position
    end
    
    local direction = velocity.Unit
    
    if lastDirection then
        local dotProduct = lastDirection:Dot(direction)
        if dotProduct < -0.3 then
            aiLeadStrength = aiLeadStrength * 0.3
        else
            aiLeadStrength = math.min(aiLeadStrength + 0.01, 0.5)
        end
    end
    lastDirection = direction
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = 0
    if myRoot then
        distance = (myRoot.Position - root.Position).Magnitude
    end
    
    local leadMultiplier = aiLeadStrength * 2.5
    
    if distance > 150 then
        leadMultiplier = leadMultiplier * 1.5
    elseif distance > 300 then
        leadMultiplier = leadMultiplier * 2
    end
    
    if distance < 30 then
        leadMultiplier = leadMultiplier * 0.5
    end
    
    local predictedPos = part.Position + (direction * leadMultiplier * (speed / 20))
    
    return predictedPos
end

local function GetClosest()
    local closest, distMin = nil, math.huge
    local center = Camera.ViewportSize / 2
    
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and not ProtectedPlayers[p] and p.Character and IsAlive(p.Character) then
            local part = GetTargetPart(p.Character)
            if part then
                local predictedPos = GetPredictedPosition(p.Character) or part.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < distMin and dist <= FOVRadius then
                        if not WallCheckEnabled or IsVisible(part) then
                            distMin = dist
                            closest = p
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = FOVRadius
    FOVCircle.Visible = AimbotOn and FOVCircleVisible and not FOVCircleForcedOff
    
    if AimbotOn then
        local target = GetClosest()
        if target and target.Character then
            local predictedPos = GetPredictedPosition(target.Character)
            if predictedPos then
                local cf = CFrame.new(Camera.CFrame.Position, predictedPos)
                Camera.CFrame = Camera.CFrame:Lerp(cf, AIM_SMOOTHNESS)
            end
        end
    end
end)

-- ================= VEHICLE DETECTION - AUTO TURN OFF CLUTCH =================
local function CheckVehicle()
    local char = LocalPlayer.Character
    if not char then return end
    
    local inVehicle = IsInVehicle(char)
    local wasInVehicle = isInVehicle
    
    -- Update vehicle state
    isInVehicle = inVehicle
    
    -- If we exited the vehicle, turn off CLUTCH automatically
    if wasInVehicle and not inVehicle then
        if clutchMode then
            clutchMode = false
            ClutchToggle.Text = "CLUTCH: OFF"
            ClutchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            print("🚗 Exited vehicle - CLUTCH turned OFF automatically")
            print("💡 Press G to turn CLUTCH ON when you enter a vehicle")
        end
    end
    
    -- If we entered the vehicle
    if not wasInVehicle and inVehicle then
        print("🚗 Entered vehicle - CLUTCH is OFF")
        print("💡 Press G to turn CLUTCH ON for HEAD aim")
    end
end

-- Vehicle state tracking
local isInVehicle = false

task.spawn(function()
    while true do
        task.wait(0.5)
        CheckVehicle()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    isInVehicle = false
    clutchMode = false
    ClutchToggle.Text = "CLUTCH: OFF"
    ClutchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    task.wait(1)
    CheckVehicle()
end)

-- ================= KEYBOARD CONTROLS =================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local currentTime = os.clock()
    
    -- SHIFT -> Auto Switch mode
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        if not smartMode then
            print("⚠️ SMART mode is OFF! Press SMART button to enable")
            return
        end
        
        if currentTime - lastModeSwitchTime >= MODE_SWITCH_COOLDOWN then
            forceMode = 1
            currentAutoIndex = 1
            lastSwitchTime = os.clock()
            lastModeSwitchTime = currentTime
            print("🔄 AUTO SWITCH mode (Head ↔ Torso)")
        else
            local remaining = math.ceil(MODE_SWITCH_COOLDOWN - (currentTime - lastModeSwitchTime))
            print("⏳ Cooldown! Wait " .. remaining .. " seconds before switching")
        end
    end
    
    -- ALT -> Head mode
    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        if not smartMode then
            print("⚠️ SMART mode is OFF! Press SMART button to enable")
            return
        end
        
        if currentTime - lastModeSwitchTime >= MODE_SWITCH_COOLDOWN then
            forceMode = 2
            lastModeSwitchTime = currentTime
            print("🔴 HEAD mode")
        else
            local remaining = math.ceil(MODE_SWITCH_COOLDOWN - (currentTime - lastModeSwitchTime))
            print("⏳ Cooldown! Wait " .. remaining .. " seconds before switching")
        end
    end
    
    -- G -> Toggle CLUTCH mode (only works if in vehicle)
    if input.KeyCode == Enum.KeyCode.G then
        local char = LocalPlayer.Character
        if not char then
            print("⚠️ You need to be in a vehicle to use CLUTCH!")
            return
        end
        
        local inVehicle = IsInVehicle(char)
        if not inVehicle then
            print("⚠️ You must be in a vehicle to toggle CLUTCH!")
            return
        end
        
        -- Toggle CLUTCH
        clutchMode = not clutchMode
        if clutchMode then
            ClutchToggle.Text = "CLUTCH: ON"
            ClutchToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            print("🚗 CLUTCH: ON - Aim will go to HEAD in vehicle")
        else
            ClutchToggle.Text = "CLUTCH: OFF"
            ClutchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            print("🚗 CLUTCH: OFF - Normal aim in vehicle")
        end
    end
    
    -- Original G for GUI (now using RightControl or different key)
    if input.KeyCode == Enum.KeyCode.RightControl then
        guiOpen = not guiOpen
        MainFrame.Visible = guiOpen
        ToggleButton.Visible = not guiOpen
        if guiOpen then UpdateProtectedList() end
    end
    
    if input.KeyCode == Enum.KeyCode.K then
        FOVCircleForcedOff = not FOVCircleForcedOff
        if FOVCircleToggle then
            if FOVCircleForcedOff then
                FOVCircleToggle.BackgroundColor3 = Color3.fromRGB(150,150,150)
                FOVCircleToggle.Text = "FOV Circle: FORCED OFF (K)"
            else
                FOVCircleToggle.BackgroundColor3 = FOVCircleVisible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                FOVCircleToggle.Text = "FOV Circle: " .. (FOVCircleVisible and "ON" or "OFF")
            end
        end
    end
end)

-- ================= BUTTONS =================
-- SMART MODE
SmartToggle.MouseButton1Click:Connect(function()
    smartMode = not smartMode
    if smartMode then
        SmartToggle.Text = "SMART: ON"
        SmartToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        print("✅ SMART mode ENABLED - SHIFT and ALT work")
    else
        SmartToggle.Text = "SMART: OFF"
        SmartToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        print("❌ SMART mode DISABLED - Manual mode")
    end
end)

-- CLUTCH MODE (Manual button press - same as G key)
ClutchToggle.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then
        print("⚠️ You need to be in a vehicle to use CLUTCH!")
        return
    end
    
    local inVehicle = IsInVehicle(char)
    if not inVehicle then
        print("⚠️ You must be in a vehicle to toggle CLUTCH!")
        return
    end
    
    clutchMode = not clutchMode
    if clutchMode then
        ClutchToggle.Text = "CLUTCH: ON"
        ClutchToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        print("🚗 CLUTCH: ON - Aim will go to HEAD in vehicle")
    else
        ClutchToggle.Text = "CLUTCH: OFF"
        ClutchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        print("🚗 CLUTCH: OFF - Normal aim in vehicle")
    end
end)

-- AI LEAD
AILeadToggle.MouseButton1Click:Connect(function()
    aiLeadEnabled = not aiLeadEnabled
    if aiLeadEnabled then
        AILeadToggle.Text = "AI LEAD: ON"
        AILeadToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        print("🧠 AI LEAD ENABLED")
    else
        AILeadToggle.Text = "AI LEAD: OFF"
        AILeadToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        print("🧠 AI LEAD DISABLED")
        lastDirection = nil
    end
end)

-- AI LEAD SLIDER
AILeadSlider.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(AILeadSlider.Text)
        if num and num >= 0 and num <= 100 then
            aiLeadStrength = num / 100
            AILabel.Text = "Lead Strength: " .. num .. "%"
            print("🎯 AI Lead Strength: " .. num .. "%")
        else
            AILeadSlider.Text = tostring(math.floor(aiLeadStrength * 100))
        end
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabledStatus = not espEnabledStatus
    ESPToggle.Text = "ESP: " .. (espEnabledStatus and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = espEnabledStatus and CurrentTheme.ON or CurrentTheme.OFF
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and p.Character then
            if espEnabledStatus then 
                applyESP(p.Character) 
            else 
                removeESP(p.Character) 
            end
        end
    end
end)

AimbotToggle.MouseButton1Click:Connect(function()
    AimbotOn = not AimbotOn
    AimbotToggle.Text = "Aimbot: " .. (AimbotOn and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = AimbotOn and CurrentTheme.ON or CurrentTheme.OFF
end)

AimPartToggle.MouseButton1Click:Connect(function()
    if not smartMode then
        print("⚠️ SMART mode is OFF! Enable SMART to switch modes")
        return
    end
    
    local currentTime = os.clock()
    
    if currentTime - lastModeSwitchTime >= MODE_SWITCH_COOLDOWN then
        if forceMode == 1 then
            forceMode = 2
            lastModeSwitchTime = currentTime
            print("🔴 HEAD mode")
        else
            forceMode = 1
            currentAutoIndex = 1
            lastSwitchTime = os.clock()
            lastModeSwitchTime = currentTime
            print("🔄 AUTO SWITCH mode")
        end
    else
        local remaining = math.ceil(MODE_SWITCH_COOLDOWN - (currentTime - lastModeSwitchTime))
        print("⏳ Cooldown! Wait " .. remaining .. " seconds before switching")
    end
end)

WallcheckToggle.MouseButton1Click:Connect(function()
    WallCheckEnabled = not WallCheckEnabled
    WallcheckToggle.Text = "Wallcheck: " .. (WallCheckEnabled and "ON" or "OFF")
    WallcheckToggle.BackgroundColor3 = WallCheckEnabled and CurrentTheme.ON or CurrentTheme.OFF
end)

FOVSlider.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(FOVSlider.Text:match("%d+"))
        if num and num >= 20 and num <= 600 then
            FOVRadius = num
            FOVCircle.Radius = num
            FOVSlider.Text = "FOV: " .. num
        else
            FOVSlider.Text = "FOV: " .. FOVRadius
        end
    end
end)

FOVCircleToggle.MouseButton1Click:Connect(function()
    FOVCircleVisible = not FOVCircleVisible
    FOVCircleToggle.Text = "FOV Circle: " .. (FOVCircleVisible and "ON" or "OFF")
    FOVCircleToggle.BackgroundColor3 = FOVCircleVisible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end)

ESPInventoryToggle.MouseButton1Click:Connect(function()
    espInventoryEnabled = not espInventoryEnabled
    ESPInventoryToggle.Text = "ESP Inventory: " .. (espInventoryEnabled and "ON" or "OFF")
    ESPInventoryToggle.BackgroundColor3 = espInventoryEnabled and CurrentTheme.ON or CurrentTheme.OFF
    for _, p in ipairs(Players:GetPlayers()) do
        updateESP(p)
    end
end)

-- ================= DRAG FUNCTIONS =================
local function makeDraggable(frame, dragArea)
    local dragging, startPos, startMouse
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startMouse = input.Position
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(MainFrame, MainDrag)
makeDraggable(ToggleButton, ToggleDrag)

ToggleButton.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    MainFrame.Visible = guiOpen
    ToggleButton.Text = guiOpen and "Close" or "Open"
    if guiOpen then UpdateProtectedList() end
end)

print("✅ AHM Script Loaded Successfully!")
print("🎮 Controls:")
print("   SHIFT = AUTO SWITCH (Head ↔ Torso) - 0.7 seconds each")
print("   ALT = HEAD mode")
print("   G = Toggle CLUTCH mode (ON/OFF) - Only works in vehicle!")
print("   ⏳ 3 second cooldown between mode switches")
print("   🚗 CLUTCH automatically turns OFF when you exit vehicle")
print("   💡 Press G again when you re-enter vehicle to turn CLUTCH ON")
print("   RightControl = Open/Close GUI")
print("   K = Toggle FOV Circle")
print("✅ SMART mode: ON by default - SHIFT and ALT work")
print("🧠 AI LEAD: OFF by default - Press 'AI LEAD' button to enable")
ApplyTheme()
