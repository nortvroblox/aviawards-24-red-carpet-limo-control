local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.LimoPackages.knit)

local Limo = workspace.LimoModel.Limo
local LimoPlayersWaiting = workspace.LimoModel.LimoPlayerWaiting
local LimoAnimation = ReplicatedStorage.LimoCommon.Assets.LimoAnimation
local LimoAnimationTrack: AnimationTrack = Limo.Humanoid.Animator:LoadAnimation(LimoAnimation)
local LimoStart, LimoEnd = 35, 44 --// GetTimeOfKeyframe is not available for CurveAnimation

local GroupId = 5287078
local PermissionLevel = RunService:IsStudio() and -1 or 50

local LimoService = Knit.CreateService({
	Name = "LimoService",
	Client = {
		CurrentPlayers = Knit.CreateProperty({}),
		CurrentState = Knit.CreateProperty("Stopped"),

		RestartLimo = Knit.CreateSignal(),
		ContinueLimo = Knit.CreateSignal(),
	},
})

local function IsTimeRangeOnHold(time: number)
	return time >= LimoStart and time <= LimoEnd
end

function LimoService:KnitStart()
	LimoAnimationTrack:Play()
	LimoAnimationTrack:AdjustSpeed(0)
end

function LimoService:KnitInit()
	LimoAnimationTrack:GetPropertyChangedSignal("IsPlaying"):Connect(function()
		self.Client.CurrentState:Set(LimoAnimationTrack.IsPlaying and "Playing" or "Stopped")
	end)

	RunService.Heartbeat:Connect(function()
		if not Limo.HumanoidRootPart.Position:FuzzyEq(Vector3.zero, 0.1) then
			Limo.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 0, 0))
		end

		local playerSortedList = self.Client.CurrentPlayers:Get()
		table.sort(playerSortedList, function(a, b)
			return a.Name < b.Name
		end)

		for i, player in ipairs(playerSortedList) do
			local seat = Limo.Seats[tostring(i)]
			if not seat then
				continue
			end
			local character = player.Character
			if character then
				character.HumanoidRootPart.CFrame = seat.CFrame
			end
		end

		if IsTimeRangeOnHold(LimoAnimationTrack.TimePosition) then
			LimoAnimationTrack:AdjustSpeed(0)
			LimoService.Client.CurrentPlayers:Set({})
		end
	end)

	self.Client.RestartLimo:Connect(function(player, players: { Player })
		if player:GetRankInGroup(GroupId) < PermissionLevel then
			return
		end

		local newPlayers = {}
		for _, player in ipairs(players) do
			if player.Character then
				table.insert(newPlayers, player)
			end
		end
		LimoAnimationTrack.TimePosition = LimoStart
		LimoAnimationTrack:Play()
		LimoAnimationTrack:AdjustSpeed(1)
		LimoService.Client.CurrentPlayers:Set(newPlayers)
	end)

	self.Client.ContinueLimo:Connect(function(player)
		if player:GetRankInGroup(GroupId) < PermissionLevel then
			return
		end
		LimoAnimationTrack:Play()
		LimoAnimationTrack:AdjustSpeed(1)
		LimoAnimationTrack.TimePosition = LimoEnd
		LimoService.Client.CurrentPlayers:Set({})
	end)
end

return LimoService
