-- Laat weer verschijnen in de wereld, regelt het vangen en de serverstorm.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local Lab = require(script.Parent.Lab)
local World = require(script.Parent.World)
local Remotes = require(script.Parent.Remotes)

local Weather = {}

local normalCount = 0
local stormCount = 0
local MAX_STORM_WEATHER = 25

-- Kiest een weertype op basis van de kansen. luck > 1 maakt alles behalve "Gewoon" vaker.
local function pickWeather(luck: number)
	local total = 0
	for _, w in Config.Weather do
		total += w.weight * (if w.rarity == "Gewoon" then 1 else luck)
	end
	local roll = math.random() * total
	for _, w in Config.Weather do
		roll -= w.weight * (if w.rarity == "Gewoon" then 1 else luck)
		if roll <= 0 then
			return w
		end
	end
	return Config.Weather[1]
end

local function rollVariant(luck: number): string?
	for _, variant in Config.Variants do
		if math.random() < variant.chance * luck then
			return variant.id
		end
	end
	return nil
end

local function notify(player: Player, text: string, color: Color3?)
	Remotes.Notify:FireClient(player, text, color or Color3.new(1, 1, 1))
end

local function onCaught(part: BasePart, weather, player: Player)
	if part:GetAttribute("Caught") then
		return
	end
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	if data.netTier < weather.netTier then
		local net = Config.Nets[weather.netTier]
		notify(player, "Je hebt een " .. net.name .. " nodig voor " .. weather.name .. "!", Color3.fromRGB(255, 120, 120))
		return
	end
	part:SetAttribute("Caught", true)

	local luck = if data.luckUntil > os.time() then Config.LuckBoostMultiplier else 1
	local variantId = rollVariant(luck)
	local result = Lab.AddJar(player, weather.id, variantId)
	if result == "full" then
		part:SetAttribute("Caught", nil)
		notify(player, "Je lab is vol! Koop een extra plank of vang beter weer.", Color3.fromRGB(255, 180, 80))
		return
	end

	local variant = Config.GetVariant(variantId)
	local name = (if variant then variant.name .. " " else "") .. weather.name
	local color = Config.RarityColors[weather.rarity] or Color3.new(1, 1, 1)
	if variant then
		color = Color3.fromRGB(255, 220, 80)
		-- Een variant is iets om te laten zien: iedereen in de server ziet het.
		for _, other in Players:GetPlayers() do
			notify(other, player.DisplayName .. " ving een " .. name .. "!", color)
		end
	else
		notify(player, "Gevangen: " .. name .. (if result == "replaced" then " (zwakste pot vervangen)" else ""), color)
	end
	part:Destroy()
end

local function spawnWeather(position: Vector3, luck: number, isStorm: boolean)
	local weather = pickWeather(luck)
	local height = 3 + weather.size / 2 + math.random() * 2

	local part = Instance.new("Part")
	part.Name = weather.id
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(weather.size, weather.size, weather.size)
	part.Position = position + Vector3.new(0, height, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = weather.color
	part.Transparency = 0.25
	part:SetAttribute("WeatherId", weather.id)

	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(weather.color)
	particles.Rate = 12
	particles.Lifetime = NumberRange.new(0.6, 1.2)
	particles.Speed = NumberRange.new(2, 5)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Size = NumberSequence.new(0.4, 0)
	particles.LightEmission = 0.8
	particles.Parent = part

	local light = Instance.new("PointLight")
	light.Color = weather.color
	light.Range = 12
	light.Brightness = 1.5
	light.Parent = part

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(160, 44)
	gui.StudsOffset = Vector3.new(0, weather.size / 2 + 1.5, 0)
	gui.MaxDistance = 80
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 0.55)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.Text = weather.name
	nameLabel.Parent = gui
	local rarityLabel = nameLabel:Clone()
	rarityLabel.Position = UDim2.fromScale(0, 0.55)
	rarityLabel.Size = UDim2.fromScale(1, 0.45)
	rarityLabel.TextColor3 = Config.RarityColors[weather.rarity] or Color3.new(1, 1, 1)
	rarityLabel.Text = weather.rarity
	rarityLabel.Parent = gui
	gui.Parent = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Vang"
	prompt.ObjectText = weather.name
	prompt.HoldDuration = Config.CatchHoldSeconds
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	prompt.Triggered:Connect(function(player)
		onCaught(part, weather, player)
	end)

	part.Parent = workspace.Weather

	-- Zachtjes op en neer zweven.
	local bob = TweenService:Create(
		part,
		TweenInfo.new(1.5 + math.random(), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = part.Position + Vector3.new(0, 1.5, 0) }
	)
	bob:Play()

	if isStorm then
		stormCount += 1
	else
		normalCount += 1
	end
	part.Destroying:Connect(function()
		bob:Cancel()
		if isStorm then
			stormCount -= 1
		else
			normalCount -= 1
		end
	end)

	task.delay(Config.WeatherLifetime + math.random() * 10, function()
		if part.Parent then
			part:Destroy()
		end
	end)
end

local function makeStormCloud(center: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "ServerStorm"
	local cloud = Instance.new("Part")
	cloud.Name = "Cloud"
	cloud.Shape = Enum.PartType.Cylinder
	cloud.Size = Vector3.new(12, Config.StormRadius * 2, Config.StormRadius * 2)
	cloud.CFrame = CFrame.new(center + Vector3.new(0, 55, 0)) * CFrame.Angles(0, 0, math.rad(90))
	cloud.Color = Color3.fromRGB(60, 60, 75)
	cloud.Material = Enum.Material.SmoothPlastic
	cloud.Transparency = 0.25
	cloud.Anchored = true
	cloud.CanCollide = false
	cloud.Parent = model

	local rain = cloud:Clone()
	rain.Name = "Rain"
	rain.Size = Vector3.new(55, Config.StormRadius * 2 - 4, Config.StormRadius * 2 - 4)
	rain.CFrame = CFrame.new(center + Vector3.new(0, 27, 0)) * CFrame.Angles(0, 0, math.rad(90))
	rain.Color = Color3.fromRGB(120, 140, 200)
	rain.Transparency = 0.85
	rain.Parent = model

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(180, 200, 255)
	light.Range = 60
	light.Brightness = 3
	light.Parent = cloud

	model.Parent = workspace.Weather
	return model
end

local function runStorm()
	local center = World.RandomFieldPosition()
	Remotes.Storm:FireAllClients("warning", center, Config.StormWarning)
	local cloud = makeStormCloud(center)
	task.wait(Config.StormWarning)

	Remotes.Storm:FireAllClients("active", center, Config.StormDuration)
	local endsAt = os.clock() + Config.StormDuration
	while os.clock() < endsAt do
		if stormCount < MAX_STORM_WEATHER then
			local angle = math.random() * math.pi * 2
			local dist = math.sqrt(math.random()) * Config.StormRadius
			local pos = center + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
			spawnWeather(pos, Config.StormLuckMultiplier, true)
		end
		task.wait(Config.StormSpawnInterval)
	end

	Remotes.Storm:FireAllClients("ended", center, 0)
	cloud:Destroy()
end

function Weather.Start()
	-- Normaal weer
	task.spawn(function()
		while true do
			if normalCount < Config.MaxWeatherInWorld then
				spawnWeather(World.RandomFieldPosition(), 1, false)
			end
			task.wait(Config.WeatherSpawnInterval)
		end
	end)

	-- Serverstorm elke paar minuten
	task.spawn(function()
		while true do
			task.wait(Config.StormInterval - Config.StormWarning)
			local ok, err = pcall(runStorm)
			if not ok then
				warn("[Weather] Storm mislukt:", err)
			end
		end
	end)
end

return Weather
