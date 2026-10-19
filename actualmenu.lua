local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Disable collisions with other players only.
-- World/map collisions are left unchanged.

local originalPlayerCollisions = {}
local collisionConnections = {}
local collisionRefreshRunning = true

local function disableCharacterPlayerCollisions(target)
	if target == player or not target.Character then
		return
	end

	for _, part in ipairs(target.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			if originalPlayerCollisions[part] == nil then
				originalPlayerCollisions[part] = part.CanCollide
			end

			part.CanCollide = false
		end
	end
end

local function setupPlayerCollisionDisabling(target)
	if target == player then
		return
	end

	if collisionConnections[target] then
		collisionConnections[target]:Disconnect()
		collisionConnections[target] = nil
	end

	disableCharacterPlayerCollisions(target)

	collisionConnections[target] = target.CharacterAdded:Connect(function(character)
		task.wait(0.2)

		if target.Parent ~= Players then
			return
		end

		disableCharacterPlayerCollisions(target)

		character.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				if originalPlayerCollisions[part] == nil then
					originalPlayerCollisions[part] = part.CanCollide
				end

				part.CanCollide = false
			end
		end)
	end)

	if target.Character then
		target.Character.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				if originalPlayerCollisions[part] == nil then
					originalPlayerCollisions[part] = part.CanCollide
				end

				part.CanCollide = false
			end
		end)
	end
end

for _, target in ipairs(Players:GetPlayers()) do
	setupPlayerCollisionDisabling(target)
end

Players.PlayerAdded:Connect(setupPlayerCollisionDisabling)

Players.PlayerRemoving:Connect(function(target)
	if collisionConnections[target] then
		collisionConnections[target]:Disconnect()
		collisionConnections[target] = nil
	end
end)

-- Keep collisions disabled if another script changes CanCollide.
task.spawn(function()
	while collisionRefreshRunning and player.Parent do
		for _, target in ipairs(Players:GetPlayers()) do
			if target ~= player then
				disableCharacterPlayerCollisions(target)
			end
		end

		task.wait(0.5)
	end
end)

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("ZorinCrashPanel")

if oldGui then
	oldGui:Destroy()
end

local selected = {}
local loopGotoActive = false
local annoyActive = false
local goofActive = false
local strongGoofActive = false
local strongGoofV2Active = false
local strongGoofV3Active = false
local strongGoofV4Active = false
local strongGoofV5Active = false
local strongGoofV6Active = false
local selectAll = false
local angle = 0
local spinSpeed = 200
local heightStep = 0
local loopGotoToken = 0
local annoyToken = 0
local goofToken = 0
local strongGoofToken = 0
local strongGoofV2Token = 0
local strongGoofV3Token = 0
local strongGoofV4Token = 0
local strongGoofV5Token = 0
local strongGoofV6Token = 0
local annoyTween = nil
local kamehamehaActive = false
local kamehamehaToken = 0

local gui = Instance.new("ScreenGui")
gui.Name = "ZorinCrashPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(320, 640)
main.Position = UDim2.new(0.5, -160, 0.5, -295)
main.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(0, 120, 255)
outline.Thickness = 1
outline.Parent = main

local contentScale = Instance.new("UIScale")
contentScale.Scale = 0.7
contentScale.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -70, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(12, 18, 35)
title.Text = "ADMIN | ANNOY PANEL"
title.TextColor3 = Color3.fromRGB(80, 170, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

local function makeTopButton(text, x)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(30, 30)
	button.Position = UDim2.new(1, x, 0, 2)
	button.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	button.BorderColor3 = Color3.fromRGB(0, 90, 220)
	button.TextColor3 = Color3.fromRGB(80, 170, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 20
	button.Text = text
	button.Parent = main
	return button
end

local minusButton = makeTopButton("−", -66)
local plusButton = makeTopButton("+", -34)

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Position = UDim2.fromOffset(10, 45)
playerList.Size = UDim2.new(1, -20, 0, 190)
playerList.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 5
playerList.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
playerList.CanvasSize = UDim2.new()
playerList.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = playerList

local function makeButton(text, position, size)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	button.BorderColor3 = Color3.fromRGB(0, 90, 220)
	button.TextColor3 = Color3.fromRGB(230, 235, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 12
	button.Text = text
	button.Parent = main
	return button
end

local selectAllButton = makeButton(
	"SELECT ALL",
	UDim2.fromOffset(48, 245),
	UDim2.new(1, -96, 0, 28)
)

local previousPageButton = makeButton(
	"◀",
	UDim2.fromOffset(10, 245),
	UDim2.fromOffset(30, 28)
)
previousPageButton.TextSize = 16

local nextPageButton = makeButton(
	"▶",
	UDim2.new(1, -40, 0, 245),
	UDim2.fromOffset(30, 28)
)
nextPageButton.TextSize = 16

local leftX = 10
local rightX = 165
local buttonWidth = 145
local buttonHeight = 32

local function makePairButton(text, x, y)
	return makeButton(
		text,
		UDim2.fromOffset(x, y),
		UDim2.fromOffset(buttonWidth, buttonHeight)
	)
end

local loopGotoButton = makePairButton("Loop goto", leftX, 280)
local stopLoopGotoButton = makePairButton("Stop loopgoto", rightX, 280)

local annoyButton = makePairButton("Annoy", leftX, 318)
local stopAnnoyingButton = makePairButton("Stop Annoy", rightX, 318)

local kamehamehaButton = makePairButton("Accel Fling", leftX, 356)
local stopKamehamehaButton = makePairButton("Cancel accel", rightX, 356)

local goofButton = makePairButton("Fling v1", leftX, 356)
local ungoofButton = makePairButton("Stop Fling v1", rightX, 356)

local strongGoofNapButton = makePairButton("Fling v2", leftX, 394)
local stopStrongGoofNapButton = makePairButton("Stop Fling v2", rightX, 394)

local strongGoofV2Button = makePairButton("Fling v3", leftX, 432)
local stopStrongGoofV2Button = makePairButton("Stop Fling v3", rightX, 432)

local strongGoofV3Button = makePairButton("Fling v4", leftX, 470)
local stopStrongGoofV3Button = makePairButton("Stop Fling v4", rightX, 470)

local strongGoofV4Button = makePairButton("Fling v5", leftX, 508)
local stopStrongGoofV4Button = makePairButton("Stop Fling v5", rightX, 508)

local strongGoofV5Button = makePairButton("Fling v6", leftX, 546)
local stopStrongGoofV5Button = makePairButton("Stop Fling v6", rightX, 546)

local strongGoofV6Button = makePairButton("Fling v7", leftX, 508)
local stopStrongGoofV6Button = makePairButton("Stop Fling v7", rightX, 508)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 590)
status.Size = UDim2.new(1, -20, 0, 25)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(80, 170, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = main

local currentPage = 1

local function setPage(page)
	currentPage = math.clamp(page, 1, 2)
	local isModsPage = currentPage == 1

	title.Text = isModsPage and "ADMIN | MODS (1/2)" or "ADMIN | MORE MODS (2/2)"

	previousPageButton.Visible = currentPage > 1
	nextPageButton.Visible = currentPage < 2

	loopGotoButton.Visible = isModsPage
	stopLoopGotoButton.Visible = isModsPage
	annoyButton.Visible = isModsPage
	stopAnnoyingButton.Visible = isModsPage
	kamehamehaButton.Visible = isModsPage
	stopKamehamehaButton.Visible = isModsPage

	goofButton.Visible = not isModsPage
	ungoofButton.Visible = not isModsPage
	strongGoofNapButton.Visible = not isModsPage
	stopStrongGoofNapButton.Visible = not isModsPage
	strongGoofV2Button.Visible = not isModsPage
	stopStrongGoofV2Button.Visible = not isModsPage
	strongGoofV3Button.Visible = not isModsPage
	stopStrongGoofV3Button.Visible = not isModsPage
	strongGoofV4Button.Visible = not isModsPage
	stopStrongGoofV4Button.Visible = not isModsPage
	strongGoofV5Button.Visible = not isModsPage
	stopStrongGoofV5Button.Visible = not isModsPage
	strongGoofV6Button.Visible = not isModsPage
	stopStrongGoofV6Button.Visible = not isModsPage

	if isModsPage then
		loopGotoButton.Position = UDim2.fromOffset(leftX, 280)
		stopLoopGotoButton.Position = UDim2.fromOffset(rightX, 280)
		annoyButton.Position = UDim2.fromOffset(leftX, 318)
		stopAnnoyingButton.Position = UDim2.fromOffset(rightX, 318)
		kamehamehaButton.Position = UDim2.fromOffset(leftX, 356)
		stopKamehamehaButton.Position = UDim2.fromOffset(rightX, 356)
	else
		goofButton.Position = UDim2.fromOffset(leftX, 280)
		ungoofButton.Position = UDim2.fromOffset(rightX, 280)
		strongGoofNapButton.Position = UDim2.fromOffset(leftX, 318)
		stopStrongGoofNapButton.Position = UDim2.fromOffset(rightX, 318)
		strongGoofV2Button.Position = UDim2.fromOffset(leftX, 356)
		stopStrongGoofV2Button.Position = UDim2.fromOffset(rightX, 356)
		strongGoofV3Button.Position = UDim2.fromOffset(leftX, 394)
		stopStrongGoofV3Button.Position = UDim2.fromOffset(rightX, 394)
		strongGoofV4Button.Position = UDim2.fromOffset(leftX, 432)
		stopStrongGoofV4Button.Position = UDim2.fromOffset(rightX, 432)
		strongGoofV5Button.Position = UDim2.fromOffset(leftX, 470)
		stopStrongGoofV5Button.Position = UDim2.fromOffset(rightX, 470)
		strongGoofV6Button.Position = UDim2.fromOffset(leftX, 508)
		stopStrongGoofV6Button.Position = UDim2.fromOffset(rightX, 508)
	end
end

previousPageButton.MouseButton1Click:Connect(function()
	setPage(currentPage - 1)
end)

nextPageButton.MouseButton1Click:Connect(function()
	setPage(currentPage + 1)
end)

local dragButton = makeButton(
	"Drag incase you cant reach the top",
	UDim2.new(0, 10, 1, -25),
	UDim2.new(1, -20, 0, 30)
)
dragButton.ZIndex = 5

local scale = 0.7
local minScale = 0.45
local maxScale = 1.5

local function updateScale(direction)
	scale = math.clamp(scale + direction * 0.1, minScale, maxScale)
	contentScale.Scale = scale
end

minusButton.MouseButton1Click:Connect(function()
	updateScale(-1)
end)

plusButton.MouseButton1Click:Connect(function()
	updateScale(1)
end)

local dragging = false
local dragStart
local startPosition
local dragInput

local function beginDrag(input)
	dragging = true
	dragStart = input.Position
	startPosition = main.Position
	dragInput = input

	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End
			or input.UserInputState == Enum.UserInputState.Cancel then
			dragging = false
			dragInput = nil
		end
	end)
end

title.Active = true

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		beginDrag(input)
	end
end)

dragButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		beginDrag(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
			or input == dragInput
		) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
		dragInput = nil
	end
end)

local function getRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function resetSpin()
	local root = getRoot(player.Character)
	if root then
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

local function getSelectedPlayers()
	local targets = {}

	for target in pairs(selected) do
		if target ~= player and target.Parent == Players then
			table.insert(targets, target)
		end
	end

	table.sort(targets, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	return targets
end

local refreshingPlayerList = false

local function refreshPlayerList()
	if refreshingPlayerList then return end
	refreshingPlayerList = true

	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local isSelected = selected[target] == true
			local button = Instance.new("TextButton")

			button.Name = "Player_" .. target.UserId
			button.Size = UDim2.new(1, -6, 0, 28)
			button.BackgroundColor3 = isSelected
				and Color3.fromRGB(0, 70, 160)
				or Color3.fromRGB(30, 35, 50)
			button.BorderSizePixel = 0
			button.TextColor3 = Color3.fromRGB(230, 235, 255)
			button.Font = Enum.Font.Gotham
			button.TextSize = 12
			button.Text = (isSelected and "[X] " or "[ ] ") .. target.DisplayName
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.Parent = playerList

			button.MouseButton1Click:Connect(function()
				if selected[target] then
					selected[target] = nil
				else
					selected[target] = true
				end

				local nowSelected = selected[target] == true
				button.BackgroundColor3 = nowSelected
					and Color3.fromRGB(0, 70, 160)
					or Color3.fromRGB(30, 35, 50)
				button.Text = (nowSelected and "[X] " or "[ ] ") .. target.DisplayName
			end)
		end
	end

	playerList.CanvasSize = UDim2.new(
		0, 0, 0,
		listLayout.AbsoluteContentSize.Y + 5
	)

	refreshingPlayerList = false
end

selectAllButton.MouseButton1Click:Connect(function()
	selectAll = not selectAll

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			selected[target] = selectAll and true or nil
		end
	end

	selectAllButton.Text = selectAll and "DESELECT ALL" or "SELECT ALL"
	refreshPlayerList()
end)

Players.PlayerAdded:Connect(refreshPlayerList)

Players.PlayerRemoving:Connect(function(target)
	selected[target] = nil
	refreshPlayerList()
end)

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	resetSpin()
end)

local function startLoopGoto()
	if loopGotoActive then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	loopGotoActive = true
	loopGotoToken += 1
	local token = loopGotoToken
	status.Text = "Status: Loop Goto running"

	task.spawn(function()
		while loopGotoActive and token == loopGotoToken and gui.Parent do
			local root = getRoot(player.Character)

			if root then
				for _, target in ipairs(getSelectedPlayers()) do
					if not loopGotoActive or token ~= loopGotoToken then break end

					local targetRoot = getRoot(target.Character)

					if targetRoot then
						root.CFrame = targetRoot.CFrame
						task.wait(0.05)
					end
				end
			end

			RunService.Heartbeat:Wait()
		end
	end)
end

local function stopLoopGoto()
	loopGotoActive = false
	loopGotoToken += 1
	status.Text = "Status: Loop Goto stopped"
end

local function isTouchingTarget(character, targetCharacter)
	if not character or not targetCharacter then return false end

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			for _, touchingPart in ipairs(part:GetTouchingParts()) do
				if touchingPart:IsDescendantOf(targetCharacter) then
					return true
				end
			end
		end
	end

	return false
end

local function startAnnoy()
	if annoyActive then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	annoyActive = true
	annoyToken += 1
	local token = annoyToken
	status.Text = "Status: Annoy running"

	task.spawn(function()
		while annoyActive and token == annoyToken and gui.Parent do
			local root = getRoot(player.Character)

			if root then
				for _, target in ipairs(getSelectedPlayers()) do
					if not annoyActive or token ~= annoyToken then break end

					local targetRoot = getRoot(target.Character)

					if targetRoot then
						if isTouchingTarget(player.Character, target.Character) then
							angle += math.rad(120)
						else
							angle += math.rad(spinSpeed)
						end

						heightStep += 1

						local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}
						local orbitDistance = strongGoofV2Active and 2 or 5

						local verticalOffset =
							heightPattern[((heightStep - 1) % #heightPattern) + 1]

						local offset = Vector3.new(
							math.cos(angle) * orbitDistance,
							verticalOffset,
							math.sin(angle) * orbitDistance
						)

						local destination = targetRoot.Position + offset

						if annoyTween then
							annoyTween:Cancel()
							annoyTween = nil
						end

						annoyTween = TweenService:Create(
							root,
							TweenInfo.new(
								0.03,
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out
							),
							{CFrame = CFrame.new(destination, targetRoot.Position)}
						)

						annoyTween:Play()
						annoyTween.Completed:Wait()
						annoyTween = nil

						if not annoyActive or token ~= annoyToken then break end
						task.wait()
					end
				end
			end

			RunService.Heartbeat:Wait()
		end
	end)
end

local function stopAnnoy()
	annoyActive = false
	annoyToken += 1

	if annoyTween then
		annoyTween:Cancel()
		annoyTween = nil
	end

	status.Text = "Status: Annoy stopped"
end

local function startGoof()
	if goofActive then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	goofActive = true
	goofToken += 1
	local token = goofToken
	status.Text = "Status: Fling v1 enabled"

	startLoopGoto()
	startAnnoy()

	task.spawn(function()
		while goofActive and token == goofToken and gui.Parent do
			local root = getRoot(player.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 200, 0)
			end

			RunService.Heartbeat:Wait()
		end

		if not strongGoofActive
			and not strongGoofV2Active
			and not strongGoofV3Active
			and not strongGoofV4Active
			and not strongGoofV5Active
			and not strongGoofV6Active then
			resetSpin()
		end
	end)
end

local function stopGoof()
	goofActive = false
	goofToken += 1

	if not strongGoofActive
		and not strongGoofV2Active
		and not strongGoofV3Active
		and not strongGoofV4Active
		and not strongGoofV5Active
			and not strongGoofV6Active then
		resetSpin()
	end

	status.Text = "Status: Fling v1 disabled"
end

local function startStrongGoofNap()
	if strongGoofActive then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	strongGoofActive = true
	strongGoofToken += 1
	local token = strongGoofToken
	local targetIndex = 1
	local targetSwitchCounter = 0
	local moveAngle = 0
	local heightIndex = 1
	local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}

	status.Text = "Status: Fling v2 enabled"

	task.spawn(function()
		while strongGoofActive and token == strongGoofToken and gui.Parent do
			local root = getRoot(player.Character)
			local targets = getSelectedPlayers()

			if #targets > 0 then
				targetIndex = math.clamp(targetIndex, 1, #targets)
				targetSwitchCounter += 1

				if targetSwitchCounter >= 30 then
					targetSwitchCounter = 0
					targetIndex = (targetIndex % #targets) + 1
				end
			end

			local target = targets[targetIndex]
			local targetRoot = target and getRoot(target.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 400, 0)
			end

			if root and targetRoot then
				moveAngle += math.rad(25)

				local height = heightPattern[heightIndex]
				heightIndex = (heightIndex % #heightPattern) + 1

				local offset = Vector3.new(
					math.cos(moveAngle) * 5,
					height,
					math.sin(moveAngle) * 5
				)

				root.CFrame = CFrame.new(
					targetRoot.Position + offset,
					targetRoot.Position
				)
			end

			RunService.Heartbeat:Wait()
		end

		if not goofActive
			and not strongGoofV2Active
			and not strongGoofV3Active
			and not strongGoofV4Active
			and not strongGoofV5Active
			and not strongGoofV6Active then
			resetSpin()
		end
	end)
end

local function stopStrongGoofNap()
	strongGoofActive = false
	strongGoofToken += 1

	if not goofActive
		and not strongGoofV2Active
		and not strongGoofV3Active
		and not strongGoofV4Active
		and not strongGoofV5Active
			and not strongGoofV6Active then
		resetSpin()
	end

	status.Text = "Status: Fling v2 disabled"
end

local function startStrongGoofV2()
	if strongGoofV2Active then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	strongGoofV2Active = true
	strongGoofV2Token += 1
	local token = strongGoofV2Token
	local targetIndex = 1
	local targetSwitchCounter = 0
	local moveAngle = 0
	local heightIndex = 1
	local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}

	status.Text = "Status: Fling v3 enabled"

	task.spawn(function()
		while strongGoofV2Active and token == strongGoofV2Token and gui.Parent do
			local root = getRoot(player.Character)
			local targets = getSelectedPlayers()

			if #targets > 0 then
				targetIndex = math.clamp(targetIndex, 1, #targets)
				targetSwitchCounter += 1

				if targetSwitchCounter >= 30 then
					targetSwitchCounter = 0
					targetIndex = (targetIndex % #targets) + 1
				end
			end

			local target = targets[targetIndex]
			local targetRoot = target and getRoot(target.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 600, 0)
			end

			if root and targetRoot then
				moveAngle += math.rad(35)

				local height = heightPattern[heightIndex]
				heightIndex = (heightIndex % #heightPattern) + 1

				local offset = Vector3.new(
					math.cos(moveAngle) * 2,
					height,
					math.sin(moveAngle) * 2
				)

				root.CFrame = CFrame.new(
					targetRoot.Position + offset,
					targetRoot.Position
				)
			end

			RunService.Heartbeat:Wait()
		end

		if not goofActive
			and not strongGoofActive
			and not strongGoofV3Active
			and not strongGoofV4Active
			and not strongGoofV5Active
			and not strongGoofV6Active then
			resetSpin()
		end
	end)
end

local function stopStrongGoofV2()
	strongGoofV2Active = false
	strongGoofV2Token += 1

	if not goofActive
		and not strongGoofActive
		and not strongGoofV3Active
		and not strongGoofV4Active
		and not strongGoofV5Active
			and not strongGoofV6Active then
		resetSpin()
	end

	status.Text = "Status: Fling v3 disabled"
end

local function startStrongGoofV3()
	if strongGoofV3Active then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	strongGoofV3Active = true
	strongGoofV3Token += 1
	local token = strongGoofV3Token
	local v3Angle = 0
	local heightIndex = 1
	local targetIndex = 1
	local targetSwitchCounter = 0
	local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}

	status.Text = "Status: Fling v4 enabled"

	task.spawn(function()
		while strongGoofV3Active and token == strongGoofV3Token and gui.Parent do
			local root = getRoot(player.Character)
			local targets = getSelectedPlayers()

			if #targets > 0 then
				targetIndex = math.clamp(targetIndex, 1, #targets)
				targetSwitchCounter += 1

				if targetSwitchCounter >= 30 then
					targetSwitchCounter = 0
					targetIndex = (targetIndex % #targets) + 1
				end
			end

			local target = targets[targetIndex]
			local targetRoot = target and getRoot(target.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 1300, 0)
			end

			if root and targetRoot then
				v3Angle += math.rad(45)

				local height = heightPattern[heightIndex]
				heightIndex = (heightIndex % #heightPattern) + 1

				local offset = Vector3.new(
					math.cos(v3Angle) * 2,
					height,
					math.sin(v3Angle) * 2
				)

				root.CFrame = CFrame.new(
					targetRoot.Position + offset,
					targetRoot.Position
				)
			end

			RunService.Heartbeat:Wait()
		end

		if not goofActive
			and not strongGoofActive
			and not strongGoofV2Active
			and not strongGoofV4Active
			and not strongGoofV5Active
			and not strongGoofV6Active then
			resetSpin()
		end
	end)
end

local function stopStrongGoofV3()
	strongGoofV3Active = false
	strongGoofV3Token += 1

	if not goofActive
		and not strongGoofActive
		and not strongGoofV2Active
		and not strongGoofV4Active
		and not strongGoofV5Active
			and not strongGoofV6Active then
		resetSpin()
	end

	status.Text = "Status: Fling v4 disabled"
end

local function startStrongGoofV4()
	if strongGoofV4Active then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	strongGoofV4Active = true
	strongGoofV4Token += 1
	local token = strongGoofV4Token
	local v4Angle = 0
	local heightIndex = 1
	local targetIndex = 1
	local targetSwitchCounter = 0
	local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}

	status.Text = "Status: Fling v5 enabled"

	task.spawn(function()
		while strongGoofV4Active and token == strongGoofV4Token and gui.Parent do
			local root = getRoot(player.Character)
			local targets = getSelectedPlayers()

			if #targets > 0 then
				targetIndex = math.clamp(targetIndex, 1, #targets)
				targetSwitchCounter += 1

				if targetSwitchCounter >= 30 then
					targetSwitchCounter = 0
					targetIndex = (targetIndex % #targets) + 1
				end
			end

			local target = targets[targetIndex]
			local targetRoot = target and getRoot(target.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 5400, 0)
			end

			if root and targetRoot then
				v4Angle += math.rad(45)

				local height = heightPattern[heightIndex]
				heightIndex = (heightIndex % #heightPattern) + 1

				local offset = Vector3.new(
					math.cos(v4Angle) * 2,
					height,
					math.sin(v4Angle) * 2
				)

				root.CFrame = CFrame.new(
					targetRoot.Position + offset,
					targetRoot.Position
				)
			end

			RunService.Heartbeat:Wait()
		end

		if not goofActive
			and not strongGoofActive
			and not strongGoofV2Active
			and not strongGoofV3Active
			and not strongGoofV5Active
			and not strongGoofV6Active then
			resetSpin()
		end
	end)
end

local function stopStrongGoofV4()
	strongGoofV4Active = false
	strongGoofV4Token += 1

	if not goofActive
		and not strongGoofActive
		and not strongGoofV2Active
		and not strongGoofV3Active
		and not strongGoofV5Active
			and not strongGoofV6Active then
		resetSpin()
	end

	status.Text = "Status: Fling v5 disabled"
end

local function startStrongGoofV5()
	if strongGoofV5Active then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	strongGoofV5Active = true
	strongGoofV5Token += 1
	local token = strongGoofV5Token
	local v5Angle = 0
	local heightIndex = 1
	local targetIndex = 1
	local targetSwitchCounter = 0
	local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}

	status.Text = "Status: Fling v6 enabled"

	task.spawn(function()
		while strongGoofV5Active and token == strongGoofV5Token and gui.Parent do
			local root = getRoot(player.Character)
			local targets = getSelectedPlayers()

			if #targets > 0 then
				targetIndex = math.clamp(targetIndex, 1, #targets)
				targetSwitchCounter += 1

				if targetSwitchCounter >= 30 then
					targetSwitchCounter = 0
					targetIndex = (targetIndex % #targets) + 1
				end
			end

			local target = targets[targetIndex]
			local targetRoot = target and getRoot(target.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 10000, 0)
			end

			if root and targetRoot then
				v5Angle += math.rad(45)

				local height = heightPattern[heightIndex]
				heightIndex = (heightIndex % #heightPattern) + 1

				local offset = Vector3.new(
					math.cos(v5Angle) * 2,
					height,
					math.sin(v5Angle) * 2
				)

				root.CFrame = CFrame.new(
					targetRoot.Position + offset,
					targetRoot.Position
				)
			end

			RunService.Heartbeat:Wait()
		end

		if not goofActive
			and not strongGoofActive
			and not strongGoofV2Active
			and not strongGoofV3Active
			and not strongGoofV4Active then
			resetSpin()
		end
	end)
end

local function stopStrongGoofV5()
	strongGoofV5Active = false
	strongGoofV5Token += 1

	if not goofActive
		and not strongGoofActive
		and not strongGoofV2Active
		and not strongGoofV3Active
		and not strongGoofV4Active then
		resetSpin()
	end

	status.Text = "Status: Fling v6 disabled"
end

local function startStrongGoofV6()
	if strongGoofV6Active then return end

	if #getSelectedPlayers() == 0 then
		status.Text = "Status: Select players first"
		return
	end

	strongGoofV6Active = true
	strongGoofV6Token += 1
	local token = strongGoofV6Token
	local v7Angle = 0
	local heightIndex = 1
	local targetIndex = 1
	local targetSwitchCounter = 0
	local heightPattern = {0, 3, -3, 5, -5, 2, -2, 0}

	status.Text = "Status: Fling v7 enabled"

	task.spawn(function()
		while strongGoofV6Active and token == strongGoofV6Token and gui.Parent do
			local root = getRoot(player.Character)
			local targets = getSelectedPlayers()

			if #targets > 0 then
				targetIndex = math.clamp(targetIndex, 1, #targets)
				targetSwitchCounter += 1

				if targetSwitchCounter >= 30 then
					targetSwitchCounter = 0
					targetIndex = (targetIndex % #targets) + 1
				end
			end

			local target = targets[targetIndex]
			local targetRoot = target and getRoot(target.Character)

			if root then
				root.AssemblyAngularVelocity = Vector3.new(0, 10480, 0)
			end

			if root and targetRoot then
				v7Angle += math.rad(45)

				local height = heightPattern[heightIndex]
				heightIndex = (heightIndex % #heightPattern) + 1

				local offset = Vector3.new(
					math.cos(v7Angle) * 2,
					height,
					math.sin(v7Angle) * 2
				)

				root.CFrame = CFrame.new(
					targetRoot.Position + offset,
					targetRoot.Position
				)
			end

			RunService.Heartbeat:Wait()
		end

		if not goofActive
			and not strongGoofActive
			and not strongGoofV2Active
			and not strongGoofV3Active
			and not strongGoofV4Active
			and not strongGoofV5Active
			and not strongGoofV6Active then
			resetSpin()
		end
	end)
end

local function stopStrongGoofV6()
	strongGoofV6Active = false
	strongGoofV6Token += 1

	if not goofActive
		and not strongGoofActive
		and not strongGoofV2Active
		and not strongGoofV3Active
		and not strongGoofV4Active
		and not strongGoofV5Active
			and not strongGoofV6Active then
		resetSpin()
	end

	status.Text = "Status: Fling v7 disabled"
end

local function stopKamehameha()
	kamehamehaActive = false
	kamehamehaToken += 1
	resetSpin()
	status.Text = "Status: Accel stopped"
end

local function startKamehameha()
	if kamehamehaActive then return end

	local targets = getSelectedPlayers()

	if #targets == 0 then
		status.Text = "Status: Select a player first"
		return
	end

	local target = targets[1]
	local character = player.Character
	local root = getRoot(character)
	local targetRoot = getRoot(target.Character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not root or not targetRoot then
		status.Text = "Status: Character unavailable"
		return
	end

	kamehamehaActive = true
	kamehamehaToken += 1
	local token = kamehamehaToken
	local oldWalkSpeed = humanoid and humanoid.WalkSpeed
	local oldJumpPower = humanoid and humanoid.JumpPower
	local oldAutoRotate = humanoid and humanoid.AutoRotate
	local fixedPosition

	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false
	end

	task.spawn(function()
		local success, err = pcall(function()
			status.Text = "Status: Accel launching"

			root = getRoot(player.Character)
			targetRoot = getRoot(target.Character)

			if not root or not targetRoot then return end

			local awayDirection = root.Position - targetRoot.Position

			if awayDirection.Magnitude < 0.01 then
				awayDirection = Vector3.new(1, 0, 0)
			else
				awayDirection = awayDirection.Unit
			end

			fixedPosition = targetRoot.Position + awayDirection * 900
			root.CFrame = CFrame.new(fixedPosition)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.new(0, 5000, 0)

			status.Text = "Status: Frozen and spinning"

			local spinStart = os.clock()
			local spinAngle = 0

			while os.clock() - spinStart < 10
				and kamehamehaActive
				and token == kamehamehaToken do
				root = getRoot(player.Character)

				if not root then break end

				local dt = RunService.Heartbeat:Wait()
				spinAngle += 5000 * dt

				root.CFrame = CFrame.new(fixedPosition)
					* CFrame.Angles(0, spinAngle, 0)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.new(0, 5000, 0)
			end

			if not kamehamehaActive or token ~= kamehamehaToken then return end

			status.Text = "Status: LoopGoto"

			for i = 1, 90 do
				if not kamehamehaActive or token ~= kamehamehaToken then
					break
				end

				root = getRoot(player.Character)
				targetRoot = getRoot(target.Character)

				if not root or not targetRoot then
					break
				end

				local dt = RunService.Heartbeat:Wait()
				spinAngle += 5000 * dt

				root = getRoot(player.Character)
				targetRoot = getRoot(target.Character)

				if not root or not targetRoot then
					break
				end

				root.CFrame = targetRoot.CFrame
					* CFrame.Angles(0, spinAngle, 0)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.new(0, 5000, 0)
			end
		end)

		root = getRoot(player.Character)

		if root then
			root.AssemblyAngularVelocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
		end

		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = oldWalkSpeed or 16
			humanoid.JumpPower = oldJumpPower or 50

			if oldAutoRotate ~= nil then
				humanoid.AutoRotate = oldAutoRotate
			else
				humanoid.AutoRotate = true
			end
		end

		resetSpin()

		if token == kamehamehaToken then
			kamehamehaActive = false
			status.Text = success
				and "Status: Accel Fling finished"
				or "Status: Accel Fling error"
		end

		if not success then
			warn("Kamehameha error:", err)
		end
	end)
end

loopGotoButton.MouseButton1Click:Connect(startLoopGoto)
stopLoopGotoButton.MouseButton1Click:Connect(stopLoopGoto)
annoyButton.MouseButton1Click:Connect(startAnnoy)
stopAnnoyingButton.MouseButton1Click:Connect(stopAnnoy)
goofButton.MouseButton1Click:Connect(startGoof)
ungoofButton.MouseButton1Click:Connect(stopGoof)
strongGoofNapButton.MouseButton1Click:Connect(startStrongGoofNap)
stopStrongGoofNapButton.MouseButton1Click:Connect(stopStrongGoofNap)
strongGoofV2Button.MouseButton1Click:Connect(startStrongGoofV2)
stopStrongGoofV2Button.MouseButton1Click:Connect(stopStrongGoofV2)
strongGoofV3Button.MouseButton1Click:Connect(startStrongGoofV3)
stopStrongGoofV3Button.MouseButton1Click:Connect(stopStrongGoofV3)
strongGoofV4Button.MouseButton1Click:Connect(startStrongGoofV4)
stopStrongGoofV4Button.MouseButton1Click:Connect(stopStrongGoofV4)
strongGoofV5Button.MouseButton1Click:Connect(startStrongGoofV5)
stopStrongGoofV5Button.MouseButton1Click:Connect(stopStrongGoofV5)
strongGoofV6Button.MouseButton1Click:Connect(startStrongGoofV6)
stopStrongGoofV6Button.MouseButton1Click:Connect(stopStrongGoofV6)
kamehamehaButton.MouseButton1Click:Connect(startKamehameha)
stopKamehamehaButton.MouseButton1Click:Connect(stopKamehameha)

refreshPlayerList()
setPage(1)

gui.Destroying:Connect(function()
	collisionRefreshRunning = false

	for target, connection in pairs(collisionConnections) do
		connection:Disconnect()
		collisionConnections[target] = nil
	end

	goofActive = false
	strongGoofActive = false
	strongGoofV2Active = false
	strongGoofV3Active = false
	strongGoofV4Active = false
	strongGoofV5Active = false
	strongGoofV6Active = false
	kamehamehaActive = false

	kamehamehaToken += 1
	goofToken += 1
	strongGoofToken += 1
	strongGoofV2Token += 1
	strongGoofV3Token += 1
	strongGoofV4Token += 1
	strongGoofV5Token += 1
	strongGoofV6Token += 1

	loopGotoActive = false
	loopGotoToken += 1
	annoyActive = false
	annoyToken += 1

	if annoyTween then
		annoyTween:Cancel()
		annoyTween = nil
	end

	resetSpin()
end)
