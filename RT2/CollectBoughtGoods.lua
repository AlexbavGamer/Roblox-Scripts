local Client = game:GetService("Players").LocalPlayer
local GetPlot = function() return getrenv()._G.Plot end
local GetLoadingDock = function() 
    local Plot = tostring(GetPlot())
    local DockNum = string.gsub(Plot, "Plot_", "")
    return game:GetService("Workspace").Map.Landmarks["Loading Dock"]["LoadingDock_" .. DockNum].LoadingSpot
end

local OnBayStorageChanged = function(OnChanged)
    local Plot = tostring(GetPlot())
    local DockNum = string.gsub(Plot, "Plot_", "")
    local BayStorage = game:GetService("Workspace").Map.Landmarks["Loading Dock"]["LoadingDock_"..DockNum].BayStorage
	
    BayStorage.ChildAdded:Connect(OnChanged)
end

local GetVehicle; GetVehicle = function()
    for _, v in next, workspace.PlayerVehicles:GetChildren() do
        if v.Name:match(Client.Name) then
            return v 
        end
    end
    game:GetService("ReplicatedStorage").Remotes.SpawnVehicle:InvokeServer(1, Client.Character.HumanoidRootPart.CFrame * CFrame.new(10, 5, 0))
    task.wait()
    return GetVehicle()
end

local LoadCar = function()
    local Vehicle = GetVehicle()
    Vehicle:SetPrimaryPartCFrame(GetLoadingDock().CFrame)
    Client.Character:SetPrimaryPartCFrame(Vehicle.PrimaryPart.CFrame * CFrame.new(5, 0, 0))
    task.wait(.5)
    game:GetService("ReplicatedStorage").Remotes.LoadVehicle:InvokeServer()
end

local UnloadCar = function()
    for i, v in next, GetPlot():GetDescendants() do
        if v.Name:lower():match("door") then 
            if v:FindFirstChild("Handle") and v:FindFirstChild("Base") then
                local Vehicle = GetVehicle()
				local Position = CFrame.new(v.Base.Position + Vector3.new(6, 0, 5)) * CFrame.Angles(0, -90, 0);
                Vehicle:SetPrimaryPartCFrame(Position)
                Client.Character:SetPrimaryPartCFrame(Vehicle.PrimaryPart.CFrame * CFrame.new(5, 0, 0))
                task.wait(.5)
                game:GetService("ReplicatedStorage").Remotes.UnloadVehicle:InvokeServer()
            end
        end
    end
end

local GetBoughtStuff = function()
    LoadCar()
    task.wait()
    UnloadCar()
end


OnBayStorageChanged(GetBoughtStuff)