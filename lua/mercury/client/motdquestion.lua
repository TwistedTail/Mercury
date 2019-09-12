SEND_QUESTION = 1
SEND_ANSWER = 2
SEND_GIVEUP = 3
SEND_MOTDCLOSE = 4

Mercury.ModHook.Add("AddPrivileges","MOTDQuest",function()
    Mercury.Commands.AddPrivilege("skipquestion")
end)

net.Receive("Mercury::MOTDQuest", function()
    local command = net.ReadInt(8)
    //print(command)
    if command == SEND_QUESTION then 
        local question = net.ReadString()
        Derma_StringRequest(
            "Please answer this question to prove you aren't dumb!", 
            question, 
            "", 
            function(text)
            net.Start("Mercury::MOTDQuest")
                net.WriteInt(SEND_ANSWER, 8)
                net.WriteString(text)
            net.SendToServer()
            end, 
            function()
            net.Start("Mercury::MOTDQuest")
                net.WriteInt(SEND_GIVEUP, 8)
            net.SendToServer()
            end, 
            "Answer", 
            "Disconnect"
            )       
    end
end)

