Mercury.ModHook.Add("AddPrivileges","Greentext",function()
    Mercury.Commands.AddPrivilege("greentext")
end)

hook.Add("PlayerSay","greentext",function(P,T)
    if T then 
        if T[1]==">" then 
            if P:HasPrivilege("greentext") then
                Mercury.Util.Broadcast({P,Color(255,255,255),": ",Color(120,195,34),T } )
            end
            return ""
        end 
        if T[1]=="<" then 
            if P:HasPrivilege("greentext") then
                Mercury.Util.Broadcast({P,Color(255,255,255),": ",Color(66,134,244),T } )
            end
            return ""
        end 
    end
end)
