-- Original music hub for a Roblox experience.
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Players add audio assets they are allowed to use through the in-game input.

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local palette = {
	background = Color3.fromRGB(12, 15, 27),
	panel = Color3.fromRGB(22, 27, 46),
	panelLight = Color3.fromRGB(31, 38, 63),
	accent = Color3.fromRGB(112, 92, 255),
	accentBright = Color3.fromRGB(157, 140, 255),
	text = Color3.fromRGB(245, 246, 255),
	muted = Color3.fromRGB(155, 161, 188),
	danger = Color3.fromRGB(245, 92, 121),
	line = Color3.fromRGB(53, 60, 89),
}

local tracks = {}
local currentIndex = 0
local isPlaying = false
local volume = 0.5

local function create(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties) do
		object[property] = value
	end
	object.Parent = parent
	return object
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
	}, parent)
end

local function label(text, size, color, parent, font)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = color,
		TextSize = size,
		Font = font or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, parent)
end

local screen = create("ScreenGui", {
	Name = "AuroraMusicHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local root = create("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(720, 500),
	BackgroundColor3 = palette.background,
	BorderSizePixel = 0,
}, screen)
corner(root, 18)
stroke(root, palette.line, 1, 0.25)

local topBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 76),
	BackgroundColor3 = palette.panel,
	BorderSizePixel = 0,
}, root)
corner(topBar, 18)
create("Frame", {
	Position = UDim2.new(0, 0, 1, -18),
	Size = UDim2.new(1, 0, 0, 18),
	BackgroundColor3 = palette.panel,
	BorderSizePixel = 0,
}, topBar)

local brand = label("AURORA", 22, palette.text, topBar, Enum.Font.GothamBold)
brand.Position = UDim2.fromOffset(28, 14)
brand.Size = UDim2.fromOffset(150, 28)
local subtitle = label("MUSIC HUB", 11, palette.accentBright, topBar, Enum.Font.GothamBold)
subtitle.Position = UDim2.fromOffset(29, 40)
subtitle.Size = UDim2.fromOffset(120, 18)

local closeButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -22, 0.5, 0),
	Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = palette.panelLight,
	Text = "×",
	TextColor3 = palette.muted,
	TextSize = 24,
	Font = Enum.Font.Gotham,
	AutoButtonColor = false,
}, topBar)
corner(closeButton, 10)
closeButton.MouseButton1Click:Connect(function()
	root.Visible = false
end)

local body = create("Frame", {
	Position = UDim2.fromOffset(22, 92),
	Size = UDim2.new(1, -44, 1, -182),
	BackgroundTransparency = 1,
}, root)

local library = create("Frame", {
	Size = UDim2.new(0.58, -8, 1, 0),
	BackgroundColor3 = palette.panel,
	BorderSizePixel = 0,
}, body)
corner(library, 14)

local libraryTitle = label("Your queue", 17, palette.text, library, Enum.Font.GothamBold)
libraryTitle.Position = UDim2.fromOffset(18, 14)
libraryTitle.Size = UDim2.new(1, -36, 0, 26)
local libraryHint = label("Add audio that your experience is allowed to use", 11, palette.muted, library)
libraryHint.Position = UDim2.fromOffset(18, 39)
libraryHint.Size = UDim2.new(1, -36, 0, 20)

local search = create("TextBox", {
	Position = UDim2.fromOffset(16, 68),
	Size = UDim2.new(1, -32, 0, 34),
	BackgroundColor3 = palette.panelLight,
	PlaceholderText = "Filter your queue",
	PlaceholderColor3 = palette.muted,
	Text = "",
	TextColor3 = palette.text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ClearTextOnFocus = false,
}, library)
corner(search, 9)

local list = create("ScrollingFrame", {
	Position = UDim2.fromOffset(10, 112),
	Size = UDim2.new(1, -20, 1, -122),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = palette.accent,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, library)
create("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, list)

local nowPlaying = create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0.42, -8, 1, 0),
	BackgroundColor3 = palette.panel,
	BorderSizePixel = 0,
}, body)
corner(nowPlaying, 14)

local artwork = create("Frame", {
	Position = UDim2.fromOffset(20, 20),
	Size = UDim2.new(1, -40, 0, 174),
	BackgroundColor3 = palette.accent,
	BorderSizePixel = 0,
}, nowPlaying)
corner(artwork, 14)
local note = label("♫", 72, Color3.fromRGB(224, 220, 255), artwork, Enum.Font.GothamBold)
note.Size = UDim2.fromScale(1, 1)
note.TextXAlignment = Enum.TextXAlignment.Center
note.TextYAlignment = Enum.TextYAlignment.Center

local playingCaption = label("NOT PLAYING", 10, palette.accentBright, nowPlaying, Enum.Font.GothamBold)
playingCaption.Position = UDim2.fromOffset(20, 210)
playingCaption.Size = UDim2.new(1, -40, 0, 18)
local trackTitle = label("Choose a track", 19, palette.text, nowPlaying, Enum.Font.GothamBold)
trackTitle.Position = UDim2.fromOffset(20, 230)
trackTitle.Size = UDim2.new(1, -40, 0, 29)
trackTitle.TextTruncate = Enum.TextTruncate.AtEnd
local trackMeta = label("Your queue is ready", 11, palette.muted, nowPlaying)
trackMeta.Position = UDim2.fromOffset(20, 258)
trackMeta.Size = UDim2.new(1, -40, 0, 20)
trackMeta.TextTruncate = Enum.TextTruncate.AtEnd

local progressBack = create("Frame", {
	Position = UDim2.fromOffset(20, 298),
	Size = UDim2.new(1, -40, 0, 5),
	BackgroundColor3 = palette.line,
	BorderSizePixel = 0,
}, nowPlaying)
corner(progressBack, 3)
local progress = create("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = palette.accentBright,
	BorderSizePixel = 0,
}, progressBack)
corner(progress, 3)

local controls = create("Frame", {
	Position = UDim2.fromOffset(20, 321),
	Size = UDim2.new(1, -40, 0, 44),
	BackgroundTransparency = 1,
}, nowPlaying)
local function controlButton(text, position, size)
	local button = create("TextButton", {
		Position = position,
		Size = size,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = palette.text,
		TextSize = 22,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, controls)
	return button
end
local previousButton = controlButton("‹", UDim2.fromOffset(32, 0), UDim2.fromOffset(36, 40))
local playButton = create("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.fromOffset(44, 44),
	BackgroundColor3 = palette.accent,
	Text = "▶",
	TextColor3 = palette.text,
	TextSize = 17,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
}, controls)
corner(playButton, 22)
local nextButton = controlButton("›", UDim2.new(1, -68, 0, 0), UDim2.fromOffset(36, 40))

local volumeText = label("VOLUME", 10, palette.muted, nowPlaying, Enum.Font.GothamBold)
volumeText.Position = UDim2.fromOffset(20, 380)
volumeText.Size = UDim2.fromOffset(60, 18)
local volumeBack = create("Frame", {
	Position = UDim2.fromOffset(20, 406),
	Size = UDim2.new(1, -40, 0, 5),
	BackgroundColor3 = palette.line,
	BorderSizePixel = 0,
}, nowPlaying)
corner(volumeBack, 3)
local volumeFill = create("Frame", {
	Size = UDim2.fromScale(volume, 1),
	BackgroundColor3 = palette.accentBright,
	BorderSizePixel = 0,
}, volumeBack)
corner(volumeFill, 3)

local addBar = create("Frame", {
	Position = UDim2.new(0, 22, 1, -76),
	Size = UDim2.new(1, -44, 0, 52),
	BackgroundColor3 = palette.panel,
	BorderSizePixel = 0,
}, root)
corner(addBar, 12)
local idInput = create("TextBox", {
	Position = UDim2.fromOffset(12, 9),
	Size = UDim2.new(0.37, 0, 0, 34),
	BackgroundColor3 = palette.panelLight,
	PlaceholderText = "Audio asset ID",
	PlaceholderColor3 = palette.muted,
	Text = "",
	TextColor3 = palette.text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ClearTextOnFocus = false,
}, addBar)
corner(idInput, 8)
local nameInput = create("TextBox", {
	Position = UDim2.new(0.39, 0, 0, 9),
	Size = UDim2.new(0.37, 0, 0, 34),
	BackgroundColor3 = palette.panelLight,
	PlaceholderText = "Track name",
	PlaceholderColor3 = palette.muted,
	Text = "",
	TextColor3 = palette.text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	ClearTextOnFocus = false,
}, addBar)
corner(nameInput, 8)
local addButton = create("TextButton", {
	Position = UDim2.new(0.78, 0, 0, 9),
	Size = UDim2.new(0.22, -12, 0, 34),
	BackgroundColor3 = palette.accent,
	Text = "+  Add track",
	TextColor3 = palette.text,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false,
}, addBar)
corner(addButton, 8)

local sound = create("Sound", {
	Name = "AuroraMusicPlayer",
	Volume = volume,
	Parent = SoundService,
})

local function setMessage(text, color)
	trackMeta.Text = text
	trackMeta.TextColor3 = color or palette.muted
end

local function refreshList()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local filter = string.lower(search.Text)
	local shown = 0
	for index, track in ipairs(tracks) do
		if filter == "" or string.find(string.lower(track.name), filter, 1, true) then
			shown += 1
			local row = create("Frame", {
				LayoutOrder = index,
				Size = UDim2.new(1, -4, 0, 52),
				BackgroundColor3 = index == currentIndex and palette.panelLight or palette.background,
				BorderSizePixel = 0,
			}, list)
			corner(row, 9)
			local rowButton = create("TextButton", {
				Size = UDim2.new(1, -46, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
			}, row)
			local rowTitle = label(track.name, 12, palette.text, row, Enum.Font.GothamMedium)
			rowTitle.Position = UDim2.fromOffset(13, 7)
			rowTitle.Size = UDim2.new(1, -20, 0, 20)
			rowTitle.TextTruncate = Enum.TextTruncate.AtEnd
			local rowId = label("Audio " .. track.assetId, 10, palette.muted, row)
			rowId.Position = UDim2.fromOffset(13, 27)
			rowId.Size = UDim2.new(1, -20, 0, 16)
			rowButton.MouseButton1Click:Connect(function()
				currentIndex = index
				sound.SoundId = "rbxassetid://" .. track.assetId
				sound:Play()
				isPlaying = true
				playButton.Text = "Ⅱ"
				trackTitle.Text = track.name
				playingCaption.Text = "NOW PLAYING"
				setMessage("Audio " .. track.assetId)
				refreshList()
			end)
			local remove = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(28, 28),
				BackgroundTransparency = 1,
				Text = "×",
				TextColor3 = palette.muted,
				TextSize = 18,
				Font = Enum.Font.Gotham,
				AutoButtonColor = false,
			}, row)
			remove.MouseButton1Click:Connect(function()
				table.remove(tracks, index)
				if currentIndex == index then
					sound:Stop()
					isPlaying = false
					currentIndex = 0
					playButton.Text = "▶"
					trackTitle.Text = "Choose a track"
					playingCaption.Text = "NOT PLAYING"
					setMessage("Your queue is ready")
				elseif currentIndex > index then
					currentIndex -= 1
				end
				refreshList()
			end)
		end
	end
	if shown == 0 then
		local empty = label(#tracks == 0 and "Add an audio asset to begin" or "No tracks match your filter", 12, palette.muted, list)
		empty.Size = UDim2.new(1, -8, 0, 44)
		empty.TextXAlignment = Enum.TextXAlignment.Center
	end
end

local function selectRelative(step)
	if #tracks == 0 then
		setMessage("Add a track to start listening", palette.muted)
		return
	end
	currentIndex = currentIndex + step
	if currentIndex > #tracks then currentIndex = 1 end
	if currentIndex < 1 then currentIndex = #tracks end
	local track = tracks[currentIndex]
	sound.SoundId = "rbxassetid://" .. track.assetId
	sound:Play()
	isPlaying = true
	playButton.Text = "Ⅱ"
	trackTitle.Text = track.name
	playingCaption.Text = "NOW PLAYING"
	setMessage("Audio " .. track.assetId)
	refreshList()
end

addButton.MouseButton1Click:Connect(function()
	local rawId = string.gsub(idInput.Text, "rbxassetid://", "")
	local numericId = tonumber(rawId)
	if not numericId or numericId <= 0 then
		setMessage("Enter a valid numeric audio asset ID", palette.danger)
		return
	end
	local name = string.gsub(nameInput.Text, "^%s*(.-)%s*$", "%1")
	if name == "" then name = "Track " .. tostring(#tracks + 1) end
	table.insert(tracks, { name = name, assetId = math.floor(numericId) })
	idInput.Text = ""
	nameInput.Text = ""
	setMessage("Track added to your queue", palette.accentBright)
	refreshList()
end)

search:GetPropertyChangedSignal("Text"):Connect(refreshList)
playButton.MouseButton1Click:Connect(function()
	if #tracks == 0 then
		setMessage("Add a track to start listening", palette.muted)
		return
	end
	if currentIndex == 0 then
		selectRelative(1)
	elseif isPlaying then
		sound:Pause()
		isPlaying = false
		playButton.Text = "▶"
		playingCaption.Text = "PAUSED"
	else
		sound:Resume()
		isPlaying = true
		playButton.Text = "Ⅱ"
		playingCaption.Text = "NOW PLAYING"
	end
end)
previousButton.MouseButton1Click:Connect(function() selectRelative(-1) end)
nextButton.MouseButton1Click:Connect(function() selectRelative(1) end)

volumeBack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local ratio = math.clamp((input.Position.X - volumeBack.AbsolutePosition.X) / volumeBack.AbsoluteSize.X, 0, 1)
		volume = ratio
		sound.Volume = volume
		volumeFill.Size = UDim2.fromScale(volume, 1)
	end
end)

sound.Ended:Connect(function()
	if #tracks > 0 then
		selectRelative(1)
	end
end)

refreshList()
