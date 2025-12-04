local l__LocalPlayer__1 = game.Players.LocalPlayer

function findRemote(RemoteType)
    local Remote;
    for _,v in pairs(l__LocalPlayer__1:GetChildren()) do
        local Name = v.Name:lower()
        if(v.ClassName == RemoteType and (Name:match('server') or Name:match('function') or Name:match('event'))) then
            Remote = v
        end
    end
    return Remote
end

function FindBackground()
    for _,inst in pairs(l__LocalPlayer__1.PlayerGui:GetDescendants()) do
        if((inst.Name == 'Inv' or inst.Name == 'Equipped') and (inst.Parent.ClassName == 'Frame' or inst.Parent.ClassName == 'ImageLabel')) then
            return inst.Parent
        end
    end
end

function AddToDataStore()
    local v40 = require(l__LocalPlayer__1.Character:WaitForChild("Animations"))
    local v41 = require(l__LocalPlayer__1.Character:WaitForChild("Modifiers"))
    local Background = FindBackground()
    local Equipped = Background:WaitForChild("Equipped")
    local l__Body__44 = Background:WaitForChild("Body")
    local l__Inv__45 = Background:WaitForChild("Inv")
    u3 = {
        Equipped = {},
        Inventory = {},
        Body = {}
    }
    local v46 = Equipped:GetChildren()
    for v47 = 1, #v46 do
        local v48 = {
            Name = "",
            Stack = 0
        }
        local v49 = v46[v47]:GetChildren()
        local v50 = nil
        for v51 = 1, #v49 do
            if v49[v51]:isA("Tool") then
                v50 = v49[v51]
            end
        end
        if v50 ~= nil then
            if v50.Configuration:FindFirstChild("Stack") then
                v48.Name = v50.Name
                v48.Stack = v50.Configuration.Stack.Value
            else
                v48.Name = v50.Name
                v48.Stack = 0
            end
        else
            v48.Name = nil
            v48.Stack = nil
        end
        u3.Equipped[v47] = v48
    end
    local v52 = l__Inv__45:GetChildren()
    for v53 = 1, #v52 do
        local v54 = {
            Name = "",
            Stack = 0
        }
        local v55 = v52[v53]:GetChildren()
        local v56 = nil
        for v57 = 1, #v55 do
            if v55[v57]:isA("Tool") then
                v56 = v55[v57]
            end
        end
        if v56 ~= nil then
            if v56.Configuration:FindFirstChild("Stack") then
                v54.Name = v56.Name
                v54.Stack = v56.Configuration.Stack.Value
            else
                v54.Name = v56.Name
                v54.Stack = 0
            end
        else
            v54.Name = nil
            v54.Stack = nil
        end
        u3.Inventory[v53] = v54
    end
    local v58 = l__Body__44:GetChildren()
    for v59 = 1, #v58 do
        local v60 = {
            Name = "",
            Stack = 0
        }
        local v61 = v58[v59]:GetChildren()
        local v62 = nil
        for v63 = 1, #v61 do
            if v61[v63]:isA("Tool") then
                v62 = v61[v63]
            end
        end
        if v62 ~= nil then
            if v62.Configuration:FindFirstChild("Stack") then
                v60.Name = v62.Name
                v60.Stack = v62.Configuration.Stack.Value
            else
                v60.Name = v62.Name
                v60.Stack = 0
            end
        else
            v60.Name = nil
            v60.Stack = nil
        end
        u3.Body[v58[v59].LayoutOrder] = v60
    end

    findRemote('RemoteFunction'):InvokeServer("updateStats", u3)
    Background.Saving.Visible = false
end

AddModifier = function(p1, p2)
    local v1 = p1:Clone()
    v1.Parent = p1.Parent
    v1.Name = p2
end

RemoveModifier = function(p3, p4)
	local v2 = p3.Parent:FindFirstChild(p3.Name);
	if not v2 then
		return;
	end;
	local v3 = v2:FindFirstChild(p4);
	if v3 then
		v3:Remove();
		return;
	end;
end

local MainFunction = {}

function MainFunction.AddToInvLOL(p18)
    local Background = FindBackground()
    if not Background then return false end
    
    local Inv = Background:WaitForChild("Inv", 5)
    if not Inv then return false end
    
    -- Check if we're already busy
    if _G.databusy then return false end
    
    Background.Saving.Visible = true
    _G.databusy = true
    
    local itemAdded = false
    
    -- Small delay to appear more natural
    wait(0.1)
    
    local newItem = p18:Clone()
    if not newItem then 
        _G.databusy = false
        Background.Saving.Visible = false
        return false 
    end
    
    -- Validate configuration exists
    local config = newItem:FindFirstChild("Configuration")
    if config then
        local replicatedObj = config:FindFirstChild("ReplicatedStorageObject")
        if replicatedObj then
            replicatedObj.Value = p18
        end
    end
    
    local interactClone = newItem:FindFirstChild("Interact")
    for i = 1, 21 do
        local success, err = pcall(function()
            local slot = Inv:FindFirstChild(tostring(i))
            if slot and not slot:FindFirstChild("Interact") and not itemAdded then
                itemAdded = true
                wait(0.05)
                if newItem.Configuration and newItem.Configuration:FindFirstChild("Weight") then
                    AddModifier(newItem.Configuration.Weight, newItem.Name)
                end

                newItem.Parent = slot
                
                if interactClone then
                    local clonedInteract = interactClone:Clone()
                    clonedInteract.Parent = slot
                    clonedInteract.Position = clonedInteract.Position - UDim2.new(0, 0, 0.1, 0)
                end
                local imageLabel = slot:FindFirstChild("Image")
                if imageLabel and newItem:FindFirstChild("Decal") then
                    imageLabel.Image = newItem.Decal.Image
                end
                
                local stackLabel = slot:FindFirstChild("Stack")
                if stackLabel then
                    local stackValue = newItem.Configuration:FindFirstChild("Stack")
                    if stackValue then
                        stackLabel.Text = stackValue.Value
                        stackLabel.Visible = true
                    else
                        stackLabel.Visible = false
                    end
                end
            end
        end)
        
        if not success then
        end
        wait(0.01)
    end
    spawn(function()
        _G.databusy = false
        if Background and Background:FindFirstChild("Saving") then
            Background.Saving.Visible = false
        end
        if itemAdded then
            wait(0.5)
            pcall(function()
                AddToDataStore()
            end)
        end
    end)
    
    return itemAdded
end
