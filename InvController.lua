local l__LocalPlayer__1 = game.Players.LocalPlayer
local dataBusy = false

local function getRemote()
    return game.ReplicatedStorage:FindFirstChild("YourRemoteFunction") or
           game.Workspace:FindFirstChild("RemoteFunction")
end

function FindBackground()
    local gui = l__LocalPlayer__1:FindFirstChild("PlayerGui")
    if not gui then return end
    
    for _, inst in pairs(gui:GetDescendants()) do
        if ((inst.Name == 'Inv' or inst.Name == 'Equipped') and 
            (inst.Parent and (inst.Parent:IsA('Frame') or inst.Parent:IsA('ImageLabel')))) then
            return inst.Parent
        end
    end
end

function AddToDataStore()
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
            u3.Eipped[i] = { Name = nil, Stack = nil }
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
    if remote and remote:IsA("RemoteFunction") then
        pcall(function()
            local method = string.sub("xupdateStatsx", 2, -2)
            remote:InvokeServer(method, u3)
        end)
    end

    pcall(function()
        if Background:FindFirstChild("Saving") then
            Background.Saving.Visible = false
        end
    end)
end

local MainFunction = {}

function MainFunction.AddToInvLOL(p18)
    if dataBusy then return false end
    if not p18 then return false end

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

    pcall(function()
        if Background:FindFirstChild("Saving") then
            Background.Saving.Visible = true
        end
    end)

    local itemAdded = false
    local v126 = p18:Clone()

    pcall(function()
        local config = v126:FindFirstChild("Configuration")
        if config then
            local repObj = config:FindFirstChild("ReplicatedStorageObject")
            if repObj then
                repObj.Value = p18
            end
        end
    end)

    local v127 = v126:FindFirstChild("Interact") and v126.Interact:Clone()

    for i = 1, 21 do
        local slot = Inv:FindFirstChild(tostring(i))
        if slot and not slot:FindFirstChild("Interact") and not itemAdded then
            itemAdded = true

            v126.Parent = slot

            if v127 then
                v127.Parent = slot
                v127.Position = v127.Position - UDim2.new(0, 0, 0.1, 0)
            end

            local imageLabel = slot:FindFirstChild("Image")
            local decal = v126:FindFirstChild("Decal")
            if imageLabel and decal then
                imageLabel.Image = decal.Image
            end

            local stackLabel = slot:FindFirstChild("Stack")
            if stackLabel then
                local stackValue = v126:FindFirstChild("Configuration") and v126.Configuration:FindFirstChild("Stack")
                if stackValue then
                    stackLabel.Text = tostring(stackValue.Value)
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
        pcall(function()
            if Background:FindFirstChild("Saving") then
                Background.Saving.Visible = false
            end
        end)
    end)

    if itemAdded then
        AddToDataStore()
        return true
    end

    AddToDataStore()
    return false
end

return MainFunction
