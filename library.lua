-- Synaptic UI Library  2
local Library = {}
Library.__index = Library

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Configuration
local Config = {
    Colors = {
        Main = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(28, 28, 35),
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

local Notifications = {}
local Windows = {}

-- Utility Functions
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
    local dragging = false
    local dragStart = nil
    local startPos = nil
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Color Picker
local function CreateColorPicker(callback)
    local ScreenGui = Create("ScreenGui", {
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local Frame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 350, 0, 400),
        Position = UDim2.new(0.5, -175, 0.5, -200),
        BackgroundColor3 = Config.Colors.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = Frame, Color = Config.Colors.Border, Thickness = 1})
    
    -- Header
    local Header = Create("Frame", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Header,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 8)})
    local HeaderCorner = Create("UICorner", {Parent = Header})
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    task.wait()
    HeaderCorner.CornerRadius = UDim.new(0, 0)
    
    local Title = Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = "Color Picker",
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("UIPadding", {Parent = Title, PaddingLeft = UDim.new(0, 10)})
    
    local CloseBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Config.Colors.Text,
        TextSize = 16,
        Font = Config.FontBold,
        ZIndex = 10
    })
    
    -- Color Area
    local ColorBox = Create("ImageButton", {
        Parent = Frame,
        Size = UDim2.new(1, -20, 0, 180),
        Position = UDim2.new(0, 10, 0, 50),
        Image = "rbxassetid://5129684636",
        BackgroundColor3 = Color3.new(1, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = ColorBox, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = ColorBox, Color = Config.Colors.Border, Thickness = 1})
    
    -- Hue Slider
    local HueContainer = Create("Frame", {
        Parent = Frame,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 245),
        BackgroundColor3 = Config.Colors.Dropdown,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = HueContainer, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = HueContainer, Color = Config.Colors.Border, Thickness = 1})
    
    local HueBar = Create("ImageLabel", {
        Parent = HueContainer,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5129684636",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    local HueKnob = Create("Frame", {
        Parent = HueContainer,
        Size = UDim2.new(0, 12, 0, 20),
        Position = UDim2.new(0, 8, 0.5, -10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Create("UICorner", {Parent = HueKnob, CornerRadius = UDim.new(0, 3)})
    Create("UIStroke", {Parent = HueKnob, Color = Color3.new(0, 0, 0), Thickness = 1})
    
    -- Preview
    local Preview = Create("Frame", {
        Parent = Frame,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 285),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = Preview, Color = Config.Colors.Border, Thickness = 1})
    
    -- Buttons
    local ConfirmBtn = Create("TextButton", {
        Parent = Frame,
        Size = UDim2.new(0, 150, 0, 35),
        Position = UDim2.new(0, 10, 0, 355),
        BackgroundColor3 = Config.Colors.Accent,
        Text = "Confirm",
        TextColor3 = Config.Colors.Text,
        TextSize = 12,
        Font = Config.FontBold,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = ConfirmBtn, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = ConfirmBtn, Color = Config.Colors.Border, Thickness = 1})
    
    local CancelBtn = Create("TextButton", {
        Parent = Frame,
        Size = UDim2.new(0, 150, 0, 35),
        Position = UDim2.new(1, -160, 0, 355),
        BackgroundColor3 = Config.Colors.Button,
        Text = "Cancel",
        TextColor3 = Config.Colors.Text,
        TextSize = 12,
        Font = Config.FontBold,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = CancelBtn, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = CancelBtn, Color = Config.Colors.Border, Thickness = 1})
    
    Draggable(Frame, Header)
    
    local currentH, currentS, currentV = 0, 1, 1
    local function UpdateColor()
        local color = Color3.fromHSV(currentH, currentS, currentV)
        ColorBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
        Preview.BackgroundColor3 = color
    end
    
    local draggingHue = false
    local draggingColor = false
    
    HueContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
        end
    end)
    HueContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)
    ColorBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingColor = true
        end
    end)
    ColorBox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingColor = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function()
        if draggingHue then
            local absSize = HueContainer.AbsoluteSize.X - 16
            local pos = math.clamp((Mouse.X - HueContainer.AbsolutePosition.X - 8), 0, absSize)
            currentH = pos / absSize
            HueKnob.Position = UDim2.new(0, 8 + pos, 0.5, -10)
            UpdateColor()
        end
        if draggingColor then
            local absPos = ColorBox.AbsolutePosition
            local absSize = ColorBox.AbsoluteSize
            local x = math.clamp((Mouse.X - absPos.X), 0, absSize.X)
            local y = math.clamp((Mouse.Y - absPos.Y), 0, absSize.Y)
            currentS = x / absSize.X
            currentV = 1 - (y / absSize.Y)
            UpdateColor()
        end
    end)
    
    local function Close()
        ScreenGui:Destroy()
    end
    
    ConfirmBtn.MouseButton1Click:Connect(function()
        callback(Color3.fromHSV(currentH, currentS, currentV))
        Close()
    end)
    CancelBtn.MouseButton1Click:Connect(Close)
    CloseBtn.MouseButton1Click:Connect(Close)
    UpdateColor()
end

-- Library Functions
function Library:CreateWindow(name)
    local Window = {}
    Window.Name = name
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Visible = true
    
    -- Create main GUI
    local ScreenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = name,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 700, 0, 480),
        Position = UDim2.new(0.5, -350, 0.5, -240),
        BackgroundColor3 = Config.Colors.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = MainFrame, Color = Config.Colors.Border, Thickness = 1})
    
    -- Header
    local Header = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Header,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 10)})
    local HeaderCorner = Create("UICorner", {Parent = Header})
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    task.wait()
    HeaderCorner.CornerRadius = UDim.new(0, 0)
    
    local TitleLabel = Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(1, -130, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("UIPadding", {Parent = TitleLabel, PaddingLeft = UDim.new(0, 15)})
    
    local ToggleKeybindsBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -110, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "⌨",
        TextColor3 = Config.Colors.Text,
        TextSize = 14,
        Font = Config.FontBold,
        ZIndex = 10
    })
    
    local MinimizeBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -75, 0.5, -15),
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
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Config.Colors.Text,
        TextSize = 16,
        Font = Config.FontBold,
        ZIndex = 10
    })
    
    -- Keybind Sidebar
    local KeybindSidebar = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 180, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Secondary,
        BorderSizePixel = 0
    })
    
    local KeybindHeader = Create("TextLabel", {
        Parent = KeybindSidebar,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Text = "Keybinds",
        TextColor3 = Config.Colors.Text,
        TextSize = 13,
        Font = Config.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("UIPadding", {Parent = KeybindHeader, PaddingLeft = UDim.new(0, 12), PaddingTop = UDim.new(0, 5)})
    
    local KeybindList = Create("ScrollingFrame", {
        Parent = KeybindSidebar,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        BorderSizePixel = 0,
        ScrollBarImageColor3 = Config.Colors.TextDim,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIPadding", {Parent = KeybindList, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
    
    local KeybindListLayout = Create("UIListLayout", {
        Parent = KeybindList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -180, 1, -40),
        Position = UDim2.new(0, 180, 0, 40),
        BackgroundTransparency = 1
    })
    
    local TabBar = Create("Frame", {
        Parent = ContentArea,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Secondary,
        BorderSizePixel = 0
    })
    
    local TabBarLayout = Create("UIListLayout", {
        Parent = TabBar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5)
    })
    Create("UIPadding", {Parent = TabBar, PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 8)})
    
    local TabContent = Create("ScrollingFrame", {
        Parent = ContentArea,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Main,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Colors.TextDim,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIPadding", {Parent = TabContent, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
    
    local TabContentLayout = Create("UIListLayout", {
        Parent = TabContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    -- Draggable
    Draggable(MainFrame, Header)
    
    -- Toggle UI
    local function ToggleUI()
        Window.Visible = not Window.Visible
        MainFrame.Visible = Window.Visible
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.UIKeybind then
            ToggleUI()
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(ToggleUI)
    
    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        Tween(MainFrame, NewTweenInfo(0.3), {
            Size = isMinimized and UDim2.new(0, 700, 0, 40) or UDim2.new(0, 700, 0, 480)
        })
    end)
    
    ToggleKeybindsBtn.MouseButton1Click:Connect(function()
        KeybindSidebar.Visible = not KeybindSidebar.Visible
        if KeybindSidebar.Visible then
            ContentArea.Position = UDim2.new(0, 180, 0, 40)
            ContentArea.Size = UDim2.new(1, -180, 1, -40)
        else
            ContentArea.Position = UDim2.new(0, 0, 0, 40)
            ContentArea.Size = UDim2.new(1, 0, 1, -40)
        end
    end)
    
    -- Add keybind to sidebar
    local function AddKeybindToSidebar(name, keybind)
        local KeybindItem = Create("Frame", {
            Parent = KeybindList,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Config.Colors.Main,
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = KeybindItem, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = KeybindItem, Color = Config.Colors.Border, Thickness = 1})
        
        local NameLabel = Create("TextLabel", {
            Parent = KeybindItem,
            Size = UDim2.new(1, -55, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Colors.Text,
            TextSize = 11,
            Font = Config.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
        Create("UIPadding", {Parent = NameLabel, PaddingLeft = UDim.new(0, 8)})
        
        local KeyLabel = Create("TextLabel", {
            Parent = KeybindItem,
            Size = UDim2.new(0, 45, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = Config.Colors.Accent,
            Text = keybind ~= Enum.KeyCode.Unknown and keybind.Name or "—",
            TextColor3 = Config.Colors.Text,
            TextSize = 10,
            Font = Config.FontBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = KeyLabel, CornerRadius = UDim.new(0, 3)})
        
        return KeybindItem
    end
    
    -- Create Tab
    function Window:CreateTab(tabName)
        local Tab = {}
        Tab.Name = tabName
        Tab.Sections = {}
        
        local TabBtn = Create("TextButton", {
            Parent = TabBar,
            Size = UDim2.new(0, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Config.Colors.Dropdown,
            Text = "",
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 5)})
        Create("UIStroke", {Parent = TabBtn, Color = Config.Colors.Border, Thickness = 1})
        
        local TabBtnText = Create("TextLabel", {
            Parent = TabBtn,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Config.Colors.TextDim,
            TextSize = 12,
            Font = Config.FontBold,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        Create("UIPadding", {Parent = TabBtnText, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})
        
        local TabPage = Create("Frame", {
            Parent = TabContent,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        Create("UIListLayout", {Parent = TabPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        
        local function SelectTab()
            for _, t in ipairs(Window.Tabs) do
                t.Button.BackgroundColor3 = Config.Colors.Dropdown
                t.ButtonText.TextColor3 = Config.Colors.TextDim
                t.Page.Visible = false
            end
            TabBtn.BackgroundColor3 = Config.Colors.Accent
            TabBtnText.TextColor3 = Config.Colors.Text
            TabPage.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        
        if #Window.Tabs == 0 then
            SelectTab()
        end
        
        function Tab:CreateSection(sectionName)
            local Section = {}
            Section.Name = sectionName
            Section.Elements = {}
            
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
                Text = sectionName,
                TextColor3 = Config.Colors.Accent,
                TextSize = 12,
                Font = Config.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SectionContent = Create("Frame", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = SectionContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
            
            local function AddElement(element)
                element.Parent = SectionContent
                table.insert(Section.Elements, element)
                task.wait()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionContent.AbsoluteSize.Y + 35)
                TabPage.Size = UDim2.new(1, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y)
                TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContent.UIListLayout.AbsoluteContentSize.Y + 20)
            end
            
            function Section:CreateButton(name, callback)
                local Button = {}
                Button.Name = name
                Button.Callback = callback or function() end
                Button.Keybind = {Key = Enum.KeyCode.Unknown, Mode = "Toggle"}
                
                local ButtonFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1
                })
                
                local Btn = Create("TextButton", {
                    Parent = ButtonFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Config.Colors.Button,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.FontBold,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
                Create("UIStroke", {Parent = Btn, Color = Config.Colors.Border, Thickness = 1})
                
                local KeyDisplay = Create("TextLabel", {
                    Parent = ButtonFrame,
                    Size = UDim2.new(0, 70, 0, 22),
                    Position = UDim2.new(1, -75, 0.5, -11),
                    BackgroundColor3 = Config.Colors.Secondary,
                    Text = Button.Keybind.Key ~= Enum.KeyCode.Unknown and Button.Keybind.Key.Name or "Unbound",
                    TextColor3 = Config.Colors.TextDim,
                    TextSize = 10,
                    Font = Config.Font,
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                Create("UICorner", {Parent = KeyDisplay, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = KeyDisplay, Color = Config.Colors.Border, Thickness = 1})
                
                AddElement(ButtonFrame)
                
                local SidebarEntry = AddKeybindToSidebar(name, Button.Keybind.Key)
                
                Btn.MouseButton1Click:Connect(function()
                    Button.Callback()
                end)
                
                return Button
            end
            
            function Section:CreateToggle(name, default, callback)
                local Toggle = {}
                Toggle.Name = name
                Toggle.Value = default or false
                Toggle.Callback = callback or function() end
                
                local ToggleFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1
                })
                
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(1, -65, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleContainer = Create("Frame", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(0, 50, 0, 24),
                    Position = UDim2.new(1, -50, 0.5, -12),
                    BackgroundColor3 = Toggle.Value and Config.Colors.ToggleOn or Config.Colors.ToggleOff,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = ToggleContainer, CornerRadius = UDim.new(0, 12)})
                Create("UIStroke", {Parent = ToggleContainer, Color = Config.Colors.Border, Thickness = 1})
                
                local ToggleKnob = Create("Frame", {
                    Parent = ToggleContainer,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, Toggle.Value and 29 or 3, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = ToggleKnob, CornerRadius = UDim.new(0, 9)})
                
                local ToggleBtn = Create("TextButton", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 10
                })
                
                AddElement(ToggleFrame)
                
                local function UpdateToggle()
                    Tween(ToggleContainer, NewTweenInfo(0.2), {
                        BackgroundColor3 = Toggle.Value and Config.Colors.ToggleOn or Config.Colors.ToggleOff
                    })
                    Tween(ToggleKnob, NewTweenInfo(0.2), {
                        Position = UDim2.new(0, Toggle.Value and 29 or 3, 0.5, -9)
                    })
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                    Toggle.Callback(Toggle.Value)
                end)
                
                return Toggle
            end
            
            function Section:CreateSlider(name, min, max, default, callback)
                local Slider = {}
                Slider.Name = name
                Slider.Value = default or min
                Slider.Min = min
                Slider.Max = max
                Slider.Callback = callback or function() end
                
                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 55),
                    BackgroundTransparency = 1
                })
                
                local Label = Create("TextLabel", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, -70, 0, 25),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextBox", {
                    Parent = SliderFrame,
                    Size = UDim2.new(0, 60, 0, 24),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundColor3 = Config.Colors.Secondary,
                    Text = tostring(Slider.Value),
                    TextColor3 = Config.Colors.Accent,
                    TextSize = 12,
                    Font = Config.FontBold,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false
                })
                Create("UICorner", {Parent = ValueLabel, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = ValueLabel, Color = Config.Colors.Border, Thickness = 1})
                
                local SliderContainer = Create("Frame", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = Config.Colors.SliderBackground,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = SliderContainer, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = SliderContainer, Color = Config.Colors.Border, Thickness = 1})
                
                local SliderFill = Create("Frame", {
                    Parent = SliderContainer,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Config.Colors.SliderFill,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = SliderFill, CornerRadius = UDim.new(0, 4)})
                
                local SliderKnob = Create("Frame", {
                    Parent = SliderContainer,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 10
                })
                Create("UICorner", {Parent = SliderKnob, CornerRadius = UDim.new(0, 8)})
                Create("UIStroke", {Parent = SliderKnob, Color = Config.Colors.SliderFill, Thickness = 2})
                
                AddElement(SliderFrame)
                
                local function UpdateSlider()
                    local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
                    ValueLabel.Text = tostring(math.round(Slider.Value * 100) / 100)
                end
                
                UpdateSlider()
                
                local dragging = false
                SliderContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                SliderContainer.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function()
                    if dragging then
                        local absSize = SliderContainer.AbsoluteSize.X
                        local percent = math.clamp((Mouse.X - SliderContainer.AbsolutePosition.X) / absSize, 0, 1)
                        Slider.Value = Slider.Min + (percent * (Slider.Max - Slider.Min))
                        UpdateSlider()
                        Slider.Callback(Slider.Value)
                    end
                end)
                
                ValueLabel.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        local num = tonumber(ValueLabel.Text)
                        if num then
                            Slider.Value = math.clamp(num, Slider.Min, Slider.Max)
                            UpdateSlider()
                            Slider.Callback(Slider.Value)
                        end
                    end
                end)
                
                return Slider
            end
            
            function Section:CreateDropdown(name, options, default, callback)
                local Dropdown = {}
                Dropdown.Name = name
                Dropdown.Value = default or options[1]
                Dropdown.Callback = callback or function() end
                Dropdown.Open = false
                
                local DropdownFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                
                local Label = Create("TextLabel", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 12,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownBtn = Create("TextButton", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 36),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Config.Colors.Dropdown,
                    Text = "",
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = DropdownBtn, CornerRadius = UDim.new(0, 6)})
                Create("UIStroke", {Parent = DropdownBtn, Color = Config.Colors.Border, Thickness = 1})
                
                local DropdownText = Create("TextLabel", {
                    Parent = DropdownBtn,
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = Dropdown.Value,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                Create("UIPadding", {Parent = DropdownText, PaddingLeft = UDim.new(0, 12)})
                
                local DropdownArrow = Create("TextLabel", {
                    Parent = DropdownBtn,
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
                    Position = UDim2.new(0, 0, 0, 60),
                    BackgroundColor3 = Config.Colors.Dropdown,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = DropdownList, CornerRadius = UDim.new(0, 6)})
                Create("UIStroke", {Parent = DropdownList, Color = Config.Colors.Border, Thickness = 1})
                Create("UIListLayout", {Parent = DropdownList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                
                for i, option in ipairs(options) do
                    local OptionBtn = Create("TextButton", {
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
                    Create("UIPadding", {Parent = OptionBtn, PaddingLeft = UDim.new(0, 12)})
                    
                    OptionBtn.MouseEnter:Connect(function()
                        OptionBtn.BackgroundColor3 = Config.Colors.DropdownHover
                    end)
                    OptionBtn.MouseLeave:Connect(function()
                        OptionBtn.BackgroundColor3 = Config.Colors.Dropdown
                    end)
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownText.Text = option
                        Dropdown.Callback(option)
                        Dropdown.Open = false
                        Tween(DropdownList, NewTweenInfo(0.2), {Size = UDim2.new(1, 0, 0, 0)})
                        Tween(DropdownArrow, NewTweenInfo(0.2), {Rotation = 0})
                    end)
                end
                
                AddElement(DropdownFrame)
                
                function Dropdown:Toggle()
                    Dropdown.Open = not Dropdown.Open
                    local listHeight = #options * 34 + (#options - 1) * 2
                    Tween(DropdownList, NewTweenInfo(0.2), {
                        Size = UDim2.new(1, 0, 0, Dropdown.Open and listHeight or 0)
                    })
                    Tween(DropdownArrow, NewTweenInfo(0.2), {
                        Rotation = Dropdown.Open and 180 or 0
                    })
                end
                
                DropdownBtn.MouseButton1Click:Connect(function()
                    Dropdown:Toggle()
                end)
                
                return Dropdown
            end
            
            function Section:CreateColorPicker(name, default, callback)
                local ColorPicker = {}
                ColorPicker.Name = name
                ColorPicker.Value = default or Color3.new(1, 1, 1)
                ColorPicker.Callback = callback or function() end
                
                local ColorFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1
                })
                
                local Label = Create("TextLabel", {
                    Parent = ColorFrame,
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    TextSize = 13,
                    Font = Config.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorBtn = Create("ImageButton", {
                    Parent = ColorFrame,
                    Size = UDim2.new(0, 38, 0, 26),
                    Position = UDim2.new(1, -38, 0.5, -13),
                    Image = "",
                    BackgroundColor3 = ColorPicker.Value,
                    BorderSizePixel = 0
                })
                Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 5)})
                Create("UIStroke", {Parent = ColorBtn, Color = Config.Colors.Border, Thickness = 1})
                
                AddElement(ColorFrame)
                
                ColorBtn.MouseButton1Click:Connect(function()
                    CreateColorPicker(function(color)
                        ColorPicker.Value = color
                        ColorBtn.BackgroundColor3 = color
                        ColorPicker.Callback(color)
                    end)
                end)
                
                return ColorPicker
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, {
            Name = tabName,
            Button = TabBtn,
            ButtonText = TabBtnText,
            Page = TabPage,
            Tab = Tab
        })
        
        return Tab
    end
    
    -- Settings Tab
    local SettingsTab = Window:CreateTab("Settings")
    
    local GeneralSection = SettingsTab:CreateSection("General")
    GeneralSection:CreateButton("Reset UI Position", function()
        MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
    end)
    GeneralSection:CreateButton("Reset Colors", function()
        Config.Colors.Main = Color3.fromRGB(20, 20, 25)
        Config.Colors.Secondary = Color3.fromRGB(28, 28, 35)
        Config.Colors.Header = Color3.fromRGB(15, 15, 20)
        Config.Colors.Accent = Color3.fromRGB(50, 150, 255)
    end)
    
    local ColorsSection = SettingsTab:CreateSection("Colors")
    ColorsSection:CreateColorPicker("Background", Config.Colors.Main, function(color)
        Config.Colors.Main = color
        MainFrame.BackgroundColor3 = color
        TabContent.BackgroundColor3 = color
    end)
    ColorsSection:CreateColorPicker("Secondary", Config.Colors.Secondary, function(color)
        Config.Colors.Secondary = color
        KeybindSidebar.BackgroundColor3 = color
        TabBar.BackgroundColor3 = color
    end)
    ColorsSection:CreateColorPicker("Accent", Config.Colors.Accent, function(color)
        Config.Colors.Accent = color
    end)
    
    table.insert(Windows, Window)
    return Window
end

function Library:Notify(title, text, duration, type)
    duration = duration or 3
    type = type or "Info"
    local color = type == "Success" and Config.Colors.Success or type == "Warning" and Config.Colors.Warning or type == "Error" and Config.Colors.Error or Config.Colors.Accent
    
    local ScreenGui = Create("ScreenGui", {
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local Notification = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 1, -100 - (#Notifications * 90)),
        BackgroundColor3 = Config.Colors.Notification,
        BorderSizePixel = 0,
        ZIndex = 100
    })
    Create("UICorner", {Parent = Notification, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = Notification, Color = color, Thickness = 1})
    Create("UIPadding", {Parent = Notification, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
    
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
    
    -- Animate in
    Notification.Position = UDim2.new(1, 20, 1, -100 - ((#Notifications - 1) * 90))
    Tween(Notification, NewTweenInfo(0.3), {
        Position = UDim2.new(1, -320, 1, -100 - ((#Notifications - 1) * 90))
    })
    
    -- Animate out and remove
    task.delay(duration, function()
        local idx = table.find(Notifications, Notification)
        if idx then
            table.remove(Notifications, idx)
            
            Tween(Notification, NewTweenInfo(0.3), {
                Position = UDim2.new(1, 20, 1, -100 - ((idx - 1) * 90)),
                BackgroundTransparency = 1
            })
            
            task.wait(0.3)
            ScreenGui:Destroy()
            
            -- Reorder remaining notifications
            for i, n in ipairs(Notifications) do
                Tween(n, NewTweenInfo(0.3), {
                    Position = UDim2.new(1, -320, 1, -100 - ((i - 1) * 90))
                })
            end
        end
    end)
end

return Library
