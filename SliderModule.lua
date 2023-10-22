local module = {}

local UserInputService = game:GetService("UserInputService")

function module.Initialize(container, detents)
	local slider : Frame = container:WaitForChild("Slider")
	local count : TextLabel = slider:WaitForChild("Count")
	local origColor = slider.BackgroundColor3
	local UserInputService = game:GetService("UserInputService")
	slider.Size = UDim2.new(0, container.AbsoluteSize.Y, 1, 0)

	local plr = game.Players.LocalPlayer
	local mouse = plr:GetMouse()

	local isDragging = false
	local initialX = nil
	local moveConnection = nil  -- To manage the connection to MouseMove event
	local lastSnappedWidth = nil  -- Keep track of the last width value that triggered a tween
	local initialSliderWidth = nil  -- Store the initial width of the slider when dragging starts
	local lastMouseX = nil  -- Store the previous mouse X position

	local function onMouseMove()
		if isDragging and initialX then
			-- Calculate the desired width based on the difference between the current mouse position and the starting mouse position
			local desiredWidth = initialSliderWidth + (mouse.X - initialX)

			-- Clamp the desired width to the bounds of the container
			desiredWidth = math.clamp(desiredWidth, 0, container.AbsoluteSize.X)

			-- Calculate the width of each detent
			local detentWidth = container.AbsoluteSize.X / detents

			-- Round the desired width to the nearest detent
			local snappedWidth = math.round(desiredWidth / detentWidth) * detentWidth

			-- Determine which detent the slider is on (1-based indexing)
			local currentDetent = math.round(snappedWidth / detentWidth)

			-- Update the count label
			count.Text = tostring(currentDetent)
			-- Check if the snappedWidth is different from the lastSnappedWidth
			if snappedWidth ~= lastSnappedWidth then
				game:GetService("TweenService"):Create(slider, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, math.clamp(snappedWidth, container.AbsoluteSize.Y, container.AbsoluteSize.X), 1, 0)}):Play()
				lastSnappedWidth = snappedWidth
				local mouseMovingLeft = mouse.X < (lastMouseX or mouse.X)  -- Check if the mouse is moving to the left
				if currentDetent <= 0 and mouseMovingLeft then
					slider.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
				elseif currentDetent >= detents then
					slider.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
				end
				game:GetService("TweenService"):Create(slider, TweenInfo.new(1, Enum.EasingStyle.Linear), {BackgroundColor3 = origColor}):Play()
			end
			lastMouseX = mouse.X  -- Update the lastMouseX value for the next iteration
		end
	end

	local function onInputChanged(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			onMouseMove()
		end
	end

	local function onInputBegan(input, GPE)
		if not GPE then
			print(input.UserInputType)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = true
				initialX = input.Position.X
				initialSliderWidth = slider.AbsoluteSize.X

				-- Ensure we connect to InputChanged or TouchMove only after initialX is set
				if moveConnection then
					moveConnection:Disconnect()  -- Disconnect any previous connections just to be safe
				end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConnection = UserInputService.InputChanged:Connect(onInputChanged)
				else
					moveConnection = UserInputService.TouchMoved:Connect(onMouseMove)
				end
			end
		end
	end

	local function onInputEnded(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
			initialX = nil
			if moveConnection then
				moveConnection:Disconnect()  -- Disconnect from MouseMove or TouchMove event
				moveConnection = nil
			end
		end
	end

	container.InputBegan:Connect(onInputBegan)
	UserInputService.TouchEnded:Connect(onInputEnded)
	UserInputService.InputEnded:Connect(onInputEnded)  -- For mouse input
end

return module
