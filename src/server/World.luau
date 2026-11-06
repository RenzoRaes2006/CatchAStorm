-- Bouwt de Groene Weide en de rij weerlabs met code, zodat de game meteen speelbaar is.
-- Later kun je de map in Studio mooier maken: zolang de onderdelen in Workspace.Map en
-- Workspace.Labs blijven, werkt de code gewoon.

local Lighting = game:GetService("Lighting")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local World = {}

World.PlotCount = 10
World.PlotSpacing = 50
World.PlotSize = Vector3.new(40, 1, 32)
World.PlotRowZ = -(Config.WorldSize / 2) - 30

local function part(props): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		p[key] = value
	end
	return p
end

function World.PlotCFrame(index: number): CFrame
	local x = (index - (World.PlotCount + 1) / 2) * World.PlotSpacing
	return CFrame.new(x, 0.5, World.PlotRowZ)
end

-- Willekeurige plek in het veld waar weer kan verschijnen.
function World.RandomFieldPosition(): Vector3
	local half = Config.WorldSize / 2 - 15
	return Vector3.new(math.random(-half, half), 0, math.random(-half, half))
end

function World.Build()
	local map = Instance.new("Folder")
	map.Name = "Map"

	part({
		Name = "Meadow",
		Size = Vector3.new(Config.WorldSize, 4, Config.WorldSize),
		Position = Vector3.new(0, -2, 0),
		Color = Color3.fromRGB(106, 170, 80),
		Material = Enum.Material.Grass,
		Parent = map,
	})

	part({
		Name = "LabStrip",
		Size = Vector3.new(World.PlotCount * World.PlotSpacing + 40, 4, 70),
		Position = Vector3.new(0, -2, World.PlotRowZ),
		Color = Color3.fromRGB(120, 120, 128),
		Material = Enum.Material.Concrete,
		Parent = map,
	})

	-- Een paar heuvels en bomen zodat het veld niet leeg is.
	math.randomseed(42)
	for _ = 1, 25 do
		local pos = World.RandomFieldPosition()
		local trunk = part({
			Name = "Trunk",
			Size = Vector3.new(2, 10, 2),
			Position = pos + Vector3.new(0, 5, 0),
			Color = Color3.fromRGB(110, 80, 50),
			Material = Enum.Material.Wood,
			Parent = map,
		})
		part({
			Name = "Leaves",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(9, 9, 9),
			Position = trunk.Position + Vector3.new(0, 7, 0),
			Color = Color3.fromRGB(60, 140, 60),
			Material = Enum.Material.Grass,
			Parent = map,
		})
	end
	math.randomseed(os.time())

	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 0.5, World.PlotRowZ + 40)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Parent = map

	map.Parent = workspace

	local labs = Instance.new("Folder")
	labs.Name = "Labs"
	labs.Parent = workspace

	local weatherFolder = Instance.new("Folder")
	weatherFolder.Name = "Weather"
	weatherFolder.Parent = workspace

	Lighting.ClockTime = 14
	Lighting.Brightness = 2
end

return World
