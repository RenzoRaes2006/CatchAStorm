-- Alle getallen van de game op één plek. Pas hier kansen, prijzen en beloningen aan.

local Config = {}

export type WeatherType = {
	id: string,
	name: string,
	rarity: string,
	weight: number, -- kans bij verschijnen (relatief)
	income: number, -- munten per seconde in het lab
	netTier: number, -- minimaal net dat nodig is
	color: Color3,
	size: number,
}

Config.Weather = {
	{ id = "RainCloud", name = "Regenwolkje", rarity = "Gewoon", weight = 40, income = 1, netTier = 1, color = Color3.fromRGB(170, 190, 210), size = 4 },
	{ id = "WindGust", name = "Windvlaag", rarity = "Gewoon", weight = 25, income = 2, netTier = 1, color = Color3.fromRGB(200, 240, 230), size = 4 },
	{ id = "Hail", name = "Hagelbui", rarity = "Ongewoon", weight = 15, income = 5, netTier = 2, color = Color3.fromRGB(230, 240, 255), size = 4.5 },
	{ id = "Lightning", name = "Bliksemschicht", rarity = "Zeldzaam", weight = 10, income = 15, netTier = 3, color = Color3.fromRGB(255, 240, 90), size = 5 },
	{ id = "Tornado", name = "Mini-tornado", rarity = "Zeldzaam", weight = 6, income = 30, netTier = 3, color = Color3.fromRGB(150, 140, 130), size = 5.5 },
	{ id = "Blizzard", name = "Sneeuwstorm", rarity = "Episch", weight = 3, income = 80, netTier = 4, color = Color3.fromRGB(180, 230, 255), size = 6 },
} :: { WeatherType }

Config.RarityColors = {
	Gewoon = Color3.fromRGB(200, 200, 200),
	Ongewoon = Color3.fromRGB(90, 200, 90),
	Zeldzaam = Color3.fromRGB(80, 150, 255),
	Episch = Color3.fromRGB(180, 90, 255),
	Legendarisch = Color3.fromRGB(255, 170, 30),
	Mythisch = Color3.fromRGB(255, 60, 90),
} :: { [string]: Color3 }

-- Varianten: kans per vangst en vermenigvuldiger voor het inkomen.
Config.Variants = {
	{ id = "Cosmic", name = "Kosmisch", chance = 0.001, multiplier = 25 },
	{ id = "Frozen", name = "Bevroren", chance = 0.01, multiplier = 5 },
	{ id = "Golden", name = "Gouden", chance = 0.05, multiplier = 3 },
}

-- Netten: tier 1 heeft iedereen al.
Config.Nets = {
	{ tier = 1, name = "Vlindernet", price = 0 },
	{ tier = 2, name = "Visnet", price = 250 },
	{ tier = 3, name = "Koperen net", price = 2500 },
	{ tier = 4, name = "IJzeren net", price = 20000 },
}

-- Planken in het lab. Elke plank heeft 5 plekken voor potten.
Config.SlotsPerShelf = 5
Config.StartShelves = 2
Config.MaxShelves = 8
function Config.ShelfPrice(currentShelves: number): number
	return math.floor(150 * 2.5 ^ (currentShelves - Config.StartShelves))
end

-- Weer in de wereld
Config.MaxWeatherInWorld = 18
Config.WeatherSpawnInterval = 2.5 -- seconden tussen nieuwe weer-objecten
Config.WeatherLifetime = 45 -- seconden voordat weer weer verdwijnt
Config.WorldSize = 360 -- breedte van de Groene Weide in studs
Config.CatchHoldSeconds = 0.6

-- Serverstorm
Config.StormInterval = 300 -- elke 5 minuten
Config.StormWarning = 30 -- seconden waarschuwing vooraf
Config.StormDuration = 60
Config.StormRadius = 60
Config.StormLuckMultiplier = 5
Config.StormSpawnInterval = 0.6

-- Offline inkomen
Config.MaxOfflineSeconds = 2 * 60 * 60

-- Geluksboost (van het rad of beloningen)
Config.LuckBoostMultiplier = 2

-- Dagelijks rad. Elke dag (UTC) één gratis draai.
-- kind: "Coins" (amount = seconden lab-inkomen, minimaal minCoins), "Luck" (amount = minuten), "Weather" (amount = weer-id)
Config.WheelPrizes = {
	{ label = "Munten", kind = "Coins", seconds = 120, minCoins = 100, weight = 30, color = Color3.fromRGB(255, 205, 60) },
	{ label = "Geluk 10 min", kind = "Luck", minutes = 10, weight = 20, color = Color3.fromRGB(90, 200, 120) },
	{ label = "Veel munten", kind = "Coins", seconds = 600, minCoins = 500, weight = 15, color = Color3.fromRGB(255, 150, 40) },
	{ label = "Hagelbui", kind = "Weather", weatherId = "Hail", weight = 15, color = Color3.fromRGB(150, 200, 255) },
	{ label = "Geluk 30 min", kind = "Luck", minutes = 30, weight = 10, color = Color3.fromRGB(40, 170, 90) },
	{ label = "Bliksem", kind = "Weather", weatherId = "Lightning", weight = 7, color = Color3.fromRGB(80, 120, 255) },
	{ label = "Jackpot", kind = "Coins", seconds = 3600, minCoins = 5000, weight = 2, color = Color3.fromRGB(230, 60, 90) },
	{ label = "Sneeuwstorm", kind = "Weather", weatherId = "Blizzard", weight = 1, color = Color3.fromRGB(170, 90, 255) },
}

-- Speeltijd-beloningen: de eerste meteen, daarna steeds twee keer zo lang wachten
-- (na 0, 2, 6, 14, 30, 62 en 126 minuten speeltijd op een dag).
Config.PlaytimeRewards = {
	{ kind = "Coins", seconds = 30, minCoins = 50 },
	{ kind = "Coins", seconds = 60, minCoins = 100 },
	{ kind = "Luck", minutes = 5 },
	{ kind = "Coins", seconds = 300, minCoins = 400 },
	{ kind = "Weather", weatherId = "Lightning" },
	{ kind = "Coins", seconds = 1200, minCoins = 2000 },
	{ kind = "Weather", weatherId = "Blizzard" },
}

-- Minuten speeltijd waarop beloning n beschikbaar wordt: 0, 2, 6, 14, 30, ...
function Config.PlaytimeUnlockMinutes(index: number): number
	return 2 ^ index - 2
end

function Config.GetWeather(id: string): WeatherType?
	for _, w in Config.Weather do
		if w.id == id then
			return w
		end
	end
	return nil
end

function Config.GetVariant(id: string?)
	if id == nil then
		return nil
	end
	for _, v in Config.Variants do
		if v.id == id then
			return v
		end
	end
	return nil
end

function Config.JarIncome(weatherId: string, variantId: string?): number
	local w = Config.GetWeather(weatherId)
	if not w then
		return 0
	end
	local v = Config.GetVariant(variantId)
	return w.income * (if v then v.multiplier else 1)
end

function Config.FormatNumber(n: number): string
	n = math.floor(n)
	if n >= 1e9 then
		return string.format("%.1fmld", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fmln", n / 1e6)
	elseif n >= 1e4 then
		return string.format("%.1fk", n / 1e3)
	end
	return tostring(n)
end

return Config
