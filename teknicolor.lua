
local revclass = DongleStub("DongleUtils").classnamesreverse
local tohex = DongleStub("DongleUtils").RGBPercToHex


local colors, x, names, names_mt = {}, {}, {}, {}
setmetatable(names, names_mt)


for class,eng in pairs(revclass) do
	local c = RAID_CLASS_COLORS[string.upper(eng)]
	local hex = tohex(c.r, c.g, c.b)
	colors[eng] = hex
	colors[class] = hex
	colors[string.upper(eng)] = hex
end


function names_mt.__newindex(t, k, v)
	if not v or not k or x[k] then return end
	local color = colors[v]
	if not color then return end
	x[k] = "|cff"..color.."["..k.."]|r"
end


function names_mt.__index(t, k)
	return x[k]
end



teknicolor = Dongle:New("teknicolor")


function teknicolor:Initialize()
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
	register(UnitName("player"), select(2, UnitClass("player")))

	self:RegisterEvent(VARIABLES_LOADED)
	self:RegisterEvent(FRIENDLIST_UPDATE)
	self:RegisterEvent(GUILD_ROSTER_UPDATE)
	self:RegisterEvent(RAID_ROSTER_UPDATE)
	self:RegisterEvent(PARTY_MEMBERS_CHANGED)
	self:RegisterEvent(PLAYER_TARGET_CHANGED)
	self:RegisterEvent(WHO_LIST_UPDATE)
	self:RegisterEvent(UPDATE_MOUSEOVER_UNIT)
	self:RegisterEvent(CHAT_MSG_SYSTEM)
end


function teknicolor:VARIABLES_LOADED()
	if IsInGuild() then GuildRoster() end
	if GetNumFriends() > 0 then ShowFriends() end
end


function teknicolor:FRIENDLIST_UPDATE()
	for i=1,GetNumFriends() do
		local name, _, class = GetFriendInfo(i)
		register(name, class)
	end
end


function teknicolor:GUILD_ROSTER_UPDATE()
	for i=1,GetNumGuildMembers(true) do
		local name, _, _, _,class = GetGuildRosterInfo(i)
		register(name, class)
	end
end


function teknicolor:RAID_ROSTER_UPDATE()
	for i=1,GetNumRaidMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		register(name, class)
	end
end


function teknicolor:PARTY_MEMBERS_CHANGED()
	for i=1,GetNumPartyMembers() do
		local unit = "party".. i
		local _, class = UnitClass(unit)
		register(UnitName(unit), class)
	end
end


function teknicolor:PLAYER_TARGET_CHANGED()
	if not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then return end
	local _, class = UnitClass("target")
	register(UnitName("target"), class)
end


function teknicolor:WHO_LIST_UPDATE()
	for i=1,GetNumWhoResults() do
		local name, _, _, _, class = GetWhoInfo(i)
		register(name, class)
	end
end


function teknicolor:UPDATE_MOUSEOVER_UNIT()
	if not UnitIsPlayer("mouseover") or not UnitIsFriend("player", "mouseover") then return end
	local _, class = UnitClass("mouseover")
	register(UnitName("mouseover"), class)
end


function teknicolor:CHAT_MSG_SYSTEM()
	local _, _, name, class = string.find(arg1, "^|Hplayer:%w+|h%[(%w+)%]|h: Level %d+ %w+ (%w+) %- .+$")
	if name and class then register(name, class) end
end

