

----------------------------
--      Localization      --
----------------------------

local locale = GetLocale()
local classnames = locale == "deDE" and {
	["Hexenmeister"] = "Warlock",
	["Hexenmeisterin"] = "Warlock",
	["Krieger"] = "Warrior",
	["Kriegerin"] = "Warrior",
	["J\195\164ger"] = "Hunter",
	["J\195\164gerin"] = "Hunter",
	["Magier"] = "Mage",
	["Magierin"] = "Mage",
	["Priester"] = "Priest",
	["Priesterin"] = "Priest",
	["Druide"] = "Druid",
	["Druidin"] = "Druid",
	["Paladin"] = "Paladin",
	["Schamane"] = "Shaman",
	["Schamanin"] = "Shaman",
	["Schurke"] = "Rogue",
	["Schurkin"] = "Rogue",
} or locale == "frFR" and {
	["D\195\169moniste"] = "Warlock",
	["Guerrier"] = "Warrior",
	["Guerri\195\168re"] = "Warrior",
	["Chasseur"] = "Hunter",
	["Chasseresse"] = "Hunter",
	["Mage"] = "Mage",
	["Pr\195\170tre"] = "Priest",
	["Pr\195\170tresse"] = "Priest",
	["Druide"] = "Druid",
	["Druidesse"] = "Druid",
	["Paladin"] = "Paladin",
	["Chaman"] = "Shaman",
	["Chamane"] = "Shaman",
	["Voleur"] = "Rogue",
	["Voleuse"] = "Rogue",
} or {
	["Warlock"] = "Warlock",
	["Warrior"] = "Warrior",
	["Hunter"] = "Hunter",
	["Mage"] = "Mage",
	["Priest"] = "Priest",
	["Druid"] = "Druid",
	["Paladin"] = "Paladin",
	["Shaman"] = "Shaman",
	["Rogue"] = "Rogue",
}


------------------------------
--      Are you local?      --
------------------------------

local colors = {}
for class,eng in pairs(classnames) do
	local c = RAID_CLASS_COLORS[string.upper(eng)]
	local hex = string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
	colors[eng] = hex
	colors[class] = hex
	colors[string.upper(eng)] = hex
end


local x, namesnobracket = {}, {}
local names = setmetatable({}, {
	__index = function(t, k) return x[k] end,
	__newindex = function(t, k, v)
		if not v or not k or x[k] or not colors[v] then return end
		x[k] = string.format("|cff%s[%s]|r", colors[v], k)
		namesnobracket[k] = "|cff".. colors[v].. k.. "|r"
	end,
})


teknicolor = {}
teknicolor.nametable = names


local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if teknicolor[event] then teknicolor[event](teknicolor, event, ...) end end)


function teknicolor:PLAYER_LOGIN()
	names[UnitName("player")] = select(2, UnitClass("player"))

--~ 	f:RegisterEvent("VARIABLES_LOADED")
	f:RegisterEvent("FRIENDLIST_UPDATE")
	f:RegisterEvent("GUILD_ROSTER_UPDATE")
	f:RegisterEvent("RAID_ROSTER_UPDATE")
	f:RegisterEvent("PARTY_MEMBERS_CHANGED")
	f:RegisterEvent("PLAYER_TARGET_CHANGED")
	f:RegisterEvent("WHO_LIST_UPDATE")
	f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	f:RegisterEvent("CHAT_MSG_SYSTEM")

	if IsInGuild() then GuildRoster() end
	if GetNumFriends() > 0 then ShowFriends() end
	self.PLAYER_LOGIN = nil
end


if IsLoggedIn() then teknicolor:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end


------------------------------------
--      Class caching events      --
------------------------------------

function teknicolor:FRIENDLIST_UPDATE()
	for i=1,GetNumFriends() do
		local name, _, class = GetFriendInfo(i)
		if name then names[name] = class end
	end
end


function teknicolor:GUILD_ROSTER_UPDATE()
	for i=1,GetNumGuildMembers(true) do
		local name, _, _, _, _, _, _, _, _, _, engclass = GetGuildRosterInfo(i)
		if name then names[name] = engclass end
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


----------------------------------
--      Chatframe coloring      --
----------------------------------

local origadds = {}


local function NewAddMessage(frame, text, ...)
	local name = arg2
	if event == "CHAT_MSG_SYSTEM" then
		local pname = text:match("^(%S+) has gone offline.$")
		if pname and namesnobracket[pname] then text = namesnobracket[pname].." has gone offline."
		else name = select(3, string.find(text, "|h%[(.+)%]|h")) end
	end
	if name and names[name] then text = string.gsub(text, "|h%["..name.."%]|h", "|h"..names[name].."|h") end
	return origadds[frame](frame, text, ...)
end


ChatFrame1.AddMessage, origadds[ChatFrame1] = NewAddMessage, ChatFrame1.AddMessage
for i=3,7 do _G["ChatFrame"..i].AddMessage, origadds[_G["ChatFrame"..i]] = NewAddMessage, _G["ChatFrame"..i].AddMessage end


------------------------------------
--      Friend List Coloring      --
------------------------------------

local origs, frameindexes = {}, {}


local function NewSetText(frame, name, ...)
	local i = frameindexes[frame]
	local _, _, class = GetFriendInfo(FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame) + i)
	if name and class and colors[class] then return origs[frame](frame, "|cff"..colors[class]..name.."|r", ...)
	else return origs[frame](frame, name, ...) end
end


for i=1,FRIENDS_TO_DISPLAY do
	local f = _G["FriendsFrameFriendButton"..i.."ButtonTextName"]
	frameindexes[f] = i
	origs[f] = f.SetText
	f.SetText = NewSetText
end

