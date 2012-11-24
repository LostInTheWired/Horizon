AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("hydrogen_tank")
	ent:SetPos( tr.HitPos + Vector(0, 0, 5))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
		
	return ent

end
 
function ENT:Initialize()
 
	self:SetModel( "models/hydrogen_tank.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	
	self.linkable = true
	self.connections = {}
	self.networkID = nil
	self.deviceType = "storage"
	self.maxHydrogen = 1200
	self.Hydrogen = 0
	self.totalHydrogen = self.Hydrogen
	self.resourcesUsed = {"hydrogen"}

        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end
 
 
function ENT:Think()

	-- update status baloon, and discard excess resources
	
	self:devUpdate()
	self:trimResources()
	
	-- calculate the total hydrogen available on the network.
	if self.networkID != nil then	
		for _, res in pairs( GAMEMODE.networks[self.networkID][1] ) do			
			if res[1] == "hydrogen" then				
				self.totalHydrogen = res[2]			
			end
			
		end
	end
	
	if self.networkID == nil then
		self:resetResources()
	end
    
end

function ENT:trimResources()

	if self.Hydrogen > self.maxHydrogen then self.Hydrogen = self.maxHydrogen end

end

function ENT:resetResources()

	self.totalHydrogen = self.Hydrogen

end

function ENT:updateResCount(resName, newAmt)

	if resName == "hydrogen" then
	
		if self.Hydrogen < self.maxHydrogen then
			self.Hydrogen = newAmt
		end
	
	end

end

function ENT:reportResources( netID )
	
	for _, res in pairs( GAMEMODE.networks[netID][1] ) do	
			
		if res[1] == "hydrogen" then	
			res[2] = res[2] + self.Hydrogen			
			res[3] = res[3] + self.maxHydrogen			
		end
	end

end

function ENT:devUpdate()
	umsg.Start("hydrogen_tank_umsg")
	umsg.Entity( self )
	umsg.Short( self.totalHydrogen )
	umsg.End()
end


 