local stoneybombs = RegisterMod("Stoneys Hate Bombs", 1);

local turretlist = {42, 235, 236, 201, 202, 203}
local spikelist = {44, 218}

local includeturrets = 1
local includespikes = 1
local includehagalaz = 1
local includestoneys = 1

local stoneyskillable = true
local spikeskillable = true
local turretskillable = true
local hagalazkillsstonethings = true
local hagalazonlykillsturrets = true

function stoneybombs:PostPlayerInit(player)
	local temp = Isaac.LoadModData(stoneybombs)
	local digit1check = string.sub(temp, 1, 1)
	local digit2check = string.sub(temp, 2, 2)
	local digit3check = string.sub(temp, 3, 3)
	local digit4check = string.sub(temp, 4, 4)
	turretskillable = false
	if digit1check ~= "" and digit1check ~= nil then
		includeturrets = tonumber(digit1check)
		if includeturrets == 1 then
			turretskillable = true
		end
	end
	spikeskillable = false
	if digit2check ~= "" and digit2check ~= nil then
		includespikes = tonumber(digit2check)
		if includespikes == 1 then
			spikeskillable = true
		end
	end
	hagalazkillsstonethings = false
	hagalazonlykillsturrets = false
	if digit3check ~= "" and digit3check ~= nil then
		includehagalaz = tonumber(digit3check)
		if includehagalaz > 0 then
			hagalazkillsstonethings = true
		end
		if includehagalaz == 1 then
			hagalazonlykillsturrets = true
		end
	end
    stoneyskillable = false
	if digit4check ~= "" and digit4check ~= nil then
		includestoneys = tonumber(digit4check)
		if includestoneys == 1 then
			stoneyskillable = true
		end
    end
end

function stoneybombs:takingDamage(target,amount,flag,source,num)
    --print("stoney - takingDamage: ", stoneyskillable)
	if flag == DamageFlag.DAMAGE_EXPLOSION then
		if includestoneys == 1 then
			if target.Type == 302 then
				target:Kill()
				target:Remove()
			end
		end
		if includeturrets == 1 then
			for i = 1, #turretlist, 1 do
				if target.Type == turretlist[i] then
					target:Kill()
					replacegrid(target.Position)
					target:Remove()
				end
			end
		end
		if includespikes == 1 then
			for i = 1, #spikelist, 1 do
				if target.Type == spikelist[i] then
					target:Kill()
					target:Remove()
				end
			end
		end
	end
end

--let player update list in console
function stoneybombs:onCmd(cmd, param)
	if cmd == "includeturrets" then
		includeturrets = 1
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Turrets now vulnerable to bombs")
	end
	if cmd == "ignoreturrets" then
		includeturrets = 0
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Turrets now invulnerable")
	end
	if cmd == "includespikes" then
		includespikes = 1
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Spikes now vulnerable to bombs")
	end
	if cmd == "ignorespikes" then
		includespikes = 0
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Spikes now invulnerable")
	end
	if cmd == "includestoneys" then
		includestoneys = 1
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Stoneys now vulnerable to bombs")
	end
	if cmd == "ignorestoneys" then
		includestoneys = 0
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Stoneys now invulnerable")
	end
	if cmd == "enablehagalazall" then
		includehagalaz = 2
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Hagalaz can now kill stoneys, turrets and spikes")
	end
	if cmd == "enablehagalazturretsonly" then
		includehagalaz = 1
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Hagalaz can now kill stone turrets")
	end
	if cmd == "disablehagalaz" then
		includehagalaz = 0
		Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		Isaac.ConsoleOutput("Hagalaz now ignores stone enemies")
	end
end

function stoneybombs:onCard(CardID)--check for hagalaz use
	if includehagalaz > 0 and CardID == 32 then
		local entities = Isaac.GetRoomEntities()
		for ent = 1, #entities do
			local entity = entities[ent]
			if includehagalaz == 2 then
				if includestoneys == 1 then
					if entity.Type == 302 then
						target:Kill()
						target:Remove()
					end
				end
				if includespikes == 1 then
					for i = 1, #spikelist, 1 do
						if entity.Type == spikelist[i] then
							entity:Kill()
							entity:Remove()
						end
					end
				end
				if includeturrets == 1 then
					for i = 1, #turretlist, 1 do
						if entity.Type == turretlist[i] then
							entity:Kill()
							replacegrid(entity.Position)
							entity:Remove()
						end
					end
				end
			else
				for i = 1, #turretlist, 1 do
					if entity.Type == turretlist[i] then
						entity:Kill()
						replacegrid(entity.Position)
						entity:Remove()
					end
				end
			end
		end
	end
end

function replacegrid(pos)
	local fireplace = Isaac.Spawn(33, 0, 0, pos, Vector(0,0), Isaac.GetPlayer(0));
	fireplace:Die()
end

--mod config menu stuff
if ModConfigMenu then
	ModConfigMenu.AddSpace("Stone enemy rules")
	ModConfigMenu.AddSetting("Stone enemy rules", { 
		Type = ModConfigMenuOptionType.BOOLEAN,
		CurrentSetting = function()
			return stoneyskillable
		end,
		Display = function()
			local onOff = "Off"
			if stoneyskillable then
				onOff = "On"
			end
			return "Stoneys: " .. onOff
		end,
		OnChange = function(currentBool)
			stoneyskillable = currentBool
			includestoneys = 0
			if stoneyskillable then
				includestoneys = 1
			end
			Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		end,
		Info = {
			"If enabled stoneys can be killed by explosions."
		}
	})
	ModConfigMenu.AddSpace("Stone enemy rules")
	ModConfigMenu.AddSetting("Stone enemy rules", { 
		Type = ModConfigMenuOptionType.BOOLEAN,
		CurrentSetting = function()
			return spikeskillable
		end,
		Display = function()
			local onOff = "Off"
			if spikeskillable then
				onOff = "On"
			end
			return "Mobile spikes: " .. onOff
		end,
		OnChange = function(currentBool)
			spikeskillable = currentBool
			includespikes = 0
			if spikeskillable then
				includespikes = 1
			end
			Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		end,
		Info = {
			"If enabled mobile spikes can be killed by explosions."
		}
	})
	ModConfigMenu.AddSpace("Stone enemy rules")
	ModConfigMenu.AddSetting("Stone enemy rules", { 
		Type = ModConfigMenuOptionType.BOOLEAN,
		CurrentSetting = function()
			return turretskillable
		end,
		Display = function()
			local onOff = "Off"
			if turretskillable then
				onOff = "On"
			end
			return "Turrets: " .. onOff
		end,
		OnChange = function(currentBool)
			turretskillable = currentBool
			includeturrets = 0
			if turretskillable then
				includeturrets = 1
			end
			Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		end,
		Info = {
			"If enabled turrets can be killed by explosions."
		}
	})
	ModConfigMenu.AddSpace("Stone enemy rules")
	ModConfigMenu.AddSetting("Stone enemy rules", { 
		Type = ModConfigMenuOptionType.BOOLEAN,
		CurrentSetting = function()
			return hagalazkillsstonethings
		end,
		Display = function()
			local onOff = "Off"
			if hagalazkillsstonethings then
				onOff = "On"
			end
			return "Hagalaz: " .. onOff
		end,
		OnChange = function(currentBool)
			hagalazkillsstonethings = currentBool
			includehagalaz = 0
			if hagalazkillsstonethings then
				includehagalaz = 2
				if hagalazonlykillsturrets then
					includehagalaz = 1
				end
			end
			Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		end,
		Info = {
			"If enabled using hagalaz runes can kill stone",
			"enemies that are vulnerable to explosions."
		}
	})
	ModConfigMenu.AddSpace("Stone enemy rules")
	ModConfigMenu.AddSetting("Stone enemy rules", { 
		Type = ModConfigMenuOptionType.BOOLEAN,
		CurrentSetting = function()
			return hagalazonlykillsturrets
		end,
		Display = function()
			local onOff = "Off"
			if hagalazonlykillsturrets then
				onOff = "On"
			end
			return "Hagalaz only kills turrets: " .. onOff
		end,
		OnChange = function(currentBool)
			hagalazonlykillsturrets = currentBool
			includehagalaz = 0
			if hagalazkillsstonethings then
				includehagalaz = 2
				if hagalazonlykillsturrets then
					includehagalaz = 1
				end
			end
			Isaac.SaveModData(stoneybombs, includeturrets .. includespikes .. includehagalaz .. includestoneys)
		end,
		Info = {
			"If hagalaz is enabled and this is enabled using hagalaz",
			"runes only kills turrets regardless of other settings."
		}
	})
end


--stoneybombs:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, stoneybombs.PostPlayerInit);
stoneybombs:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, stoneybombs.takingDamage);
stoneybombs:AddCallback(ModCallbacks.MC_USE_CARD, stoneybombs.onCard);
stoneybombs:AddCallback(ModCallbacks.MC_EXECUTE_CMD, stoneybombs.onCmd);

stoneybombs:ForceError() --this function doesn't exist, we do this to cause an error intentionally