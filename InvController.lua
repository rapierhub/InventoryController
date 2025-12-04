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
    local Inv = Background:WaitForChild("Inv")
    local v125 = false
    if not _G.databusy and true then
        Background.Saving.Visible = true
        _G.databusy = true
        local v126 = p18:Clone()
        v126:WaitForChild("Configuration"):WaitForChild("ReplicatedStorageObject").Value = p18
        local v127 = v126.Interact:Clone()
        for v128 = 1, 21 do
            pcall(function()
                local v129 = Inv[v128]
                if not v129:FindFirstChild("Interact") and not v125 then
                    v125 = true
                    AddModifier(v126.Configuration.Weight, v126.Name)
                    v126.Parent = v129
                    v127.Parent = v129
                    v127.Position = v127.Position - UDim2.new(0, 0, 0.1, 0)
                    pcall(function()
                        v129:FindFirstChild("Image").Image = v126.Decal.Image
                        local Weight = Instance.new('NumberValue', l__LocalPlayer__1.Character.Modifiers.Weight)
                        Weight.Name = p18.Name
                    end)
                    v129.Stack.Visible = false
                    if v126.Configuration:FindFirstChild("Stack") then
                        v129.Stack.Text = v126.Configuration.Stack.Value
                        v129.Stack.Visible = true
                    end
                end
            end)
        end
    end
    spawn(
        function()
            for v130 = 0, 5 do
                wait(1)
                if _G.databusy == false then
                    break
                end
            end
            _G.databusy = false
            Background.Saving.Visible = false
        end
    )
    if v125 ~= false then
        AddToDataStore()
        _G.databusy = false
        return true
    end
    AddToDataStore()
    _G.databusy = false
    return false
end

return MainFunction
