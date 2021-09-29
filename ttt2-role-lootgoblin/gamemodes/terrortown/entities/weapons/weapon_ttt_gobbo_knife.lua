if SERVER then
   AddCSLuaFile()
 end
 
 if CLIENT then
   SWEP.PrintName = "Gobbo Stabber"
 
   SWEP.ViewModelFlip = false
   SWEP.ViewModelFOV = 54
   SWEP.DrawCrosshair = true
 
   SWEP.EquipMenuData = {
     type = "item_weapon",
     desc = "knife_desc"
   }
 
   SWEP.Icon = "materials/vgui/ttt/dynamic/roles/icon_gobbo.vmt"
   SWEP.IconLetter = "j"
 end
 
 SWEP.Base = "weapon_tttbase"
 
 SWEP.HoldType = "knife"
 SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
 SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
 SWEP.UseHands = true
 
 SWEP.Primary.Damage = 45
 SWEP.Primary.ClipSize = -1
 SWEP.Primary.DefaultClip = -1
 SWEP.Primary.Automatic = true
 SWEP.Primary.Delay = 1
 SWEP.Primary.Ammo = "none"
 
 SWEP.Secondary.ClipSize = -1
 SWEP.Secondary.DefaultClip = -1
 SWEP.Secondary.Automatic = false
 SWEP.Secondary.Ammo = "none"
 SWEP.Secondary.Delay = 5
 
 SWEP.Kind = WEAPON_SPECIAL
 SWEP.CanBuy = false
 SWEP.HitDistance = 64
 
 SWEP.AutoSpawnable         = false
 SWEP.AdminSpawnable	=	false
 
 
 SWEP.AllowDrop = false
 SWEP.IsSilent = true
 
 -- Pull out faster than standard guns
 SWEP.DeploySpeed = 2

 
 if SERVER then
   function SWEP:Initialize()
     self:SetHoldType("knife")
   end
 end
 
 function SWEP:Deploy()
   local owner = self:GetOwner()
   owner:SetNWBool("Knife_Out", true)
   return true
 end
 
 function SWEP:Holster(weapon)
   local owner = self:GetOwner()
   owner:SetNWBool("Knife_Out", false)
   return true
 end
 
 function SWEP:OnDrop()
   self:GetOwner():SetNWBool("Knife_Out", false)
   self:Remove()
 end
 
 
 function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
 
   if not IsValid(self:GetOwner()) then return end
 
   self:GetOwner():LagCompensation(true)
 
   local spos = self:GetOwner():GetShootPos()
   local sdest = spos + (self:GetOwner():GetAimVector() * 70)
 
   local kmins = Vector(1, 1, 1) * -10
   local kmaxs = Vector(1, 1, 1) * 10
 
   local tr = util.TraceHull({
       start = spos,
       endpos = sdest,
       filter = self:GetOwner(),
       mask = MASK_SHOT_HULL,
       mins = kmins,
       maxs = kmaxs
   })
 
   if not IsValid(tr.Entity) then
     tr = util.TraceLine({
         start = spos,
         endpos = sdest,
         filter = self:GetOwner(),
         mask = MASK_SHOT_HULL
     })
   end
 
   local hitEnt = tr.Entity
 
   if IsValid(hitEnt) then
     self:SendWeaponAnim(ACT_VM_HITCENTER)
 
     local edata = EffectData()
     edata:SetStart(spos)
     edata:SetOrigin(tr.HitPos)
     edata:SetNormal(tr.Normal)
     edata:SetEntity(hitEnt)
 
     if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
       self:GetOwner():SetAnimation(PLAYER_ATTACK1)
 
       self:SendWeaponAnim(ACT_VM_MISSCENTER)
 
       util.Effect("BloodImpact", edata)
     end
 
   else
     self:SendWeaponAnim(ACT_VM_MISSCENTER)
   end
 
   if SERVER then
     self:GetOwner():SetAnimation(PLAYER_ATTACK1)
   end
 
   if SERVER and tr.Hit and tr.HitNonWorld and IsValid(hitEnt) and hitEnt:IsPlayer() then
       local dmg = DamageInfo()
       dmg:SetDamage(self.Primary.Damage)
       dmg:SetAttacker(self:GetOwner())
       dmg:SetInflictor(self)
       dmg:SetDamageForce(self:GetOwner():GetAimVector() * 5)
       dmg:SetDamagePosition(self:GetOwner():GetPos())
       dmg:SetDamageType(DMG_SLASH)
 
       hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
       local dmg_dealt = dmg:GetDamage()
   end
 
   self:GetOwner():LagCompensation(false)
 end
 
 
 function SWEP:Error()
 
 end
