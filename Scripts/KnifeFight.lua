_G.Enabled = false;

local Plataform = Instance.new("Part", game.Workspace)
Plataform.Name = "Plataform"
Plataform.Position = Vector3.new(300, 300, 300);
Plataform.Anchored = true;
Plataform.Size = Vector3.new(100, 1, 100);

local TableUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexbavGamer/Roblox-Scripts/main/TableUtil.lua"))()

local RunService = game:GetService("RunService")

_G.S_Heartbeat = nil;
local Player = game.Players.LocalPlayer;
_G.CharacterAdded = nil;
local Humanoid : Humanoid = nil;

local function GetPlayerKnife()
    local Tools = TableUtil.Filter(Player.Character:GetChildren(), function(children: Instance)
        return children:IsA("Tool")
    end)
    return Tools[1]
end

if(_G.Enabled == false) then
    if(_G.CharacterAdded and _G.CharacterAdded.Connected) then
        _G.CharacterAdded:Disconnect();
        _G.CharacterAdded = nil;
    end
    if(_G.S_Heartbeat and _G.S_Heartbeat.Connected) then
        _G.S_Heartbeat:Disconnect();
        _G.S_Heartbeat = nil
    end
    return
end

game:GetService("Players").LocalPlayer.Character.clientMain.Remote:FireServer(unpack({
    [1] = "Teleport"
}))
task.wait(1);
local function OnCharacterAdded(Character: Model)
    Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
    
    local args = {
        [1] = "Teleport"
    }

    game:GetService("Players").LocalPlayer.Character.clientMain.Remote:FireServer(unpack(args))
    
    _G.S_Heartbeat = RunService.Heartbeat:Connect(function(dt)
        if(_G.Enabled) then
            task.wait(0.1);
            Player.Character.HumanoidRootPart.Position = Plataform.Position
            local args = {
                [1] = "Hit",
                [2] = Player.Character.Humanoid
            }
        
            local Knife = GetPlayerKnife();
            if(Knife ~= nil) then
                game:GetService("Players").LocalPlayer.Character:FindFirstChild(Knife.Name).Knife.Remote:FireServer(unpack(args))
            end
        end
    end)
    local Died; Died = Humanoid.Died:Connect(function()
        Died:Disconnect();
    end)
end

OnCharacterAdded(Player.Character);
_G.CharacterAdded = Player.CharacterAdded:Connect(OnCharacterAdded);

