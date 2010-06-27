
------------------------------
--      Are you local?      --
------------------------------

local colors = {}
local nameclass = {}
local namesnobracket = setmetatable({}, {
	__index = function(t, k)
		local nc = k and nameclass[k]
		local c = nc and colors[nc]
		if not c then return end

		local v = "|cff".. c.. k.. "|r"
		t[k] = v
		return v
	end,
})
local x = setmetatable({}, {
	__index = function(t, k)
		local nc = k and nameclass[k]
		local c = nc and colors[nc]
		if not c then return end

		local v = string.format("[|cff%s%s|r]", c, k)
		t[k] = v
		return v
	end,
})
local names = setmetatable({}, {
	__index = function(t, k) return x[k] end,
	__newindex = function(t, k, v) if colors[v] then nameclass[k] = v end end,
})


local function SetColors()
	for i in pairs(x) do x[i] = nil end
	for i in pairs(namesnobracket) do namesnobracket[i] = nil end
	local cc = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	for token,loc_male in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		local loc_female = LOCALIZED_CLASS_NAMES_FEMALE[token]
		local c = cc[token]
		if c then
			local hex = string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
			colors[loc_male], colors[loc_female], colors[token] = hex, hex, hex
		end
	end
end
SetColors()
if CUSTOM_CLASS_COLORS then CUSTOM_CLASS_COLORS:RegisterCallback(SetColors) end
SetColors = nil



teknicolor = {}
teknicolor.nametable = names


local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if teknicolor[event] then teknicolor[event](teknicolor, event, ...) end end)


function teknicolor:PLAYER_LOGIN()
	f:RegisterEvent("FRIENDLIST_UPDATE")
	f:RegisterEvent("GUILD_ROSTER_UPDATE")

	if IsInGuild() then GuildRoster() end
	if GetNumFriends() > 0 then ShowFriends() end

	f:UnregisterEvent("PLAYER_LOGIN")
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


----------------------------------
--      Chatframe coloring      --
----------------------------------

local OFFLINE_MATCH = ERR_FRIEND_OFFLINE_S:gsub("%%s", "(%%S+)")
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg, ...)
	local pname = msg:match(OFFLINE_MATCH)
	if pname and namesnobracket[pname] then return false, string.format(ERR_FRIEND_OFFLINE_S, namesnobracket[pname]), ... end

	local name = msg:match("|h%[(.+)%]|h")
	if name and names[name] then return false, msg:gsub("|h%["..name.."%]|h", "|h"..names[name].."|h"), ... end
end)


------------------------------------
--      Friend List Coloring      --
------------------------------------

local origs, frameindexes, butts = {}, {}, {}


local inhook
local function NewSetText(frame, str, ...)
	if inhook then return end -- Failsafe to avoid the great infinity
	inhook = true

	local i, butt = frameindexes[frame], butts[frame]
	if butt.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local name, level, class, area, connected, status, note = GetFriendInfo(butt.id)
		if str and class and connected and colors[class] then
			origs[frame](frame, name..", "..format(FRIENDS_LEVEL_TEMPLATE, level, "|cff"..colors[class]..class.."|r"), ...)
		end
	elseif butt.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText = BNGetFriendInfo(butt.id)
		if toonID and toonName and client == BNET_CLIENT_WOW then
			local hasFocus, toonName, client, realmName, faction, race, class, guild, zoneName, level, gameText = BNGetToonInfo(toonID)
			if class and colors[class] then
				local coop = CanCooperateWithToon(toonID) and "" or "*"
				local coopcolor = coop == "" and FRIENDS_WOW_NAME_COLOR_CODE or FRIENDS_OTHER_NAME_COLOR_CODE
				if coop == "*" and ENABLE_COLORBLIND_MODE == "1" then toonName = toonName..CANNOT_COOPERATE_LABEL end
				origs[frame](frame, str:gsub("%("..toonName.."%)", "(|cff"..colors[class]..toonName..coopcolor..coop..")"), ...)
			end
		end
	end

	inhook = nil
end


for i=1,FRIENDS_TO_DISPLAY do
	local f = _G["FriendsFrameFriendsScrollFrameButton"..i.."Name"]
	butts[f] = _G["FriendsFrameFriendsScrollFrameButton"..i]
	frameindexes[f] = i
	origs[f] = f.SetText
	hooksecurefunc(f, "SetText", NewSetText)
end

