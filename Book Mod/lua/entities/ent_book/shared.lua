ENT.Type 						= "anim"
ENT.Base 						= "base_entity"
ENT.PrintName 			= "Book"
ENT.Author 					= "Justin"
ENT.Information 		= ""
ENT.Spawnable 			= true
ENT.AdminSpawnable 	= true
ENT.Category 				= "Book Addon"

isOpen = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"owning_ent")
end