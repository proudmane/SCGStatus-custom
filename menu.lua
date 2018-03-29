
local Main = SCGStatus

local g_menu_mode     = nil
local g_menu_player   = nil
local g_dialog_player = nil

-------------------------------------------------------------------------------
StaticPopupDialogs["SCGSTATUS_SETCUSTOMDIALOG"] = {
	text = "Enter your custom status.";
	button1 = "On Duty";
	button2 = "Off Duty";
	button3 = "Cancel";
	
	hasEditBox = true;
	enterClicksFirstButton = true;
	hideOnEscape = true;
	timeout = 0;
	--[[OnShow = function()
		
	end;
	OnHide = function()
	end;]]
	OnAccept = function( self )
		local status = self.editBox:GetText()
		if status ~= "" then
			Main.Status.Set( "+ " .. status, g_dialog_player )
		end
	end;
	OnCancel = function( self )
		
		local status = self.editBox:GetText()
		if status ~= "" then
			Main.Status.Set( "- " .. status, g_dialog_player )
		end
	end;
	OnAlt = function( self )
	end;
}


-------------------------------------------------------------------------------
-- Initialize the SET STATUS menu.
--
local function PopulateStatusMenu( level )
	local info
	
	local standard_status = false
	local my_status, onduty, clean = Main.Status.Get( g_menu_player )
	local statuses = Main.Status.List()
	
	for k,v in ipairs( statuses ) do
		
		info = UIDropDownMenu_CreateInfo()
		if v == clean then
			standard_status = true
			info.checked = true
		end
		
		info.func = function()
			Main.Status.Set( v, g_menu_player )
			HideDropDownMenu(1)
		end
		
		local text = v
		
		if v:sub(1,1) == "+" then
			-- on-duty thing
			text = "|cff00ff00" .. text:sub( 3 )
		elseif v:sub(1,1) == "-" then
			-- off-duty thing
			text = "|cffff0000" .. text:sub( 3 )
		end
		info.text         = text
		info.notCheckable = false
		
		UIDropDownMenu_AddButton( info, level );
	end
	
	info = UIDropDownMenu_CreateInfo()
	info.text = "Custom"
	info.notCheckable = false
	if not standard_status then
		info.checked = true
	end
	info.func = function() 
		SCGStatusMinimapMenu:Hide()
		HideDropDownMenu(1)
		g_dialog_player = g_menu_player
		StaticPopup_Show( "SCGSTATUS_SETCUSTOMDIALOG" )
	end
	UIDropDownMenu_AddButton( info, level ); 
end

-------------------------------------------------------------------------------
local function PopulateMainMenu( level )
	info = UIDropDownMenu_CreateInfo()
	info.text         = "Status"
	info.notCheckable = true
	info.hasArrow     = true
	info.value        = {
		Level1_Key = "STATUS";
	}
	info.tooltipTitle     = "Status."
	info.tooltipText      = "Changes your guard status."
	info.tooltipOnButton  = true
	UIDropDownMenu_AddButton( info, level )
	
	info = UIDropDownMenu_CreateInfo()
	info.text         = "Roster"
	info.notCheckable = true
	info.hasArrow     = false
	info.func         = function()
		Main.Roster.Show()
	end
	info.tooltipTitle     = "Roster."
	info.tooltipText      = "Opens the guard roster."
	info.tooltipOnButton  = true
	UIDropDownMenu_AddButton( info, level )
	
	info = UIDropDownMenu_CreateInfo()
	info.text         = "Hide Off Duty"
	info.checked      = Main.db.char.hide_off_duty
	info.isNotRadio   = true
	info.hasArrow     = false
	info.keepShownOnClick = true
	info.func         = function()
		Main.db.char.hide_off_duty = not Main.db.char.hide_off_duty
		Main:GuildRosterUpdate()
	end
	info.tooltipTitle     = "Hide Off Duty."
	info.tooltipText      = "Hides the on-screen panel when you are off duty."
	info.tooltipOnButton  = true
	UIDropDownMenu_AddButton( info, level )
end
 
-------------------------------------------------------------------------------
local function InitializeMenu( self, level )

	local info
	level = level or 1
	
	if g_menu_mode == "normal" then
		if level == 1 then
			PopulateMainMenu( level )
		elseif level == 2 then
			PopulateStatusMenu( level )
		end
	elseif g_menu_mode == "status" then
		if level == 1 then
			PopulateStatusMenu( level )
		end
	end
end

local function InitMenu( menu )
	if not Main.menu then
		Main.menu = CreateFrame( "Button", "SCGStatusMinimapMenu", UIParent, "UIDropDownMenuTemplate" )
		Main.menu.displayMode = "MENU"
	end
	
	UIDropDownMenu_Initialize( SCGStatusMinimapMenu, InitializeMenu )
	UIDropDownMenu_JustifyText( SCGStatusMinimapMenu, "LEFT" )
	
end

-------------------------------------------------------------------------------
function Main.ShowMenu()
	g_menu_mode   = "normal"
	g_menu_player = nil
	InitMenu()
	local x,y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	ToggleDropDownMenu( 1, nil, Main.menu, "UIParent", x / scale, y / scale )
end

-------------------------------------------------------------------------------
-- Show the Set Status menu for a different player.
--
function Main.ShowSetStatusMenu( player )
	g_menu_mode   = "status"
	g_menu_player = player
	InitMenu()
	local x,y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	ToggleDropDownMenu( 1, nil, Main.menu, "UIParent", x / scale, y / scale )
end
