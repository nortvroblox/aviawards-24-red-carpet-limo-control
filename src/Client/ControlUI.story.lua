local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.LimoPackages["ui-labs"])
-- return function(parent: GuiObject)
-- end

local controls = {}

local story = {
	controls = controls,
	render = function(props)
		local Iris = require(ReplicatedStorage.LimoPackages.iris)

		Iris.UpdateGlobalConfig({
			UseScreenGUIs = false,
		})
		Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)

		Iris.Init(props.target)

		-- Actual Iris code here:
		Iris:Connect(require(script.Parent.ControlUI)(props))

		return function()
			Iris.Shutdown()
		end
	end,
}

return story
