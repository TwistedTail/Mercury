--Webhook Stuff
local chatlog = "https://discordapp.com/api/webhooks/443871714368159766/LUEO-5MDoV4jp39SHLmsp0ZYWsgi3z0X-mCFMi74iZq0UC2oZYA_mVlGsbbQEhZqh6Fq"
local avatar = "http://i.imgur.com/c4xeJix.png" --Default avatar





local MCMD = {}
MCMD.Command = "freezeall"
MCMD.Verb = ""
MCMD.RconUse = true
MCMD.Useage = "<player>"
MCMD.UseImmunity = false
MCMD.PlayerTarget = false
MCMD.HasMenu = false
MCMD.Category = "fuck" 
 
function callfunc(caller, args)
  for k,v in pairs(ents.GetAll()) do
    if v:CPPIGetOwner()==caller then 
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
   end

    
    return true,"",true,{caller, Mercury.Config.Colors.Default, " has frozened all of their props."}

end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)


local MCMD = {}
MCMD.Command = "freezemap"
MCMD.Verb = ""
MCMD.RconUse = true
MCMD.Useage = "<player>"
MCMD.UseImmunity = false
MCMD.PlayerTarget = false
MCMD.HasMenu = false
MCMD.Category = "fuck" 
 
function callfunc(caller, args)
  for k,v in pairs(ents.GetAll()) do

        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
  	if v:IsPlayer() then 
  		v:EmitSound("weapons/icicle_freeze_victim_01.wav")

  	end
   end
    return true,"",true,{caller, Mercury.Config.Colors.Default, " frozened the map."}
    
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)


local MCMD = {}
MCMD.Command = "freezeallof"
MCMD.Verb = ""
MCMD.RconUse = true
MCMD.Useage = "<player>"
MCMD.UseImmunity = true 
MCMD.PlayerTarget = true
MCMD.HasMenu = false
MCMD.Category = "fuck" 
 
function callfunc(caller, args)
  for k,v in pairs(ents.GetAll()) do
    if v:CPPIGetOwner()==args[1] then 
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
   end
    return true,"",true,{caller, Mercury.Config.Colors.Default, " has frozed all of ", args[1], "'s props."}
    
end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)
