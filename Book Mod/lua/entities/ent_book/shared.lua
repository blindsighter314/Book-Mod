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

// Config /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Book_MaxTitleLength = 20
Book_MaxText				= 5000	// Max amount of text (in characters) per line.

// Config /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
