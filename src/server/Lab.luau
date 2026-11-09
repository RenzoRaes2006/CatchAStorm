-- Het weerlab van elke speler: een eigen plek, planken met potten, en inkomen per seconde.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local World = require(script.Parent.World)

local Lab = {}

local plotOwners: { [number]: Player } = {}
local playerPlots: { [Player]: number } = {}
local plotModels: { [Player]: Model } = {}

local VARIANT_SPARKLE = {
	Golden = Color3.fromRGB(255, 215, 60),
	Frozen = Color3.fromRGB(150, 230, 255),
	Cosmic = Color3.fromRGB(220, 90, 255),
}

local function newPart(props): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		p[key] = value
	end
	return p
end

local function makeLabel(parent: Instance, text: string, size: UDim2, offset: Vector3): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Size = size
	gui.StudsOffset = offset
	gui.AlwaysOnTop = false
	gui.MaxDistance = 120
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = gui
	gui.Parent = parent
	return label
end

local function buildPlot(player: Player, index: number): Model
	local model = Instance.new("Model")
	model.Name = "Lab_" .. player.Name
	local origin = World.PlotCFrame(index)

	local floor = newPart({
		Name = "Floor",
		Size = World.PlotSize,
		CFrame = origin,
		Color = Color3.fromRGB(70, 90, 140),
		Material = Enum.Material.SmoothPlastic,
		Parent = model,
	})
	model.PrimaryPart = floor

	local sign = newPart({
		Name = "Sign",
		Size = Vector3.new(1, 8, 1),
		CFrame = origin * CFrame.new(0, 4.5, World.PlotSize.Z / 2 - 1),
		Color = Color3.fromRGB(60, 60, 70),
		Parent = model,
	})
	makeLabel(sign, "Lab van " .. player.DisplayName, UDim2.fromOffset(260, 50), Vector3.new(0, 6, 0)).Name = "Title"
	makeLabel(sign, "0 munten/s", UDim2.fromOffset(200, 34), Vector3.new(0, 3.5, 0)).Name = "Income"

	local shelves = Instance.new("Folder")
	shelves.Name = "Shelves"
	shelves.Parent = model

	model.Parent = workspace.Labs
	return model
end

local function shelfCFrame(origin: CFrame, row: number): CFrame
	local z = -World.PlotSize.Z / 2 + 3 + (row - 1) * 3.4
	return origin * CFrame.new(0, 2.5, z)
end

local function buildJar(parent: Instance, cf: CFrame, weatherId: string, variantId: string?)
	local weather = Config.GetWeather(weatherId)
	if not weather then
		return
	end
	local glass = newPart({
		Name = "Jar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2.6, 2.2, 2.2),
		CFrame = cf * CFrame.Angles(0, 0, math.rad(90)),
		Material = Enum.Material.Glass,
		Transparency = 0.6,
		Color = if variantId == "Frozen" then Color3.fromRGB(170, 230, 255) else Color3.fromRGB(220, 240, 255),
		CanCollide = false,
		Parent = parent,
	})
	newPart({
		Name = "Lid",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.4, 2.4, 2.4),
		CFrame = cf * CFrame.new(0, 1.4, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(90, 70, 50),
		Material = Enum.Material.Wood,
		CanCollide = false,
		Parent = parent,
	})
	local core = newPart({
		Name = "Weather",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.5, 1.5, 1.5),
		CFrame = cf,
		Color = if variantId == "Golden" then Color3.fromRGB(255, 210, 60) else weather.color,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = parent,
	})
	local sparkleColor = variantId and VARIANT_SPARKLE[variantId]
	if sparkleColor then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = sparkleColor
		sparkles.Parent = core
	end
	glass:SetAttribute("WeatherId", weatherId)
end

-- Tekent planken en potten opnieuw na een verandering.
function Lab.Render(player: Player)
	local model = plotModels[player]
	local data = PlayerData.Get(player)
	if not model or not data then
		return
	end
	local shelves = model:FindFirstChild("Shelves")
	shelves:ClearAllChildren()
	local origin = model.PrimaryPart.CFrame

	-- Sorteer zodat de waardevolste potten vooraan staan.
	local sorted = table.clone(data.jars)
	table.sort(sorted, function(a, b)
		return Config.JarIncome(a.w, a.v) > Config.JarIncome(b.w, b.v)
	end)

	for row = 1, data.shelves do
		local cf = shelfCFrame(origin, row)
		newPart({
			Name = "Shelf",
			Size = Vector3.new(28, 0.6, 2.6),
			CFrame = cf,
			Color = Color3.fromRGB(150, 110, 70),
			Material = Enum.Material.WoodPlanks,
			Parent = shelves,
		})
		for slot = 1, Config.SlotsPerShelf do
			local jar = sorted[(row - 1) * Config.SlotsPerShelf + slot]
			if jar then
				local x = (slot - (Config.SlotsPerShelf + 1) / 2) * 5
				buildJar(shelves, cf * CFrame.new(x, 1.6, 0), jar.w, jar.v)
			end
		end
	end

	local sign = model:FindFirstChild("Sign")
	for _, gui in sign:GetChildren() do
		local label = gui:FindFirstChild("Income")
		if label then
			label.Text = Config.FormatNumber(PlayerData.Income(data)) .. " munten/s"
		end
	end
end

-- Voegt een pot toe. Is het lab vol, dan vervangt hij de zwakste pot als de nieuwe beter is.
-- Geeft terug: "added", "replaced" of "full".
function Lab.AddJar(player: Player, weatherId: string, variantId: string?): string
	local data = PlayerData.Get(player)
	if not data then
		return "full"
	end
	local newJar = { w = weatherId, v = variantId }
	local result
	if #data.jars < PlayerData.Capacity(data) then
		table.insert(data.jars, newJar)
		result = "added"
	else
		local weakestIndex, weakestIncome = nil, math.huge
		for i, jar in data.jars do
			local income = Config.JarIncome(jar.w, jar.v)
			if income < weakestIncome then
				weakestIndex, weakestIncome = i, income
			end
		end
		if weakestIndex and Config.JarIncome(weatherId, variantId) > weakestIncome then
			data.jars[weakestIndex] = newJar
			result = "replaced"
		else
			return "full"
		end
	end
	data.totalCaught += 1
	Lab.Render(player)
	PlayerData.Sync(player)
	return result
end

function Lab.TeleportHome(player: Player)
	local index = playerPlots[player]
	local character = player.Character
	if not index or not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local front = World.PlotCFrame(index) * CFrame.new(0, 4, World.PlotSize.Z / 2 + 6)
		character:PivotTo(CFrame.lookAt(front.Position, front.Position + Vector3.new(0, 0, 1)))
	end
end

function Lab.OnPlayerLoaded(player: Player)
	local index = nil
	for i = 1, World.PlotCount do
		if not plotOwners[i] then
			index = i
			break
		end
	end
	if not index then
		warn("[Lab] Geen vrije plek voor", player.Name, "- zet Max Players op", World.PlotCount)
		return
	end
	plotOwners[index] = player
	playerPlots[player] = index
	plotModels[player] = buildPlot(player, index)
	Lab.Render(player)

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		Lab.TeleportHome(player)
	end)
	if player.Character then
		Lab.TeleportHome(player)
	end
end

function Lab.Start()
	Players.PlayerRemoving:Connect(function(player)
		local index = playerPlots[player]
		if index then
			plotOwners[index] = nil
		end
		playerPlots[player] = nil
		if plotModels[player] then
			plotModels[player]:Destroy()
			plotModels[player] = nil
		end
	end)

	-- Inkomen: elke seconde munten voor alle potten.
	task.spawn(function()
		local ticks = 0
		while true do
			task.wait(1)
			ticks += 1
			for _, player in Players:GetPlayers() do
				local data = PlayerData.Get(player)
				if data then
					PlayerData.AddCoins(player, PlayerData.Income(data))
					if ticks % 5 == 0 then
						PlayerData.Sync(player)
					end
				end
			end
		end
	end)
end

return Lab
