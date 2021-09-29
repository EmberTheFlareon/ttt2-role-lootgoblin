if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_gobbo.vmt")
	util.AddNetworkString("gobbo_spawn")
	util.AddNetworkString("gobbo_defeat")
end

roles.InitCustomTeam(ROLE.name, {
    icon = "vgui/ttt/dynamic/roles/icon_gobbo.vmt",
    color = Color(167, 11, 120)
})



function ROLE:PreInitialize()
	self.color = Color(167, 11, 120)

	self.abbr = "gobbo"
	self.score.surviveBonusMultiplier = 0.5
	self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = g
	self.score.teamKillsMultiplier = -16
	self.score.bodyFoundMuliplier = 0

	self.defaultTeam = TEAM_LOOTGOBLIN
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		pct = 0.1,
		maximum = 1,
		minPlayers = 8,
		credits = 0,
		togglable = true,
		random = 20
	}
end

function ROLE:Initialize()
	if SERVER and JESTER then
		self.networkRoles = {JESTER}
	end
end

if SERVER then


	local function StripWeapons(ply)
		for _, wep in ipairs(ply:GetWeapons()) do
		  if wep.ClassName == "weapon_ttt_gobbo_revolver" then continue end
		  if wep.ClassName == "weapon_ttt_gobbo_knife" then continue end
		  if wep.ClassName == "weapon_ttt_unarmed" or wep.ClassName == "weapon_zm_carry" then continue end
		  ply:StripWeapon(wep.ClassName)
		end
	  end
	
	local function GiveTheGobboHisAbilities(ply)
		ply:SetMaxHealth(350)
		ply:SetHealth(350)
		ply:SetWalkSpeed(350)

		g = 2

		local sizedata = {
			stepSize = ply:GetStepSize(),
			modelScale = ply:GetModelScale(),
			viewOffset = ply:GetViewOffset(),
			viewOffsetDucked = ply:GetViewOffsetDucked()}

		ply:SetModelScale(sizedata.modelScale * 0.5)
		ply:SetViewOffset(sizedata.viewOffset * 0.5)
		ply:SetViewOffsetDucked(sizedata.viewOffsetDucked * 0.5)
		ply:SetStepSize(sizedata.stepSize * 0.5)
		StripWeapons(ply)
		ply:GiveEquipmentWeapon("weapon_ttt_gobbo_revolver")
		ply:GiveEquipmentWeapon("weapon_ttt_gobbo_knife")	
	end

    local function LootGoblinSpawner(ply)
        timer.Create("GobboReveal" .. ply:SteamID64(), 10, 1, function()
			GiveTheGobboHisAbilities(ply)
			ply.GobboTime = true
			net.Start("gobbo_spawn")
            net.WriteString(ply:Nick())
            net.Broadcast()

		end)
	end   
	hook.Add("Initialize", "GobboTimer", GobboReveal)

	hook.Add("PlayerDeath", "GobboDropsTheGoods", function (ply)
		if ply.GobboTime == true then

			lootyloot = {  }
			table.Add(lootyloot, SPECIAL_EQUIPMENT)
			table.Add(lootyloot, TRAITOR_EQUIPMENT)
			local looty = (lootyloot[math.random(7, #lootyloot)])
			local entgob = ents.Create( looty )
			entgob:SetPos( ply:GetBonePosition( 1 ) + (Vector((-10 + math.random(-10, 10)), math.random(-10, 10), 0)))
			entgob:Spawn()
			ply.GobboTime = false
			net.Start("gobbo_defeat")
            net.WriteString(ply:Nick())
            net.Broadcast()

		elseif not ply.GobboTime == true or ply.GobboTime == false then timer.Remove("GobboReveal") end
	end)
	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		g = 0
        LootGoblinSpawner(ply)
		view1 = Vector(ply:GetViewOffset())
		view2 = Vector(ply:GetViewOffsetDucked())

		SendPlayerToEveryone(ply)
		SendFullStateUpdate()
    end

    function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:SetMaxHealth(100)
		ply:SetWalkSpeed(250)
        ply:SetStepSize(1)
        ply:SetModelScale(1)
		ply:SetViewOffset(view1)
        ply:SetViewOffsetDucked(view1)
		ply:RemoveEquipmentWeapon("weapon_ttt_gobbo_revolver")
		ply:RemoveEquipmentWeapon("weapon_ttt_gobbo_knife")
		timer.Remove("GobboReveal")
    end

	if not IsValid() or not ply:IsPlayer() or not ply:Alive() or ply:IsSpec() then
		timer.Remove("GobboReveal")
	end

end
