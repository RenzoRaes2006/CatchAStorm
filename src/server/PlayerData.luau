-- Laadt en bewaart de voortgang van spelers (DataStore) en stuurt de stand naar de client.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(script.Parent.Remotes)

local PlayerData = {}

local STORE_NAME = "CatchAStorm_v1"
local AUTOSAVE_SECONDS = 120

local store = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(STORE_NAME)
	end)
	if ok then
		store = result
	else
		warn("[PlayerData] DataStore niet beschikbaar, voortgang wordt niet opgeslagen:", result)
	end
end

local profiles: { [Player]: any } = {}

function PlayerData.Today(): number
	return math.floor(os.time() / 86400)
end

local function defaultData()
	return {
		coins = 0,
		netTier = 1,
		shelves = Config.StartShelves,
		jars = {}, -- lijst van { w = weatherId, v = variantId of nil }
		totalCaught = 0,
		wheelDay = -1,
		playDay = PlayerData.Today(),
		playSeconds = 0,
		playClaimed = 0,
		luckUntil = 0,
		lastOnline = os.time(),
	}
end

local function reconcile(data)
	local defaults = defaultData()
	for key, value in defaults do
		if data[key] == nil then
			data[key] = value
		end
	end
	return data
end

function PlayerData.Get(player: Player)
	return profiles[player]
end

function PlayerData.Capacity(data): number
	return data.shelves * Config.SlotsPerShelf
end

function PlayerData.Income(data): number
	local total = 0
	for _, jar in data.jars do
		total += Config.JarIncome(jar.w, jar.v)
	end
	return total
end

-- Alles wat de client nodig heeft om de UI te tekenen.
function PlayerData.Sync(player: Player)
	local data = profiles[player]
	if not data then
		return
	end
	Remotes.State:FireClient(player, {
		coins = data.coins,
		income = PlayerData.Income(data),
		netTier = data.netTier,
		shelves = data.shelves,
		capacity = PlayerData.Capacity(data),
		jars = data.jars,
		totalCaught = data.totalCaught,
		wheelReady = data.wheelDay ~= PlayerData.Today(),
		playSeconds = data.playSeconds,
		playClaimed = data.playClaimed,
		luckLeft = math.max(0, data.luckUntil - os.time()),
		serverTime = os.time(),
	})
end

function PlayerData.SetCoins(player: Player, amount: number)
	local data = profiles[player]
	if not data then
		return
	end
	data.coins = amount
	local leaderstats = player:FindFirstChild("leaderstats")
	local coinsValue = leaderstats and leaderstats:FindFirstChild("Munten")
	if coinsValue then
		coinsValue.Value = math.floor(amount)
	end
end

function PlayerData.AddCoins(player: Player, amount: number)
	local data = profiles[player]
	if data then
		PlayerData.SetCoins(player, data.coins + amount)
	end
end

local function save(player: Player)
	local data = profiles[player]
	if not data or not store then
		return
	end
	data.lastOnline = os.time()
	local ok, err = pcall(function()
		store:SetAsync("player_" .. player.UserId, data)
	end)
	if not ok then
		warn("[PlayerData] Opslaan mislukt voor", player.Name, err)
	end
end

local function load(player: Player)
	local data = nil
	if store then
		for _ = 1, 3 do
			local ok, result = pcall(function()
				return store:GetAsync("player_" .. player.UserId)
			end)
			if ok then
				data = result
				break
			end
			task.wait(1)
		end
	end
	data = reconcile(data or defaultData())

	-- Nieuwe dag: speeltijd-beloningen beginnen opnieuw.
	if data.playDay ~= PlayerData.Today() then
		data.playDay = PlayerData.Today()
		data.playSeconds = 0
		data.playClaimed = 0
	end

	-- Inkomen terwijl de speler weg was (maximaal 2 uur).
	local away = math.clamp(os.time() - data.lastOnline, 0, Config.MaxOfflineSeconds)
	local offlineCoins = math.floor(away * PlayerData.Income(data))
	data.coins += offlineCoins
	data.lastOnline = os.time()

	return data, offlineCoins
end

-- onLoaded(player, data, offlineCoins) wordt aangeroepen zodra de data klaar is.
function PlayerData.Start(onLoaded: (Player, any, number) -> ())
	local function onPlayerAdded(player: Player)
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		local coinsValue = Instance.new("NumberValue")
		coinsValue.Name = "Munten"
		coinsValue.Parent = leaderstats
		leaderstats.Parent = player

		local data, offlineCoins = load(player)
		if not player.Parent then
			return
		end
		profiles[player] = data
		PlayerData.SetCoins(player, data.coins)
		onLoaded(player, data, offlineCoins)
		PlayerData.Sync(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		save(player)
		profiles[player] = nil
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			task.spawn(save, player)
		end
		task.wait(3)
	end)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_SECONDS)
			for _, player in Players:GetPlayers() do
				task.spawn(save, player)
			end
		end
	end)
end

return PlayerData
