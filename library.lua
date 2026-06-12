local Library = {}
Library.__index = Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Config = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        BackgroundAlt = Color3.fromRGB(28, 28, 35),
        Header = Color3.fromRGB(15, 15, 20),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(50, 150, 255),
        AccentHover = Color3.fromRGB(70, 170, 255),
        Border = Color3.fromRGB(40, 40, 50),
        SliderFill = Color3.fromRGB(50, 150, 255),
        SliderBackground = Color3.fromRGB(60, 60, 70),
        ToggleOn = Color3.fromRGB(50, 200, 100),
        ToggleOff = Color3.fromRGB(80, 80, 90),
        Dropdown = Color3.fromRGB(30, 30, 38),
        DropdownHover = Color3.fromRGB(40, 40, 50),
        Button = Color3.fromRGB(35, 35, 45),
        ButtonHover = Color3.fromRGB(45, 45, 55),
        Notification = Color3.fromRGB(25, 25, 32),
        Success = Color3.fromRGB(50, 200, 100),
        Warning = Color3.fromRGB(255, 170, 50),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    UIKeybind = Enum.KeyCode.RightShift
}

local Keybinds = {}
local Notifications = {}
local Windows = {}

local function Create(class, properties)
    local obj = Instance.new(class)
    for k, v in pairs(properties or {}) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, info, properties)
    local tween = TweenService:Create(obj, info, properties)
    tween:Play()
    return tween
end

local function NewTweenInfo(duration, style, direction)
    return TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
end

local function Draggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function Resizable(frame, minSize, maxSize)
    local handle = Create("TextButton", {
        Name = "ResizeHandle",
        Parent = frame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 100
    })
    local resizing, startPos, startSize
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startPos = Vector2.new(Mouse.X, Mouse.Y)
            startSize = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    UserInputService.InputChanged:Connect(function()
        if resizing then
            local delta = Vector2.new(Mouse.X, Mouse.Y) - startPos
            local newSize = startSize + delta
            newSize = Vector2.new(math.clamp(newSize.X, minSize.X, maxSize.X), math.clamp(newSize.Y, minSize.Y, maxSize.Y))
            frame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
        end
    end)
end

local function CreateColorPicker(callback)
    local screenGui = Create("ScreenGui", {
        Parent = Player.PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    local frame = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 350, 0, 400),
        Position = UDim2.new(0.5, -175, 0.5, -200),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 8)})
    Create("UIPadding", {Parent = frame, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    local header = Create("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = header, Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = "Color Picker", TextColor3 = Config.Colors.Text, TextSize = 14, Font = Config.FontBold, TextXAlignment = Enum.TextXAlignment.Left})
    local closeBtn = Create("TextButton", {Parent = header, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = "✕", TextColor3 = Config.Colors.Text, TextSize = 16, Font = Config.FontBold})
    local colorBox = Create("ImageButton", {Parent = frame, Size = UDim2.new(1, 0, 0, 200), Position = UDim2.new(0, 0, 0, 40), Image = "rbxassetid://5129684636", ImageColor3 = Color3.new(1, 1, 1), BackgroundColor3 = Color3.new(1, 0, 0), BorderSizePixel = 0})
    Create("UICorner", {Parent = colorBox, CornerRadius = UDim.new(0, 6)})
    local hueSlider = Create("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 250), BackgroundColor3 = Config.Colors.BackgroundAlt, BorderSizePixel = 0})
    Create("UICorner", {Parent = hueSlider, CornerRadius = UDim.new(0, 6)})
    local hueBar = Create("ImageLabel", {Parent = hueSlider, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Image = "rbxassetid://5129684636", ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(0, 0, 0, 0), BorderSizePixel = 0})
    local hueKnob = Create("Frame", {Parent = hueSlider, Size = UDim2.new(0, 12, 0, 16), Position = UDim2.new(0, 8, 0.5, -8), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 10})
    Create("UICorner", {Parent = hueKnob, CornerRadius = UDim.new(0, 3)})
    Create("UIStroke", {Parent = hueKnob, Color = Color3.new(0, 0, 0), Thickness = 1})
    local rgbFrame = Create("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 280), BackgroundTransparency = 1})
    local function CreateColorInput(name, y, color)
        local f = Create("Frame", {Parent = rgbFrame, Size = UDim2.new(0.32, 0, 1, 0), Position = UDim2.new(y, 0, 0, 0), BackgroundTransparency = 1})
        Create("TextLabel", {Parent = f, Size = UDim2.new(0, 30, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Config.Colors.TextDim, TextSize = 12, Font = Config.Font, TextXAlignment = Enum.TextXAlignment.Left})
        local tb = Create("TextBox", {Parent = f, Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, 35, 0, 0), BackgroundColor3 = Config.Colors.BackgroundAlt, Text = "255", TextColor3 = Config.Colors.Text, TextSize = 12, Font = Config.Font, TextXAlignment = Enum.TextXAlignment.Center, BorderSizePixel = 0, ClipsDescendants = true})
        Create("UICorner", {Parent = tb, CornerRadius = UDim.new(0, 4)})
        return tb
    end
    local rInput = CreateColorInput("R", 0)
    local gInput = CreateColorInput("G", 0.34)
    local bInput = CreateColorInput("B", 0.68)
    local preview = Create("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 320), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0})
    Create("UICorner", {Parent = preview, CornerRadius = UDim.new(0, 6)})
    local confirmBtn = Create("TextButton", {Parent = frame, Size = UDim2.new(0.48, 0, 0, 35), Position = UDim2.new(0, 0, 0, 365), BackgroundColor3 = Config.Colors.Accent, Text = "Confirm", TextColor3 = Config.Colors.Text, TextSize = 12, Font = Config.FontBold, BorderSizePixel = 0})
    local cancelBtn = Create("TextButton", {Parent = frame, Size = UDim2.new(0.48, 0, 0, 35), Position = UDim2.new(0.52, 0, 0, 365), BackgroundColor3 = Config.Colors.Button, Text = "Cancel", TextColor3 = Config.Colors.Text, TextSize = 12, Font = Config.FontBold, BorderSizePixel = 0})
    Create("UICorner", {Parent = confirmBtn, CornerRadius = UDim.new(0, 6)})
    Create("UICorner", {Parent = cancelBtn, CornerRadius = UDim.new(0, 6)})
    Draggable(frame, header)
    local currentH, currentS, currentV = 0, 1, 1
    local function UpdateColor()
        local color = Color3.fromHSV(currentH, currentS, currentV)
        colorBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
        preview.BackgroundColor3 = color
        rInput.Text = tostring(math.floor(color.R * 255))
        gInput.Text = tostring(math.floor(color.G * 255))
        bInput.Text = tostring(math.floor(color.B * 255))
    end
    local draggingHue, draggingColor
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
        end
    end)
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)
    colorBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingColor = true
        end
    end)
    colorBox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingColor = false
        end
    end)
    UserInputService.InputChanged:Connect(function()
        if draggingHue then
            local absSize = hueSlider.AbsoluteSize.X - 16
            local pos = math.clamp((Mouse.X - hueSlider.AbsolutePosition.X - 8), 0, absSize)
            currentH = pos / absSize
            hueKnob.Position = UDim2.new(0, 8 + pos, 0.5, -8)
            UpdateColor()
        end
        if draggingColor then
            local absPos = colorBox.AbsolutePosition
            local absSize = colorBox.AbsoluteSize
            local x = math.clamp((Mouse.X - absPos.X), 0, absSize.X)
            local y = math.clamp((Mouse.Y - absPos.Y), 0, absSize.Y)
            currentS = x / absSize.X
            currentV = 1 - (y / absSize.Y)
            UpdateColor()
        end
    end)
    local function Close()
        screenGui:Destroy()
    end
    confirmBtn.MouseButton1Click:Connect(function()
        callback(Color3.fromHSV(currentH, currentS, currentV))
        Close()
    end)
    cancelBtn.MouseButton1Click:Connect(Close)
    closeBtn.MouseButton1Click:Connect(Close)
    UpdateColor()
end

function Library:CreateWindow(name)
    local window = {}
    window.Name = name
    window.Tabs = {}
    window.KeybindListOpen = true
    local ScreenGui = Create("ScreenGui", {
        Parent = Player.PlayerGui,
        Name = name,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 650, 0, 450),
        Position = UDim2.new(0.5, -325, 0.5, -225),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
    Create("UIPadding", {Parent = MainFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    local Header = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1
    })
    local Title = Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Config.Colors.Text,
        TextSize = 16,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local MinimizeBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = Config.Colors.Text,
        TextSize = 18,
        Font = Config.FontBold,
        ZIndex = 10
    })
    local CloseBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Config.Colors.Text,
        TextSize = 16,
        Font = Config.FontBold,
        ZIndex = 10
    })
    local ToggleKeybindBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -105, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "⌨",
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        ZIndex = 10
    })
    local KeybindList = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 180, 1, -50),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Config.Colors.BackgroundAlt,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = KeybindList, CornerRadius = UDim.new(0, 8)})
    Create("UIPadding", {Parent = KeybindList, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
    local KeybindListHeader = Create("TextLabel", {
        Parent = KeybindList,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Keybinds",
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local KeybindListCanvas = Create("ScrollingFrame", {
        Parent = KeybindList,
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        BorderSizePixel = 0,
        ScrollBarImageColor3 = Config.Colors.TextDim
    })
    Create("UIListLayout", {Parent = KeybindListCanvas, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local ContentContainer = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -190, 1, -50),
        Position = UDim2.new(0, 190, 0, 45),
        BackgroundTransparency = 1
    })
    local TabContainer = Create("Frame", {
        Parent = ContentContainer,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1
    })
    local TabListLayout = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)})
    local TabContentContainer = Create("Frame", {
        Parent = ContentContainer,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })
    Draggable(MainFrame, Header)
    Resizable(MainFrame, Vector2.new(400, 300), Vector2.new(900, 600))
    local uiVisible = true
    local function ToggleUI()
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
    end
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.UIKeybind then
            ToggleUI()
        end
    end)
    CloseBtn.MouseButton1Click:Connect(ToggleUI)
    MinimizeBtn.MouseButton1Click:Connect(function()
        local isMinimized = MainFrame.Size.Y.Offset == 50
        MainFrame:TweenSize(UDim2.new(0, 650, 0, isMinimized and 450 or 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end)
    ToggleKeybindBtn.MouseButton1Click:Connect(function()
        window.KeybindListOpen = not window.KeybindListOpen
        KeybindList.Visible = window.KeybindListOpen
        if window.KeybindListOpen then
            ContentContainer.Position = UDim2.new(0, 190, 0, 45)
            ContentContainer.Size = UDim2.new(1, -190, 1, -50)
        else
            ContentContainer.Position = UDim2.new(0, 0, 0, 45)
            ContentContainer.Size = UDim2.new(1, 0, 1, -50)
        end
    end)
    local function AddKeybindToList(name, keybind)
        local keybindFrame = Create("Frame", {
            Parent = KeybindListCanvas,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Config.Colors.Background,
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = keybindFrame, CornerRadius = UDim.new(0, 4)})
        local keybindName = Create("TextLabel", {
            Parent = keybindFrame,
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Colors.Text,
            TextSize = 11,
            Font = Config.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
        Create("UIPadding", {Parent = keybindName, PaddingLeft = UDim.new(0, 6)})
        local keybindLabel = Create("TextLabel", {
            Parent = keybindFrame,
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -55, 0.5, -10),
            BackgroundColor3 = Config.Colors.Accent,
            Text = keybind.Name,
            TextColor3 = Config.Colors.Text,
            TextSize = 10,
            Font = Config.FontBold,
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = keybindLabel, CornerRadius = UDim.new(0, 3)})
        return keybindFrame
    end
    function window:CreateTab(name)
        local tab = {}
        tab.Name = name
        tab.Sections = {}
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = Config.Colors.BackgroundAlt,
            Text = name,
            TextColor3 = Config.Colors.TextDim,
            TextSize = 13,
            Font = Config.FontBold,
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 6)})
        local TabPage = Create("ScrollingFrame", {
            Parent = TabContentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Config.Colors.BackgroundAlt,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Config.Colors.TextDim,
            Visible = false
        })
        Create("UICorner", {Parent = TabPage, CornerRadius = UDim.new(0, 8)})
        Create("UIPadding", {Parent = TabPage, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        Create("UIListLayout", {Parent = TabPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        local function SelectTab()
            for _, t in pairs(window.Tabs) do
                t.Button.BackgroundColor3 = Config.Colors.BackgroundAlt
                t.Button.TextColor3 = Config.Colors.TextDim
                t.Page.Visible = false
            end
            TabButton.BackgroundColor3 = Config.Colors.Accent
            TabButton.TextColor3 = Config.Colors.Text
            TabPage.Visible = true
        end
        TabButton.MouseButton1Click:Connect(SelectTab)
        if #window.Tabs == 0 then
            SelectTab()
        end
        function tab:CreateSection(name)
            local section = {}
            section.Name = name
            section.Elements = {}
            local SectionFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            local SectionTitle = Create("TextLabel", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Config.Colors.Accent,
                TextSize = 12,
                Font = Config.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local SectionContent = Create("Frame", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = SectionContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
            local function AddElement(elementFrame)
                elementFrame.Parent = SectionContent
                table.insert(section.Elements, elementFrame)
                section:UpdateSize()
            end
            function section:UpdateSize()
                local totalHeight = 30
                for _, el in pairs(SectionContent:GetChildren()) do
                    if el:IsA("GuiObject") and el.Visible then
                        totalHeight = totalHeight + el.AbsoluteSize.Y + 8
                    end
                end
                SectionFrame.Size = UDim2.new(1, 0, 0, totalHeight)
                TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y + 20)
            end
            function section:CreateButton(name, callback)
                local button = {}
                button.Name = name
                button.Callback = callback or function() end
                button.Keybind = {Key = Enum.KeyCode.Unknown, Mode = "Toggle"}
                local ButtonFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
                local Button = Create("TextButton", {
                    Parent = ButtonFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Config.Colors.Button,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.FontBold,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 6)})
                local KeybindDisplay = Create("TextLabel", {
                    Parent = ButtonFrame,
                    Size = UDim2.new(0, 70, 0, 24),
                    Position = UDim2.new(1, -75, 0.5, -12),
                    BackgroundColor3 = Config.Colors.BackgroundAlt,
                    Text = "Unbound",
                    TextColor3 = Config.Colors.TextDim,
                    TextSize = 11,
                    Font = Config.Font,
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                Create("UICorner", {Parent = KeybindDisplay, CornerRadius = UDim.new(0, 4)})
                AddElement(ButtonFrame)
                local RightClickMenu
                local function CloseRightClickMenu()
                    if RightClickMenu then
                        RightClickMenu:Destroy()
                        RightClickMenu = nil
                    end
                end
                Button.MouseButton1Click:Connect(function()
                    button.Callback()
                end)
                Button.MouseButton2Click:Connect(function()
                    CloseRightClickMenu()
                    RightClickMenu = Create("Frame", {
                        Parent = ScreenGui,
                        Size = UDim2.new(0, 220, 0, 200),
                        Position = UDim2.new(0, Mouse.X + 10, 0, Mouse.Y + 10),
                        BackgroundColor3 = Config.Colors.Background,
                        BorderSizePixel = 0,
                        ZIndex = 1000
                    })
                    Create("UICorner", {Parent = RightClickMenu, CornerRadius = UDim.new(0, 8)})
                    Create("UIPadding", {Parent = RightClickMenu, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
                    Create("UIListLayout", {Parent = RightClickMenu, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
                    local KeybindLabel = Create("TextLabel", {
                        Parent = RightClickMenu,
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        Text = "Keybind",
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.FontBold,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    local KeybindInput = Create("TextBox", {
                        Parent = RightClickMenu,
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundColor3 = Config.Colors.BackgroundAlt,
                        Text = button.Keybind.Key ~= Enum.KeyCode.Unknown and button.Keybind.Key.Name or "Click to set",
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.Font,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BorderSizePixel = 0,
                        ClearTextOnFocus = false
                    })
                    Create("UICorner", {Parent = KeybindInput, CornerRadius = UDim.new(0, 6)})
                    local ModeLabel = Create("TextLabel", {
                        Parent = RightClickMenu,
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        Text = "Mode",
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.FontBold,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    local ModeContainer = Create("Frame", {
                        Parent = RightClickMenu,
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundTransparency = 1
                    })
                    local function CreateModeOption(text, pos, mode)
                        local opt = Create("TextButton", {
                            Parent = ModeContainer,
                            Size = UDim2.new(0.32, 0, 1, 0),
                            Position = UDim2.new(pos, 0, 0, 0),
                            BackgroundColor3 = button.Keybind.Mode == mode and Config.Colors.Accent or Config.Colors.BackgroundAlt,
                            Text = text,
                            TextColor3 = Config.Colors.Text,
                            TextSize = 11,
                            Font = Config.Font,
                            BorderSizePixel = 0
                        })
                        Create("UICorner", {Parent = opt, CornerRadius = UDim.new(0, 4)})
                        opt.MouseButton1Click:Connect(function()
                            button.Keybind.Mode = mode
                            for _, child in pairs(ModeContainer:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child.BackgroundColor3 = Config.Colors.BackgroundAlt
                                end
                            end
                            opt.BackgroundColor3 = Config.Colors.Accent
                        end)
                    end
                    CreateModeOption("Toggle", 0, "Toggle")
                    CreateModeOption("Hold", 0.34, "Hold")
                    CreateModeOption("Always", 0.68, "Always")
                    local ClearBtn = Create("TextButton", {
                        Parent = RightClickMenu,
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Config.Colors.Error,
                        Text = "Clear Keybind",
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.FontBold,
                        BorderSizePixel = 0
                    })
                    Create("UICorner", {Parent = ClearBtn, CornerRadius = UDim.new(0, 4)})
                    local inputConnection
                    KeybindInput.Focused:Connect(function()
                        KeybindInput.Text = "Press a key..."
                        KeybindInput.TextColor3 = Config.Colors.Accent
                        inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                                button.Keybind.Key = input.KeyCode
                                KeybindDisplay.Text = input.KeyCode.Name
                                KeybindDisplay.TextColor3 = Config.Colors.Text
                                KeybindInput.Text = input.KeyCode.Name
                                KeybindInput.TextColor3 = Config.Colors.Text
                                KeybindListCanvas:ClearAllChildren()
                                AddKeybindToList(name, button.Keybind)
                                task.wait()
                                KeybindInput:ReleaseFocus()
                            end
                        end)
                    end)
                    KeybindInput.FocusLost:Connect(function()
                        if inputConnection then
                            inputConnection:Disconnect()
                        end
                        KeybindInput.Text = button.Keybind.Key ~= Enum.KeyCode.Unknown and button.Keybind.Key.Name or "Click to set"
                        KeybindInput.TextColor3 = Config.Colors.Text
                    end)
                    ClearBtn.MouseButton1Click:Connect(function()
                        button.Keybind.Key = Enum.KeyCode.Unknown
                        KeybindDisplay.Text = "Unbound"
                        KeybindDisplay.TextColor3 = Config.Colors.TextDim
                        KeybindInput.Text = "Click to set"
                        KeybindListCanvas:ClearAllChildren()
                    end)
                    UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            CloseRightClickMenu()
                        end
                    end)
                end)
                local keybindListEntry = AddKeybindToList(name, button.Keybind)
                local keyHeld = false
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode == button.Keybind.Key then
                        if button.Keybind.Mode == "Toggle" then
                            button.Callback()
                        elseif button.Keybind.Mode == "Hold" then
                            keyHeld = true
                            button.Callback(true)
                        elseif button.Keybind.Mode == "Always" then
                        end
                    end
                end)
                UserInputService.InputEnded:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode == button.Keybind.Key then
                        if button.Keybind.Mode == "Hold" and keyHeld then
                            keyHeld = false
                            button.Callback(false)
                        end
                    end
                end)
                return button
            end
            function section:CreateToggle(name, default, callback)
                local toggle = {}
                toggle.Name = name
                toggle.Value = default or false
                toggle.Callback = callback or function() end
                local ToggleFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
                local ToggleLabel = Create("TextLabel", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(1, -70, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local ToggleContainer = Create("Frame", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(0, 50, 0, 26),
                    Position = UDim2.new(1, -50, 0.5, -13),
                    BackgroundColor3 = toggle.Value and Config.Colors.ToggleOn or Config.Colors.ToggleOff,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = ToggleContainer, CornerRadius = UDim.new(0, 13)})
                local ToggleKnob = Create("Frame", {
                    Parent = ToggleContainer,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 3, 0.5, -10),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = ToggleKnob, CornerRadius = UDim.new(0, 10)})
                local ToggleButton = Create("TextButton", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 10
                })
                AddElement(ToggleFrame)
                local function UpdateToggle()
                    Tween(ToggleContainer, NewTweenInfo(0.2), {BackgroundColor3 = toggle.Value and Config.Colors.ToggleOn or Config.Colors.ToggleOff})
                    Tween(ToggleKnob, NewTweenInfo(0.2), {Position = UDim2.new(0, toggle.Value and 27 or 3, 0.5, -10)})
                end
                UpdateToggle()
                ToggleButton.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    UpdateToggle()
                    toggle.Callback(toggle.Value)
                end)
                return toggle
            end
            function section:CreateSlider(name, min, max, default, callback)
                local slider = {}
                slider.Name = name
                slider.Value = default or min
                slider.Min = min
                slider.Max = max
                slider.Callback = callback or function() end
                local SliderFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundTransparency = 1})
                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, -60, 0, 25),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local SliderValue = Create("TextBox", {
                    Parent = SliderFrame,
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundColor3 = Config.Colors.BackgroundAlt,
                    Text = tostring(slider.Value),
                    TextColor3 = Config.Colors.Accent,
                    TextSize = 12,
                    Font = Config.FontBold,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = SliderValue, CornerRadius = UDim.new(0, 4)})
                local SliderBackground = Create("Frame", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 35),
                    BackgroundColor3 = Config.Colors.SliderBackground,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = SliderBackground, CornerRadius = UDim.new(0, 4)})
                local SliderFill = Create("Frame", {
                    Parent = SliderBackground,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Config.Colors.SliderFill,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(0, 4)})
                local SliderKnob = Create("Frame", {
                    Parent = SliderBackground,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 0, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 10
                })
                Create("UICorner", {Parent = SliderKnob, CornerRadius = UDim.new(0, 9)})
                Create("UIStroke", {Parent = SliderKnob, Color = Config.Colors.SliderFill, Thickness = 2})
                AddElement(SliderFrame)
                local function UpdateSlider()
                    local percent = (slider.Value - slider.Min) / (slider.Max - slider.Min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percent, -9, 0.5, -9)
                    SliderValue.Text = tostring(math.round(slider.Value * 100) / 100)
                end
                UpdateSlider()
                local dragging = false
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                SliderBackground.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function()
                    if dragging then
                        local absSize = SliderBackground.AbsoluteSize.X
                        local percent = math.clamp((Mouse.X - SliderBackground.AbsolutePosition.X) / absSize, 0, 1)
                        slider.Value = slider.Min + (percent * (slider.Max - slider.Min))
                        UpdateSlider()
                        slider.Callback(slider.Value)
                    end
                end)
                SliderValue.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        local num = tonumber(SliderValue.Text)
                        if num then
                            slider.Value = math.clamp(num, slider.Min, slider.Max)
                            UpdateSlider()
                            slider.Callback(slider.Value)
                        end
                    end
                end)
                return slider
            end
            function section:CreateDropdown(name, options, default, callback)
                local dropdown = {}
                dropdown.Name = name
                dropdown.Value = default or options[1]
                dropdown.Callback = callback or function() end
                dropdown.Open = false
                local DropdownFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
                local DropdownLabel = Create("TextLabel", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 12,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local DropdownContainer = Create("TextButton", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 38),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Config.Colors.Dropdown,
                    Text = "",
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = DropdownContainer, CornerRadius = UDim.new(0, 6)})
                local DropdownValue = Create("TextLabel", {
                    Parent = DropdownContainer,
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = dropdown.Value,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                Create("UIPadding", {Parent = DropdownValue, PaddingLeft = UDim.new(0, 10)})
                local DropdownArrow = Create("TextLabel", {
                    Parent = DropdownContainer,
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Config.Colors.TextDim,
                    TextSize = 10,
                    Font = Config.FontBold
                })
                local DropdownList = Create("Frame", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 62),
                    BackgroundColor3 = Config.Colors.Dropdown,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = DropdownList, CornerRadius = UDim.new(0, 6)})
                Create("UIListLayout", {Parent = DropdownList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                local optionButtons = {}
                for _, option in ipairs(options) do
                    local OptionButton = Create("TextButton", {
                        Parent = DropdownList,
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = Config.Colors.Dropdown,
                        Text = option,
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0
                    })
                    Create("UIPadding", {Parent = OptionButton, PaddingLeft = UDim.new(0, 10)})
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundColor3 = Config.Colors.DropdownHover
                    end)
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundColor3 = Config.Colors.Dropdown
                    end)
                    OptionButton.MouseButton1Click:Connect(function()
                        dropdown.Value = option
                        DropdownValue.Text = option
                        dropdown.Callback(option)
                        dropdown:Toggle()
                    end)
                    table.insert(optionButtons, OptionButton)
                end
                AddElement(DropdownFrame)
                function dropdown:Toggle()
                    dropdown.Open = not dropdown.Open
                    local listHeight = #options * 34 + (#options - 1) * 2
                    Tween(DropdownList, NewTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, dropdown.Open and listHeight or 0)})
                    Tween(DropdownArrow, NewTweenInfo(0.2), {Rotation = dropdown.Open and 180 or 0})
                end
                DropdownContainer.MouseButton1Click:Connect(function()
                    dropdown:Toggle()
                end)
                return dropdown
            end
            function section:CreateMultiDropdown(name, options, callback)
                local multiselect = {}
                multiselect.Name = name
                multiselect.Values = {}
                multiselect.Callback = callback or function() end
                multiselect.Open = false
                for _, opt in ipairs(options) do
                    multiselect.Values[opt] = false
                end
                local MultiFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
                local MultiLabel = Create("TextLabel", {
                    Parent = MultiFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 12,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local MultiContainer = Create("TextButton", {
                    Parent = MultiFrame,
                    Size = UDim2.new(1, 0, 0, 38),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Config.Colors.Dropdown,
                    Text = "",
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = MultiContainer, CornerRadius = UDim.new(0, 6)})
                local MultiValue = Create("TextLabel", {
                    Parent = MultiContainer,
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "None selected",
                    TextColor3 = Config.Colors.TextDim,
                    TextSize = 12,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })
                Create("UIPadding", {Parent = MultiValue, PaddingLeft = UDim.new(0, 10)})
                local MultiArrow = Create("TextLabel", {
                    Parent = MultiContainer,
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Config.Colors.TextDim,
                    TextSize = 10,
                    Font = Config.FontBold
                })
                local MultiList = Create("Frame", {
                    Parent = MultiFrame,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 62),
                    BackgroundColor3 = Config.Colors.Dropdown,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = MultiList, CornerRadius = UDim.new(0, 6)})
                Create("UIListLayout", {Parent = MultiList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                local function UpdateText()
                    local selected = {}
                    for opt, val in pairs(multiselect.Values) do
                        if val then
                            table.insert(selected, opt)
                        end
                    end
                    if #selected == 0 then
                        MultiValue.Text = "None selected"
                        MultiValue.TextColor3 = Config.Colors.TextDim
                    elseif #selected == #options then
                        MultiValue.Text = "All selected"
                        MultiValue.TextColor3 = Config.Colors.Accent
                    else
                        MultiValue.Text = table.concat(selected, ", ")
                        MultiValue.TextColor3 = Config.Colors.Text
                    end
                end
                for _, option in ipairs(options) do
                    local OptionFrame = Create("TextButton", {
                        Parent = MultiList,
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = Config.Colors.Dropdown,
                        Text = "",
                        BorderSizePixel = 0
                    })
                    local OptionLabel = Create("TextLabel", {
                        Parent = OptionFrame,
                        Size = UDim2.new(1, -40, 1, 0),
                        BackgroundTransparency = 1,
                        Text = option,
                        TextColor3 = Config.Colors.Text,
                        TextSize = 12,
                        Font = Config.Font,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    Create("UIPadding", {Parent = OptionLabel, PaddingLeft = UDim.new(0, 10)})
                    local OptionBox = Create("Frame", {
                        Parent = OptionFrame,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(1, -28, 0.5, -9),
                        BackgroundColor3 = Config.Colors.BackgroundAlt,
                        BorderSizePixel = 0
                    })
                    Create("UICorner", {Parent = OptionBox, CornerRadius = UDim.new(0, 3)})
                    local OptionCheck = Create("TextLabel", {
                        Parent = OptionBox,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "✓",
                        TextColor3 = Config.Colors.ToggleOn,
                        TextSize = 14,
                        Font = Config.FontBold,
                        Visible = false
                    })
                    OptionFrame.MouseEnter:Connect(function()
                        OptionFrame.BackgroundColor3 = Config.Colors.DropdownHover
                    end)
                    OptionFrame.MouseLeave:Connect(function()
                        OptionFrame.BackgroundColor3 = Config.Colors.Dropdown
                    end)
                    OptionFrame.MouseButton1Click:Connect(function()
                        multiselect.Values[option] = not multiselect.Values[option]
                        OptionCheck.Visible = multiselect.Values[option]
                        OptionBox.BackgroundColor3 = multiselect.Values[option] and Config.Colors.ToggleOn or Config.Colors.BackgroundAlt
                        UpdateText()
                        multiselect.Callback(multiselect.Values)
                    end)
                end
                AddElement(MultiFrame)
                function multiselect:Toggle()
                    multiselect.Open = not multiselect.Open
                    local listHeight = #options * 34 + (#options - 1) * 2
                    Tween(MultiList, NewTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, multiselect.Open and listHeight or 0)})
                    Tween(MultiArrow, NewTweenInfo(0.2), {Rotation = multiselect.Open and 180 or 0})
                end
                MultiContainer.MouseButton1Click:Connect(function()
                    multiselect:Toggle()
                end)
                UpdateText()
                return multiselect
            end
            function section:CreateColorPicker(name, default, callback)
                local colorpicker = {}
                colorpicker.Name = name
                colorpicker.Value = default or Color3.new(1, 1, 1)
                colorpicker.Callback = callback or function() end
                local ColorFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
                local ColorLabel = Create("TextLabel", {
                    Parent = ColorFrame,
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local ColorDisplay = Create("ImageButton", {
                    Parent = ColorFrame,
                    Size = UDim2.new(0, 40, 0, 28),
                    Position = UDim2.new(1, -40, 0.5, -14),
                    Image = "",
                    BackgroundColor3 = colorpicker.Value,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = ColorDisplay, CornerRadius = UDim.new(0, 6)})
                Create("UIStroke", {Parent = ColorDisplay, Color = Config.Colors.Border, Thickness = 1})
                AddElement(ColorFrame)
                ColorDisplay.MouseButton1Click:Connect(function()
                    CreateColorPicker(function(color)
                        colorpicker.Value = color
                        ColorDisplay.BackgroundColor3 = color
                        colorpicker.Callback(color)
                    end)
                end)
                return colorpicker
            end
            function section:CreateTextBox(name, default, callback)
                local textbox = {}
                textbox.Name = name
                textbox.Value = default or ""
                textbox.Callback = callback or function() end
                local TextFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundTransparency = 1})
                local TextLabel = Create("TextLabel", {
                    Parent = TextFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 12,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local TextInput = Create("TextBox", {
                    Parent = TextFrame,
                    Size = UDim2.new(1, 0, 0, 35),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Config.Colors.BackgroundAlt,
                    Text = textbox.Value,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    PlaceholderText = "Enter text...",
                    PlaceholderColor3 = Config.Colors.TextDim
                })
                Create("UICorner", {Parent = TextInput, CornerRadius = UDim.new(0, 6)})
                Create("UIPadding", {Parent = TextInput, PaddingLeft = UDim.new(0, 10)})
                AddElement(TextFrame)
                TextInput.FocusLost:Connect(function(enterPressed)
                    textbox.Value = TextInput.Text
                    textbox.Callback(textbox.Value, enterPressed)
                end)
                return textbox
            end
            function section:CreateLabel(name)
                local label = {}
                label.Name = name
                local LabelFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1})
                local LabelText = Create("TextLabel", {
                    Parent = LabelFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.TextDim,
                    TextSize = 12,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                AddElement(LabelFrame)
                return label
            end
            table.insert(tab.Sections, section)
            return section
        end
        table.insert(window.Tabs, {Name = name, Button = TabButton, Page = TabPage, Tab = tab})
        local SettingsTab = window:CreateTab("Settings")
        local GeneralSection = SettingsTab:CreateSection("General")
        GeneralSection:CreateButton("Reset UI Position", function()
            MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
        end)
        GeneralSection:CreateButton("Reset Colors", function()
            Config.Colors.Background = Color3.fromRGB(20, 20, 25)
            Config.Colors.BackgroundAlt = Color3.fromRGB(28, 28, 35)
            Config.Colors.Header = Color3.fromRGB(15, 15, 20)
            Config.Colors.Text = Color3.fromRGB(255, 255, 255)
            Config.Colors.TextDim = Color3.fromRGB(180, 180, 180)
            Config.Colors.Accent = Color3.fromRGB(50, 150, 255)
            Config.Colors.Border = Color3.fromRGB(40, 40, 50)
            Config.Colors.SliderFill = Color3.fromRGB(50, 150, 255)
            Config.Colors.SliderBackground = Color3.fromRGB(60, 60, 70)
            Config.Colors.ToggleOn = Color3.fromRGB(50, 200, 100)
            Config.Colors.ToggleOff = Color3.fromRGB(80, 80, 90)
            Config.Colors.Dropdown = Color3.fromRGB(30, 30, 38)
            Config.Colors.DropdownHover = Color3.fromRGB(40, 40, 50)
            Config.Colors.Button = Color3.fromRGB(35, 35, 45)
            Config.Colors.ButtonHover = Color3.fromRGB(45, 45, 55)
            Config.Colors.Notification = Color3.fromRGB(25, 25, 32)
            Config.Colors.Success = Color3.fromRGB(50, 200, 100)
            Config.Colors.Warning = Color3.fromRGB(255, 170, 50)
            Config.Colors.Error = Color3.fromRGB(255, 80, 80)
        end)
        local KeybindSection = SettingsTab:CreateSection("Keybinds")
        local uiKeybindBtn = KeybindSection:CreateButton("UI Toggle: " .. Config.UIKeybind.Name, function() end)
        local ColorsSection = SettingsTab:CreateSection("Colors")
        ColorsSection:CreateColorPicker("Background", Config.Colors.Background, function(color)
            Config.Colors.Background = color
            MainFrame.BackgroundColor3 = color
        end)
        ColorsSection:CreateColorPicker("Background Alt", Config.Colors.BackgroundAlt, function(color)
            Config.Colors.BackgroundAlt = color
        end)
        ColorsSection:CreateColorPicker("Accent", Config.Colors.Accent, function(color)
            Config.Colors.Accent = color
        end)
        ColorsSection:CreateColorPicker("Text", Config.Colors.Text, function(color)
            Config.Colors.Text = color
        end)
        ColorsSection:CreateColorPicker("Text Dim", Config.Colors.TextDim, function(color)
            Config.Colors.TextDim = color
        end)
        table.insert(Windows, window)
        return window
    end
    function Library:Notify(title, text, duration, type)
        duration = duration or 3
        type = type or "Info"
        local color = type == "Success" and Config.Colors.Success or type == "Warning" and Config.Colors.Warning or type == "Error" and Config.Colors.Error or Config.Colors.Accent
        local Notification = Create("Frame", {
            Parent = Player.PlayerGui,
            Size = UDim2.new(0, 300, 0, 80),
            Position = UDim2.new(1, -320, 0.5, -40 + (#Notifications * 90)),
            BackgroundColor3 = Config.Colors.Notification,
            BorderSizePixel = 0,
            ZIndex = 100
        })
        Create("UICorner", {Parent = Notification, CornerRadius = UDim.new(0, 8)})
        Create("UIPadding", {Parent = Notification, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
        local AccentLine = Create("Frame", {
            Parent = Notification,
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0
        })
        local Title = Create("TextLabel", {
            Parent = Notification,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = color,
            TextSize = 14,
            Font = Config.FontBold,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local Text = Create("TextLabel", {
            Parent = Notification,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Config.Colors.Text,
            TextSize = 12,
            Font = Config.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        table.insert(Notifications, Notification)
        Tween(Notification, NewTweenInfo(0.3), {Position = UDim2.new(1, -320, 1, -100 - ((#Notifications - 1) * 90))})
        task.delay(duration, function()
            Tween(Notification, NewTweenInfo(0.3), {Position = UDim2.new(1, 20, 1, -100 - ((#Notifications - 1) * 90)), BackgroundTransparency = 1})
            task.wait(0.3)
            Notification:Destroy()
            table.remove(Notifications, table.find(Notifications, Notification))
            for i, n in ipairs(Notifications) do
                Tween(n, NewTweenInfo(0.3), {Position = UDim2.new(1, -320, 1, -100 - ((i - 1) * 90))})
            end
        end)
    end
    return Library
end

return Library
