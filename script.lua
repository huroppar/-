-- ライブラリロード
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- GUI作成
local Window = Rayfield:CreateWindow({
    Name = "Skibidi Tower Defense - Auto Destroy",
    LoadingTitle = "Starting up...",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = false,
    }
})

-- タブ作成
local MainTab = Window:CreateTab("Main", 4483362458)

-- 状態管理
local AutoAttack = false

-- セクション作成
local MainSection = MainTab:CreateSection("Auto Farm")

-- ボタンスイッチ作成
local Toggle = MainTab:CreateToggle({
    Name = "Auto Kill Enemies",
    CurrentValue = false,
    Callback = function(Value)
        AutoAttack = Value
    end,
})

-- 実行ループ
task.spawn(function()
    while task.wait(0.1) do
        if AutoAttack then
            -- 敵リストを探す
            for _, enemy in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") then
                    -- ダメージを与える処理（仮）
                    enemy.Humanoid.Health = 0
                end
            end
        end
    end
end)
