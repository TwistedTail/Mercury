


-- Slay
MCMD = {
    ["Command"] = "fixparticles",
    ["Verb"] = "slayed",
    ["RconUse"] = true,
    ["Useage"] = "slay <player>",
    ["UseImmunity"] =  true,
    ["HasMenu"] = false,
    ["Category"] = "Fun",
    ["UseCustomPrivCheck"] = false,
    ["PlayerTarget"] = true,
    ["AllowWildcard"] = true
}

function callfunc(caller, args)
    if IsValid(args[1]) then
 
        if args[1]:IsPlayer() then 
           
            args[1]:SendLua([[if _RB_PARTICLE_EMITTERS then 
	for k,v in pairs(_RB_PARTICLE_EMITTERS) do
		if IsValid(v) then v:Finish()  end
	end
else            
	Error("!MERCURY! Renderbender module is not initialized.")                
end
]])
            
        
                return true,"",true, {caller, Mercury.Config.Colors.Default, " has fixed particles for " , Mercury.Config.Colors.Server , args[1] }
        
    
            
        end 
        
        
    end     
    
  

end
Mercury.Commands.AddCommand(MCMD.Command, MCMD, callfunc)