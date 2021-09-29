if SERVER then
    AddCSLuaFile()
	util.AddNetworkString("gobbo_spawn")
	util.AddNetworkString("gobbo_defeat")
end

if CLIENT then
    net.Receive("gobbo_spawn", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("gobbo_epop_title", {nick = net.ReadString()}),
            color = LOOTGOBLIN.ltcolor
            },
            LANG.GetTranslation("gobbo_epop_desc")
        )
    end)

    net.Receive("gobbo_defeat", function()
        EPOP:AddMessage({
            text = LANG.GetParamTranslation("gobbo_epop_defeat_title", {nick = net.ReadString()}),
            color = LOOTGOBLIN.ltcolor
            },
            LANG.GetTranslation("gobbo_epop_defeat_desc")
        )
    end)

end