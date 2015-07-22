AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("openBookEdit")
util.AddNetworkString("openBookRead")
util.AddNetworkString("updateServer")
util.AddNetworkString("bookAction")
util.AddNetworkString("Close")

function ENT:SpawnFunction(ply, tr, classname)
	if ( !tr.Hit ) then return end

  local SpawnPos = tr.HitPos + tr.HitNormal * 16

  local ent = ents.Create("ent_book")
  ent:SetPos( SpawnPos )
  ent:Spawn()
  ent:Activate()

  return ent
end

function ENT:Initialize()
	self:SetModel("models/props_lab/binderredlabel.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self.Entity:GetPhysicsObject():SetMass(50)

	self:SetNWString("Title", "Untitled")
	self:SetNWString("Text", "")
	self:SetNWBool("isOpen", false)
	self:SetNWBool("Published", false)
end

function ENT:AcceptInput(name, activator, caller)
	if name == "Use" and caller:IsPlayer() then
		if caller == self:Getowning_ent() then
			if self:GetNWBool("Published") == true then
				net.Start("openBookRead")
					net.WriteEntity(self)
					net.WriteString(self:GetNWString("Title"))
				net.Send(caller)
			else
				net.Start("openBookEdit")
					net.WriteEntity(self)
					net.WriteString(self:GetNWString("Title"))
				net.Send(caller)
			end
		else
			net.Start("openBookRead")
				net.WriteEntity(self)
				net.WriteString(self:GetNWString("Title"))
			net.Send(caller)
		end
	end 
end

net.Receive("updateServer", function()
	local ent = net.ReadEntity()
	local title = net.ReadString()
	local history = net.ReadTable()

	ent:SetNWString("Title", title)
	local para = ""

	for k,v in pairs(history) do
		para = (para..v.."\n")
	end

	ent:SetNWString("Text", para)
	print(ent:GetNWString("Text"))
	print("Niggers")
end)



net.Receive("bookAction", function()
	local ent = net.ReadEntity()
	local ply = net.ReadEntity()
	local action = net.ReadString()
	local color = net.ReadColor()

	if action == "Freeze" then
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
		ply:ChatPrint("Your book has been frozen!")
	elseif action == "Unfreeze" then
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(true)
		end
		ply:ChatPrint("Your book has been unfrozen!")

	elseif action == "ChangeColor" then
		ent:SetColor(color)
	elseif action == "Publish" then
		ply:ChatPrint("Your book is published and can no longer be edited!")
		ent:SetNWBool("Published", true)
	elseif action == "Help" then
		ply:ChatPrint("Stop Sign: Freeze your book")
		ply:ChatPrint("Arrow Right: UnFreeze your book")
		ply:ChatPrint("Color Wheel: Change color of your book")
		ply:ChatPrint("Book with plus: Publish your book (CANNOT BE UNDONE)")
	end
end)

net.Receive( "Close", function()
	isOpen = false
end )
