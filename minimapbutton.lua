
local Main = SCGStatus
local Me = {}
Main.MinimapButton = Me

local LDB    = LibStub:GetLibrary( "LibDataBroker-1.1" )
local DBIcon = LibStub:GetLibrary( "LibDBIcon-1.0"     )

-------------------------------------------------------------------------------
function Me.Init()
	
	Me.data = LDB:NewDataObject( "SCGStatus", {
		type = "data source";
		text = "SCGStatus";
		icon = "Interface\\Icons\\Inv_Misc_Tournaments_banner_Human";
		OnClick = function(...) Me.OnClick(...) end;
		OnEnter = function(...) Me.OnEnter(...) end;
		OnLeave = function(...) Me.OnLeave(...) end;
	})
	
end

-------------------------------------------------------------------------------
function Me.OnLoad() 
	DBIcon:Register( "SCGStatus", Me.data, Main.db.char.minimapicon )
end

-------------------------------------------------------------------------------
function Me.OnClick( frame, button )
	if button == "LeftButton" then
		Main.Roster.Show()
	elseif button == "RightButton" then
		-- open menu
		Main.ShowMenu() 
	end
end

-------------------------------------------------------------------------------
function Me.OnEnter( frame ) 
	-- Section the screen into 6 sextants and define the tooltip 
	-- anchor position based on which sextant the cursor is in.
	-- Code taken from WeakAuras.
	--
    local max_x = 768 * GetMonitorAspectRatio()
    local max_y = 768
    local x, y = GetCursorPosition()
	
    local horizontal = (x < (max_x/3) and "LEFT") or ((x >= (max_x/3) and x < ((max_x/3)*2)) and "") or "RIGHT"
    local tooltip_vertical = (y < (max_y/2) and "BOTTOM") or "TOP"
    local anchor_vertical = (y < (max_y/2) and "TOP") or "BOTTOM"
    GameTooltip:SetOwner( frame, "ANCHOR_NONE" )
    GameTooltip:SetPoint( tooltip_vertical..horizontal, frame, anchor_vertical..horizontal )
	
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine("Guard Status", Main.version, 0, 0.7, 1, 1, 1, 1)
	GameTooltip:AddLine( " " )
	GameTooltip:AddLine( "|cff00ff00Left-click|r to open guard roster.", 1, 1, 1 )
	GameTooltip:AddLine( "|cff00ff00Right-click|r to open menu.", 1, 1, 1 )
	GameTooltip:Show()
end

-------------------------------------------------------------------------------
function Me.OnLeave( frame ) 
	GameTooltip:Hide()
end
