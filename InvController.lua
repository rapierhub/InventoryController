local l__LocalPlayer__1 = game.Players.LocalPlayer

local function findRemote(RemoteType)
    for _, v in pairs(l__LocalPlayer__1:GetChildren()) do
        local name = v.Name:lower()
        if v.ClassName == RemoteType and (name:find("server") or name:find("function") or name:find("event")) then
            return v
        end
    end
end

local function FindBackground()
    for _, inst in pairs(l__LocalPlayer__1.PlayerGui:GetDescendants()) do
        if (inst.Name == "Inv" or inst.Name == "Equipped") and (inst.Parent.ClassName == "Frame" or inst.Parent.ClassName == "ImageLabel") then
            return inst.Parent
        end
    end
end

local u3 = {
    Equipped = {},
    Inventory = {},
    Body = {}
}

local function AddToDataStore()
    local anims = require(l__LocalPlayer__1.Character:WaitForChild("Animations"))
    local mods = require(l__LocalPlayer__1.Character:WaitForChild("Modifiers"))
    local Background = FindBackground()
    local Equipped = Background:WaitForChild("Equipped")
    local Body = Background:WaitForChild("Body")
    local Inv = Background:WaitForChild("Inv")

    local function processContainer(container, targetTable)
        local children = container:GetChildren()
        for i = 1, #children do
            local entry = { Name = "", Stack = 0 }
            local tool = nil
            local items = children[i]:GetChildren()
            for j = 1, #items do
                if items[j]:IsA("Tool") then
                    tool = items[j]
                    break
                end
            end
            if tool then
                local stackObj = tool.Configuration:FindFirstChild("Stack")
                entry.Name = tool.Name
                entry.Stack = stackObj and stackObj.Value or 0
            else
                entry.Name = nil
                entry.Stack = nil
            end
            if container == Body then
                targetTable[children[i].LayoutOrder] = entry
            else
                targetTable[i] = entry
            end
        end
    end

    processContainer(Equipped, u3.Equipped)
    processContainer(Inv, u3.Inventory)
    processContainer(Body, u3.Body)

    local remoteFunc = findRemote("RemoteFunction")
    if remoteFunc then
        remoteFunc:InvokeServer("updateStats", u3)
    end
    Background.Saving.Visible = false
end

local function AddModifier(template, name)
    local clone = template:Clone()
    clone.Parent = template.Parent
    clone.Name = name
end

local function RemoveModifier(parentObj, modifierName)
    local folder = parentObj:FindFirstChild(parentObj.Name)
    if not folder then return end
    local mod = folder:FindFirstChild(modifierName)
    if mod then
        mod:Destroy()
    end
end

local MainFunction = {}

function MainFunction.AddToInvLOL(itemToAdd)
    local Background = FindBackground()
    local Inv = Background:WaitForChild("Inv")
    local added = false

    if not _G.__inv_lock then
        Background.Saving.Visible = true
        _G.__inv_lock = true

        local clonedItem = itemToAdd:Clone()
        local config = clonedItem:WaitForChild("Configuration")
        config:WaitForChild("ReplicatedStorageObject").Value = itemToAdd

        local interactClone = clonedItem.Interact:Clone()

        for i = 1, 21 do
            pcall(function()
                local slot = Inv[i]
                if not slot:FindFirstChild("Interact") and not added then
                    added = true
                    AddModifier(clonedItem.Configuration.Weight, clonedItem.Name)
                    clonedItem.Parent = slot
                    interactClone.Parent = slot
                    interactClone.Position = interactClone.Position - UDim2.new(0, 0, 0.1, 0)

                    pcall(function()
                        slot:FindFirstChild("Image").Image = clonedItem.Decal.Image
                        local weightVal = Instance.new("NumberValue")
                        weightVal.Name = itemToAdd.Name
                        weightVal.Parent = l__LocalPlayer__1.Character:WaitForChild("Modifiers").Weight
                    end)

                    slot.Stack.Visible = false
                    local stackObj = clonedItem.Configuration:FindFirstChild("Stack")
                    if stackObj then
                        slot.Stack.Text = stackObj.Value
                        slot.Stack.Visible = true
                    end
                end
            end)
        end
    end

    spawn(function()
        for i = 1, 5 do
            wait(1)
            if not _G.__inv_lock then break end
        end
        _G.__inv_lock = false
        Background.Saving.Visible = false
    end)

    if added then
        AddToDataStore()
        _G.__inv_lock = false
        return true
    end

    AddToDataStore()
    _G.__inv_lock = false
    return false
end

return MainFunction
