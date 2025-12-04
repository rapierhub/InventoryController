local l__LocalPlayer__1 = game.Players.LocalPlayer
local v_u_2 = l__LocalPlayer__1:WaitForChild("GwyneddEventUn")
local v_u_3 = l__LocalPlayer__1:WaitForChild("GwyneddFunctionDau")
_G.__inv_lock = false
_G.__data_busy = false

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

local v_u_301 = {
    ["AddToDataStore"] = function()
        local anims = require(l__LocalPlayer__1.Character:WaitForChild("Animations"))
        local mods = require(l__LocalPlayer__1.Character:WaitForChild("Modifiers"))
        local Background = FindBackground()
        local Equipped = Background:WaitForChild("Equipped")
        local Body = Background:WaitForChild("Body")
        local Inv = Background:WaitForChild("Inv")
        
        local u3 = {
            ["Equipped"] = {},
            ["Inventory"] = {},
            ["Body"] = {}
        }
        
        local function processContainer(container, targetTable)
            local children = container:GetChildren()
            for i = 1, #children do
                local entry = { ["Name"] = "", ["Stack"] = 0 }
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

        v_u_3:InvokeServer("abc", u3)
        Background.Saving.Visible = false
    end,
    
    ["AddToInvLOL"] = function(itemToAdd)
        local Background = FindBackground()
        local Inv = Background:WaitForChild("Inv")
        local added = false

        if not _G.__data_busy then
            Background.Saving.Visible = true
            _G.__data_busy = true
            
            local clonedItem = itemToAdd:Clone()
            clonedItem:WaitForChild("Configuration"):WaitForChild("ReplicatedStorageObject").Value = itemToAdd
            local interactClone = clonedItem.Interact:Clone()

            for i = 1, 18 do
                pcall(function()
                    local slot = Inv[i]
                    if not slot:FindFirstChild("Interact") and not added then
                        added = true
                        
                        clonedItem.Parent = slot
                        interactClone.Parent = slot
                        slot.Image = clonedItem.Decal.Image
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
                if not _G.__data_busy then break end
            end
            _G.__data_busy = false
            Background.Saving.Visible = false
        end)

        if added then
            v_u_301["AddToDataStore"]()
            _G.__data_busy = false
            return true
        end
        
        v_u_301["AddToDataStore"]()
        _G.__data_busy = false
        return false
    end,
    
    ["DropInvItem"] = function(slot, itemConfig)
        local itemObj = itemConfig.Configuration.ReplicatedStorageObject.Value
        require(l__LocalPlayer__1.Character:WaitForChild("Animations"))
        local mods = require(l__LocalPlayer__1.Character:WaitForChild("Modifiers"))
        local Background = FindBackground()
        Background:WaitForChild("Equipped")
        Background:WaitForChild("Body")
        Background:WaitForChild("Inv")
        
        if not _G.__data_busy then
            v_u_2:FireServer("dropInvItem", itemObj)
            Background.Saving.Visible = true
            _G.__data_busy = true
            
            local children = slot:GetChildren()
            for i = 1, #children do
                if children[i]:IsA("Tool") or children[i].Name == "Interact" then
                    children[i]:Destroy()
                    _G.GUIsubmenuopen = false
                end
            end
            
            slot.Image = ""
            slot.Stack.Visible = false
            v_u_301["AddToDataStore"]()
            _G.__data_busy = false
        end
    end,
    
    ["RefillAllAmmo"] = function()
        local changed = false
        require(l__LocalPlayer__1.Character:WaitForChild("Animations"))
        require(l__LocalPlayer__1.Character:WaitForChild("Modifiers"))
        local Background = FindBackground()
        local Equipped = Background:WaitForChild("Equipped")
        local Body = Background:WaitForChild("Body")
        local Inv = Background:WaitForChild("Inv")
        
        if not _G.__data_busy then
            Background.Saving.Visible = true
            _G.__data_busy = true
            
            local bodyChildren = Body:GetChildren()
            for i = 1, #bodyChildren do
                local items = bodyChildren[i]:GetChildren()
                for j = 1, #items do
                    if items[j]:IsA("Tool") and items[j].Configuration:FindFirstChild("Stack") then
                        local stack = items[j].Configuration.Stack
                        if stack.Value < stack.Max.Value then
                            stack.Value = stack.Max.Value
                            bodyChildren[i].Stack.Text = stack.Value
                            bodyChildren[i].Stack.Visible = true
                            changed = true
                        end
                    end
                end
            end
            
            local equipChildren = Equipped:GetChildren()
            for i = 1, #equipChildren do
                local items = equipChildren[i]:GetChildren()
                for j = 1, #items do
                    if items[j]:IsA("Tool") and items[j].Configuration:FindFirstChild("Stack") then
                        local stack = items[j].Configuration.Stack
                        if stack.Value < stack.Max.Value then
                            _G.active = true
                            v_u_3:InvokeServer("despawnSword", i)
                            v_u_3:InvokeServer("spawnSword", items[j].Configuration.ReplicatedStorageObject.Value, i)
                            local weaponFuncs = require(l__LocalPlayer__1.Backpack:WaitForChild(i):WaitForChild("WeaponFunctions"))
                            stack.Value = stack.Max.Value
                            weaponFuncs.Initialize(i)
                            equipChildren[i].Stack.Text = stack.Value
                            equipChildren[i].Stack.Visible = true
                            _G.active = false
                            changed = true
                        end
                    end
                end
            end
            
            local invChildren = Inv:GetChildren()
            for i = 1, #invChildren do
                local items = invChildren[i]:GetChildren()
                for j = 1, #items do
                    if items[j]:IsA("Tool") and items[j].Configuration:FindFirstChild("Stack") then
                        local stack = items[j].Configuration.Stack
                        if stack.Value < stack.Max.Value then
                            stack.Value = stack.Max.Value
                            invChildren[i].Stack.Text = stack.Value
                            invChildren[i].Stack.Visible = true
                            changed = true
                        end
                    end
                end
            end
            
            spawn(function()
                for i = 1, 5 do
                    wait(1)
                    if not _G.__data_busy then break end
                end
                _G.__data_busy = false
                Background.Saving.Visible = false
            end)
            
            v_u_301["AddToDataStore"]()
            _G.__data_busy = false
        end
        return changed
    end
}

return v_u_301
