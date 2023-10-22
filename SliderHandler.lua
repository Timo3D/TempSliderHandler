local gs = game:GetService("GamepadService")
local SliderModule = require(game:GetService("ReplicatedStorage"):WaitForChild("SliderModule"))  -- Adjust the path to where your ModuleScript is located

local detents = 50
local container = script.Parent

container.SelectionGained:Connect(function()
	gs:EnableGamepadCursor(container)
end)

SliderModule.Initialize(container, detents)
