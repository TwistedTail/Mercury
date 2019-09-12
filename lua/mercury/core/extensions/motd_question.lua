util.AddNetworkString("Mercury::MOTDQuest")


Mercury.ModHook.Add("AddPrivileges","MOTDQuest",function()
    Mercury.Commands.AddPrivilege("skipquestion")
end)

SEND_QUESTION = 1
SEND_ANSWER = 2
SEND_GIVEUP = 3
SEND_MOTDCLOSE = 4

local questions = {
    [1]={
        question = "What is an ADVANCED (not weld/thruster/etc) tool that is essential for building with ACF?",
        id = "Tool Question",
        answers={
            "alignment",
            "parent",
            "precision",
            "acf",
            "wire",
            "socket",
            "elastic",
            "hydraulic",
            "e2",
            "expression 2",
            "starfall",
            "axis",
            "centre",
            "center",
            "collide",
            "ruler",
            "fin",
            "visclip",
            "visual clip",
            "make spherical",
            "slider",
            "buoyancy",
            "mass",
            "duplicator",
            "armor",
            "advdupe",
            "adv",
            "duplicator",
            "weight",
            "armor",
            "measuring stick",
        }
    },
    [2]={
        question = "What addon adds gearboxes, guns, engines, and more to sandbox?",
        id = "ACF Question",
        answers={
            "acf",
            "armored",
            "combat",
            "framework"
        }
    }
}

Mercury.ModHook.Add("PostUserDataLoaded","MOTDQuest",function(player, data)

end)


net.Receive("Mercury::MOTDQuest", function(len, ply)

    local command = net.ReadInt(8)
    //print(command)

    if command == SEND_MOTDCLOSE then 
        if ply:HasPrivilege("skipquestion") or ply._MercuryUserData["passedmotd"] then return false end
        local Q = table.Random(questions)
        ply.motdquestion = Q
        net.Start("Mercury::MOTDQuest")
            net.WriteInt(SEND_QUESTION, 8)
            net.WriteString(Q.question)
        net.Send(ply)
    end

    if command == SEND_ANSWER then 
        local answer = net.ReadString()
        if not ply.motdquestion then ply:Kick("Tampering") return end
        local Q = ply.motdquestion 
        local attempts = ply._MercuryUserData.motdattempts
        answer = string.lower(answer)
        local correct = false
        for i,a in pairs(Q.answers) do
            if string.find(answer,a) then
                correct = true 
            end
        end
        if not correct then 
            print(ply:GetName() .. "failed motd question (" .. Q.id .. " - " .. answer .. ")")
            if attempts then 
                if attempts >= 2 then 
                    attempts = attempts+1
                    ply._MercuryUserData["motdattempts"] = attempts
                    Mercury.UDL.SaveSingle(ply)
                    --Mercury.Util.Broadcast({Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, ply, " Failed the MOTD question so much they got banned!",""})
                    Mercury.Util.Broadcast({Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, ply, " failed the MOTD question so much they got banned! Their question was: ",Mercury.Config.Colors.Arg, Q.id, Mercury.Config.Colors.Default, " and their answer was: ",Mercury.Config.Colors.Arg, (#answer > 0 and (" '" .. answer .. "' ") or "nothing (empty string)"),""})
                    timer.Simple(0.25,function()
                        Mercury.Bans.Add(nil,ply,1440,"Failed MOTD Question too many times")
                        
                    end)
                else
                    Mercury.Util.Broadcast({Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, ply, " failed the MOTD question. Their question was: ",Mercury.Config.Colors.Arg, Q.id, Mercury.Config.Colors.Default, " and their answer was: ",Mercury.Config.Colors.Arg, (#answer > 0 and (" '" .. answer .. "' ") or "nothing (empty string)"),""})
                    attempts = attempts+1
                    ply._MercuryUserData["motdattempts"] = attempts
                    Mercury.UDL.SaveSingle(ply)
                    timer.Simple(0.25,function()
                        ply:Kick("You failed the test, maybe build servers aren't for you? (Answer" .. (#answer > 0 and (" '" .. answer .. "' ") or " ") .. "not recognized as valid)")
                        print(attempts)
                    end)
                end
            else
                print("User does not have any motd attempts, creating table...")
                ply._MercuryUserData["motdattempts"] = 1
                Mercury.UDL.SaveSingle(ply)
                Mercury.Util.Broadcast({Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, ply, " failed the MOTD question. Their question was: ",Mercury.Config.Colors.Arg, Q.id, Mercury.Config.Colors.Default, " and their answer was: ",Mercury.Config.Colors.Arg, (#answer > 0 and (" '" .. answer .. "' ") or "nothing (empty string)"),""})
                timer.Simple(0.25,function()
                    ply:Kick("You failed the test, maybe build servers aren't for you? (Answer" .. (#answer > 0 and (" '" .. answer .. "' ") or " ") .. "not recognized as valid)")
                    print(attempts)
                end)
            end
        else
            Mercury.Util.Broadcast({Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, ply, " passed the MOTD question. Their question was: ",Mercury.Config.Colors.Arg, Q.id, Mercury.Config.Colors.Default, " and their answer was: ",Mercury.Config.Colors.Arg, answer,""})
            print(ply:GetName() .. "passed motd question (" .. Q.id .. " - " .. answer .. ")")
            ply._MercuryUserData["passedmotd"] = true 
            ply._MercuryUserData["motdattempts"] = nil --Wipe attempts, theyre in.   
        end
    end

    if command == SEND_GIVEUP then
        Mercury.Util.Broadcast({Mercury.Config.Colors.Server,"[Server] ", Mercury.Config.Colors.Default, ply, " decided not to do the MOTD test.",""})
        print(ply:GetName() .. "did not attempt motd question.")
        timer.Simple(0.25,function()
            ply:Kick("Disconnected (Quit MOTD question)")
        end)
    end

end)