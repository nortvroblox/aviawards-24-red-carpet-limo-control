local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("LimoPackages"):WaitForChild("knit"))

-- Add controllers & components:
Knit.AddControllersDeep(script.Controllers)

-- Start Knit:
Knit.Start()
	:andThen(function()
		print("Knit Client has started")
	end)
	:catch(function(err)
		warn("Knit framework failure: " .. tostring(err))
	end)
