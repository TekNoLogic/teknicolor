
local revclass = DongleStub("DongleUtils").classnamesreverse
local tohex = DongleStub("DongleUtils").RGBPercToHex
local colors, x, names = {}, {}, {}
setmetatable(names, {
	__index = function(t, k) return x[k] end,
	__newindex = function(t, k, v)
		teknicolor:Debug(1,k,v)
		if not v or not k or x[k] or not colors[v] then return end
		x[k] = string.format("|cff%s[%s]|r", colors[v], k)
	end,
})


teknicolor = Dongle:New("teknicolor")

function teknicolor:Initialize()
	self:EnableDebug(1)

	for class,eng in pairs(revclass) do
		local c = RAID_CLASS_COLORS[string.upper(eng)]
		local hex = tohex(c.r, c.g, c.b)
		colors[eng] = hex
		colors[class] = hex
		colors[string.upper(eng)] = hex
	end
	revclass = nil

	local _G = getfenv(0)
	for i=1,7 do
		local f = _G["ChatFrame"..i]
		local add = f.AddMessage
		f.AddMessage = function(this, text, ...)
			local name = arg2
			if event == "CHAT_MSG_SYSTEM" then name = select(3, string.find(text, "|h%[(.+)%]|h")) end
			if name and names[name] then text = string.gsub(text, "|h%["..name.."%]|h", "|h"..names[name].."|h") end
			add(this, text, ...)
		end
	end
end


function teknicolor:Enable()
	names[UnitName("player")] = select(2, UnitClass("player"))

	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("WHO_LIST_UPDATE")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
end


function teknicolor:VARIABLES_LOADED()
	if IsInGuild() then GuildRoster() end
	if GetNumFriends() > 0 then ShowFriends() end
end


function teknicolor:FRIENDLIST_UPDATE()
	for i=1,GetNumFriends() do
		local name, _, class = GetFriendInfo(i)
		names[name] = class
	end
end


function teknicolor:GUILD_ROSTER_UPDATE()
	for i=1,GetNumGuildMembers(true) do
		local name, _, _, _,class = GetGuildRosterInfo(i)
		names[name] = class
	end
end


function teknicolor:RAID_ROSTER_UPDATE()
	for i=1,GetNumRaidMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		names[name] = class
	end
end


function teknicolor:PARTY_MEMBERS_CHANGED()
	for i=1,GetNumPartyMembers() do
		local unit = "party".. i
		local _, class = UnitClass(unit)
		names[UnitName(unit)] = class
	end
end


function teknicolor:PLAYER_TARGET_CHANGED()
	if not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then return end
	local _, class = UnitClass("target")
	names[UnitName("target")] = class
end


function teknicolor:WHO_LIST_UPDATE()
	for i=1,GetNumWhoResults() do
		local name, _, _, _, class = GetWhoInfo(i)
		names[name] = class
	end
end


function teknicolor:UPDATE_MOUSEOVER_UNIT()
	if not UnitIsPlayer("mouseover") or not UnitIsFriend("player", "mouseover") then return end
	local _, class = UnitClass("mouseover")
	names[UnitName("mouseover")] = class
end


function teknicolor:CHAT_MSG_SYSTEM()
	local _, _, name, class = string.find(arg1, "^|Hplayer:%w+|h%[(%w+)%]|h: Level %d+ %w+ (%w+) %- .+$")
	if name and class then names[name] = class end
end

