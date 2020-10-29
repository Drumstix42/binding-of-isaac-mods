SymbolId = {
	--Para llamar a los items
	IGNIS = Isaac.GetItemIdByName("Ignis"),
	AQUA = Isaac.GetItemIdByName("Aqua"),
	AER = Isaac.GetItemIdByName("Aer"),
	TERRA = Isaac.GetItemIdByName("Terra"),
	ORDO = Isaac.GetItemIdByName("Salis"),
	VITAE = Isaac.GetItemIdByName("Vitae"),
	MORTEM = Isaac.GetItemIdByName("Mortem"),
	HERMETIC = Isaac.GetTrinketIdByName("Hermetic Marble"),
	
}

HasSymbol = {
	--Para saber si lo tiene
	Ignis = false,
	Aqua = false,
	Aer = false,
	Terra = false,
	Ordo = false,
	Vitae = false,
	Mortem = false,
	Hermetic = false,

}

SymbolStats = {

	IGNIS_DMG = 2,
	IGNIS_TH = 13,
	AQUA_TH = 10,
	AQUA_TD = 4,
	AQUA_SP = 0.5,
	TERRA = 0.3,
	playerHit = false,
	Mortem_DMG = 0,
	Mortem_TH = 0,
	Mortem_SS = 0,
	Mortem_MS = 0,
	kills = 0,
	HasIgnisEffect = false,
	HasAquaEffect = false,
	HasTerraEffect = false,
	HasAerEffect = false,
	HadTerraEffect = false,
	HasIgnisUpgrade = false,
	HasAquaUpgrade = false,
	HasTerraUpgrade = false,
	HasAerUpgrade = false,

}

SymbolCostumes = {

	IgnisCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis.anm2"),
	IgnisBlackCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_black.anm2"),
	IgnisBlueCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_blue.anm2"),
	IgnisGreenCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_green.anm2"),
	IgnisGreyCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_grey.anm2"),
	IgnisRedCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_red.anm2"),
	IgnisWhiteCostume = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_white.anm2"),
	IgnisCostumeForgotten = Isaac.GetCostumeIdByPath("gfx/characters/Ignis_Forgotten.anm2"),
	SalisCostume = Isaac.GetCostumeIdByPath("gfx/characters/Salis.anm2"),
	TerraCostume = Isaac.GetCostumeIdByPath("gfx/characters/Terra.anm2"),
	AerCostume = Isaac.GetCostumeIdByPath("gfx/characters/Aer.anm2"),

}

TearFlags = {
	FLAG_NO_EFFECT = 0,
	FLAG_SPECTRAL = 1,
	FLAG_PIERCING = 1<<1,
	FLAG_HOMING = 1<<2,
	FLAG_SLOWING = 1<<3,
	FLAG_POISONING = 1<<4,
	FLAG_FREEZING = 1<<5,
	FLAG_COAL = 1<<6,
	FLAG_PARASITE = 1<<7,
	FLAG_MAGIC_MIRROR = 1<<8,
	FLAG_POLYPHEMUS = 1<<9,
	FLAG_WIGGLE_WORM = 1<<10,
	FLAG_UNK1 = 1<<11, --No noticeable effect
	FLAG_IPECAC = 1<<12,
	FLAG_CHARMING = 1<<13,
	FLAG_CONFUSING = 1<<14,
	FLAG_ENEMIES_DROP_HEARTS = 1<<15,
	FLAG_TINY_PLANET = 1<<16,
	FLAG_ANTI_GRAVITY = 1<<17,
	FLAG_CRICKETS_BODY = 1<<18,
	FLAG_RUBBER_CEMENT = 1<<19,
	FLAG_FEAR = 1<<20,
	FLAG_PROPTOSIS = 1<<21,
	FLAG_FIRE = 1<<22,
	FLAG_STRANGE_ATTRACTOR = 1<<23,
	FLAG_UNK2 = 1<<24, --Possible worm?
	FLAG_PULSE_WORM = 1<<25,
	FLAG_RING_WORM = 1<<26,
	FLAG_FLAT_WORM = 1<<27,
	FLAG_UNK3 = 1<<28, --Possible worm?
	FLAG_UNK4 = 1<<29, --Possible worm?
	FLAG_UNK5 = 1<<30, --Possible worm?
	FLAG_HOOK_WORM = 1<<31,
	FLAG_GODHEAD = 1<<32,
	FLAG_UNK6 = 1<<33, --No noticeable effect
	FLAG_UNK7 = 1<<34, --No noticeable effect
	FLAG_EXPLOSIVO = 1<<35,
	FLAG_CONTINUUM = 1<<36,
	FLAG_HOLY_LIGHT = 1<<37,
	FLAG_KEEPER_HEAD = 1<<38,
	FLAG_ENEMIES_DROP_BLACK_HEARTS = 1<<39,
	FLAG_ENEMIES_DROP_BLACK_HEARTS2 = 1<<40,
	FLAG_GODS_FLESH = 1<<41,
	FLAG_UNK8 = 1<<42, --No noticeable effect
	FLAG_TOXIC_LIQUID = 1<<43,
	FLAG_OUROBOROS_WORM = 1<<44,
	FLAG_GLAUCOMA = 1<<45,
	FLAG_BOOGERS = 1<<46,
	FLAG_PARASITOID = 1<<47,
	FLAG_UNK9 = 1<<48, --No noticeable effect
	FLAG_SPLIT = 1<<49,
	FLAG_DEADSHOT = 1<<50,
	FLAG_MIDAS = 1<<51,
	FLAG_EUTHANASIA = 1<<52,
	FLAG_JACOBS_LADDER = 1<<53,
	FLAG_LITTLE_HORN = 1<<54,
	FLAG_GHOST_PEPPER = 1<<55
}

if 1 == 1 then --Eid

	if not __eidItemDescriptions then         
	__eidItemDescriptions = {};
	end	

	if not __eidTrinketDescriptions then         
	__eidTrinketDescriptions = {};
	end	

	__eidItemDescriptions[SymbolId.IGNIS] = "*2 damage multiplier#Range down";
	__eidItemDescriptions[SymbolId.AQUA] = "-4 fire delay#Shot speed down";
	__eidItemDescriptions[SymbolId.TERRA] = "+2 hearts#Full health#Speed down";
	__eidItemDescriptions[SymbolId.AER] = "Grants flying#Chance of losing pickups when hit";
	__eidItemDescriptions[SymbolId.ORDO] = "Balance your pickups#Negates downsides of Ignis, Aqua, Terra and Aer";
	__eidItemDescriptions[SymbolId.VITAE] = "Gives stats up depending on the amount of heart containers";
	__eidItemDescriptions[SymbolId.MORTEM] = "+1 black heart#Gives random rewards after killing 15 enemies";
	__eidTrinketDescriptions[SymbolId.HERMETIC] = "Gives a random effect between Ignis, Aqua, Terra or Aer#If you already have the item, gives an upgrade";

end