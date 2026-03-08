local promptRet = {}

local UserInputService = game:GetService("UserInputService")

local debounce = false

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end

local function isInBounds(pos, boundsPos, boundsSize)
	return pos.X >= boundsPos.X
		and pos.X <= boundsPos.X + boundsSize.X
		and pos.Y >= boundsPos.Y
		and pos.Y <= boundsPos.Y + boundsSize.Y
end

function promptRet.create(title, description, primary, secondary, callback)
	local objects = {}
	local fin = false

	local viewport = getViewportSize()

	local dialogW = 463
	local dialogH = 150
	local dialogX = (viewport.X - dialogW) / 2
	local dialogY = (viewport.Y - dialogH) / 2

	local btnH = 30
	local btnPadding = 10
	local primaryBtnW = 140
	local secondaryBtnW = 100

	local primaryBtnX = dialogX + dialogW - primaryBtnW - secondaryBtnW - btnPadding * 3
	local primaryBtnY = dialogY + dialogH - btnH - btnPadding
	local secondaryBtnX = dialogX + dialogW - secondaryBtnW - btnPadding
	local secondaryBtnY = primaryBtnY

	-- Background overlay
	local overlay = Drawing.new("Square")
	overlay.Size = Vector2.new(viewport.X, viewport.Y)
	overlay.Position = Vector2.new(0, 0)
	overlay.Color = Color3.fromRGB(0, 0, 0)
	overlay.Transparency = 0.5
	overlay.Filled = true
	overlay.Visible = false
	overlay.ZIndex = 100
	table.insert(objects, overlay)

	-- Dialog background
	local dialogBg = Drawing.new("Square")
	dialogBg.Size = Vector2.new(dialogW, dialogH)
	dialogBg.Position = Vector2.new(dialogX, dialogY)
	dialogBg.Color = Color3.fromRGB(30, 30, 35)
	dialogBg.Transparency = 1
	dialogBg.Filled = true
	dialogBg.Visible = false
	dialogBg.ZIndex = 101
	table.insert(objects, dialogBg)

	-- Dialog border
	local dialogBorder = Drawing.new("Square")
	dialogBorder.Size = Vector2.new(dialogW, dialogH)
	dialogBorder.Position = Vector2.new(dialogX, dialogY)
	dialogBorder.Color = Color3.fromRGB(60, 60, 65)
	dialogBorder.Transparency = 1
	dialogBorder.Filled = false
	dialogBorder.Visible = false
	dialogBorder.ZIndex = 102
	table.insert(objects, dialogBorder)

	-- Title text
	local titleText = Drawing.new("Text")
	titleText.Text = title or ""
	titleText.Size = 20
	titleText.Font = Drawing.Fonts.SystemBold
	titleText.Color = Color3.fromRGB(255, 255, 255)
	titleText.Position = Vector2.new(dialogX + btnPadding, dialogY + 12)
	titleText.Transparency = 1
	titleText.Outline = true
	titleText.Center = false
	titleText.Visible = false
	titleText.ZIndex = 103
	table.insert(objects, titleText)

	-- Description text
	local descText = Drawing.new("Text")
	descText.Text = description or ""
	descText.Size = 16
	descText.Font = Drawing.Fonts.System
	descText.Color = Color3.fromRGB(180, 180, 185)
	descText.Position = Vector2.new(dialogX + btnPadding, dialogY + 42)
	descText.Transparency = 1
	descText.Outline = false
	descText.Center = false
	descText.Visible = false
	descText.ZIndex = 103
	table.insert(objects, descText)

	-- Primary button background
	local primaryBtnBg = Drawing.new("Square")
	primaryBtnBg.Size = Vector2.new(primaryBtnW, btnH)
	primaryBtnBg.Position = Vector2.new(primaryBtnX, primaryBtnY)
	primaryBtnBg.Color = Color3.fromRGB(65, 105, 225)
	primaryBtnBg.Transparency = 1
	primaryBtnBg.Filled = true
	primaryBtnBg.Visible = false
	primaryBtnBg.ZIndex = 103
	table.insert(objects, primaryBtnBg)

	-- Primary button text
	local primaryBtnText = Drawing.new("Text")
	primaryBtnText.Text = primary or ""
	primaryBtnText.Size = 16
	primaryBtnText.Font = Drawing.Fonts.SystemBold
	primaryBtnText.Color = Color3.fromRGB(255, 255, 255)
	primaryBtnText.Position = Vector2.new(primaryBtnX + primaryBtnW / 2, primaryBtnY + 6)
	primaryBtnText.Transparency = 1
	primaryBtnText.Center = true
	primaryBtnText.Outline = false
	primaryBtnText.Visible = false
	primaryBtnText.ZIndex = 104
	table.insert(objects, primaryBtnText)

	-- Secondary button text (text-only style)
	local secondaryBtnText = Drawing.new("Text")
	secondaryBtnText.Text = secondary or ""
	secondaryBtnText.Size = 16
	secondaryBtnText.Font = Drawing.Fonts.System
	secondaryBtnText.Color = Color3.fromRGB(150, 150, 155)
	secondaryBtnText.Position = Vector2.new(secondaryBtnX + secondaryBtnW / 2, secondaryBtnY + 6)
	secondaryBtnText.Transparency = 1
	secondaryBtnText.Center = true
	secondaryBtnText.Outline = false
	secondaryBtnText.Visible = false
	secondaryBtnText.ZIndex = 104
	table.insert(objects, secondaryBtnText)

	local function cleanup()
		for _, obj in ipairs(objects) do
			pcall(function() obj:Remove() end)
		end
		objects = {}
	end

	local function close(result)
		if fin then return end
		fin = true
		debounce = true

		for _, obj in ipairs(objects) do
			pcall(function() obj.Visible = false end)
		end

		task.wait(0.05)
		cleanup()

		if callback then
			callback(result)
		end
	end

	-- Input connection
	local inputConn
	inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if fin or debounce then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = Vector2.new(input.Position.X, input.Position.Y)

			if isInBounds(mousePos, Vector2.new(primaryBtnX, primaryBtnY), Vector2.new(primaryBtnW, btnH)) then
				if inputConn then inputConn:Disconnect() end
				close(true)
			elseif isInBounds(mousePos, Vector2.new(secondaryBtnX, secondaryBtnY), Vector2.new(secondaryBtnW, btnH)) then
				if inputConn then inputConn:Disconnect() end
				close(false)
			end
		end
	end)

	-- Open animation: show elements with a short stagger
	task.spawn(function()
		debounce = true

		overlay.Visible = true
		dialogBg.Visible = true
		dialogBorder.Visible = true

		task.wait(0.15)

		titleText.Visible = true

		task.wait(0.03)

		descText.Visible = true

		task.wait(0.15)

		primaryBtnBg.Visible = true
		primaryBtnText.Visible = true

		task.wait(0.1)

		secondaryBtnText.Visible = true
		debounce = false
	end)
end

return promptRet
