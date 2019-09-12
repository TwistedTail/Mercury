Mercury.Commands.AddPrivilege("commcontrol")
Mercury.Commands.AddPrivilege("adminchat")


//because functions
function findPlayerByName(name)
	for _,ply in pairs (player.GetAll()) do
		if string.match(string.lower(ply:GetName()), string.lower(name)) then
			return ply
		end
	end
	return nil
end

// /me 
hook.Add("PlayerSay","MercuryComm",function(XAD, txt,tea )
	local etab = string.Explode(" ",txt)
	if XAD["Muted"] ==true then 
		return ""		
	end
	if etab[1]=="/me" then 
		local rck = string.Explode(" ",txt)
		table.remove(rck,1)
		for k,v in pairs(player.GetAll()) do 
			v:ChatPrint( "*"  .. XAD:Nick() .. " " .. table.concat(rck," "))
		end
		return ""
	end

//Admin chat
	if etab[1]=="~" or etab[1]=="@" then 
		if etab[1]=="~" or etab[1]=="@" then 
			txt = string.sub(txt,2,#txt)
		end 

			local rck = string.Explode(" ",txt)
			table.remove(rck,1)
			for k,v in pairs(player.GetAll()) do 
				if v:HasPrivilege("adminchat") then 
					Mercury.Util.SendMessage(v,{Mercury.Config.Colors.Arg,"~ADMIN - ",XAD,Mercury.Config.Colors.Arg,": ", txt })
				end
			end
			return ""
	
	end


//About Mercury Command (MODIFIED!)
	if etab[1]=="!aboutmercury" or etab[1]=="!mercury" or etab[1]=="!about" then 
		
		for k,v in pairs(player.GetAll()) do 
				Mercury.Util.SendMessage(v,{Color(255,255,255) ,"Mercury Administration System ~ version", Color(0,255,255), " (HOTEL 9.3) ",Color(255,255,255) ,"Created by" , Color(255,0,255) , " FreezeBug" , Color(255,255,255), " with help from", Color(255,0,0), " Rusketh, Mythic, Merc, and !cake"})
		end
	end


//Private messages (so fucking hacky lmao)
	if etab[1]=="!pm" or etab[1]=="/pm"then
		local ply = findPlayerByName(etab[2])
		if ply then
			if XAD.ignoring != ply then
				if etab[3] then
					Mercury.Util.SendMessage(XAD,{Color(255,0,255),"[PM] ",Color(186,85,211),"You to " .. ply:Nick() .. ": ", Color(255,255,255), table.concat(etab," ",3,#etab)}) 
					Mercury.Util.SendMessage(ply,{Color(255,0,255),"[PM] ",Color(186,85,211),XAD:Nick() .. " to You: ", Color(255,255,255), table.concat(etab," ",3,#etab)}) 
				else 
					Mercury.Util.SendMessage(XAD,{Color(255,132,84),"No message specified."})
				end
			else
				Mercury.Util.SendMessage(XAD,{Color(255,132,84),"You cannot PM " .. ply:Nick() .. "."})
			end
		else 
			Mercury.Util.SendMessage(XAD,{Color(255,132,84),"Player not found."})
		end
		return ""
	end
	


end, -18 ) 
local plymeta = FindMetaTable("Player")

function plymeta:isIgnoring(target)
	local ply = self
	
	return ply.ignoring == target
end

hook.Add("PlayerCanHearPlayersVoice","mercurygag",function(listener, talker)
	if talker.Gagged == true then 
		return false,false
	else
		return !listener:isIgnoring(talker),false
	end
end)
hook.Add("PlayerCanSeePlayersChat","mercurysilencechat",function(txt, isteam, listener, talker)
	return !listener:isIgnoring(talker)
end)

//was the player gagged before they left? if so, they will stay gagged.
Mercury.ModHook.Add("PostUserDataLoaded","CommGag",function(Ply)
	if Ply._MercuryUserData["gaginfo"] then 
		if Ply._MercuryUserData["gaginfo"]["permagagged"] == true then
			Ply.Gagged = true
		end 
	end 


	if Ply._MercuryUserData["muteinfo"] then 
		if Ply._MercuryUserData["muteinfo"]["permamuted"] == true then
			Ply.Muted = true
		end 
	end 

end) 

local function CommPrivCheck(ply)
	return ply:HasPrivilege("commcontrol",true)
end



MCMD = {
	["Command"] = "broadcast",
	["Verb"] = "broadcasted",
	["RconUse"] = true,
	["Useage"] = "!broadcast <text>",
	["UseImmunity"] =  false,
	["HasMenu"] = false,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PlayerTarget"] = false,
	["PrivCheck"] = CommPrivCheck,
	["AllowWildcard"] = false
}

function callfunc(caller,args)

	if args[1] then

		//dont yell at me freezebug
		http.Post( chatlog, { 
					content =  table.concat(args," "),
					username = "Console"
				} )

		for k,v in pairs(player.GetAll()) do 
			v:SendLua("system.FlashWindow()") 
		end
    	return true, "",true, {Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, table.concat(args," "),""}
	else
		return false, "No text was provided!"
	end

end

Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)


MCMD = {
	["Command"] = "silence",
	["Verb"] = "silenced",
	["RconUse"] = true,
	["Useage"] = "!silence <player1> <player2>",
	["UseImmunity"] =  false,
	["HasMenu"] = false,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PlayerTarget"] = true,
	["PrivCheck"] = CommPrivCheck,
	["AllowWildcard"] = false
}

--what i figured out about returns
--1. true/false is the message an error
--2. (optional - use "" if none) error message
--3. true/false display custom message
--4. (optional - use {} if none) custom message
function callfunc(caller,args)
	local ply1 = args[1]
	local ply2 = findPlayerByName(args[2])
	if ply2 then
		if ply2 ~= ply1 then
			if ply1.ignoring == nil and ply2.ignoring == nil then
				ply1.ignoring = ply2
				ply2.ignoring = ply1
				return true, "", true, {Mercury.Config.Colors.Default,caller," has blocked communication between ", ply1, " and ", ply2}
			elseif ply1.ignoring == ply2 and ply2.ignoring == ply1 then
				return false, ply1:Nick() .. " and " .. ply2:Nick() .. " are already ignoring eachother."
			else
				return false, ply1:Nick() .. " or " .. ply2:Nick() .. " are already ignoring someone."
			end
		else
			return false, "First target is the same as second target."
		end
	else
		return false, "No second target found."
	end
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)
--==================================================================================================================================
MCMD = {
	["Command"] = "unsilence",
	["Verb"] = "unsilenced",
	["RconUse"] = true,
	["Useage"] = "!unsilence <player1> <player2>",
	["UseImmunity"] =  false,
	["HasMenu"] = false,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PlayerTarget"] = true,
	["PrivCheck"] = CommPrivCheck,
	["AllowWildcard"] = false
}

function callfunc(caller,args)
	local ply1 = args[1]
	local ply2 = findPlayerByName(args[2])
	if ply2 then
		if ply1 ~= ply2 then
			if ply1.ignoring == ply2 and ply2.ignoring == ply1 then
				ply1.ignoring = nil
				ply2.ignoring = nil
				return true, "", true, {Mercury.Config.Colors.Default,caller," has unblocked communication between ", ply1, " and ", ply2}
			else
				return false, ply1:Nick() .. " and " .. ply2:Nick() .. " are not ignoring eachother."
			end
		else
			return false, "First target is the same as second target."
		end
	else
		return false, "No second target found.", false, {}
	end
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)





MCMD = {
	["Command"] = "mute",
	["Verb"] = "muted",
	["RconUse"] = true,
	["Useage"] = "!mute <player>",
	["UseImmunity"] =  true,
	["HasMenu"] = true,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PlayerTarget"] = true,
	["PrivCheck"] = CommPrivCheck,
	["AllowWildcard"] = true
}

function callfunc(caller,args)
	local addon = {"."}
	if args[2] == "true" then 
		if !args[1]._MercuryUserData["muteinfo"] then 
			args[1]._MercuryUserData["muteinfo"] = {permamuted = true}
			addon = {" for ",Color(255,0,0), "eternity",Mercury.Config.Colors.Default,"."}
			Mercury.UDL.SaveSingle(args[1])
		end 
	end 

	args[1].Muted = true 
	return true, "", true, {Mercury.Config.Colors.Default,caller," has muted ", args[1],unpack(addon) }
end

function MCMD.GenerateMenu(frame)
	local selectedplayer = nil 

	local ctrl = vgui.Create( "DListView", frame)
	ctrl:AddColumn( "Players" )
	ctrl:SetSize( 210, 380 )	
	ctrl:SetPos( 10, 0 )
				
	local UnmuteButton = vgui.Create( "DButton" , frame)
	local MuteButton = vgui.Create( "DButton" , frame)
	MuteButton:SetPos( 240, 40 )
	MuteButton:SetText( "Mute Chat" )
	MuteButton:SetSize( 130, 60 )
	MuteButton:SetDisabled(true)
	MuteButton.DoClick = function(self)
		if self:GetDisabled()==true then return false end
		surface.PlaySound("buttons/button3.wav")
		net.Start("Mercury:Commands")
			net.WriteString("mute")
			net.WriteTable({selectedplayer})
		net.SendToServer()
	end

	UnmuteButton:SetPos( 240, 120 )
	UnmuteButton:SetText( "Unmute Chat" )
	UnmuteButton:SetSize( 130, 60 )
	UnmuteButton:SetDisabled(true)
	UnmuteButton.DoClick = function(self)
		if self:GetDisabled()==true then return false end
		surface.PlaySound("buttons/button3.wav")
		net.Start("Mercury:Commands")
			net.WriteString("unmute")
			net.WriteTable({selectedplayer})
		net.SendToServer()		
	end
		
	local players = player.GetAll()
	local t = {}
	for _, ply in ipairs( players ) do
		local item = ctrl:AddLine( ply:Nick() )
		item.ply = ply
	end	

	function ctrl:OnRowSelected(lineid,isselected)
		local line_obj = self:GetLine(lineid)
		surface.PlaySound("buttons/button6.wav")
		UnmuteButton:SetDisabled(false)
		MuteButton:SetDisabled(false)
		selectedplayer = line_obj.ply
		return true
	end
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)

MCMD = {
	["Command"] = "denmark",
	["Verb"] = "censored",
	["RconUse"] = true,
	["Useage"] = "!mute <player>",
	["UseImmunity"] =  true,
	["HasMenu"] = true,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PlayerTarget"] = true,
	["PrivCheck"] = CommPrivCheck,
	["AllowWildcard"] = true
}

function callfunc(caller,args)

	args[1].Muted = true 
	return true, "", false, {}
end

Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)

-- Unmute
MCMD = {
	["Command"] = "unmute",
	["Verb"] = "unmuted",
	["RconUse"] = true,
	["Useage"] = "!unmute <player>",
	["UseImmunity"] = true,
	["HasMenu"] = false,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PrivCheck"] = CommPrivCheck,
	["PlayerTarget"] = true,
	["AllowWildcard"] = true
}
function callfunc(caller,args)
	args[1].Muted = false

	if args[1]._MercuryUserData["muteinfo"] then 

			args[1]._MercuryUserData["muteinfo"] = {permamuted = false}
			Mercury.UDL.SaveSingle(args[1])
	end 


	return true, "", false, {}
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)

-- Gag
MCMD = {
	["Command"] = "gag",
	["Verb"] = "gagged",
	["RconUse"] = true,
	["Useage"] = "!gag <player>",
	["UseImmunity"] =  true,
	["HasMenu"] = true,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PrivCheck"] = CommPrivCheck,
	["PlayerTarget"] = true,
	["AllowWildcard"] = true
}

function callfunc(caller,args)
	args[1].Gagged = true
	local addon = {"."}

	if args[2] == "true" then 
		if !args[1]._MercuryUserData["gaginfo"] then 
			args[1]._MercuryUserData["gaginfo"] = {permagagged = true}
			addon = {" for ",Color(255,0,0), "eternity",Mercury.Config.Colors.Default,"."}
			Mercury.UDL.SaveSingle(args[1])
		end 
	end 

	return true, "", true, {caller,Mercury.Config.Colors.Default," has gagged ", args[1],unpack(addon) }
end

function MCMD.GenerateMenu(frame)
	local selectedplayer = nil 

	local ctrl = vgui.Create( "DListView", frame)
	ctrl:AddColumn( "Players" )
	ctrl:SetSize( 210, 380 )	
	ctrl:SetPos( 10, 0 )
				
	local UnGagButton = vgui.Create( "DButton" , frame)
	local GagButton = vgui.Create( "DButton" , frame)
	GagButton:SetPos( 240, 40 )
	GagButton:SetText( "Gag Voice" )
	GagButton:SetSize( 130, 60 )
	GagButton:SetDisabled(true)
	GagButton.DoClick = function(self)
		if self:GetDisabled()==true then return false end
		surface.PlaySound("buttons/button3.wav")
		net.Start("Mercury:Commands")
			net.WriteString("gag")
			net.WriteTable({selectedplayer})
		net.SendToServer()
	end

	UnGagButton:SetPos( 240, 120 )
	UnGagButton:SetText( "UnGag Voice" )
	UnGagButton:SetSize( 130, 60 )
	UnGagButton:SetDisabled(true)
	UnGagButton.DoClick = function(self)
		if self:GetDisabled()==true then return false end
		surface.PlaySound("buttons/button3.wav")
		net.Start("Mercury:Commands")
			net.WriteString("ungag")
			net.WriteTable({selectedplayer})
		net.SendToServer()
	end

	local players = player.GetAll()
	local t = {}
	for _, ply in ipairs( players ) do
		local item = ctrl:AddLine( ply:Nick() )
		item.ply = ply
	end	

	function ctrl:OnRowSelected(lineid,isselected)
		local line_obj = self:GetLine(lineid)
		surface.PlaySound("buttons/button6.wav")
		UnGagButton:SetDisabled(false)
		GagButton:SetDisabled(false)
		selectedplayer = line_obj.ply
		return true
	end
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)




MCMD = {
	["Command"] = "ungag",
	["Verb"] = "ungagged",
	["RconUse"] = true,
	["Useage"] = "!ungag <player>",
	["UseImmunity"] =  true,
	["HasMenu"] = false,
	["Category"] = "Communications",
	["UseCustomPrivCheck"] = true,
	["PrivCheck"] = CommPrivCheck,
	["PlayerTarget"] = true,
	["AllowWildcard"] = true
}

function callfunc(caller,args)
		args[1].Gagged = false


		if args[1]._MercuryUserData["gaginfo"] then 

			args[1]._MercuryUserData["gaginfo"] = {permagagged = false}
			Mercury.UDL.SaveSingle(args[1])
		end 



	return true, "", false, {}
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)