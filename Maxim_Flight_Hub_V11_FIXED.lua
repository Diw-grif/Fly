-- MAXIM FLIGHT HUB — DELTA / ANDROID
-- Client-side flight and visual hub. Run from Delta's executor.
-- 24 visual themes, 25 flight presets, 10 poses, 10 animations, 11 aura presets, 15 animated effects, 5 VIP tools.

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
    {"Neo Pink", Color3.fromRGB(255,55,170), Color3.fromRGB(35,12,35), "aurora"},
    {"Red White", Color3.fromRGB(255,55,65), Color3.fromRGB(28,28,32), "carbon"},
    {"Cyber Blue", Color3.fromRGB(45,170,255), Color3.fromRGB(10,22,40), "circuit"},
    {"Purple", Color3.fromRGB(170,90,255), Color3.fromRGB(25,14,40), "nebula"},
    {"Emerald", Color3.fromRGB(40,230,150), Color3.fromRGB(10,30,25), "grid"},
    {"Gold", Color3.fromRGB(255,190,55), Color3.fromRGB(38,28,10), "lux"},
    {"Ice", Color3.fromRGB(110,235,255), Color3.fromRGB(12,30,40), "frost"},
    {"Lava", Color3.fromRGB(255,100,25), Color3.fromRGB(38,15,8), "ember"},
    {"Ocean", Color3.fromRGB(35,120,220), Color3.fromRGB(8,20,38), "waves"},
    {"Toxic", Color3.fromRGB(170,255,35), Color3.fromRGB(22,32,8), "hazard"},
    {"Violet", Color3.fromRGB(210,80,255), Color3.fromRGB(30,10,40), "prism"},
    {"Rose", Color3.fromRGB(255,120,145), Color3.fromRGB(38,16,25), "silk"},
    {"Monochrome", Color3.fromRGB(220,220,230), Color3.fromRGB(20,20,24), "minimal"},
    {"Mint", Color3.fromRGB(100,255,210), Color3.fromRGB(10,32,28), "glass"},
    {"Sunset", Color3.fromRGB(255,130,70), Color3.fromRGB(38,18,24), "sunset"},
    {"Matrix", Color3.fromRGB(0,255,100), Color3.fromRGB(5,20,10), "matrix"},
    {"Arctic", Color3.fromRGB(170,220,255), Color3.fromRGB(15,25,42), "crystal"},
    {"Cherry", Color3.fromRGB(220,25,70), Color3.fromRGB(35,8,18), "velvet"},
    {"Aqua", Color3.fromRGB(0,230,230), Color3.fromRGB(8,30,34), "wave"},
    {"Dark Neon", Color3.fromRGB(255,255,70), Color3.fromRGB(12,12,18), "scanline"},
    {"Minecraft Blocks", Color3.fromRGB(110,205,75), Color3.fromRGB(27,48,35), "minecraft"},
    {"Brawl Stars", Color3.fromRGB(255,190,35), Color3.fromRGB(40,22,65), "brawl"},
    {"Roblox Classic", Color3.fromRGB(235,65,55), Color3.fromRGB(28,31,38), "roblox"},
    {"GTA V Night", Color3.fromRGB(100,255,155), Color3.fromRGB(17,28,29), "gtav"}
}

local modes = {
    {"Обычный", 55, 1.0}, {"Быстрый", 90, 1.0}, {"Сверхскорость", 145, 1.0},
    {"Медленный", 25, 1.0}, {"Плавный", 45, 0.55}, {"Рывками", 85, 0.25},
    {"Низкий полёт", 55, 0.7}, {"Высокий полёт", 55, 1.5}, {"Ракета", 180, 1.0},
    {"Парение", 35, 0.15}, {"Лунный", 65, 0.8}, {"Невесомость", 50, 0.35},
    {"Спираль", 75, 0.9}, {"Зигзаг", 80, 0.8}, {"Точный", 35, 0.4},
    {"Турбо", 220, 1.0}, {"Призрак", 70, 0.6}, {"Орбита", 60, 1.0},
    {"Экстрим", 260, 1.0}, {"Максим", 120, 1.0},
    {"Камера 3D", 85, 1.0}, {"Истребитель", 130, 1.0},
    {"Комета 3D", 175, 1.0}, {"Грави-дайв", 95, 1.0},
    {"Астральный", 110, 1.0}
}

-- These five presets use the camera's complete 3D look vector (pitch + yaw).
-- Vertical touch buttons are intentionally hidden while one is selected.
local cameraFlightModes = {
    ["Камера 3D"] = true, ["Истребитель"] = true,
    ["Комета 3D"] = true, ["Грави-дайв"] = true,
    ["Астральный"] = true
}
local function isCameraFlightMode()
    return cameraFlightModes[modes[modeIndex] and modes[modeIndex][1]] == true
end

local effects = {
    {"Бег", "🏃"}, {"Лёд", "❄️"}, {"Огонёк", "🔥"}, {"Рагнарёк", "⚡"},
    {"Вихрь", "O"}, {"Конёк", "🐎"}, {"Базлайтер", "💡"},
    {"Комета", "☄️"}, {"Неон", "✨"}, {"Пузырь", "O"},
    {"Тень", "🌑"}, {"Радуга", "🌈"}, {"Молния", "🌩️"},
    {"Сердца", "💗"}, {"Звёзды", "🌟"}
}

local themeIndex, modeIndex = 1, 1
local currentTheme = themes[1]
local auraPresets = {
    {"Северное сияние", Color3.fromRGB(80,255,210)},
    {"Плазма", Color3.fromRGB(190,70,255)},
    {"Солнечная корона", Color3.fromRGB(255,190,55)},
    {"Лунный свет", Color3.fromRGB(150,180,255)},
    {"Феникс", Color3.fromRGB(255,75,35)},
    {"Туманность", Color3.fromRGB(100,90,255)},
    {"Ледяной дух", Color3.fromRGB(120,230,255)},
    {"Токсичный импульс", Color3.fromRGB(160,255,40)},
    {"Розовый импульс", Color3.fromRGB(255,70,175)},
    {"Галактика", Color3.fromRGB(100,60,220)},
    {"Кубический импульс", Color3.fromRGB(105,225,95)}
}
local auraIndex = 1
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
local hudEnabled = true
-- Flight pose / animation controls (visual-only; movement controller stays intact).
local flightPoseIndex, flightAnimationIndex = 1, 1
local flightPoseFrozen = false
local flightControlProfile = 1 -- 1=native, 2=force 3D camera controls, 3=force flat controls
local savedMotorTransforms = {}
local setDockTheme, toggleMinimize, refreshShortcutTheme
local freecamOn, freecamConn, savedCameraType, savedCameraSubject = false, nil, nil, nil
local freecamSpeed = 60
local noclipOn, noclipConn = false, nil
local bookmarks = {}
local activeTab = "Полёт"
local flightButton
local mainTargetSize = UDim2.fromOffset(390,530)
local lang = "RU"
local device = "Планшет"
local hudVisiblePreference = nil
local savePending = false
local globalConnections = {}

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
            theme=themeIndex, mode=modeIndex, speed=flightSpeed, aura=auraIndex,
            pose=flightPoseIndex, animation=flightAnimationIndex, poseFrozen=flightPoseFrozen, controlProfile=flightControlProfile,
            speedOverride=speedOverride, lang=lang, device=device,
            freecamSpeed=freecamSpeed,
            hudVisible=hudEnabled,
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
        if type(d.aura)=="number" and auraPresets[d.aura] then auraIndex=d.aura end
        if type(d.pose)=="number" and d.pose>=1 and d.pose<=10 then flightPoseIndex=d.pose end
        if type(d.animation)=="number" and d.animation>=1 and d.animation<=10 then flightAnimationIndex=d.animation end
        if type(d.poseFrozen)=="boolean" then flightPoseFrozen=d.poseFrozen end
        if type(d.controlProfile)=="number" and d.controlProfile>=1 and d.controlProfile<=3 then flightControlProfile=d.controlProfile end
        if type(d.speed)=="number" then flightSpeed=math.clamp(d.speed,5,300) end
        if type(d.speedOverride)=="boolean" then speedOverride=d.speedOverride end
        if d.lang=="RU" or d.lang=="EN" then lang=d.lang end
        if type(d.device)=="string" then device=d.device end
        -- VIP is session-only: a saved settings file must never grant access.
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
hudEnabled = hudVisiblePreference == nil and true or hudVisiblePreference

local translations = {
    ["Полёт"]="Flight",["Темы"]="Themes",["Эффекты"]="Effects",["Инстр."]="Tools",["VIP"]="VIP",
    ["ПОЛЁТ"]="FLIGHT",["ПОЛЁТ: ВЫКЛ"]="FLIGHT: OFF",["ПОЛЁТ: ВКЛ"]="FLIGHT: ON",
    ["Режим"]="Mode",["следующий"]="next",["Скорость"]="Speed",["Текущая скорость"]="Current speed",
    ["ВЕРТИКАЛЬНОЕ УПРАВЛЕНИЕ"]="VERTICAL CONTROL",["Вверх"]="Up",["Вниз"]="Down",
    ["Сброс высоты"]="Reset altitude",["БЫСТРЫЙ ВЫБОР РЕЖИМА"]="QUICK MODE SELECT",
    ["20 ТЕМ • ТЕКСТУРЫ • СТИЛИ"]="20 THEMES • TEXTURES • STYLES",
    ["24 ТЕМЫ • ТЕКСТУРЫ • СТИЛИ"]="24 THEMES • TEXTURES • STYLES",
    ["Minecraft • Brawl Stars • Roblox • GTA V — отдельные текстуры меню"]="Minecraft • Brawl Stars • Roblox • GTA V menu textures",["15 ДОПОЛНИТЕЛЬНЫХ ЭФФЕКТОВ — НАЖМИ ДЛЯ ВКЛ/ВЫКЛ"]="15 EXTRA EFFECTS — TAP TO TOGGLE",
    ["VIP ДОСТУП"]="VIP ACCESS",["VIP доступ активируется секретным кодом"]="VIP access requires your private code",
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
    ["Призрак"]="Ghost",["Орбита"]="Orbit",["Экстрим"]="Extreme",["Максим"]="Maxim",["Камера 3D"]="Camera 3D",["Истребитель"]="Fighter",["Комета 3D"]="Comet 3D",["Грави-дайв"]="Gravity Dive",["Астральный"]="Astral",
    ["Бег"]="Run",["Лёд"]="Ice",["Огонёк"]="Flame",["Рагнарёк"]="Ragnarok",["Вихрь"]="Vortex",
    ["Конёк"]="Skater",["Базлайтер"]="Baselighter",["Комета"]="Comet",["Неон"]="Neon",
    ["Пузырь"]="Bubble",["Тень"]="Shadow",["Радуга"]="Rainbow",["Молния"]="Lightning",
    ["Сердца"]="Hearts",["Звёзды"]="Stars",
    ["VIP разблокирован"]="VIP unlocked",["Позиция сохранена"]="Position saved",
    ["Туман убран"]="Fog removed",["Туман восстановлен"]="Fog restored",
    ["Введи секретный код..."]="Enter secret code...",
    ["Тема: "]="Theme: ",["Noclip: "]="Noclip: ",
    ["25 РЕЖИМОВ ПОЛЁТА"]="25 FLIGHT MODES",["РЕЖИМЫ ПОЛЁТА ПО КАМЕРЕ — 3D"]="CAMERA-LOCKED 3D FLIGHT",
    ["УПРАВЛЕНИЕ: ПОЛНОЕ НАПРАВЛЕНИЕ КАМЕРЫ 3D"]="CONTROL: FULL 3D CAMERA DIRECTION",
    ["Аура"]="Aura",
    ["Аура выбрана: "]="Aura selected: ",
    ["Кубический импульс"]="Cubic Pulse",
    ["Окно ушло за экран. Вернуть?"]="Window moved off-screen. Restore?",
    ["ДА, ВЕРНУТЬ"]="YES, RESTORE",["НЕТ"]="NO",["Секунды (например 60)"]="Seconds (e.g. 60)",
    ["ВЕРНУТЬ ЧЕРЕЗ"]="RESTORE IN",["↩ ВЕРНУТЬ"]="↩ RESTORE",
    ["Северное сияние"]="Aurora",["Плазма"]="Plasma",["Солнечная корона"]="Solar Crown",
    ["Лунный свет"]="Moonlight",["Феникс"]="Phoenix",["Туманность"]="Nebula",
    ["Ледяной дух"]="Frost Spirit",["Токсичный импульс"]="Toxic Pulse",
    ["Розовый импульс"]="Pink Pulse",["Галактика"]="Galaxy"
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
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid",10)
    root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart",10)
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
main.Size = UDim2.fromOffset(390, 530)
main.Position = UDim2.new(0.5, -195, 0.5, -265)
main.BackgroundColor3 = currentTheme[3]
main.Parent = gui
corner(main, 20)
main.ClipsDescendants = true
local mainStroke = stroke(main, currentTheme[2], 2.5)
local function getResponsiveMainSize()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(390,700)
    return UDim2.fromOffset(
        math.min(mainTargetSize.X.Offset,math.max(240,vp.X-16)),
        math.min(mainTargetSize.Y.Offset,math.max(320,vp.Y-16))
    )
end
local function recenterMain()
    local size = getResponsiveMainSize()
    main.Size = size
    main.Position = UDim2.new(0.5,-size.X.Offset/2,0.5,-size.Y.Offset/2)
end

-- Procedural theme texture layer: no external image assets required.
local textureLayer = Instance.new("Frame")
textureLayer.Name = "ThemeTexture"
textureLayer.Size = UDim2.fromScale(1,1)
textureLayer.BackgroundTransparency = 1
textureLayer.ClipsDescendants = true
textureLayer.ZIndex = 1
textureLayer.Parent = main
local textureMarks = {}
local textureDots = {}
local textureRings = {}
local themeDecor = Instance.new("Frame")
themeDecor.Name = "ThemeDecor"
themeDecor.Size = UDim2.fromScale(1,1)
themeDecor.BackgroundTransparency = 1
themeDecor.ZIndex = 2
themeDecor.Parent = textureLayer
local minecraftBlocks, brawlStars, robloxStuds = {}, {}, {}
for i=1,42 do
    local block=Instance.new("Frame")
    block.Name="VoxelBlock"
    local size=12+(i%4)*7
    block.Size=UDim2.fromOffset(size,size)
    block.Position=UDim2.new((i*29%96)/100,0,(i*41%94)/100,0)
    block.BackgroundColor3=(i%3==0) and Color3.fromRGB(83,155,65) or Color3.fromRGB(115,190,80)
    block.BackgroundTransparency=0.32+(i%3)*0.12
    block.BorderSizePixel=0
    block.ZIndex=2
    block.Visible=false
    block.Parent=themeDecor
    local edge=Instance.new("UIStroke")
    edge.Color=Color3.fromRGB(25,65,35)
    edge.Thickness=1
    edge.Transparency=0.25
    edge.Parent=block
    table.insert(minecraftBlocks,block)
end
for i=1,18 do
    local star=Instance.new("TextLabel")
    star.Name="BrawlStar"
    star.BackgroundTransparency=1
    star.Size=UDim2.fromOffset(26+(i%3)*8,26+(i%3)*8)
    star.Position=UDim2.new((i*43%94)/100,0,(i*31%90)/100,0)
    star.Text=(i%3==0) and "✦" or "★"
    star.TextColor3=(i%2==0) and Color3.fromRGB(255,205,45) or Color3.fromRGB(255,120,45)
    star.TextTransparency=0.18
    star.TextScaled=true
    star.Font=Enum.Font.GothamBlack
    star.ZIndex=2
    star.Visible=false
    star.Parent=themeDecor
    table.insert(brawlStars,star)
end
for i=1,36 do
    local stud=Instance.new("Frame")
    stud.Name="RobloxStud"
    local size=8+(i%3)*4
    stud.Size=UDim2.fromOffset(size,size)
    stud.Position=UDim2.new((i*37%96)/100,0,(i*23%94)/100,0)
    stud.BackgroundColor3=Color3.fromRGB(245,75,65)
    stud.BackgroundTransparency=0.25
    stud.BorderSizePixel=0
    stud.ZIndex=2
    stud.Visible=false
    stud.Parent=themeDecor
    corner(stud,3)
    local edge=Instance.new("UIStroke")
    edge.Color=Color3.fromRGB(255,255,255)
    edge.Transparency=0.55
    edge.Thickness=1
    edge.Parent=stud
    table.insert(robloxStuds,stud)
end
local gtaLabel=Instance.new("TextLabel")
gtaLabel.Name="GTAVTexture"
gtaLabel.Size=UDim2.new(1,0,0,82)
gtaLabel.Position=UDim2.new(0,0,0.38,0)
gtaLabel.BackgroundTransparency=1
gtaLabel.Text="V"
gtaLabel.TextColor3=Color3.fromRGB(100,255,155)
gtaLabel.TextTransparency=0.88
gtaLabel.TextScaled=true
gtaLabel.Font=Enum.Font.GothamBlack
gtaLabel.Rotation=-8
gtaLabel.ZIndex=2
gtaLabel.Visible=false
gtaLabel.Parent=themeDecor
for i=1,18 do
    local dot=Instance.new("Frame")
    dot.Name="TextureDot"
    dot.Size=UDim2.fromOffset((i%3)+2,(i%3)+2)
    dot.Position=UDim2.new((i*37%97)/100,0,(i*23%91)/100,0)
    dot.BackgroundColor3=currentTheme[2]
    dot.BackgroundTransparency=0.72
    dot.BorderSizePixel=0
    dot.ZIndex=1
    dot.Parent=textureLayer
    corner(dot,10)
    table.insert(textureDots,dot)
end
for i=1,4 do
    local ring=Instance.new("Frame")
    ring.Name="TextureRing"
    ring.AnchorPoint=Vector2.new(0.5,0.5)
    ring.Position=UDim2.new((i*23%80)/100,0,(i*31%80)/100,0)
    ring.Size=UDim2.fromOffset(80+i*28,80+i*28)
    ring.BackgroundTransparency=1
    ring.ZIndex=1
    ring.Parent=textureLayer
    corner(ring,100)
    local edge=Instance.new("UIStroke")
    edge.Color=currentTheme[2]
    edge.Thickness=1.5
    edge.Transparency=0.78
    edge.Parent=ring
    table.insert(textureRings,ring)
end
for i=1,14 do
    local mark = Instance.new("Frame")
    mark.Name = "TextureMark"
    mark.BorderSizePixel = 0
    mark.BackgroundColor3 = currentTheme[2]
    mark.BackgroundTransparency = 0.91
    mark.Size = UDim2.new(1.5,0,0,1)
    mark.Position = UDim2.new(-0.2,0,(i-1)/14,0)
    mark.Rotation = (i%2==0) and -18 or 18
    mark.ZIndex = 1
    mark.Parent = textureLayer
    table.insert(textureMarks,mark)
end
local mainGradient = Instance.new("UIGradient")
mainGradient.Rotation = 35
mainGradient.Color = ColorSequence.new(currentTheme[3], currentTheme[2]:Lerp(currentTheme[3],0.72))
mainGradient.Parent = main
local topGradient = Instance.new("UIGradient")
topGradient.Rotation = 0
topGradient.Color = ColorSequence.new(currentTheme[2], currentTheme[2]:Lerp(Color3.new(1,1,1),0.18))
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 54)
top.BackgroundColor3 = currentTheme[2]
top.BackgroundTransparency = 0.12
top.Parent = main
topGradient.Parent = top
corner(top, 18)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -104, 0, 28)
title.Position = UDim2.fromOffset(16, 5)
title.BackgroundTransparency = 1
title.Name = "HubTitle"
title.Text = "MAXIM FLIGHT HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top
local subtitle = Instance.new("TextLabel")
subtitle.Name = "HubSubtitle"
subtitle.Size = UDim2.new(1,-110,0,14)
subtitle.Position = UDim2.fromOffset(17,32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "FLIGHT EXPERIENCE  •  MAXIM"
subtitle.TextColor3 = Color3.fromRGB(225,225,235)
subtitle.TextTransparency = 0.12
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = top

local function makeButton(parent, text, size, pos)
    local b = Instance.new("TextButton")
    b.Size, b.Position = size, pos
    b.BackgroundColor3 = currentTheme[2]
    b.BackgroundTransparency = 0.12
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 12)
    local buttonGradient=Instance.new("UIGradient")
    buttonGradient.Color=ColorSequence.new(currentTheme[2],currentTheme[2]:Lerp(currentTheme[3],0.38))
    buttonGradient.Rotation=35
    buttonGradient.Parent=b
    local edge = stroke(b,currentTheme[2],1)
    edge.Transparency = 0.48
    b.MouseEnter:Connect(function() tween(b,{BackgroundTransparency=0.02},0.12) end)
    b.MouseLeave:Connect(function() tween(b,{BackgroundTransparency=0.12},0.12) end)
    return b
end

local close = makeButton(top, "—", UDim2.fromOffset(34,30), UDim2.new(1,-76,0,7))
local xbtn = makeButton(top, "×", UDim2.fromOffset(34,30), UDim2.new(1,-38,0,7))

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,-24,1,-70)
pages.Position = UDim2.fromOffset(12,62)
pages.BackgroundTransparency = 1
pages.Parent = main

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1,0,0,40)
tabs.BackgroundTransparency = 1
tabs.Parent = pages

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,0,1,-49)
content.Position = UDim2.fromOffset(0,49)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = currentTheme[2]
content.CanvasSize = UDim2.new()
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = pages

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,9)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local pageActionCount, pageDetachedCount = 0, 0
local detachedRecords = {}
local syncDetachedForTab
local function clearContent()
    pageActionCount, pageDetachedCount = 0, 0
    -- Detached placeholders belong to their original tab. Keep their instances,
    -- but unparent them while another tab is being built.
    if detachedRecords then
        for _,rec in ipairs(detachedRecords) do
            if rec.placeholder and rec.placeholder.Parent == content then
                rec.placeholder.Parent = nil
            end
        end
    end
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
    task.defer(function()
        if syncDetachedForTab and content and content.Parent then
            syncDetachedForTab(activeTab)
        end
    end)
end

local function sectionLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-4,0,29)
    l.BackgroundColor3 = currentTheme[2]
    l.BackgroundTransparency = 0.88
    l.Text = tr(text)
    l.TextColor3 = currentTheme[2]
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = content
    corner(l,8)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,10)
    pad.Parent = l
    return l
end

local createShortcut
local setTab
local bubble
local shortcutItems = {}
local shortcutCounter = 0
local function itemButton(text, callback)
    pageActionCount += 1
    local b = makeButton(content, tr(text), UDim2.new(1,-4,0,39), UDim2.new())
    b:SetAttribute("MaximActionLabel",tostring(text))
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "   " .. tr(text)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,4)
    pad.Parent = b
    local holdActive, holdTriggered, holdToken = false, false, 0
    local actionTab = activeTab
    local function invokeAction()
        local displayedTab = activeTab
        callback()
        if displayedTab ~= actionTab and setTab then
            setTab(displayedTab)
        end
    end
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdActive = true
            holdTriggered = false
            holdToken += 1
            local thisToken = holdToken
            task.delay(5, function()
                if holdActive and holdToken == thisToken and b.Parent == content then
                    holdTriggered = true
                    if createShortcut then createShortcut(text, callback, b) end
                end
            end)
        end
    end)
    b.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdActive = false
        end
    end)
    b.MouseButton1Click:Connect(function()
        if holdTriggered then holdTriggered = false; return end
        if b:GetAttribute("MaximSuppressClick") then
            b:SetAttribute("MaximSuppressClick",false)
            return
        end
        invokeAction()
    end)
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

-- Floating actions keep their original tab/order and own every temporary input connection.
local recoveryPrompt, recoveryFlag, recoveryPending = nil, nil, false
local recoveryTarget = nil
local recoveryConnections = {}
local shortcutPanel, shortcutPanelLayout, gatherButton
local pendingReturns = {}
local miniMenuOpen = false
local updateGatherButton

local function disconnectConnections(list)
    if not list then return end
    for _, connection in ipairs(list) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(list)
end

local function getViewportSize()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(390,700)
end

local function clampGuiObject(obj, margin)
    if not obj or not obj.Parent then return false end
    local vp = getViewportSize()
    local size = obj.AbsoluteSize
    local m = margin or 8
    local maxX = math.max(m, vp.X - size.X - m)
    local maxY = math.max(m, vp.Y - size.Y - m)
    local x = math.clamp(obj.AbsolutePosition.X, m, maxX)
    local y = math.clamp(obj.AbsolutePosition.Y, m, maxY)
    obj.Position = UDim2.fromOffset(
        x + size.X * obj.AnchorPoint.X,
        y + size.Y * obj.AnchorPoint.Y
    )
    return true
end

local function setShortcutFloatingGeometry(obj, position)
    obj.AnchorPoint = Vector2.new(0,0)
    obj.Size = UDim2.fromOffset(148,38)
    if position then
        obj.Position = UDim2.fromOffset(position.X,position.Y)
    end
    obj.AutomaticSize = Enum.AutomaticSize.None
    obj.TextScaled = false
    obj.TextSize = 10
    obj.TextTruncate = Enum.TextTruncate.AtEnd
end

refreshShortcutTheme = function()
    for _,obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and (obj.Name:find("MaximShortcut") or obj.Name=="MaximGatherButton" or obj.Name=="MaximMiniAction") then
            obj.BackgroundColor3 = currentTheme[2]
            local grad=obj:FindFirstChildOfClass("UIGradient")
            if grad then grad.Color=ColorSequence.new(currentTheme[2],currentTheme[2]:Lerp(currentTheme[3],0.38)) end
        end
    end
    if shortcutPanel then
        shortcutPanel.BackgroundColor3=currentTheme[3]
        local edge=shortcutPanel:FindFirstChildOfClass("UIStroke")
        if edge then edge.Color=currentTheme[2] end
    end
end

local function renumberContentChildren(insertedButton, preferredIndex)
    local children = {}
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("GuiObject") and child ~= insertedButton then
            table.insert(children,child)
        end
    end
    if insertedButton then
        table.insert(children,math.clamp(preferredIndex or (#children+1),1,#children+1),insertedButton)
    end
    for index, child in ipairs(children) do
        child.LayoutOrder = index
    end
end

syncDetachedForTab = function(tabName)
    if not content or not content.Parent then return end
    local insertions = {}
    pageDetachedCount = 0

    for _, rec in ipairs(detachedRecords) do
        if rec.tab == tabName and rec.placeholder then
            local duplicate
            for _, child in ipairs(content:GetChildren()) do
                if child:IsA("TextButton") and child:GetAttribute("MaximActionLabel") == rec.label then
                    duplicate = child
                    break
                end
            end
            if duplicate then duplicate:Destroy() end
            rec.placeholder.Parent = nil
            table.insert(insertions,{object=rec.placeholder,index=rec.layoutOrder})
            pageDetachedCount += 1
        end
    end

    for index = #pendingReturns,1,-1 do
        local rec = pendingReturns[index]
        if rec.tab == tabName and rec.button then
            local duplicate
            for _, child in ipairs(content:GetChildren()) do
                if child:IsA("TextButton") and child:GetAttribute("MaximActionLabel") == rec.label then
                    duplicate = child
                    break
                end
            end
            if duplicate then duplicate:Destroy() end
            rec.button.Parent = nil
            table.insert(insertions,{object=rec.button,index=rec.layoutOrder})
            table.remove(pendingReturns,index)
        end
    end

    table.sort(insertions,function(a,b) return a.index < b.index end)
    for _, item in ipairs(insertions) do
        item.object.Parent = content
        renumberContentChildren(item.object,item.index)
    end
    if updateGatherButton then updateGatherButton() end
end

local function restoreHubLayout(target)
    target = target or main
    if not target or not target.Parent then return false end

    if target == main then
        local vp = getViewportSize()
        local width = math.min(mainTargetSize.X.Offset,math.max(240,vp.X-16))
        local height = math.min(mainTargetSize.Y.Offset,math.max(320,vp.Y-16))
        main.Size = UDim2.fromOffset(width,height)
        main.Position = UDim2.fromOffset((vp.X-width)/2,(vp.Y-height)/2)
        -- Keep the user's minimized/visible state; restoring the main window must not
        -- unminimize it or alter the dock, HUD, tabs, or detached shortcuts.
        if main.Visible then
            tween(main,{Size=UDim2.fromOffset(width,height)},0.18)
        end
    else
        clampGuiObject(target,8)
    end

    toast("Положение элемента восстановлено")
    return true
end

local function makeRecoveryFlag()
    if recoveryFlag and recoveryFlag.Parent then return end
    local flag = makeButton(gui,"⚑",UDim2.fromOffset(39,34),UDim2.fromOffset(8,8))
    flag.Name = "MaximRecoveryFlag"
    flag.ZIndex = 120
    flag.BackgroundColor3 = Color3.fromRGB(205,48,58)
    flag.TextColor3 = Color3.new(1,1,1)
    recoveryFlag = flag

    flag.MouseButton1Click:Connect(function()
        if not recoveryPending then return end
        recoveryPending = false
        local target = recoveryTarget
        recoveryTarget = nil
        disconnectConnections(recoveryConnections)
        flag.Text = "✓"
        tween(flag,{BackgroundColor3=Color3.fromRGB(35,210,105),Size=UDim2.fromOffset(45,38)},0.25)
        task.delay(0.35,function()
            if flag and flag.Parent then flag:Destroy() end
            if recoveryFlag == flag then recoveryFlag=nil end
            restoreHubLayout(target)
        end)
    end)

    local dragging, start, startPos = false, nil, nil
    table.insert(recoveryConnections,flag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, start, startPos = true, input.Position, flag.Position
        end
    end))
    table.insert(recoveryConnections,UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
        if isTouch or isMouse then
            local delta = input.Position-start
            flag.Position = UDim2.fromOffset(startPos.X.Offset+delta.X,startPos.Y.Offset+delta.Y)
            clampGuiObject(flag,8)
        end
    end))
    table.insert(recoveryConnections,UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            clampGuiObject(flag,8)
        end
    end))
end

local function scheduleRecovery(seconds,target)
    if recoveryPending or (recoveryPrompt and recoveryPrompt.Parent) then return end
    recoveryPending = true
    recoveryTarget = target or main

    local prompt = Instance.new("Frame")
    prompt.Name = "MaximRecoveryPrompt"
    prompt.Size = UDim2.fromOffset(286,178)
    prompt.Position = UDim2.new(0.5,-143,0.5,-89)
    prompt.BackgroundColor3 = currentTheme[3]
    prompt.ZIndex = 110
    prompt.Parent = gui
    corner(prompt,14)
    stroke(prompt,currentTheme[2],2)
    recoveryPrompt = prompt

    local heading = Instance.new("TextLabel")
    heading.Size = UDim2.new(1,-16,0,42)
    heading.Position = UDim2.fromOffset(8,5)
    heading.BackgroundTransparency = 1
    heading.Text = "Окно ушло за экран. Вернуть?"
    heading.TextWrapped = true
    heading.TextColor3 = Color3.new(1,1,1)
    heading.Font = Enum.Font.GothamBold
    heading.TextSize = 13
    heading.ZIndex = 111
    heading.Parent = prompt

    local function closePrompt(restore)
        if not recoveryPending then return end
        recoveryPending = false
        local restoreTarget = recoveryTarget
        recoveryTarget = nil
        if prompt and prompt.Parent then prompt:Destroy() end
        if recoveryPrompt == prompt then recoveryPrompt=nil end
        if restore then restoreHubLayout(restoreTarget) end
    end

    local yes = makeButton(prompt,"ДА, ВЕРНУТЬ",UDim2.new(0.48,-6,0,34),UDim2.fromOffset(8,52))
    yes.ZIndex = 112
    yes.MouseButton1Click:Connect(function() closePrompt(true) end)

    local no = makeButton(prompt,"НЕТ",UDim2.new(0.48,-6,0,34),UDim2.new(0.52,0,0,52))
    no.ZIndex = 112
    no.MouseButton1Click:Connect(function() closePrompt(false) end)

    local secondsBox = Instance.new("TextBox")
    secondsBox.Size = UDim2.new(1,-16,0,32)
    secondsBox.Position = UDim2.fromOffset(8,96)
    secondsBox.BackgroundColor3 = currentTheme[3]
    secondsBox.TextColor3 = Color3.new(1,1,1)
    secondsBox.PlaceholderText = "Секунды (например 60)"
    secondsBox.Text = tostring(seconds or 60)
    secondsBox.ClearTextOnFocus = false
    secondsBox.Font = Enum.Font.Gotham
    secondsBox.TextSize = 12
    secondsBox.ZIndex = 112
    secondsBox.Parent = prompt
    corner(secondsBox,8)
    stroke(secondsBox,currentTheme[2],1)
    secondsBox:GetPropertyChangedSignal("Text"):Connect(function()
        local digits = secondsBox.Text:gsub("%D","")
        if digits ~= secondsBox.Text then secondsBox.Text = digits end
    end)

    local later = makeButton(prompt,"ВЕРНУТЬ ЧЕРЕЗ",UDim2.new(1,-16,0,30),UDim2.fromOffset(8,137))
    later.ZIndex = 112
    later.MouseButton1Click:Connect(function()
        local delaySeconds = math.clamp(tonumber(secondsBox.Text) or 60,1,3600)
        if prompt and prompt.Parent then prompt:Destroy() end
        if recoveryPrompt == prompt then recoveryPrompt=nil end
        toast("Флажок возврата появится через "..delaySeconds.." сек.")
        task.delay(delaySeconds,function()
            if gui and gui.Parent and recoveryPending then makeRecoveryFlag() end
        end)
    end)
end

local function detachButton(source,label,callback)
    if not source or source.Parent ~= content then return false end

    local ordered = {}
    for _,child in ipairs(content:GetChildren()) do
        if child:IsA("GuiObject") then table.insert(ordered,child) end
    end
    for index,child in ipairs(ordered) do child.LayoutOrder=index end

    local originalPosition = source.AbsolutePosition
    local originalSize = source.Size
    local originalText = source.Text
    local originalName = source.Name
    local originalAlignment = source.TextXAlignment
    local originalLayoutOrder = source.LayoutOrder
    local originalTab = activeTab

    local placeholder = Instance.new("Frame")
    placeholder.Name = "MaximDetachedPlaceholder"
    placeholder.Size = UDim2.new(1,-4,0,39)
    placeholder.BackgroundTransparency = 1
    placeholder.LayoutOrder = originalLayoutOrder
    placeholder.Parent = content

    local flag = makeButton(placeholder,"⚑ ВЕРНУТЬ",UDim2.new(1,0,1,0),UDim2.new())
    flag.Name = "MaximReturnFlag"
    flag.BackgroundColor3 = Color3.fromRGB(205,48,58)
    flag.TextColor3 = Color3.new(1,1,1)
    flag.ZIndex = 5

    local rec = {
        button=source, placeholder=placeholder, flag=flag, label=label, callback=callback,
        tab=originalTab, layoutOrder=originalLayoutOrder, originalSize=originalSize,
        originalText=originalText, originalName=originalName, originalAlignment=originalAlignment,
        inputConnections={}, menuConnections={}
    }
    table.insert(detachedRecords,rec)
    pageDetachedCount += 1

    source.Parent = gui
    source.Name = "MaximShortcut_"..tostring(#detachedRecords)
    source:SetAttribute("ShortcutLabel",label)
    source.AnchorPoint = Vector2.new(0,0)
    setShortcutFloatingGeometry(source,Vector2.new(originalPosition.X,originalPosition.Y))
    source.ZIndex = 90
    source.Text = "✦ "..tr(label)
    source.TextXAlignment = Enum.TextXAlignment.Center
    table.insert(shortcutItems,source)

    local vp = getViewportSize()
    local slot = #shortcutItems-1
    local targetX = 12+(slot%2)*156
    local targetY = math.max(8,vp.Y-112-math.floor(slot/2)*46)
    tween(source,{Position=UDim2.fromOffset(targetX,targetY),BackgroundTransparency=0.04},0.25)

    local dragging, dragStart, dragPosition, dragMoved, activeInput = false,nil,nil,false,nil
    table.insert(rec.inputConnections,source.InputBegan:Connect(function(input)
        if miniMenuOpen then return end
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            dragMoved=false
            activeInput=input
            dragStart=input.Position
            dragPosition=source.Position
        end
    end))
    table.insert(rec.inputConnections,UIS.InputChanged:Connect(function(input)
        if not dragging or miniMenuOpen then return end
        local matchingTouch = activeInput and activeInput.UserInputType==Enum.UserInputType.Touch
            and input==activeInput
        local matchingMouse = activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1
            and input.UserInputType==Enum.UserInputType.MouseMovement
        if matchingTouch or matchingMouse then
            local delta=input.Position-dragStart
            if delta.Magnitude>5 then dragMoved=true end
            source.Position=UDim2.fromOffset(dragPosition.X.Offset+delta.X,dragPosition.Y.Offset+delta.Y)
            clampGuiObject(source,8)
        end
    end))
    table.insert(rec.inputConnections,UIS.InputEnded:Connect(function(input)
        if not dragging or not activeInput then return end
        local sameTouch = activeInput.UserInputType==Enum.UserInputType.Touch and input==activeInput
        local sameMouse = activeInput.UserInputType==Enum.UserInputType.MouseButton1
            and input.UserInputType==Enum.UserInputType.MouseButton1
        if sameTouch or sameMouse then
            dragging=false
            activeInput=nil
            if dragMoved then source:SetAttribute("MaximSuppressClick",true) end
            clampGuiObject(source,8)
        end
    end))

    rec.returnAction = function()
        if rec.returning then return end
        rec.returning=true
        flag.Text="✓"
        tween(flag,{BackgroundColor3=Color3.fromRGB(35,210,105)},0.2)
        task.delay(0.3,function()
            if not rec.button or not rec.button.Parent or not gui.Parent then return end
            local button=rec.button
            disconnectConnections(rec.inputConnections)
            disconnectConnections(rec.menuConnections)

            for index,obj in ipairs(shortcutItems) do
                if obj==button then table.remove(shortcutItems,index) break end
            end
            for index,item in ipairs(detachedRecords) do
                if item==rec then table.remove(detachedRecords,index) break end
            end

            if rec.placeholder then rec.placeholder:Destroy() end
            rec.placeholder=nil
            button.Name=rec.originalName or "TextButton"
            button.Text=rec.originalText or ("   "..tr(label))
            button.TextXAlignment=rec.originalAlignment or Enum.TextXAlignment.Left
            button.Size=rec.originalSize or UDim2.new(1,-4,0,39)
            button.AnchorPoint=Vector2.new(0,0)
            button:SetAttribute("ShortcutLabel",nil)
            button:SetAttribute("MaximSuppressClick",false)

            if activeTab==rec.tab then
                button.Parent=content
                renumberContentChildren(button,rec.layoutOrder)
            else
                button.Parent=nil
                table.insert(pendingReturns,rec)
            end

            pageDetachedCount=0
            for _,item in ipairs(detachedRecords) do
                if item.tab==activeTab then pageDetachedCount+=1 end
            end
            if updateGatherButton then updateGatherButton() end
            if miniMenuOpen and #detachedRecords==0 then
                miniMenuOpen=false
                if shortcutPanel then shortcutPanel:Destroy(); shortcutPanel=nil end
                if gatherButton then gatherButton:Destroy(); gatherButton=nil end
            end
            refreshShortcutTheme()
        end)
    end
    flag.MouseButton1Click:Connect(rec.returnAction)
    renumberContentChildren(placeholder,originalLayoutOrder)
    return true
end

local function dissolveMiniMenu()
    if not miniMenuOpen then return end
    miniMenuOpen=false
    for _,rec in ipairs(detachedRecords) do
        disconnectConnections(rec.menuConnections)
    end

    for _,obj in ipairs(shortcutItems) do
        if obj and obj.Parent then
            local absolute = obj.AbsolutePosition
            obj.Parent=gui
            obj.Name = "MaximShortcut_"..tostring(obj:GetAttribute("ShortcutLabel") or "Action")
            setShortcutFloatingGeometry(obj,absolute)
            clampGuiObject(obj,8)
        end
    end
    if shortcutPanel then shortcutPanel:Destroy(); shortcutPanel=nil end
    if gatherButton then gatherButton:Destroy(); gatherButton=nil end
end

local function buildMiniMenu()
    if miniMenuOpen or #detachedRecords<5 then return end
    miniMenuOpen=true
    local vp=getViewportSize()
    local panelWidth=math.max(160,math.min(270,vp.X-16))
    local rows=math.ceil(#shortcutItems/2)
    local panelHeight=math.min(math.max(130,vp.Y-24),54+rows*45)

    shortcutPanel=Instance.new("Frame")
    shortcutPanel.Name="MaximShortcutMiniMenu"
    shortcutPanel.Size=UDim2.fromOffset(panelWidth,0)
    shortcutPanel.Position=UDim2.fromOffset((vp.X-panelWidth)/2,(vp.Y-panelHeight)/2)
    shortcutPanel.BackgroundColor3=currentTheme[3]
    shortcutPanel.ClipsDescendants=true
    shortcutPanel.ZIndex=85
    shortcutPanel.Parent=gui
    corner(shortcutPanel,16)
    stroke(shortcutPanel,currentTheme[2],2)

    local heading=Instance.new("TextLabel")
    heading.Name="MiniMenuTitle"
    heading.Size=UDim2.new(1,-16,0,28)
    heading.Position=UDim2.fromOffset(8,5)
    heading.BackgroundTransparency=1
    heading.Text="MAXIM • QUICK MENU"
    heading.TextColor3=currentTheme[2]
    heading.Font=Enum.Font.GothamBlack
    heading.TextSize=12
    heading.ZIndex=87
    heading.Parent=shortcutPanel

    local grid=Instance.new("Frame")
    grid.Name="MiniMenuGrid"
    grid.Size=UDim2.new(1,-14,1,-42)
    grid.Position=UDim2.fromOffset(7,36)
    grid.BackgroundTransparency=1
    grid.ZIndex=86
    grid.Parent=shortcutPanel

    local gridLayout=Instance.new("UIGridLayout")
    gridLayout.CellSize=UDim2.new(0.5,-5,0,39)
    gridLayout.CellPadding=UDim2.fromOffset(6,6)
    gridLayout.SortOrder=Enum.SortOrder.LayoutOrder
    gridLayout.Parent=grid

    for index,obj in ipairs(shortcutItems) do
        if obj and obj.Parent then
            local rec
            for _,candidate in ipairs(detachedRecords) do
                if candidate.button==obj then rec=candidate break end
            end
            obj.Parent=grid
            obj.Name="MaximMiniAction"
            obj.LayoutOrder=index
            obj.Size=UDim2.new(0.5,-5,0,39)
            obj.ZIndex=88
            obj.Text="✦ "..tr(obj:GetAttribute("ShortcutLabel") or obj.Text:gsub("^✦ ",""))

            if rec then
                local hold,token=false,0
                table.insert(rec.menuConnections,obj.InputBegan:Connect(function(input)
                    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                        hold=true
                        token+=1
                        local thisToken=token
                        task.delay(3,function()
                            if hold and token==thisToken and miniMenuOpen and obj.Parent==grid then
                                obj:SetAttribute("MaximSuppressClick",true)
                                dissolveMiniMenu()
                            end
                        end)
                    end
                end))
                table.insert(rec.menuConnections,obj.InputEnded:Connect(function(input)
                    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                        hold=false
                        token+=1
                    end
                end))
            end
        end
    end

    updateGatherButton()

    tween(shortcutPanel,{Size=UDim2.fromOffset(panelWidth,panelHeight)},0.3)
    refreshShortcutTheme()
    toast("Мини-меню собрано")
end

updateGatherButton = function()
    local shouldShow = miniMenuOpen and pageActionCount>0 and pageDetachedCount>=pageActionCount
    if not shouldShow then
        if gatherButton then gatherButton:Destroy(); gatherButton=nil end
        return
    end
    if gatherButton and gatherButton.Parent then return end
    gatherButton=makeButton(gui,"СОБРАТЬ КНОПКИ",UDim2.fromOffset(150,34),UDim2.new(0.5,-75,0.82,0))
    gatherButton.Name="MaximGatherButton"
    gatherButton.ZIndex=95
    gatherButton.MouseButton1Click:Connect(function()
        local pending={}
        for _,rec in ipairs(detachedRecords) do table.insert(pending,rec) end
        for _,rec in ipairs(pending) do
            if rec.returnAction then rec.returnAction() end
        end
    end)
end

createShortcut = function(label,callback,source)
    for _,rec in ipairs(detachedRecords) do
        if rec.label==label and rec.button and rec.button.Parent then
            toast("Эта кнопка уже вынесена")
            return
        end
    end
    if detachButton(source,label,callback) then
        if #detachedRecords>=5 then buildMiniMenu() end
        toast("Кнопка перемещена: "..label)
    end
end

local function monitorOffscreenWindows()
    while gui and gui.Parent do
        task.wait(0.6)
        if recoveryPrompt and recoveryPrompt.Parent then continue end
        local vp=getViewportSize()
        local function outside(obj)
            if not obj or not obj.Parent or not obj.Visible then return false end
            local p,size=obj.AbsolutePosition,obj.AbsoluteSize
            return p.X+size.X< -2 or p.Y+size.Y< -2 or p.X+size.X>vp.X+2 or p.Y+size.Y>vp.Y+2
        end

        local lostTarget
        if main.Visible and outside(main) then
            lostTarget=main
        elseif bubble.Visible and outside(bubble) then
            lostTarget=bubble
        elseif not miniMenuOpen then
            for _,obj in ipairs(shortcutItems) do
                if obj and obj.Parent==gui and outside(obj) then
                    lostTarget=obj
                    break
                end
            end
        end
        if lostTarget and not recoveryPending then
            scheduleRecovery(60,lostTarget)
        end
    end
end
task.spawn(monitorOffscreenWindows)

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
    content.ScrollBarImageColor3 = currentTheme[2]
    mainGradient.Color = ColorSequence.new(currentTheme[3],currentTheme[2]:Lerp(currentTheme[3],0.72))
    topGradient.Color = ColorSequence.new(currentTheme[2],currentTheme[2]:Lerp(Color3.new(1,1,1),0.18))
    local style = currentTheme[4] or "aurora"
    local rotations = {aurora=35,carbon=90,circuit=0,nebula=135,grid=45,lux=0,frost=90,ember=25,waves=0,hazard=45,prism=135,silk=0,minimal=90,glass=45,sunset=0,matrix=90,crystal=45,velvet=135,wave=0,scanline=90}
    mainGradient.Rotation = rotations[style] or 35
    topGradient.Rotation = (rotations[style] or 35) * 0.5
    local patternTransparency = (style=="minimal") and 0.97 or ((style=="carbon" or style=="matrix" or style=="scanline") and 0.84 or 0.91)
    for _,mark in ipairs(textureMarks) do
        mark.BackgroundColor3 = currentTheme[2]
        mark.BackgroundTransparency = patternTransparency
        if style=="circuit" or style=="grid" or style=="matrix" then mark.Rotation = 0
        elseif style=="waves" or style=="wave" then mark.Rotation = 8
        elseif style=="frost" or style=="crystal" then mark.Rotation = 45
        else mark.Rotation = 18 end
    end
    local dotsOn = style=="nebula" or style=="aurora" or style=="prism" or style=="matrix" or style=="hazard" or style=="roblox"
    local ringsOn = style=="nebula" or style=="aurora" or style=="waves" or style=="wave" or style=="prism" or style=="crystal" or style=="glass" or style=="gtav"
    for _,obj in ipairs(minecraftBlocks) do obj.Visible = style=="minecraft" end
    for _,obj in ipairs(brawlStars) do obj.Visible = style=="brawl" end
    for _,obj in ipairs(robloxStuds) do obj.Visible = style=="roblox" end
    gtaLabel.Visible = style=="gtav"
    if style=="minecraft" then
        mainGradient.Rotation=90
        topGradient.Rotation=0
    elseif style=="brawl" then
        mainGradient.Rotation=25
        topGradient.Rotation=155
    elseif style=="roblox" then
        mainGradient.Rotation=135
        topGradient.Rotation=45
    elseif style=="gtav" then
        mainGradient.Rotation=0
        topGradient.Rotation=90
    end
    for _,dot in ipairs(textureDots) do dot.Visible=dotsOn; dot.BackgroundColor3=currentTheme[2] end
    for _,ring in ipairs(textureRings) do
        ring.Visible=ringsOn
        local edge=ring:FindFirstChildOfClass("UIStroke")
        if edge then edge.Color=currentTheme[2] end
    end
    if hud then hud.BackgroundColor3 = currentTheme[3] end
    if hudText then hudText.TextColor3 = currentTheme[2] end
    if setDockTheme then setDockTheme() end
    if refreshShortcutTheme then refreshShortcutTheme() end
    for _,obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") then
            obj.BackgroundColor3 = currentTheme[2]
            local grad=obj:FindFirstChildOfClass("UIGradient")
            if not grad then
                grad=Instance.new("UIGradient")
                grad.Parent=obj
            end
            grad.Color=ColorSequence.new(currentTheme[2],currentTheme[2]:Lerp(currentTheme[3],0.38))
            grad.Rotation=rotations[style] or 35
            obj.Font=(style=="matrix" or style=="scanline" or style=="circuit" or style=="minecraft") and Enum.Font.Code or Enum.Font.GothamBold
            if style=="minecraft" then obj.BorderSizePixel=2
            elseif style=="brawl" then obj.BorderSizePixel=2
            elseif style=="roblox" then obj.BorderSizePixel=1
            else obj.BorderSizePixel=0 end
        end
        if obj:IsA("TextBox") then obj.BackgroundColor3 = currentTheme[3]; obj.TextColor3 = Color3.new(1,1,1) end
        if obj:IsA("TextLabel") and obj.Name ~= "HubTitle" and obj.Name ~= "LauncherTitle" and obj.Name ~= "HubSubtitle" and obj.Name ~= "DockEffect" then obj.TextColor3 = currentTheme[2] end
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

local noclipOriginalCollision = setmetatable({}, {__mode="k"})
local function setNoclip(state)
    noclipOn = state
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        -- Capture each part's original collision value once, including accessories.
        if character and character.Parent then
            for _,part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and noclipOriginalCollision[part] == nil then
                    noclipOriginalCollision[part] = part.CanCollide
                end
            end
        end
        noclipConn = RunService.Stepped:Connect(function()
            if character and character.Parent then
                for _,part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if noclipOriginalCollision[part] == nil then
                            noclipOriginalCollision[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        for part,original in pairs(noclipOriginalCollision) do
            if part and part.Parent then
                pcall(function() part.CanCollide = original end)
            end
            noclipOriginalCollision[part] = nil
        end
    end
    toast("Noclip: "..(state and "ON" or "OFF"))
end

local flightPoses = {
    {"Супермен", {RootJoint={-12,0,0}, Waist={-8,0,0}, Neck={8,0,0}, LeftShoulder={-72,0,-18}, RightShoulder={-72,0,18}, LeftHip={12,0,-8}, RightHip={12,0,8}}},
    {"Горизонтальная", {RootJoint={-82,0,0}, Waist={-8,0,0}, Neck={12,0,0}, LeftShoulder={-12,0,-75}, RightShoulder={-12,0,75}, LeftHip={18,0,-8}, RightHip={18,0,8}}},
    {"Вертикальная", {RootJoint={0,0,0}, Waist={0,0,0}, Neck={0,0,0}, LeftShoulder={-12,0,-25}, RightShoulder={-12,0,25}, LeftHip={0,0,-8}, RightHip={0,0,8}}},
    {"Свободное падение", {RootJoint={75,0,0}, Waist={10,0,0}, Neck={-15,0,0}, LeftShoulder={-95,0,-35}, RightShoulder={-95,0,35}, LeftHip={-25,0,-12}, RightHip={-25,0,12}}},
    {"На спине", {RootJoint={165,0,0}, Waist={0,0,0}, Neck={0,0,0}, LeftShoulder={-35,0,-65}, RightShoulder={-35,0,65}, LeftHip={0,0,-10}, RightHip={0,0,10}}},
    {"Сидя в воздухе", {RootJoint={-18,0,0}, Waist={5,0,0}, Neck={-5,0,0}, LeftShoulder={-35,0,-18}, RightShoulder={-35,0,18}, LeftHip={-78,0,-12}, RightHip={-78,0,12}}},
    {"Компактная", {RootJoint={-35,0,0}, Waist={0,0,0}, Neck={5,0,0}, LeftShoulder={-45,0,-20}, RightShoulder={-45,0,20}, LeftHip={-48,0,-12}, RightHip={-48,0,12}}},
    {"Звезда", {RootJoint={-5,0,0}, Waist={0,0,0}, Neck={0,0,0}, LeftShoulder={0,0,-95}, RightShoulder={0,0,95}, LeftHip={0,0,-55}, RightHip={0,0,55}}},
    {"Ниндзя", {RootJoint={-28,0,0}, Waist={0,0,0}, Neck={8,0,0}, LeftShoulder={-75,0,-48}, RightShoulder={-25,0,35}, LeftHip={-35,0,-18}, RightHip={25,0,18}}},
    {"Диагональная", {RootJoint={-48,0,-22}, Waist={0,0,12}, Neck={5,0,0}, LeftShoulder={-65,0,-30}, RightShoulder={-30,0,55}, LeftHip={-35,0,-15}, RightHip={15,0,20}}}
}
local flightAnimations = {
    {"Супермен", "superman"}, {"Соник — клубок", "sonic"}, {"Крылья", "wings"},
    {"Истребитель", "fighter"}, {"Парашютист", "skydiver"}, {"Ангел", "angel"},
    {"Ракетный рывок", "rocket"}, {"Ниндзя", "ninja"}, {"Звёздное парение", "star"},
    {"Магическое парение", "magic"}
}

local function resetFlightPoseTransforms()
    for motor, original in pairs(savedMotorTransforms) do
        if motor and motor.Parent then pcall(function() motor.Transform = original end) end
    end
    table.clear(savedMotorTransforms)
end

local function applyFlightPoseAnimation(now)
    if not character or not character.Parent then return end
    local pose = flightPoses[flightPoseIndex] or flightPoses[1]
    local animation = flightAnimations[flightAnimationIndex] and flightAnimations[flightAnimationIndex][2] or "superman"
    local phase = flightPoseFrozen and 0 or now
    local wave = math.sin(phase * 2.4)
    local fast = math.sin(phase * 9)
    for _, motor in ipairs(character:GetDescendants()) do
        if motor:IsA("Motor6D") then
            local name = motor.Name:gsub("%s", "")
            local base = savedMotorTransforms[motor]
            if not base then base = motor.Transform; savedMotorTransforms[motor] = base end
            local angles = pose[2][name]
            local rx, ry, rz = 0, 0, 0
            if angles then rx, ry, rz = math.rad(angles[1]), math.rad(angles[2]), math.rad(angles[3]) end
            if name == "LeftShoulder" or name == "RightShoulder" then
                local sign = name == "LeftShoulder" and -1 or 1
                if animation == "wings" then rz += math.rad(sign * (18 + wave * 24))
                elseif animation == "angel" then rz += math.rad(sign * (8 + wave * 7))
                elseif animation == "superman" then rx += math.rad(wave * 2)
                elseif animation == "sonic" then rx += math.rad(-48)
                elseif animation == "fighter" then rz += math.rad(sign * 8)
                elseif animation == "magic" then rz += math.rad(sign * (12 + math.sin(phase*1.7)*10)) end
            elseif name == "RootJoint" or name == "Waist" then
                if animation == "sonic" then rz += math.rad(flightPoseFrozen and 0 or ((phase*420)%360)); rx += math.rad(-12)
                elseif animation == "rocket" then rx += math.rad(-8 + wave*3)
                elseif animation == "skydiver" then rx += math.rad(wave*5)
                elseif animation == "ninja" then rz += math.rad(math.sin(phase*3)*5)
                elseif animation == "star" then rz += math.rad(math.sin(phase*1.4)*4)
                elseif animation == "magic" then ry += math.rad(math.sin(phase*1.8)*5) end
            elseif name == "LeftHip" or name == "RightHip" then
                local sign = name == "LeftHip" and -1 or 1
                if animation == "sonic" then rx += math.rad(-65 + math.sin(phase*14)*5)
                elseif animation == "wings" then rx += math.rad(wave*4)
                elseif animation == "skydiver" then rx += math.rad(12 + wave*8)
                elseif animation == "rocket" then rx += math.rad(-12)
                elseif animation == "star" then rz += math.rad(sign*4)
                elseif animation == "ninja" then rx += math.rad(sign*8) end
            elseif name == "Neck" then
                if animation == "superman" then rx += math.rad(-4 + wave*2)
                elseif animation == "sonic" then rx += math.rad(8)
                elseif animation == "magic" then ry += math.rad(math.sin(phase*1.8)*8) end
            end
            -- Small, stable joint offsets only; no root-position corrections or velocity writes.
            motor.Transform = base * CFrame.Angles(rx, ry, rz)
        end
    end
end

local function stopFlight()
    flying = false
    dashVelocity, dashUntil = nil, 0
    holdingUp, holdingDown = false, false
    if moveConn then moveConn:Disconnect() moveConn = nil end
    if velocity then velocity:Destroy() velocity = nil end
    if gyro then gyro:Destroy() gyro = nil end
    resetFlightPoseTransforms()
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

    local verticalButtons = not (flightControlProfile == 2 or (flightControlProfile == 1 and isCameraFlightMode()))
    if up then up.Visible = verticalButtons end
    if down then down.Visible = verticalButtons end
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

        local modeName = modes[modeIndex][1]
        local cameraLook = cam.CFrame.LookVector
        local cameraFlight = flightControlProfile == 2 or (flightControlProfile == 1 and cameraFlightModes[modeName] == true)
        if cameraFlight then
            -- MoveDirection is driven by WASD on desktop and the thumbstick on touch.
            -- Neutral input means a stable hover; camera pitch never causes auto-flight.
            local flatForward = Vector3.new(cameraLook.X,0,cameraLook.Z)
            if flatForward.Magnitude < 0.01 then flatForward = Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
            if flatForward.Magnitude < 0.01 then flatForward = Vector3.new(0,0,-1) end
            flatForward = flatForward.Unit
            local flatRight = Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)
            if flatRight.Magnitude < 0.01 then flatRight = Vector3.new(1,0,0) else flatRight = flatRight.Unit end
            if UIS.KeyboardEnabled and not UIS:GetFocusedTextBox() then
                local keyboardForward = (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                local keyboardStrafe = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
                if keyboardForward ~= 0 or keyboardStrafe ~= 0 then
                    dir = (flatForward * keyboardForward + flatRight * keyboardStrafe).Unit
                end
            end
            local forwardInput = math.clamp(dir:Dot(flatForward),-1,1)
            local strafeInput = math.clamp(dir:Dot(flatRight),-1,1)
            local inputVector = Vector3.zero
            if math.abs(forwardInput) > 0.04 then
                inputVector += cameraLook * forwardInput
            end
            if math.abs(strafeInput) > 0.04 then
                inputVector += flatRight * strafeInput
            end
            local multiplier = 1
            if modeName == "Комета 3D" then multiplier = 1.12 + math.sin(os.clock()*5)*0.08 end
            if modeName == "Грави-дайв" and forwardInput > 0.04 then multiplier = cameraLook.Y < -0.25 and 1.45 or 0.92 end
            if modeName == "Истребитель" then multiplier = 1.18 end
            if modeName == "Астральный" and inputVector.Magnitude > 0.01 then
                inputVector = (inputVector + cam.CFrame.UpVector * math.sin(os.clock()*2.2)*0.045).Unit
            end
            if inputVector.Magnitude > 0.04 then
                horizontal = inputVector.Unit * flightSpeed * multiplier
            end
        elseif flatMove.Magnitude > 0.05 then
            -- Original twenty presets keep their existing movement behavior.
            horizontal = flatMove.Unit * flightSpeed
        end
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

        local y = cameraFlight and 0 or baseVertical
        if not cameraFlight and holdingUp then y = 65 end
        if not cameraFlight and holdingDown then y = -65 end
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

        local look
        if cameraFlight then
            -- Face the full 3D camera direction, including looking straight up/down.
            look = cam.CFrame.LookVector
        else
            look = Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
            if look.Magnitude < 0.01 then look = Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
            if look.Magnitude < 0.01 then look = Vector3.new(0,0,-1) end
        end
        if cameraFlight then
            local flightFrame = CFrame.lookAt(root.Position,root.Position+look.Unit,cam.CFrame.UpVector)
            if modeName == "Истребитель" then
                flightFrame = flightFrame * CFrame.Angles(math.rad(-90),0,0)
            end
            gyro.CFrame = flightFrame
        else
            gyro.CFrame = CFrame.lookAt(root.Position,root.Position+look.Unit)
        end
        applyFlightPoseAnimation(os.clock())
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
    sectionLabel("Текущая скорость: "..tostring(math.floor(flightSpeed)))
    itemButton("Режим: "..modes[modeIndex][1].."  › следующий", function()
        modeIndex = modeIndex % #modes + 1
        if not speedOverride then flightSpeed = modes[modeIndex][2] end
        local verticalVisible = not (flightControlProfile == 2 or (flightControlProfile == 1 and isCameraFlightMode()))
        if up then up.Visible = flying and verticalVisible end
        if down then down.Visible = flying and verticalVisible end
        saveSettings()
        buildHome()
    end)
    makeSlider(content,5,300,flightSpeed,function(value)
        flightSpeed=value
        speedOverride=true
        saveSettings()
    end)
    if flightControlProfile == 2 or (flightControlProfile == 1 and isCameraFlightMode()) then
        sectionLabel("УПРАВЛЕНИЕ: ПОЛНОЕ НАПРАВЛЕНИЕ КАМЕРЫ 3D")
    else
        sectionLabel("ВЕРТИКАЛЬНОЕ УПРАВЛЕНИЕ")
        itemButton("Вверх ▲", function() baseVertical = math.min(150, baseVertical + 15) end)
        itemButton("Вниз ▼", function() baseVertical = math.max(-150, baseVertical - 15) end)
        itemButton("Сброс высоты", function() baseVertical = 0 end)
    end
    sectionLabel("ПОЗЫ ПОЛЁТА — 10 ВАРИАНТОВ")
    itemButton("Поза: "..flightPoses[flightPoseIndex][1].."  › следующая", function()
        flightPoseIndex = flightPoseIndex % #flightPoses + 1
        saveSettings()
        buildHome()
    end)
    sectionLabel("АНИМАЦИИ ПОЛЁТА — 10 ВАРИАНТОВ")
    itemButton("Анимация: "..flightAnimations[flightAnimationIndex][1].."  › следующая", function()
        flightAnimationIndex = flightAnimationIndex % #flightAnimations + 1
        if flying then resetFlightPoseTransforms() end
        saveSettings()
        buildHome()
    end)
    local freezeButton = itemButton("❄ ЗАМОРОЗИТЬ ПОЗУ: "..(flightPoseFrozen and "ВКЛ" or "ВЫКЛ"), function()
        flightPoseFrozen = not flightPoseFrozen
        if flying then resetFlightPoseTransforms() end
        toast(flightPoseFrozen and "Поза зафиксирована" or "Анимация позы возобновлена")
        buildHome()
    end)
    freezeButton.BackgroundColor3 = Color3.fromRGB(65,155,190)
    local freezeGradient = freezeButton:FindFirstChildOfClass("UIGradient")
    if freezeGradient then
        freezeGradient.Color = ColorSequence.new(Color3.fromRGB(175,245,255), Color3.fromRGB(35,105,160))
    end
    sectionLabel("ПРОФИЛЬ УПРАВЛЕНИЯ ПОЛЁТОМ")
    sectionLabel("Это меняет только клиентское управление; серверные проверки игры не отключаются")
    local profileNames = {"Обычный", "3D — все направления камеры", "Отключить 3D-профиль"}
    for i, profileName in ipairs(profileNames) do
        local profileButton = itemButton((flightControlProfile == i and "✓ " or "○ ")..profileName, function()
            flightControlProfile = i
            if i == 2 then holdingUp, holdingDown = false, false end
            if flying then
                local showVertical = not (flightControlProfile == 2 or (flightControlProfile == 1 and isCameraFlightMode()))
                if up then up.Visible = showVertical end
                if down then down.Visible = showVertical end
            end
            saveSettings()
            buildHome()
        end)
        if flightControlProfile == i then profileButton.BackgroundColor3 = currentTheme[2]:Lerp(Color3.fromRGB(70,190,220),0.35) end
    end
    sectionLabel("25 РЕЖИМОВ ПОЛЁТА")
    local function addModeButton(i,m)
        itemButton(string.format("%02d. %s  |  %d", i,m[1],m[2]), function()
            modeIndex = i
            if not speedOverride then flightSpeed = m[2] end
            local verticalVisible = not (flightControlProfile == 2 or (flightControlProfile == 1 and isCameraFlightMode()))
            if up then up.Visible = flying and verticalVisible end
            if down then down.Visible = flying and verticalVisible end
            saveSettings()
            buildHome()
        end)
    end
    for i=1,math.min(20,#modes) do addModeButton(i,modes[i]) end
    if #modes > 20 then
        sectionLabel("РЕЖИМЫ ПОЛЁТА ПО КАМЕРЕ — 3D")
        for i=21,#modes do addModeButton(i,modes[i]) end
    end
end

local function buildThemes()
    clearContent()
    sectionLabel("24 ТЕМЫ • ТЕКСТУРЫ • СТИЛИ")
    sectionLabel("Minecraft • Brawl Stars • Roblox • GTA V — отдельные текстуры меню")
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
        ["Вихрь"]=Color3.fromRGB(150,100,255),
        ["Пузырь"]=Color3.fromRGB(130,210,255)
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

-- Selected launcher aura is a real character effect (separate from the 15 toggled effects).
local auraHighlight, auraAttachment, auraParticles
local function clearSelectedAura()
    if auraHighlight then pcall(function() auraHighlight:Destroy() end) end
    if auraAttachment then pcall(function() auraAttachment:Destroy() end) end
    auraHighlight, auraAttachment, auraParticles = nil, nil, nil
end
local function applySelectedAura()
    clearSelectedAura()
    if not getCharacter() then return end
    local auraColor = auraPresets[auraIndex][2]
    auraHighlight = Instance.new("Highlight")
    auraHighlight.Name = "MaximSelectedAura"
    auraHighlight.Adornee = character
    auraHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    auraHighlight.FillColor = auraColor
    auraHighlight.OutlineColor = auraColor:Lerp(Color3.new(1,1,1),0.35)
    auraHighlight.FillTransparency = 0.88
    auraHighlight.OutlineTransparency = 0.12
    auraHighlight.Parent = gui

    auraAttachment = Instance.new("Attachment")
    auraAttachment.Name = "MaximSelectedAuraAttachment"
    auraAttachment.Parent = root
    auraParticles = Instance.new("ParticleEmitter")
    auraParticles.Name = "MaximSelectedAuraParticles"
    auraParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    auraParticles.Color = ColorSequence.new(auraColor)
    auraParticles.LightEmission = 0.75
    auraParticles.Rate = 14
    auraParticles.Lifetime = NumberRange.new(0.7,1.25)
    auraParticles.Speed = NumberRange.new(0.4,1.8)
    auraParticles.SpreadAngle = Vector2.new(180,180)
    auraParticles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.18),
        NumberSequenceKeypoint.new(1,0)
    })
    auraParticles.Parent = auraAttachment
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

local function requireVIP()
    if not vipUnlocked then
        toast("Сначала активируй VIP-код")
        return false
    end
    return true
end

local function buildVip()
    clearContent()
    sectionLabel("VIP ДОСТУП")
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,-4,0,44)
    info.BackgroundTransparency = 1
    info.TextWrapped = true
    info.Text = tr(vipUnlocked and "VIP РАЗБЛОКИРОВАН" or "VIP доступ активируется секретным кодом")
    info.TextColor3 = currentTheme[2]
    info.Font = Enum.Font.GothamBold
    info.TextSize = 12
    info.Parent = content

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-4,0,38)
    input.BackgroundColor3 = currentTheme[3]
    input.PlaceholderText = tr("Секретный код...")
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
            if not requireVIP() then return end
            flightSpeed = 300
            speedOverride = true
            modeIndex = 19
            saveSettings()
            buildVip()
        end)
        itemButton("VIP 2 — Мягкое парение", function()
            if not requireVIP() then return end
            modeIndex = 10
            flightSpeed = modes[10][2]
            baseVertical = 0
            saveSettings()
        end)
        itemButton("VIP 3 — Турбо-рывок", function()
            if not requireVIP() then return end
            if getCharacter() and root then
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
            if not requireVIP() then return end
            addEffect("Неон","✨")
        end)
        itemButton("VIP 5 — Полный сброс эффектов", function()
            if not requireVIP() then return end
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
    sectionLabel("АУРА ПЕРСОНАЖА")
    itemButton((lang == "EN" and "Change aura → " or "Сменить ауру → ")..auraPresets[auraIndex][1], function()
        auraIndex = auraIndex % #auraPresets + 1
        applySelectedAura()
        toast("Аура выбрана: "..auraPresets[auraIndex][1])
        saveSettings()
        buildTools()
    end)
    sectionLabel("ОСВЕЩЕНИЕ")
    itemButton("Fullbright: "..(lightState.fullbright and "ВКЛ" or "ВЫКЛ"),function()
        setFullbright(not lightState.fullbright); buildTools()
    end)
    itemButton("Время: "..math.floor(Lighting.ClockTime).."ч — +3ч",function()
        Lighting.ClockTime=(Lighting.ClockTime+3)%24; buildTools()
    end)
    itemButton("Убрать туман",function() Lighting.FogEnd=1000000; toast("Туман убран") end)
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
    itemButton("HUD: "..(hudEnabled and "ВКЛ" or "ВЫКЛ"), function()
        hudEnabled = not hudEnabled
        if hud then hud.Visible = hudEnabled and minimized end
        saveSettings()
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

setTab = function(name)
    activeTab = name
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
        hudEnabled = not hudEnabled
        if hud then hud.Visible = hudEnabled and minimized end
        saveSettings()
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
table.insert(globalConnections,keybindConn)

-- Floating M button: drag it to an edge to dock, pull it back out, tap to open.
local dockDragging = false
local dockDragInput, dockDragStart, dockStartPos
local dockDragMoved = false

bubble = Instance.new("TextButton")
bubble.Name = "MaximBubble"
bubble.Size = UDim2.fromOffset(42,66)
bubble.AnchorPoint = Vector2.new(0,0.5)
bubble.Position = UDim2.new(0,0,0.55,0)
bubble.BackgroundColor3 = currentTheme[2]
bubble.BackgroundTransparency = 0.08
bubble.BorderSizePixel = 0
bubble.Text = ""
bubble.TextColor3 = currentTheme[3]
bubble.TextSize = 23
bubble.Font = Enum.Font.GothamBlack
bubble.AutoButtonColor = false
bubble.Active = true
bubble.Visible = false
bubble.ZIndex = 80
bubble.Parent = gui
corner(bubble,22)
local bubbleStroke = stroke(bubble,currentTheme[2],2)
local dockGradient = Instance.new("UIGradient")
dockGradient.Color = ColorSequence.new(currentTheme[2], currentTheme[2]:Lerp(Color3.new(1,1,1),0.42))
dockGradient.Rotation = 90
dockGradient.Parent = bubble

local dockCaption = Instance.new("TextLabel")
dockCaption.Name = "DockEffect"
dockCaption.BackgroundTransparency = 1
dockCaption.Size = UDim2.fromScale(1,1)
dockCaption.Font = Enum.Font.GothamBlack
dockCaption.TextSize = 23
dockCaption.Text = "M"
dockCaption.TextColor3 = currentTheme[3]
dockCaption.TextTransparency = 0.04
dockCaption.ZIndex = 81
dockCaption.Active = false
dockCaption.Parent = bubble

task.spawn(function()
    while bubble.Parent do
        local shimmer = TweenService:Create(
            dockGradient,
            TweenInfo.new(2.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {Rotation=360}
        )
        shimmer:Play()
        shimmer.Completed:Wait()
        dockGradient.Rotation = 0
    end
end)

setDockTheme = function()
    if not bubble or not bubble.Parent then return end
    bubble.BackgroundColor3 = currentTheme[2]
    bubbleStroke.Color = currentTheme[2]
    dockGradient.Color = ColorSequence.new(currentTheme[2],currentTheme[2]:Lerp(Color3.new(1,1,1),0.42))
    dockCaption.TextColor3 = currentTheme[3]
end

local function openFromDock()
    minimized = false
    if hud then hud.Visible = false end
    main.Visible = true
    main.Size = UDim2.fromOffset(0,0)
    tween(main,{Size=getResponsiveMainSize()},0.24)
end

bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dockDragging = true
        dockDragInput = input
        dockDragStart = input.Position
        dockStartPos = bubble.Position
        dockDragMoved = false
    end
end)

table.insert(globalConnections,UIS.InputChanged:Connect(function(input)
    if not dockDragging then return end
    local isTouchMove = dockDragInput and dockDragInput.UserInputType == Enum.UserInputType.Touch
        and input.UserInputType == Enum.UserInputType.Touch and input == dockDragInput
    local isMouseMove = dockDragInput and dockDragInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    if isTouchMove or isMouseMove then
        local delta = input.Position - dockDragStart
        if delta.Magnitude > 6 then dockDragMoved = true end
        bubble.Position = UDim2.new(
            dockStartPos.X.Scale,dockStartPos.X.Offset+delta.X,
            dockStartPos.Y.Scale,dockStartPos.Y.Offset+delta.Y
        )
        clampGuiObject(bubble,8)
    end
end))

table.insert(globalConnections,UIS.InputEnded:Connect(function(input)
    if not dockDragging or not dockDragInput then return end
    local sameTouch = dockDragInput.UserInputType == Enum.UserInputType.Touch and input == dockDragInput
    local sameMouse = dockDragInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseButton1
    if not (sameTouch or sameMouse) then return end

    local delta = input.Position - dockDragStart
    if delta.Magnitude > 6 then dockDragMoved = true end

    if dockDragMoved then
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
        if viewport then
            local x = dockStartPos.X.Scale*viewport.X + dockStartPos.X.Offset + delta.X
            local y = dockStartPos.Y.Scale*viewport.Y + dockStartPos.Y.Offset + delta.Y
            local maxY = math.max(70,viewport.Y-70)
            y = math.clamp(y,math.min(70,maxY),maxY)

            -- Dock flush against either edge without hiding the M button.
            if x <= 18 then
                x = 0
            elseif x >= viewport.X-60 then
                x = math.max(0,viewport.X-42)
            else
                x = math.clamp(x,0,math.max(0,viewport.X-42))
            end
            bubble.Position = UDim2.new(0,x,0,y)
        end
    else
        -- Handle taps here instead of MouseButton1Click so dragging cannot swallow the next tap.
        if main.Visible then
            toggleMinimize()
        else
            openFromDock()
        end
    end

    dockDragging = false
    dockDragInput, dockDragStart, dockStartPos = nil, nil, nil
    dockDragMoved = false
end))

toggleMinimize = function()
    minimized = not minimized
    if minimized then
        tween(main,{Size=UDim2.fromOffset(0,0)},0.22)
        task.delay(0.23,function()
            if minimized and main and main.Parent then
                main.Visible = false
                if hud then hud.Visible = hudEnabled end
            end
        end)
    else
        if hud then hud.Visible = false end
        main.Visible = true
        main.Size = UDim2.fromOffset(0,0)
        tween(main,{Size=getResponsiveMainSize()},0.22)
    end
end

close.MouseButton1Click:Connect(toggleMinimize)
xbtn.MouseButton1Click:Connect(function()
    saveSettings()
    gui:Destroy()
end)

-- Drag the main window (touch + mouse).
local function makeDraggable(handle, object)
    local dragging, dragStart, startPos, activeInput = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeInput = input
            dragStart = input.Position
            startPos = object.Position
        end
    end)
    table.insert(globalConnections,UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local touchMove = activeInput and activeInput.UserInputType==Enum.UserInputType.Touch and input==activeInput
        local mouseMove = activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement
        if touchMove or mouseMove then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            clampGuiObject(object,8)
        end
    end))
    table.insert(globalConnections,UIS.InputEnded:Connect(function(input)
        local sameTouch = activeInput and activeInput.UserInputType==Enum.UserInputType.Touch and input==activeInput
        local sameMouse = activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1
        if dragging and (sameTouch or sameMouse) then
            dragging = false
            activeInput = nil
            clampGuiObject(object,8)
        end
    end))
end
makeDraggable(top,main)
local viewportConn
local function bindViewportWatcher()
    if viewportConn then viewportConn:Disconnect(); viewportConn=nil end
    local cam=workspace.CurrentCamera
    if cam then
        viewportConn=cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if main and main.Parent and main.Visible and not minimized then
                local size=getResponsiveMainSize()
                main.Size=size
                clampGuiObject(main,8)
            end
            if bubble and bubble.Parent then clampGuiObject(bubble,8) end
            for _,obj in ipairs(shortcutItems) do
                if obj and obj.Parent==gui then clampGuiObject(obj,8) end
            end
        end)
        table.insert(globalConnections,viewportConn)
    end
end
bindViewportWatcher()
table.insert(globalConnections,workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewportWatcher))

-- Simple touch-friendly vertical controls displayed only while flight is active.
up = makeButton(gui,"▲",UDim2.fromOffset(48,48),UDim2.new(1,-70,0.58,0))
down = makeButton(gui,"▼",UDim2.fromOffset(48,48),UDim2.new(1,-70,0.70,0))
up.TextSize, down.TextSize = 20,20
local function makeSmallControlDraggable(button)
    local dragging, start, startPos, activeInput = false, nil, nil, nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, start, startPos, activeInput = true, input.Position, button.AbsolutePosition, input
        end
    end)
    table.insert(globalConnections,UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local touchMove = activeInput and activeInput.UserInputType==Enum.UserInputType.Touch and input==activeInput
        local mouseMove = activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement
        if touchMove or mouseMove then
            local delta = input.Position-start
            if delta.Magnitude > 7 then
                button.Position = UDim2.fromOffset(startPos.X+delta.X,startPos.Y+delta.Y)
                clampGuiObject(button,8)
            end
        end
    end))
    table.insert(globalConnections,UIS.InputEnded:Connect(function(input)
        local sameTouch = activeInput and activeInput.UserInputType==Enum.UserInputType.Touch and input==activeInput
        local sameMouse = activeInput and activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1
        if dragging and (sameTouch or sameMouse) then
            dragging = false
            activeInput = nil
            clampGuiObject(button,8)
        end
    end))
end
makeSmallControlDraggable(up)
makeSmallControlDraggable(down)
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
table.insert(globalConnections,UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        holdingUp, holdingDown = false, false
    end
end))

hud = Instance.new("Frame")
hud.Name = "FlightHUD"
hud.Size = UDim2.fromOffset(180,78)
hud.AnchorPoint = Vector2.new(0,1)
hud.Position = UDim2.new(0,12,1,-12)
hud.BackgroundColor3 = currentTheme[3]
hud.BackgroundTransparency = 0.2
hud.Visible = false
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
local hudRenderConn = RunService.RenderStepped:Connect(function()
    local y = root and root.Parent and root.Position.Y or 0
    if hudText and hudText.Parent then
        hudText.Text = string.format("FLIGHT: %s\nMODE: %s\nSPEED: %d\nALT: %.0f",
            flying and "ON" or "OFF", modes[modeIndex][1], math.floor(flightSpeed), y)
    end
end)
table.insert(globalConnections,hudRenderConn)

-- Initial launcher: language and device layout choice.
local launcher = Instance.new("Frame")
local launcherViewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(390,700)
local launcherWidth = math.min(330,math.max(260,launcherViewport.X-16))
local launcherHeight = math.min(258,math.max(220,launcherViewport.Y-16))
launcher.Size = UDim2.fromOffset(launcherWidth,launcherHeight)
launcher.Position = UDim2.fromOffset((launcherViewport.X-launcherWidth)/2,(launcherViewport.Y-launcherHeight)/2)
launcher.BackgroundColor3 = currentTheme[3]
launcher.Parent = gui
corner(launcher,16)
stroke(launcher,currentTheme[2],2)

local launchTitle = Instance.new("TextLabel")
launchTitle.Size = UDim2.new(1,-20,0,42)
launchTitle.Position = UDim2.fromOffset(10,8)
launchTitle.BackgroundTransparency = 1
launchTitle.Name = "LauncherTitle"
launchTitle.Text = "MAXIM FLIGHT HUB"
launchTitle.TextColor3 = Color3.new(1,1,1)
launchTitle.Font = Enum.Font.GothamBold
launchTitle.TextSize = 17
launchTitle.Parent = launcher

local langBtn = makeButton(launcher,"Язык: Русский",UDim2.new(1,-24,0,36),UDim2.fromOffset(12,55))
local deviceBtn = makeButton(launcher,"Устройство: Планшет",UDim2.new(1,-24,0,36),UDim2.fromOffset(12,99))
local auraBtn = makeButton(launcher,"Аура: Северное сияние",UDim2.new(1,-24,0,36),UDim2.fromOffset(12,143))
local devices = {"Планшет","Телефон","ПК","Консоль"}
local di = table.find(devices, device) or 1
local deviceEnglish = { ["Планшет"]="Tablet", ["Телефон"]="Phone", ["ПК"]="PC", ["Консоль"]="Console" }
local updateLauncherLabels
langBtn.Text = lang == "RU" and "Язык: Русский" or "Language: English"
deviceBtn.Text = lang == "RU" and ("Устройство: "..device) or ("Device: "..(deviceEnglish[device] or device))
deviceBtn.MouseButton1Click:Connect(function()
    di = di % #devices + 1
    device = devices[di]
    updateLauncherLabels()
    saveSettings()
end)
langBtn.MouseButton1Click:Connect(function()
    lang = lang == "RU" and "EN" or "RU"
    updateLauncherLabels()
    saveSettings()
end)
local launch = makeButton(launcher,"ЗАПУСТИТЬ HUB",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,191))
updateLauncherLabels = function()
    langBtn.Text = lang == "RU" and "Язык: Русский" or "Language: English"
    deviceBtn.Text = lang == "RU" and ("Устройство: "..device) or ("Device: "..(deviceEnglish[device] or device))
    auraBtn.Text = tr("Аура")..": "..tr(auraPresets[auraIndex][1])
    subtitle.Text = lang == "RU" and "ПОЛЁТ • ОПЫТ • MAXIM" or "FLIGHT EXPERIENCE  •  MAXIM"
end
auraBtn.MouseButton1Click:Connect(function()
    auraIndex = auraIndex % #auraPresets + 1
    updateLauncherLabels()
    toast("Аура выбрана: "..auraPresets[auraIndex][1])
    saveSettings()
end)
updateLauncherLabels()

local function runLaunchAnimation()
    local overlay = Instance.new("Frame")
    overlay.Name = "LaunchSequence"
    overlay.Size = UDim2.fromScale(1,1)
    overlay.BackgroundColor3 = Color3.fromRGB(4,6,16)
    overlay.BackgroundTransparency = 0.12
    overlay.ZIndex = 90
    overlay.Parent = gui
    local center = Instance.new("Frame")
    center.AnchorPoint = Vector2.new(0.5,0.5)
    center.Position = UDim2.fromScale(0.5,0.5)
    center.Size = UDim2.fromOffset(20,20)
    center.BackgroundColor3 = auraPresets[auraIndex][2]
    center.BackgroundTransparency = 0.08
    center.ZIndex = 92
    center.Parent = overlay
    corner(center,100)
    local ring = Instance.new("UIStroke")
    ring.Color = auraPresets[auraIndex][2]
    ring.Thickness = 3
    ring.Transparency = 0.05
    ring.Parent = center
    local glyph = Instance.new("TextLabel")
    glyph.Size = UDim2.fromScale(1,1)
    glyph.BackgroundTransparency = 1
    glyph.TextColor3 = Color3.new(1,1,1)
    glyph.Font = Enum.Font.GothamBlack
    glyph.TextSize = 12
    glyph.ZIndex = 93
    glyph.Parent = center
    local accent = auraPresets[auraIndex][2]
    local auraGlyphs = {"〰","✺","☀","☾","🔥","✧","❄","⬡","♥","✦","▦"}
    local auraNames = {"AURORA","PLASMA","SOLAR","MOON","PHOENIX","NEBULA","ICE","TOXIC","PINK","GALAXY","CUBIC"}
    local auraNumber = math.clamp(auraIndex,1,#auraPresets)
    local function particle(text,pos,size,rotation)
        local label=Instance.new("TextLabel")
        label.AnchorPoint=Vector2.new(0.5,0.5)
        label.Position=pos
        label.Size=UDim2.fromOffset(size,size)
        label.BackgroundTransparency=1
        label.Text=text
        label.TextColor3=accent
        label.TextTransparency=0.05
        label.TextSize=size
        label.Font=Enum.Font.GothamBlack
        label.Rotation=rotation or 0
        label.ZIndex=94
        label.Parent=overlay
        return label
    end
    glyph.Text = auraGlyphs[auraNumber] or "✦"
    glyph.TextSize = auraNumber==11 and 10 or 15
    center.Size = UDim2.fromOffset(58,58)
    local function ringPulse(size,delayTime,thickness)
        local r=Instance.new("Frame")
        r.AnchorPoint=Vector2.new(0.5,0.5)
        r.Position=UDim2.fromScale(0.5,0.5)
        r.Size=UDim2.fromOffset(28,28)
        r.BackgroundTransparency=1
        r.ZIndex=91
        r.Parent=overlay
        corner(r,100)
        local st=Instance.new("UIStroke")
        st.Color=accent
        st.Thickness=thickness or 2
        st.Transparency=0.12
        st.Parent=r
        task.delay(delayTime or 0,function()
            if r.Parent then
                tween(r,{Size=UDim2.fromOffset(size,size)},0.95)
                tween(st,{Transparency=1},0.95)
            end
        end)
    end
    local function orbitGlyph(char,count,radius,size,spin)
        for i=1,count do
            local a=(i/count)*math.pi*2
            local obj=particle(char,UDim2.fromScale(0.5+math.cos(a)*radius,0.5+math.sin(a)*radius),size,i*360/count)
            tween(obj,{Position=UDim2.fromScale(0.5+math.cos(a+spin)*radius*0.55,0.5+math.sin(a+spin)*radius*0.55),TextTransparency=1},1.0)
        end
    end
    if auraNumber==1 then -- Northern lights: flowing ribbons
        for i=1,4 do
            local ribbon=Instance.new("Frame")
            ribbon.AnchorPoint=Vector2.new(0.5,0.5)
            ribbon.Position=UDim2.fromScale(0.5,0.5+i*0.035)
            ribbon.Size=UDim2.fromOffset(190-i*22,4+i)
            ribbon.Rotation=(i%2==0) and -18 or 18
            ribbon.BackgroundColor3=accent
            ribbon.BackgroundTransparency=0.22+i*0.12
            ribbon.ZIndex=91
            ribbon.Parent=overlay
            corner(ribbon,10)
            tween(ribbon,{Position=ribbon.Position-UDim2.fromScale(0,0.18),Size=UDim2.fromOffset(110,2),BackgroundTransparency=1},1.0)
        end
        ringPulse(260,0,2)
    elseif auraNumber==2 then -- Plasma: fast concentric pulses
        ringPulse(300,0,4); ringPulse(220,0.12,3); ringPulse(140,0.24,2)
        orbitGlyph("•",10,0.34,16,1.8)
    elseif auraNumber==3 then -- Solar crown: rays
        for i=1,16 do particle("✦",UDim2.fromScale(0.5+math.cos(i*math.pi/8)*0.3,0.5+math.sin(i*math.pi/8)*0.3),22,i*22.5) end
        ringPulse(235,0,4)
        tween(center,{Size=UDim2.fromOffset(125,125)},0.8)
    elseif auraNumber==4 then -- Moonlight: crescent drift
        particle("☾",UDim2.fromScale(0.5,0.5),74,0)
        orbitGlyph("·",12,0.3,12,0.8)
        ringPulse(205,0.1,1.5)
    elseif auraNumber==5 then -- Phoenix: rising flame
        for i=1,9 do
            local flame=particle((i%2==0) and "▲" or "🔥",UDim2.fromScale(0.5+math.random(-20,20)/100,0.72),18+math.random(0,10),math.random(-20,20))
            tween(flame,{Position=flame.Position-UDim2.fromScale(0,0.5),TextTransparency=1},0.95)
        end
        ringPulse(170,0.05,3)
    elseif auraNumber==6 then -- Nebula: star field bloom
        for i=1,22 do particle((i%3==0) and "✧" or "·",UDim2.fromScale(math.random(15,85)/100,math.random(15,85)/100),10+math.random(0,16),math.random(0,360)) end
        ringPulse(310,0,2)
    elseif auraNumber==7 then -- Ice spirit: crystal shards
        for i=1,10 do particle("◆",UDim2.fromScale(0.5+math.cos(i*math.pi/5)*0.32,0.5+math.sin(i*math.pi/5)*0.32),18,i*36) end
        ringPulse(250,0,2); ringPulse(170,0.18,1.5)
    elseif auraNumber==8 then -- Toxic pulse: hex-like cells
        for i=1,12 do particle("⬡",UDim2.fromScale(0.5+math.cos(i*math.pi/6)*0.34,0.5+math.sin(i*math.pi/6)*0.34),20,i*30) end
        ringPulse(270,0,3)
    elseif auraNumber==9 then -- Pink impulse: heart burst
        for i=1,12 do particle("♥",UDim2.fromScale(0.5+math.cos(i*math.pi/6)*0.3,0.5+math.sin(i*math.pi/6)*0.3),18,i*30) end
        ringPulse(240,0,3)
    elseif auraNumber==10 then -- Galaxy: rotating star spiral
        for i=1,18 do
            local a=i*0.62
            local star=particle("✦",UDim2.fromScale(0.5+math.cos(a)*(i/60),0.5+math.sin(a)*(i/60)),12+(i%3)*5,i*20)
            tween(star,{Position=UDim2.fromScale(0.5,0.5),TextTransparency=1},1.0)
        end
        ringPulse(290,0.08,2)
    else -- Cubic Pulse: pixel blocks assemble around the selected aura
        for i=1,16 do
            local block=Instance.new("Frame")
            block.AnchorPoint=Vector2.new(0.5,0.5)
            block.Position=UDim2.fromScale(math.random(18,82)/100,math.random(18,82)/100)
            local sz=8+(i%4)*5
            block.Size=UDim2.fromOffset(sz,sz)
            block.BackgroundColor3=accent
            block.BackgroundTransparency=0.12
            block.BorderSizePixel=1
            block.BorderColor3=Color3.fromRGB(30,90,35)
            block.ZIndex=94
            block.Parent=overlay
            tween(block,{Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(3,3),BackgroundTransparency=1},0.85)
        end
        center.Size=UDim2.fromOffset(74,74)
        ringPulse(220,0,3)
    end
    local auraCaption=Instance.new("TextLabel")
    auraCaption.AnchorPoint=Vector2.new(0.5,0.5)
    auraCaption.Position=UDim2.fromScale(0.5,0.66)
    auraCaption.Size=UDim2.new(0.8,0,0,24)
    auraCaption.BackgroundTransparency=1
    auraCaption.Text=auraNames[auraNumber] or "AURA"
    auraCaption.TextColor3=accent
    auraCaption.Font=Enum.Font.GothamBold
    auraCaption.TextSize=13
    auraCaption.ZIndex=94
    auraCaption.Parent=overlay
    tween(auraCaption,{TextTransparency=1,Position=UDim2.fromScale(0.5,0.72)},1.1)
    tween(center,{BackgroundTransparency=0.28},0.55)
    task.wait(1.35)
    tween(overlay,{BackgroundTransparency=1},0.35)
    for _,obj in ipairs(overlay:GetDescendants()) do
        if obj:IsA("GuiObject") then pcall(function() tween(obj,{BackgroundTransparency=1,TextTransparency=1},0.3) end) end
    end
    task.wait(0.38)
    if overlay.Parent then overlay:Destroy() end
end

launch.MouseButton1Click:Connect(function()
    launch.Active=false
    launcher.Visible=false
    if device == "Телефон" then
        mainTargetSize = UDim2.fromOffset(350,500)
    elseif device == "ПК" then
        mainTargetSize = UDim2.fromOffset(430,570)
    elseif device == "Консоль" then
        mainTargetSize = UDim2.fromOffset(410,550)
    else
        mainTargetSize = UDim2.fromOffset(390,530)
    end
    recenterMain()
    task.spawn(function()
        runLaunchAnimation()
        if not gui.Parent then return end
        launcher:Destroy()
        applySelectedAura()
        bubble.Visible = true
        setDockTheme()
        main.Visible = true
        main.Size = UDim2.fromOffset(0,0)
        tween(main,{Size=getResponsiveMainSize()},0.32)
        setTab("Полёт")
        applyTheme(themeIndex)
        saveSettings()
        title.Text = "MAXIM FLIGHT HUB"
    end)
end)

-- Start with main hidden until launcher choice is completed.
main.Visible = false

local characterAddedConn = LP.CharacterAdded:Connect(function(newCharacter)
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
    resetFlightPoseTransforms()
    character, humanoid, root = newCharacter, nil, nil
    local newHumanoid = newCharacter:WaitForChild("Humanoid",10)
    local newRoot = newCharacter:WaitForChild("HumanoidRootPart",10)
    humanoid, root = newHumanoid, newRoot
    local newCam=workspace.CurrentCamera
    if newCam then camBaseFOV=newCam.FieldOfView end
    if noclipOn then setNoclip(true) end
    if launcher and not launcher.Parent then applySelectedAura() end
    local restoreEffects={}
    for name in pairs(activeEffects) do table.insert(restoreEffects,name) end
    for _,name in ipairs(restoreEffects) do
        effectObjects[name] = nil
        addEffect(name,nil,true)
    end
    refreshFlightButton()
end)
table.insert(globalConnections,characterAddedConn)

-- Destroying the ScreenGui also cleans global listeners and restores client state.
local cleanupStarted = false
gui.Destroying:Connect(function()
    if cleanupStarted then return end
    cleanupStarted = true
    disconnectConnections(globalConnections)
    if moveConn then moveConn:Disconnect(); moveConn=nil end
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    if freecamConn then freecamConn:Disconnect(); freecamConn=nil end
    if flying then
        flying=false
        local cleanupCamera=workspace.CurrentCamera
        if cleanupCamera then cleanupCamera.FieldOfView=camBaseFOV end
        if velocity then velocity:Destroy(); velocity=nil end
        if gyro then gyro:Destroy(); gyro=nil end
        resetFlightPoseTransforms()
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand=false
            humanoid.AutoRotate=true
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
    if freecamOn then
        freecamOn=false
        local cam=workspace.CurrentCamera
        if cam then
            cam.CameraType=savedCameraType or Enum.CameraType.Custom
            cam.CameraSubject=savedCameraSubject or humanoid
        end
    end
    if noclipOn then
        noclipOn=false
        for part,original in pairs(noclipOriginalCollision) do
            if part and part.Parent then pcall(function() part.CanCollide=original end) end
            noclipOriginalCollision[part]=nil
        end
    end
    setFullbright(false)
    for _,objects in pairs(effectObjects) do
        for _,object in ipairs(objects) do pcall(function() object:Destroy() end) end
    end
    table.clear(effectObjects)
    table.clear(activeEffects)
    clearSelectedAura()
    disconnectConnections(recoveryConnections)
    for _,rec in ipairs(detachedRecords) do
        disconnectConnections(rec.inputConnections)
        disconnectConnections(rec.menuConnections)
        if rec.placeholder then pcall(function() rec.placeholder:Destroy() end) end
    end
    for _,rec in ipairs(pendingReturns) do
        if rec.button then pcall(function() rec.button:Destroy() end) end
    end
    table.clear(detachedRecords)
    table.clear(pendingReturns)
    table.clear(shortcutItems)
end)

print("[MAXIM FLIGHT HUB] VISUAL FLIGHT EDITION loaded. Delta / Android client script.")
