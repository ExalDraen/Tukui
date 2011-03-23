local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["others"].announceinterrupt ~= true then return end

local announce = CreateFrame("Frame")
announce:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
announce:SetScript("OnEvent", function(self, _, _, event, _, sourceName, _, _, destName, _, _, _, _, spellID, spellName)
	if not (event == "SPELL_INTERRUPT" and sourceName == E.myname) then return end
	
<<<<<<< HEAD
	if (C["others"].announcechannel == "PARTY" or C["others"].announcechannel== "RAID")
	then		
		if GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		elseif GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "RAID", nil, nil)
		end
	else
		SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", C["others"].announcechannel, nil, nil)
	end
		
end)