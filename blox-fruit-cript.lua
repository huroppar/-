local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Window = OrionLib:MakeWindow({Name = "BloxFarm", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- グローバル変数
getgenv().autoFarm = false
getgenv().useSkill = false
getgenv().weaponType = "Melee"

-- レベル帯ごとの敵・クエスト・NPC座標（必要に応じて拡張）
local FarmData = {
    {
        Min = 0,
        Max = 9,
        Enemy = "Bandit",
        Quest = "BanditQuest1",
        NPCPos = Vector3.new(1060, 17, 1547)
    },
    -- ここに他のレベル帯追加可能
}

-- 武器タイプごとの数字キー対応
local weaponKeyMap = {
    Melee = "1",
    Fruit = "2",
    Sword = "3",
    Gun = "4"
}

-- 敵取得関数（生きてる一番近い敵を取得）
local function getEnemy(name)
    local closest = nil
    local shortest = math.huge
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == name and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
            local dist = (enemy.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = enemy
            end
        end
    end
    return closest
end

-- レベルに応じて対象データ取得
local function getTargetData()
    local lv = player.Data.Level.Value
    for _, data in pairs(FarmData) do
        if lv >= data.Min and lv <= data.Max then
            return data
        end
    end
end

-- 武器切り替え（数字キー押し）
local function equipWeapon(weaponType)
    local key = weaponKeyMap[weaponType]
    if key then
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        task.wait(0.1)
    end
end

-- マウス左クリックシミュレート
local function click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- 空中にピタッと止まる関数
local function floatAboveEnemy(enemy)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end

    humanoid.PlatformStand = true

    local bodyVelocity = hrp:FindFirstChild("BodyVelocity")
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVelocity.Parent = hrp
    end

    while getgenv().autoFarm and enemy.Humanoid.Health > 0 do
        local targetPos = enemy.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        hrp.CFrame = CFrame.lookAt(targetPos, enemy.HumanoidRootPart.Position)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        task.wait(0.1)
    end

    humanoid.PlatformStand = false
    if bodyVelocity then bodyVelocity:Destroy() end
end

-- 攻撃関数
local function attack()
    equipWeapon(getgenv().weaponType)
    click()
    if getgenv().useSkill then
        task.wait(0.15)
        VirtualInputManager:SendKeyEvent(true, "Z", false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, "Z", false, game)
    end
end

-- メインオートファームループ
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().autoFarm then
            local data = getTargetData()
            if not data then continue end

            local enemy = getEnemy(data.Enemy)
            if enemy then
                task.spawn(function() floatAboveEnemy(enemy) end)
                attack()
            end
        end
    end
end)

-- GUI作成
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
    Options = {"Melee", "Fruit", "Sword", "Gun"},
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

