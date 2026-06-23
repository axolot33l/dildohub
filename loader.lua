-- Key System for Blahaj Hub
-- Uses Junkie SDK: https://jnkie.com

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "blahaj"
Junkie.identifier = "1101907"
Junkie.provider = "blahaj"

-- Game scripts config — {placeId, scriptUrl}
local gameScripts = {
    {97598239454123, "https://api.jnkie.com/api/v1/luascripts/public/9d7ce4a538a05c68052f8f6fc715ed1e8deefcf1646551c8f7784778bd973194/download"},
    {0, "https://raw.githubusercontent.com/axolot33l/dildohub/refs/heads/main/loader.lua"}, -- 0 = fallback for unlisted games
}

local function getScriptUrl()
    local pid = game.PlaceId
    for _, entry in next, gameScripts do
        if entry[1] == pid then
            return entry[2]
        end
    end
    for _, entry in next, gameScripts do
        if entry[1] == 0 then
            return entry[2]
        end
    end
    return nil
end

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Cozy dark theme colors (matching the hub)
local colors = {
    bg = Color3.fromRGB(16, 18, 28),
    surface = Color3.fromRGB(22, 26, 40),
    surface2 = Color3.fromRGB(26, 30, 46),
    accent = Color3.fromRGB(0, 200, 255),
    accentDim = Color3.fromRGB(0, 160, 210),
    text = Color3.fromRGB(210, 220, 235),
    textDim = Color3.fromRGB(140, 155, 180),
    textBright = Color3.fromRGB(255, 255, 255),
    success = Color3.fromRGB(60, 220, 150),
    error = Color3.fromRGB(255, 100, 100),
    inputBg = Color3.fromRGB(18, 20, 32),
    border = Color3.fromRGB(40, 50, 75),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlahajHub_KeySys"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = screenGui
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = colors.bg
main.BorderSizePixel = 0

local mainStroke = Instance.new("UIStroke")
mainStroke.Parent = main
mainStroke.Color = colors.border
mainStroke.Thickness = 1
mainStroke.Transparency = 0.3

local mainCorner = Instance.new("UICorner")
mainCorner.Parent = main
mainCorner.CornerRadius = UDim.new(0, 8)

-- Title bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Parent = main
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = colors.surface
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = titleBar
titleCorner.CornerRadius = UDim.new(0, 8)

local minimized = false
local fullSize = UDim2.new(0, 400, 0, 300)
local minSize = UDim2.new(0, 400, 0, 38)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -76, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Blahaj Hub  |  Key Validation"
titleLabel.TextColor3 = colors.textBright
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton")
minBtn.Parent = titleBar
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -62, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
minBtn.BorderSizePixel = 0
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(140, 180, 255)
minBtn.Font = Enum.Font.GothamMedium
minBtn.TextSize = 16
minBtn.AutoButtonColor = false

local minCorner = Instance.new("UICorner")
minCorner.Parent = minBtn
minCorner.CornerRadius = UDim.new(0, 4)

minBtn.MouseEnter:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 95) end)
minBtn.MouseLeave:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60) end)
-- minimize handler moved after content creation

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(140, 180, 255)
closeBtn.Font = Enum.Font.GothamMedium
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false

local closeCorner = Instance.new("UICorner")
closeCorner.Parent = closeBtn
closeCorner.CornerRadius = UDim.new(0, 4)

closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60); closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60); closeBtn.TextColor3 = Color3.fromRGB(140, 180, 255) end)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Draggable
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
userInput.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
userInput.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
    end
end)

-- Content
local content = Instance.new("Frame")
content.Parent = main
content.Size = UDim2.new(1, -24, 1, -50)
content.Position = UDim2.new(0, 12, 0, 44)
content.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Size = minimized and minSize or fullSize
    minBtn.Text = minimized and "+" or "-"
    content.Visible = not minimized
end)

local layout = Instance.new("UIListLayout")
layout.Parent = content
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Icon / Title area
local iconLabel = Instance.new("TextLabel")
iconLabel.Parent = content
iconLabel.Size = UDim2.new(1, 0, 0, 40)
iconLabel.BackgroundTransparency = 1
iconLabel.Text = "🔑"
iconLabel.TextColor3 = colors.textBright
iconLabel.Font = Enum.Font.GothamBold
iconLabel.TextSize = 32
iconLabel.TextYAlignment = Enum.TextYAlignment.Center
iconLabel.LayoutOrder = 1

local promptLabel = Instance.new("TextLabel")
promptLabel.Parent = content
promptLabel.Size = UDim2.new(1, 0, 0, 20)
promptLabel.BackgroundTransparency = 1
promptLabel.Text = "Enter your license key"
promptLabel.TextColor3 = colors.textDim
promptLabel.Font = Enum.Font.GothamMedium
promptLabel.TextSize = 13
promptLabel.TextYAlignment = Enum.TextYAlignment.Center
promptLabel.LayoutOrder = 2

-- Key input
local inputFrame = Instance.new("Frame")
inputFrame.Parent = content
inputFrame.Size = UDim2.new(1, 0, 0, 36)
inputFrame.BackgroundColor3 = colors.inputBg
inputFrame.BorderSizePixel = 0
inputFrame.LayoutOrder = 3

local inputCorner = Instance.new("UICorner")
inputCorner.Parent = inputFrame
inputCorner.CornerRadius = UDim.new(0, 6)

local inputStroke = Instance.new("UIStroke")
inputStroke.Parent = inputFrame
inputStroke.Color = colors.border
inputStroke.Thickness = 1
inputStroke.Transparency = 0.5

local keyBox = Instance.new("TextBox")
keyBox.Parent = inputFrame
keyBox.Size = UDim2.new(1, -16, 1, 0)
keyBox.Position = UDim2.new(0, 8, 0, 0)
keyBox.BackgroundTransparency = 1
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Paste your key here..."
keyBox.PlaceholderColor3 = colors.textDim
keyBox.Text = ""
keyBox.TextColor3 = colors.textBright
keyBox.Font = Enum.Font.GothamMedium
keyBox.TextSize = 13
keyBox.ClearTextOnFocus = false

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = content
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = colors.textDim
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.TextYAlignment = Enum.TextYAlignment.Center
statusLabel.LayoutOrder = 4

-- Button row
local btnFrame = Instance.new("Frame")
btnFrame.Parent = content
btnFrame.Size = UDim2.new(1, 0, 0, 34)
btnFrame.BackgroundTransparency = 1
btnFrame.LayoutOrder = 5

local validateBtn = Instance.new("TextButton")
validateBtn.Parent = btnFrame
validateBtn.Size = UDim2.new(0.48, 0, 1, 0)
validateBtn.Position = UDim2.new(0, 0, 0, 0)
validateBtn.BackgroundColor3 = colors.accent
validateBtn.BorderSizePixel = 0
validateBtn.Text = "Validate"
validateBtn.TextColor3 = colors.textBright
validateBtn.Font = Enum.Font.GothamBold
validateBtn.TextSize = 13
validateBtn.AutoButtonColor = false

local btnCorner = Instance.new("UICorner")
btnCorner.Parent = validateBtn
btnCorner.CornerRadius = UDim.new(0, 6)

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Parent = btnFrame
getKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
getKeyBtn.Position = UDim2.new(0.52, 0, 0, 0)
getKeyBtn.BackgroundColor3 = colors.surface2
getKeyBtn.BorderSizePixel = 0
getKeyBtn.Text = "Get a Key"
getKeyBtn.TextColor3 = colors.textDim
getKeyBtn.Font = Enum.Font.GothamMedium
getKeyBtn.TextSize = 13
getKeyBtn.AutoButtonColor = false

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.Parent = getKeyBtn
getKeyCorner.CornerRadius = UDim.new(0, 6)

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Parent = getKeyBtn
getKeyStroke.Color = colors.border
getKeyStroke.Thickness = 1
getKeyStroke.Transparency = 0.5

-- Hover effects
validateBtn.MouseEnter:Connect(function() validateBtn.BackgroundColor3 = colors.accentDim end)
validateBtn.MouseLeave:Connect(function() validateBtn.BackgroundColor3 = colors.accent end)
getKeyBtn.MouseEnter:Connect(function() getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60) end)
getKeyBtn.MouseLeave:Connect(function() getKeyBtn.BackgroundColor3 = colors.surface2 end)

-- Footer
local footerLabel = Instance.new("TextLabel")
footerLabel.Parent = content
footerLabel.Size = UDim2.new(1, 0, 0, 16)
footerLabel.BackgroundTransparency = 1
footerLabel.Text = "blahaj / 1101907"
footerLabel.TextColor3 = Color3.fromRGB(60, 75, 100)
footerLabel.Font = Enum.Font.GothamMedium
footerLabel.TextSize = 10
footerLabel.TextYAlignment = Enum.TextYAlignment.Center
footerLabel.LayoutOrder = 6

-- Logic
local validatedKey = nil
local function setStatus(text, isError)
    statusLabel.Text = text
    statusLabel.TextColor3 = isError and colors.error or colors.success
end

local function copyToClipboard(text)
    local fn = setclipboard or clipboard or toclipboard
    if fn then
        fn(text)
    end
end

getKeyBtn.MouseButton1Click:Connect(function()
    local link = Junkie.get_key_link()
    if link then
        copyToClipboard(link)
        setStatus("Link copied to clipboard! Get your key and paste it above.", false)
    else
        setStatus("Please wait 5 minutes between attempts.", true)
    end
end)

local maxAttempts = 5
local attempts = 0

validateBtn.MouseButton1Click:Connect(function()
    local userKey = keyBox.Text:match("^%s*(.-)%s*$")
    if not userKey or #userKey == 0 then
        setStatus("Please enter or paste a key.", true)
        return
    end
    attempts = attempts + 1
    setStatus("Validating...", false)
    local ok, validation = pcall(function() return Junkie.check_key(userKey) end)
    if not ok or not validation then
        setStatus("Connection error — try again.", true)
        return
    end
    if validation.valid then
        validatedKey = userKey
        setStatus("Key validated! Loading script...", false)
        getgenv().SCRIPT_KEY = validatedKey
        task.wait(0.5)
        screenGui:Destroy()
        -- Expiry monitor
        task.spawn(function()
            while task.wait(30) do
                local expiresAt = getgenv().JD_EXPIRES_AT
                if expiresAt and os.time() >= expiresAt then
                    pcall(function()
                        if player.Parent then
                            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
                        end
                    end)
                    break
                end
            end
        end)
        -- Load script for current game
        local scriptUrl = getScriptUrl()
        if scriptUrl then
            local ok, err = pcall(function() loadstring(game:HttpGet(scriptUrl))() end)
            if not ok then
                warn("Blahaj Hub: failed to load script — " .. tostring(err))
            end
        else
            warn("Blahaj Hub: no script configured for PlaceId " .. game.PlaceId)
        end
        return
    else
        local err = validation.message or "Invalid key"
        setStatus(err, true)
        if err == "KEY_EXPIRED" then
            setStatus("Key expired — get a new one.", true)
        elseif err == "HWID_BANNED" then
            player:Kick("Hardware banned")
            return
        elseif err == "HWID_MISMATCH" then
            setStatus("HWID limit reached.", true)
        end
        if attempts >= maxAttempts then
            setStatus("Too many failed attempts!", true)
            task.wait(1.5)
            screenGui:Destroy()
        end
    end
end)

-- Allow Enter to validate
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateBtn.MouseButton1Click:Fire()
    end
end)
