-- RoStrapを読み込む
local RoStrap = require(game:GetService("ReplicatedStorage"):WaitForChild("RoStrap"))

-- GUIウィンドウ作成
local Window = RoStrap.CreateWindow({
    Title = "Skibidi Tower Defense Helper",
    Size = UDim2.new(0, 400, 0, 500)
})

-- スタートボタンを作成
local StartButton = Window:CreateButton({
    Text = "Start Auto-Clear",
    Size = UDim2.new(0, 200, 0, 50),
    Position = UDim2.new(0.5, -100, 0.2, 0),
    Callback = function()
        print("Auto-Clear Started!")
        StartAutoClear()
    end
})

-- 停止ボタンを作成
local StopButton = Window:CreateButton({
    Text = "Stop Auto-Clear",
    Size = UDim2.new(0, 200, 0, 50),
    Position = UDim2.new(0.5, -100, 0.3, 0),
    Callback = function()
        print("Auto-Clear Stopped!")
        StopAutoClear()
    end
})

-- 自動クリア開始のフラグ
local autoClearActive = false

-- 自動クリアを開始する関数
function StartAutoClear()
    autoClearActive = true
    
    -- Waveごとに繰り返す
    while autoClearActive do
        -- 現在のWaveの進行状況をチェック
        local currentWave = game.ReplicatedStorage.GameData.Wave.Value
        
        -- 次のWaveに進むための条件
        if currentWave >= 1 then
            -- タワーを強化または配置する
            AutoPlaceTowers()  -- タワーを自動で配置・強化
        end
        
        -- Waveがクリアできたら次に進む
        if currentWave == game.ReplicatedStorage.GameData.MaxWave.Value then
            print("Wave " .. currentWave .. " cleared!")
            -- ここで報酬を得る処理を追加したり、次のWaveに進む処理を行う
            game.ReplicatedStorage.GameData.Wave.Value = currentWave + 1
        end

        wait(2)  -- 一定間隔でチェックを行う
    end
end

-- 自動クリアを停止する関数
function StopAutoClear()
    autoClearActive = false
end

-- タワーを自動で配置・強化する関数（簡易例）
function AutoPlaceTowers()
    -- 配置するタワーを決定（例：最も効果的な位置に配置）
    local towerPosition = Vector3.new(10, 0, 10)  -- 仮の位置
    local tower = game.ReplicatedStorage.TowerModels["SkibidiTower"]:Clone()
    tower.Parent = game.Workspace
    tower:SetPrimaryPartCFrame(CFrame.new(towerPosition))
    
    -- タワー強化（例えばレベル2にする）
    tower.Level.Value = 2  -- 仮の強化処理
end
