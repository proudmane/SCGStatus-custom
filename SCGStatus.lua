-------------------------------------------------------------------------------
-- A super special addon for the Stormwind City Guard.
-------------------------------------------------------------------------------

local VERSION = GetAddOnMetadata( "SCGStatus", "Version" )
local Main = LibStub("AceAddon-3.0"):NewAddon( "SCGStatus",
												"AceHook-3.0", "AceEvent-3.0" )
local AceConfig       = LibStub("AceConfig-3.0")

local DBIcon = LibStub:GetLibrary( "LibDBIcon-1.0" )

SCGStatus = Main
Main.version = VERSION
Main.guild_roster_update = 0

-------------------------------------------------------------------------------
DB_DEFAULTS = {
	char = {
		minimapicon = {
			hide = false
		};
		hide_off_duty = false;
	}
}

-------------------------------------------------------------------------------
-- Initialization.
--
function Main:OnInitialize()
	Main.MinimapButton.Init()
end

-------------------------------------------------------------------------------
-- Post-initialization
--
function Main:OnEnable()
	Main:CreateDB()
	Main.MinimapButton.OnLoad()

	Main.Status.Update()
	Main:RegisterEvent( "GUILD_ROSTER_UPDATE", "GuildRosterUpdate" )
	Main:GuildRosterUpdate()
end

function Main.InGuild()
	local guildName, _, guildRankIndex = GetGuildInfo( "player" )
	return guildName == "Stormwind City Guard"
end

-------------------------------------------------------------------------------
-- Event when guild status changes.
--
function Main:GuildRosterUpdate()
	Main.guild_roster_update = GetTime()
	if not Main.InGuild() then
		SCGS_Panel:Hide()
		DBIcon:Hide( "SCGStatus" )
		Main.db.char.minimapicon.hide = true
		return
	end

	Main.db.char.minimapicon.hide = false
	DBIcon:Show( "SCGStatus" )
	Main.Status.Update()

	if Main.Roster.ui and Main.Roster.ui.frame:IsShown() then
		Main.Roster.Update()
	end

	if not Main.Status.OnDuty() and Main.db.char.hide_off_duty then
		SCGS_Panel:Hide()
	else
		SCGS_Panel:Show()
		local status = Main.Status.Get()
		SCGS_Panel.text:SetText( status )

		if Main.Status.OnDuty() then
			SCGS_Panel.bg:SetColorTexture( 0.05, 0.2, 0.6, 0.6 )
		else
			SCGS_Panel.bg:SetColorTexture( 0.1, 0.1, 0.1, 0.7 )
		end
	end


end

-------------------------------------------------------------------------------
function Main:CreateDB()

	local acedb = LibStub( "AceDB-3.0" )
	Main.db = acedb:New( "SCGStatusSaved", DB_DEFAULTS, true )
	Main.db.global.version = VERSION

end

-------------------------------------------------------------------------------
-- Slash command.
--
SlashCmdList["SCGSTATUS"] = function( msg )
	-- todo add slash command registration

end
