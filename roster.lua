local Main = SCGStatus
local AceGUI = LibStub("AceGUI-3.0") 
local Me = {}
Main.Roster = Me

-------------------------------------------------------------------------------
local function OnRosterUpdate( self )
	if GetTime() > Main.guild_roster_update + 15 then
		Main.guild_roster_update = GetTime()
		GuildRoster()
	end
end

-------------------------------------------------------------------------------
-- Initialization function
--
local function SetupUI()
	if Me.ui then return end
	
	Me.ui = {}
	local f = AceGUI:Create( "Frame" )
	f:SetTitle( "Guard Roster" )
	f:SetLayout( "Flow" )
	f:SetWidth( 400 )
	f:Hide()
	f.frame:SetScript( "OnUpdate", OnRosterUpdate )
	Me.ui.frame = f
	
	e = AceGUI:Create( "SimpleGroup" )
	e:SetFullWidth( true )
	e:SetFullHeight( true )
	e:SetLayout( "Fill" )
	f:AddChild( e )
	local scrollcontainer = e

	e = AceGUI:Create( "ScrollFrame" )
	e:SetLayout( "Flow" ) 
	scrollcontainer:AddChild( e )
	
	Me.ui.scrollframe = e
	
	e = AceGUI:Create( "SCGStatusRosterEntry" )
	e:Update( "Happyguard" )
	Me.ui.scrollframe:AddChild( e )
end

-------------------------------------------------------------------------------
-- Show the roster window.
--
function Me.Show()
	GuildRoster()
	SetupUI()
	Me.ui.frame:Show()
	Me.Update()
end

-------------------------------------------------------------------------------
-- Update the roster listing.
--
function Me.Update()
	local players = Main.Status.GetAll()
	local sorted = {}
	
	-- copy table to sort it
	for k,v in pairs( players ) do
		table.insert( sorted, {
			name       = k;
			rank       = v.rank;
			rank_index = v.rank_index;
			status     = v.status;
		})
	end
	
	table.sort( sorted, function( a, b )
		if not b then return true end
		-- on duty higher than off duty
		local status1 = (a.status:sub(1,1) == "+")
		local status2 = (b.status:sub(1,1) == "+")
		if status1 ~= status2 then
			return status1
		end
		
		-- higher ranks higher than lower ranks
		if a.rank_index ~= b.rank_index then
			return a.rank_index < b.rank_index
		end
		
		-- alphabetically
		return a.name < b.name
	end)
	
	Me.ui.scrollframe:ReleaseChildren()
	
	for k,v in ipairs( sorted ) do
		local e = AceGUI:Create( "SCGStatusRosterEntry" )
		e:Update( v.name )
		Me.ui.scrollframe:AddChild( e )
	end
	
end
