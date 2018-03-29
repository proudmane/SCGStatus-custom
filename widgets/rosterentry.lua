-- SimplePokerPlayerStatus widget

local TYPE, VERSION = "SCGStatusRosterEntry", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= VERSION then return end

local Main = SCGStatus

local g_menu = nil
local g_context = nil

-------------------------------------------------------------------------------
local RANK_ICONS = {
	["Probation"]           = nil;
	["Cadet"]               = "Interface/Addons/SCGStatus/cadet";
	["Auxiliary"]           = nil;
	["Private"]             = "Interface/PvPRankBadges/PvPRank01";
	["Private First Class"] = "Interface/PvPRankBadges/PvPRank01";
	["Corporal"]            = "Interface/PvPRankBadges/PvPRank02";
	["Sergeant"]            = "Interface/PvPRankBadges/PvPRank03";
	["Master Sergeant"]     = "Interface/PvPRankBadges/PvPRank04";
	["Sergeant Major"]      = "Interface/PvPRankBadges/PvPRank05";
	["Officer"]             = "Interface/PvPRankBadges/PvPRank07";
	["Lieutenant"]          = "Interface/PvPRankBadges/PvPRank07";
	["Captain"]             = "Interface/PvPRankBadges/PvPRank08";
	["Commander"]           = "Interface/PvPRankBadges/PvPRank11";
}
   
-------------------------------------------------------------------------------
local function Control_OnClick( frame, button )

	if button == "RightButton" then
		if Main.Status.IsOfficer() or frame.obj.player == UnitName( "player" ) then
			Main.ShowSetStatusMenu( frame.obj.player )
		end
	end
end
 
-------------------------------------------------------------------------------
local methods = {
	OnAcquire = function(self)
		self:SetHeight( 24 ) 
		self:SetFullWidth( true )
	end;
	
	---------------------------------------------------------------------------
	-- Updates the display.
	--
	-- @param player Player to display or nil to use last player specified.
	--
	Update = function( self, player )
		
		player = player or self.player
		if not player then return end
		self.player = player
		
		-- todo: fetch TRP name!
		self.frame.text_name:SetText( player )
		
		local status, onduty, clean, rank, rank_index, rname = Main.Status.Get( player )
		if not status then return end
		
		if rname and rname ~= "" then
			self.frame.text_name:SetText( rname )
		end
		
		self.frame.text_status:SetText( status )
		
		local icon = RANK_ICONS[rank]
		
		if not icon then
			self.frame.icon:Hide()
		else
			self.frame.icon:SetTexture( icon )
			self.frame.icon:Show()
		end
		
		if onduty then
			self.frame.background:SetColorTexture( 38/255, 173/255, 228/255, 0.5 )
		else
			self.frame.background:SetColorTexture( 0.5, 0.5, 0.5, 0.5 )
		end
		
	end;
}

-------------------------------------------------------------------------------
local function Frame_OnEnter( self )
	self.highlight:Show()
end

-------------------------------------------------------------------------------
local function Frame_OnLeave( self )
	self.highlight:Hide()
end

-------------------------------------------------------------------------------
local function Constructor()
	local widget = {
		type  = TYPE;
		player = nil;
	}
	
	local name = TYPE .. AceGUI:GetNextWidgetNum( TYPE )
	local frame = CreateFrame( "Button", name, UIParent )
	widget.frame = frame
	frame:Hide()
	frame:EnableMouse( true )
	frame:RegisterForClicks( "RightButtonUp" )
	
	local text = frame:CreateFontString()
	text:SetFont( "Fonts\\ARIALN.TTF", 12 )
	text:SetPoint( "LEFT", 40, 0 )
	text:SetText( "Unknown" )
	frame.text_name = text;
	
	local text = frame:CreateFontString()
	text:SetFont( "Fonts\\ARIALN.TTF", 12 )
	text:SetPoint( "RIGHT", -10, 0 ) 
	frame.text_status = text
	
	local icon = frame:CreateTexture( nil, "ARTWORK" )
	icon:SetSize( 20, 20 )
	icon:SetPoint( "LEFT", 9, 0 ) 
	frame.icon = icon
	
	local bg = frame:CreateTexture( nil, "BACKGROUND" )
	bg:SetAllPoints()
	bg:SetColorTexture( 0,0,0,0.25 )
	frame.background = bg
	
	local hl = frame:CreateTexture( nil, "OVERLAY" )
	hl:SetAllPoints()
	hl:SetColorTexture( 0.1, 0.1, 0.1, 1.0 )
	hl:SetBlendMode( "ADD" )
	hl:Hide()
	frame.highlight = hl
	
	frame:SetScript( "OnEnter", Frame_OnEnter )
	frame:SetScript( "OnLeave", Frame_OnLeave )
	 
	frame:SetScript( "OnClick", Control_OnClick )
	
	-- todo: background magic
	 
	for method, func in pairs(methods) do
		widget[method] = func
	end
	
	return AceGUI:RegisterAsWidget( widget )
end

-------------------------------------------------------------------------------
AceGUI:RegisterWidgetType( TYPE, Constructor, VERSION )
