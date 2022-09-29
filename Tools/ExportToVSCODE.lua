local game = remodel.readPlaceAsset(--[[ your place id here]]--)

local Exports = {
    "Workspace",
    "StarterPlayer",
    "StarterGui",
    "ReplicatedFirst",
    "ServerScriptService",
    "ReplicatedStorage",
    "StarterPack"
}

local thisFolder = io.popen("cd"):read():gsub("\\", "/")

local function ToExplorerFolder(Path)
    return thisFolder.."/src/"..Path
end

local WhatToExport = {
    ["Script"] = true,
    ["LocalScript"] = true,
    ["ModuleScript"] = true,
}

local ObjectNameEndings = {
    ["Script"] = ".server.lua",
    ["LocalScript"] = ".client.lua";
    ["ModuleScript"] = ".lua",
}

function split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end



local Functions = {}

function InstanceCount(Instance)
    local Amount = 0;

    local Parent = Instance.Parent

    for _, Child in pairs(Parent:GetChildren()) do
        if Child.Name == Instance.Name then
            Amount = Amount + 1
        end
    end

    return Amount;
end

Functions.Model = function(Path, Instance)
    local PathSplitted = split(Path, "/")
    PathSplitted[#PathSplitted] = nil;
    Path = table.concat(PathSplitted, "/")
    local ScriptName = Instance.Name..".rbxmx"
    local FileToWrite = Path..ScriptName

    local FolderFound, _ = pcall(function() 
        return remodel.isDir(Path)
    end)

    if(not FolderFound) then
        remodel.createDirAll(Path)
    end

    local FileFound, _ = pcall(function() 
        return remodel.isFile(FileToWrite)
    end)

    if(not FileFound) then
        local Count = InstanceCount(Instance)
        if Count > 0 then
            for i = 1, Count do
                ScriptName = PathSplitted[#PathSplitted]..i..".rbxmx"
                FileToWrite = Path..ScriptName
                remodel.writeModelFile(FileToWrite, Instance)
            end
        else
            remodel.writeModelFile(FileToWrite, Instance)
        end
    end
end

Functions.Script = function(Path, Instance)
    if(Path:find("Packages") ~= nil) then return end
    if(Path:find("ServerPackages") ~= nil) then return end
    local function GetEndingName()
        local Ending = ObjectNameEndings[Instance.ClassName]
    
        return Ending;
    end
    local FileName = Instance.Name .. GetEndingName();
    local FileToWrite = Path .. "/" .. FileName;

    local FolderExits = pcall(function() 
        return remodel.irDir(Path)
    end)
    if (not FolderExits) then
        remodel.createDirAll(Path)
    end
    local FileExists = pcall(function()
        return remodel.isFile(FileToWrite)
    end)
    if (not FileExists) then
        remodel.writeFile(FileToWrite, remodel.getRawProperty(Instance, "Source"))
    end
end

Functions.LocalScript = Functions.Script;
Functions.ModuleScript = Functions.Script;

function array_inverse(x)
    local n, m = #x, #x/2
    for i=1, m do
      x[i], x[n-i+1] = x[n-i+1], x[i]
    end
    return x
end

function contains_string(tbl, string)
    for _, value in ipairs(tbl) do
        if value == string then
            return true
        end
    end
    return false;
end

function GetObjectPath(Object)
    local Names = {}
    local Parent = Object.Parent;
    repeat
        table.insert(Names, Parent.Name)
        Parent = Parent.Parent
    until Parent == game;
    Names = array_inverse(Names);
    return table.concat(Names, "/");
end

for _, ToExport in ipairs(Exports) do
    local Object = game[ToExport]

    local ObjectContents = Object:GetDescendants()

    for _, ObjectContent in ipairs(ObjectContents) do
        local Path = ToExplorerFolder(GetObjectPath(ObjectContent))
        local FuncToExec = Functions[ObjectContent.ClassName]
        if WhatToExport[ObjectContent.ClassName] then
            if not FuncToExec then
                print("Missing Function to Export: "..ObjectContent.ClassName)
            else
                if(type(FuncToExec) == "function") then
                    FuncToExec(Path, ObjectContent)
                end
            end
        end
    end
end
