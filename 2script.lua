local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))();
local Window = OrionLib:MakeWindow({Name="wos script",HidePremium=false,SaveConfig=true,ConfigFolder="WOS_Config"});
local MainTab = Window:MakeTab({Name="メイン",Icon="rbxassetid://4483345998",PremiumOnly=false});
local ChestTab = Window:MakeTab({Name="チェスト",Icon="rbxassetid://4483345998",PremiumOnly=false});
local AimTab = Window:MakeTab({Name="AimAssist", Icon="rbxassetid://4483345998", PremiumOnly=false})
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentChestNumber = 1;
local function findChestByNumber(number)
	local FlatIdent_378D0 = 0;
	while true do
		if (FlatIdent_378D0 == 0) then
			for _, object in ipairs(game.Workspace:GetChildren()) do
				if (object:IsA("Model") and (object.Name == tostring(number))) then
					return object;
				end
			end
			return nil;
		end
	end
end
local function teleportToChest(chest)
	if chest then
		if chest.PrimaryPart then
			local FlatIdent_2953F = 0;
			local chestPosition;
			local teleportPosition;
			while true do
				if (FlatIdent_2953F == 0) then
					chestPosition = chest.PrimaryPart.Position;
					teleportPosition = chestPosition + Vector3.new(0, 7, 0);
					FlatIdent_2953F = 1;
				end
				if (FlatIdent_2953F == 1) then
					LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(teleportPosition));
					print("テレポートしました: " .. chest.Name);
					break;
				end
			end
		end
	else
		print("指定されたチェストが見つかりませんでした。");
	end
end
local buttonVisible = false;
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"));
screenGui.Name = "TeleportGui";
local floatingButton = Instance.new("TextButton");
floatingButton.Size = UDim2.new(0, 200, 0, 50);
floatingButton.Position = UDim2.new(0.5, -100, 0.5, -25);
floatingButton.Text = "次のチェストにテレポート";
floatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255);
floatingButton.Parent = screenGui;
floatingButton.Visible = buttonVisible;
floatingButton.MouseButton1Click:Connect(function()
	local FlatIdent_1CA5D = 0;
	local nextChest;
	while true do
		if (FlatIdent_1CA5D == 0) then
			currentChestNumber = currentChestNumber + 1;
			if (currentChestNumber > 30) then
				currentChestNumber = 1;
			end
			FlatIdent_1CA5D = 1;
		end
		if (FlatIdent_1CA5D == 1) then
			nextChest = findChestByNumber(currentChestNumber);
			teleportToChest(nextChest);
			break;
		end
	end
end);
ChestTab:AddToggle({Name="チェストボタン表示",Default=false,Callback=function(value)
	local FlatIdent_47A9C = 0;
	while true do
		if (FlatIdent_47A9C == 0) then
			buttonVisible = value;
			floatingButton.Visible = buttonVisible;
			break;
		end
	end
end});
local dragging = false;
local dragInput;
local startPos;
floatingButton.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1) then
		local FlatIdent_67517 = 0;
		while true do
			if (FlatIdent_67517 == 0) then
				dragging = true;
				startPos = input.Position;
				break;
			end
		end
	end
end);
floatingButton.InputChanged:Connect(function(input)
	if (dragging and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
		local FlatIdent_63487 = 0;
		local delta;
		while true do
			if (FlatIdent_63487 == 0) then
				delta = input.Position - startPos;
				floatingButton.Position = UDim2.new(floatingButton.Position.X.Scale, floatingButton.Position.X.Offset + delta.X, floatingButton.Position.Y.Scale, floatingButton.Position.Y.Offset + delta.Y);
				FlatIdent_63487 = 1;
			end
			if (FlatIdent_63487 == 1) then
				startPos = input.Position;
				break;
			end
		end
	end
end);
floatingButton.InputEnded:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1) then
		dragging = false;
	end
end);
ChestTab:AddButton({Name="次のチェストにテレポート",Callback=function()
	local FlatIdent_634AF = 0;
	local nextChest;
	while true do
		if (0 == FlatIdent_634AF) then
			currentChestNumber = currentChestNumber + 1;
			if (currentChestNumber > 30) then
				currentChestNumber = 1;
			end
			FlatIdent_634AF = 1;
		end
		if (FlatIdent_634AF == 1) then
			nextChest = findChestByNumber(currentChestNumber);
			teleportToChest(nextChest);
			break;
		end
	end
end});
local speedEnabled = false;
local speedValue = 16;
local speedConnection;
MainTab:AddToggle({Name="スピード有効化",Default=false,Callback=function(value)
	local FlatIdent_8199B = 0;
	while true do
		if (FlatIdent_8199B == 0) then
			speedEnabled = value;
			if value then
				if speedConnection then
					speedConnection:Disconnect();
				end
				speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
					if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) then
						LocalPlayer.Character.Humanoid.WalkSpeed = speedValue;
					end
				end);
			else
				local FlatIdent_39B0 = 0;
				while true do
					if (FlatIdent_39B0 == 0) then
						if speedConnection then
							speedConnection:Disconnect();
						end
						if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) then
							LocalPlayer.Character.Humanoid.WalkSpeed = 30;
						end
						break;
					end
				end
			end
			break;
		end
	end
end});
MainTab:AddSlider({Name="スピード調整",Min=1,Max=1000,Default=30,Color=Color3.fromRGB(255, 255, 255),Increment=1,ValueName="Speed",Callback=function(value)
	speedValue = value;
end});
local infiniteJumpEnabled = false;
MainTab:AddToggle({Name="無限ジャンプ",Default=false,Callback=function(value)
	infiniteJumpEnabled = value;
end});
game:GetService("UserInputService").JumpRequest:Connect(function()
	if (infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
	end
end);
local noclipEnabled = false;
MainTab:AddToggle({Name="壁貫通（Noclip）",Default=false,Callback=function(value)
	noclipEnabled = value;
end});
game:GetService("RunService").Stepped:Connect(function()
	if (noclipEnabled and LocalPlayer.Character) then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false;
			end
		end
	end
end);
local airTpButton = Instance.new("TextButton");
airTpButton.Size = UDim2.new(0, 100, 0, 50);
airTpButton.Position = UDim2.new(0.5, -50, 1, -100);
airTpButton.Text = "空中TP";
airTpButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
airTpButton.TextColor3 = Color3.fromRGB(255, 255, 255);
airTpButton.Parent = screenGui;
airTpButton.Active = true;
airTpButton.Draggable = true;
MainTab:AddToggle({Name="空中TPボタン表示",Default=true,Callback=function(value)
	airTpButton.Visible = value;
end});
local floating = false;
local originalPosition;
airTpButton.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character;
	if (character and character:FindFirstChild("HumanoidRootPart")) then
		local FlatIdent_31905 = 0;
		local hrp;
		local humanoid;
		while true do
			if (FlatIdent_31905 == 1) then
				if not floating then
					local FlatIdent_31ECC = 0;
					local bodyVel;
					local ground;
					while true do
						if (FlatIdent_31ECC == 0) then
							originalPosition = hrp.Position;
							hrp.CFrame = hrp.CFrame + Vector3.new(0, 500000, 0);
							bodyVel = Instance.new("BodyVelocity");
							FlatIdent_31ECC = 1;
						end
						if (FlatIdent_31ECC == 1) then
							bodyVel.Name = "FloatForce";
							bodyVel.Velocity = Vector3.new(0, 0, 0);
							bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
							FlatIdent_31ECC = 2;
						end
						if (FlatIdent_31ECC == 3) then
							ground.Size = Vector3.new(10, 1, 10);
							ground.Position = hrp.Position - Vector3.new(0, 5, 0);
							ground.Anchored = true;
							FlatIdent_31ECC = 4;
						end
						if (4 == FlatIdent_31ECC) then
							ground.CanCollide = true;
							ground.Name = "SkyPlatform";
							ground.Parent = workspace;
							FlatIdent_31ECC = 5;
						end
						if (FlatIdent_31ECC == 2) then
							bodyVel.Parent = hrp;
							if humanoid then
								humanoid.PlatformStand = true;
							end
							ground = Instance.new("Part");
							FlatIdent_31ECC = 3;
						end
						if (5 == FlatIdent_31ECC) then
							floating = true;
							break;
						end
					end
				else
					local FlatIdent_61B23 = 0;
					local float;
					local platform;
					while true do
						if (2 == FlatIdent_61B23) then
							if platform then
								platform:Destroy();
							end
							if humanoid then
								humanoid.PlatformStand = false;
							end
							FlatIdent_61B23 = 3;
						end
						if (FlatIdent_61B23 == 3) then
							floating = false;
							break;
						end
						if (FlatIdent_61B23 == 0) then
							hrp.CFrame = CFrame.new(originalPosition);
							float = hrp:FindFirstChild("FloatForce");
							FlatIdent_61B23 = 1;
						end
						if (FlatIdent_61B23 == 1) then
							if float then
								float:Destroy();
							end
							platform = workspace:FindFirstChild("SkyPlatform");
							FlatIdent_61B23 = 2;
						end
					end
				end
				break;
			end
			if (0 == FlatIdent_31905) then
				hrp = character.HumanoidRootPart;
				humanoid = character:FindFirstChildOfClass("Humanoid");
				FlatIdent_31905 = 1;
			end
		end
	end
end);
local gatherDistance = 50;
local RunService = game:GetService("RunService");
local gatheredEnemies = {};
local gathering = false;
local function startGatheringEnemies()
	local FlatIdent_2FD19 = 0;
	local myHRP;
	while true do
		if (FlatIdent_2FD19 == 0) then
			gathering = true;
			table.clear(gatheredEnemies);
			FlatIdent_2FD19 = 1;
		end
		if (FlatIdent_2FD19 == 1) then
			myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			if not myHRP then
				return;
			end
			FlatIdent_2FD19 = 2;
		end
		if (FlatIdent_2FD19 == 2) then
			for _, model in pairs(workspace:GetDescendants()) do
				if (model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and (model ~= LocalPlayer.Character)) then
					if (not model:FindFirstChild("Dialogue") and not model:FindFirstChild("QuestBubble")) then
						local enemyHRP = model.HumanoidRootPart;
						local dist = (enemyHRP.Position - myHRP.Position).Magnitude;
						if (dist <= gatherDistance) then
							table.insert(gatheredEnemies, model);
						end
					end
				end
			end
			break;
		end
	end
end
RunService.Heartbeat:Connect(function()
	if gathering then
		local FlatIdent_21CA5 = 0;
		local myHRP;
		while true do
			if (FlatIdent_21CA5 == 0) then
				myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
				if not myHRP then
					return;
				end
				FlatIdent_21CA5 = 1;
			end
			if (FlatIdent_21CA5 == 1) then
				for _, enemy in pairs(gatheredEnemies) do
					if (enemy and enemy:FindFirstChild("HumanoidRootPart")) then
						local FlatIdent_803FB = 0;
						local eHRP;
						while true do
							if (FlatIdent_803FB == 0) then
								eHRP = enemy.HumanoidRootPart;
								eHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -5);
								break;
							end
						end
					end
				end
				break;
			end
		end
	end
end);
MainTab:AddToggle({Name="敵を集める",Default=false,Callback=function(val)
	if val then
		startGatheringEnemies();
	else
		local FlatIdent_1B51D = 0;
		while true do
			if (FlatIdent_1B51D == 0) then
				gathering = false;
				gatheredEnemies = {};
				break;
			end
		end
	end
end});
MainTab:AddSlider({Name="敵集め距離",Min=1,Max=200,Default=50,Increment=1,Callback=function(value)
	gatherDistance = value;
end});
MainTab:AddTextbox({Name="敵集め 距離（手入力）",Default="50",TextDisappear=false,Callback=function(text)
	local FlatIdent_17196 = 0;
	local num;
	while true do
		if (FlatIdent_17196 == 0) then
			num = tonumber(text);
			if (num and (num >= 0)) then
				gatherDistance = num;
			end
			break;
		end
	end
end});
local CollectEnemies = false;
MainTab:AddToggle({Name="連続で敵を集める",Default=false,Callback=function(Value)
	local FlatIdent_12544 = 0;
	while true do
		if (FlatIdent_12544 == 0) then
			CollectEnemies = Value;
			if CollectEnemies then
				task.spawn(function()
					while CollectEnemies do
						local FlatIdent_29B3D = 0;
						while true do
							if (FlatIdent_29B3D == 0) then
								startGatheringEnemies();
								task.wait(0.5);
								break;
							end
						end
					end
				end);
			end
			break;
		end
	end
end});
local selectedPlayer = nil;
local dropdown;
local following = false;
local connection = nil;
local savedCFrame = nil;
local function getPlayerNames()
	local FlatIdent_90113 = 0;
	local names;
	while true do
		if (FlatIdent_90113 == 0) then
			names = {};
			for _, plr in pairs(Players:GetPlayers()) do
				if (plr ~= LocalPlayer) then
					table.insert(names, plr.Name);
				end
			end
			FlatIdent_90113 = 1;
		end
		if (FlatIdent_90113 == 1) then
			return names;
		end
	end
end
local function refreshDropdownOptions()
	if (dropdown and dropdown.Refresh) then
		dropdown:Refresh(getPlayerNames(), true);
	end
end
local function createDropdown()
	dropdown = MainTab:AddDropdown({Name="プレイヤーを選択",Default="",Options=getPlayerNames(),Callback=function(value)
		selectedPlayer = value;
	end});
end
task.spawn(function()
	while true do
		local FlatIdent_B1F4 = 0;
		while true do
			if (FlatIdent_B1F4 == 0) then
				task.wait(5);
				refreshDropdownOptions();
				break;
			end
		end
	end
end);
createDropdown();
MainTab:AddButton({Name="選択したプレイヤーの近くにテレポート",Callback=function()
	local target = Players:FindFirstChild(selectedPlayer);
	if (target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")) then
		LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 2);
	end
end});
MainTab:AddButton({Name="プレイヤーリストを手動更新",Callback=function()
	local FlatIdent_656E9 = 0;
	while true do
		if (FlatIdent_656E9 == 0) then
			refreshDropdownOptions();
			OrionLib:MakeNotification({Name="更新完了",Content="プレイヤー一覧を更新しました！",Time=3});
			break;
		end
	end
end});
MainTab:AddToggle({Name="密着追尾(オン/オフ)",Default=false,Callback=function(state)
	local FlatIdent_3EEE1 = 0;
	local myHRP;
	while true do
		if (FlatIdent_3EEE1 == 0) then
			following = state;
			myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			FlatIdent_3EEE1 = 1;
		end
		if (FlatIdent_3EEE1 == 1) then
			if following then
				local FlatIdent_324DE = 0;
				while true do
					if (0 == FlatIdent_324DE) then
						if myHRP then
							savedCFrame = myHRP.CFrame;
						end
						connection = game:GetService("RunService").Heartbeat:Connect(function()
							local FlatIdent_1DFAF = 0;
							local target;
							while true do
								if (FlatIdent_1DFAF == 0) then
									target = Players:FindFirstChild(selectedPlayer);
									if (target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")) then
										local FlatIdent_35A31 = 0;
										local targetHRP;
										local targetPos;
										while true do
											if (FlatIdent_35A31 == 0) then
												targetHRP = target.Character.HumanoidRootPart;
												targetPos = targetHRP.Position;
												FlatIdent_35A31 = 1;
											end
											if (FlatIdent_35A31 == 1) then
												if myHRP then
													local FlatIdent_64E40 = 0;
													local offsetCFrame;
													while true do
														if (FlatIdent_64E40 == 0) then
															offsetCFrame = targetHRP.CFrame * CFrame.new(0, 0, 7);
															myHRP.CFrame = CFrame.new(offsetCFrame.Position, targetPos);
															break;
														end
													end
												end
												break;
											end
										end
									end
									break;
								end
							end
						end);
						break;
					end
				end
			else
				local FlatIdent_8D1A5 = 0;
				while true do
					if (0 == FlatIdent_8D1A5) then
						if connection then
							local FlatIdent_8B523 = 0;
							while true do
								if (FlatIdent_8B523 == 0) then
									connection:Disconnect();
									connection = nil;
									break;
								end
							end
						end
						if (savedCFrame and myHRP) then
							myHRP.CFrame = savedCFrame;
						end
						break;
					end
				end
			end
			break;
		end
	end
end});
MainTab:AddButton({Name="透明化(PC非推奨)",Callback=function()
	local FlatIdent_6EF7B = 0;
	while true do
		if (FlatIdent_6EF7B == 0) then
			loadstring(game:HttpGet("https://pastebin.com/raw/3Rnd9rHf"))();
			loadstring(game:HttpGet("https://pastebin.com/raw/XXXXXXX"))();
			FlatIdent_6EF7B = 1;
		end
		if (FlatIdent_6EF7B == 1) then
			OrionLib:MakeNotification({Name="透明化実行",Content="透明化を実行しました！",Time=3});
			break;
		end
	end
end});
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local playerHighlights = {};
local highlightEnabled = true;
local function applyHighlight(player)
	local FlatIdent_20FB0 = 0;
	local character;
	local hrp;
	local isTimeErasing;
	while true do
		if (0 == FlatIdent_20FB0) then
			character = player.Character;
			if not character then
				return;
			end
			FlatIdent_20FB0 = 1;
		end
		if (FlatIdent_20FB0 == 1) then
			hrp = character:WaitForChild("HumanoidRootPart", 5);
			if not hrp then
				return;
			end
			FlatIdent_20FB0 = 2;
		end
		if (FlatIdent_20FB0 == 2) then
			isTimeErasing = character:FindFirstChild("TimeErase") and character.TimeErase.Value;
			if (highlightEnabled and not isTimeErasing) then
				local existingHighlight = playerHighlights[player];
				if (not existingHighlight or (existingHighlight.Adornee ~= character)) then
					local FlatIdent_6C033 = 0;
					local highlight;
					while true do
						if (FlatIdent_6C033 == 2) then
							highlight.OutlineColor = Color3.fromRGB(0, 0, 0);
							highlight.FillTransparency = 0.5;
							FlatIdent_6C033 = 3;
						end
						if (FlatIdent_6C033 == 4) then
							highlight.Parent = character;
							playerHighlights[player] = highlight;
							break;
						end
						if (FlatIdent_6C033 == 3) then
							highlight.OutlineTransparency = 0;
							highlight.Adornee = character;
							FlatIdent_6C033 = 4;
						end
						if (FlatIdent_6C033 == 1) then
							highlight.Name = "PlayerHighlight";
							highlight.FillColor = Color3.fromRGB(255, 255, 0);
							FlatIdent_6C033 = 2;
						end
						if (0 == FlatIdent_6C033) then
							if existingHighlight then
								existingHighlight:Destroy();
							end
							highlight = Instance.new("Highlight");
							FlatIdent_6C033 = 1;
						end
					end
				end
			elseif playerHighlights[player] then
				local FlatIdent_466B2 = 0;
				while true do
					if (FlatIdent_466B2 == 0) then
						playerHighlights[player]:Destroy();
						playerHighlights[player] = nil;
						break;
					end
				end
			end
			break;
		end
	end
end
local function updatePlayerHighlights()
	for _, player in ipairs(Players:GetPlayers()) do
		if (player ~= LocalPlayer) then
			applyHighlight(player);
		end
	end
end
MainTab:AddToggle({Name="プレイヤーハイライト",Default=true,Callback=function(value)
	local FlatIdent_1A54 = 0;
	while true do
		if (0 == FlatIdent_1A54) then
			highlightEnabled = value;
			updatePlayerHighlights();
			break;
		end
	end
end});
local function setupCharacterListener(player)
	player.CharacterAdded:Connect(function()
		local FlatIdent_2F298 = 0;
		while true do
			if (FlatIdent_2F298 == 0) then
				task.wait(1);
				applyHighlight(player);
				break;
			end
		end
	end);
end
for _, player in ipairs(Players:GetPlayers()) do
	if (player ~= LocalPlayer) then
		local FlatIdent_61800 = 0;
		while true do
			if (FlatIdent_61800 == 0) then
				setupCharacterListener(player);
				applyHighlight(player);
				break;
			end
		end
	end
end
Players.PlayerAdded:Connect(function(player)
	if (player ~= LocalPlayer) then
		setupCharacterListener(player);
	end
end);
while true do
	task.wait(1);
	updatePlayerHighlights();
end

-- Xeno完全統合AimAssist
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI
local Window = OrionLib:MakeWindow({
    Name = "Xeno AimAssist",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "XenoAim"
})

local Tab = Window:MakeTab({Name = "AimAssist", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- 設定
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

-- 味方判定
local function IsEnemy(char)
	if not char then return false end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if AimAssist.TeamCheck then
		local plr = Players:GetPlayerFromCharacter(char)
		if plr and plr.Team == player.Team then
			return false
		end
	end
	return true
end

-- ターゲット部位
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

-- 壁越しチェック
local function isVisible(part)
	if AimAssist.ThroughWalls then return true end
	local origin = camera.CFrame.Position
	local direction = (part.Position - origin)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, direction, params)
	if result then
		return result.Instance:IsDescendantOf(part.Parent)
	end
	return true
end

-- レティクルに一番近い敵
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

-- エイム処理
RS.RenderStepped:Connect(function()
	if AimAssist.Enabled then
		local target = GetClosestToCrosshair()
		if target then
			local aimCF = CFrame.new(camera.CFrame.Position, target.Position)
			camera.CFrame = camera.CFrame:Lerp(aimCF, AimAssist.Smoothness)
		end
	end
end)

-- キーハンドリング（PC）
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

-- GUI設定
Tab:AddToggle({
	Name = "AimAssist ON/OFF",
	Default = false,
	Callback = function(v)
		AimAssist.Enabled = v
	end
})

Tab:AddToggle({
	Name = "Toggle Mode (トグル/ホールド切替)",
	Default = true,
	Callback = function(v)
		AimAssist.UseToggleMode = v
	end
})

-- KeyBox
Tab:AddTextbox({
	Name = "Toggle Key (トグル用)",
	PlaceholderText = "V",
	Text = "V",
	Callback = function(txt)
		local suc, key = pcall(function() return Enum.KeyCode[txt] end)
		if suc then AimAssist.ToggleKey = key end
	end
})

Tab:AddTextbox({
	Name = "Hold Key (ホールド用)",
	PlaceholderText = "RightShift",
	Text = "RightShift",
	Callback = function(txt)
		local suc, key = pcall(function() return Enum.KeyCode[txt] end)
		if suc then AimAssist.HoldKey = key end
	end
})

Tab:AddSlider({
	Name = "Smoothness",
	Min = 0.05,
	Max = 0.5,
	Default = 0.18,
	Increment = 0.01,
	Callback = function(val)
		AimAssist.Smoothness = val
	end
})

Tab:AddSlider({
	Name = "Max Distance",
	Min = 50,
	Max = 1000,
	Default = 250,
	Increment = 10,
	Callback = function(val)
		AimAssist.MaxDistance = val
	end
})

Tab:AddToggle({
	Name = "Through Walls (壁越し吸い付き)",
	Default = false,
	Callback = function(v)
		AimAssist.ThroughWalls = v
	end
})

Tab:AddDropdown({
	Name = "Target Mode",
	Default = "Head",
	Options = {"Head","Body","Random"},
	Callback = function(opt)
		AimAssist.TargetMode = opt
	end
})

-- スマホ用ボタン
Tab:AddButton({
	Name = "AimAssist ON/OFF (スマホ用)",
	Callback = function()
		AimAssist.Enabled = not AimAssist.Enabled
		if AimAssist.Enabled then
			print("スマホ用AimAssist: ON")
		else
			print("スマホ用AimAssist: OFF")
		end
	end
})

OrionLib:Init()


MainTab:AddButton({Name="キャラクターリセット",Callback=function()
	local FlatIdent_90A41 = 0;
	local player;
	local character;
	local humanoid;
	while true do
		if (FlatIdent_90A41 == 1) then
			humanoid = character:FindFirstChild("Humanoid");
			if humanoid then
				humanoid.Health = 0;
			end
			break;
		end
		if (FlatIdent_90A41 == 0) then
			player = game.Players.LocalPlayer;
			character = player.Character or player.CharacterAdded:Wait();
			FlatIdent_90A41 = 1;
		end
	end
end});
local reopenButtonGui = Instance.new("ScreenGui");
reopenButtonGui.Name = "ReopenGui";
reopenButtonGui.ResetOnSpawn = false;
reopenButtonGui.Parent = game:GetService("CoreGui");
local reopenButton = Instance.new("TextButton");
reopenButton.Size = UDim2.new(0, 100, 0, 40);
reopenButton.Position = UDim2.new(0, 10, 0, 10);
reopenButton.Text = "UI再表示";
reopenButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
reopenButton.TextColor3 = Color3.fromRGB(255, 255, 255);
reopenButton.Parent = reopenButtonGui;
reopenButton.MouseButton1Click:Connect(function()
	OrionLib:Toggle(true);
end);
OrionLib:MakeNotification({Name="WOSユーティリティ",Content="スクリプトの読み込みが完了しました！ - by Masashi",Time=5});
