local Promise = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/Promise.lua"))()

local function promisePlayTween(tween)
	local promise = Promise.new()

	-- Couple promise state to the tween
	local conn = tween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			promise:Resolve()
		elseif playbackState == Enum.PlaybackState.Cancelled then
			promise:Reject()
		end
	end)

	promise:Finally(function()
		conn:Disconnect()
		tween:Cancel()
	end)

	tween:Play()

	return promise
end

return promisePlayTween;
