--[[
MAXIM FLIGHT HUB — DELTA / ANDROID
Client-side flight and visual hub. Run from Delta's executor.
20 themes, 20 flight presets, 15 animated effect circles, 5 VIP tools.
VIP unlock codes:
  English: burger
  Russian: рагнарёк
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local guiParent = PlayerGui
local old
pcall(function()
    if type(gethui) == "function" then
        local h = gethui()
        if h then
            guiParent = h
            old = h:FindFirstChild("MaximFlightHub")
        end
    end
end)
if not old then old = PlayerGui:FindFirstChild("MaximFlightHub") end
if old then pcall(function() old:Destroy() end) end

local gui = Instance.new("ScreenGui")
gui.Name = "MaximFlightHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

local themes = {
    {"Neo Pink", Color3.fromRGB(255,55,170), Color3.fromRGB(35,12,35)},
    {"Red White", Color3.fromRGB(255,55,65), Color3.fromRGB(28,28,32)},
    {"Cyber Blue", Color3.fromRGB(45,170,255), Color3.fromRGB(10,22,40)},
    {"Purple", Color3.fromRGB(170,90,255), Color3.fromRGB(25,14,40)},
    {"Emerald", Color3.fromRGB(40,230,150), Color3.fromRGB(10,30,25)},
    {"Gold", Color3.fromRGB(255,190,55), Color3.fromRGB(38,28,10)},
    {"Ice", Color3.fromRGB(110,235,255), Color3.fromRGB(12,30,40)},
    {"Lava", Color3.fromRGB(255,100,25), Color3.fromRGB(38,15,8)},
    {"Ocean", Color3.fromRGB(35,120,220), Color3.fromRGB(8,20,38)},
    {"Toxic", Color3.fromRGB(170,255,35), Color3.fromRGB(22,32,8)},
    {"Violet", Color3.fromRGB(210,80,255), Color3.fromRGB(30,10,40)},
    {"Rose", Color3.fromRGB(255,120,145), Color3.fromRGB(38,16,25)},
    {"Monochrome", Color3.fromRGB(220,220,230), Color3.fromRGB(20,20,24)},
    {"Mint", Color3.fromRGB(100,255,210), Color3.fromRGB(10,32,28)},
    {"Sunset", Color3.fromRGB(255,130,70), Color3.fromRGB(38,18,24)},
    {"Matrix", Color3.fromRGB(0,255,100), Color3.fromRGB(5,20,10)},
    {"Arctic", Color3.fromRGB(170,220,255), Color3.fromRGB(15,25,42)},
    {"Cherry", Color3.fromRGB(220,25,70), Color3.fromRGB(35,8,18)},
    {"Aqua", Color3.fromRGB(0,230,230), Color3.fromRGB(8,30,34)},
    {"Dark Neon", Color3.fromRGB(255,255,70), Color3.fromRGB(12,12,18)}
}

local modes = {
    {"Обычный", 55, 1.0}, {"Быстрый", 90, 1.0}, {"Сверхскорость", 145, 1.0},
    {"Медленный", 25, 1.0}, {"Плавный", 45, 0.55}, {"Рывками", 85, 0.25},
    {"Низкий полёт", 55, 0.7}, {"Высокий полёт", 55, 1.5}, {"Ракета", 180, 1.0},
    {"Парение", 35, 0.15}, {"Лунный", 65, 0.8}, {"Невесомость", 50, 0.35},
    {"Спираль", 75, 0.9}, {"Зигзаг", 80, 0.8}, {"Точный", 35, 0.4},
    {"Турбо", 220, 1.0}, {"Призрак", 70, 0.6}, {"Орбита", 60, 1.0},
    {"Экстрим", 260, 1.0}, {"Максим", 120, 1.0}
}

local effects = {
    {"Бег", "🏃"}, {"Лёд", "❄️"}, {"Огонёк", "🔥"}, {"Рагнарёк", "⚡"},
    {"Вихрь", "O"}, {"Конёк", "🐎"}, {"Базлайтер", "💡"},
    {"Комета", "☄️"}, {"Неон", "✨"}, {"Пузырь", "O"},
    {"Тень", "🌑"}, {"Радуга", "🌈"}, {"Молния", "🌩️"},
    {"Сердца", "💗"}, {"Звёзды", "🌟"}
}

local themeIndex, modeIndex = 1, 1
local currentTheme = themes[1]
local flying, minimized, vipUnlocked = false, false, false
local activeEffects = {}
local flightSpeed = modes[1][2]
local moveConn, velocity, gyro
local camBaseFOV = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
local effectObjects = {}
local character, humanoid, root
local up, down
local holdingUp, holdingDown = false, false
local baseVertical = 0
local speedOverride = false
local dashVelocity, dashUntil = nil, 0
local hud, hudText
local freecamOn, freecamConn, savedCameraType, savedCameraSubject = false, nil, nil, nil
local freecamSpeed = 60
local noclipOn, noclipConn = false, nil
local bookmarks = {}
local activeTab = "Полёт"
local flightButton
local mainTargetSize = UDim2.fromOffset(330,440)
local lang = "RU"
local device = "Планшет"
local hudVisiblePreference = nil
local savePending = false

-- Persistent settings (executor filesystem is optional).
local SETTINGS_FILE = "MaximFlightHub.json"
local function saveSettings()
    if type(writefile) ~= "function" or savePending then return end
    savePending = true
    task.delay(1, function()
        savePending = false
        if type(writefile) ~= "function" then return end
        pcall(function()
            writefile(SETTINGS_FILE, HttpService:JSONEncode({
            theme=themeIndex, mode=modeIndex, speed=flightSpeed,
            speedOverride=speedOverride, lang=lang, device=device,
            vip=vipUnlocked, freecamSpeed=freecamSpeed,
            hudVisible=hud and hud.Visible or false,
            bookmarks=(function()
                local out = {}
                for _,bm in ipairs(bookmarks) do
                    local p, l = bm.cf.Position, bm.cf.LookVector
                    table.insert(out,{place=bm.place,x=p.X,y=p.Y,z=p.Z,lx=l.X,ly=l.Y,lz=l.Z})
                end
                return out
            end)()
            }))
        end)
    end)
end

local function loadSettings()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    pcall(function()
        if not isfile(SETTINGS_FILE) then return end
        local d = HttpService:JSONDecode(readfile(SETTINGS_FILE))
        if type(d) ~= "table" then return end
        if type(d.theme)=="number" and themes[d.theme] then themeIndex=d.theme; currentTheme=themes[themeIndex] end
        if type(d.mode)=="number" and modes[d.mode] then modeIndex=d.mode end
        if type(d.speed)=="number" then flightSpeed=math.clamp(d.speed,5,300) end
        if type(d.speedOverride)=="boolean" then speedOverride=d.speedOverride end
        if d.lang=="RU" or d.lang=="EN" then lang=d.lang end
        if type(d.device)=="string" then device=d.device end
        if type(d.vip)=="boolean" then vipUnlocked=d.vip end
        if type(d.freecamSpeed)=="number" then freecamSpeed=math.clamp(d.freecamSpeed,10,200) end
        if type(d.hudVisible)=="boolean" then hudVisiblePreference=d.hudVisible end
        if type(d.bookmarks)=="table" then
            local perPlace = {}
            for _,b in ipairs(d.bookmarks) do
                if type(b)=="table" and type(b.place)=="number" and type(b.x)=="number" and type(b.y)=="number" and type(b.z)=="number" then
                    perPlace[b.place]=(perPlace[b.place] or 0)+1
                    if perPlace[b.place] <= 5 then
                        local pos=Vector3.new(b.x,b.y,b.z)
                        local look=Vector3.new(type(b.lx)=="number" and b.lx or 0,type(b.ly)=="number" and b.ly or 0,type(b.lz)=="number" and b.lz or -1)
                        if look.Magnitude < 0.01 then look=Vector3.new(0,0,-1) end
                        table.insert(bookmarks,{cf=CFrame.lookAt(pos,pos+look),place=b.place})
                    end
                end
            end
        end
    end)
end
loadSettings()

local translations = {
    ["Полёт"]="Flight",["Темы"]="Themes",["Эффекты"]="Effects",["Инстр."]="Tools",["VIP"]="VIP",
    ["ПОЛЁТ"]="FLIGHT",["ПОЛЁТ: ВЫКЛ"]="FLIGHT: OFF",["ПОЛЁТ: ВКЛ"]="FLIGHT: ON",
    ["Режим"]="Mode",["следующий"]="next",["Скорость"]="Speed",["Текущая скорость"]="Current speed",
    ["ВЕРТИКАЛЬНОЕ УПРАВЛЕНИЕ"]="VERTICAL CONTROL",["Вверх"]="Up",["Вниз"]="Down",
    ["Сброс высоты"]="Reset altitude",["БЫСТРЫЙ ВЫБОР РЕЖИМА"]="QUICK MODE SELECT",
    ["20 ТЕМ ОФОРМЛЕНИЯ"]="20 THEMES",["15 ДОПОЛНИТЕЛЬНЫХ ЭФФЕКТОВ — НАЖМИ ДЛЯ ВКЛ/ВЫКЛ"]="15 EXTRA EFFECTS — TAP TO TOGGLE",
    ["VIP ДОСТУП"]="VIP ACCESS",["Введи секретный код. Английский: burger | Русский: рагнарёк"]="Enter secret code. English: burger | Russian: рагнарёк",
    ["Секретный код..."]="Secret code...",["ПРОВЕРИТЬ КОД"]="CHECK CODE",["Неверный код — попробуй ещё раз"]="Wrong code — try again",
    ["VIP РАЗБЛОКИРОВАН"]="VIP UNLOCKED",["5 VIP-ФУНКЦИЙ"]="5 VIP FEATURES",
    ["Суперскорость"]="Super speed",["Мягкое парение"]="Soft hover",["Турбо-рывок"]="Turbo dash",
    ["Неоновая аура"]="Neon aura",["Полный сброс эффектов"]="Reset effects",
    ["ИНСТРУМЕНТЫ"]="TOOLS",["ВКЛ"]="ON",["ВЫКЛ"]="OFF",["ИГРОКИ — ЛОКАЛЬНОЕ ПЕРЕМЕЩЕНИЕ"]="PLAYERS — LOCAL TELEPORT",
    ["ПРОХОД СКВОЗЬ СТЕНЫ"]="NOCLIP",["ЗАКЛАДКИ ПОЗИЦИИ — ДО 5 ТОЧЕК"]="POSITION BOOKMARKS — UP TO 5",
    ["＋ Сохранить текущую позицию"]="＋ Save current position",["Загрузка точки"]="Load bookmark",
    ["Язык: Русский"]="Language: Russian",["Устройство: Планшет"]="Device: Tablet",["ЗАПУСТИТЬ HUB"]="START HUB",
    ["Обычный"]="Normal",["Быстрый"]="Fast",["Сверхскорость"]="Hyper speed",["Медленный"]="Slow",
    ["Плавный"]="Smooth",["Рывками"]="Pulse",["Низкий полёт"]="Low flight",["Высокий полёт"]="High flight",
    ["Ракета"]="Rocket",["Парение"]="Hover",["Лунный"]="Moon",["Невесомость"]="Zero gravity",
    ["Спираль"]="Spiral",["Зигзаг"]="Zigzag",["Точный"]="Precision",["Турбо"]="Turbo",
    ["Призрак"]="Ghost",["Орбита"]="Orbit",["Экстрим"]="Extreme",["Максим"]="Maxim",
    ["Бег"]="Run",["Лёд"]="Ice",["Огонёк"]="Flame",["Рагнарёк"]="Ragnarok",["Вихрь"]="Vortex",
    ["Конёк"]="Skater",["Базлайтер"]="Baselighter",["Комета"]="Comet",["Неон"]="Neon",
    ["Пузырь"]="Bubble",["Тень"]="Shadow",["Радуга"]="Rainbow",["Молния"]="Lightning",
    ["Сердца"]="Hearts",["Звёзды"]="Stars",
    ["VIP разблокирован"]="VIP unlocked",["Позиция сохранена"]="Position saved",
    ["Туман убран"]="Fog removed",["Туман восстановлен"]="Fog restored",
    ["Неверный код — попробуй ещё раз"]="Wrong code — try again",
    ["Введи секретный код..."]="Enter secret code...",
    ["Тема: "]="Theme: ",["Noclip: "]="Noclip: ",["Убрано"]="Removed"
}
local function tr(value)
    local result = tostring(value)
    if lang == "EN" then
        local keys = {}
        for ru in pairs(translations) do table.insert(keys,ru) end
        table.sort(keys,function(a,b) return #a > #b end)
        for _,ru in ipairs(keys) do result = result:gsub(ru,translations[ru]) end
    end
    return result
end

local function getCharacter()
    character = LP.Character or LP.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid")
    root = character:FindFirstChild("HumanoidRootPart")
    return humanoid and root
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or currentTheme[2]
    s.Thickness = thickness or 1.5
    s.Transparency = 0.15
    s.Parent = obj
    return s
end

local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(330, 440)
main.Position = UDim2.new(0.5, -165, 0.5, -220)
main.BackgroundColor3 = currentTheme[3]
main.Parent = gui
corner(main, 16)
local mainStroke = stroke(main, currentTheme[2], 2)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 45)
top.BackgroundColor3 = currentTheme[2]
top.BackgroundTransparency = 0.12
top.Parent = main
corner(top, 15)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Name = "HubTitle"
title.Text = "MAXIM FLIGHT HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local function makeButton(parent, text, size, pos)
    local b = Instance.new("TextButton")
    b.Size, b.Position = size, pos
    b.BackgroundColor3 = currentTheme[2]
    b.BackgroundTransparency = 0.18
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 10)
    return b
end

local close = makeButton(top, "—", UDim2.fromOffset(34,30), UDim2.new(1,-76,0,7))
local xbtn = makeButton(top, "×", UDim2.fromOffset(34,30), UDim2.new(1,-38,0,7))

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,-20,1,-58)
pages.Position = UDim2.fromOffset(10,52)
pages.BackgroundTransparency = 1
pages.Parent = main

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1,0,0,34)
tabs.BackgroundTransparency = 1
tabs.Parent = pages

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,0,1,-42)
content.Position = UDim2.fromOffset(0,42)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new()
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = pages

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function clearContent()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
end

local function sectionLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-4,0,25)
    l.BackgroundTransparency = 1
    l.Text = tr(text)
    l.TextColor3 = currentTheme[2]
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = content
    return l
end

local function itemButton(text, callback)
    local b = makeButton(content, tr(text), UDim2.new(1,-4,0,34), UDim2.new())
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "  " .. tr(text)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Compact toast stack.
local toastBox = Instance.new("Frame")
toastBox.Name = "ToastStack"
toastBox.Size = UDim2.fromOffset(280,180)
toastBox.Position = UDim2.new(0.5,-140,0,12)
toastBox.BackgroundTransparency = 1
toastBox.ClipsDescendants = true
toastBox.ZIndex = 50
toastBox.Parent = gui
local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0,6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Parent = toastBox

local function toast(message, duration)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,32)
    label.BackgroundColor3 = currentTheme[2]
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = tr(message)
    label.ZIndex = 51
    label.Parent = toastBox
    corner(label,9)
    local toastItems = {}
    for _,child in ipairs(toastBox:GetChildren()) do
        if child:IsA("TextLabel") then table.insert(toastItems,child) end
    end
    while #toastItems > 5 do
        local oldest=table.remove(toastItems,1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end
    local life = duration or 2
    task.delay(life,function()
        if label and label.Parent then
            tween(label,{BackgroundTransparency=1,TextTransparency=1},0.2)
            task.delay(0.25,function() if label then label:Destroy() end end)
        end
    end)
end

local function makeSlider(parent,minValue,maxValue,initial,onChanged)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1,-4,0,48)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent
    local readout = Instance.new("TextLabel")
    readout.Size = UDim2.new(1,0,0,18)
    readout.BackgroundTransparency = 1
    readout.TextColor3 = currentTheme[2]
    readout.Font = Enum.Font.GothamBold
    readout.TextSize = 12
    readout.TextXAlignment = Enum.TextXAlignment.Left
    readout.Parent = wrap
    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1,0,0,18)
    bar.Position = UDim2.fromOffset(0,24)
    bar.BackgroundColor3 = currentTheme[3]
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = wrap
    corner(bar,8)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = currentTheme[2]
    fill.Size = UDim2.new(0,0,1,0)
    fill.Parent = bar
    corner(fill,8)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18,18)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = bar
    corner(knob,9)
    local dragging = false
    local function setAt(x)
        if bar.AbsoluteSize.X < 10 then return end
        local width = bar.AbsoluteSize.X
        local ratio = math.clamp((x-bar.AbsolutePosition.X)/width,0,1)
        local value = math.floor(minValue+ratio*(maxValue-minValue)+0.5)
        fill.Size = UDim2.new(ratio,0,1,0)
        knob.Position = UDim2.new(ratio,-9,0.5,-9)
        readout.Text = tr("Скорость")..": "..value
        onChanged(value)
    end
    local function begin(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; setAt(input.Position.X)
        end
    end
    bar.InputBegan:Connect(begin)
    knob.InputBegan:Connect(begin)
    local changedConn = UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then setAt(input.Position.X) end
    end)
    local endedConn = UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    wrap.Destroying:Connect(function()
        changedConn:Disconnect()
        endedConn:Disconnect()
    end)
    local ratio=math.clamp((initial-minValue)/(maxValue-minValue),0,1)
    fill.Size=UDim2.new(ratio,0,1,0); knob.Position=UDim2.new(ratio,-9,0.5,-9)
    readout.Text=tr("Скорость")..": "..math.floor(initial)
    return wrap
end

local firstThemeApply = true
local function applyTheme(index)
    themeIndex = index
    currentTheme = themes[index]
    main.BackgroundColor3 = currentTheme[3]
    top.BackgroundColor3 = currentTheme[2]
    mainStroke.Color = currentTheme[2]
    if hud then hud.BackgroundColor3 = currentTheme[3] end
    if hudText then hudText.TextColor3 = currentTheme[2] end
    for _,obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then obj.BackgroundColor3 = currentTheme[2] end
        if obj:IsA("TextBox") then obj.BackgroundColor3 = currentTheme[3]; obj.TextColor3 = Color3.new(1,1,1) end
        if obj:IsA("TextLabel") and obj.Name ~= "HubTitle" and obj.Name ~= "LauncherTitle" then obj.TextColor3 = currentTheme[2] end
        if obj:IsA("UIStroke") then obj.Color = currentTheme[2] end
    end
    if not firstThemeApply then toast("Тема: "..currentTheme[1]) end
    firstThemeApply = false
    saveSettings()
end

local function refreshFlightButton(button)
    local target = button or flightButton
    if target and target.Parent then
        target.Text = tr(flying and "  ПОЛЁТ: ВКЛ" or "  ПОЛЁТ: ВЫКЛ")
    end
end

local function setNoclip(state)
    noclipOn = state
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if character and character.Parent then
                for _,part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if character and character.Parent then
            for _,part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
    toast("Noclip: "..(state and "ON" or "OFF"))
end

local function stopFlight()
    flying = false
    dashVelocity, dashUntil = nil, 0
    holdingUp, holdingDown = false, false
    if moveConn then moveConn:Disconnect() moveConn = nil end
    if velocity then velocity:Destroy() velocity = nil end
    if gyro then gyro:Destroy() gyro = nil end
    if humanoid and humanoid.Parent then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    if up then up.Visible = false end
    if down then down.Visible = false end
    local cam = workspace.CurrentCamera
    if cam then tween(cam,{FieldOfView=camBaseFOV},0.25) end
    refreshFlightButton()
end

local function startFlight()
    if not getCharacter() then return end
    stopFlight()
    flying = true
    humanoid.PlatformStand = false
    humanoid.AutoRotate = false
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Physics) end)

    velocity = Instance.new("BodyVelocity")
    velocity.Name = "MaximFlightVelocity"
    velocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    velocity.P = 1e4
    velocity.Velocity = Vector3.zero
    velocity.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.Name = "MaximFlightGyro"
    gyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    gyro.P = 1e4
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    if up then up.Visible = true end
    if down then down.Visible = true end
    if noclipOn then setNoclip(true) end
    refreshFlightButton()

    moveConn = RunService.RenderStepped:Connect(function()
        if not flying or not root or not root.Parent or not humanoid or not humanoid.Parent then
            stopFlight()
            return
        end

        local cam = workspace.CurrentCamera
        if not cam then return end
        local dir = humanoid.MoveDirection
        local flatMove = Vector3.new(dir.X, 0, dir.Z)
        local horizontal = Vector3.zero

        -- MoveDirection is already world-space and follows the player's camera-relative controls.
        if flatMove.Magnitude > 0.05 then
            horizontal = flatMove.Unit * flightSpeed
        end

        local modeName = modes[modeIndex][1]
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
        if right.Magnitude < 0.01 then right = Vector3.new(1,0,0) else right = right.Unit end

        if modeName == "Зигзаг" then
            horizontal += right * math.sin(os.clock()*7) * flightSpeed * 0.45
        elseif modeName == "Спираль" then
            local a = os.clock()*3
            horizontal += (right*math.cos(a) + Vector3.new(-right.Z,0,right.X)*math.sin(a)) * flightSpeed * 0.45
        elseif modeName == "Орбита" then
            local a = os.clock()*2
            horizontal += right * math.cos(a) * flightSpeed * 0.55
            horizontal += Vector3.new(-right.Z,0,right.X) * math.sin(a) * flightSpeed * 0.55
        end

        local y = baseVertical
        if holdingUp then y = 65 end
        if holdingDown then y = -65 end
        if modeName == "Невесомость" then y = y * 0.35 end
        if modeName == "Парение" then y = 0 end
        if modeName == "Высокий полёт" then y = math.max(y, 12) end
        if modeName == "Низкий полёт" then y = math.min(y, -4) end
        if modeName == "Рывками" then
            local pulse = (math.floor(os.clock()*3)%2 == 0) and 1 or 0.35
            horizontal *= pulse
        end

        if dashVelocity and os.clock() < dashUntil then
            velocity.Velocity = dashVelocity
        else
            dashVelocity = nil
            velocity.Velocity = horizontal + Vector3.new(0,y,0)
        end

        local look = Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
        if look.Magnitude < 0.01 then
            look = Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
        end
        if look.Magnitude < 0.01 then look = Vector3.new(0,0,-1) end
        gyro.CFrame = CFrame.lookAt(root.Position, root.Position + look.Unit)
        local targetFOV = camBaseFOV + math.min(35,flightSpeed/10)
        cam.FieldOfView = cam.FieldOfView + (targetFOV-cam.FieldOfView)*0.08
    end)
end

local function buildHome()
    clearContent()
    sectionLabel("ПОЛЁТ")
    local fly
    fly = itemButton("ПОЛЁТ: ВЫКЛ", function()
        if flying then stopFlight() else startFlight() end
        refreshFlightButton(fly)
    end)
    flightButton = fly
    refreshFlightButton(fly)
    itemButton("Текущая скорость: "..tostring(math.floor(flightSpeed)), function() end)
    itemButton("Режим: "..modes[modeIndex][1].."  › следующий", function()
        modeIndex = modeIndex % #modes + 1
        if not speedOverride then flightSpeed = modes[modeIndex][2] end
        saveSettings()
        buildHome()
    end)
    makeSlider(content,5,300,flightSpeed,function(value)
        flightSpeed=value
        speedOverride=true
        saveSettings()
    end)
    sectionLabel("ВЕРТИКАЛЬНОЕ УПРАВЛЕНИЕ")
    itemButton("Вверх ▲", function() baseVertical = math.min(150, baseVertical + 15) end)
    itemButton("Вниз ▼", function() baseVertical = math.max(-150, baseVertical - 15) end)
    itemButton("Сброс высоты", function() baseVertical = 0 end)
    sectionLabel("БЫСТРЫЙ ВЫБОР РЕЖИМА")
    for i,m in ipairs(modes) do
        itemButton(string.format("%02d. %s  |  %d", i,m[1],m[2]), function()
            modeIndex = i
            if not speedOverride then flightSpeed = m[2] end
            saveSettings()
            buildHome()
        end)
    end
end

local function buildThemes()
    clearContent()
    sectionLabel("20 ТЕМ ОФОРМЛЕНИЯ")
    for i,t in ipairs(themes) do
        itemButton(string.format("%02d. %s",i,t[1]), function()
            applyTheme(i)
        end)
    end
end

local function removeEffect(name)
    activeEffects[name] = nil
    local obj = effectObjects[name]
    if obj then
        for _,v in ipairs(obj) do
            pcall(function() v:Destroy() end)
        end
    end
    effectObjects[name] = nil
    toast(name.." • OFF")
end

local function addEffect(name, emoji, forceOn)
    if activeEffects[name] and not forceOn then
        removeEffect(name)
        return
    end
    activeEffects[name] = true
    if not getCharacter() then return end
    if effectObjects[name] then
        for _,v in ipairs(effectObjects[name]) do pcall(function() v:Destroy() end) end
    end
    local objects = {}
    effectObjects[name] = objects

    local att = Instance.new("Attachment")
    att.Name = "Maxim_"..name
    att.Parent = root
    table.insert(objects,att)

    local particleNames = {
        ["Лёд"]=Color3.fromRGB(120,230,255),
        ["Огонёк"]=Color3.fromRGB(255,100,20),
        ["Рагнарёк"]=Color3.fromRGB(255,55,100),
        ["Комета"]=Color3.fromRGB(80,180,255),
        ["Звёзды"]=Color3.fromRGB(255,255,180),
        ["Радуга"]=Color3.fromRGB(200,100,255),
        ["Молния"]=Color3.fromRGB(255,245,90),
        ["Сердца"]=Color3.fromRGB(255,80,160),
        ["Пузырь"]=Color3.fromRGB(100,220,255),
        ["Конёк"]=Color3.fromRGB(200,170,255),
        ["Вихрь"]=Color3.fromRGB(150,100,255)
    }
    if particleNames[name] then
        local p = Instance.new("ParticleEmitter")
        p.Name = "Maxim_"..name.."_Particles"
        p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        p.Rate = (name == "Рагнарёк" or name == "Молния") and 70 or 28
        p.Lifetime = NumberRange.new(0.55,1.5)
        p.Speed = NumberRange.new(1,5)
        p.SpreadAngle = Vector2.new(180,180)
        p.LightEmission = 0.7
        p.Color = ColorSequence.new(particleNames[name], Color3.new(1,1,1))
        p.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.25),NumberSequenceKeypoint.new(1,0)})
        if name == "Пузырь" then
            p.Transparency = NumberSequence.new(0.25,1)
            p.RotSpeed = NumberRange.new(-50,50)
        end
        p.Parent = att
        table.insert(objects,p)
    end

    if name == "Бег" or name == "Неон" or name == "Базлайтер" or name == "Тень" then
        local h = Instance.new("Highlight")
        h.Name = "Maxim_"..name.."_Highlight"
        h.Adornee = character
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency = name == "Тень" and 0.25 or 0.78
        h.OutlineTransparency = name == "Тень" and 0.35 or 0.05
        h.FillColor = name == "Тень" and Color3.fromRGB(12,12,25) or currentTheme[2]
        h.OutlineColor = name == "Бег" and Color3.fromRGB(255,180,50) or currentTheme[2]
        h.Parent = gui
        table.insert(objects,h)
    end

    if name == "Огонёк" then
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255,110,30)
        light.Range = 12
        light.Brightness = 1.5
        light.Parent = att
        table.insert(objects,light)
    elseif name == "Лёд" then
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(100,220,255)
        light.Range = 10
        light.Brightness = 1
        light.Parent = att
        table.insert(objects,light)
    elseif name == "Рагнарёк" or name == "Вихрь" then
        local smoke = Instance.new("Smoke")
        smoke.Color = particleNames[name]
        smoke.Opacity = 0.18
        smoke.RiseVelocity = 3
        smoke.Size = 5
        smoke.Parent = root
        table.insert(objects,smoke)
    elseif name == "Бег" then
        local trailA = Instance.new("Attachment")
        trailA.Position = Vector3.new(-0.7,-1,0)
        trailA.Parent = root
        local trailB = Instance.new("Attachment")
        trailB.Position = Vector3.new(0.7,-1,0)
        trailB.Parent = root
        local tr = Instance.new("Trail")
        tr.Attachment0, tr.Attachment1 = trailA, trailB
        tr.Lifetime = 0.35
        tr.Color = ColorSequence.new(Color3.fromRGB(255,180,50))
        tr.Parent = root
        table.insert(objects,trailA); table.insert(objects,trailB); table.insert(objects,tr)
    elseif name == "Конёк" then
        local spark = Instance.new("Sparkles")
        spark.SparkleColor = Color3.fromRGB(190,150,255)
        spark.Parent = root
        table.insert(objects,spark)
    elseif name == "Сердца" then
        local p = Instance.new("ParticleEmitter")
        p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        p.Rate = 16
        p.Lifetime = NumberRange.new(1,2)
        p.Speed = NumberRange.new(1,2)
        p.Color = ColorSequence.new(Color3.fromRGB(255,70,150))
        p.Parent = att
        table.insert(objects,p)
    end
    toast(name.." • ON")
end

local function buildEffects()
    clearContent()
    sectionLabel("15 ДОПОЛНИТЕЛЬНЫХ ЭФФЕКТОВ — НАЖМИ ДЛЯ ВКЛ/ВЫКЛ")
    for i,e in ipairs(effects) do
        local b
        b = itemButton(e[2].."  "..e[1].."  •  ВЫКЛ", function()
            addEffect(e[1],e[2])
            b.Text = tr("  "..e[2].."  "..e[1].."  •  "..(activeEffects[e[1]] and "ВКЛ" or "ВЫКЛ"))
        end)
    end
end

local function buildVip()
    clearContent()
    sectionLabel("VIP ДОСТУП")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,-4,0,44)
    info.BackgroundTransparency = 1
    info.TextWrapped = true
    info.Text = tr(vipUnlocked and "VIP РАЗБЛОКИРОВАН" or "Введи секретный код. Английский: burger | Русский: рагнарёк")
    info.TextColor3 = currentTheme[2]
    info.Font = Enum.Font.GothamBold
    info.TextSize = 12
    info.Parent = content

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-4,0,38)
    input.BackgroundColor3 = currentTheme[3]
    input.PlaceholderText = "Секретный код..."
    input.Text = ""
    input.TextColor3 = Color3.new(1,1,1)
    input.PlaceholderColor3 = Color3.fromRGB(180,180,180)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = content
    corner(input,9)
    stroke(input,currentTheme[2])

    itemButton("ПРОВЕРИТЬ КОД", function()
        local raw = input.Text:gsub("%s+","")
        local folded = raw:lower()
        local upperMap = {
            ["А"]="а",["Б"]="б",["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ё"]="ё",
            ["Ж"]="ж",["З"]="з",["И"]="и",["Й"]="й",["К"]="к",["Л"]="л",["М"]="м",
            ["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",["С"]="с",["Т"]="т",["У"]="у",
            ["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",["Ъ"]="ъ",
            ["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я"
        }
        for upper,lower in pairs(upperMap) do folded = folded:gsub(upper,lower) end
        if folded == "burger" or folded == "рагнарёк" then
            vipUnlocked = true
            saveSettings()
            toast("VIP разблокирован")
            buildVip()
        else
            info.Text = tr("Неверный код — попробуй ещё раз")
        end
    end)

    if vipUnlocked then
        sectionLabel("5 VIP-ФУНКЦИЙ")
        itemButton("VIP 1 — Суперскорость", function()
            flightSpeed = 300
            speedOverride = true
            modeIndex = 19
            saveSettings()
            buildVip()
        end)
        itemButton("VIP 2 — Мягкое парение", function()
            modeIndex = 10
            flightSpeed = modes[10][2]
            baseVertical = 0
            saveSettings()
        end)
        itemButton("VIP 3 — Турбо-рывок", function()
            if getCharacter() then
                local burst = workspace.CurrentCamera.CFrame.LookVector * 180
                if flying and velocity then
                    dashVelocity = burst
                    dashUntil = os.clock() + 0.22
                else
                    root.AssemblyLinearVelocity = burst
                end
            end
        end)
        itemButton("VIP 4 — Неоновая аура", function()
            addEffect("Неон","✨")
        end)
        itemButton("VIP 5 — Полный сброс эффектов", function()
            for name in pairs(activeEffects) do removeEffect(name) end
            baseVertical = 0
            speedOverride = false
            flightSpeed = modes[modeIndex][2]
            saveSettings()
            buildVip()
        end)
    end
end

local lightState = {
    ambient=Lighting.Ambient, outdoor=Lighting.OutdoorAmbient,
    brightness=Lighting.Brightness, fog=Lighting.FogEnd,
    clock=Lighting.ClockTime, fullbright=false
}
local function setFullbright(state)
    lightState.fullbright=state
    if state then
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        Lighting.Brightness=3
        Lighting.FogEnd=1000000
        Lighting.ClockTime=12
    else
        Lighting.Ambient=lightState.ambient
        Lighting.OutdoorAmbient=lightState.outdoor
        Lighting.Brightness=lightState.brightness
        Lighting.FogEnd=lightState.fog
        Lighting.ClockTime=lightState.clock
    end
end

local function toggleFreecam()
    local cam=workspace.CurrentCamera
    if not cam then return end
    freecamOn=not freecamOn
    if freecamOn then
        savedCameraType=cam.CameraType
        savedCameraSubject=cam.CameraSubject
        cam.CameraType=Enum.CameraType.Scriptable
        local cf=cam.CFrame
        freecamConn=RunService.RenderStepped:Connect(function(dt)
            local currentCam=workspace.CurrentCamera
            if not freecamOn or not currentCam then return end
            local move=Vector3.zero
            local md=humanoid and humanoid.MoveDirection or Vector3.zero
            local look=Vector3.new(currentCam.CFrame.LookVector.X,0,currentCam.CFrame.LookVector.Z)
            local right=Vector3.new(currentCam.CFrame.RightVector.X,0,currentCam.CFrame.RightVector.Z)
            if look.Magnitude < 0.01 then look=Vector3.new(0,0,-1) else look=look.Unit end
            if right.Magnitude < 0.01 then right=Vector3.new(1,0,0) else right=right.Unit end
            local fwd=md:Dot(currentCam.CFrame.LookVector)
            local side=md:Dot(currentCam.CFrame.RightVector)
            move+=look*fwd+right*side
            if UIS:IsKeyDown(Enum.KeyCode.E) then move+=Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then move-=Vector3.yAxis end
            if move.Magnitude>0 then cf+=move.Unit*freecamSpeed*dt end
            currentCam.CFrame=cf
        end)
    else
        if freecamConn then freecamConn:Disconnect(); freecamConn=nil end
        cam.CameraType=savedCameraType or Enum.CameraType.Custom
        cam.CameraSubject=savedCameraSubject or humanoid
    end
    saveSettings()
end

local function buildTools()
    clearContent()
    sectionLabel("ИНСТРУМЕНТЫ")
    sectionLabel("ОСВЕЩЕНИЕ")
    itemButton("Fullbright: "..(lightState.fullbright and "ВКЛ" or "ВЫКЛ"),function()
        setFullbright(not lightState.fullbright); buildTools()
    end)
    itemButton("Время: "..math.floor(Lighting.ClockTime).."ч — +3ч",function()
        Lighting.ClockTime=(Lighting.ClockTime+3)%24; lightState.clock=Lighting.ClockTime; buildTools()
    end)
    itemButton("Убрать туман",function() Lighting.FogEnd=1000000; lightState.fog=Lighting.FogEnd; toast("Туман убран") end)
    itemButton("Вернуть туман",function() Lighting.FogEnd=lightState.fog; toast("Туман восстановлен") end)

    itemButton("Freecam: "..(freecamOn and "ВКЛ" or "ВЫКЛ"), function()
        toggleFreecam()
        buildTools()
    end)
    itemButton("Freecam speed −", function() freecamSpeed = math.max(10,freecamSpeed-10); saveSettings(); buildTools() end)
    itemButton("Freecam speed +", function() freecamSpeed = math.min(200,freecamSpeed+10); saveSettings(); buildTools() end)
    sectionLabel("ИГРОКИ — ЛОКАЛЬНОЕ ПЕРЕМЕЩЕНИЕ")
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            itemButton(plr.DisplayName.."  (@"..plr.Name..")", function()
                local targetChar = plr.Character
                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if getCharacter() and targetRoot then
                    root.CFrame = targetRoot.CFrame * CFrame.new(0,3,-3)
                    if velocity then velocity.Velocity = Vector3.zero end
                end
            end)
        end
    end
    sectionLabel("ГОРЯЧИЕ КЛАВИШИ")
    itemButton("F — Полёт | N — Noclip | H — HUD | V — Freecam | X — PANIC",function()
        toast("F / N / H / V / X")
    end)
    sectionLabel("HUD")
    itemButton("HUD: "..((hud and hud.Visible) and "ВКЛ" or "ВЫКЛ"), function()
        if hud then hud.Visible = not hud.Visible; saveSettings() end
        buildTools()
    end)
    sectionLabel("ПРОХОД СКВОЗЬ СТЕНЫ")
    itemButton("Noclip: "..(noclipOn and "ВКЛ" or "ВЫКЛ"), function()
        setNoclip(not noclipOn)
        buildTools()
    end)
    sectionLabel("ЗАКЛАДКИ ПОЗИЦИИ — ДО 5 ТОЧЕК")
    itemButton("＋ Сохранить текущую позицию", function()
        if getCharacter() then
            local currentCount, oldestIndex = 0, nil
            for index,bm in ipairs(bookmarks) do
                if bm.place == game.PlaceId then currentCount += 1; oldestIndex = oldestIndex or index end
            end
            if currentCount >= 5 and oldestIndex then table.remove(bookmarks,oldestIndex) end
            table.insert(bookmarks,{cf=root.CFrame,place=game.PlaceId})
            saveSettings()
            toast("Позиция сохранена")
            buildTools()
        end
    end)
    local visibleBookmarkIndex = 0
    for _,bm in ipairs(bookmarks) do
        if bm.place == game.PlaceId then
        visibleBookmarkIndex += 1
        local i = visibleBookmarkIndex
        itemButton("Загрузка точки "..i.."  •  Y="..math.floor(bm.cf.Position.Y), function()
            if bm.place == game.PlaceId and getCharacter() then
                root.CFrame = bm.cf + Vector3.new(0,3,0)
                if velocity then velocity.Velocity = Vector3.zero end
            end
        end)
        end
    end
end

local function setTab(name)
    for _,v in ipairs(tabs:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local names = {"Полёт","Темы","Эффекты","Инстр.","VIP"}
    local builders = {buildHome,buildThemes,buildEffects,buildTools,buildVip}
    for i,n in ipairs(names) do
        local b = makeButton(tabs,tr(n),UDim2.new(0.2,-3,1,0),UDim2.new((i-1)*0.2,2,0,0))
        b.TextSize = 10
        if (name == "Инструменты" and i == 4) or (name == n) then
            b.BackgroundTransparency = 0
        else
            b.BackgroundTransparency = 0.45
        end
        b.MouseButton1Click:Connect(function()
            activeTab = (i == 4) and "Инструменты" or n
            setTab(activeTab)
        end)
    end
    if name == "Темы" then buildThemes()
    elseif name == "Эффекты" then buildEffects()
    elseif name == "VIP" then buildVip()
    elseif name == "Инструменты" then buildTools()
    else buildHome() end
end

local keybindConn = UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.F then
        if flying then stopFlight() else startFlight() end
    elseif input.KeyCode==Enum.KeyCode.N then
        setNoclip(not noclipOn)
    elseif input.KeyCode==Enum.KeyCode.H then
        if hud then hud.Visible=not hud.Visible; saveSettings() end
    elseif input.KeyCode==Enum.KeyCode.V then
        toggleFreecam()
    elseif input.KeyCode==Enum.KeyCode.X then
        stopFlight()
        setNoclip(false)
        if freecamOn then toggleFreecam() end
        local names={}
        for name in pairs(activeEffects) do table.insert(names,name) end
        for _,name in ipairs(names) do removeEffect(name) end
        toast("PANIC — everything off")
    end
end)

local bubbleWasDragged = false
local bubbleDragStart = nil
local bubble = makeButton(gui,"M",UDim2.fromOffset(54,54),UDim2.new(0,18,0.55,0))
bubble.Name = "MaximBubble"
bubble.Visible = false
bubble.TextSize = 22
corner(bubble,27)
local bubbleStroke = stroke(bubble,Color3.new(1,1,1),2)

local function toggleMinimize()
    minimized = not minimized
    if minimized then
        if hud then hud.Position=UDim2.new(1,-192,0,12) end
        tween(main,{Size=UDim2.fromOffset(0,0)},0.22)
        task.delay(0.23,function() if minimized then main.Visible = false end end)
    else
        if hud then hud.Position=UDim2.new(1,-192,0,12) end
        main.Visible = true
        main.Size = UDim2.fromOffset(0,0)
        tween(main,{Size=mainTargetSize},0.22)
    end
end

bubble.MouseButton1Click:Connect(function()
    if bubbleWasDragged then bubbleWasDragged=false; return end
    if main.Visible then toggleMinimize()
    else minimized = false if hud then hud.Position=UDim2.new(1,-192,0,12) end main.Visible = true main.Size = UDim2.fromOffset(0,0) tween(main,{Size=mainTargetSize},0.22) end
end)
close.MouseButton1Click:Connect(toggleMinimize)
xbtn.MouseButton1Click:Connect(function()
    stopFlight()
    setNoclip(false)
    if freecamOn then
        freecamOn = false
        if freecamConn then freecamConn:Disconnect() freecamConn = nil end
        local cam = workspace.CurrentCamera
        if cam then cam.CameraType = Enum.CameraType.Custom; if humanoid then cam.CameraSubject = humanoid end end
    end
    local names={}
    for name in pairs(activeEffects) do table.insert(names,name) end
    for _,name in ipairs(names) do removeEffect(name) end
    saveSettings()
    if keybindConn then keybindConn:Disconnect() end
    gui:Destroy()
end)

-- Drag main window and floating M bubble (touch + mouse).
local function makeDraggable(handle, object)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if object == bubble and delta.Magnitude > 4 then bubbleWasDragged = true end
            object.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if object == bubble and bubbleWasDragged then
                task.delay(0.15, function() bubbleWasDragged = false end)
            end
        end
    end)
end
makeDraggable(top,main)
makeDraggable(bubble,bubble)

-- Simple touch-friendly vertical controls displayed only while flight is active.
up = makeButton(gui,"▲",UDim2.fromOffset(48,48),UDim2.new(1,-70,0.58,0))
down = makeButton(gui,"▼",UDim2.fromOffset(48,48),UDim2.new(1,-70,0.70,0))
up.TextSize, down.TextSize = 20,20
up.Visible, down.Visible = false, false
up.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then holdingUp = true end
end)
up.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then holdingUp = false end
end)
down.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then holdingDown = true end
end)
down.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then holdingDown = false end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        holdingUp, holdingDown = false, false
    end
end)

hud = Instance.new("Frame")
hud.Name = "FlightHUD"
hud.Size = UDim2.fromOffset(180,78)
hud.Position = UDim2.new(1,-192,0,12)
hud.BackgroundColor3 = currentTheme[3]
hud.BackgroundTransparency = 0.2
hud.Visible = hudVisiblePreference == nil and true or hudVisiblePreference
hud.Parent = gui
corner(hud,10)
stroke(hud,currentTheme[2],1.5)
hudText = Instance.new("TextLabel")
hudText.Size = UDim2.new(1,-10,1,-10)
hudText.Position = UDim2.fromOffset(5,5)
hudText.BackgroundTransparency = 1
hudText.TextColor3 = currentTheme[2]
hudText.Font = Enum.Font.Code
hudText.TextSize = 12
hudText.TextXAlignment = Enum.TextXAlignment.Left
hudText.TextYAlignment = Enum.TextYAlignment.Top
hudText.Parent = hud
RunService.RenderStepped:Connect(function()
    local y = root and root.Parent and root.Position.Y or 0
    if hudText and hudText.Parent then
        hudText.Text = string.format("FLIGHT: %s\nMODE: %s\nSPEED: %d\nALT: %.0f",
            flying and "ON" or "OFF", modes[modeIndex][1], math.floor(flightSpeed), y)
    end
end)

-- Initial launcher: language and device layout choice.
local launcher = Instance.new("Frame")
launcher.Size = UDim2.fromOffset(300,250)
launcher.Position = UDim2.new(0.5,-150,0.5,-125)
launcher.BackgroundColor3 = currentTheme[3]
launcher.Parent = gui
corner(launcher,16)
stroke(launcher,currentTheme[2],2)

local launchTitle = Instance.new("TextLabel")
launchTitle.Size = UDim2.new(1,-20,0,38)
launchTitle.Position = UDim2.fromOffset(10,8)
launchTitle.BackgroundTransparency = 1
launchTitle.Name = "LauncherTitle"
launchTitle.Text = "MAXIM FLIGHT HUB"
launchTitle.TextColor3 = Color3.new(1,1,1)
launchTitle.Font = Enum.Font.GothamBold
launchTitle.TextSize = 17
launchTitle.Parent = launcher

local langBtn = makeButton(launcher,"Язык: Русский",UDim2.new(1,-24,0,34),UDim2.fromOffset(12,55))
local deviceBtn = makeButton(launcher,"Устройство: Планшет",UDim2.new(1,-24,0,34),UDim2.fromOffset(12,97))
local devices = {"Планшет","Телефон","ПК","Консоль"}
local di = table.find(devices, device) or 1
local deviceEnglish = { ["Планшет"]="Tablet", ["Телефон"]="Phone", ["ПК"]="PC", ["Консоль"]="Console" }
langBtn.Text = lang == "RU" and "Язык: Русский" or "Language: English"
deviceBtn.Text = lang == "RU" and ("Устройство: "..device) or ("Device: "..(deviceEnglish[device] or device))
deviceBtn.MouseButton1Click:Connect(function()
    di = di % #devices + 1
    device = devices[di]
    saveSettings()
    deviceBtn.Text = lang == "RU" and ("Устройство: "..device) or ("Device: "..(deviceEnglish[device] or device))
end)
langBtn.MouseButton1Click:Connect(function()
    lang = lang == "RU" and "EN" or "RU"
    saveSettings()
    langBtn.Text = lang == "RU" and "Язык: Русский" or "Language: English"
    deviceBtn.Text = lang == "RU" and ("Устройство: "..device) or ("Device: "..(deviceEnglish[device] or device))
end)
local launch = makeButton(launcher,"ЗАПУСТИТЬ HUB",UDim2.new(1,-24,0,42),UDim2.fromOffset(12,151))
launch.MouseButton1Click:Connect(function()
    launcher:Destroy()
    bubble.Visible = true
    main.Visible = true
    setTab("Полёт")
    if device == "Телефон" then
        mainTargetSize = UDim2.fromOffset(300,410)
    elseif device == "ПК" then
        mainTargetSize = UDim2.fromOffset(370,470)
    elseif device == "Консоль" then
        mainTargetSize = UDim2.fromOffset(360,450)
    else
        mainTargetSize = UDim2.fromOffset(330,440)
    end
    main.Size = mainTargetSize
    applyTheme(themeIndex)
    saveSettings()
    if lang == "EN" then
        title.Text = "MAXIM FLIGHT HUB"
    end
end)

-- Start with main hidden until launcher choice is completed.
main.Visible = false
up.Visible = false
down.Visible = false

LP.CharacterAdded:Connect(function(newCharacter)
    if flying then stopFlight() end
    if freecamOn then
        freecamOn = false
        if freecamConn then freecamConn:Disconnect() freecamConn = nil end
        local cam = workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            local newHum = newCharacter:WaitForChild("Humanoid",10)
            if newHum then cam.CameraSubject = newHum end
        end
    end
    character, humanoid, root = newCharacter, nil, nil
    local newHumanoid = newCharacter:WaitForChild("Humanoid",10)
    local newRoot = newCharacter:WaitForChild("HumanoidRootPart",10)
    humanoid, root = newHumanoid, newRoot
    local newCam=workspace.CurrentCamera
    if newCam then camBaseFOV=newCam.FieldOfView end
    if noclipOn then setNoclip(true) end
    local restoreEffects={}
    for name in pairs(activeEffects) do table.insert(restoreEffects,name) end
    for _,name in ipairs(restoreEffects) do
        effectObjects[name] = nil
        addEffect(name,nil,true)
    end
    refreshFlightButton()
end)

print("[MAXIM FLIGHT HUB] FIXED v2 loaded. Delta / Android client script.")
