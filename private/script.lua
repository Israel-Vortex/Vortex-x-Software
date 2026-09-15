--[[
  Vortex X Sage · Loader + Intro (loop infinito)
  Animación + audio en bucle hasta CONTINUAR
]]

if not game:IsLoaded() then
        game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ================= CONFIG =================
local INTRO_AUDIO_URL =
        "https://www.image2url.com/r2/default/audio/1789249131827-a7aff83d-4a2d-4f1a-8f8d-d891a48b7f81.mp3"
local INTRO_FILE = "introvortex-sage.mp3"

local LOGO_ID = "rbxassetid://118833096342184"
local BG_ID = "rbxassetid://133044138027516"

local BASE_URL =
        "https://raw.githubusercontent.com/Israel-Vortex/vortex-x-scripts/refs/heads/main/Official-Vortex-Software/Dev-Project/"

-- Cada PlaceId en su propia clave (Lua no permite [id1, id2] = ...)
local games = {
        [135856908115931] = "Duels.lua", -- Duels normal
        [74084441161738]  = "Duels.lua", -- Duels Server Pro
        [142823291]       = "MM2.lua",
        [125927821145949] = "MOUNTAIN.lua",
        [107778070777162] = "StealAnEgg.lua",
}

local function tween(obj, t, props, style, dir)
        local tw = TweenService:Create(
                obj,
                TweenInfo.new(t or 0.45, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
                props
        )
        tw:Play()
        return tw
end

-- ================= AUDIO =================
local function loadIntroAudio(url)
        if type(writefile) ~= "function" or type(getcustomasset) ~= "function" then
                return nil, "falta writefile/getcustomasset"
        end
        local sound = Instance.new("Sound")
        sound.Name = "VortexIntroAudio"
        sound.Looped = true -- bucle
        sound.Volume = 1
        local ok, err = pcall(function()
                if type(isfile) ~= "function" or not isfile(INTRO_FILE) then
                        writefile(INTRO_FILE, game:HttpGet(url))
                end
                sound.SoundId = getcustomasset(INTRO_FILE)
                sound.Parent = workspace
                sound:Play()
        end)
        if not ok then
                local ok2, err2 = pcall(function()
                        writefile(INTRO_FILE, game:HttpGet(url))
                        sound.SoundId = getcustomasset(INTRO_FILE)
                        sound.Parent = workspace
                        sound:Play()
                end)
                if not ok2 then
                        pcall(function() sound:Destroy() end)
                        return nil, tostring(err2 or err)
                end
        end
        return sound, nil
end

-- ================= UI =================
local finished = false

local gui = Instance.new("ScreenGui")
gui.Name = "VortexSageIntro"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (type(gethui) == "function" and gethui()) or PlayerGui

local cover = Instance.new("Frame")
cover.Size = UDim2.fromScale(1, 1)
cover.BackgroundColor3 = Color3.fromRGB(4, 4, 6)
cover.BorderSizePixel = 0
cover.ClipsDescendants = true
cover.Parent = gui

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.fromScale(1.12, 1.12)
bg.Position = UDim2.fromScale(-0.06, -0.06)
bg.BackgroundTransparency = 1
bg.Image = BG_ID
bg.ImageTransparency = 1
bg.ScaleType = Enum.ScaleType.Crop
bg.Parent = cover
tween(bg, 1.2, { ImageTransparency = 0.5 }, Enum.EasingStyle.Sine)

-- zoom lento infinito del fondo
task.spawn(function()
        while bg.Parent and not finished do
                tween(bg, 6, {
                        Size = UDim2.fromScale(1.18, 1.18),
                        Position = UDim2.fromScale(-0.09, -0.09),
                }, Enum.EasingStyle.Sine)
                task.wait(6)
                if finished then break end
                tween(bg, 6, {
                        Size = UDim2.fromScale(1.08, 1.08),
                        Position = UDim2.fromScale(-0.04, -0.04),
                }, Enum.EasingStyle.Sine)
                task.wait(6)
        end
end)

local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dim.BackgroundTransparency = 0.28
dim.BorderSizePixel = 0
dim.Parent = cover

-- partículas infinitas
local particles = Instance.new("Frame")
particles.Size = UDim2.fromScale(1, 1)
particles.BackgroundTransparency = 1
particles.Parent = cover

local function spawnSpark()
        if not particles.Parent or finished then return end
        local s = Instance.new("Frame")
        local sz = math.random(2, 5)
        s.Size = UDim2.fromOffset(sz, sz)
        s.Position = UDim2.new(math.random(), 0, 1.05, 0)
        s.BackgroundColor3 = Color3.fromRGB(255, math.random(170, 220), math.random(40, 90))
        s.BorderSizePixel = 0
        s.BackgroundTransparency = 0.15
        s.Parent = particles
        Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
        local life = math.random(40, 80) / 10
        tween(s, life, {
                Position = UDim2.new(s.Position.X.Scale, 0, -0.08, 0),
                BackgroundTransparency = 1,
        }, Enum.EasingStyle.Sine)
        task.delay(life + 0.1, function()
                pcall(function() s:Destroy() end)
        end)
end

task.spawn(function()
        while particles.Parent and not finished do
                spawnSpark()
                if math.random() > 0.35 then spawnSpark() end
                task.wait(0.11)
        end
end)

-- flash entrada
local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.fromRGB(255, 220, 120)
flash.BackgroundTransparency = 0.55
flash.BorderSizePixel = 0
flash.Parent = cover
tween(flash, 0.9, { BackgroundTransparency = 1 })

local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.fromScale(0.5, 0.45)
center.Size = UDim2.fromOffset(340, 280)
center.BackgroundTransparency = 1
center.Parent = cover

local glow = Instance.new("Frame")
glow.AnchorPoint = Vector2.new(0.5, 0)
glow.Position = UDim2.new(0.5, 0, 0, 0)
glow.Size = UDim2.fromOffset(160, 160)
glow.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
glow.BackgroundTransparency = 0.85
glow.BorderSizePixel = 0
glow.Parent = center
Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

local logoWrap = Instance.new("Frame")
logoWrap.AnchorPoint = Vector2.new(0.5, 0)
logoWrap.Position = UDim2.new(0.5, 0, 0, 12)
logoWrap.Size = UDim2.fromOffset(20, 20)
logoWrap.BackgroundColor3 = Color3.fromRGB(18, 16, 10)
logoWrap.BorderSizePixel = 0
logoWrap.BackgroundTransparency = 1
logoWrap.Parent = center
Instance.new("UICorner", logoWrap).CornerRadius = UDim.new(0, 26)

local logoStroke = Instance.new("UIStroke", logoWrap)
logoStroke.Color = Color3.fromRGB(255, 205, 60)
logoStroke.Thickness = 2.5
logoStroke.Transparency = 1

local logo = Instance.new("ImageLabel")
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.Position = UDim2.fromScale(0.5, 0.5)
logo.Size = UDim2.fromOffset(12, 12)
logo.BackgroundTransparency = 1
logo.Image = LOGO_ID
logo.ImageTransparency = 1
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = logoWrap

local function makeRing(size, thick)
        local r = Instance.new("Frame")
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Position = UDim2.fromScale(0.5, 0.5)
        r.Size = UDim2.fromOffset(size, size)
        r.BackgroundTransparency = 1
        r.Parent = logoWrap
        local st = Instance.new("UIStroke", r)
        st.Color = Color3.fromRGB(255, 200, 55)
        st.Thickness = thick
        st.Transparency = 0.55
        Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
        return r
end

local ring1 = makeRing(132, 2)
local ring2 = makeRing(150, 1.2)
ring1.Visible = false
ring2.Visible = false

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, 148)
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 215, 80)
title.Text = "VORTEX X SAGE"
title.TextTransparency = 1
title.Parent = center

local titleLine = Instance.new("Frame")
titleLine.AnchorPoint = Vector2.new(0.5, 0)
titleLine.Position = UDim2.new(0.5, 0, 0, 182)
titleLine.Size = UDim2.fromOffset(0, 2)
titleLine.BackgroundColor3 = Color3.fromRGB(255, 200, 55)
titleLine.BorderSizePixel = 0
titleLine.Parent = center
Instance.new("UICorner", titleLine).CornerRadius = UDim.new(1, 0)

local subtitle = Instance.new("TextLabel")
subtitle.AnchorPoint = Vector2.new(0.5, 0)
subtitle.Position = UDim2.new(0.5, 0, 0, 196)
subtitle.Size = UDim2.new(1, 0, 0, 18)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(200, 200, 210)
subtitle.Text = "Presiona CONTINUAR para entrar"
subtitle.TextTransparency = 1
subtitle.Parent = center

local audioStatus = Instance.new("TextLabel")
audioStatus.AnchorPoint = Vector2.new(0.5, 0)
audioStatus.Position = UDim2.new(0.5, 0, 0, 222)
audioStatus.Size = UDim2.new(1, 0, 0, 14)
audioStatus.BackgroundTransparency = 1
audioStatus.Font = Enum.Font.Gotham
audioStatus.TextSize = 10
audioStatus.TextColor3 = Color3.fromRGB(140, 140, 150)
audioStatus.Text = "Audio: cargando…"
audioStatus.Parent = center

-- CONTINUAR (centro abajo)
local continueBtn = Instance.new("TextButton")
continueBtn.AnchorPoint = Vector2.new(0.5, 1)
continueBtn.Position = UDim2.new(0.5, 0, 1, -70)
continueBtn.Size = UDim2.fromOffset(180, 46)
continueBtn.BackgroundColor3 = Color3.fromRGB(210, 160, 35)
continueBtn.Text = "CONTINUAR"
continueBtn.Font = Enum.Font.GothamBold
continueBtn.TextSize = 16
continueBtn.TextColor3 = Color3.fromRGB(20, 16, 8)
continueBtn.AutoButtonColor = true
continueBtn.Parent = cover
Instance.new("UICorner", continueBtn).CornerRadius = UDim.new(0, 14)
local contStroke = Instance.new("UIStroke", continueBtn)
contStroke.Color = Color3.fromRGB(255, 230, 120)
contStroke.Thickness = 1.5
contStroke.Transparency = 0.25

-- pulse botón
task.spawn(function()
        while continueBtn.Parent and not finished do
                tween(continueBtn, 0.85, { Size = UDim2.fromOffset(188, 50) }, Enum.EasingStyle.Sine)
                task.wait(0.85)
                if finished then break end
                tween(continueBtn, 0.85, { Size = UDim2.fromOffset(180, 46) }, Enum.EasingStyle.Sine)
                task.wait(0.85)
        end
end)

local footer = Instance.new("TextLabel")
footer.AnchorPoint = Vector2.new(0.5, 1)
footer.Position = UDim2.new(0.5, 0, 1, -28)
footer.Size = UDim2.new(1, -40, 0, 16)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.Gotham
footer.TextSize = 11
footer.TextColor3 = Color3.fromRGB(110, 110, 120)
footer.Text = "By Israelcc & Novak · Vortex X Sage"
footer.Parent = cover

-- ================= SOUND LOOP =================
local sound
task.spawn(function()
        local s, info = loadIntroAudio(INTRO_AUDIO_URL)
        sound = s
        if sound then
                audioStatus.Text = "Audio: ▶ en bucle"
                audioStatus.TextColor3 = Color3.fromRGB(120, 220, 140)
        else
                audioStatus.Text = "Audio: OFF (" .. tostring(info) .. ")"
                audioStatus.TextColor3 = Color3.fromRGB(255, 120, 120)
                warn("[Vortex Intro] Audio:", info)
        end
end)

-- ================= ANIMS ENTRADA + LOOP =================
task.spawn(function()
        tween(logoWrap, 0.85, {
                Size = UDim2.fromOffset(118, 118),
                BackgroundTransparency = 0,
        }, Enum.EasingStyle.Back)
        tween(logo, 0.85, {
                Size = UDim2.fromOffset(82, 82),
                ImageTransparency = 0,
        }, Enum.EasingStyle.Back)
        tween(logoStroke, 0.7, { Transparency = 0.15 })
        tween(glow, 1.1, { BackgroundTransparency = 0.72, Size = UDim2.fromOffset(200, 200) })

        task.wait(0.35)
        ring1.Visible = true
        ring2.Visible = true
        tween(title, 0.55, { TextTransparency = 0 })
        tween(titleLine, 0.55, { Size = UDim2.fromOffset(160, 2) }, Enum.EasingStyle.Quint)
        task.wait(0.1)
        tween(subtitle, 0.45, { TextTransparency = 0 })

        -- glow pulse infinito
        while glow.Parent and not finished do
                tween(glow, 1.0, { BackgroundTransparency = 0.58, Size = UDim2.fromOffset(210, 210) }, Enum.EasingStyle.Sine)
                task.wait(1.0)
                if finished then break end
                tween(glow, 1.0, { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(180, 180) }, Enum.EasingStyle.Sine)
                task.wait(1.0)
        end
end)

-- título “respiración”
task.spawn(function()
        task.wait(1)
        while title.Parent and not finished do
                tween(title, 1.2, { TextTransparency = 0.15 }, Enum.EasingStyle.Sine)
                task.wait(1.2)
                if finished then break end
                tween(title, 1.2, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                task.wait(1.2)
        end
end)

local rotConn = RunService.RenderStepped:Connect(function(dt)
        if not logoWrap.Parent or finished then return end
        ring1.Rotation = (ring1.Rotation + dt * 70) % 360
        ring2.Rotation = (ring2.Rotation + dt * -48) % 360
end)

-- ================= CONTINUAR → LOADER =================
local function stopAudio()
        pcall(function()
                if sound and sound.Parent then
                        for i = 10, 0, -1 do
                                if not sound.Parent then break end
                                sound.Volume = i / 10
                                task.wait(0.03)
                        end
                        sound:Stop()
                        sound:Destroy()
                end
        end)
        pcall(function()
                local s = workspace:FindFirstChild("VortexIntroAudio")
                if s then
                        s:Stop()
                        s:Destroy()
                end
        end)
end

local function destroyIntro()
        pcall(function()
                if rotConn then rotConn:Disconnect() end
        end)
        stopAudio()
        tween(center, 0.4, { Position = UDim2.fromScale(0.5, 0.4) })
        tween(cover, 0.5, { BackgroundTransparency = 1 })
        tween(bg, 0.5, { ImageTransparency = 1 })
        tween(dim, 0.5, { BackgroundTransparency = 1 })
        tween(title, 0.35, { TextTransparency = 1 })
        tween(subtitle, 0.35, { TextTransparency = 1 })
        tween(audioStatus, 0.3, { TextTransparency = 1 })
        tween(logo, 0.35, { ImageTransparency = 1 })
        tween(logoWrap, 0.35, { BackgroundTransparency = 1 })
        tween(glow, 0.35, { BackgroundTransparency = 1 })
        tween(continueBtn, 0.3, { BackgroundTransparency = 1, TextTransparency = 1 })
        tween(footer, 0.3, { TextTransparency = 1 })
        tween(titleLine, 0.3, { BackgroundTransparency = 1 })
        task.delay(0.55, function()
                pcall(function() gui:Destroy() end)
        end)
end

local function runGameLoader()
        local scriptFile = games[game.PlaceId]
        if scriptFile then
                local success, err = pcall(function()
                        loadstring(game:HttpGet(BASE_URL .. scriptFile))()
                end)
                if not success then
                        warn("[VORTEX X SAGE] Error al cargar el script:", err)
                end
        else
                warn("[VORTEX X SAGE] Juego no registrado o script en mantenimiento. PlaceId: " .. tostring(game.PlaceId))
        end
end

local function onContinue()
        if finished then return end
        finished = true
        subtitle.Text = "Entrando…"
        local f2 = Instance.new("Frame")
        f2.Size = UDim2.fromScale(1, 1)
        f2.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
        f2.BackgroundTransparency = 0.7
        f2.BorderSizePixel = 0
        f2.Parent = cover
        tween(f2, 0.45, { BackgroundTransparency = 1 })
        task.wait(0.3)
        destroyIntro()
        task.wait(0.4)
        runGameLoader()
end

continueBtn.MouseButton1Click:Connect(onContinue)
continueBtn.MouseEnter:Connect(function()
        if finished then return end
        tween(continueBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(255, 200, 55) })
end)
continueBtn.MouseLeave:Connect(function()
        if finished then return end
        tween(continueBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(210, 160, 35) })
end)

print("[Vortex X Sage] Intro loop · espera CONTINUAR")
