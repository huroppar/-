-- OrionLibの読み込み
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local player = game.Players.LocalPlayer
local currentWalkSpeed = 16
local infiniteJumpEnabled = false

-- 現在のHumanoidを取得する関数
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("Humanoid")
end

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
	Name = "🔥 Speed & 無限ジャンプ GUI",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "SpeedJumpConfig"
})

local Tab = Window:MakeTab({
	Name = "メイン機能",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- スピードスライダー
Tab:AddSlider({
	Name = "移動スピード",
	Min = 16,
	Max = 100,
	Default = 16,
	Color = Color3.fromRGB(255, 170, 0),
	Increment = 1,
	ValueName = "スピード",
	Callback = function(value)
		currentWalkSpeed = value
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.WalkSpeed = value
		end
	end
})

-- 無限ジャンプトグル
Tab:AddToggle({
	Name = "無限ジャンプ",
	Default = false,
	Callback = function(state)
		infiniteJumpEnabled = state
	end
})

-- 無限ジャンプ処理
game:GetService("UserInputService").JumpRequest:Connect(function()
	if infiniteJumpEnabled then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- リスポーン後もスピード反映させる
player.CharacterAdded:Connect(function(char)
	local humanoid = char:WaitForChild("Humanoid")
	task.wait(0.1)
	humanoid.WalkSpeed = currentWalkSpeed
end)

-- GUI起動
OrionLib:Init()
