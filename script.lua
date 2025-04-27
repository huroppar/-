-- OrionLib読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()


-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "Skibidi Tower Defense - Auto Destroy",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false
})

-- メインタブ作成
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- 状態管理
local AutoKill = false

-- トグルボタン作成
MainTab:AddToggle({
    Name = "Auto Kill Enemies",
    Default = false,
    Callback = function(Value)
        AutoKill = Value
    end    
})

-- 実行ループ
task.spawn(function()
    while task.wait(0.1) do
        if AutoKill then
            for _, enemy in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") then
                    enemy.Humanoid.Health = 0 -- 仮のダメージ処理
                end
            end
        end
    end
end)

-- 完了通知
OrionLib:MakeNotification({
    Name = "準備完了",
    Content = "オートキル起動準備できたぞ！",
    Image = "rbxassetid://4483345998",
    Time = 5
})
