-- Alle schermen van de speler: munten, winkel, dagelijks rad, speeltijd-beloningen,
-- meldingen en de stormwaarschuwing. Alles wordt met code gemaakt.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local FONT = Enum.Font.FredokaOne
local DARK = Color3.fromRGB(25, 30, 45)
local ACCENT = Color3.fromRGB(70, 140, 255)
local GOOD = Color3.fromRGB(70, 190, 100)

local state = nil
local stateClock = os.clock()

---------------------------------------------------------------------------
-- Hulpfuncties
---------------------------------------------------------------------------
local function create(className: string, props, children)
	local inst = Instance.new(className)
	for key, value in props do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	for _, child in children or {} do
		child.Parent = inst
	end
	if props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(radius: number?)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 12) })
end

local function stroke()
	return create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 2, Transparency = 0.4 })
end

local function label(props)
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.Font = FONT
	props.TextColor3 = props.TextColor3 or Color3.new(1, 1, 1)
	props.TextScaled = true
	return create("TextLabel", props, { create("UIStroke", { Thickness = 1.5, Transparency = 0.3 }) })
end

local function button(props)
	props.Font = FONT
	props.TextColor3 = Color3.new(1, 1, 1)
	props.TextScaled = true
	props.AutoButtonColor = true
	return create("TextButton", props, {
		corner(12),
		stroke(),
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
		}),
	})
end

local function formatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	if m >= 60 then
		return string.format("%d:%02d:%02d", math.floor(m / 60), m % 60, s)
	end
	return string.format("%d:%02d", m, s)
end

---------------------------------------------------------------------------
-- Scherm
---------------------------------------------------------------------------
local gui = create("ScreenGui", {
	Name = "CatchAStormUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

-- Munten bovenaan
local topBar = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(360, 74),
	BackgroundTransparency = 1,
	Parent = gui,
})
local coinsLabel = label({
	Size = UDim2.new(1, 0, 0, 44),
	Text = "0 munten",
	TextColor3 = Color3.fromRGB(255, 215, 70),
	Parent = topBar,
})
local infoLabel = label({
	Position = UDim2.fromOffset(0, 46),
	Size = UDim2.new(1, 0, 0, 24),
	Text = "",
	Parent = topBar,
})

-- Knoppen links
local sideBar = create("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 10, 0.5, 0),
	Size = UDim2.fromOffset(150, 230),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
})
local shopButton = button({ Text = "Winkel", Size = UDim2.fromOffset(150, 60), BackgroundColor3 = ACCENT, LayoutOrder = 1, Parent = sideBar })
local wheelButton = button({ Text = "Rad", Size = UDim2.fromOffset(150, 60), BackgroundColor3 = Color3.fromRGB(230, 120, 40), LayoutOrder = 2, Parent = sideBar })
local rewardButton = button({ Text = "Beloning", Size = UDim2.fromOffset(150, 70), BackgroundColor3 = Color3.fromRGB(120, 120, 130), LayoutOrder = 3, Parent = sideBar })
local wheelDot = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -4, 0, 4),
	Size = UDim2.fromOffset(18, 18),
	BackgroundColor3 = Color3.fromRGB(255, 60, 60),
	Visible = false,
	Parent = wheelButton,
}, { corner(9) })

-- Meldingen
local toastHolder = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 90),
	Size = UDim2.fromOffset(520, 200),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	create("UIListLayout", {
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})
local toastCount = 0
local function toast(text: string, color: Color3?)
	toastCount += 1
	local t = label({
		Text = text,
		Size = UDim2.fromOffset(520, 34),
		TextColor3 = color or Color3.new(1, 1, 1),
		BackgroundColor3 = DARK,
		BackgroundTransparency = 0.35,
		LayoutOrder = toastCount,
		Parent = toastHolder,
	})
	corner(10).Parent = t
	task.delay(3.5, function()
		TweenService:Create(t, TweenInfo.new(0.4), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		task.wait(0.4)
		t:Destroy()
	end)
end

-- Stormbanner
local stormBanner = label({
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -20),
	Size = UDim2.fromOffset(560, 56),
	BackgroundColor3 = Color3.fromRGB(60, 50, 120),
	BackgroundTransparency = 0.15,
	Text = "",
	Visible = false,
	Parent = gui,
})
corner(14).Parent = stormBanner

---------------------------------------------------------------------------
-- Panelen
---------------------------------------------------------------------------
local function panel(title: string, size: Vector2)
	local frame = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundColor3 = DARK,
		BackgroundTransparency = 0.05,
		Visible = false,
		Parent = gui,
	}, { corner(18), stroke() })
	label({ Text = title, Size = UDim2.new(1, -60, 0, 44), Position = UDim2.fromOffset(16, 8), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
	local close = button({
		Text = "X",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.fromOffset(44, 44),
		BackgroundColor3 = Color3.fromRGB(200, 60, 60),
		Parent = frame,
	})
	close.Activated:Connect(function()
		frame.Visible = false
	end)
	return frame
end

local shopPanel = panel("Winkel", Vector2.new(420, 260))
local netBuy = button({ Position = UDim2.fromOffset(20, 70), Size = UDim2.new(1, -40, 0, 74), BackgroundColor3 = GOOD, Text = "", Parent = shopPanel })
local shelfBuy = button({ Position = UDim2.fromOffset(20, 160), Size = UDim2.new(1, -40, 0, 74), BackgroundColor3 = GOOD, Text = "", Parent = shopPanel })

local wheelPanel = panel("Dagelijks rad", Vector2.new(400, 500))
local WHEEL_SIZE = 300
local wheel = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 80),
	Size = UDim2.fromOffset(WHEEL_SIZE, WHEEL_SIZE),
	BackgroundColor3 = Color3.fromRGB(240, 240, 250),
	Parent = wheelPanel,
}, { corner(WHEEL_SIZE / 2), create("UIStroke", { Thickness = 6, Color = Color3.fromRGB(255, 200, 60) }) })

local prizeCount = #Config.WheelPrizes
local segmentAngle = 360 / prizeCount
for i, prize in Config.WheelPrizes do
	local angle = (i - 1) * segmentAngle
	local rad = math.rad(angle)
	-- Klein genoeg zodat 8 prijzen naast elkaar passen zonder te overlappen.
	local radius = WHEEL_SIZE / 2 - 44
	local chip = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, math.sin(rad) * radius, 0.5, -math.cos(rad) * radius),
		Size = UDim2.fromOffset(76, 34),
		Rotation = angle,
		BackgroundColor3 = prize.color,
		Parent = wheel,
	}, { corner(10) })
	label({ Text = prize.label, Size = UDim2.fromScale(1, 1), Parent = chip })
end
create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = Color3.fromRGB(255, 200, 60),
	Parent = wheel,
}, { corner(20) })
-- Pijl bovenaan die de prijs aanwijst
label({
	Text = "V",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 0, 84),
	Size = UDim2.fromOffset(40, 36),
	TextColor3 = Color3.fromRGB(255, 70, 70),
	Parent = wheelPanel,
})
local spinButton = button({
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -20),
	Size = UDim2.fromOffset(220, 64),
	BackgroundColor3 = GOOD,
	Text = "Draai!",
	Parent = wheelPanel,
})

---------------------------------------------------------------------------
-- Gedrag
---------------------------------------------------------------------------
local function playSecondsNow(): number
	if not state then
		return 0
	end
	return state.playSeconds + (os.clock() - stateClock)
end

local function refresh()
	if not state then
		return
	end
	local net = Config.Nets[state.netTier]
	local nextNet = Config.Nets[state.netTier + 1]
	local luckLeft = state.luckLeft - (os.clock() - stateClock)
	local info = string.format(
		"+%s/s  |  %s  |  Lab %d/%d",
		Config.FormatNumber(state.income),
		net and net.name or "?",
		#state.jars,
		state.capacity
	)
	if luckLeft > 0 then
		info ..= "  |  Geluk " .. formatTime(luckLeft)
	end
	infoLabel.Text = info

	if nextNet then
		netBuy.Text = nextNet.name .. "  -  " .. Config.FormatNumber(nextNet.price) .. " munten"
	else
		netBuy.Text = "Je hebt het beste net"
	end
	if state.shelves < Config.MaxShelves then
		shelfBuy.Text = "Extra plank (+" .. Config.SlotsPerShelf .. " potten)  -  " .. Config.FormatNumber(Config.ShelfPrice(state.shelves)) .. " munten"
	else
		shelfBuy.Text = "Maximaal aantal planken"
	end

	wheelDot.Visible = state.wheelReady
	spinButton.Text = if state.wheelReady then "Draai!" else "Morgen weer"
end

local function refreshReward()
	if not state then
		return
	end
	local nextIndex = state.playClaimed + 1
	if not Config.PlaytimeRewards[nextIndex] then
		rewardButton.Text = "Morgen meer beloningen"
		rewardButton.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
		return
	end
	local waitSeconds = Config.PlaytimeUnlockMinutes(nextIndex) * 60 - playSecondsNow()
	if waitSeconds <= 0 then
		rewardButton.Text = "Beloning klaar!"
		rewardButton.BackgroundColor3 = GOOD
	else
		rewardButton.Text = "Beloning over " .. formatTime(waitSeconds)
		rewardButton.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
	end
end

remotes:WaitForChild("State").OnClientEvent:Connect(function(newState)
	state = newState
	stateClock = os.clock()
	refresh()
	refreshReward()
end)

remotes:WaitForChild("Notify").OnClientEvent:Connect(toast)

-- Munten live bijwerken via leaderstats
task.spawn(function()
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Munten")
	local function update()
		coinsLabel.Text = Config.FormatNumber(coins.Value) .. " munten"
	end
	coins.Changed:Connect(update)
	update()
end)

shopButton.Activated:Connect(function()
	shopPanel.Visible = not shopPanel.Visible
	wheelPanel.Visible = false
end)
wheelButton.Activated:Connect(function()
	wheelPanel.Visible = not wheelPanel.Visible
	shopPanel.Visible = false
end)

local busy = false
local function invoke(name: string)
	if busy then
		return
	end
	busy = true
	local ok, success, message = pcall(function()
		return remotes[name]:InvokeServer()
	end)
	busy = false
	if ok and message then
		toast(message, if success then GOOD else Color3.fromRGB(255, 120, 120))
	end
end

netBuy.Activated:Connect(function()
	invoke("BuyNet")
end)
shelfBuy.Activated:Connect(function()
	invoke("BuyShelf")
end)
rewardButton.Activated:Connect(function()
	invoke("ClaimPlaytime")
end)

local spinning = false
spinButton.Activated:Connect(function()
	if spinning or not state or not state.wheelReady then
		return
	end
	spinning = true
	local ok, index, text = pcall(function()
		return remotes.SpinWheel:InvokeServer()
	end)
	if not ok or not index then
		spinning = false
		return
	end
	-- Draai een paar rondes en stop met de gewonnen prijs bovenaan.
	wheel.Rotation = wheel.Rotation % 360
	local target = -(index - 1) * segmentAngle - 360 * 5
	local tween = TweenService:Create(wheel, TweenInfo.new(4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = target })
	tween:Play()
	tween.Completed:Wait()
	toast("Je won " .. text .. "!", Color3.fromRGB(255, 220, 80))
	spinning = false
end)

-- Storm
local stormEndsAt = 0
local stormPhase = "ended"
remotes:WaitForChild("Storm").OnClientEvent:Connect(function(phase, _center, seconds)
	stormPhase = phase
	stormEndsAt = os.clock() + seconds
	stormBanner.Visible = phase ~= "ended"
	if phase == "warning" then
		toast("Er komt een storm aan! Kijk naar de donkere wolk.", Color3.fromRGB(180, 160, 255))
	elseif phase == "ended" then
		toast("De storm is voorbij.", Color3.fromRGB(180, 180, 200))
	end
end)

-- Elke frame: tellers bijwerken
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
	if os.clock() - lastUpdate < 0.25 then
		return
	end
	lastUpdate = os.clock()
	refreshReward()
	if state and state.luckLeft > 0 then
		refresh()
	end
	if stormPhase ~= "ended" then
		local left = formatTime(stormEndsAt - os.clock())
		if stormPhase == "warning" then
			stormBanner.Text = "STORM over " .. left .. "! Ren naar de donkere wolk"
		else
			stormBanner.Text = "STORM! 5x kans op zeldzaam weer  -  nog " .. left
		end
	end
end)
