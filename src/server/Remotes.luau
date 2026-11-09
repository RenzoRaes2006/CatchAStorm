-- Maakt alle RemoteEvents en RemoteFunctions aan in ReplicatedStorage.Remotes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Remotes"

local function event(name: string): RemoteEvent
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

local function func(name: string): RemoteFunction
	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = folder
	return remote
end

local Remotes = {
	State = event("State"), -- server -> client: volledige stand van de speler
	Notify = event("Notify"), -- server -> client: korte melding (tekst, kleur)
	Storm = event("Storm"), -- server -> iedereen: storm-fase
	BuyNet = func("BuyNet"),
	BuyShelf = func("BuyShelf"),
	SpinWheel = func("SpinWheel"),
	ClaimPlaytime = func("ClaimPlaytime"),
}

folder.Parent = ReplicatedStorage

return Remotes
