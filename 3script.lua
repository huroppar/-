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

--================================
-- スピード
--================================
playerTab:CreateToggle({
    Name = "スピード",
    CurrentValue = false,
    Callback = function(v)
        speedEnabled = v
        local _, hum = getCharacter()
        if hum then
            if v then
                originalWalkSpeed = hum.WalkSpeed
            else
                hum.WalkSpeed = originalWalkSpeed or 16
            end
        end
    end
})

playerTab:CreateSlider({
    Name = "スピード調節",
    Range = {0, 500},
    Increment = 1,
    CurrentValue = speedValue,
    Callback = function(v)
        speedValue = v
    end
})

--================================
-- ジャンプ
--================================
playerTab:CreateToggle({
    Name = "跳躍力",
    CurrentValue = false,
    Callback = function(v)
        jumpEnabled = v
        local _, hum = getCharacter()
        if hum then
            if v then
                originalJumpPower = hum.JumpPower
                hum.JumpPower = jumpPowerValue
            else
                hum.JumpPower = originalJumpPower or 50
            end
        end
    end
})

playerTab:CreateSlider({
    Name = "跳躍力調節",
    Range = {0, 700},
    Increment = 5,
    CurrentValue = jumpPowerValue,
    Callback = function(v)
        jumpPowerValue = v
        local _, hum = getCharacter()
        if hum and jumpEnabled then
            hum.JumpPower = v
        end
    end
})

--================================
-- 無限ジャンプ
--================================
playerTab:CreateToggle({
    Name = "無限ジャンプ",
    CurrentValue = false,
    Callback = function(v)
        infiniteJumpEnabled = v
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local _, hum = getCharacter()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--================================
-- 壁貫通（Noclip）
--================================
local function enableNoclip()
    if noclipConn then return end
    local char = LocalPlayer.Character
    if not char then return end

    -- オンにする前のCanCollideを保存
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            originalCanCollide[p] = p.CanCollide
        end
    end

    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
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
    local char = LocalPlayer.Character
    if not char then return end

    -- オンにする前の状態に戻す
    for p,canCollide in pairs(originalCanCollide) do
        if p and p.Parent then
            p.CanCollide = canCollide
        end
    end
    originalCanCollide = {}
end

playerTab:CreateToggle({
    Name = "壁貫通",
    CurrentValue = false,
    Callback = function(v)
        noclipEnabled = v
        if v then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})


--================================
-- 空中TP
--================================
playerTab:CreateButton({
    Name = "空中TP",
    Callback = function()
        local _, hum, hrp = getCharacter()
        if not hum or not hrp then return end

        if not airTPActive then
            airOriginCF = hrp.CFrame
            hrp.CFrame = hrp.CFrame + Vector3.new(0, airHeight, 0)

            airForce = Instance.new("BodyVelocity")
            airForce.MaxForce = Vector3.new(0, math.huge, 0)
            airForce.Velocity = Vector3.zero
            airForce.Parent = hrp

            airTPActive = true
        else
            if airForce then airForce:Destroy() end
            if airOriginCF then hrp.CFrame = airOriginCF end
            airTPActive = false
        end
    end
})


--================================
-- 足場管理
--================================
local platforms = platforms or {}

-- 足場生成
playerTab:CreateButton({
    Name = "足場生成",
    Callback = function()
        local char, hum, root = getCharacter()
        if not root then return end

        local platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 1, 6)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Color = Color3.fromRGB(255, 200, 0)
        platform.Material = Enum.Material.Neon

        platform.CFrame = root.CFrame * CFrame.new(0, -3, 0)
        platform.Parent = workspace

        table.insert(platforms, platform)
    end
})

-- 足場削除
playerTab:CreateButton({
    Name = "足場削除",
    Callback = function()
        for _, p in ipairs(platforms) do
            if p and p.Parent then
                p:Destroy()
            end
        end
        table.clear(platforms)
    end
})


--================================
-- 位置固定
--================================
playerTab:CreateToggle({
    Name = "位置固定",
    CurrentValue = false,
    Callback = function(v)
        freezeEnabled = v
        local _, _, hrp = getCharacter()
        if not hrp then return end

        if v then
            freezeCFrame = hrp.CFrame
            freezeConn = RunService.RenderStepped:Connect(function()
                hrp.CFrame = freezeCFrame
            end)
        else
            if freezeConn then
                freezeConn:Disconnect()
                freezeConn = nil
            end
        end
    end
})

--=============================
-- Fly機能（向き自由・重力のみ無効）
--=============================
local flyActive = false
local flySpeed = 50

local flyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

-- Fly ON / OFF
playerTab:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(state)
		flyActive = state
		local _, hum, root = getCharacter()
		if not hum or not root then return end

		if flyActive then
			-- 🔵 重力だけ無効化（向きはそのまま）
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		else
			-- 🔵 通常に戻す
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end
})

-- Fly速度
playerTab:CreateSlider({
	Name = "Fly速度",
	Range = {10, 2000},
	Increment = 5,
	CurrentValue = flySpeed,
	Flag = "FlySpeedSlider",
	Callback = function(val)
		flySpeed = val
	end
})

-- キー入力
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if flyKeys[input.KeyCode.Name] ~= nil then
			flyKeys[input.KeyCode.Name] = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if flyKeys[input.KeyCode.Name] ~= nil then
			flyKeys[input.KeyCode.Name] = false
		end
	end
end)

-- Fly制御
RunService.RenderStepped:Connect(function(dt)
	if not flyActive then return end

	local _, hum, root = getCharacter()
	if not hum or not root then return end

	-- 🔒 落下防止（重力キャンセル）
	root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

	local cam = workspace.CurrentCamera
	local move = Vector3.zero

	-- 前後左右（＝向きは普通に変わる）
	if flyKeys.W then move += cam.CFrame.LookVector end
	if flyKeys.S then move -= cam.CFrame.LookVector end
	if flyKeys.A then move -= cam.CFrame.RightVector end
	if flyKeys.D then move += cam.CFrame.RightVector end

	-- 上下
	if flyKeys.Space then move += Vector3.new(0, 1, 0) end
	if flyKeys.LeftShift then move -= Vector3.new(0, 1, 0) end

	if move.Magnitude > 0 then
		root.CFrame = root.CFrame + (move.Unit * flySpeed * dt)
	end
end)

--================================
-- スピード反映
--================================
RunService.RenderStepped:Connect(function()
    if speedEnabled then
        local _, hum = getCharacter()
        if hum then hum.WalkSpeed = speedValue end
    end
end)


--========================
-- 位置保存 / TP（1スロット）
--========================
local savedCFrame = nil

-- 現在地を保存
playerTab:CreateButton({
    Name = "現在地を保存",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        savedCFrame = hrp.CFrame
        warn("位置を保存した")
    end
})

-- 保存地点にTP
playerTab:CreateButton({
    Name = "保存地点にTP",
    Callback = function()
        if not savedCFrame then
            warn("まだ位置が保存されてない")
            return
        end

        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        hrp.Anchored = false
        hrp.CFrame = savedCFrame
    end
})
