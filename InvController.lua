local l__LocalPlayer__1 = game.Players.LocalPlayer
local dataBusy = false

local function getRemote()
    return game.ReplicatedStorage:FindFirstChild("YourRemoteFunction") or
           game.Workspace:FindFirstChild("RemoteFunction")
end

function FindBackground()
    for _,inst in pairs(l__LocalPlayer__1.PlayerGui:GetDescendants()) do
        if((inst.Name == 'Inv' or inst.Name == 'Equipped') and (inst.Parent.ClassName == 'Frame' or inst.Parent.ClassName == 'ImageLabel')) then
            return inst.Parent
        end
    end
end

function AddToDataStore()
    local success, v40 = pcall(function() 
        return require(l__LocalPlayer__1.Character:WaitForChild("Animations"))
    end)
    local success, v41 = pcall(function() 
        return require(l__LocalPlayer__1.Character:WaitForChild("Modifiers"))
    end)
    
    local Background = FindBackground()
    if not Background then return end
    
    local Equipped = Background:FindFirstChild("Equipped")
    local Body = Background:FindFirstChild("Body")
    local Inv = Background:FindFirstChild("Inv")
    
    if not (Equipped and Body and Inv) then return end
    
    local u3 = {
        Equipped = {},
        Inventory = {},
        Body = {}
    }
    
    for i, slot in ipairs(Equipped:GetChildren()) do
        local tool = slot:FindFirstChildWhichIsA("Tool")
        if tool then
            local config = tool:FindFirstChild("Configuration")
            local stackValue = config and config:FindFirstChild("Stack")
            u3.Equipped[i] = {
                Name = tool.Name,
                Stack = stackValue and stackValue.Value or 0
            }
        else
            u3.Equipped[i] = { Name = nil, Stack = nil }
        end
    end
    
    for i, slot in ipairs(Inv:GetChildren()) do
        local tool = slot:FindFirstChildWhichIsA("Tool")
        if tool then
            local config = tool:FindFirstChild("Configuration")
            local stackValue = config and config:FindFirstChild("Stack")
            u3.Inventory[i] = {
                Name = tool.Name,
                Stack = stackValue and stackValue.Value or 0
            }
        else
            u3.Inventory[i] = { Name = nil, Stack = nil }
        end
    end
    
    for i, slot in ipairs(Body:GetChildren()) do
        local tool = slot:FindFirstChildWhichIsA("Tool")
        if tool then
            local config = tool:FindFirstChild("Configuration")
            local stackValue = config and config:FindFirstChild("Stack")
            local layoutOrder = slot:FindFirstChild("LayoutOrder") and slot.LayoutOrder or i
            u3.Body[layoutOrder] = {
                Name = tool.Name,
                Stack = stackValue and stackValue.Value or 0
            }
        else
            u3.Body[i] = { Name = nil, Stack = nil }
        end
    end

    local remote = getRemote()
    if remote and remote.ClassName == "RemoteFunction" then
        local success, err = pcall(function()
            local method = string.sub("xupdateStatsx", 2, -2)
            remote:InvokeServer(method, u3)
        end)
    end
    
    if Background:FindFirstChild("Saving") then
        Background.Saving.Visible = false
    end
end

AddModifier = function(p1, p2)
    local v1 = p1:Clone()
    v1.Parent = p1.Parent
    v1.Name = p2
end

RemoveModifier = function(p3, p4)
    local v2 = p3.Parent:FindFirstChild(p3.Name)
    if not v2 then return end
    local v3 = v2:FindFirstChild(p4)
    if v3 then
        v3:Destroy()
    end
end

local MainFunction = {}

function MainFunction.AddToInvLOL(p18)
    if dataBusy then return false end
    
    dataBusy = true
    local Background = FindBackground()
    if not Background then 
        dataBusy = false
        return false 
    end
    
    local Inv = Background:FindFirstChild("Inv")
    if not Inv then 
        dataBusy = false
        return false 
    end
    
    if Background:FindFirstChild("Saving") then
        Background.Saving.Visible = true
    end
    
    local itemAdded = false
    local v126 = p18:Clone()
    
    local success, err = pcall(function()
        local config = v126:WaitForChild("Configuration")
        local repObj = config:WaitForChild("ReplicatedStorageObject")
        repObj.Value = p18
    end)
    
    if not success then
        dataBusy = false
        return false
    end
    
    local v127 = v126:FindFirstChild("Interact") and v126.Interact:Clone()
    
    for i = 1, 21 do
        local slot = Inv:FindFirstChild(tostring(i))
        if slot and not slot:FindFirstChild("Interact") and not itemAdded then
            itemAdded = true
            
            AddModifier(v126.Configuration.Weight, v126.Name)
            v126.Parent = slot
            
            if v127 then
                v127.Parent = slot
                v127.Position = v127.Position - UDim2.new(0, 0, 0.1, 0)
            end
            
            local imageLabel = slot:FindFirstChild("Image")
            if imageLabel and v126:FindFirstChild("Decal") then
                imageLabel.Image = v126.Decal.Image
            end
            
            local stackLabel = slot:FindFirstChild("Stack")
            if stackLabel then
                local stackValue = v126.Configuration:FindFirstChild("Stack")
                if stackValue then
                    stackLabel.Text = stackValue.Value
                    stackLabel.Visible = true
                else
                    stackLabel.Visible = false
                end
            end
            
            break
        end
    end
    
    spawn(function()
        wait(0.5)
        dataBusy = false
        if Background:FindFirstChild("Saving") then
            Background.Saving.Visible = false
        end
    end)
    
    if itemAdded then
        AddToDataStore()
        return true
    end
    
    AddToDataStore()
    return false
end

return MainFunction
