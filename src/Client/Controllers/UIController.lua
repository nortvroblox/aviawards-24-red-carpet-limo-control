local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Iris = require(ReplicatedStorage.LimoPackages.iris).Init()
local Knit = require(ReplicatedStorage.LimoPackages.knit)

local LimoUIController: Controller = Knit.CreateController({ Name = "LimoUIController" })
local Limo = workspace:WaitForChild("LimoModel"):WaitForChild("Limo")
local LimoService

function LimoUIController:KnitStart()
	LimoService = Knit.GetService("LimoService")
	Limo:WaitForChild("Humanoid")
	Limo.Humanoid:WaitForChild("Animator")

	local limoAnimationTrack: AnimationTrack
	repeat
		limoAnimationTrack = Limo.Humanoid.Animator:GetPlayingAnimationTracks()[1]
		task.wait()
	until limoAnimationTrack

	Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
	Iris:Connect(require(script.Parent.Parent.ControlUI)({
		getLimoState = function()
			return LimoService.CurrentState:Get()
		end,
		getLimoAnimationProgress = function()
			return limoAnimationTrack.TimePosition / limoAnimationTrack.Length
		end,
		getLimoCurrentPlayers = function()
			return LimoService.CurrentPlayers:Get()
		end,
		startEnterSequence = function(players: { Player })
			LimoService.RestartLimo:Fire(players)
		end,
		startExitSequence = function()
			LimoService.ContinueLimo:Fire()
		end,
	}))
end

return LimoUIController
