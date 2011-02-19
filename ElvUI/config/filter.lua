local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--[[
	Spell Reminder Arguments
	
	Type of Check:
		spells - List of spells in a group, if you have anyone of these spells the icon will hide.
		weapon - Run a weapon enchant check instead of a spell check
	
	Spells only Requirements:
		negate_spells - List of spells in a group, if you have anyone of these spells the icon will immediately hide and stop running the spell check (these should be other peoples spells)
		reversecheck - only works if you provide a role or a tree, instead of hiding the frame when you have the buff, it shows the frame when you have the buff, doesn't work with weapons
		negate_reversecheck - if reversecheck is set you can set a talent tree to not follow the reverse check, doesn't work with weapons
	
	Requirements: (These work for both spell and weapon checks)
		role - you must be a certain role for it to display (Tank, Melee, Caster)
		tree - you must be active in a specific talent tree for it to display (1, 2, 3) note: tree order can be viewed from left to right when you open your talent pane
		level - the minimum level you must be (most of the time we don't need to use this because it will register the spell learned event if you don't know the spell, but in the case of weapon enchants this is useful)
		personal - aura must come from the player
		
	Additional Checks: (Note we always run a check when gaining/losing an aura)
		instance - check when entering a party/raid instance
		pvp - check when entering a bg/arena
		combat - check when entering combat
	
	For every group created a new frame is created, it's a lot easier this way.
]]

E.ReminderBuffs = {
	PRIEST = {
		[1] = { --inner fire/will group
			["spells"] = {
				588, -- inner fire
				73413, -- inner will			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true
		},
	},
	HUNTER = {
		[1] = { --aspects group
			["spells"] = {
				13165, -- hawk
				5118, -- cheetah
				20043, -- wild
				82661, -- fox	
			},
			["instance"] = true,
			["personal"] = true,
		},				
	},
	MAGE = {
		[1] = { --armors group
			["spells"] = {
				7302, -- frost armor
				6117, -- mage armor
				30482, -- molten armor		
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},		
	},
	WARLOCK = {
		[1] = { --armors group
			["spells"] = {
				28176, -- fel armor
				687, -- demon armor			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
	},
	PALADIN = {
		[1] = { --Seals group
			["spells"] = {
				20154, -- seal of righteousness
				20164, -- seal of justice
				20165, -- seal of insight
				31801, -- seal of truth				
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		[2] = { -- righteous fury group
			["spells"] = {
				25780, 
			},
			["role"] = "Tank",
			["instance"] = true,
			["reversecheck"] = true,
			["negate_reversecheck"] = 1, --Holy paladins use RF sometimes
		},
		[3] = { -- auras
			["spells"] = {
				465, --devo
				7294, --retr
				19746, -- conc
				19891, -- resist
			},
			["instance"] = true,
			["personal"] = true,
		},
	},
	SHAMAN = {
		[1] = { --shields group
			["spells"] = {
				52127, -- water shield
				324, -- lightning shield			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		[2] = { --check weapons for enchants
			["weapon"] = true,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
			["level"] = 10,
		},
	},
	WARRIOR = {
		[1] = { -- commanding Shout group
			["spells"] = {
				469, 
			},
			["negate_spells"] = {
				6307, -- Blood Pact
				90364, -- Qiraji Fortitude
				72590, -- Drums of fortitude
				21562, -- Fortitude				
			},
			["combat"] = true,
			["role"] = "Tank",
		},
		[2] = { -- battle Shout group
			["spells"] = {
				6673, 
			},
			["negate_spells"] = {
				8076, -- strength of earth
				57330, -- horn of Winter
				93435, -- roar of courage (hunter pet)						
			},
			["combat"] = true,
			["role"] = "Melee",
		},
	},
	DEATHKNIGHT = {
		[1] = { -- horn of Winter group
			["spells"] = {
				57330, 
			},
			["negate_spells"] = {
				8076, -- strength of earth totem
				6673, -- battle Shout
				93435, -- roar of courage (hunter pet)			
			},
			["combat"] = true,
		},
		[2] = { -- blood presence group
			["spells"] = {
				48263, 
			},
			["role"] = "Tank",
			["instance"] = true,	
			["reversecheck"] = true,
		},
	},
	ROGUE = { 
		[1] = { --weapons enchant group
			["weapon"] = true,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
			["level"] = 10,
		},
	},
}

--[[
	Nameplate Filter, Add the Nameplates name exactly here that you do NOT want to see
]]
E.PlateBlacklist = {
	--Shaman Totems
	["Earth Elemental Totem"] = true,
	["Fire Elemental Totem"] = true,
	["Fire Resistance Totem"] = true,
	["Flametongue Totem"] = true,
	["Frost Resistance Totem"] = true,
	["Healing Stream Totem"] = true,
	["Magma Totem"] = true,
	["Mana Spring Totem"] = true,
	["Nature Resistance Totem"] = true,
	["Searing Totem"] = true,
	["Stoneclaw Totem"] = true,
	["Stoneskin Totem"] = true,
	["Strength of Earth Totem"] = true,
	["Windfury Totem"] = true,
	["Totem of Wrath"] = true,
	["Wrath of Air Totem"] = true,

	--Army of the Dead
	["Army of the Dead Ghoul"] = true,

	--Hunter Trap
	["Venomous Snake"] = true,
	["Viper"] = true,

	--Test
	--["Unbound Seer"] = true,
}

--[[
		This portion of the file is for adding of deleting a spellID for a specific encounter on Grid layout
		or enemy cooldown in Arena displayed on screen.
		
		The best way to add or delete spell is to go at www.wowhead.com, search for a spell :
		Example : Incinerate Flesh from Lord Jaraxxus -> http://www.wowhead.com/?spell=67049
		Take the number ID at the end of the URL, and add it to the list
		
		That's it, That's all! 
		
		Elv
]]-- 

--------------------------------------------------------------------------------------------
-- Raid Buff Reminder (Bar in the topright corner below minimap)
--------------------------------------------------------------------------------------------

E.BuffReminderRaidBuffs = {
	Flask = {
		94160, --"Flask of Flowing Water"
		79469, --"Flask of Steelskin"
		79470, --"Flask of the Draconic Mind"
		79471, --"Flask of the Winds
		79472, --"Flask of Titanic Strength"
		79638, --"Flask of Enhancement-STR"
		79639, --"Flask of Enhancement-AGI"
		79640, --"Flask of Enhancement-INT"
		92679, --Flask of battle
	},
	BattleElixir = {
		--Scrolls
		89343, --Agility
		63308, --Armor 
		89347, --Int
		89342, --Spirit
		63306, --Stam
		89346, --Strength
		
		--Elixirs
		79481, --Hit
		79632, --Haste
		79477, --Crit
		79635, --Mastery
		79474, --Expertise
		79468, --Spirit
	},
	GuardianElixir = {
		79480, --Armor
		79631, --Resistance+90
	},
	Food = {
		87545, --90 STR
		87546, --90 AGI
		87547, --90 INT
		87548, --90 SPI
		87549, --90 MAST
		87550, --90 HIT
		87551, --90 CRIT
		87552, --90 HASTE
		87554, --90 DODGE
		87555, --90 PARRY
		87635, --90 EXP
		87556, --60 STR
		87557, --60 AGI
		87558, --60 INT
		87559, --60 SPI
		87560, --60 MAST
		87561, --60 HIT
		87562, --60 CRIT
		87563, --60 HASTE
		87564, --60 DODGE
		87634, --60 EXP
		87554, --Seafood Feast
	},
}

--------------------------------------------------------------------------------------------
-- Buff Watch (Raid Frame Buff Indicator)
--------------------------------------------------------------------------------------------

if C["auras"].raidunitbuffwatch == true then
	-- Classbuffs { spell ID, position [, {r,g,b,a}][, anyUnit] }
	
	--Healer Layout
	E.HealerBuffIDs = {
		PRIEST = {
			{6788, "TOPLEFT", {1, 0, 0}, true}, -- Weakened Soul
			{33076, "TOPRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
			{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
			{17, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
			{10060 , "RIGHT", {227/255, 23/255, 13/255}}, -- Power Infusion
			{33206, "LEFT", {227/255, 23/255, 13/255}, true}, -- Pain Suppression
			{47788, "LEFT", {221/255, 117/255, 0}, true}, -- Guardian Spirit
		},
		DRUID = {
			{774, "TOPRIGHT", {0.8, 0.4, 0.8}}, -- Rejuvenation
			{8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}}, -- Regrowth
			{94447, "TOPLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
			{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
		},
		PALADIN = {
			{53563, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Beacon of Light
			{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
			{1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
			{6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true}, -- Hand of Sacrafice
			{1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true} -- Hand of Salvation
		},
		SHAMAN = {
			{61295, "TOPLEFT", {0.7, 0.3, 0.7}}, -- Riptide 
			{16236, "BOTTOMLEFT", {145/255, 210/255, 100/255}}, -- Ancestral Fortitude
			{51945, "BOTTOMRIGHT", {0.2, 0.7, 0.2}}, -- Earthliving
			{974, "TOPRIGHT", {221/255, 117/255, 0}, true}, -- Earth Shield
		},
		ALL = {
			{23333, "LEFT", {1, 0, 0}}, -- Warsong Flag
		},
	}

	--DPS Layout
	E.DPSBuffIDs = {
		PALADIN = {
			{1022, "TOPRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
			{1044, "TOPRIGHT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
			{6940, "TOPRIGHT", {227/255, 23/255, 13/255}, true}, -- Hand of Sacrafice
			{1038, "TOPRIGHT", {238/255, 201/255, 0}, true}, -- Hand of Salvation
		},
		ROGUE = {
			{57933, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Tricks of the Trade
		},
		DEATHKNIGHT = {
			{49016, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Hysteria
		},
		MAGE = {
			{54646, "TOPRIGHT", {0.2, 0.2, 1}}, -- Focus Magic
		},
		WARRIOR = {
			{59665, "TOPLEFT", {0.2, 0.2, 1}}, -- Vigilance
			{3411, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Intervene
		},
		ALL = {
			{23333, "LEFT", {1, 0, 0}}, -- Warsong flag
		},
	}
	
	--Layout for pets
	E.PetBuffs = {
		HUNTER = {
			{136, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Mend Pet
		},
		DEATHKNIGHT = {
			{91342, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Shadow Infusion
			{63560, "TOPLEFT", {227/255, 23/255, 13/255}}, --Dark Transformation
		},
		WARLOCK = {
			{47193, "TOPRIGHT", {227/255, 23/255, 13/255}}, --Demonic Empowerment
		},
	}
end

--List of buffs to watch for on arena frames
E.ArenaBuffWhiteList = {
	-- Buffs
		[1022] = true, --hop
		[12051] = true, --evoc
		[2825] = true, --BL
		[32182] = true, --Heroism
		[33206] = true, --Pain Suppression
		[29166] = true, --Innervate
		[18708] = true, --"Fel Domination"
		[54428] = true, --divine plea
		[31821] = true, -- aura mastery

	-- Turtling abilities
		[871] = true, --Shield Wall
		[48707] = true, --"Anti-Magic Shell"
		[31224] = true, -- cloak of shadows
		[19263] = true, -- deterance
		[47585] = true, --  Dispersion

	-- Immunities
		[45438] = true, -- ice Brock
		[642] = true, -- pally bubble from hell
		
	-- Offensive Shit
		[31884] = true, -- Avenging Wrath
		[34471] = true, -- beast within
		[85696] = true, -- Zealotry
		[467] = true, -- Thorns
}

-------------------------------------------------------------
-- Debuff Filters
-------------------------------------------------------------

-- Debuffs to always hide
-- DPS Raid frames use this when not inside a BG/Arena. Player, TargetTarget, Focus always use it.
E.DebuffBlacklist = {
	[8733] = true, --Blessing of Blackfathom
	[57724] = true, --Sated
	[25771] = true, --forbearance
	[57723] = true, --Exhaustion
	[36032] = true, --arcane blast
	[58539] = true, --watchers corpse
	[26013] = true, --deserter
	[6788] = true, --weakended soul
	[71041] = true, --dungeon deserter
	[41425] = true, --"Hypothermia"
	[55711] = true, --Weakened Heart
	[8326] = true, --ghost
	[23445] = true, --evil twin
	[24755] = true, --gay homosexual tricked or treated debuff
	[25163] = true, --fucking annoying pet debuff oozeling disgusting aura
	[80354] = true, --timewarp debuff
}


-- Debuffs to Show
-- Only works on raid frames when inside a BG/Arena. Target frame will always show these, arena frames will always show these.
E.DebuffWhiteList = {
	-- Death Knight
		[51209] = true, --hungering cold
		[47476] = true, --strangulate
	-- Druid
		[33786] = true, --Cyclone
		[2637] = true, --Hibernate
		[339] = true, --Entangling Roots
		[80964] = true, --Skull Bash
		[78675] = true, --Solar Beam
	-- Hunter
		[3355] = true, --Freezing Trap Effect
		--[60210] = true, --Freezing Arrow Effect
		[1513] = true, --scare beast
		[19503] = true, --scatter shot
		[34490] = true, --silence shot
	-- Mage
		[31661] = true, --Dragon's Breath
		[61305] = true, --Polymorph
		[18469] = true, --Silenced - Improved Counterspell
		[122] = true, --Frost Nova
		[55080] = true, --Shattered Barrier
	-- Paladin
		[20066] = true, --Repentance
		[10326] = true, --Turn Evil
		[853] = true, --Hammer of Justice
	-- Priest
		[605] = true, --Mind Control
		[64044] = true, --Psychic Horror
		[8122] = true, --Psychic Scream
		[9484] = true, --Shackle Undead
		[15487] = true, --Silence
	-- Rogue
		[2094] = true, --Blind
		[1776] = true, --Gouge
		[6770] = true, --Sap
		[18425] = true, --Silenced - Improved Kick
	-- Shaman
		[51514] = true, --Hex
		[3600] = true, --Earthbind
		[8056] = true, --Frost Shock
		[63685] = true, --Freeze
		[39796] = true, --Stoneclaw Stun
	-- Warlock
		[710] = true, --Banish
		[6789] = true, --Death Coil
		[5782] = true, --Fear
		[5484] = true, --Howl of Terror
		[6358] = true, --Seduction
		[30283] = true, --Shadowfury
		[89605] = true, --Aura of Foreboding
	-- Warrior
		[20511] = true, --Intimidating Shout
	-- Racial
		[25046] = true, --Arcane Torrent
		[20549] = true, --War Stomp
	--PVE

			
}

--List of debuffs for targetframe for pvp only (when inside a bg/arena
--We do this because in PVE Situations we don't want to see these debuffs on our target frame, arena frames will always show these.
E.TargetPVPOnly = {
	[34438] = true, --UA
	[34914] = true, --VT
	[31935] = true, --avengers shield
	[63529] = true, --shield of the templar
	[19386] = true, --wyvern sting
	[116] = true, --frostbolt
	[58179] = true, --infected wounds
	[18223] = true, -- curse of exhaustion
	[18118] = true, --aftermath
	[31589] = true, --Slow
	--not sure if this one belongs here but i do know frost pve uses this
	[44572] = true, --deep freeze
}

--This list is used by the healerlayout (When not inside a bg/arena)
E.DebuffHealerWhiteList = {
	--Baradin Hold
		[95173] = true, -- Consuming Darkness

	--Blackwing Descent
		--Magmaw
		[91911] = true, -- Constricting Chains
		[94679] = true, -- Parasitic Infection
		[94617] = true, -- Mangle
		
		--Omintron Defense System
		[79835] = true, --Poison Soaked Shell	
		[91433] = true, --Lightning Conductor
		[91521] = true, --Incineration Security Measure
		
		--Maloriak
		[77699] = true, -- Flash Freeze
		[77760] = true, -- Biting Chill
		
		--Atramedes
		[92423] = true, -- Searing Flame
		[92485] = true, -- Roaring Flame
		[92407] = true, -- Sonic Breath
		
		--Chimaeron
		[82881] = true, -- Break
		[89084] = true, -- Low Health
		
		--Nefarian
		
	--The Bastion of Twilight
		--Valiona & Theralion
		[92878] = true, -- Blackout
		[86840] = true, -- Devouring Flames
		[95639] = true, -- Engulfing Magic
		
		--Halfus Wyrmbreaker
		[39171] = true, -- Malevolent Strikes
		
		--Twilight Ascendant Council
		[92511] = true, -- Hydro Lance
		[82762] = true, -- Waterlogged
		[92505] = true, -- Frozen
		[92518] = true, -- Flame Torrent
		[83099] = true, -- Lightning Rod
		[92075] = true, -- Gravity Core
		[92488] = true, -- Gravity Crush
		
		--Cho'gall
		[86028] = true, -- Cho's Blast
		[86029] = true, -- Gall's Blast
		[81836] = true, -- Corruption: Accelerated
		
	--Throne of the Four Winds
		--Conclave of Wind
			--Nezir <Lord of the North Wind>
			[93131] = true, --Ice Patch
			--Anshal <Lord of the West Wind>
			[86206] = true, --Soothing Breeze
			[93122] = true, --Toxic Spores
			--Rohash <Lord of the East Wind>
			[93058] = true, --Slicing Gale 
		--Al'Akir
		[93260] = true, -- Ice Storm
		[93295] = true, -- Lightning Rod
}

--This list is used by the dps layout grid (When not inside a bg/arena)
E.DebuffDPSWhiteList = {
	--Baradin Hold
		[88942] = true, -- Meteor Slash
		
	--Blackwing Descent
		--Magmaw
		[91911] = true, -- Constricting Chains
		[78199] = true, -- Sweltering Armor
		
		--Omintron Defense System
		[91431] = true, --Lightning Conductor
		[80094] = true, --Fixate 
		
		--Maloriak
		[77699] = true, -- Flash Freeze
		
		--Atramedes
		
		--Chimaeron
		[82881] = true, -- Break
		[89084] = true, -- Low Health
		
		--Nefarian
		
		--Sinestra
		[92956] = true, -- Wrack
		
	--The Bastion of Twilight
		--Valiona & Theralion
		[92878] = true, -- Blackout
		[86840] = true, -- Devouring Flames
		[95639] = true, -- Engulfing Magic
		
		--Halfus Wyrmbreaker
		[39171] = true, -- Malevolent Strikes
		
		--Twilight Ascendant Council
		[92511] = true, -- Hydro Lance
		[82762] = true, -- Waterlogged
		[92518] = true, -- Flame Torrent
		[83099] = true, -- Lightning Rod
		[92075] = true, -- Gravity Core
		[92488] = true, -- Gravity Crush
		
		--Cho'gall
		[86028] = true, -- Cho's Blast
		[86029] = true, -- Gall's Blast
		
	--Throne of the Four Winds
		--Conclave of Wind
			--Nezir <Lord of the North Wind>
			[93131] = true, --Ice Patch
			--Anshal <Lord of the West Wind>
			
			--Rohash <Lord of the East Wind>
			
		--Al'Akir
		[93260] = true, -- Ice Storm
		[93295] = true, -- Lightning Rod
}

--Spells to show how long the buff/debuff has been active on you instead of how long is left
E.ReverseTimerSpells = {
	[92956] = true, -- Wrack (Sinestra)
	--[79102] = true, -- Test(Blessing of Might)
}

--------------------------------------------------------------------------------------------
-- Enemy cooldown tracker or Spell Alert list
--------------------------------------------------------------------------------------------

-- the spellIDs to track on screen in arena.
if C["arena"].spelltracker == true then
	E.spelltracker = {
		[1766] = 10, -- kick
		[6552] = 10, -- pummel
		[80964] = 60, --SkullBash Bear
		[80965] = 60, --SkullBash Cat
		[85285] = 10, --Rebuke
		[2139] = 24, -- counterspell
		[19647] = 24, -- spell lock
		[10890] = 27, -- fear priest
		[47476] = 120, -- strangulate
		[47528] = 10, -- mindfreeze
		[29166] = 180, -- innervate
		[49039] = 120, -- Lichborne
		[54428] = 120, -- Divine Plea
		[10278] = 180, -- Hand of Protection
		[16190] = 180, -- Mana Tide Totem
		[51514] = 45, -- Hex
		[2094] = 120, -- Blind
		[72] = 12, -- fucking prot warrior shield bash
		[33206] = 144, -- pain sup
		[15487] = 45, -- silence priest
		[34490] = 20, -- i hate hunter silencing shot
		[14311] = 30, -- hunter forst trap shit
	}
end
