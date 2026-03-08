
-- Sirius Boosts (Matcha LuaVM compatible)
-- sirius.menu/privacy | sirius.menu/terms

-- Services
local httpService = game:GetService('HttpService')
local players = game:GetService('Players')
local localPlayer = players.LocalPlayer

-- Hashing
local hasher = loadstring(game:HttpGet("https://sync-api.sirius.menu/v1/lua/hasher"))()["hasher"]

-- GET Boosts
local response = game:HttpGet("https://sync-api.sirius.menu/v1/u")
local success, boosts = pcall(function() return httpService:JSONDecode(response) end)

if not success then
	notify("Failed to load booster data", "Sirius Boosts", 5)
	return
end

local function getBooster(userId)
	local hashed = hasher(tostring(userId))

	local properties = boosts[hashed]
	if not properties then
		return false
	end

	local booster = {}

	if properties.color and not (properties.color[1] > 255 or properties.color[2] > 255 or properties.color[3] > 255) then
		booster.color = Color3.fromRGB(properties.color[1], properties.color[2], properties.color[3])
	end

	booster.icon = properties.icon ~= 0 and properties.icon or nil

	return booster
end

-- Drawing overlay for booster badges
local BADGE_X = 10
local BADGE_START_Y = 200
local BADGE_HEIGHT = 22
local BADGE_SPACING = 4
local BADGE_FONT = Drawing.Fonts.System

local drawingObjects = {} -- [userId] = { bg, text }

local function createBadge(player, booster, yOffset)
	local displayColor = booster.color or Color3.fromRGB(255, 138, 250)
	local label = "⚡ " .. player.DisplayName

	local bg = Drawing.new("Square")
	bg.Filled = true
	bg.Color = Color3.fromRGB(30, 30, 30)
	bg.Transparency = 0.4
	bg.Position = Vector2.new(BADGE_X, BADGE_START_Y + yOffset)
	bg.Size = Vector2.new(180, BADGE_HEIGHT)
	bg.Visible = true
	bg.ZIndex = 10

	local text = Drawing.new("Text")
	text.Text = label
	text.Color = displayColor
	text.Position = Vector2.new(BADGE_X + 6, BADGE_START_Y + yOffset + 3)
	text.Size = 16
	text.Font = BADGE_FONT
	text.Outline = true
	text.Visible = true
	text.ZIndex = 11

	return { bg = bg, text = text }
end

local function clearDrawings()
	for userId, objs in pairs(drawingObjects) do
		if objs.bg then objs.bg:Remove() end
		if objs.text then objs.text:Remove() end
	end
	drawingObjects = {}
end

local function refreshOverlay()
	clearDrawings()

	local yOffset = 0
	for _, player in ipairs(players:GetPlayers()) do
		local booster = getBooster(player.UserId)
		if booster then
			drawingObjects[player.UserId] = createBadge(player, booster, yOffset)
			yOffset = yOffset + BADGE_HEIGHT + BADGE_SPACING
		end
	end
end

local function onPlayerAdded(player)
	local booster = getBooster(player.UserId)
	if booster then
		local displayColor = booster.color or Color3.fromRGB(255, 138, 250)
		notify(player.DisplayName .. " is a Sirius Booster!", "Sirius Boosts", 5)
		refreshOverlay()
	end
end

local function onPlayerRemoving(player)
	if drawingObjects[player.UserId] then
		refreshOverlay()
	end
end

-- Initial scan
refreshOverlay()

-- Notify about local player if booster
local localBooster = getBooster(localPlayer.UserId)
if localBooster then
	notify("You are a Sirius Booster!", "Sirius Boosts", 5)
end

-- Events
players.PlayerAdded:Connect(onPlayerAdded)
players.PlayerRemoving:Connect(onPlayerRemoving)
