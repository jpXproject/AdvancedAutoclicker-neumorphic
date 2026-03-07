-- Advanced AutoClicker Script for Roblox (Lua)
-- Designed for execution with Velocity or similar Roblox executors
-- Features: Variable UI size, Neumorphic theme, Professional & User-Friendly
-- Includes: Click intervals, Click types, Repetitions, Cursor positions, Hotkeys, Record/Playback
-- Additional Roblox helpers: Auto-farm toggle, Click detection bypass simulation
-- UI Library: Uses a custom implementation inspired by modern UI libs (e.g., Rayfield/Kavo style)
-- Note: This script assumes executor support for mouse/keyboard simulation and UI drawing.
-- For best results, use with executors that have full input simulation (e.g., Synapse/Fluxus equivalents).

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Neumorphic Theme Colors
local Theme = {
    Background = Color3.fromRGB(230, 230, 230),
    Accent = Color3.fromRGB(200, 200, 200),
    Text = Color3.fromRGB(50, 50, 50),
    ShadowLight = Color3.fromRGB(255, 255, 255),
    ShadowDark = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(180, 180, 180)
}

-- UI Library (Simplified Neumorphic UI Builder)
local UI = {}
function UI:CreateWindow(title, size)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "AutoClickerUI"

    local Frame = Instance.new("Frame")
    Frame.Size = size or UDim2.new(0, 400, 0, 500)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -250)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Draggable = true
    Frame.Active = true

    -- Neumorphic Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.BackgroundTransparency = 1
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.Image = "rbxassetid://0" -- Placeholder for shadow, use blur or custom
    Shadow.ImageColor3 = Theme.ShadowDark
    Shadow.Parent = Frame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = Frame

    -- Resize Handle
    local ResizeCorner = Instance.new("TextButton")
    ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
    ResizeCorner.Position = UDim2.new(1, -20, 1, -20)
    ResizeCorner.BackgroundTransparency = 1
    ResizeCorner.Text = ""
    ResizeCorner.Parent = Frame
    local resizing = false
    ResizeCorner.MouseButton1Down:Connect(function()
        resizing = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if resizing then
            local mouse = UserInputService:GetMouseLocation()
            Frame.Size = UDim2.new(0, math.max(300, mouse.X - Frame.AbsolutePosition.X), 0, math.max(400, mouse.Y - Frame.AbsolutePosition.Y))
        end
    end)

    return Frame, ScreenGui
end

function UI:CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 100)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = parent

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Text = title
    SectionTitle.Size = UDim2.new(1, 0, 0, 20)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.TextColor3 = Theme.Accent
    SectionTitle.Font = Enum.Font.Gotham
    SectionTitle.Parent = SectionFrame

    return SectionFrame
end

function UI:CreateSlider(parent, title, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 30)
    SliderFrame.BackgroundColor3 = Theme.Accent
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    SliderFrame.CornerRadius = UDim.new(0, 8) -- Neumorphic rounded

    -- Add neumorphic inset shadow
    local Inset = Instance.new("UIGradient")
    -- Simulate neumorphic with gradient

    local Title = Instance.new("TextLabel")
    Title.Text = title
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Text
    Title.Parent = SliderFrame

    local Value = Instance.new("TextLabel")
    Value.Text = tostring(default)
    Value.Size = UDim2.new(0.5, 0, 1, 0)
    Value.BackgroundTransparency = 1
    Value.TextColor3 = Theme.Text
    Value.Parent = SliderFrame

    -- Slider logic (simplified)
    local sliding = false
    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if sliding then
            local pos = UserInputService:GetMouseLocation()
            local rel = math.clamp((pos.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * rel
            Value.Text = tostring(math.floor(val))
            callback(val)
        end
    end)

    return SliderFrame
end

function UI:CreateToggle(parent, title, default, callback)
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundColor3 = Theme.Accent
    ToggleFrame.Text = title .. (default and " ON" or " OFF")
    ToggleFrame.TextColor3 = Theme.Text
    ToggleFrame.Parent = parent

    local state = default
    ToggleFrame.MouseButton1Click:Connect(function()
        state = not state
        ToggleFrame.Text = title .. (state and " ON" or " OFF")
        callback(state)
    end)

    return ToggleFrame
end

function UI:CreateDropdown(parent, title, options, default, callback)
    local DropdownFrame = Instance.new("TextButton")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    DropdownFrame.BackgroundColor3 = Theme.Accent
    DropdownFrame.Text = title .. ": " .. default
    DropdownFrame.TextColor3 = Theme.Text
    DropdownFrame.Parent = parent

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, 0, 0, 100)
    ListFrame.Position = UDim2.new(0, 0, 1, 0)
    ListFrame.BackgroundColor3 = Theme.Background
    ListFrame.Visible = false
    ListFrame.Parent = DropdownFrame

    for _, opt in ipairs(options) do
        local OptButton = Instance.new("TextButton")
        OptButton.Size = UDim2.new(1, 0, 0, 20)
        OptButton.Text = opt
        OptButton.BackgroundColor3 = Theme.Accent
        OptButton.Parent = ListFrame
        OptButton.MouseButton1Click:Connect(function()
            DropdownFrame.Text = title .. ": " .. opt
            ListFrame.Visible = false
            callback(opt)
        end)
    end

    DropdownFrame.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible
    end)

    return DropdownFrame
end

function UI:CreateButton(parent, title, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.5, 0, 0, 30)
    Button.BackgroundColor3 = Theme.Accent
    Button.Text = title
    Button.TextColor3 = Theme.Text
    Button.Parent = parent
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Main Script Logic
local AutoClicker = {
    Running = false,
    Interval = {Hours = 0, Minutes = 0, Seconds = 0, Ms = 100},
    ClickType = "Left",
    ClickMode = "Single",
    Repetitions = "Infinite",
    RepCount = 0,
    CursorMode = "Dynamic",
    FixedPos = {X = 0, Y = 0},
    Hotkey = Enum.KeyCode.F6,
    Recording = false,
    RecordedActions = {},
    Playing = false,
    AntiDetect = false  -- Roblox helper: Simulate human-like clicks
}

-- Click Simulation (Executor-dependent; assumes virtual input)
local function SimulateClick(button, mode)
    -- Use mouse.click or similar; adjust for Velocity
    if AutoClicker.CursorMode == "Fixed" then
        mouse1click(AutoClicker.FixedPos.X, AutoClicker.FixedPos.Y) -- Pseudo-code, replace with executor's API
    else
        mouse1click() -- Dynamic
    end
    if mode == "Double" then wait(0.05) mouse1click() end
    if mode == "Triple" then wait(0.05) mouse1click() wait(0.05) mouse1click() end
    if AutoClicker.AntiDetect then
        wait(math.random(10, 50)/1000) -- Human-like delay
    end
end

local function GetIntervalMs()
    return (AutoClicker.Interval.Hours * 3600000) + (AutoClicker.Interval.Minutes * 60000) + (AutoClicker.Interval.Seconds * 1000) + AutoClicker.Interval.Ms
end

local function StartAutoClick()
    AutoClicker.Running = true
    spawn(function()
        local count = 0
        while AutoClicker.Running do
            SimulateClick(AutoClicker.ClickType, AutoClicker.ClickMode)
            count = count + 1
            if AutoClicker.Repetitions == "Limited" and count >= AutoClicker.RepCount then
                AutoClicker.Running = false
                break
            end
            wait(GetIntervalMs() / 1000)
        end
    end)
end

local function StopAutoClick()
    AutoClicker.Running = false
end

-- Recording
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if AutoClicker.Recording and input.UserInputType == Enum.UserInputType.MouseButton1 then
        table.insert(AutoClicker.RecordedActions, {Type = "Click", Pos = UserInputService:GetMouseLocation(), Time = tick()})
    elseif input.KeyCode == AutoClicker.Hotkey then
        if AutoClicker.Running then StopAutoClick() else StartAutoClick() end
    end
end)

local function StartRecording()
    AutoClicker.Recording = true
    AutoClicker.RecordedActions = {}
end

local function StopRecording()
    AutoClicker.Recording = false
end

local function PlayRecording()
    AutoClicker.Playing = true
    spawn(function()
        local startTime = tick()
        for _, action in ipairs(AutoClicker.RecordedActions) do
            while tick() - startTime < action.Time - startTime do wait() end
            mouse1click(action.Pos.X, action.Pos.Y)
        end
        AutoClicker.Playing = false
    end)
end

local function SaveRecording()
    local data = HttpService:JSONEncode(AutoClicker.RecordedActions)
    writefile("recording.json", data) -- Executor file access
end

local function LoadRecording()
    if isfile("recording.json") then
        AutoClicker.RecordedActions = HttpService:JSONDecode(readfile("recording.json"))
    end
end

-- Roblox Helpers
local function ToggleAntiDetect(state)
    AutoClicker.AntiDetect = state
end

-- Build UI
local Window, Gui = UI:CreateWindow("Grok AutoClicker [Hacker Mode]", UDim2.new(0, 400, 0, 500))

local IntervalSection = UI:CreateSection(Window, "Interval Klik")
UI:CreateSlider(IntervalSection, "Jam", 0, 23, AutoClicker.Interval.Hours, function(v) AutoClicker.Interval.Hours = v end)
UI:CreateSlider(IntervalSection, "Menit", 0, 59, AutoClicker.Interval.Minutes, function(v) AutoClicker.Interval.Minutes = v end)
UI:CreateSlider(IntervalSection, "Detik", 0, 59, AutoClicker.Interval.Seconds, function(v) AutoClicker.Interval.Seconds = v end)
UI:CreateSlider(IntervalSection, "Ms", 0, 999, AutoClicker.Interval.Ms, function(v) AutoClicker.Interval.Ms = v end)

local ClickOptionsSection = UI:CreateSection(Window, "Opsi Klik")
UI:CreateDropdown(ClickOptionsSection, "Tombol", {"Kiri", "Kanan", "Tengah"}, AutoClicker.ClickType, function(v) AutoClicker.ClickType = v end)
UI:CreateDropdown(ClickOptionsSection, "Jenis", {"Tunggal", "Ganda", "Triple"}, AutoClicker.ClickMode, function(v) AutoClicker.ClickMode = v end)

local RepSection = UI:CreateSection(Window, "Pengulangan")
UI:CreateDropdown(RepSection, "Mode", {"Tanpa Batas", "Jumlah"}, AutoClicker.Repetitions, function(v) AutoClicker.Repetitions = v end)
UI:CreateSlider(RepSection, "Jumlah", 1, 1000, AutoClicker.RepCount, function(v) AutoClicker.RepCount = v end)

local CursorSection = UI:CreateSection(Window, "Posisi Kursor")
UI:CreateDropdown(CursorSection, "Mode", {"Dinamis", "Fixed"}, AutoClicker.CursorMode, function(v) AutoClicker.CursorMode = v end)
UI:CreateSlider(CursorSection, "X", 0, 1920, AutoClicker.FixedPos.X, function(v) AutoClicker.FixedPos.X = v end)
UI:CreateSlider(CursorSection, "Y", 0, 1080, AutoClicker.FixedPos.Y, function(v) AutoClicker.FixedPos.Y = v end)

local HotkeySection = UI:CreateSection(Window, "Hotkey")
local HotkeyLabel = Instance.new("TextLabel")
HotkeyLabel.Text = "Current Key: F6"
HotkeyLabel.Parent = HotkeySection
UI:CreateButton(HotkeySection, "Ubah", function()
    HotkeyLabel.Text = "Press a key..."
    local conn = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            AutoClicker.Hotkey = input.KeyCode
            HotkeyLabel.Text = "Current Key: " .. input.KeyCode.Name
            conn:Disconnect()
        end
    end)
end)

local RecordSection = UI:CreateSection(Window, "Rekam & Putar")
UI:CreateButton(RecordSection, "REC", StartRecording)
UI:CreateButton(RecordSection, "STOP REC", StopRecording)
UI:CreateButton(RecordSection, "PLAY", PlayRecording)
UI:CreateButton(RecordSection, "SAVE", SaveRecording)
UI:CreateButton(RecordSection, "LOAD", LoadRecording)

local RobloxHelpersSection = UI:CreateSection(Window, "Roblox Helpers")
UI:CreateToggle(RobloxHelpersSection, "Anti-Detect (Human Clicks)", false, ToggleAntiDetect)
UI:CreateToggle(RobloxHelpersSection, "Auto-Farm (Click Loop)", false, function(state)
    if state then StartAutoClick() else StopAutoClick() end
end)

-- Status Label
local Status = Instance.new("TextLabel")
Status.Text = "READY"
Status.Size = UDim2.new(1, 0, 0, 30)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.Parent = Window

print("AutoClicker Loaded! UI should appear.")
