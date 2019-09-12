Mercury = {} // Onward!

Mercury.Version = "Mercury 2.5 v.1.1.1.3"
Mercury.Booted = false
Mercury.Config = {
	UseScoreboard = true,  // Don't change this! This is designed to contain default config values in case yours get fucked up some how.
	UseTeams = true, TeamOffset = 50000,
	UseRankTime = true 

} 
   

 
local t_then = SysTime()
local now = SysTime
          
 CreateConVar( "mercury_version", Mercury.Version , FCVAR_REPLICATED , "Current version of mercury.") 
local q = 0


if SERVER then
 AddCSLuaFile("mercury/config.lua") 
 AddCSLuaFile("mercury/localizer.lua")

end
include("mercury/config.lua") 

 
print("Starting Mercury")
 
   
 
if SERVER then 
    	MsgC(Color(255,255,0),"Checking existance of data folder... ")
    	//tout("Checking existance of data folder...")
	if !file.Exists("mercury","DATA") then
		 	MsgC(Color(255,0,0)," NO  \n") 
		file.CreateDir("mercury") 
		    MsgN(" ") MsgC(Color(255,255,0)," Data folder created \n")
		else
			  	MsgC(Color(0,255,0)," OK. \n")
	

	end
	
	AddCSLuaFile()  

	for _,f in pairs(file.Find("mercury/core/lib/*.lua","LUA")) do
		local S,ER =	pcall(function() include("mercury/core/lib/" .. f) end)
		if (S) then print("Loaded LIBRARY: " .. f)  else
			 Msg("[Mercury]: " .. ER)
			
		end 
	end

	Mercury.ModHook.Call("LibrariesLoaded")

	for _,f in pairs(file.Find("mercury/core/*.lua","LUA")) do
		local S,ER =	pcall(function() include("mercury/core/" .. f) end)
		if (S) then print("Loaded CORE: " .. f)   else
			 Msg("[Mercury]: " .. ER)
			
		end
	end

	Mercury.ModHook.Call("CoresLoaded")

	for _,f in pairs(file.Find("mercury/client/*.lua","LUA")) do
		local S,ER =	pcall(function() AddCSLuaFile("mercury/client/" .. f) end) 
		if (S) then print("Push CLIENT: " .. f)   else
			 Msg("[Mercury]: Loaded " .. f .. "\n")
			
		end
	end

	Mercury.ModHook.Call("ClientPacked")

	for _,f in pairs(file.Find("mercury/core/extensions/*.lua","LUA")) do
		local S,ER =	pcall(function() include("mercury/core/extensions/" .. f) end)
		if (S) then print("Loaded: " .. f)  else
	 		 Msg("[Mercury]: " .. ER)
	 		 
		end
	end

		Mercury.ModHook.Call("ExtensionsLoaded")
	
		Mercury.ModHook.Call("AddPrivileges")
		Mercury.ModHook.Call("PrivilegesReady")
		Mercury.ModHook.Call("ServerSideLoaded")

end

 local MerMat = Material("mercury/mercury.png")
local msg = {}
local dispmsg = {} 
local oldmsg = Msg 
local oldprint = print 
local oldmsgn = MsgN 
local fc = 0 
function print( ... )
	local band = {...}
	pcall(function() 
		
		msg[#msg + 1] =  table.concat(band," ")
	end)
end


function Msg(... )
	local band = {...}
	msg[#msg + 1] =  table.concat(band," ")
end 

function MsgN(... )
	local band = {...}
	msg[#msg + 1] =  table.concat(band," ")
end 

  
local rmc = 0
local msgc = 0 
local fir = false
local snd = false

hook.Add("DrawOverlay","MercuryStart",function()
	fc = fc + 1 
	if fc > 2 then 
		if msg[1]!=nil then 
			dispmsg[#dispmsg + 1] = msg[1]
			table.remove(msg,1)
   			rmc = rmc + 1
		end 
 

    if #msg < 3 and not snd then 
        surface.PlaySound("mercury/mercury_info.ogg")
        snd = true
       
    end
    
end 

 surface.SetDrawColor(Color(255,255,255,255))
 surface.SetDrawColor(Color(0,0,0,255))
 surface.DrawRect(ScrW() * 0.73 ,ScrH() * 0.79  + 70,500,25)
 surface.SetDrawColor(Color(math.abs(math.sin(CurTime())) * 255 ,math.abs(math.sin(CurTime()*2)) * 255,math.abs(math.sin(CurTime()*6)) * 255,255))
 surface.DrawRect(ScrW() * 0.73 ,ScrH() * 0.79 + 70,500 * (rmc / msgc) ,25)
 draw.DrawText( msg[1] or "LOAD OK" , "ChatFont", ScrW() * 0.73 + 200, ScrH() * 0.79 + 70, Color(255,255,255), TEXT_ALLIGN_LEFT) 

end )

hook.Add("HUDPaint","m3startend",function()
	if #msg==0 then 
		hook.Remove("DrawOverlay","MercuryStart")
		hook.Remove("HUDPaint","m3startend")
	end 
end)
 
  
if CLIENT then


	for _,f in pairs(file.Find("mercury/client/*.lua","LUA")) do
		local S,ER =	pcall(function() include("mercury/client/" .. f) end) 
		if (S) then print("EXEC CLIENT: " .. f) else
			 Msg("nope: " .. f .. "\n")
		end
	end

	Mercury.ModHook.Call("ExtensionsLoaded")
    Mercury.ModHook.Call("AddPrivileges")
    Mercury.ModHook.Call("PrivilegesReady")
    Mercury.ModHook.Call("ClientSideLoaded")
	
end

msgc = #msg

include("mercury/localizer.lua")


print( Mercury.Version .. " fully loaded. ")





print = oldprint
MsgN = oldmsgn
Msg = oldmsg 

Mercury.Booted = true // This seems really stupid, I know. This is for later, it helps with live-updates.

