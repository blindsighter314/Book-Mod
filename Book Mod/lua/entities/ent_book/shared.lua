ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Book"
ENT.Author 				= "Justin"
ENT.Information 		= ""
ENT.Spawnable 			= true
ENT.AdminSpawnable 		= true
ENT.Category 			= "Book Addon"

isOpen = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"owning_ent")
end

// Config /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Book_MaxTitleLength 	= 20
Book_MaxText			= 1023	// Max amount of text (in characters).

// DUE TO GMOD CONSTRAINTS, Book_MaxText CANNOT EXCEED 1023, IF YOU SET IT HIGHER, NOTHING BAD WILL HAPPEN, BUT IT WILL BE 1023

// Config /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
