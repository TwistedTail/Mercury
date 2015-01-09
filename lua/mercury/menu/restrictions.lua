  local MenuTab = {}
  MenuTab.index = 4 //Internal identifier for table
  MenuTab.Name = "Restrictions" // Display name 
  MenuTab.Desc = "Tool and Sent restrictions" // Description 
  MenuTab.Icon = "icon16/wrench.png" // Icon





  local tabs = {}



local EXTEND_WEAPONS = {
	"weapon_crowbar",
	"weapon_pistol",
	"weapon_physcannon",
	"weapon_stunstick",
	"weapon_slam",
	"weapon_frag",
	"weapon_ar2",
	"weapon_smg1",
	"weapon_rpg",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_bugbait"

}

local EXTEND_SENTS = {
	
	"item_ammo_357"  ,
	"item_ammo_ar2"  ,
	"item_ammo_ar2_altfire",
	"combine_mine"  ,
	"item_ammo_crossbow"  ,
	"item_healthcharger"  ,
	"item_healthkit"  ,
	"item_healthvial"  ,
	"grenade_helicopter"  ,
	"weapon_striderbuster"  ,
	"item_ammo_pistol"  ,
	"item_rpg_round"  ,
	"item_box_buckshot"  ,
	"item_ammo_smg1"  ,
	"item_ammo_smg1_grenade"  ,
	"item_suit"  ,
	"item_battery"  ,
	"item_suitcharger"  ,
	"npc_grenade_frag"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  , // Did I put enough emphasis on how much I hate this?
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,
	"prop_thumper"  ,




}




function GenerateSwepMenu(frame,ranktab,rindex)
			if !ranktab["restrictions"] then 
				ranktab["restrictions"] = {}
			end
			if !ranktab["restrictions"]["Weaps"] then 
				ranktab["restrictions"]["Weaps"] = {}
			end


			local selected_index 

			local noitems = vgui.Create( "DListView", frame)
			noitems:AddColumn( "Useable Weapons" )
			noitems:SetSize( 150, 355 )	
			noitems:SetPos( 5, 5 )
				

			local currentitems = vgui.Create( "DListView", frame)
			currentitems:AddColumn( "Restricted Weapons" )
			currentitems:SetSize( 150, 355 )	
			currentitems:SetPos( 220, 5 )




				local allsweps = {}
				for _, Weap in pairs( weapons.GetList() ) do
					allsweps[Weap.ClassName] = true 
				end
				for k,v in pairs(EXTEND_WEAPONS) do
					allsweps[v] = true 
				end

			
	
			for k,v in SortedPairs(ranktab.restrictions["Weaps"]) do
				if #k > 1 then
					local gx = currentitems:AddLine(k)
					gx.cname = k
				end
				for class,_ in pairs(allsweps) do
					if class==k then 
						allsweps[class] = nil
					end
				end
			end

			for k,bool in SortedPairs(allsweps) do
				local gx = noitems:AddLine(k)
				gx.cname = k
				
			end


			

			local AddItemButton = vgui.Create( "DButton" , frame)
			AddItemButton:SetPos( 167 ,  150 )
			AddItemButton:SetText( "-->" )
			AddItemButton:SetSize( 40, 20 )
			AddItemButton:SetDisabled(true)
			AddItemButton.DoClick = function(self)
				if self:GetDisabled()==true then return false end
				if !selected_index then surface.PlaySound("buttons/button2.wav") return false else surface.PlaySound("mercury/mercury_ster_switch.ogg")  end
				local xg = currentitems:AddLine(selected_index)
				xg.cname = selected_index
				local lid = noitems:GetSelectedLine()
				noitems:RemoveLine(lid)	
				net.Start("Mercury:Commands")
					net.WriteString("restrictswep")
					net.WriteTable({tostring(selected_index),"add",tostring(rindex)})
				net.SendToServer()
				selected_index = nil
				AddItemButton:SetDisabled(true)
				
			end



			local RemItemButton = vgui.Create( "DButton" , frame)
			RemItemButton:SetPos( 167,  175 )
			RemItemButton:SetText( "<--" )
			RemItemButton:SetSize( 40, 20 )
			RemItemButton:SetDisabled(true)
			RemItemButton.DoClick = function(self)
				if self:GetDisabled()==true then return false end
				if !selected_index then surface.PlaySound("buttons/button2.wav") return false else surface.PlaySound("mercury/mercury_ster_switch.ogg")  end

				local xg = noitems:AddLine(selected_index)
				xg.cname = selected_index
				local lid = currentitems:GetSelectedLine()
				currentitems:RemoveLine(lid)	
				net.Start("Mercury:Commands")
					net.WriteString("restrictswep")
					net.WriteTable({tostring(selected_index),"remove",tostring(rindex)})
				net.SendToServer()
				selected_index = nil
				RemItemButton:SetDisabled(true)

			end


			function noitems:OnRowSelected(lineid,isselected)
				local line_obj = self:GetLine(lineid)
				surface.PlaySound("buttons/button6.wav")
				currentitems:ClearSelection()
				RemItemButton:SetDisabled(true)
				AddItemButton:SetDisabled(false)
				selected_index = line_obj.cname
				return true
			end

			function currentitems:OnRowSelected(lineid,isselected)
				local line_obj = self:GetLine(lineid)
				surface.PlaySound("buttons/button6.wav")
				noitems:ClearSelection()
				RemItemButton:SetDisabled(false)
				AddItemButton:SetDisabled(true)
				selected_index = line_obj.cname
				return true
			end
 
end



function GenerateSentsMenu(frame,ranktab,rindex)
			if !ranktab["restrictions"] then 
				ranktab["restrictions"] = {}
			end
			if !ranktab["restrictions"]["Sents"] then 
				ranktab["restrictions"]["Sents"] = {}
			end


			local selected_index 

			local noitems = vgui.Create( "DListView", frame)
			noitems:AddColumn( "Spawnable Sents" )
			noitems:SetSize( 150, 355 )	
			noitems:SetPos( 5, 5 )
				

			local currentitems = vgui.Create( "DListView", frame)
			currentitems:AddColumn( "Restricted Sents" )
			currentitems:SetSize( 150, 355 )	
			currentitems:SetPos( 220, 5 )




				local allssents = {}
				for _, Weap in pairs( scripted_ents.GetSpawnable() ) do
					allssents[Weap.ClassName] = true 
				end
				for k,v in pairs(EXTEND_SENTS) do
					allssents[v] = true 
				end

			
	
			for k,v in SortedPairs(ranktab.restrictions["Sents"]) do
				if #k > 1 then
					local gx = currentitems:AddLine(k)
					gx.cname = k
				end
				for class,_ in pairs(allssents) do
					if class==k then 
						allssents[class] = nil
					end
				end
			end

			for k,bool in SortedPairs(allssents) do
				local gx = noitems:AddLine(k)
				gx.cname = k
				
			end


			

			local AddItemButton = vgui.Create( "DButton" , frame)
			AddItemButton:SetPos( 167 ,  150 )
			AddItemButton:SetText( "-->" )
			AddItemButton:SetSize( 40, 20 )
			AddItemButton:SetDisabled(true)
			AddItemButton.DoClick = function(self)
				if self:GetDisabled()==true then return false end
				if !selected_index then surface.PlaySound("buttons/button2.wav") return false else surface.PlaySound("mercury/mercury_ster_switch.ogg")  end
				local xg = currentitems:AddLine(selected_index)
				xg.cname = selected_index
				local lid = noitems:GetSelectedLine()
				noitems:RemoveLine(lid)	
				net.Start("Mercury:Commands")
					net.WriteString("restrictsent")
					net.WriteTable({tostring(selected_index),"add",tostring(rindex)})
				net.SendToServer()
				selected_index = nil
				AddItemButton:SetDisabled(true)
				
			end



			local RemItemButton = vgui.Create( "DButton" , frame)
			RemItemButton:SetPos( 167,  175 )
			RemItemButton:SetText( "<--" )
			RemItemButton:SetSize( 40, 20 )
			RemItemButton:SetDisabled(true)
			RemItemButton.DoClick = function(self)
				if self:GetDisabled()==true then return false end
				if !selected_index then surface.PlaySound("buttons/button2.wav") return false else surface.PlaySound("mercury/mercury_ster_switch.ogg")  end

				local xg = noitems:AddLine(selected_index)
				xg.cname = selected_index
				local lid = currentitems:GetSelectedLine()
				currentitems:RemoveLine(lid)	
				net.Start("Mercury:Commands")
					net.WriteString("restrictsent")
					net.WriteTable({tostring(selected_index),"remove",tostring(rindex)})
				net.SendToServer()
				selected_index = nil
				RemItemButton:SetDisabled(true)

			end


			function noitems:OnRowSelected(lineid,isselected)
				local line_obj = self:GetLine(lineid)
				surface.PlaySound("buttons/button6.wav")
				currentitems:ClearSelection()
				RemItemButton:SetDisabled(true)
				AddItemButton:SetDisabled(false)
				selected_index = line_obj.cname
				return true
			end

			function currentitems:OnRowSelected(lineid,isselected)
				local line_obj = self:GetLine(lineid)
				surface.PlaySound("buttons/button6.wav")
				noitems:ClearSelection()
				RemItemButton:SetDisabled(false)
				AddItemButton:SetDisabled(true)
				selected_index = line_obj.cname
				return true
			end
 
end
--		local TOOLS = weapons.GetStored("gmod_tool").Tool


function GenerateToolsMenu(frame,ranktab,rindex)
			if !ranktab["restrictions"] then 
				ranktab["restrictions"] = {}
			end
			if !ranktab["restrictions"]["Tools"] then 
				ranktab["restrictions"]["Tools"] = {}
			end


			local selected_index 

			local noitems = vgui.Create( "DListView", frame)
			noitems:AddColumn( "Spawnable Tools" )
			noitems:SetSize( 150, 355 )	
			noitems:SetPos( 5, 5 )
				

			local currentitems = vgui.Create( "DListView", frame)
			currentitems:AddColumn( "Restricted Tools" )
			currentitems:SetSize( 150, 355 )	
			currentitems:SetPos( 220, 5 )




				local alltools = {}
				for _, Weap in pairs( weapons.GetStored("gmod_tool").Tool ) do
					alltools[_] = true 
				end
	
	
			for k,v in SortedPairs(ranktab.restrictions["Tools"]) do
				if #k > 1 then
					local gx = currentitems:AddLine(k)
					gx.cname = k
				end
				for class,_ in pairs(alltools) do
					if class==k then 
						alltools[class] = nil
					end
				end
			end

			for k,bool in SortedPairs(alltools) do
				local gx = noitems:AddLine(k)
				gx.cname = k
				
			end


			

			local AddItemButton = vgui.Create( "DButton" , frame)
			AddItemButton:SetPos( 167 ,  150 )
			AddItemButton:SetText( "-->" )
			AddItemButton:SetSize( 40, 20 )
			AddItemButton:SetDisabled(true)
			AddItemButton.DoClick = function(self)
				if self:GetDisabled()==true then return false end
				if !selected_index then surface.PlaySound("buttons/button2.wav") return false else surface.PlaySound("mercury/mercury_ster_switch.ogg")  end
				local xg = currentitems:AddLine(selected_index)
				xg.cname = selected_index
				local lid = noitems:GetSelectedLine()
				noitems:RemoveLine(lid)	
				net.Start("Mercury:Commands")
					net.WriteString("restricttool")
					net.WriteTable({tostring(selected_index),"add",tostring(rindex)})
				net.SendToServer()
				selected_index = nil
				AddItemButton:SetDisabled(true)
				
			end



			local RemItemButton = vgui.Create( "DButton" , frame)
			RemItemButton:SetPos( 167,  175 )
			RemItemButton:SetText( "<--" )
			RemItemButton:SetSize( 40, 20 )
			RemItemButton:SetDisabled(true)
			RemItemButton.DoClick = function(self)
				if self:GetDisabled()==true then return false end
				if !selected_index then surface.PlaySound("buttons/button2.wav") return false else surface.PlaySound("mercury/mercury_ster_switch.ogg")  end

				local xg = noitems:AddLine(selected_index)
				xg.cname = selected_index
				local lid = currentitems:GetSelectedLine()
				currentitems:RemoveLine(lid)	
				net.Start("Mercury:Commands")
					net.WriteString("restricttool")
					net.WriteTable({tostring(selected_index),"remove",tostring(rindex)})
				net.SendToServer()
				selected_index = nil
				RemItemButton:SetDisabled(true)

			end


			function noitems:OnRowSelected(lineid,isselected)
				local line_obj = self:GetLine(lineid)
				surface.PlaySound("buttons/button6.wav")
				currentitems:ClearSelection()
				RemItemButton:SetDisabled(true)
				AddItemButton:SetDisabled(false)
				selected_index = line_obj.cname
				return true
			end

			function currentitems:OnRowSelected(lineid,isselected)
				local line_obj = self:GetLine(lineid)
				surface.PlaySound("buttons/button6.wav")
				noitems:ClearSelection()
				RemItemButton:SetDisabled(false)
				AddItemButton:SetDisabled(true)
				selected_index = line_obj.cname
				return true
			end
 
end




tabs["sweprest"] = {name = "SWEPs",genfunc = GenerateSwepMenu, icon = "icon16/gun.png",desc = "SWEP restrictions!"}
tabs["sentrest"] = {name = "Entities",genfunc = GenerateSentsMenu, icon = "icon16/box.png",desc = "SENT Restrictions!"}
tabs["toolrest"] = {name = "Tools",genfunc = GenerateToolsMenu, icon = "icon16/wrench.png",desc = "TOOL restrictions!"}
function GenerateTabs(frame,rdata)
	local prosh = vgui.Create("DPropertySheet", frame) // Property sheet in which everything attaches to.


	 prosh:Dock(FILL)


	
	 function prosh:GetWindow()
	    return frame
	 end 

	 function frame:GetPropertySheet()
	 	return prosh
	 end



  
	for k,v in pairs(tabs) do
		local window = vgui.Create("DPanel",prosh)
		window:SetSize(640,456)
		//	indow.Paint = function()
		//	draw.RoundedBox(4, 0, 0, window:GetWide(), window:GetTall(), Color( math.abs(255*math.sin(CurTime())) ,134, 255, 250 ))
	    // end
		local gtab = tabs[k]

		local gf = tabs[k]["genfunc"]
		
		local stat , err = xpcall(gf ,function(err) Mercury.Menu.ShowError(err .. " \n " .. debug.traceback()) end,window,rdata,rdata["_RANKINDEX"])

		
		prosh:AddSheet(  gtab.name ,window, gtab.icon , false, false, gtab.desc ) // Register window on propertysheet.
	end

end

 function GenerateMenu(CONTAINER)




 	local gframe = vgui.Create( "ContextBase" , CONTAINER ) 
	gframe:SetSize( 390, 400 )
	gframe:SetPos(225,10)
	gframe:SetVisible( true )
	function gframe:GetWindow()
		return CONTAINER
	end	



	CONTAINER.CurrentRestrictGFrame  = gframe

	local ctrl = vgui.Create( "DListView", CONTAINER )
	ctrl:AddColumn( "Ranks" )
	ctrl:SetSize( 210, 400 )	
	ctrl:SetPos( 10, 10 )
	ctrl:SetMultiSelect(false)
	function ctrl:GetWindow()
		return CONTAINER
	end
	function ctrl:Regenerate()
		self:Clear()
			local sortab = {}
			for k,v in SortedPairs(Mercury.Ranks.RankTable) do
			local line = ctrl:AddLine(k)
		 		local menutab = table.Copy(v)
		 		menutab._RANKINDEX = k // so much hax.
		 		line.RankTable = menutab
			end

 
	end
	function ctrl:OnRowSelected(lineid,isselected)
			local line = self:GetLine(lineid)
			local gframe = vgui.Create( "ContextBase" , CONTAINER )
			gframe:SetSize( 390, 400 )
			gframe:SetPos(225,10)
			gframe:SetVisible( true )
			function gframe:GetWindow()
				return CONTAINER
			end
		
			self:GetWindow().CurrentRestrictGFrame = gframe
			if line.RankTable then 
					GenerateTabs(gframe,line.RankTable)
			end
			line:SetSelected(true)
			self.LastSelectedRow = line
		
	end
	ctrl:Regenerate()









/*	


*/
 

 
 end

Mercury.Menu.AddMenuTab(MenuTab.index,MenuTab.Icon,MenuTab.Name,MenuTab.Desc,GenerateMenu) 
