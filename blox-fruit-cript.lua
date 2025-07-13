-- OrionLibロード
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "BloxFarm Pro", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

-- グローバル設定
getgenv().autoFarm = false
getgenv().useSkill = false
getgenv().weaponType = "Melee"

-- 敵とクエストのデータテーブル（ここは今後拡張）
local FarmData = {
    {
        Min = 0,
        Max = 9,
        Enemy = "Bandit",
        Quest = "BanditQuest1",
        NPCPos = Vector3.new(1060, 17, 1547)
    }
}

-- ツール取得関数
local function getTool()
    local char = game.Players.LocalPlayer.Character
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

-- 敵取得関数
local function getEnemy(name)
    local closest = nil
    local shortest = math.huge
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == name and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
            local dist = (enemy.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = enemy
            end
        end
    end
    return closest
end

-- 移動関数（Tweenでスライド）
local function slideTo(pos)
    local ts = game:GetService("TweenService")
    local char = game.Players.LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local tween = ts:Create(hrp, TweenInfo.new(0.5), {CFrame = pos})
    tween:Play()
    tween.Completed:Wait()
end

-- 攻撃関数（通常＋スキルありならZ発動）
local function attack()
    local vim = game:GetService("VirtualInputManager")
    local tool = getTool()
    if tool then
        tool:Activate()
    end

    if getgenv().useSkill then
        task.wait(0.1)
        vim:SendKeyEvent(true, "Z", false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, "Z", false, game)
    end
end

-- レベルに応じた敵データ取得
local function getTargetData()
    local lv = game.Players.LocalPlayer.Data.Level.Value
    for _, data in pairs(FarmData) do
        if lv >= data.Min and lv <= data.Max then
            return data
        end
    end
end

-- メインループ
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().autoFarm then
            local data = getTargetData()
            if not data then continue end

            local enemy = getEnemy(data.Enemy)
            if enemy then
                local above = enemy.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                local look = CFrame.lookAt(above, enemy.HumanoidRootPart.Position)
                slideTo(look)
                attack()
            end
        end
    end
end)

-- GUI構築
local tab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

tab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(v)
        getgenv().autoFarm = v
    end
})

tab:AddDropdown({
    Name = "武器タイプ",
    Default = "Melee",
    Options = {"Melee", "Sword", "Gun", "Fruit"},
    Callback = function(v)
        getgenv().weaponType = v
    end
})

tab:AddToggle({
    Name = "Zスキルを使う",
    Default = false,
    Callback = function(v)
        getgenv().useSkill = v
    end
})

OrionLib:Init()
