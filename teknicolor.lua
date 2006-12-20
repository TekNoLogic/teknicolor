Teknicolor = {}

local BC = AceLibrary("Babble-Class-2.2")

local names = {}
Teknicolor.nametable = names
local function register(name, class)
	if not class or not name or names[name] then return end
	local color = BC:GetHexColor(class)
	if color == "a0a0a0" then return end
	names[name] = "|cff"..color.."["..name.."]|r"
end
local _, class = UnitClass("player")
register(UnitName("player"), class)

local _G = getfenv(0)
for i=1,7 do
	local f = _G["ChatFrame"..i]
	local add = f.AddMessage
	f.AddMessage = function(this,text,r,g,b,id)
		local name = arg2
		if event == "CHAT_MSG_SYSTEM" then _, _, name = string.find(text, "|h%[(.+)%]|h") end
		if name and names[name] then text = string.gsub(text, "|h%["..name.."%]|h", "|h"..names[name].."|h") end
		add(this,text,r,g,b,id)
	end
end

local eventfuncs = {
	VARIABLES_LOADED = function() if IsInGuild() then GuildRoster() end if GetNumFriends() > 0 then ShowFriends() end end,
	FRIENDLIST_UPDATE = function() for i=1,GetNumFriends() do local name, _, class = GetFriendInfo(i) register(name, class) end end,
	GUILD_ROSTER_UPDATE = function() for i=1,GetNumGuildMembers(true) do local name, _, _, _,class = GetGuildRosterInfo(i) register(name, class) end end,
	RAID_ROSTER_UPDATE = function() for i=1,GetNumRaidMembers() do local name, _, _, _, _, class = GetRaidRosterInfo(i) register(name, class) end end,
	PARTY_MEMBERS_CHANGED = function() for i=1,GetNumPartyMembers() do local unit = "party" .. i local _, class = UnitClass(unit) register(UnitName(unit), class) end end,
	PLAYER_TARGET_CHANGED = function() if not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then return end local _, class = UnitClass("target") register(UnitName("target"), class) end,
	WHO_LIST_UPDATE = function() for i=1,GetNumWhoResults() do local name, _, _, _, class = GetWhoInfo(i) register(name, class) end end,
	UPDATE_MOUSEOVER_UNIT = function() if not UnitIsPlayer("mouseover") or not UnitIsFriend("player", "mouseover") then return end local _, class = UnitClass("mouseover") register(UnitName("mouseover"), class) end,
	CHAT_MSG_SYSTEM = function() local _,_,name, class = string.find(arg1, "^|Hplayer:%w+|h%[(%w+)%]|h: Level %d+ %w+ (%w+) %- .+$") if name and class then register(name, class) end end,
}
local frame = CreateFrame("frame")
frame.name = "Teknicolor"
frame:Show()
frame:SetScript("OnEvent", function() if eventfuncs[event] then eventfuncs[event]() end end)
for e in pairs(eventfuncs) do frame:RegisterEvent(e) end


