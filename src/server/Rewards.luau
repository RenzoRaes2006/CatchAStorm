-- Dagelijks rad en speeltijd-beloningen (0, 2, 6, 14, 30, ... minuten).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local Lab = require(script.Parent.Lab)
local Remotes = require(script.Parent.Remotes)

local Rewards = {}

-- Geeft een beloning en geeft een tekst terug voor de melding.
function Rewards.Grant(player: Player, reward): string
	local data = PlayerData.Get(player)
	if not data then
		return ""
	end
	if reward.kind == "Coins" then
		local amount = math.max(reward.minCoins or 0, math.floor(PlayerData.Income(data) * (reward.seconds or 0)))
		PlayerData.AddCoins(player, amount)
		PlayerData.Sync(player)
		return Config.FormatNumber(amount) .. " munten"
	elseif reward.kind == "Luck" then
		data.luckUntil = math.max(os.time(), data.luckUntil) + reward.minutes * 60
		PlayerData.Sync(player)
		return reward.minutes .. " minuten geluksboost"
	elseif reward.kind == "Weather" then
		local weather = Config.GetWeather(reward.weatherId)
		local result = Lab.AddJar(player, reward.weatherId, nil)
		if result == "full" then
			-- Lab vol en de pot is niet beter: geef munten als vervanging.
			local amount = (weather and weather.income or 1) * 300
			PlayerData.AddCoins(player, amount)
			PlayerData.Sync(player)
			return Config.FormatNumber(amount) .. " munten (je lab was vol)"
		end
		return "een pot " .. (weather and weather.name or reward.weatherId)
	end
	return ""
end

local function pickWheelIndex(): number
	local total = 0
	for _, prize in Config.WheelPrizes do
		total += prize.weight
	end
	local roll = math.random() * total
	for i, prize in Config.WheelPrizes do
		roll -= prize.weight
		if roll <= 0 then
			return i
		end
	end
	return 1
end

local function resetDayIfNeeded(data)
	local today = PlayerData.Today()
	if data.playDay ~= today then
		data.playDay = today
		data.playSeconds = 0
		data.playClaimed = 0
		return true
	end
	return false
end

function Rewards.Start()
	Remotes.SpinWheel.OnServerInvoke = function(player: Player)
		local data = PlayerData.Get(player)
		if not data then
			return nil
		end
		if data.wheelDay == PlayerData.Today() then
			return nil
		end
		data.wheelDay = PlayerData.Today()
		local index = pickWheelIndex()
		-- De client laat het rad eerst draaien en toont daarna de prijs.
		local text = Rewards.Grant(player, Config.WheelPrizes[index])
		PlayerData.Sync(player)
		return index, text
	end

	Remotes.ClaimPlaytime.OnServerInvoke = function(player: Player)
		local data = PlayerData.Get(player)
		if not data then
			return false, "Even geduld."
		end
		resetDayIfNeeded(data)
		local nextIndex = data.playClaimed + 1
		local reward = Config.PlaytimeRewards[nextIndex]
		if not reward then
			return false, "Alle beloningen van vandaag zijn binnen. Morgen weer!"
		end
		if data.playSeconds < Config.PlaytimeUnlockMinutes(nextIndex) * 60 then
			return false, "Nog even spelen voor de volgende beloning."
		end
		data.playClaimed = nextIndex
		local text = Rewards.Grant(player, reward)
		PlayerData.Sync(player)
		return true, "Beloning: " .. text
	end

	-- Speeltijd telt per dag, niet per keer inloggen.
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				local data = PlayerData.Get(player)
				if data then
					if resetDayIfNeeded(data) then
						PlayerData.Sync(player)
					end
					data.playSeconds += 1
				end
			end
		end
	end)
end

return Rewards
