-- サービス取得
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- GUIロード
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "WOS Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Config"
})

-- タブ作成
local MainTab = Window:MakeTab({Name="メイン", Icon="rbxassetid://4483345998", PremiumOnly=false})
local ChestTab = Window:MakeTab({Name="チェスト", Icon="rbxassetid://4483345998", PremiumOnly=false})
local AimTab = Window:MakeTab({Name="AimAssist", Icon="rbxassetid://4483345998", PremiumOnly=false})

-- ==============================
-- MainTab 機能
-- ==============================

-- スピード
local speedEnabled = false
local speedValue = 30
local speedConnection

MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        if speedConnection then speedConnection:Disconnect() end
        if value then
            speedConnection = RS.RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 30
            end
        end
    end
})

MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1, Max = 1000,
    Default = 30,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        speedValue = value
    end
})

-- 無限ジャンプ
local infiniteJumpEnabled = false
MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

UIS.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
local noclipEnabled = false
MainTab:AddToggle({
    Name = "壁貫通（Noclip）",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
    end
})

RS.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 空中TPボタン
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "TeleportGui"
local airTpButton = Instance.new("TextButton")
airTpButton.Size = UDim2.new(0, 100, 0, 50)
airTpButton.Position = UDim2.new(0.5, -50, 1, -100)
airTpButton.Text = "空中TP"
airTpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
airTpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
airTpButton.Parent = screenGui

local floating = false
local originalPosition

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = true,
    Callback = function(value)
        airTpButton.Visible = value
    end
})

airTpButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not floating then
            originalPosition = hrp.Position
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 500, 0)
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FloatForce"
            bodyVel.Velocity = Vector3.new(0,0,0)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Parent = hrp
            if humanoid then humanoid.PlatformStand = true end
            local ground = Instance.new("Part")
            ground.Size = Vector3.new(10,1,10)
            ground.Position = hrp.Position - Vector3.new(0,5,0)
            ground.Anchored = true
            ground.CanCollide = true
            ground.Name = "SkyPlatform"
            ground.Parent = workspace
            floating = true
        else
            hrp.CFrame = CFrame.new(originalPosition)
            local floatForce = hrp:FindFirstChild("FloatForce")
            if floatForce then floatForce:Destroy() end
            local platform = workspace:FindFirstChild("SkyPlatform")
            if platform then platform:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
            floating = false
        end
    end
end)

-- ==============================
-- ChestTab 機能
-- ==============================

local currentChestNumber = 1

local function findChestByNumber(number)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == tostring(number) then
            return obj
        end
    end
    return nil
end

local function teleportToChest(chest)
    if chest and chest.PrimaryPart then
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(chest.PrimaryPart.Position + Vector3.new(0,7,0)))
        print("テレポートしました: "..chest.Name)
    else
        print("指定されたチェストが見つかりませんでした。")
    end
end

local buttonVisible = false
local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0,200,0,50)
floatingButton.Position = UDim2.new(0.5,-100,0.5,-25)
floatingButton.Text = "次のチェストにテレポート"
floatingButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
floatingButton.TextColor3 = Color3.fromRGB(255,255,255)
floatingButton.Parent = screenGui
floatingButton.Visible = buttonVisible

floatingButton.MouseButton1Click:Connect(function()
    currentChestNumber = currentChestNumber + 1
    if currentChestNumber > 30 then currentChestNumber = 1 end
    local chest = findChestByNumber(currentChestNumber)
    teleportToChest(chest)
end)

ChestTab:AddToggle({
    Name = "チェストボタン表示",
    Default = false,
    Callback = function(value)
        buttonVisible = value
        floatingButton.Visible = value
    end
})

ChestTab:AddButton({
    Name = "次のチェストにテレポート",
    Callback = function()
        currentChestNumber = currentChestNumber + 1
        if currentChestNumber > 30 then currentChestNumber = 1 end
        local chest = findChestByNumber(currentChestNumber)
        teleportToChest(chest)
    end
})
-- ==============================
-- 敵集め機能
-- ==============================
local gatherDistance = 50
local gatheredEnemies = {}
local gathering = false

local function startGatheringEnemies()
    gathering = true
    table.clear(gatheredEnemies)
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and model ~= LocalPlayer.Character then
            if not model:FindFirstChild("Dialogue") and not model:FindFirstChild("QuestBubble") then
                local dist = (model.HumanoidRootPart.Position - myHRP.Position).Magnitude
                if dist <= gatherDistance then
                    table.insert(gatheredEnemies, model)
                end
            end
        end
    end
end

RS.Heartbeat:Connect(function()
    if gathering then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, enemy in pairs(gatheredEnemies) do
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                enemy.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(0,0,-5)
            end
        end
    end
end)

MainTab:AddToggle({
    Name="敵を集める",
    Default=false,
    Callback=function(val)
        if val then
            startGatheringEnemies()
        else
            gathering = false
            gatheredEnemies = {}
        end
    end
})

MainTab:AddSlider({
    Name="敵集め距離",
    Min=1, Max=200, Default=50, Increment=1,
    Callback=function(value)
        gatherDistance = value
    end
})

MainTab:AddTextbox({
    Name="敵集め 距離（手入力）",
    Default="50",
    TextDisappear=false,
    Callback=function(text)
        local num = tonumber(text)
        if num and num >= 0 then
            gatherDistance = num
        end
    end
})

local CollectEnemies = false
MainTab:AddToggle({
    Name="連続で敵を集める",
    Default=false,
    Callback=function(Value)
        CollectEnemies = Value
        if CollectEnemies then
            task.spawn(function()
                while CollectEnemies do
                    startGatheringEnemies()
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ==============================
-- プレイヤー追尾機能
-- ==============================
local selectedPlayer = nil
local dropdown
local following = false
local connection = nil
local savedCFrame = nil

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local function refreshDropdownOptions()
    if dropdown and dropdown.Refresh then
        dropdown:Refresh(getPlayerNames(), true)
    end
end

local function createDropdown()
    dropdown = MainTab:AddDropdown({
        Name="プレイヤーを選択",
        Default="",
        Options=getPlayerNames(),
        Callback=function(value)
            selectedPlayer = value
        end
    })
end
createDropdown()

task.spawn(function()
    while true do
        task.wait(5)
        refreshDropdownOptions()
    end
end)

MainTab:AddButton({
    Name="選択したプレイヤーの近くにテレポート",
    Callback=function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,2)
        end
    end
})

MainTab:AddButton({
    Name="プレイヤーリストを手動更新",
    Callback=function()
        refreshDropdownOptions()
        OrionLib:MakeNotification({Name="更新完了", Content="プレイヤー一覧を更新しました！", Time=3})
    end
})

MainTab:AddToggle({
    Name="密着追尾(オン/オフ)",
    Default=false,
    Callback=function(state)
        following = state
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if following then
            if myHRP then savedCFrame = myHRP.CFrame end
            connection = RS.Heartbeat:Connect(function()
                local target = Players:FindFirstChild(selectedPlayer)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local offset = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,7)
                    if myHRP then
                        myHRP.CFrame = CFrame.new(offset.Position, target.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            if connection then connection:Disconnect() connection = nil end
            if savedCFrame and myHRP then myHRP.CFrame = savedCFrame end
        end
    end
})

-- ==============================
-- プレイヤーハイライト
-- ==============================
local playerHighlights = {}
local highlightEnabled = true

local function applyHighlight(player)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local isTimeErasing = character:FindFirstChild("TimeErase") and character.TimeErase.Value
    if highlightEnabled and not isTimeErasing then
        local existingHighlight = playerHighlights[player]
        if not existingHighlight or existingHighlight.Adornee ~= character then
            if existingHighlight then existingHighlight:Destroy() end
            local highlight = Instance.new("Highlight")
            highlight.Name = "PlayerHighlight"
            highlight.FillColor = Color3.fromRGB(255,255,0)
            highlight.OutlineColor = Color3.fromRGB(0,0,0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = character
            highlight.Parent = character
            playerHighlights[player] = highlight
        end
    elseif playerHighlights[player] then
        playerHighlights[player]:Destroy()
        playerHighlights[player] = nil
    end
end

local function updatePlayerHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            applyHighlight(player)
        end
    end
end

MainTab:AddToggle({
    Name="プレイヤーハイライト",
    Default=true,
    Callback=function(value)
        highlightEnabled = value
        updatePlayerHighlights()
    end
})

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(1)
            applyHighlight(player)
        end)
        applyHighlight(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(1)
            applyHighlight(player)
        end)
    end
end)

RS.Heartbeat:Connect(updatePlayerHighlights)
-- ==============================
-- Xeno 完全統合 AimAssist
-- ==============================
local AimAssist = {}
AimAssist.Enabled = false
AimAssist.UseToggleMode = true
AimAssist.ToggleKey = Enum.KeyCode.V
AimAssist.HoldKey = Enum.KeyCode.RightShift
AimAssist.Smoothness = 0.18
AimAssist.MaxDistance = 250
AimAssist.TeamCheck = true
AimAssist.ThroughWalls = false
AimAssist.TargetMode = "Head"

local function IsEnemy(char)
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if AimAssist.TeamCheck then
        local plr = Players:GetPlayerFromCharacter(char)
        if plr and plr.Team == player.Team then return false end
    end
    return true
end

local function GetTargetPart(char)
    if AimAssist.TargetMode == "Head" then
        return char:FindFirstChild("Head")
    elseif AimAssist.TargetMode == "Body" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        local parts = {char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")}
        return parts[math.random(1,#parts)]
    end
end

local function isVisible(part)
    if AimAssist.ThroughWalls then return true end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function GetClosestToCrosshair()
    local closest = nil
    local closestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and IsEnemy(p.Character) then
            local part = GetTargetPart(p.Character)
            if part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                    local pos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (pos - center).Magnitude
                    if dist < closestDist and (part.Position - camera.CFrame.Position).Magnitude <= AimAssist.MaxDistance then
                        if isVisible(part) then
                            closestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

RS.RenderStepped:Connect(function()
    if AimAssist.Enabled then
        local target = GetClosestToCrosshair()
        if target then
            local aimCF = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(aimCF, AimAssist.Smoothness)
        end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if AimAssist.UseToggleMode and input.KeyCode == AimAssist.ToggleKey then
        AimAssist.Enabled = not AimAssist.Enabled
    end
    if not AimAssist.UseToggleMode and input.KeyCode == AimAssist.HoldKey then
        AimAssist.Enabled = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if not AimAssist.UseToggleMode and input.KeyCode == AimAssist.HoldKey then
        AimAssist.Enabled = false
    end
end)

-- AimAssist GUI 設定
local AimTab = Window:MakeTab({Name="AimAssist", Icon="rbxassetid://4483345998", PremiumOnly=false})

AimTab:AddToggle({Name="AimAssist ON/OFF", Default=false, Callback=function(v) AimAssist.Enabled = v end})
AimTab:AddToggle({Name="Toggle Mode (トグル/ホールド切替)", Default=true, Callback=function(v) AimAssist.UseToggleMode = v end})

AimTab:AddTextbox({Name="Toggle Key (トグル用)", PlaceholderText="V", Text="V", Callback=function(txt)
    local suc, key = pcall(function() return Enum.KeyCode[txt] end)
    if suc then AimAssist.ToggleKey = key end
end})

AimTab:AddTextbox({Name="Hold Key (ホールド用)", PlaceholderText="RightShift", Text="RightShift", Callback=function(txt)
    local suc, key = pcall(function() return Enum.KeyCode[txt] end)
    if suc then AimAssist.HoldKey = key end
end})

AimTab:AddSlider({Name="Smoothness", Min=0.05, Max=0.5, Default=0.18, Increment=0.01, Callback=function(val) AimAssist.Smoothness = val end})
AimTab:AddSlider({Name="Max Distance", Min=50, Max=1000, Default=250, Increment=10, Callback=function(val) AimAssist.MaxDistance = val end})
AimTab:AddToggle({Name="Through Walls (壁越し吸い付き)", Default=false, Callback=function(v) AimAssist.ThroughWalls = v end})
AimTab:AddDropdown({Name="Target Mode", Default="Head", Options={"Head","Body","Random"}, Callback=function(opt) AimAssist.TargetMode = opt end})

-- スマホ用ボタン
AimTab:AddButton({
    Name="AimAssist ON/OFF (スマホ用)",
    Callback=function()
        AimAssist.Enabled = not AimAssist.Enabled
        if AimAssist.Enabled then
            print("スマホ用AimAssist: ON")
        else
            print("スマホ用AimAssist: OFF")
        end
    end
})

-- ==============================
-- キャラクターリセット
-- ==============================
MainTab:AddButton({
    Name="キャラクターリセット",
    Callback=function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.Health = 0 end
    end
})

-- ==============================
-- 透明化ボタン
-- ==============================
MainTab:AddButton({
    Name="透明化(PC非推奨)",
    Callback=function()
        loadstring(game:HttpGet("https://pastebin.com/raw/3Rnd9rHf"))()
        loadstring(game:HttpGet("https://pastebin.com/raw/XXXXXXX"))()
        OrionLib:MakeNotification({Name="透明化実行", Content="透明化を実行しました！", Time=3})
    end
})

-- ==============================
-- UI再表示ボタン
-- ==============================
local reopenButtonGui = Instance.new("ScreenGui")
reopenButtonGui.Name = "ReopenGui"
reopenButtonGui.ResetOnSpawn = false
reopenButtonGui.Parent = game:GetService("CoreGui")

local reopenButton = Instance.new("TextButton")
reopenButton.Size = UDim2.new(0,100,0,40)
reopenButton.Position = UDim2.new(0,10,0,10)
reopenButton.Text = "UI再表示"
reopenButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
reopenButton.TextColor3 = Color3.fromRGB(255,255,255)
reopenButton.Parent = reopenButtonGui

reopenButton.MouseButton1Click:Connect(function()
    OrionLib:Toggle(true)
end)

OrionLib:MakeNotification({Name="WOSユーティリティ", Content="スクリプトの読み込みが完了しました！ - by Masashi", Time=5})
