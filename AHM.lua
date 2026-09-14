local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterPack = game:GetService("StarterPack");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local Camera = workspace.CurrentCamera;
local LocalPlayer = Players.LocalPlayer;
local espInventoryEnabled = true;
local MAX_DISTANCE = 4000;
local UPDATE_INTERVAL = 1;
local BillboardCache = {};
local nameCache = {};
local RARITY_COLORS = {Common=Color3.fromRGB(220, 220, 220),Uncommon=Color3.fromRGB(0, 255, 100),Rare=Color3.fromRGB(0, 170, 255),Epic=Color3.fromRGB(200, 0, 255),Legendary=Color3.fromRGB(255, 215, 0),Omega=Color3.fromRGB(255, 0, 0)};
local function getRealName(t)
	local FlatIdent_95CAC = 0;
	local originalName;
	local lowerName;
	local cleaned;
	local h;
	local fallbackName;
	while true do
		if (FlatIdent_95CAC == 3) then
			nameCache[originalName] = fallbackName;
			return fallbackName;
		end
		if (FlatIdent_95CAC == 1) then
			cleaned = lowerName:gsub("%d+$", ""):gsub("_%d+$", ""):gsub("%s*%d+%s*$", ""):gsub("[%s_]+", " "):gsub("([^%w%s])", ""):match("^%s*(.-)%s*$");
			if (cleaned:find("fishing") or cleaned:find("rod") or cleaned:find("canne") or cleaned:find("pط£ع¾che")) then
				if (cleaned:find("ultimate") or cleaned:find("ult")) then
					return "Ultimate Fishing Rod";
				elseif cleaned:find("advanced") then
					return "Advanced Fishing Rod";
				elseif cleaned:find("pro") then
					return "Pro Fishing Rod";
				else
					return "Regular Fishing Rod";
				end
			end
			if nameCache[originalName] then
				return nameCache[originalName];
			end
			FlatIdent_95CAC = 2;
		end
		if (FlatIdent_95CAC == 0) then
			if (not t or not t.Name) then
				return nil;
			end
			originalName = t.Name;
			lowerName = originalName:lower();
			FlatIdent_95CAC = 1;
		end
		if (FlatIdent_95CAC == 2) then
			h = t:FindFirstChild("Handle");
			fallbackName = cleaned;
			for _, folder in ipairs({ReplicatedStorage:FindFirstChild("Items"),StarterPack}) do
				if folder then
					for _, item in ipairs(folder:GetDescendants()) do
						if (item:IsA("Tool") and item:FindFirstChild("Handle")) then
							local match = true;
							if h then
								for _, c in ipairs(h:GetChildren()) do
									if not item.Handle:FindFirstChild(c.Name) then
										match = false;
										break;
									end
								end
							else
								match = false;
							end
							if match then
								local FlatIdent_7126A = 0;
								while true do
									if (FlatIdent_7126A == 0) then
										nameCache[originalName] = item.Name;
										return item.Name;
									end
								end
							end
						end
					end
				end
			end
			FlatIdent_95CAC = 3;
		end
	end
end
local function updateESP(p)
	local FlatIdent_12703 = 0;
	local bb;
	local char;
	local lChar;
	local container;
	local layout;
	local tools;
	while true do
		if (FlatIdent_12703 == 3) then
			layout = Instance.new("UIListLayout", container);
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
			layout.VerticalAlignment = Enum.VerticalAlignment.Bottom;
			FlatIdent_12703 = 4;
		end
		if (FlatIdent_12703 == 4) then
			layout.Padding = UDim.new(0, 2);
			tools = {};
			if p:FindFirstChild("Backpack") then
				for _, t in ipairs(p.Backpack:GetChildren()) do
					if (t:IsA("Tool") and (t.Name:lower() ~= "fists")) then
						table.insert(tools, t);
					end
				end
			end
			FlatIdent_12703 = 5;
		end
		if (FlatIdent_12703 == 5) then
			if char then
				for _, t in ipairs(char:GetChildren()) do
					if (t:IsA("Tool") and (t.Name:lower() ~= "fists")) then
						table.insert(tools, t);
					end
				end
			end
			bb.Enabled = espInventoryEnabled and (#tools > 0);
			for _, tool in ipairs(tools) do
				local name = getRealName(tool);
				if name then
					local FlatIdent_104D4 = 0;
					local lbl;
					local rarity;
					while true do
						if (FlatIdent_104D4 == 1) then
							lbl.BackgroundTransparency = 1;
							lbl.Text = name;
							FlatIdent_104D4 = 2;
						end
						if (FlatIdent_104D4 == 4) then
							lbl.TextColor3 = RARITY_COLORS[rarity] or Color3.fromRGB(255, 255, 255);
							lbl.TextXAlignment = Enum.TextXAlignment.Center;
							break;
						end
						if (3 == FlatIdent_104D4) then
							lbl.TextStrokeTransparency = 0.5;
							rarity = tool:GetAttribute("RarityName") or tool:GetAttribute("Rarity");
							FlatIdent_104D4 = 4;
						end
						if (FlatIdent_104D4 == 2) then
							lbl.Font = Enum.Font.GothamBold;
							lbl.TextSize = 13;
							FlatIdent_104D4 = 3;
						end
						if (FlatIdent_104D4 == 0) then
							lbl = Instance.new("TextLabel", container);
							lbl.Size = UDim2.new(0, 180, 0, 14);
							FlatIdent_104D4 = 1;
						end
					end
				end
			end
			break;
		end
		if (FlatIdent_12703 == 0) then
			bb = BillboardCache[p];
			if not bb then
				return;
			end
			char = p.Character;
			FlatIdent_12703 = 1;
		end
		if (FlatIdent_12703 == 1) then
			if (not char or not char:FindFirstChild("HumanoidRootPart")) then
				local FlatIdent_1076E = 0;
				while true do
					if (FlatIdent_1076E == 0) then
						bb.Enabled = false;
						return;
					end
				end
			end
			lChar = LocalPlayer.Character;
			if (lChar and lChar:FindFirstChild("HumanoidRootPart")) then
				local FlatIdent_C460 = 0;
				local dist;
				while true do
					if (FlatIdent_C460 == 0) then
						dist = (lChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude;
						if (dist > MAX_DISTANCE) then
							bb.Enabled = false;
							return;
						end
						break;
					end
				end
			end
			FlatIdent_12703 = 2;
		end
		if (FlatIdent_12703 == 2) then
			container = bb:FindFirstChild("EspContainer");
			if not container then
				return;
			end
			container:ClearAllChildren();
			FlatIdent_12703 = 3;
		end
	end
end
local function createESP(p)
	if (p == LocalPlayer) then
		return;
	end
	local function setup(char)
		local FlatIdent_8F59B = 0;
		local root;
		local bb;
		local cont;
		local backpack;
		while true do
			if (FlatIdent_8F59B == 3) then
				cont.BackgroundTransparency = 1;
				BillboardCache[p] = bb;
				updateESP(p);
				char.ChildAdded:Connect(function(child)
					if child:IsA("Tool") then
						local FlatIdent_E0D0 = 0;
						while true do
							if (FlatIdent_E0D0 == 0) then
								task.wait(0.1);
								updateESP(p);
								break;
							end
						end
					end
				end);
				FlatIdent_8F59B = 4;
			end
			if (FlatIdent_8F59B == 2) then
				bb.MaxDistance = MAX_DISTANCE;
				cont = Instance.new("Frame", bb);
				cont.Name = "EspContainer";
				cont.Size = UDim2.new(1, 0, 1, 0);
				FlatIdent_8F59B = 3;
			end
			if (FlatIdent_8F59B == 4) then
				char.ChildRemoved:Connect(function(child)
					if child:IsA("Tool") then
						local FlatIdent_8DCA9 = 0;
						while true do
							if (FlatIdent_8DCA9 == 0) then
								task.wait(0.1);
								updateESP(p);
								break;
							end
						end
					end
				end);
				backpack = p:WaitForChild("Backpack", 5);
				if backpack then
					local FlatIdent_39EBF = 0;
					while true do
						if (FlatIdent_39EBF == 0) then
							backpack.ChildAdded:Connect(function()
								updateESP(p);
							end);
							backpack.ChildRemoved:Connect(function()
								updateESP(p);
							end);
							break;
						end
					end
				end
				task.spawn(function()
					while char.Parent and bb.Parent do
						updateESP(p);
						task.wait(UPDATE_INTERVAL);
					end
				end);
				break;
			end
			if (FlatIdent_8F59B == 1) then
				bb.Name = "FixedUnderfootESP";
				bb.Size = UDim2.new(0, 200, 0, 150);
				bb.StudsOffset = Vector3.new(0, -3.5, 0);
				bb.AlwaysOnTop = true;
				FlatIdent_8F59B = 2;
			end
			if (FlatIdent_8F59B == 0) then
				root = char:WaitForChild("HumanoidRootPart", 15);
				if not root then
					return;
				end
				if BillboardCache[p] then
					BillboardCache[p]:Destroy();
				end
				bb = Instance.new("BillboardGui", root);
				FlatIdent_8F59B = 1;
			end
		end
	end
	p.CharacterAdded:Connect(setup);
	if p.Character then
		setup(p.Character);
	end
end
for _, p in ipairs(Players:GetPlayers()) do
	createESP(p);
end
Players.PlayerAdded:Connect(createESP);
local ScreenGui = Instance.new("ScreenGui", game.CoreGui);
ScreenGui.Name = "AHM_HUB";
ScreenGui.IgnoreGuiInset = true;
ScreenGui.ResetOnSpawn = false;
local Themes = {Navy={Background=Color3.fromRGB(10, 20, 40),Panel=Color3.fromRGB(20, 35, 70),Accent=Color3.fromRGB(0, 170, 255),Text=Color3.fromRGB(235, 245, 255),ON=Color3.fromRGB(0, 200, 0),OFF=Color3.fromRGB(200, 0, 0)}};
local CurrentTheme = Themes.Navy;
local MainFrame = Instance.new("Frame", ScreenGui);
MainFrame.Size = UDim2.new(0.4, 0, 0.85, 0);
MainFrame.Position = UDim2.new(0.3, 0, 0.08, 0);
MainFrame.BackgroundColor3 = CurrentTheme.Background;
MainFrame.BorderSizePixel = 0;
MainFrame.Visible = false;
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8);
local TitleLabel = Instance.new("TextLabel", MainFrame);
TitleLabel.Size = UDim2.new(0.8, 0, 0.05, 0);
TitleLabel.Position = UDim2.new(0.1, 0, 0.01, 0);
TitleLabel.BackgroundTransparency = 1;
TitleLabel.Text = "âڑ، AHM HUB âڑ،";
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 0);
TitleLabel.TextScaled = true;
TitleLabel.Font = Enum.Font.SourceSansBold;
local MainDrag = Instance.new("Frame", MainFrame);
MainDrag.Size = UDim2.new(1, 0, 0.06, 0);
MainDrag.BackgroundTransparency = 1;
local ClutchPlayer = Players.LocalPlayer;
local ClutchCamera = workspace.CurrentCamera;
local TweenService = game:GetService("TweenService");
local ClutchScreenGui = Instance.new("ScreenGui");
ClutchScreenGui.Name = "ClutchAHM_GUI";
ClutchScreenGui.ResetOnSpawn = false;
ClutchScreenGui.Parent = ClutchPlayer:WaitForChild("PlayerGui");
local ClutchButton = Instance.new("TextButton");
ClutchButton.Size = UDim2.new(0, 180, 0, 45);
ClutchButton.Position = UDim2.new(0.5, -90, 0.05, 0);
ClutchButton.Text = "ظ‚ظ„طھط´ AHM";
ClutchButton.TextColor3 = Color3.fromRGB(255, 255, 255);
ClutchButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
ClutchButton.Font = Enum.Font.GothamBold;
ClutchButton.TextSize = 14;
ClutchButton.AutoButtonColor = false;
ClutchButton.Parent = ClutchScreenGui;
local ClutchCorner = Instance.new("UICorner");
ClutchCorner.CornerRadius = UDim.new(0, 12);
ClutchCorner.Parent = ClutchButton;
local ClutchStroke = Instance.new("UIStroke");
ClutchStroke.Thickness = 2;
ClutchStroke.Color = Color3.fromRGB(80, 80, 80);
ClutchStroke.Transparency = 0.5;
ClutchStroke.Parent = ClutchButton;
ClutchButton.MouseEnter:Connect(function()
	TweenService:Create(ClutchButton, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(40, 40, 40)}):Play();
end);
ClutchButton.MouseLeave:Connect(function()
	TweenService:Create(ClutchButton, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(20, 20, 20)}):Play();
end);
local ClutchBlackFrame = Instance.new("Frame");
ClutchBlackFrame.Name = "BlackOverlay";
ClutchBlackFrame.Size = UDim2.new(1, 0, 1, 0);
ClutchBlackFrame.Position = UDim2.new(0, 0, 0, 0);
ClutchBlackFrame.BackgroundColor3 = Color3.new(0, 0, 0);
ClutchBlackFrame.BackgroundTransparency = 0;
ClutchBlackFrame.Visible = false;
ClutchBlackFrame.ZIndex = 10;
ClutchBlackFrame.Active = true;
ClutchBlackFrame.Parent = ClutchScreenGui;
local ClutchCloseButton = Instance.new("TextButton");
ClutchCloseButton.Size = UDim2.new(0, 40, 0, 40);
ClutchCloseButton.Position = UDim2.new(1, -50, 0, 10);
ClutchCloseButton.Text = "X";
ClutchCloseButton.TextColor3 = Color3.fromRGB(200, 200, 200);
ClutchCloseButton.BackgroundTransparency = 1;
ClutchCloseButton.Font = Enum.Font.GothamBold;
ClutchCloseButton.TextSize = 20;
ClutchCloseButton.ZIndex = 11;
ClutchCloseButton.Parent = ClutchBlackFrame;
local ClutchIsActive = false;
local function ClutchRestoreCamera()
	local FlatIdent_8BF78 = 0;
	while true do
		if (FlatIdent_8BF78 == 0) then
			ClutchCamera.CameraType = Enum.CameraType.Custom;
			if ClutchPlayer.Character then
				local humanoid = ClutchPlayer.Character:FindFirstChild("Humanoid");
				if humanoid then
					ClutchCamera.CameraSubject = humanoid;
				end
			end
			FlatIdent_8BF78 = 1;
		end
		if (1 == FlatIdent_8BF78) then
			if _G.SpectateConnection then
				local FlatIdent_27404 = 0;
				while true do
					if (FlatIdent_27404 == 0) then
						_G.SpectateConnection:Disconnect();
						_G.SpectateConnection = nil;
						break;
					end
				end
			end
			break;
		end
	end
end
local function ClutchHideBlackScreen()
	ClutchBlackFrame.Visible = false;
	ClutchButton.Text = "ظ‚ظ„طھط´ AHM";
	ClutchButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
	ClutchRestoreCamera();
	ClutchIsActive = false;
end
local function ClutchShowBlackScreen()
	local FlatIdent_9622C = 0;
	while true do
		if (3 == FlatIdent_9622C) then
			task.wait(0.1);
			ClutchHideBlackScreen();
			break;
		end
		if (FlatIdent_9622C == 1) then
			ClutchBlackFrame.Visible = true;
			ClutchButton.Text = "ط¬ط§ط±ظٹ...";
			FlatIdent_9622C = 2;
		end
		if (FlatIdent_9622C == 2) then
			ClutchButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0);
			ClutchRestoreCamera();
			FlatIdent_9622C = 3;
		end
		if (FlatIdent_9622C == 0) then
			if ClutchIsActive then
				return;
			end
			ClutchIsActive = true;
			FlatIdent_9622C = 1;
		end
	end
end
ClutchButton.MouseButton1Click:Connect(ClutchShowBlackScreen);
ClutchCloseButton.MouseButton1Click:Connect(function()
	ClutchHideBlackScreen();
end);
local HideGlitchToggle = Instance.new("TextButton", MainFrame);
HideGlitchToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
HideGlitchToggle.Position = UDim2.new(0.1, 0, 0.07, 0);
HideGlitchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0);
HideGlitchToggle.Text = "ط¥ط®ظپط§ط، ط§ظ„ظ‚ظ„طھط´: OFF";
HideGlitchToggle.TextScaled = true;
HideGlitchToggle.TextColor3 = Color3.new(1, 1, 1);
Instance.new("UICorner", HideGlitchToggle).CornerRadius = UDim.new(0, 8);
local ToggleButton = Instance.new("TextButton", ScreenGui);
ToggleButton.Size = UDim2.new(0, 100, 0, 40);
ToggleButton.Position = UDim2.new(0.9, 0, 0.05, 0);
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
ToggleButton.Text = "Open";
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0);
ToggleButton.TextScaled = true;
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8);
ToggleButton.Visible = true;
local ToggleDrag = Instance.new("Frame", ToggleButton);
ToggleDrag.Size = UDim2.new(1, 0, 1, 0);
ToggleDrag.BackgroundTransparency = 1;
local SmartToggle = Instance.new("TextButton", MainFrame);
SmartToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
SmartToggle.Position = UDim2.new(0.1, 0, 0.15, 0);
SmartToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0);
SmartToggle.Text = "ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±: ON";
SmartToggle.TextScaled = true;
SmartToggle.TextColor3 = Color3.new(1, 1, 1);
Instance.new("UICorner", SmartToggle).CornerRadius = UDim.new(0, 8);
local AILeadToggle = Instance.new("TextButton", MainFrame);
AILeadToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
AILeadToggle.Position = UDim2.new(0.1, 0, 0.23, 0);
AILeadToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0);
AILeadToggle.Text = "طھط³ط¨ظٹظ‚: OFF";
AILeadToggle.TextScaled = true;
AILeadToggle.TextColor3 = Color3.new(1, 1, 1);
Instance.new("UICorner", AILeadToggle).CornerRadius = UDim.new(0, 8);
local AILabel = Instance.new("TextLabel", MainFrame);
AILabel.Size = UDim2.new(0.4, 0, 0.05, 0);
AILabel.Position = UDim2.new(0.1, 0, 0.31, 0);
AILabel.BackgroundTransparency = 1;
AILabel.Text = "ظ‚ظˆط© ط§ظ„طھط³ط¨ظٹظ‚: 50%";
AILabel.TextColor3 = Color3.fromRGB(255, 255, 255);
AILabel.TextScaled = true;
AILabel.Font = Enum.Font.SourceSansBold;
local AILeadSlider = Instance.new("TextBox", MainFrame);
AILeadSlider.Size = UDim2.new(0.4, 0, 0.05, 0);
AILeadSlider.Position = UDim2.new(0.5, 0, 0.31, 0);
AILeadSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50);
AILeadSlider.Text = "50";
AILeadSlider.TextColor3 = Color3.fromRGB(255, 255, 255);
AILeadSlider.TextScaled = true;
Instance.new("UICorner", AILeadSlider).CornerRadius = UDim.new(0, 8);
local ESPInventoryToggle = Instance.new("TextButton", MainFrame);
ESPInventoryToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
ESPInventoryToggle.Position = UDim2.new(0.1, 0, 0.37, 0);
ESPInventoryToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
ESPInventoryToggle.Text = "ESP Inventory: ON";
ESPInventoryToggle.TextScaled = true;
Instance.new("UICorner", ESPInventoryToggle).CornerRadius = UDim.new(0, 8);
local ESPToggle = Instance.new("TextButton", MainFrame);
ESPToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
ESPToggle.Position = UDim2.new(0.1, 0, 0.44, 0);
ESPToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
ESPToggle.Text = "ESP: ON";
ESPToggle.TextScaled = true;
Instance.new("UICorner", ESPToggle).CornerRadius = UDim.new(0, 8);
local AimbotToggle = Instance.new("TextButton", MainFrame);
AimbotToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
AimbotToggle.Position = UDim2.new(0.1, 0, 0.51, 0);
AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
AimbotToggle.Text = "Aimbot: ON";
AimbotToggle.TextScaled = true;
Instance.new("UICorner", AimbotToggle).CornerRadius = UDim.new(0, 8);
local WallcheckToggle = Instance.new("TextButton", MainFrame);
WallcheckToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
WallcheckToggle.Position = UDim2.new(0.1, 0, 0.58, 0);
WallcheckToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
WallcheckToggle.Text = "Wallcheck: ON";
WallcheckToggle.TextScaled = true;
WallcheckToggle.TextColor3 = Color3.new(1, 1, 1);
Instance.new("UICorner", WallcheckToggle).CornerRadius = UDim.new(0, 8);
local FOVSlider = Instance.new("TextBox", MainFrame);
FOVSlider.Size = UDim2.new(0.8, 0, 0.07, 0);
FOVSlider.Position = UDim2.new(0.1, 0, 0.65, 0);
FOVSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50);
FOVSlider.Text = "FOV: 150";
FOVSlider.TextColor3 = Color3.fromRGB(255, 0, 0);
FOVSlider.TextScaled = true;
Instance.new("UICorner", FOVSlider).CornerRadius = UDim.new(0, 8);
local AimPartToggle = Instance.new("TextButton", MainFrame);
AimPartToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
AimPartToggle.Position = UDim2.new(0.1, 0, 0.72, 0);
AimPartToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 255);
AimPartToggle.Text = "Target: Auto Switch (Head â†” Torso)";
AimPartToggle.TextScaled = true;
AimPartToggle.TextColor3 = Color3.new(1, 1, 1);
Instance.new("UICorner", AimPartToggle).CornerRadius = UDim.new(0, 8);
local FOVCircleToggle = Instance.new("TextButton", MainFrame);
FOVCircleToggle.Size = UDim2.new(0.8, 0, 0.07, 0);
FOVCircleToggle.Position = UDim2.new(0.1, 0, 0.79, 0);
FOVCircleToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
FOVCircleToggle.Text = "FOV Circle: ON";
FOVCircleToggle.TextScaled = true;
FOVCircleToggle.TextColor3 = Color3.new(1, 1, 1);
Instance.new("UICorner", FOVCircleToggle).CornerRadius = UDim.new(0, 8);
local PlayerListFrame = Instance.new("ScrollingFrame", MainFrame);
PlayerListFrame.Size = UDim2.new(0.8, 0, 0.13, 0);
PlayerListFrame.Position = UDim2.new(0.1, 0, 0.87, 0);
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
PlayerListFrame.ScrollBarThickness = 6;
PlayerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y;
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 8);
local PlayerListLayout = Instance.new("UIListLayout", PlayerListFrame);
PlayerListLayout.Padding = UDim.new(0, 4);
local function ApplyTheme()
	local FlatIdent_6DC53 = 0;
	while true do
		if (0 == FlatIdent_6DC53) then
			MainFrame.BackgroundColor3 = CurrentTheme.Background;
			TitleLabel.TextColor3 = CurrentTheme.Accent;
			FlatIdent_6DC53 = 1;
		end
		if (1 == FlatIdent_6DC53) then
			for _, v in ipairs(MainFrame:GetDescendants()) do
				if v:IsA("TextButton") then
					local FlatIdent_68E92 = 0;
					while true do
						if (FlatIdent_68E92 == 0) then
							v.BackgroundColor3 = CurrentTheme.Panel;
							v.TextColor3 = CurrentTheme.Text;
							break;
						end
					end
				end
			end
			break;
		end
	end
end
local clutchVisible = true;
HideGlitchToggle.MouseButton1Click:Connect(function()
	local FlatIdent_6C033 = 0;
	while true do
		if (0 == FlatIdent_6C033) then
			clutchVisible = not clutchVisible;
			if clutchVisible then
				HideGlitchToggle.Text = "ط¥ط®ظپط§ط، ط§ظ„ظ‚ظ„طھط´: OFF";
				HideGlitchToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0);
				ClutchButton.Visible = true;
				print("âœ… ط²ط± ط§ظ„ظ‚ظ„طھط´ ط¸ط§ظ‡ط± (ط§ظ„ط¥ط®ظپط§ط، ظ…ط¹ط·ظ„)");
			else
				HideGlitchToggle.Text = "ط¥ط®ظپط§ط، ط§ظ„ظ‚ظ„طھط´: ON";
				HideGlitchToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0);
				ClutchButton.Visible = false;
				print("â‌Œ ط²ط± ط§ظ„ظ‚ظ„طھط´ ظ…ط®ظپظٹ (ط§ظ„ط¥ط®ظپط§ط، ظ…ظپط¹ظ„)");
			end
			break;
		end
	end
end);
local espEnabledStatus = true;
local AimbotOn = true;
local FOVRadius = 150;
local WallCheckEnabled = true;
local FOVCircleVisible = true;
local FOVCircleForcedOff = false;
local ProtectedPlayers = {};
local PlayerButtons = {};
local AIM_SMOOTHNESS = 0.6;
local PREDICTION_TIME = 0.04;
local guiOpen = false;
local smartMode = true;
local aiLeadEnabled = false;
local aiLeadStrength = 0.5;
local lastDirection = nil;
local forceMode = 1;
local lastModeSwitchTime = 0;
local MODE_SWITCH_COOLDOWN = 3;
local FOVCircle = Drawing.new("Circle");
FOVCircle.Radius = FOVRadius;
FOVCircle.Thickness = 2;
FOVCircle.Color = Color3.fromRGB(255, 0, 0);
FOVCircle.Transparency = 0.6;
FOVCircle.Filled = false;
FOVCircle.Visible = false;
local AIM_MODES = {{name="Auto Switch (Head â†” Torso)",parts={"Head","HumanoidRootPart"}},{name="Head (fixed)",part="Head"}};
local currentAutoIndex = 1;
local lastSwitchTime = os.clock();
local switchTimes = {0.4,0.5};
local currentSwitchTime = switchTimes[1];
local function IsAlive(char)
	local FlatIdent_5B2CE = 0;
	local h;
	while true do
		if (FlatIdent_5B2CE == 0) then
			h = char and char:FindFirstChildOfClass("Humanoid");
			return h and (h.Health > 0);
		end
	end
end
local function IsVisible(part)
	local FlatIdent_2E9CB = 0;
	local origin;
	local direction;
	local params;
	local result;
	while true do
		if (FlatIdent_2E9CB == 3) then
			result = workspace:Raycast(origin, direction, params);
			return not result;
		end
		if (FlatIdent_2E9CB == 0) then
			if not part then
				return false;
			end
			origin = Camera.CFrame.Position;
			FlatIdent_2E9CB = 1;
		end
		if (FlatIdent_2E9CB == 2) then
			params.FilterType = Enum.RaycastFilterType.Blacklist;
			params.FilterDescendantsInstances = {(LocalPlayer.Character or workspace),part.Parent};
			FlatIdent_2E9CB = 3;
		end
		if (FlatIdent_2E9CB == 1) then
			direction = part.Position - origin;
			params = RaycastParams.new();
			FlatIdent_2E9CB = 2;
		end
	end
end
local function removeESP(char)
	if char then
		local FlatIdent_45D37 = 0;
		local head;
		local h;
		while true do
			if (FlatIdent_45D37 == 1) then
				h = char:FindFirstChild("AHMHighlight");
				if h then
					h:Destroy();
				end
				break;
			end
			if (FlatIdent_45D37 == 0) then
				head = char:FindFirstChild("Head");
				if head then
					local FlatIdent_90A41 = 0;
					local b;
					while true do
						if (FlatIdent_90A41 == 0) then
							b = head:FindFirstChild("AHMNameHP");
							if b then
								b:Destroy();
							end
							break;
						end
					end
				end
				FlatIdent_45D37 = 1;
			end
		end
	end
end
local function applyESP(char)
	local FlatIdent_6D9D2 = 0;
	local plr;
	local head;
	local hum;
	local bill;
	local name;
	local hpBg;
	local hpFill;
	local hpText;
	local updateHP;
	local hl;
	while true do
		if (FlatIdent_6D9D2 == 7) then
			updateHP = nil;
			function updateHP()
				if (hum.Parent and IsAlive(char)) then
					local FlatIdent_77172 = 0;
					local r;
					while true do
						if (FlatIdent_77172 == 1) then
							hpText.Text = math.floor(hum.Health) .. "/" .. hum.MaxHealth;
							break;
						end
						if (FlatIdent_77172 == 0) then
							r = math.clamp(hum.Health / hum.MaxHealth, 0, 1);
							hpFill.Size = UDim2.new(r, 0, 1, 0);
							FlatIdent_77172 = 1;
						end
					end
				else
					removeESP(char);
				end
			end
			hum.HealthChanged:Connect(updateHP);
			hum.Died:Connect(function()
				removeESP(char);
			end);
			updateHP();
			FlatIdent_6D9D2 = 8;
		end
		if (FlatIdent_6D9D2 == 5) then
			hpFill = Instance.new("Frame", hpBg);
			hpFill.Size = UDim2.new(1, 0, 1, 0);
			hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
			Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 3);
			hpText = Instance.new("TextLabel", hpBg);
			FlatIdent_6D9D2 = 6;
		end
		if (FlatIdent_6D9D2 == 4) then
			hpBg = Instance.new("Frame", bill);
			hpBg.Size = UDim2.new(1, -6, 0, 5);
			hpBg.Position = UDim2.new(0, 3, 0, 16);
			hpBg.BackgroundColor3 = Color3.new(0, 0, 0);
			Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3);
			FlatIdent_6D9D2 = 5;
		end
		if (FlatIdent_6D9D2 == 0) then
			plr = Players:GetPlayerFromCharacter(char);
			if (not plr or (plr == LocalPlayer)) then
				return;
			end
			removeESP(char);
			head = char:FindFirstChild("Head");
			hum = char:FindFirstChildOfClass("Humanoid");
			FlatIdent_6D9D2 = 1;
		end
		if (FlatIdent_6D9D2 == 2) then
			bill.StudsOffset = Vector3.new(0, 2.8, 0);
			bill.AlwaysOnTop = true;
			name = Instance.new("TextLabel", bill);
			name.Size = UDim2.new(1, 0, 0, 16);
			name.BackgroundTransparency = 1;
			FlatIdent_6D9D2 = 3;
		end
		if (FlatIdent_6D9D2 == 6) then
			hpText.Size = UDim2.new(1, 0, 1, 0);
			hpText.BackgroundTransparency = 1;
			hpText.TextColor3 = Color3.new(1, 1, 1);
			hpText.TextStrokeTransparency = 0;
			hpText.TextSize = 8;
			FlatIdent_6D9D2 = 7;
		end
		if (FlatIdent_6D9D2 == 8) then
			hl = Instance.new("Highlight", char);
			hl.Name = "AHMHighlight";
			hl.OutlineColor = Color3.fromRGB(255, 255, 0);
			hl.OutlineTransparency = 0;
			hl.FillTransparency = 1;
			break;
		end
		if (FlatIdent_6D9D2 == 3) then
			name.Text = ((plr.DisplayName ~= plr.Name) and (plr.DisplayName .. " (@" .. plr.Name .. ")")) or plr.Name;
			name.TextColor3 = Color3.new(1, 1, 1);
			name.TextStrokeTransparency = 0;
			name.Font = Enum.Font.SourceSansBold;
			name.TextSize = 14;
			FlatIdent_6D9D2 = 4;
		end
		if (FlatIdent_6D9D2 == 1) then
			if (not head or not hum or not IsAlive(char)) then
				return;
			end
			bill = Instance.new("BillboardGui", head);
			bill.Name = "AHMNameHP";
			bill.Adornee = head;
			bill.Size = UDim2.new(0, 160, 0, 35);
			FlatIdent_6D9D2 = 2;
		end
	end
end
local function onCharAdded(char)
	local FlatIdent_7E707 = 0;
	local plr;
	while true do
		if (FlatIdent_7E707 == 1) then
			task.delay(0.6, function()
				local FlatIdent_68856 = 0;
				while true do
					if (FlatIdent_68856 == 0) then
						removeESP(char);
						if espEnabledStatus then
							applyESP(char);
						end
						break;
					end
				end
			end);
			break;
		end
		if (FlatIdent_7E707 == 0) then
			plr = Players:GetPlayerFromCharacter(char);
			if (not plr or (plr == LocalPlayer)) then
				return;
			end
			FlatIdent_7E707 = 1;
		end
	end
end
for _, p in Players:GetPlayers() do
	if (p ~= LocalPlayer) then
		p.CharacterAdded:Connect(onCharAdded);
		if p.Character then
			onCharAdded(p.Character);
		end
	end
end
Players.PlayerAdded:Connect(function(p)
	if (p ~= LocalPlayer) then
		local FlatIdent_42BD8 = 0;
		while true do
			if (FlatIdent_42BD8 == 0) then
				p.CharacterAdded:Connect(onCharAdded);
				if p.Character then
					onCharAdded(p.Character);
				end
				break;
			end
		end
	end
end);
RunService.Heartbeat:Connect(function()
	if espEnabledStatus then
		for _, p in Players:GetPlayers() do
			if ((p ~= LocalPlayer) and p.Character) then
				local FlatIdent_28855 = 0;
				local head;
				while true do
					if (FlatIdent_28855 == 0) then
						head = p.Character:FindFirstChild("Head");
						if (head and not head:FindFirstChild("AHMNameHP")) then
							applyESP(p.Character);
						end
						break;
					end
				end
			end
		end
	end
end);
local function UpdateProtectedList()
	local FlatIdent_331F0 = 0;
	local count;
	while true do
		if (FlatIdent_331F0 == 1) then
			for _, p in Players:GetPlayers() do
				if (p ~= LocalPlayer) then
					local FlatIdent_7F3C8 = 0;
					local btn;
					local prot;
					while true do
						if (FlatIdent_7F3C8 == 3) then
							btn.TextScaled = true;
							Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6);
							FlatIdent_7F3C8 = 4;
						end
						if (1 == FlatIdent_7F3C8) then
							prot = ProtectedPlayers[p] or false;
							btn.BackgroundColor3 = (prot and Color3.fromRGB(0, 100, 255)) or Color3.fromRGB(60, 60, 60);
							FlatIdent_7F3C8 = 2;
						end
						if (FlatIdent_7F3C8 == 0) then
							btn = Instance.new("TextButton", PlayerListFrame);
							btn.Size = UDim2.new(1, -10, 0, 30);
							FlatIdent_7F3C8 = 1;
						end
						if (FlatIdent_7F3C8 == 4) then
							table.insert(PlayerButtons, btn);
							btn.MouseButton1Click:Connect(function()
								local FlatIdent_2593F = 0;
								while true do
									if (FlatIdent_2593F == 0) then
										ProtectedPlayers[p] = not ProtectedPlayers[p];
										UpdateProtectedList();
										break;
									end
								end
							end);
							break;
						end
						if (FlatIdent_7F3C8 == 2) then
							btn.Text = p.DisplayName .. " (@" .. p.Name .. ")" .. ((prot and " âœ”") or "");
							btn.TextColor3 = Color3.new(1, 1, 1);
							FlatIdent_7F3C8 = 3;
						end
					end
				end
			end
			count = 0;
			FlatIdent_331F0 = 2;
		end
		if (FlatIdent_331F0 == 0) then
			for _, b in PlayerButtons do
				b:Destroy();
			end
			PlayerButtons = {};
			FlatIdent_331F0 = 1;
		end
		if (FlatIdent_331F0 == 2) then
			for _ in pairs(ProtectedPlayers) do
				count = count + 1;
			end
			TitleLabel.Text = "âڑ، AHM HUB | Protected: " .. count .. " âڑ،";
			break;
		end
	end
end
Players.PlayerAdded:Connect(UpdateProtectedList);
Players.PlayerRemoving:Connect(UpdateProtectedList);
UpdateProtectedList();
local function GetTargetPart(char)
	local FlatIdent_3B08E = 0;
	local targetPartName;
	local part;
	while true do
		if (FlatIdent_3B08E == 0) then
			targetPartName = nil;
			if (forceMode == 2) then
				targetPartName = "Head";
			else
				local mode = AIM_MODES[1];
				if ((os.clock() - lastSwitchTime) >= currentSwitchTime) then
					local FlatIdent_956D = 0;
					while true do
						if (FlatIdent_956D == 1) then
							currentSwitchTime = switchTimes[currentAutoIndex];
							break;
						end
						if (FlatIdent_956D == 0) then
							lastSwitchTime = os.clock();
							currentAutoIndex = (currentAutoIndex % #mode.parts) + 1;
							FlatIdent_956D = 1;
						end
					end
				end
				targetPartName = mode.parts[currentAutoIndex];
			end
			FlatIdent_3B08E = 1;
		end
		if (FlatIdent_3B08E == 2) then
			if (forceMode == 2) then
				local FlatIdent_512FF = 0;
				while true do
					if (FlatIdent_512FF == 0) then
						AimPartToggle.Text = "Target: HEAD (ALT)";
						AimPartToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50);
						break;
					end
				end
			else
				local FlatIdent_829F9 = 0;
				local currentPart;
				while true do
					if (FlatIdent_829F9 == 0) then
						currentPart = ((currentAutoIndex == 1) and "HEAD") or "TORSO";
						AimPartToggle.Text = "Target: Auto Switch (" .. currentPart .. ") [SHIFT]";
						FlatIdent_829F9 = 1;
					end
					if (1 == FlatIdent_829F9) then
						AimPartToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 255);
						break;
					end
				end
			end
			return part or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart");
		end
		if (FlatIdent_3B08E == 1) then
			part = char:FindFirstChild(targetPartName);
			if not part then
				if (targetPartName == "RightUpperArm") then
					part = char:FindFirstChild("Right Arm");
				end
				if (targetPartName == "LeftUpperArm") then
					part = char:FindFirstChild("Left Arm");
				end
			end
			FlatIdent_3B08E = 2;
		end
	end
end
local function GetPredictedPosition(char)
	local FlatIdent_3ACCC = 0;
	local part;
	local root;
	local velocity;
	local speed;
	local direction;
	local myRoot;
	local distance;
	local leadMultiplier;
	local predictedPos;
	while true do
		if (FlatIdent_3ACCC == 6) then
			return predictedPos;
		end
		if (3 == FlatIdent_3ACCC) then
			if lastDirection then
				local FlatIdent_6DFD9 = 0;
				local dotProduct;
				while true do
					if (FlatIdent_6DFD9 == 0) then
						dotProduct = lastDirection:Dot(direction);
						if (dotProduct < -0.3) then
							aiLeadStrength = aiLeadStrength * 0.3;
						else
							aiLeadStrength = math.min(aiLeadStrength + 0.01, 0.7);
						end
						break;
					end
				end
			end
			lastDirection = direction;
			myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			FlatIdent_3ACCC = 4;
		end
		if (FlatIdent_3ACCC == 1) then
			if not root then
				return part.Position;
			end
			if not aiLeadEnabled then
				return part.Position;
			end
			velocity = root.Velocity;
			FlatIdent_3ACCC = 2;
		end
		if (2 == FlatIdent_3ACCC) then
			speed = velocity.Magnitude;
			if (speed < 5) then
				return part.Position;
			end
			direction = velocity.Unit;
			FlatIdent_3ACCC = 3;
		end
		if (FlatIdent_3ACCC == 4) then
			distance = 0;
			if myRoot then
				distance = (myRoot.Position - root.Position).Magnitude;
			end
			leadMultiplier = aiLeadStrength * 6;
			FlatIdent_3ACCC = 5;
		end
		if (FlatIdent_3ACCC == 0) then
			part = GetTargetPart(char);
			if not part then
				return nil;
			end
			root = char:FindFirstChild("HumanoidRootPart");
			FlatIdent_3ACCC = 1;
		end
		if (FlatIdent_3ACCC == 5) then
			if (distance > 150) then
				leadMultiplier = leadMultiplier * 1.8;
			elseif (distance > 300) then
				leadMultiplier = leadMultiplier * 2.5;
			end
			if (distance < 30) then
				leadMultiplier = leadMultiplier * 0.5;
			end
			predictedPos = part.Position + (direction * leadMultiplier * (speed / 25));
			FlatIdent_3ACCC = 6;
		end
	end
end
local function GetClosest()
	local closest, distMin = nil, math.huge;
	local center = Camera.ViewportSize / 2;
	for _, p in Players:GetPlayers() do
		if ((p ~= LocalPlayer) and not ProtectedPlayers[p] and p.Character and IsAlive(p.Character)) then
			local part = GetTargetPart(p.Character);
			if part then
				local predictedPos = GetPredictedPosition(p.Character) or part.Position;
				local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos);
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude;
					if ((dist < distMin) and (dist <= FOVRadius)) then
						if (not WallCheckEnabled or IsVisible(part)) then
							local FlatIdent_56F59 = 0;
							while true do
								if (FlatIdent_56F59 == 0) then
									distMin = dist;
									closest = p;
									break;
								end
							end
						end
					end
				end
			end
		end
	end
	return closest;
end
RunService.RenderStepped:Connect(function()
	local FlatIdent_3121 = 0;
	while true do
		if (FlatIdent_3121 == 1) then
			FOVCircle.Visible = AimbotOn and FOVCircleVisible and not FOVCircleForcedOff;
			if AimbotOn then
				local FlatIdent_51C44 = 0;
				local target;
				while true do
					if (FlatIdent_51C44 == 0) then
						target = GetClosest();
						if (target and target.Character) then
							local predictedPos = GetPredictedPosition(target.Character);
							if predictedPos then
								local FlatIdent_92514 = 0;
								local cf;
								while true do
									if (FlatIdent_92514 == 0) then
										cf = CFrame.new(Camera.CFrame.Position, predictedPos);
										Camera.CFrame = Camera.CFrame:Lerp(cf, AIM_SMOOTHNESS);
										break;
									end
								end
							end
						end
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_3121 == 0) then
			FOVCircle.Position = Camera.ViewportSize / 2;
			FOVCircle.Radius = FOVRadius;
			FlatIdent_3121 = 1;
		end
	end
end);
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return;
	end
	local currentTime = os.clock();
	if ((input.KeyCode == Enum.KeyCode.LeftShift) or (input.KeyCode == Enum.KeyCode.RightShift)) then
		if not smartMode then
			local FlatIdent_13B77 = 0;
			while true do
				if (0 == FlatIdent_13B77) then
					print("âڑ ï¸ڈ ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط± ظ…ظ‚ظپظ„! ط§ط¶ط؛ط· ط²ط± 'ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±' ظ„ظ„طھط´ط؛ظٹظ„");
					return;
				end
			end
		end
		if ((currentTime - lastModeSwitchTime) >= MODE_SWITCH_COOLDOWN) then
			local FlatIdent_94CF9 = 0;
			while true do
				if (FlatIdent_94CF9 == 0) then
					forceMode = 1;
					currentAutoIndex = 1;
					FlatIdent_94CF9 = 1;
				end
				if (FlatIdent_94CF9 == 1) then
					lastSwitchTime = os.clock();
					currentSwitchTime = switchTimes[1];
					FlatIdent_94CF9 = 2;
				end
				if (FlatIdent_94CF9 == 2) then
					lastModeSwitchTime = currentTime;
					print("ًں”„ AUTO SWITCH mode (Head â†” Torso)");
					break;
				end
			end
		else
			local FlatIdent_6C34 = 0;
			local remaining;
			while true do
				if (0 == FlatIdent_6C34) then
					remaining = math.ceil(MODE_SWITCH_COOLDOWN - (currentTime - lastModeSwitchTime));
					print("âڈ³ Cooldown! Wait " .. remaining .. " seconds before switching");
					break;
				end
			end
		end
	end
	if ((input.KeyCode == Enum.KeyCode.LeftAlt) or (input.KeyCode == Enum.KeyCode.RightAlt)) then
		local FlatIdent_14716 = 0;
		while true do
			if (0 == FlatIdent_14716) then
				if not smartMode then
					local FlatIdent_A446 = 0;
					while true do
						if (FlatIdent_A446 == 0) then
							print("âڑ ï¸ڈ ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط± ظ…ظ‚ظپظ„! ط§ط¶ط؛ط· ط²ط± 'ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±' ظ„ظ„طھط´ط؛ظٹظ„");
							return;
						end
					end
				end
				if ((currentTime - lastModeSwitchTime) >= MODE_SWITCH_COOLDOWN) then
					local FlatIdent_1454F = 0;
					while true do
						if (FlatIdent_1454F == 0) then
							forceMode = 2;
							lastModeSwitchTime = currentTime;
							FlatIdent_1454F = 1;
						end
						if (FlatIdent_1454F == 1) then
							print("ًں”´ HEAD mode");
							break;
						end
					end
				else
					local FlatIdent_37555 = 0;
					local remaining;
					while true do
						if (FlatIdent_37555 == 0) then
							remaining = math.ceil(MODE_SWITCH_COOLDOWN - (currentTime - lastModeSwitchTime));
							print("âڈ³ Cooldown! Wait " .. remaining .. " seconds before switching");
							break;
						end
					end
				end
				break;
			end
		end
	end
	if (input.KeyCode == Enum.KeyCode.G) then
		local FlatIdent_11AA1 = 0;
		while true do
			if (1 == FlatIdent_11AA1) then
				ToggleButton.Visible = not guiOpen;
				if guiOpen then
					UpdateProtectedList();
				end
				break;
			end
			if (FlatIdent_11AA1 == 0) then
				guiOpen = not guiOpen;
				MainFrame.Visible = guiOpen;
				FlatIdent_11AA1 = 1;
			end
		end
	end
	if (input.KeyCode == Enum.KeyCode.K) then
		FOVCircleForcedOff = not FOVCircleForcedOff;
		if FOVCircleToggle then
			if FOVCircleForcedOff then
				local FlatIdent_3501F = 0;
				while true do
					if (0 == FlatIdent_3501F) then
						FOVCircleToggle.BackgroundColor3 = Color3.fromRGB(150, 150, 150);
						FOVCircleToggle.Text = "FOV Circle: FORCED OFF (K)";
						break;
					end
				end
			else
				local FlatIdent_15F29 = 0;
				while true do
					if (FlatIdent_15F29 == 0) then
						FOVCircleToggle.BackgroundColor3 = (FOVCircleVisible and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(255, 0, 0);
						FOVCircleToggle.Text = "FOV Circle: " .. ((FOVCircleVisible and "ON") or "OFF");
						break;
					end
				end
			end
		end
	end
end);
SmartToggle.MouseButton1Click:Connect(function()
	local FlatIdent_2C980 = 0;
	while true do
		if (FlatIdent_2C980 == 0) then
			smartMode = not smartMode;
			if smartMode then
				local FlatIdent_58E6A = 0;
				while true do
					if (FlatIdent_58E6A == 1) then
						print("âœ… ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط± ظ…ظپط¹ظ„ - SHIFT ظˆ ALT ظٹط´طھط؛ظ„ظˆظ†");
						break;
					end
					if (FlatIdent_58E6A == 0) then
						SmartToggle.Text = "ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±: ON";
						SmartToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0);
						FlatIdent_58E6A = 1;
					end
				end
			else
				SmartToggle.Text = "ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±: OFF";
				SmartToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0);
				print("â‌Œ ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط± ظ…ظ‚ظپظ„ - ظˆط¶ط¹ ظٹط¯ظˆظٹ");
			end
			break;
		end
	end
end);
AILeadToggle.MouseButton1Click:Connect(function()
	aiLeadEnabled = not aiLeadEnabled;
	if aiLeadEnabled then
		AILeadToggle.Text = "طھط³ط¨ظٹظ‚: ON";
		AILeadToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0);
		print("ًں§  طھط³ط¨ظٹظ‚ ظ…ظپط¹ظ„");
	else
		local FlatIdent_84ED3 = 0;
		while true do
			if (0 == FlatIdent_84ED3) then
				AILeadToggle.Text = "طھط³ط¨ظٹظ‚: OFF";
				AILeadToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0);
				FlatIdent_84ED3 = 1;
			end
			if (FlatIdent_84ED3 == 1) then
				print("ًں§  طھط³ط¨ظٹظ‚ ظ…ظ‚ظپظ„");
				lastDirection = nil;
				break;
			end
		end
	end
end);
AILeadSlider.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local FlatIdent_7C57C = 0;
		local num;
		while true do
			if (FlatIdent_7C57C == 0) then
				num = tonumber(AILeadSlider.Text);
				if (num and (num >= 0) and (num <= 100)) then
					local FlatIdent_23B66 = 0;
					while true do
						if (FlatIdent_23B66 == 1) then
							print("ًںژ¯ ظ‚ظˆط© ط§ظ„طھط³ط¨ظٹظ‚: " .. num .. "%");
							break;
						end
						if (FlatIdent_23B66 == 0) then
							aiLeadStrength = num / 100;
							AILabel.Text = "ظ‚ظˆط© ط§ظ„طھط³ط¨ظٹظ‚: " .. num .. "%";
							FlatIdent_23B66 = 1;
						end
					end
				else
					AILeadSlider.Text = tostring(math.floor(aiLeadStrength * 100));
				end
				break;
			end
		end
	end
end);
ESPToggle.MouseButton1Click:Connect(function()
	local FlatIdent_30B1F = 0;
	while true do
		if (1 == FlatIdent_30B1F) then
			ESPToggle.BackgroundColor3 = (espEnabledStatus and CurrentTheme.ON) or CurrentTheme.OFF;
			for _, p in Players:GetPlayers() do
				if ((p ~= LocalPlayer) and p.Character) then
					if espEnabledStatus then
						applyESP(p.Character);
					else
						removeESP(p.Character);
					end
				end
			end
			break;
		end
		if (FlatIdent_30B1F == 0) then
			espEnabledStatus = not espEnabledStatus;
			ESPToggle.Text = "ESP: " .. ((espEnabledStatus and "ON") or "OFF");
			FlatIdent_30B1F = 1;
		end
	end
end);
AimbotToggle.MouseButton1Click:Connect(function()
	local FlatIdent_23521 = 0;
	while true do
		if (1 == FlatIdent_23521) then
			AimbotToggle.BackgroundColor3 = (AimbotOn and CurrentTheme.ON) or CurrentTheme.OFF;
			break;
		end
		if (FlatIdent_23521 == 0) then
			AimbotOn = not AimbotOn;
			AimbotToggle.Text = "Aimbot: " .. ((AimbotOn and "ON") or "OFF");
			FlatIdent_23521 = 1;
		end
	end
end);
AimPartToggle.MouseButton1Click:Connect(function()
	local FlatIdent_974E = 0;
	local currentTime;
	while true do
		if (FlatIdent_974E == 0) then
			if not smartMode then
				print("âڑ ï¸ڈ ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط± ظ…ظ‚ظپظ„! ظپط¹ظ‘ظ„ 'ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±' ط¹ط´ط§ظ† طھط؛ظٹط± ط§ظ„ظ‡ط¯ظپ");
				return;
			end
			currentTime = os.clock();
			FlatIdent_974E = 1;
		end
		if (FlatIdent_974E == 1) then
			if ((currentTime - lastModeSwitchTime) >= MODE_SWITCH_COOLDOWN) then
				if (forceMode == 1) then
					local FlatIdent_129E6 = 0;
					while true do
						if (0 == FlatIdent_129E6) then
							forceMode = 2;
							lastModeSwitchTime = currentTime;
							FlatIdent_129E6 = 1;
						end
						if (FlatIdent_129E6 == 1) then
							print("ًں”´ HEAD mode");
							break;
						end
					end
				else
					local FlatIdent_91A09 = 0;
					while true do
						if (FlatIdent_91A09 == 1) then
							lastSwitchTime = os.clock();
							currentSwitchTime = switchTimes[1];
							FlatIdent_91A09 = 2;
						end
						if (FlatIdent_91A09 == 0) then
							forceMode = 1;
							currentAutoIndex = 1;
							FlatIdent_91A09 = 1;
						end
						if (FlatIdent_91A09 == 2) then
							lastModeSwitchTime = currentTime;
							print("ًں”„ AUTO SWITCH mode");
							break;
						end
					end
				end
			else
				local remaining = math.ceil(MODE_SWITCH_COOLDOWN - (currentTime - lastModeSwitchTime));
				print("âڈ³ Cooldown! Wait " .. remaining .. " seconds before switching");
			end
			break;
		end
	end
end);
WallcheckToggle.MouseButton1Click:Connect(function()
	local FlatIdent_5C0FA = 0;
	while true do
		if (FlatIdent_5C0FA == 0) then
			WallCheckEnabled = not WallCheckEnabled;
			WallcheckToggle.Text = "Wallcheck: " .. ((WallCheckEnabled and "ON") or "OFF");
			FlatIdent_5C0FA = 1;
		end
		if (FlatIdent_5C0FA == 1) then
			WallcheckToggle.BackgroundColor3 = (WallCheckEnabled and CurrentTheme.ON) or CurrentTheme.OFF;
			break;
		end
	end
end);
FOVSlider.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local FlatIdent_86634 = 0;
		local num;
		while true do
			if (FlatIdent_86634 == 0) then
				num = tonumber(FOVSlider.Text:match("%d+"));
				if (num and (num >= 20) and (num <= 600)) then
					local FlatIdent_92569 = 0;
					while true do
						if (FlatIdent_92569 == 0) then
							FOVRadius = num;
							FOVCircle.Radius = num;
							FlatIdent_92569 = 1;
						end
						if (1 == FlatIdent_92569) then
							FOVSlider.Text = "FOV: " .. num;
							break;
						end
					end
				else
					FOVSlider.Text = "FOV: " .. FOVRadius;
				end
				break;
			end
		end
	end
end);
FOVCircleToggle.MouseButton1Click:Connect(function()
	local FlatIdent_8770C = 0;
	while true do
		if (FlatIdent_8770C == 1) then
			FOVCircleToggle.BackgroundColor3 = (FOVCircleVisible and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(255, 0, 0);
			break;
		end
		if (FlatIdent_8770C == 0) then
			FOVCircleVisible = not FOVCircleVisible;
			FOVCircleToggle.Text = "FOV Circle: " .. ((FOVCircleVisible and "ON") or "OFF");
			FlatIdent_8770C = 1;
		end
	end
end);
ESPInventoryToggle.MouseButton1Click:Connect(function()
	espInventoryEnabled = not espInventoryEnabled;
	ESPInventoryToggle.Text = "ESP Inventory: " .. ((espInventoryEnabled and "ON") or "OFF");
	ESPInventoryToggle.BackgroundColor3 = (espInventoryEnabled and CurrentTheme.ON) or CurrentTheme.OFF;
	for _, p in ipairs(Players:GetPlayers()) do
		updateESP(p);
	end
end);
local function makeDraggable(frame, dragArea)
	local FlatIdent_15C08 = 0;
	local dragging;
	local startPos;
	local startMouse;
	while true do
		if (FlatIdent_15C08 == 0) then
			dragging, startPos, startMouse = nil;
			dragArea.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1) then
					local FlatIdent_89C1C = 0;
					while true do
						if (FlatIdent_89C1C == 1) then
							startMouse = input.Position;
							break;
						end
						if (FlatIdent_89C1C == 0) then
							dragging = true;
							startPos = frame.Position;
							FlatIdent_89C1C = 1;
						end
					end
				end
			end);
			FlatIdent_15C08 = 1;
		end
		if (1 == FlatIdent_15C08) then
			dragArea.InputChanged:Connect(function(input)
				if (dragging and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
					local delta = input.Position - startMouse;
					frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
				end
			end);
			UserInputService.InputEnded:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1) then
					dragging = false;
				end
			end);
			break;
		end
	end
end
makeDraggable(MainFrame, MainDrag);
makeDraggable(ToggleButton, ToggleDrag);
ToggleButton.MouseButton1Click:Connect(function()
	guiOpen = not guiOpen;
	MainFrame.Visible = guiOpen;
	ToggleButton.Text = (guiOpen and "Close") or "Open";
	if guiOpen then
		UpdateProtectedList();
	end
end);
print("âœ… AHM Script Loaded Successfully!");
print("ًںژ® Controls:");
print("   SHIFT = AUTO SWITCH (Head 0.4s â†” Torso 0.5s)");
print("   ALT = HEAD mode");
print("   G = Open/Close GUI");
print("   K = Toggle FOV Circle");
print("   ًںڑ— CLUTCH Button in top center - Press for black screen effect");
print("   ًں‘پï¸ڈ ط¥ط®ظپط§ط، ط§ظ„ظ‚ظ„طھط´: OFF by default - Click to hide CLUTCH button");
print("   ًں§  طھط³ط¨ظٹظ‚: OFF by default - Press 'طھط³ط¨ظٹظ‚' button to enable");
print("   ًں“ٹ ظ‚ظˆط© ط§ظ„طھط³ط¨ظٹظ‚: 50% default - Lead strength multiplier: 6x");
print("   âڑ™ï¸ڈ ط§ظ„طھط¨ط¯ظٹظ„ ط¨ط§ظ„ط§ط²ط±ط§ط±: ON by default - SHIFT and ALT work");
ApplyTheme();
