local Promise = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/Promise.lua"))()
local TableUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/TableUtil.lua"))()
local TweenService = game:GetService("TweenService")

local TweenModel = function(ModelToTween : Model, CFrame : CFrame, Time: number, Delay: number)
	Time = Time or 1000
	Delay = Delay or 1000
	local tInfo = TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, Delay);
    return Promise.new(function(resolve, reject)
        local CFrameValue = Instance.new("CFrameValue")
        CFrameValue.Value = ModelToTween:GetPrimaryPartCFrame()
    
        CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
            ModelToTween:SetPrimaryPartCFrame(CFrameValue.Value)
        end)

        local Tween = TweenService:Create(CFrameValue, info, { Value = CFrame })
        Tween:Play();

		Tween.Completed:Connect(function() 
			ModelToTween:SetPrimaryPartCFrame(CFrame)
		end)

        resolve(Tween.Completed:Wait())
    end)
end

return TweenModel
