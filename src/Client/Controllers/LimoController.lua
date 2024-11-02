local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.LimoPackages.knit)

local LimoController = Knit.CreateController({ Name = "LimoController" })
local Limo = workspace:WaitForChild("LimoModel"):WaitForChild("Limo")
local LimoService

local UseLimoCam = false

function LimoController:KnitStart()
	self.areInLimo = {}
	LimoService = Knit.GetService("LimoService")
	Limo:WaitForChild("Humanoid")
	Limo.Humanoid:WaitForChild("Animator")

	local CurrentCamera = workspace.CurrentCamera

	LimoService.CurrentPlayers:Observe(function(players)
		local selfIsInPlayers = false
		for _, player in ipairs(players) do
			if player == Players.LocalPlayer then
				selfIsInPlayers = true
				break
			end
		end

		for player, _ in pairs(self.areInLimo) do
			local character = player.Character
			if not players[player] and character then
				character.HumanoidRootPart.Anchored = false
				character.Humanoid.Sit = false
			end
		end
		self.areInLimo = {}

		if UseLimoCam then
			if selfIsInPlayers then
				self.isInLimo = true
				CurrentCamera.CameraType = Enum.CameraType.Scriptable
				CurrentCamera.FieldOfView = 30
			elseif self.isInLimo then
				self.isInLimo = false
				CurrentCamera.CameraType = Enum.CameraType.Custom
				CurrentCamera.FieldOfView = 70
			end
		end
	end)

	RunService:BindToRenderStep("LimoController", Enum.RenderPriority.Camera.Value, function()
		if self.isInLimo and UseLimoCam then
			CurrentCamera.CFrame = Limo.LimoPlayerCam.CFrame
		end

		local playerSortedList = LimoService.CurrentPlayers:Get() or {}
		table.sort(playerSortedList, function(a, b)
			return a.Name < b.Name
		end)
		--// ensure consistent order

		for i, player in ipairs(playerSortedList) do
			local seat = Limo.Seats[tostring(i)]
			if not seat then
				continue
			end
			local character = player.Character
			if character then
				character.HumanoidRootPart.Anchored = true
				character.HumanoidRootPart.CFrame = seat.CFrame
				character.Humanoid.Sit = true
			end
			self.areInLimo[player] = true
		end
	end)
end

return LimoController
