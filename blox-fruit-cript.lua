local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "BloxFarm Pro", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

getgenv().autoFarm = false
getgenv().useSkill = false
getgenv().weaponType = "Melee"

local FarmData = {
    {
        Min = 0,
        Max = 9,
        Enemy = "Bandit",
        Quest = "BanditQuest1",
        NPCPos = Vector3.new(1060, 17, 1547)
    }
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getTool()
    local char = player.Character
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

local function equipTool(tool)
    local char = player.Character
    if not tool then return end
    if not char or not char:FindFirstChild(tool.Name) then
        tool.Parent = char
        task.wait(0.2)
    end
end

local function getEnemy(name)
    local closest = nil
    local shortest = math.huge
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == name and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
            local dist = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = enemy
            end
        end
    end
    return closest
end

local function getTargetData()
    local lv = player.Data.Level.Value
    for _, data in pairs(FarmData) do
        if lv >= data.Min and lv <= data.Max then
            return data
        end
    end
end

local function attack()
    local vim = game:GetService("VirtualInputManager")
    local tool = getTool()
    if tool then
        equipTool(tool)
        tool:Activate()
    end

    if getgenv().useSkill then
        task.wait(0.15)
        vim:SendKeyEvent(true, "Z", false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, "Z", false, game)
    end
end

local function floatAboveEnemy(enemy)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not hrp or not humanoid or not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end

    -- 空中固定用設定
    humanoid.PlatformStand = true
    local bodyVelocity = hrp:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Parent = hrp

    while getgenv().autoFarm and enemy.Humanoid.Health > 0 do
        local targetPos = enemy.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        hrp.CFrame = CFrame.lookAt(targetPos, enemy.HumanoidRootPart.Position)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        task.wait(0.1)
    end

    -- 終了時は元に戻す
    humanoid.PlatformStand = false
    if bodyVelocity then bodyVelocity:Destroy() end
end

task.spawn(function()
    while task.wait(0.3) do
        if getgenv().autoFarm then
            local data = getTargetData()
            if not data then continue end

            local enemy = getEnemy(data.Enemy)
            if enemy then
                -- 上空に固定して攻撃ループ
                task.spawn(function() floatAboveEnemy(enemy) end)
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
