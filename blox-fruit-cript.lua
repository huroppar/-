local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--================================
-- Services
--================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--================================
-- キャラ取得（安全版）
--================================
local function getCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

--================================
-- 設定値
--================================
local speedEnabled = false
local speedValue = 30
local originalWalkSpeed = nil

local jumpEnabled = false
local jumpPowerValue = 50
local originalJumpPower = nil

local infiniteJumpEnabled = false

-- noclip
local noclipEnabled = false
local noclipConn = nil
local originalCanCollide = {}

-- freeze
local freezeEnabled = false
local freezeConn = nil
local freezeCFrame = nil

-- 空中TP
local airTPActive = false
local airHeight = 2000
local airOriginCF = nil
local airForce = nil

-- 足場
local platforms = {}

--================================
-- Rayfield Window
--================================
local Window = Rayfield:CreateWindow({
    Name = "Furo Hub",
    LoadingTitle = "読み込み中.....",
    LoadingSubtitle = "Editting by Furopper",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FuroHub",
        FileName = "Player"
    },
    KeySystem = false
})

--================================
-- プレイヤータブ
--================================
local playerTab = Window:CreateTab("プレイヤー", 4483362458)

loadstring(game:HttpGet("https://raw.githubusercontent.com/huroppar/-/refs/heads/main/3script.lua"))()
--================================
-- ESP TAB
--================================
local espTab = Window:CreateTab("ESP", 4483362458)

--================================
-- Services（ESP専用で再定義）
--================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--================================
-- 設定フラグ
--================================
local showAllyHighlight = false
local showEnemyHighlight = false
local showNameESP = false
local showLineESP = false
local fullBrightEnabled = false
local worldXray = false
local playerXray = false
local itemHighlight = false
local chestHighlight = false
local hitboxEnabled = false
local worldXrayAlpha = 0.6
local playerXrayAlpha = 0.6
local clockGuiEnabled = false

--================================
-- 管理テーブル
--================================
local highlights = {}
local drawings = {}
local lineDrawings = {}
local chestHighlights = {}
local originalSize = {}

--================================
-- ユーティリティ
--================================
local function isEnemy(player)
	if not LocalPlayer.Team or not player.Team then
		return player ~= LocalPlayer
	end
	return player.Team ~= LocalPlayer.Team
end

local function createHighlight(char, color)
	if highlights[char] then return end
	local hl = Instance.new("Highlight")
	hl.FillColor = color
	hl.OutlineColor = Color3.new(1,1,1)
	hl.FillTransparency = 0.5
	hl.Parent = char
	highlights[char] = hl
end

local function removeHighlight(char)
	if highlights[char] then
		highlights[char]:Destroy()
		highlights[char] = nil
	end
end

--================================
-- Name & Line ESP
--================================
RunService.RenderStepped:Connect(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				-- Name ESP
				if showNameESP and onScreen then
					if not drawings[plr] then
						local text = Drawing.new("Text")
						text.Center = true
						text.Outline = true
						text.Size = 16
						drawings[plr] = text
					end
					local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
					drawings[plr].Visible = true
					drawings[plr].Text = plr.Name .. " | " .. dist .. "m"
					drawings[plr].Position = Vector2.new(pos.X, pos.Y - 25)
					drawings[plr].Color = isEnemy(plr) and Color3.new(1,0,0) or Color3.new(0,1,0)
				elseif drawings[plr] then
					drawings[plr].Visible = false
				end
				-- Line ESP
				if showLineESP and onScreen then
					if not lineDrawings[plr] then
						local line = Drawing.new("Line")
						line.Thickness = 1.5
						lineDrawings[plr] = line
					end
					local line = lineDrawings[plr]
					line.Visible = true
					line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
					line.To = Vector2.new(pos.X, pos.Y)
					line.Color = Color3.new(1, 0, 0)
				elseif lineDrawings[plr] then
					lineDrawings[plr].Visible = false
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if drawings[plr] then
		drawings[plr]:Remove()
		drawings[plr] = nil
	end
	if lineDrawings[plr] then
		lineDrawings[plr]:Remove()
		lineDrawings[plr] = nil
	end
	if plr.Character then
		removeHighlight(plr.Character)
	end
	originalSize[plr] = nil
end)

--================================
-- Clock（ESPラベル + 自作GUI）
--================================
local ClockLabel = espTab:CreateLabel("Time: --:--")
local clockGuiEnabled = false

-- 自作GUI
local clockGui = Instance.new("ScreenGui")
clockGui.Name = "ClockGui"
clockGui.ResetOnSpawn = false
clockGui.Enabled = false
clockGui.Parent = game.CoreGui

local clockFrame = Instance.new("Frame")
clockFrame.Size = UDim2.new(0, 220, 0, 60)
clockFrame.Position = UDim2.new(0.5, -110, 0, 40)
clockFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
clockFrame.BackgroundTransparency = 0.15
clockFrame.Parent = clockGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = clockFrame

local clockLabelGui = Instance.new("TextLabel")
clockLabelGui.Size = UDim2.new(1, -10, 1, -10)
clockLabelGui.Position = UDim2.new(0, 5, 0, 5)
clockLabelGui.BackgroundTransparency = 1
clockLabelGui.Font = Enum.Font.GothamBold
clockLabelGui.TextScaled = true
clockLabelGui.TextColor3 = Color3.fromRGB(255,255,255)
clockLabelGui.Text = "--:--"
clockLabelGui.Parent = clockFrame

local NIGHT_START = 18
local MORNING_START = 7

local function isNight(t)
	return t >= NIGHT_START or t < MORNING_START
end
local function formatTime(t)
	local h = math.floor(t)
	local m = math.floor((t - h) * 60)
	return string.format("%02d:%02d", h, m)
end

RunService.Heartbeat:Connect(function()
	local t = Lighting.ClockTime
	local timeText = formatTime(t)
	local state = isNight(t) and "Night" or "Morning"
	if ClockLabel then
		ClockLabel:Set("Time: " .. timeText .. " (" .. state .. ")")
	end
	if clockGuiEnabled and clockLabelGui then
		clockLabelGui.Text = timeText .. " (" .. state .. ")"
	end
end)

espTab:CreateToggle({
	Name = "Clock GUI 表示",
	CurrentValue = false,
	Callback = function(v)
		clockGuiEnabled = v
		if clockGui then
			clockGui.Enabled = v
		end
	end
})

--================================
-- Position ESPラベル
--================================
local positionLabel = espTab:CreateLabel("Position: --, --, --")
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		positionLabel:Set(string.format("Position: X %.1f | Y %.1f | Z %.1f", pos.X, pos.Y, pos.Z))
	else
		positionLabel:Set("Position: Loading...")
	end
end)

--================================
-- FullBright
--================================
local fullBrightConn
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd
}
espTab:CreateToggle({
	Name = "FullBright",
	CurrentValue = false,
	Callback = function(v)
		if v then
			if fullBrightConn then fullBrightConn:Disconnect() end
			fullBrightConn = RunService.RenderStepped:Connect(function()
				Lighting.Brightness = 5
				Lighting.ClockTime = 12
				Lighting.FogEnd = 1e9
			end)
		else
			if fullBrightConn then
				fullBrightConn:Disconnect()
				fullBrightConn = nil
			end
			Lighting.Brightness = originalLighting.Brightness
			Lighting.ClockTime = originalLighting.ClockTime
			Lighting.FogEnd = originalLighting.FogEnd
		end
	end
})

--================================
-- Fog / Atmosphere Toggle
--================================
local fogEnabled = false
local fogConn
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd

local savedAtmospheres = {}
for _,v in ipairs(Lighting:GetChildren()) do
	if v:IsA("Atmosphere") then
		table.insert(savedAtmospheres, v:Clone())
	end
end

local savedEffects = {}
for _,v in ipairs(Lighting:GetChildren()) do
	if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
		savedEffects[v] = v.Enabled
	end
end

local function removeFog()
	Lighting.FogStart = 1e9
	Lighting.FogEnd = 1e9
	for _,v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		elseif savedEffects[v] ~= nil then
			v.Enabled = false
		end
	end
end

local function FogON()
	if fogEnabled then return end
	fogEnabled = true
	removeFog()
	fogConn = RunService.Heartbeat:Connect(function()
		if fogEnabled then removeFog() end
	end)
end

local function FogOFF()
	fogEnabled = false
	if fogConn then fogConn:Disconnect(); fogConn=nil end
	Lighting.FogStart = originalFogStart
	Lighting.FogEnd = originalFogEnd
	for _,v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere") then v:Destroy() end
	end
	for _,a in ipairs(savedAtmospheres) do a:Clone().Parent = Lighting end
	for eff,enabled in pairs(savedEffects) do
		if eff and eff.Parent then eff.Enabled = enabled end
	end
end

espTab:CreateToggle({
	Name = "Fog / Atmosphere 無効化",
	CurrentValue = false,
	Callback = function(v)
		if v then FogON() else FogOFF() end
	end
})

--================================
-- プレイヤー Highlight
--================================
espTab:CreateToggle({
    Name = "味方ハイライト",
    CurrentValue = false,
    Callback = function(v)
        showAllyHighlight = v
    end
})

espTab:CreateToggle({
    Name = "敵ハイライト",
    CurrentValue = false,
    Callback = function(v)
        showEnemyHighlight = v
    end
})

RunService.Stepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            if plr ~= LocalPlayer then
                if isEnemy(plr) and showEnemyHighlight then
                    createHighlight(plr.Character, Color3.new(1,0,0))
                elseif not isEnemy(plr) and showAllyHighlight then
                    createHighlight(plr.Character, Color3.new(0,1,0))
                else
                    removeHighlight(plr.Character)
                end
            end
        end
    end
end)

--================================
-- Name / Line ESP Toggles
--================================
espTab:CreateToggle({
    Name = "名前ESP",
    CurrentValue = false,
    Callback = function(v)
        showNameESP = v
    end
})

espTab:CreateToggle({ 
	Name="線ESP", 
	CurrentValue=false, 		
	Callback=function(v)
		showLineESP = v
	end
})

--================================
-- X-Ray
--================================
espTab:CreateToggle({
    Name = "ワールドX-Ray",
    CurrentValue = false,
    Callback = function(v)
        worldXray = v
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") then
                p.LocalTransparencyModifier = v and worldXrayAlpha or 0
            end
        end
    end
})

espTab:CreateSlider({
    Name = "ワールドX-Ray透明度",
    Range = {0, 0.95},
    Increment = 0.05,
    Suffix = "Alpha",
    CurrentValue = 0.6,
    Callback = function(v)
        worldXrayAlpha = v
        if worldXray then
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.LocalTransparencyModifier = v
                end
            end
        end
    end
})

espTab:CreateToggle({
    Name = "プレイヤーX-Ray",
    CurrentValue = false,
    Callback = function(v)
        playerXray = v
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.LocalTransparencyModifier = v and playerXrayAlpha or 0
                    end
                end
            end
        end
    end
})

espTab:CreateSlider({
    Name = "プレイヤーX-Ray透明度",
    Range = {0, 0.95},
    Increment = 0.05,
    Suffix = "Alpha",
    CurrentValue = 0.6,
    Callback = function(v)
        playerXrayAlpha = v
        if playerXray then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, p in ipairs(plr.Character:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.LocalTransparencyModifier = v
                        end
                    end
                end
            end
        end
    end
})

--================================
-- アイテム / チェスト
--================================
local function highlightByName(keyword, color)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name:lower(), keyword) then
            local adornee = obj:FindFirstChildWhichIsA("BasePart")
            if adornee then
                createHighlight(adornee, color)
            end
        end
    end
end


espTab:CreateToggle({
    Name = "アイテムハイライト",
    CurrentValue = false,
    Callback = function(v)
        itemHighlight = v
        if v then
            highlightByName("item", Color3.fromRGB(0,255,255))
        end
    end
})

espTab:CreateToggle({
    Name = "チェストハイライト",
    CurrentValue = false,
    Callback = function(v)
        chestHighlight = v

        if v then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and string.find(obj.Name:lower(), "chest") then
                    if not chestHighlights[obj] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 215, 0)
                        hl.FillTransparency = 0.4
                        hl.Parent = obj
                        chestHighlights[obj] = hl
                    end
                end
            end
        else
            for _, hl in pairs(chestHighlights) do
                if hl then hl:Destroy() end
            end
            chestHighlights = {}
        end
    end
})


--================================
-- HitBox
--================================
-- HitBox倍率
local hitboxScale = 1

-- HitBoxトグル
espTab:CreateToggle({
    Name = "HitBox表示",
    CurrentValue = false,
    Callback = function(v)
        hitboxEnabled = v

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if v then
                        if not originalSize[plr] then
                            originalSize[plr] = hrp.Size
                        end

                        -- キャラサイズに応じてHitBoxを拡大
                        local baseScale = math.max(hrp.Size.X, hrp.Size.Y, hrp.Size.Z) / 2
                        local newSize = Vector3.new(baseScale*2, baseScale*2, baseScale*2) * hitboxScale
                        hrp.Size = newSize
                        hrp.Transparency = 0.5
                        hrp.CanCollide = false
                        hrp.Color = isEnemy(plr) and Color3.new(1,0,0) or Color3.new(1,1,1)
                    else
                        if originalSize[plr] then
                            hrp.Size = originalSize[plr]
                        end
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
})

-- HitBoxスライダー
espTab:CreateSlider({
    Name = "HitBox倍率",
    Range = {1, 20}, -- 1倍～10倍まで
    Increment = 0.1,
    Suffix = "倍",
    CurrentValue = 1,
    Callback = function(v)
        hitboxScale = v

        -- HitBox有効時は即反映
        if hitboxEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and originalSize[plr] then
                        local baseScale = math.max(originalSize[plr].X, originalSize[plr].Y, originalSize[plr].Z) / 2
                        hrp.Size = Vector3.new(baseScale*2, baseScale*2, baseScale*2) * hitboxScale
                        hrp.Transparency = 0.5
                    end
                end
            end
        end
    end
})
--================================
-- 自分の攻撃HitBox拡大
--================================
-- 元サイズ保存用
local originalSize = nil
local hitboxScale = 1

-- HitBox拡大用スライダー
espTab:CreateSlider({
    Name = "攻撃範囲倍率",
    Range = {1, 10},
    Increment = 0.1,
    Suffix = "倍",
    CurrentValue = 1,
    Callback = function(v)
        hitboxScale = v

        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not originalSize then
                    originalSize = hrp.Size -- 元サイズを保存
                end
                -- 倍率に応じてサイズ変更
                hrp.Size = originalSize * hitboxScale
            end
        end
    end
})


--========================================================--
--                     🔥 Combat Tab + Invisible 完全統合版（地面補正付き）
--========================================================--
local combatTab = Window:CreateTab("戦闘", 4483362458)
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
--============================--
-- 状態変数
--============================--
local SAFE_Y = -200000
local selectedTarget = nil
local followActive = false
local followMode = nil -- "normal", "v2", "under"
local originalPos_Follow = nil

local tracerActive = false
local tracerLine = Drawing.new("Line")
tracerLine.Visible = false
tracerLine.Thickness = 2
tracerLine.Transparency = 1
tracerLine.Color = Color3.fromRGB(0,255,255)

local noclipConn = nil
local noclipEnabled = false
local originalCanCollide = {}
local UserInputService = game:GetService("UserInputService")

--============================--
-- Invisible 用
--============================--
local invisible = false
local parts = {}
local invisibleKey = Enum.KeyCode.G
local keybindEnabled = false
local character, humanoid, rootPart

local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    parts = {}
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency == 0 then
            table.insert(parts, obj)
        end
    end
end

setupCharacter()
player.CharacterAdded:Connect(function()
    setupCharacter()
    if invisible then
        for _, part in pairs(parts) do
            part.Transparency = 0.5
        end
    end
end)

local function setInvisible(value)
    invisible = value
    for _, part in pairs(parts) do
        part.Transparency = invisible and 0.5 or 0
    end

    -- 画面通知
    Rayfield:Notify({
        Title = "Invisible",
        Content = invisible and "透明化 ON" or "透明化 OFF",
        Duration = 3
    })
end

--============================--
-- プレイヤー選択
--============================--
_G.SetTarget = function(tar)
    if typeof(tar) == "Instance" and tar:FindFirstChild("Humanoid") then
        selectedTarget = tar
    end
end

--============================--
-- Noclip
--============================--
local function enableNoclip()
    if noclipConn then return end
    if not character then return end
    for _,p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then
            originalCanCollide[p] = p.CanCollide
        end
    end
    noclipConn = RunService.Stepped:Connect(function()
        if not character then return end
        for _,p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    if not character then return end
    for p,canCollide in pairs(originalCanCollide) do
        if p and p.Parent then
            p.CanCollide = canCollide
        end
    end
    originalCanCollide = {}
end

--============================--
-- Follow系
--============================--
local function GetHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function GetHumanoid(char) return char and char:FindFirstChildOfClass("Humanoid") end

local function EnableFollow(mode)
    if not selectedTarget then return end
    followActive = true
    followMode = mode
    local hrp = GetHRP(player.Character)
    if hrp and not originalPos_Follow then
        originalPos_Follow = hrp.CFrame -- 下向き張り付き前の位置を保存
    end
end

local function ReturnToOriginalPosition()
    local hrp = GetHRP(player.Character)
    local hum = GetHumanoid(player.Character)
    if not hrp or not originalPos_Follow then return end

    hrp.CFrame = originalPos_Follow
    hum.PlatformStand = false
    disableNoclip()
    noclipEnabled = false
    originalPos_Follow = nil
end

local function DisableFollow()
    followActive = false
    followMode = nil
    ReturnToOriginalPosition()
end


--============================--
-- GUI設定
--============================--
combatTab:CreateButton({
    Name = "選択中のプレイヤーへ TP",
    Callback = function()
        if selectedTarget and selectedTarget.Character and GetHRP(selectedTarget.Character) then
            player.Character:PivotTo(GetHRP(selectedTarget.Character).CFrame * CFrame.new(0,0,3))
        else
            RayField:Notify({Title="エラー", Content="ターゲット無効！", Duration=3})
        end
    end
})

combatTab:CreateToggle({Name="普通の張り付き", Callback=function(v) if v then EnableFollow("normal") else DisableFollow() end end})
combatTab:CreateToggle({Name="張り付きv2（BloxFruit使用可）", Callback=function(v) if v then EnableFollow("v2") else DisableFollow() end end})
combatTab:CreateToggle({Name="下向き張り付き", Callback=function(v) if v then EnableFollow("under") else DisableFollow() end end})
combatTab:CreateToggle({Name="ターゲット線", Callback=function(v) tracerActive=v if not v then tracerLine.Visible=false end end})

combatTab:CreateToggle({
    Name = "Invisible(ゲームによっては使用不可)",
    CurrentValue = false,
    Callback = function(v) setInvisible(v) end
})

combatTab:CreateToggle({
    Name = "キーで切替有効",
    CurrentValue = false,
    Callback = function(v) keybindEnabled = v end
})

combatTab:CreateInput({
    Name = "Invisible キー設定",
    PlaceholderText = "例: G",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local success, kc = pcall(function() return Enum.KeyCode[text:upper()] end)
        if success and kc then
            invisibleKey = kc
            RayField:Notify({Title="設定完了", Content="Invisibleキーを "..text:upper().." に設定しました", Duration=3})
        else
            RayField:Notify({Title="エラー", Content="無効なキー名です", Duration=3})
        end
    end
})



--============================--
-- プレイヤー一覧 + HP
--============================--
combatTab:CreateSection("プレイヤー一覧")
local playerButtons = {}

local function GetHP(plr)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then return math.floor(hum.Health), math.floor(hum.MaxHealth) end
    return 0,0
end

local function CreatePlayerButton(plr)
    local hp,maxhp = GetHP(plr)
    local btn = combatTab:CreateButton({
        Name = plr.Name.." ["..hp.."/"..maxhp.."]",
        Callback = function()
            selectedTarget = plr
            Rayfield:Notify({
				Title = "選択", 
				Content = plr.Name.." をターゲットにしたよ！", 
				Duration = 3 
			})
        end
    })
    playerButtons[plr] = btn
end


local function UpdatePlayerList()
    local current = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            current[p] = true
            if not playerButtons[p] then CreatePlayerButton(p) end
        end
    end
    for plr,btn in pairs(playerButtons) do
        if not current[plr] then
            pcall(function() btn:Remove() end)
            playerButtons[plr] = nil
        end
    end
end

UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

--============================--
-- キー入力で Invisible 切替（修正版）
--============================--
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not keybindEnabled then return end

    if input.UserInputType == Enum.UserInputType.Keyboard
    and input.KeyCode == invisibleKey then
        setInvisible(not invisible)
    end
end)

--============================--
-- Heartbeat: Invisible 本体下移動（元仕様通り）
--============================--
RunService.Heartbeat:Connect(function()
    if invisible and rootPart and humanoid then
        local cf = rootPart.CFrame
        local camOffset = humanoid.CameraOffset
        local hidden = cf * CFrame.new(0, -SAFE_Y, 0)
        rootPart.CFrame = hidden
        humanoid.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        game:GetService("RunService").RenderStepped:Wait()
        rootPart.CFrame = cf
        humanoid.CameraOffset = camOffset
    end
end)

--============================--
-- RenderStepped: Follow + Tracer
--============================--
RunService.RenderStepped:Connect(function(dt)
    if not character or not humanoid or not rootPart then return end

    -- 張り付き中は物理制御で重力無効
    if followActive then
        rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end

    -- ==== Follow ====
    if followActive and selectedTarget and selectedTarget.Character then
        local targetHRP = GetHRP(selectedTarget.Character)
        if targetHRP then
            if followMode=="normal" then
                rootPart.CFrame = targetHRP.CFrame * CFrame.new(0,0,7)
            elseif followMode=="v2" then
                local dVec = targetHRP.Position - rootPart.Position
                local dist = dVec.Magnitude
                local speed = 300
                if dist > 200 then
                    rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position + dVec.Unit * speed * dt), 1)
                else
                    rootPart.CFrame = rootPart.CFrame:Lerp(targetHRP.CFrame * CFrame.new(0,0,7), 0.2)
                end
            elseif followMode=="under" then
                if not noclipEnabled then
                    enableNoclip()
                    noclipEnabled = true
                end
                humanoid.PlatformStand = true
                local goalCF = targetHRP.CFrame * CFrame.new(0,-12,0) * CFrame.Angles(math.rad(90),0,0)
                rootPart.CFrame = rootPart.CFrame:Lerp(goalCF, 0.3)
            end
        end
    else
        humanoid.PlatformStand = false
        if noclipEnabled then
            disableNoclip()
            noclipEnabled = false
        end
    end

    -- ==== Tracer ====
    if tracerActive and selectedTarget and selectedTarget.Character then
        local targetHRP = GetHRP(selectedTarget.Character)
        if targetHRP then
            local p1,v1 = camera:WorldToViewportPoint(rootPart.Position)
            local p2,v2 = camera:WorldToViewportPoint(targetHRP.Position)
            tracerLine.Visible = v1 and v2
            if v1 and v2 then
                tracerLine.From = Vector2.new(p1.X,p1.Y)
                tracerLine.To   = Vector2.new(p2.X,p2.Y)
            end
        else
            tracerLine.Visible = false
        end
    else
        tracerLine.Visible = false
    end
end)
--============================--
-- HP更新
--============================--
RunService.Heartbeat:Connect(function()
    for plr, btn in pairs(playerButtons) do
        if btn then
            local name = plr.Name or "Unknown"
            local hp,maxhp = GetHP(plr)
            hp = hp or 0
            maxhp = maxhp or 0
            pcall(function()
                btn:Set(name.." ["..hp.."/"..maxhp.."]")
            end)
        end
    end
end)



--========================================================--
--                 🔥 World Of Stand                     --
--========================================================--

--================= Services =================
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local humanoid, rootPart
local parts = {}



--================= GUI =================
local StandTab = Window:CreateTab("スタンドの世界", 4483362458)

--========================================================--
--                 🔒 Character Setup                    --
--========================================================--
local function setupCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")

    parts = {}
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(parts, v)
        end
    end
end

setupCharacter()
LocalPlayer.CharacterAdded:Connect(function()
    invisibleEnabled = false
    setupCharacter()
end)


--========================================================--
--                 📦 Chest System                       --
--========================================================--
local currentChest = 0
local maxChest = 54

local availableChests = {}
for i = 1, maxChest do
    table.insert(availableChests, tostring(i))
end

local chestLabel = StandTab:CreateLabel("現在のチェスト: 0")

--================= Dropdown =================
local isDropdownInitialized = false

local chestDropdown = StandTab:CreateDropdown({
    Name = "開くチェストを選択",
    Options = availableChests,
    CurrentOption = {availableChests[1]},
    MultipleOptions = false,
    Callback = function(option)
        if not isDropdownInitialized then return end
        local number = tonumber(option[1])
        if not number then return end

        local chest = Workspace:FindFirstChild(tostring(number))
        if chest and chest.PrimaryPart then
            setInvisible(false)
            LocalPlayer.Character:SetPrimaryPartCFrame(
                CFrame.new(chest.PrimaryPart.Position + Vector3.new(0, 7, 0))
            )
            currentChest = number
            chestLabel:Set("現在のチェスト: " .. number)
        end
    end
})

isDropdownInitialized = true

--================= Input =================
StandTab:CreateInput({
    Name = "チェスト番号入力",
    PlaceholderText = "1〜" .. maxChest,
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local number = tonumber(text)
        if not number or number < 1 or number > maxChest then return end

        local chest = Workspace:FindFirstChild(tostring(number))
        if chest and chest.PrimaryPart then
            setInvisible(false)
            LocalPlayer.Character:SetPrimaryPartCFrame(
                CFrame.new(chest.PrimaryPart.Position + Vector3.new(0, 7, 0))
            )
            currentChest = number
            chestLabel:Set("現在のチェスト: " .. number)
        end
    end
})

--================= Next Chest =================
StandTab:CreateButton({
    Name = "次のチェストにTP",
    Callback = function()
        currentChest += 1
        if currentChest > maxChest then currentChest = 1 end

        local chest = Workspace:FindFirstChild(tostring(currentChest))
        if chest and chest.PrimaryPart then
            setInvisible(false)
            LocalPlayer.Character:SetPrimaryPartCFrame(
                CFrame.new(chest.PrimaryPart.Position + Vector3.new(0, 7, 0))
            )
            chestLabel:Set("現在のチェスト: " .. currentChest)
        end
    end
})

--================= Chest Auto Update =================
RunService.RenderStepped:Connect(function()
    local changed = false
    for i = #availableChests, 1, -1 do
        if not Workspace:FindFirstChild(availableChests[i]) then
            table.remove(availableChests, i)
            changed = true
        end
    end
    if changed then
        chestDropdown:Refresh(availableChests)
    end
end)


--========================================================--
--                🎯 Auto Aim Tab (Tab2)                 --
--========================================================--
local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local UIS = game:GetService("UserInputService") 
local localPlayer = Players.LocalPlayer 
local camera = workspace.CurrentCamera 
--==================== -- 設定 --==================== 
local autoAimEnabled = false 
local lockedPart = nil 
local FOV_RADIUS = 160 
local AIM_PART = "HumanoidRootPart" 
local AIM_STRENGTH = 0.35 
local showFOV = true

--====================
-- FOV表示
--====================
local fov = Drawing.new("Circle")
fov.Radius = FOV_RADIUS
fov.Thickness = 2
fov.NumSides = 64
fov.Filled = false
fov.Color = Color3.fromRGB(255, 255, 255)
fov.Visible = false

--====================
-- ShiftLock判定
--====================
local function isShiftLock()
	return UIS.MouseBehavior == Enum.MouseBehavior.LockCenter
end

--====================
-- 一番近いプレイヤー取得
--====================
local function getClosestPlayer()
	local closestPart = nil
	local shortest = math.huge
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= localPlayer and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local part = plr.Character:FindFirstChild(AIM_PART)
			if hum and hum.Health > 0 and part then
				local pos, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if dist < FOV_RADIUS and dist < shortest then
						shortest = dist
						closestPart = part
					end
				end
			end
		end
	end

	return closestPart
end

--====================
-- メインループ
--====================
RunService.RenderStepped:Connect(function()
	-- GUIオフなら処理しない
	if not autoAimEnabled then
		lockedPart = nil
		fov.Visible = false
		return
	end

	-- FOV表示
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	fov.Position = center
	fov.Radius = FOV_RADIUS
	fov.Visible = showFOV

	-- ShiftLockしてないならターゲット解除
	if not isShiftLock() then
		lockedPart = nil
		return
	end

	-- ShiftLock中のみターゲットを取得
	if not lockedPart or not lockedPart.Parent then
		lockedPart = getClosestPlayer()
	end

	-- ターゲットがあれば吸い付き
	if lockedPart then
		local camCF = camera.CFrame
		local targetCF = CFrame.new(camCF.Position, lockedPart.Position)
		camera.CFrame = camCF:Lerp(targetCF, AIM_STRENGTH)
	end
end)


--========================================================--
-- 🍏 Fruit 自動スライド移動（AutoAimと共存）
--========================================================--

local fruitSlideEnabled = false
local SLIDE_SPEED = 300
local HEIGHT_OFFSET = 0 -- 高さ固定（落下防止）

-- キャラRoot取得
local function getRoot()
    local char = localPlayer.Character
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

--================ Fruit検索（完全一致） =================
local function getAllFruits()
    local fruits = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Fruit" then
            table.insert(fruits, obj)
        end
    end

    return fruits
end


-- 一番近いFruit
local function getNearestFruit(root)
    local closest, dist = nil, math.huge
    for _, fruit in ipairs(getAllFruits()) do
        local d = (fruit.Position - root.Position).Magnitude
        if d < dist then
            dist = d
            closest = fruit
        end
    end
    return closest
end

-- Fruitスライド処理
RunService.RenderStepped:Connect(function(dt)
    if not fruitSlideEnabled then return end

    local root = getRoot()
    if not root then return end

    local fruit = getNearestFruit(root)
    if not fruit then return end

    -- 落下・慣性完全防止
    root.AssemblyLinearVelocity = Vector3.zero

    -- Y固定でスライド
    local targetPos = Vector3.new(
        fruit.Position.X,
        root.Position.Y + HEIGHT_OFFSET,
        fruit.Position.Z
    )

    local dir = targetPos - root.Position
    if dir.Magnitude < 2 then return end

    root.CFrame = root.CFrame + dir.Unit * SLIDE_SPEED * dt
end)




-- 新しいON/OFF変数
local fruitTPEnabled = false
local fruitCheckInterval = 0.2

-- Fruit瞬間TPループ
task.spawn(function()
    while true do
        task.wait(fruitCheckInterval)
        if not fruitTPEnabled then continue end

        local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- 一番近いFruitを取得
        local fruit
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Fruit" and v:IsA("BasePart") then
                fruit = v
                break
            end
        end
        if not fruit then continue end

        local originalCFrame = root.CFrame
        root.CFrame = fruit.CFrame
        task.wait(0.05)
        root.CFrame = originalCFrame
    end
end)


--========================================================--
--                    🧩 GUI (Tab2)                      --
--========================================================--

local autoAimTab = Window:CreateTab("戦闘(BloxFruit用)", 4483362458)

-- ON / OFF
autoAimTab:CreateToggle({
	Name = "オートエイム",
	CurrentValue = false,
	Flag = "AutoAimToggle",
	Callback = function(v)
		autoAimEnabled = v
		print("[AutoAim]", v and "ON" or "OFF")
	end
})

-- FOV表示
autoAimTab:CreateToggle({
	Name = "FOV",
	CurrentValue = true,
	Flag = "AutoAimFOV",
	Callback = function(v)
		showFOV = v
	end
})

-- FOVサイズ
autoAimTab:CreateSlider({
	Name = "FOV大きさ",
	Range = {50, 400},
	Increment = 5,
	Suffix = "px",
	CurrentValue = FOV_RADIUS,
	Flag = "AutoAimFOVRadius",
	Callback = function(v)
		FOV_RADIUS = v
	end
})

-- 吸い付き強度
autoAimTab:CreateSlider({
	Name = "吸い付き強度",
	Range = {0.1, 1},
	Increment = 0.05,
	Suffix = "",
	CurrentValue = AIM_STRENGTH,
	Flag = "AutoAimStrength",
	Callback = function(v)
		AIM_STRENGTH = v
	end
})

-- Fruitスライド ON / OFF
autoAimTab:CreateToggle({
	Name = "Fruit自動回収",
	CurrentValue = false,
	Flag = "FruitSlideToggle",
	Callback = function(v)
		fruitSlideEnabled = v
		print("[FruitSlide]", v and "ON" or "OFF")
	end
})

autoAimTab:CreateToggle({
    Name = "Fruit瞬間回収",
    CurrentValue = false,
    Flag = "FruitTPToggle",
    Callback = function(v)
        fruitTPEnabled = v
        print("[FruitTP]", v and "ON" or "OFF")
    end
})

-- DropDown用テーブル
local fruitList = {}

-- DropDown作成
local fruitDropDown = autoAimTab:CreateDropdown({
    Name = "Fruit 一覧",
    Options = fruitList,
    CurrentOption = nil,
    Callback = function(selected)
        print("選択されたFruit:", selected)
    end
})

-- 更新ボタン
autoAimTab:CreateButton({
    Name = "更新",
    Callback = function()
        -- Fruitリスト更新
        fruitList = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if string.lower(obj.Name) == "fruit" then
                table.insert(fruitList, obj:GetFullName())
            end
        end

        -- DropDown更新
        fruitDropDown:Refresh(fruitList)
        print("Fruitリスト更新完了")
    end
})


--================================
-- Enemy Head HitBox
--================================

local headHitboxEnabled = false
local headScale = 1
local originalHeadSize = {}

-- 敵Head拡大トグル
autoAimTab:CreateToggle({
    Name = "Head拡大（全員）",
    CurrentValue = false,
    Callback = function(v)
        headHitboxEnabled = v

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")

                if head and head:IsA("BasePart") then
                    if v then
                        if not originalHeadSize[head] then
                            originalHeadSize[head] = head.Size
                        end

                        head.Size = originalHeadSize[head] * headScale
                        head.Transparency = 0.5
                        head.CanCollide = false
                        head.Massless = true
                    else
                        if originalHeadSize[head] then
                            head.Size = originalHeadSize[head]
                        end
                        head.Transparency = 0
                    end
                end
            end
        end
    end
})



-- 敵Head倍率スライダー
autoAimTab:CreateSlider({
    Name = "Head倍率",
    Range = {1, 2000},
    Increment = 0.1,
    Suffix = "倍",
    CurrentValue = 1,
    Callback = function(v)
        headScale = v

        if headHitboxEnabled then
            for head, size in pairs(originalHeadSize) do
                if head and head.Parent then
                    head.Size = size * headScale
                    head.Transparency = 0.5
                end
            end
        end
    end
})




--============================
-- 設定値
--============================
local FollowDistance = 4   -- プレイヤー前方の距離
local AttractionRadius = 1 -- 半径20スタッド以内だけ吸引（初期値）

--============================
-- RayField UI
--============================
local EnemyTab = Window:CreateTab("敵処理", 4483362458)

-- 距離スライダー
local DistanceSlider = EnemyTab:CreateSlider({
    Name = "敵の前方距離",
    Range = {1, 80},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = FollowDistance,
    Flag = "DistanceSliderFlag",
    Callback = function(val)
        FollowDistance = val
    end,
})

-- 半径スライダー
local RadiusSlider = EnemyTab:CreateSlider({
    Name = "吸引半径",
    Range = {1, 2000},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = AttractionRadius,
    Flag = "RadiusSliderFlag",
    Callback = function(val)
        AttractionRadius = val
    end,
})

--============================
-- 敵吸引処理
--============================
local run = game:GetService("RunService")
local enemyFolder = workspace:FindFirstChild("Enemies") -- 存在しない場合は nil

run.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemyFolder = workspace:FindFirstChild("Enemies") -- 毎フレーム確認

    if enemyFolder then
        for _, enemy in pairs(enemyFolder:GetChildren()) do
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            if eHRP then
                local distance = (eHRP.Position - hrp.Position).Magnitude
                if distance <= AttractionRadius then
                    eHRP.CFrame = hrp.CFrame * CFrame.new(0,0,-FollowDistance)
                end
            end
        end
    end
end)



--=============================
-- ハンティ・ゾンビタブ（敵ESP統合）
--=============================

local huntTab = Window:CreateTab("ハンティ・ゾンビ", 4483362458)

--=============================
-- Pickupスライド
--=============================
local slideSpeed = 20
local slideActive = false
local pickupCooldown = 0.5
local lastPickupSearch = 0

local function getPickups()
    local targets = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "PickupHitbox" and obj.Parent then
            table.insert(targets, obj)
        end
    end
    return targets
end

huntTab:CreateSlider({
    Name = "移動速度",
    Range = {5,50},
    Increment = 1,
    CurrentValue = slideSpeed,
    Suffix = " stud/s",
    Callback = function(v)
        slideSpeed = v
    end
})

huntTab:CreateToggle({
    Name = "スライド取得",
    CurrentValue = false,
    Callback = function(v)
        slideActive = v
    end
})

--=============================
-- Pipe追尾
--=============================
local followActive = false
local originalCFrame
local pipeCache = {}
local searchCooldown = 0.5
local lastSearch = 0

local function updatePipeCache()
    table.clear(pipeCache)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Pipe" or obj.Name == "SewerPipeModel") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                obj.PrimaryPart = part
                table.insert(pipeCache, obj)
            end
        end
    end
end

huntTab:CreateToggle({
    Name = "Pipe追尾",
    CurrentValue = false,
    Callback = function(v)
        followActive = v
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if v then
                    originalCFrame = hrp.CFrame
                elseif originalCFrame then
                    hrp.CFrame = originalCFrame
                end
            end
        end
    end
})

--=============================
-- Endless Island TP
--=============================
huntTab:CreateButton({
    Name = "🌴 Endless Island 放置場所TP",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(12.4, -14.2, -31.8)
    end
})

--=============================
-- バス追従
--=============================
local moveActive = false
local targetName = "Cylinder.015"
local updateInterval = 0.02
local lastUpdate = 0

huntTab:CreateToggle({
    Name = "バスに追従",
    CurrentValue = false,
    Callback = function(v)
        moveActive = v
    end
})

--=============================
-- 敵ESP
--=============================
local enemyESPEnabled = false

huntTab:CreateToggle({
    Name = "🧟 敵ESP",
    CurrentValue = false,
    Callback = function(v)
        enemyESPEnabled = v
        if not v then
            local entities = Workspace:FindFirstChild("Entities")
            if entities then
                for _, g in pairs(entities:GetDescendants()) do
                    if g:IsA("BillboardGui") and g.Name == "EnemyESP" then
                        g:Destroy()
                    end
                end
            end
        end
    end
})

local function createEnemyESP(hrp)
    if hrp:FindFirstChild("EnemyESP") then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "EnemyESP"
    gui.Adornee = hrp
    gui.Size = UDim2.new(0,90,0,24)
    gui.StudsOffset = Vector3.new(0,2.5,0)
    gui.AlwaysOnTop = true

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.TextColor3 = Color3.fromRGB(255,60,60)
    txt.TextStrokeTransparency = 0
    txt.Text = hrp.Parent.Name
    txt.Parent = gui

    gui.Parent = hrp
end

--=============================
-- RenderStepped
--=============================
RunService.RenderStepped:Connect(function(dt)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Pickupスライド
    if slideActive then
        lastPickupSearch += dt
        if lastPickupSearch >= pickupCooldown then
            lastPickupSearch = 0
            local pickups = getPickups()
            local target = pickups[1]
            if target then
                hrp.CFrame = CFrame.new(target.Position + Vector3.new(0,3,0))
                if (hrp.Position - target.Position).Magnitude < 3 then
                    pcall(function()
                        firetouchinterest(hrp, target, 0)
                        firetouchinterest(hrp, target, 1)
                        if target.Parent then target:Destroy() end
                    end)
                end
            end
        end
    end

    -- Pipe追尾
    if followActive then
        lastSearch += dt
        if lastSearch >= searchCooldown then
            updatePipeCache()
            lastSearch = 0
        end

        if #pipeCache > 0 then
            table.sort(pipeCache, function(a,b)
                return (hrp.Position - a.PrimaryPart.Position).Magnitude <
                       (hrp.Position - b.PrimaryPart.Position).Magnitude
            end)

            local target = pipeCache[1]
            if target and target.PrimaryPart then
                hrp.CFrame = hrp.CFrame:Lerp(
                    CFrame.new(target.PrimaryPart.Position + Vector3.new(0,3,0)),
                    math.clamp(slideSpeed * dt, 0, 1)
                )
            end
        end
    end

    -- バス追従
    if moveActive then
        lastUpdate += dt
        if lastUpdate >= updateInterval then
            lastUpdate = 0
            local part = Workspace:FindFirstChild(targetName, true)
            if part then
                hrp.CFrame = hrp.CFrame:Lerp(
                    CFrame.new(part.Position + Vector3.new(0,5,0)),
                    math.clamp(slideSpeed * dt, 0, 1)
                )
            end
        end
    end

    -- 敵ESP
    if enemyESPEnabled then
        local entities = Workspace:FindFirstChild("Entities")
        if entities then
            for _, zombie in pairs(entities:GetChildren()) do
                if zombie.Name == "Zombie" then
                    for _, enemy in pairs(zombie:GetChildren()) do
                        local ehrp = enemy:FindFirstChild("HumanoidRootPart")
                        if ehrp then
                            createEnemyESP(ehrp)
                        end
                    end
                end
            end
        end
    end
end)



--================================
-- Services
--================================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId


local autoRejoinEnabled = false
local rejoinHotkeyEnabled = false
local rejoinKey = Enum.KeyCode.F6

local lastPrivateServerCode = nil
local privateServerLink = ""

local Network = Stats:WaitForChild("Network")


local serverTab = Window:CreateTab("Server", 4483362458)

local pingLabel = serverTab:CreateLabel("Ping: -- ms")

RunService.RenderStepped:Connect(function()
    local pingItem = Network.ServerStatsItem:FindFirstChild("Data Ping")
    if pingItem then
        local ping = math.floor(pingItem:GetValue())
        pingLabel:Set("Ping: " .. ping .. " ms")
    end
end)


serverTab:CreateButton({
    Name = "サーバー入りなおし",
    Callback = function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
})


serverTab:CreateToggle({
    Name = "入りなおしキー (F6)",
    CurrentValue = false,
    Callback = function(v)
        rejoinHotkeyEnabled = v
    end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if rejoinHotkeyEnabled and input.KeyCode == rejoinKey then
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end)


serverTab:CreateInput({
    Name = "プライベートサーバーリンク",
    PlaceholderText = "...privateServerLinkCode=XXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        privateServerLink = text
    end
})

serverTab:CreateButton({
    Name = "プライベートサーバーに参加(リンク必須)",
    Callback = function()
        local code = privateServerLink:match("privateServerLinkCode=([%w%-]+)")
        if not code then return end

        lastPrivateServerCode = code

        TeleportService:TeleportToPrivateServer(
            PlaceId,
            code,
            { LocalPlayer }
        )
    end
})


serverTab:CreateButton({
    Name = "サーバーに参加(ランダム)",
    Callback = function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
})



serverTab:CreateButton({
    Name = "人数が少ないサーバーに参加",
    Callback = function()
        local servers = {}
        local cursor = ""

        repeat
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
                PlaceId,
                cursor ~= "" and "&cursor=" .. cursor or ""
            )

            local res = HttpService:JSONDecode(game:HttpGet(url))
            for _, s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= JobId then
                    table.insert(servers, s.id)
                end
            end

            cursor = res.nextPageCursor or ""
        until #servers > 0 or cursor == ""

        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                servers[math.random(#servers)],
                LocalPlayer
            )
        end
    end
})


serverTab:CreateButton({
    Name = "フレンドのいるサーバーに参加",
    Callback = function()
        local pages = Players:GetFriendsAsync(LocalPlayer.UserId)
        for _, friend in ipairs(pages:GetCurrentPage()) do
            if friend.IsOnline and friend.PlaceId == PlaceId then
                TeleportService:TeleportToPlaceInstance(
                    PlaceId,
                    friend.GameId,
                    LocalPlayer
                )
                break
            end
        end
    end
})


serverTab:CreateToggle({
    Name = "キック時に自動参加",
    CurrentValue = false,
    Callback = function(v)
        autoRejoinEnabled = v
    end
})

GuiService.ErrorMessageChanged:Connect(function(msg)
    if not autoRejoinEnabled then return end

    task.wait(2)

    if lastPrivateServerCode then
        TeleportService:TeleportToPrivateServer(
            PlaceId,
            lastPrivateServerCode,
            { LocalPlayer }
        )
    else
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end)
