function handleShower(show)
    local emit = show.ShowerHead.Head.Spout.Water
    local sound = show.ShowerHead.Head.Spout.Sound
    local click = show.Control.Click

    local on = false
    local deb = false

    click.MouseClick:connect(function()
        if deb == false then
            deb = true
            if on == true then
                emit.Enabled = false
                sound:Stop()
                on = false
            else
                emit.Enabled = true
                sound:Play()
                on = true
            end
            task.wait(1)
            deb = false
        end
    end)
end

for _, v in pairs(script.Parent.ShowerStalls:GetChildren()) do
    if v.Name == "ShowerStall" then
        handleShower(v)
    end
end