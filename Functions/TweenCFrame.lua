local Promise = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/Promise.lua"))()
local TableUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/TableUtil.lua"))()
local tInfo = TweenInfo.new();

local TweenService = game:GetService("TweenService")

local TweenModel = function(ModelToTween : Model, CFrame : CFrame)
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
