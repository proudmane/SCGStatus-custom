local Main = SCGStatus
local Me = {}
Main.Status = Me

-------------------------------------------------------------------------------
local STATUS_DEFS = {
	"+ On Duty";
	"+ Standby";
	"- Off Duty";
}

-------------------------------------------------------------------------------
local players = {}
local playerGuildMap = {}

local guildRanks = {
	{
		name = "Commander";
		patterns = {
			"^commander%s"
		};
	};
	{
		name = "Captain";
		patterns = {
			"^captain%s", "^cpt%.?%s"
		};
	};
	{
		name = "Lieutenant";
		patterns = {
			"^lieutenant%s", "^lt%.?%s"
		};
	};
	{
		name = "Knight";
		patterns = {
			"^knight%s"
		};
	};
	{
		name = "Sergeant Major";
		patterns = {
			"^sergeant major%s", "^sgt%.? major%s"
		};
	};
	{
		name = "Master Sergeant";
		patterns = {
			"^master sergeant%s", "^master sgt%s", "^msgt?%.?%s"
		};
	};
	{
		name = "Sergeant";
		patterns = {
			"^sergeant%s", "^sgt%.?%s"
		};
	};
	{
		name = "Corporal";
		patterns = {
			"^corporal%s", "^cpl%.?%s"
		};
	};
	{
		name = "Private First Class";
		patterns = {
			"^pfc%.?%s"
		};
	};
	{
		name = "Private";
		patterns = {
			"^private%s", "^pvt%.?%s"
		};
	};
	{
		name = "Cadet";
		patterns = {
			"^cadet%s"
		};
	};
	{
		name = "Auxiliary";
		patterns = {
			"^auxiliary%s", "^aux%.?%s"
		};
	};
	{
		name = "Applicant";
		patterns = {
			"^applicant%s"
		};
	};
}

local guildRankIndexes = {}
for k,v in pairs( guildRanks ) do
	guildRankIndexes[v.name] = k
end

-------------------------------------------------------------------------------
-- Fetch data from the guild roster.
--
function Me.Update()
	players = {}
	playerGuildMap = {}
	for i = 1, GetNumGuildMembers() do
		local fullName,rank,rankIndex,_,_,_,note,note2,online = GetGuildRosterInfo( i )
		note2 = note2 or ""
		
		local name = Ambiguate( fullName, "all" )
		if online and rank ~= "Applicant" then
		
			local foundRank = false
			local rank_space  = (rank .. " "):lower()
			local note2_space = (note2 .. " "):lower()
			
			for myRank = #guildRanks, 1, -1 do
				for _, pattern in ipairs(guildRanks[myRank].patterns) do
					if note2_space:match( pattern ) or rank_space:match( pattern ) then
						foundRank = true
						rank      = guildRanks[myRank].name
						break
					end
				end
			end
			
			if not foundRank then
				-- some hacks here~
				if note2_space:match( "duchess amanda" ) then
					rank = "Commander"
					foundRank = true
				end
			end
			
			if foundRank then
				players[name] = {
					rank       = rank;
					rank_index = guildRankIndexes[rank];
					status     = note;
					name       = note2;
				}
			else
				players[name] = {
					rank       = "Auxiliary";
					rank_index = guildRankIndexes["Auxiliary"];
					status     = note;
					name       = note2;
				}
			end
		end
		playerGuildMap[name] = i
	end
end

-------------------------------------------------------------------------------
-- Returns true if the player is an officer (should have admin capability).
--
function Me.IsOfficer()
	local guildName, _, guildRankIndex = GetGuildInfo( "player" )
	if guildName ~= "Stormwind City Guard" then return false end
	return guildRankIndex <= 1
	--return CanEditOfficerNote()
end

-------------------------------------------------------------------------------
-- Get current status from guild roster.
--
-- @param name Name of player or nil for self.
-- @returns Status text, on duty, clean status string (prefixed with +/- and space)
--          player rank, player rank index.
function Me.Get( name )
	name = name or UnitName( "player" )
	local data = players[name]
	if not data then return end
	
	local status, onduty = Me.Parse( data.status )
	local clean
	if onduty then
		clean = "+ " .. status
	else
		clean = "- " .. status
	end
	
	return status, onduty, clean, data.rank, data.rank_index, data.name
end

function Me.Parse( status )
	if status:sub(1,1) == "+" then
		return status:gsub( "^%+%s*", "" ), true
	elseif status:sub(1,1) == "-" then
		return status:gsub( "^%-%s*", "" ), false
	end
	return status, false
end

-------------------------------------------------------------------------------
-- Returns true if a status is not defined in the standard status selection.
--
function Me.IsCustom( status )
	for k,v in pairs( STATUS_DEFS ) do
		if v == status then
			return false
		end
	end
	
	return true
end

-------------------------------------------------------------------------------
-- Get current status from guild roster.
--
-- @param status Status to set.
-- @param name Name of player or nil for self.
--
function Me.Set( status, name )
	
	name = name or UnitName( "player" )
	name = Ambiguate( name, "all" )
	
	if not Main.InGuild() then 
		return
	end
	if name ~= UnitName("player") and not Me.IsOfficer() then return end
	
	if not playerGuildMap[name] then return end -- player is not in guild...
	
	GuildRosterSetPublicNote( playerGuildMap[name], status )
end

-------------------------------------------------------------------------------
-- Toggle On Duty / Off Duty for selected player.
--
-- @param name Name of player.
--
function Me.ToggleDuty( name )
	if Me.OnDuty( name ) then
		Me.Set( "- Off Duty", name )
	else
		Me.Set( "+ On Duty", name )
	end
end

-------------------------------------------------------------------------------
-- Returns true if a player is on duty.
--
-- @param name Name of player or nil for self.
--
function Me.OnDuty( name )
	name = name or UnitName( "player" )
	name = Ambiguate( name, "all" )
	if not players[name] then return end
	return players[name].status:sub( 1, 1 ) == "+"
end

-------------------------------------------------------------------------------
function Me.GetAll()
	return players
end

-------------------------------------------------------------------------------
-- Returns list of standard status settings.
--
function Me.List()
	return STATUS_DEFS
end
