local MOTDURL = "http://steamcommunity.com/groups/Flatgrass_Construct_Railroad/discussions/0/613936673469402409/";
    
 
local function MOTDMenu()
	if Mercury.Config.UseMOTD then  
		local buttonFlag = false;
		
		local MF = vgui.Create("DFrame")
		MF:SetSize(ScrW() - 100, ScrH() - 100);
		MF:Center()
		MF:SetTitle( "Server MOTD" )
		MF:SetBackgroundBlur( true )
		MF:SetVisible( true )
		MF:SetDraggable( false )
		MF:ShowCloseButton( false )
		MF:MakePopup()
		
		//HTML view. :D
		html = vgui.Create("HTML");
		html:SetParent(MF)
		html:SetPos(5,25)
		html:Dock(FILL)
		html:OpenURL(Mercury.Config.MotdURL)

		
		local B = vgui.Create("DButton", MF)
		B:SetSize(50,40)
		B:Dock(BOTTOM)
		B:SetText("Okay, I've read the rules, and agree not to be a total idiot.")
		B.DoClick = function(ply)
				MF:Close()
				pcall(function()
					net.Start("Mercury::MOTDQuest")
						net.WriteInt(SEND_MOTDCLOSE, 8)
					net.SendToServer()
				end)
			
		end 
	end 

end

concommand.Add("motd", MOTDMenu);


Mercury.ModHook.Add("GotConfig","OpenMOTD",function()

	if not MERCURY_MOTD_SHOWN then 

			MOTDMenu()
			hook.Remove("HUDPaint","OpenMOTD")
			MERCURY_MOTD_SHOWN = true 

	end 
end)
