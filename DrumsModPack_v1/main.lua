drumsModPack = RegisterMod("Drums Mod Pack", 1);
local game = Game()
local itemConfig = Isaac.GetItemConfig()
local music = MusicManager()

-- Always Boss Rush / Hush
local checkBossRushStart
local checkBossRushEnd
local checkHushStart
local checkHushEnd

-- Always Void
local voidTp = Isaac.GetItemIdByName("voidTp")
local spawnItemStage = 400
local lastBossRoomIndex
local currentBossRoomIndex

-- EID
 local EIDEnabled = true

-- EID Community
	local ItemNames = {}
	local ItemDescriptions = {}
	local TrinketNames = {}
	local TrinketDescriptions = {}
	local CardNames = {}
	local CardDescriptions = {}
	local PillNames = {}
	local PillDescriptions = {}
	local TransformItemNames = {}
	local TransformDescriptions = {}

-- External Item Descriptions
	local SacrificeCounter = 1
	local _, err = pcall(require, "config")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require passed in config"
		end
		Isaac.DebugString(err)
		print(err)
	end
	require("descriptions.ab+."..EIDConfig["Language"])

	if not __eidItemDescriptions then
	__eidItemDescriptions = {};
	end
	if not __eidTrinketDescriptions then
	__eidTrinketDescriptions = {};
	end
	if not __eidCardDescriptions then
	__eidCardDescriptions = {};
	end
	if not __eidPillDescriptions then
	__eidPillDescriptions = {};
	end
	if not __eidItemTransformations then
	__eidItemTransformations = {};
	end
	if not __eidEntityDescriptions then
	__eidEntityDescriptions = {};
	end
 
	function getModDescription(list, id)
		return (list) and (list[id])
	end
--

-- Makes textscale smaller, when using detailed english descriptions
	if EIDConfig["Language"]=="en_us_detailed" and EIDConfig["Scale"] > 0.5 then
		EIDConfig["Scale"] = 0.5
	end

	local IconSprite = Sprite()
	IconSprite:Load("gfx/icons.anm2", true)
	IconSprite.Scale = Vector(EIDConfig["Scale"],EIDConfig["Scale"])

	local ArrowSprite = Sprite()
	ArrowSprite:Load("gfx/icons.anm2", true)
	ArrowSprite:Play("Arrow",false)

	local CardSprite = Sprite()
	CardSprite:Load("gfx/cardfronts.anm2", true)
	CardSprite.Scale = Vector(EIDConfig["Scale"],EIDConfig["Scale"])
--

-- Alchemy
	local REAL_MIN_FIRE_DELAY = 5
	local MIN_FIRE_DELAY = 4
	require("alchemy")
--

-- Angels Drop Items
	local angelPool = { 33, 72, 98, 101, 108, 112, 124, 142, 146, 156, 162, 173, 178, 182, 184, 185, 243, 313, 326,331, 332, 333, 334,                    335, 363, 374, 387, 390, 400, 413, 415, 423, 464, 477, 490, 498, 499, 510 }
	local greedPool = { 7, 72, 73, 78, 112, 138, 162, 178, 184, 185, 173, 182, 197, 243, 313, 331, 333, 334,
						335, 363, 387, 390, 400, 407, 413, 415, 423, 464, 490, 499 }
	local angelActive = { 33, 124, 146, 326, 477, 490, 510 }
	local greedActive = { 78, 490 }
--

-- Bombable Devil Statue
	local DevilStatueDestroyed = false
    local DevilStatueBossDeath = false
--

-- Stoneys Hate Bombs
	local _, err = pcall(require, "stoneyshatebombs")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require stoneyshatebombs"
		end
		Isaac.DebugString(err)
		print(err)
	end
--

-- Crowhead
	local _, err = pcall(require, "crowhead")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require crowhead"
		end
		Isaac.DebugString(err)
		print(err)
	end
--

-- Cornucopia
	local _, err = pcall(require, "cornucopia")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require cornucopia"
		end
		Isaac.DebugString(err)
		print(err)
	end
--

-- God Transformation (Mind + Body + Soul = Godhead)
	local _, err = pcall(require, "godtransformation")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require godtransformation"
		end
		Isaac.DebugString(err)
		print(err)
	end
--

-- Revamped Special Rooms
	local _, err = pcall(require, "revampedspecialrooms")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require revampedspecialrooms"
		end
		Isaac.DebugString(err)
		print(err)
	end
--

-- Yum Heart + Maggy's Bow tweak
	local _, err = pcall(require, "yumhearttweak")
	err = tostring(err)
	if not string.match(err, "attempt to call a nil value %(method 'ForceError'%)") then
		if string.match(err, "true") then
			err = "Error: require yumhearttweak"
		end
		Isaac.DebugString(err)
		print(err)
	end
--

--[[
	===================================================================================================================
	GLOBAL VARS
	===================================================================================================================
]]--
-- Unique Item Appearances
	UniquePickupsEntityType = {
		ENTITY_STICKY_EFFECT = Isaac.GetEntityTypeByName("Sticky Nickel Effect")
	}

	UniquePickupsEffectVariant = {
		STICKY_NICKEL = Isaac.GetEntityVariantByName("Sticky Nickel Effect")
	}

	UniquePickupsStickySubType = {
		STICKY_NICKEL = 33206 --there's no GetEntitySubTypeByName function
	}
--


--[[
	===================================================================================================================
	CALLBACK FUNCTIONS
	===================================================================================================================
]]--
function drumsModPack:postPlayerInit(player)
	-- EID Community
	loadEIDtextFromFile()
	EIDCgetDescriptions()

	local seed = player.DropSeed

	-- Always Boss Rush
	checkBossRushStart = true
	checkBossRushEnd = true
	--Isaac.DebugString("#ALWAYSBOSSRUSH reset")

	-- Always Hush
	checkHushStart = true
	checkHushEnd = true
	--Isaac.DebugString("#ALWAYSHUSH reset")
	
	-- Always Void
	if Isaac.HasModData(drumsModPack) == true then

		local loadString = Isaac.LoadModData(drumsModPack)
		local loadData = string.split(loadString, "@")
		local loadedSpawnItemStage = tonumber(loadData[1])
		local loadedLastBossRoomIndex = tonumber(loadData[2])
		local loadedSeed = tonumber(loadData[3])
		
		if seed == loadedSeed then
			lastBossRoomIndex = loadedLastBossRoomIndex
			spawnItemStage = loadedSpawnItemStage
		else
			Isaac.RemoveModData(drumsModPack)
			spawnItemStage = 400
		end

	else
		
		spawnItemStage = 400
		
	end

	-- Alchemy
	HasSymbol.Ignis = player:HasCollectible(SymbolId.IGNIS)
	HasSymbol.Aqua = player:HasCollectible(SymbolId.AQUA)
	HasSymbol.Aer = player:HasCollectible(SymbolId.AER)
	HasSymbol.Terra = player:HasCollectible(SymbolId.TERRA)
	HasSymbol.Ordo = player:HasCollectible(SymbolId.ORDO)
	HasSymbol.Vitae = player:HasCollectible(SymbolId.VITAE)
	HasSymbol.Mortem = player:HasCollectible(SymbolId.MORTEM)
	HasSymbol.Hermetic = player:HasTrinket(SymbolId.HERMETIC)

end

function drumsModPack:updateCache(player,cacheFlag)
	--print("updateCache")
	--print(player)
	--print(player:HasCollectible(CollectibleType.COLLECTIBLE_HEART))
	-- Alchemy
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if player:HasCollectible(SymbolId.IGNIS) or SymbolStats.HasIgnisEffect then
			player.Damage = player.Damage * SymbolStats.IGNIS_DMG
		end
		if player:HasCollectible(SymbolId.VITAE) then
			player.Damage = player.Damage + (player:GetMaxHearts() * 0.5)
		end
		if player:HasCollectible(SymbolId.MORTEM) then
			player.Damage = player.Damage + (SymbolStats.Mortem_DMG * 0.5)
		end
	end
	
	if cacheFlag == CacheFlag.CACHE_FIREDELAY then
		if player:HasCollectible(SymbolId.AQUA) or SymbolStats.HasAquaEffect then
			if player.MaxFireDelay - SymbolStats.AQUA_TD >= MIN_FIRE_DELAY then
				player.MaxFireDelay = player.MaxFireDelay - SymbolStats.AQUA_TD
			elseif player.MaxFireDelay < MIN_FIRE_DELAY then
			
			else
				player.MaxFireDelay = MIN_FIRE_DELAY
			end
		end
		
		if player:HasCollectible(SymbolId.VITAE) then
			if player.MaxFireDelay - math.floor(player:GetMaxHearts() / 6) >= REAL_MIN_FIRE_DELAY then
				player.MaxFireDelay = player.MaxFireDelay - math.floor(player:GetMaxHearts() / 6)
			else
				player.MaxFireDelay = REAL_MIN_FIRE_DELAY
			end
		end
	end
	
	if cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(SymbolId.IGNIS) then
			player.TearHeight = player.TearHeight + SymbolStats.IGNIS_TH
		end
		if player:HasCollectible(SymbolId.AQUA) then
			player.TearHeight = player.TearHeight - SymbolStats.AQUA_TH
		end
		if player:HasCollectible(SymbolId.VITAE) then
			player.TearHeight = player.TearHeight - (player:GetMaxHearts() * 0.5)
		end
		if player:HasCollectible(SymbolId.MORTEM) then
			player.TearHeight = player.TearHeight - (SymbolStats.Mortem_TH * 0.5)
		end
		
		if player:HasCollectible(SymbolId.IGNIS) and player:HasCollectible(SymbolId.ORDO) then
			player.TearHeight = player.TearHeight - SymbolStats.IGNIS_TH
		end
		if player:HasCollectible(SymbolId.AQUA) and player:HasCollectible(SymbolId.ORDO) then
			player.TearHeight = player.TearHeight + SymbolStats.AQUA_TH
		end
	end
	
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(SymbolId.AQUA) then
			player.ShotSpeed = player.ShotSpeed - SymbolStats.AQUA_SP
		end
		if player:HasCollectible(SymbolId.VITAE) then
			player.ShotSpeed = player.ShotSpeed + (player:GetMaxHearts() * 0.02)
		end
		if player:HasCollectible(SymbolId.MORTEM) then
			player.ShotSpeed = player.ShotSpeed + (SymbolStats.Mortem_SS * 0.07)
		end
		if player:HasCollectible(SymbolId.AQUA) and player:HasCollectible(SymbolId.ORDO) then
			player.ShotSpeed = player.ShotSpeed + SymbolStats.AQUA_SP
		end
	end
	
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(SymbolId.TERRA) then
			player.MoveSpeed = player.MoveSpeed - SymbolStats.TERRA
		end
		if player:HasCollectible(SymbolId.VITAE) then
			player.MoveSpeed = player.MoveSpeed + (player:GetMaxHearts() * 0.05)
		end
		if player:HasCollectible(SymbolId.MORTEM) then
			player.MoveSpeed = player.MoveSpeed + (SymbolStats.Mortem_MS * 0.07)
		end
		if player:HasCollectible(SymbolId.TERRA) and player:HasCollectible(SymbolId.ORDO) then
			player.MoveSpeed = player.MoveSpeed + SymbolStats.TERRA
		end
	end
	
	if cacheFlag == CacheFlag.CACHE_FLYING then
		if player:HasCollectible(SymbolId.AER) or SymbolStats.HasAerEffect then
			player.CanFly = true
		end
	end

end

function drumsModPack:onEnterFloor()

	-- EID
	SacrificeCounter = 1

	-- Bomable Devil Statues
	DevilStatueDestroyed = false
	DevilStatueBossDeath = false

	if game:GetStateFlag(GameStateFlag.STATE_DONATION_SLOT_JAMMED) then
		game:SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_JAMMED, false)
	end
	
end

function drumsModPack:onEnterRoom()

	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel() 
	local room = level:GetCurrentRoom()
	
	-- Alchemy
	SymbolStats.HasIgnisEffect = false
	SymbolStats.HasAquaEffect = false
	SymbolStats.HasTerraEffect = false
	SymbolStats.HasAerEffect = false
	SymbolStats.HasIgnisUpgrade = false
	SymbolStats.HasAquaUpgrade = false
	SymbolStats.HasTerraUpgrade = false
	SymbolStats.HasAerUpgrade = false
	
	if HasSymbol.Hermetic then
		if SymbolStats.HadTerraEffect then
			player:AddMaxHearts(-4)
			SymbolStats.HadTerraEffect = false
		end
	
		rom = math.random(4)
		Isaac.DebugString(rom)
	
		if rom == 1 then
			if player:HasCollectible(SymbolId.IGNIS) then
				SymbolStats.HasIgnisUpgrade = true
			else
				SymbolStats.HasIgnisEffect = true
			end
		elseif rom == 2 then
			if player:HasCollectible(SymbolId.AQUA) then
				SymbolStats.HasAquaUpgrade = true
			else
				SymbolStats.HasAquaEffect = true
			end
		elseif rom == 3 then
			if player:HasCollectible(SymbolId.AER) then
				SymbolStats.HasAerUpgrade = true
			else
				SymbolStats.HasAerEffect = true
			end
		elseif rom == 4 then
			if player:HasCollectible(SymbolId.TERRA) then
				SymbolStats.HasTerraUpgrade = true
			else
				SymbolStats.HasTerraEffect = true
			end
		end
	end

	-- Bombable Devil Statues
	if room:GetType() == RoomType.ROOM_DEVIL and DevilStatueDestroyed == true  then
    	local entities = Isaac.GetRoomEntities()
    	local statua = room:GetCenterPos():__sub(Vector(0,32))
    	for i = 1, #entities do
    	    if entities[i].Type == 1000 and entities[i].Variant == 6    then
    	        entities[i]:Remove()
    	        Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__sub(Vector(0,32)), true);
    			Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__add(Vector(0,32)), true);
    			Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__sub(Vector(32,0)), true);
    			Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__add(Vector(32,0)), true);
	        end
	    end
    end
	
end

function drumsModPack:postUpdate()
	
	local level = game:GetLevel()
	local stage = level:GetAbsoluteStage()
	local curse = level:GetCurseName()
	local room = game:GetRoom()
	local roomIndex = level:GetCurrentRoomIndex ()
	local player = Isaac.GetPlayer(0)
	local isLastBoss = room:IsCurrentRoomLastBoss()
	local bossNum = room:GetAliveBossesCount()
	local seed = player.DropSeed

	local entities = Isaac.GetRoomEntities()

	-- Disable Giant Animation/Overlays
    -- check if the player changed stages with an eternal heart (there is no STAGE_CHANGE event)
    self:_eternal_heart_joined(player)
    -- check if the player used a book (this is a workaround because MC_USE_ITEM does not fire for non-mod items)
    self:_book_used(player)
  
	-- Always Void
	Isaac.SaveModData(drumsModPack, tostring(spawnItemStage) .. "@" ..tostring(lastBossRoomIndex) .. "@" .. tostring(seed))
	
	-- Always Boss Rush
	if checkBossRushStart == true and (stage == 6 or (stage == 5 and curse == "Curse of the Labyrinth")) then

		game.BossRushParTime = 2147483647
		--Isaac.DebugString("#ALWAYSBOSSRUSH set high")
		--Isaac.DebugString(game.BossRushParTime)
		checkBossRushStart = false
	
	elseif checkBossRushEnd == true and stage == 7  then
	
		game.BossRushParTime = 36000
		--Isaac.DebugString("#ALWAYSBOSSRUSH set back to normal")
		--Isaac.DebugString(game.BossRushParTime)
		checkBossRushEnd = false

	end

	-- Always Hush
	if checkHushStart == true and (stage == 8 or (stage == 7 and curse == "Curse of the Labyrinth")) then
	
		game.BlueWombParTime = 2147483647
		--Isaac.DebugString("#ALWAYSHUSH set high")
		--Isaac.DebugString(game.BlueWombParTime)
		checkHushStart = false
	
	elseif checkHushEnd == true and stage == 9  then
	
		game.BlueWombParTime = 54000
		--Isaac.DebugString("#ALWAYSHUSH set back to normal")
		--Isaac.DebugString(game.BlueWombParTime)
		checkHushEnd = false
	
	end

	-- Always Void
	if player:HasCollectible(voidTp) then
		level:SetStage(12, math.random(0,2))
		game:StartStageTransition(false, 1)
		player:AnimateAppear()
		player:RemoveCollectible(voidTp)	
	end
	if isLastBoss == true and spawnItemStage == stage then 
		currentBossRoomIndex = level:GetCurrentRoomIndex()    
		if currentBossRoomIndex ~= lastBossRoomIndex then
			spawnItemStage = 400
		end
	end
	if stage == 11 and (game.Difficulty == 0 or game.Difficulty == 1) and bossNum == 0 and spawnItemStage ~= stage and isLastBoss == true and room:IsClear() == true then
		if player:HasCollectible(voidTp) == false then
			local pos = Isaac.GetFreeNearPosition(Vector(320, 350), 0)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, voidTp, pos, Vector(0, 0), player)
			spawnItemStage = stage
			lastBossRoomIndex = level:GetCurrentRoomIndex()
		end
	end

	-- Curse Disabler
	if Isaac.GetFrameCount() % 10 == 0 then
		level:RemoveCurses();
	end

	-- Angels Drop Items
	-- TODO: Can we optimize this/put it somewhere else? (like enter room)
	if Isaac.GetFrameCount() % 10 == 0 then
		local greedMode = false
		local activeToPick
			
		if game:IsGreedMode() then
			activeToPick = greedActive
			greedMode = true
		else
			activeToPick = angelActive
		end
		
		if #activeToPick > 0 then
			for i, id in pairs(activeToPick) do
				if player:HasCollectible(id) then
					local tempPool
					table.remove(activeToPick, i)
					if greedMode then
						tempPool = greedPool
					else
						tempPool = angelPool
					end
					for i1, id1 in pairs(tempPool) do
						if id == id1 then
							if greedMode then
								table.remove(greedPool, i1)
							else
								table.remove(angelPool, i1)
							end
							break
						end
					end
					break
				end
			end
		end
		
		--[[
		if fallenAngels and (room:GetType() == RoomType.ROOM_ANGEL or room:GetType() == RoomType.ROOM_SACRIFICE or room:GetType() == RoomType.ROOM_SUPERSECRET) then
			for i, entity in pairs(Isaac:GetRoomEntities()) do
				if entity.Variant == 0 and 
					((entity.Type == EntityType.ENTITY_URIEL and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)) or 
					(entity.Type == EntityType.ENTITY_GABRIEL and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2))) then
					Isaac.Spawn(entity.Type, 1, 0, entity.Position, Vector(0,0), entity)
					entity:Remove()
				end
			end
		end
		]]--
	end

	-- Never BREAKFASTING
	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BREAKFAST) > 1 then
		local roomCenter = room:GetCenterPos()
		Isaac.ConsoleOutput(player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BREAKFAST))
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
		player.MaxHitPoints = player.MaxHitPoints - 1;
		--player:AddCollectible(math.random(1,550), 12, true);
		-- Spawn a new pedastal if player gets more than 1 Breakfast
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, math.random(1,550), room:FindFreePickupSpawnPosition(roomCenter,0,true), Vector(0, 0), nil)
		playSound(SoundEffect.SOUND_POWERUP1)
	end
  
	for i = 1, #entities do

		-- Never BREAKFASTING
		if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BREAKFAST) == 1 then
			if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_COLLECTIBLE and entities[i].SubType == CollectibleType.COLLECTIBLE_BREAKFAST then
				-- Reroll Breakfast pedastal into another item if already have Breakfast
				entities[i]:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, math.random(1,550), true)
				playSound(SoundEffect.SOUND_POWERUP1)
			end
		end

		-- If the entity is a movable TNT reduce its mass
		if entities[i].Type == EntityType.ENTITY_MOVABLE_TNT then
			entities[i].Mass = 0.8
		end

		-- No Empty Pedastals
		local e = entities[i]
		if e.Type == 5 and e.Variant == 100 and e.SubType == 0 then
			e:Remove()
			break
		end

	-- Bombable Devil Statues
		-- IF YOU KILL BOSS SPAWNED FROM STATUE
		if entities[i]:HasMortalDamage() and 
		  (entities[i].Type == EntityType.ENTITY_URIEL or entities[i].Type == EntityType.ENTITY_GABRIEL) and 
	      entities[i].Variant == 1 and DevilStatueBossDeath == false and DevilStatueDestroyed == true and room:GetType() == RoomType.ROOM_DEVIL   then
			
			local roomCenter = room:GetCenterPos()
			music:Play(Music.MUSIC_JINGLE_BOSS_OVER, 0.2)
			music:Queue(Music.MUSIC_BOSS_OVER) 
			
			-- 50% chance to spawn item after killing Angel
			if random(75) then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, room:FindFreePickupSpawnPosition(roomCenter,0,true), Vector(0,0), nil)
			else
				playSound(SoundEffect.SOUND_SCARED_WHIMPER)
			end
			DevilStatueBossDeath = true
		
		end

	    -- IF YOU BOMB THE STATUE
		if room:GetType() == RoomType.ROOM_DEVIL and entities[i].Type == 1000 and entities[i].Variant == 1 and entities[i].FrameCount == 1 then
			for j = 1, #entities do
				if entities[j].Type == 1000 and entities[j].Variant == 6 and 
				   entities[j].Position:Distance(entities[i].Position, entities[j].Position) < 80 and DevilStatueDestroyed == false  then
					
					DevilStatueDestroyed = true
					
					-- SPAWN AN ANGEL
                    local pos = entities[j].Position:__add(Vector(0,64))
                    if random(50) then
						Isaac.Spawn(EntityType.ENTITY_URIEL , 1, 0,pos,Vector(0,0),player)
			    	else
				    	Isaac.Spawn(EntityType.ENTITY_GABRIEL , 1, 0,pos,Vector(0,0),player)
			        end
			    
					room:SetClear(false)	
                    
					-- REMOVE BLOCKS AND SPAWN RANDOM BLOCKS
					local statua = room:GetCenterPos():__sub(Vector(0,32))
					local chance = math.random(0,100)
					
    				if chance >= 0 and chance <= 30     then
    					Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__sub(Vector(0,32)), true);
    					Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__add(Vector(0,32)), true);
    					Isaac.GridSpawn(GridEntityType.GRID_ROCKB , 0, statua:__sub(Vector(32,0)), true);
    					Isaac.GridSpawn(GridEntityType.GRID_ROCKB, 0, statua:__add(Vector(32,0)), true);
    				end
    				
    				if chance >= 31 and chance <= 50	then			
    				    Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__sub(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_GAPING_MAW, 0, 0,statua:__add(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__sub(Vector(32,0)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__add(Vector(32,0)),Vector(0,0),player)
                    end
                    
                    if chance >= 51 and chance <= 70	then			
    				    Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__sub(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_BROKEN_GAPING_MAW, 0, 0,statua:__add(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__sub(Vector(32,0)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__add(Vector(32,0)),Vector(0,0),player)
                    end
        
        			if chance >= 71 and chance <= 80	then			
    				    Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__sub(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__add(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__sub(Vector(32,0)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 0, 0,statua:__add(Vector(32,0)),Vector(0,0),player)
                    end            
    
        			if chance >= 81 and chance <= 100	then			
    				    Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 1, 0,statua:__sub(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 1, 0,statua:__add(Vector(0,32)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 1, 0,statua:__sub(Vector(32,0)),Vector(0,0),player)
    	                Isaac.Spawn(EntityType.ENTITY_STONEHEAD, 1, 0,statua:__add(Vector(32,0)),Vector(0,0),player)
                    end    
					
					entities[j]:Remove()
					
					-- REMOVE CURRENT ITEM PEDASTALS
					for y = 1, #entities do
						-- Only remove items with a price (heart sacrifice)
						if entities[y].Type == 5 and not (entities[y]:ToPickup().Price == PickupPrice.FREE or entities[y]:ToPickup().Price == 0) then
		                	entities[y]:Remove()
	                    end
	                end
	                
					-- CLOSE THE DOOR
				    local enter_door = room:GetDoor(level.EnterDoor) 
					if enter_door ~= nil and enter_door:IsOpen() then
						enter_door:Bar()
					end

                    -- CHANGE MUSIC
                    music:Play(Music.MUSIC_SATAN_BOSS ,0.2)

				end
			end
    	end
	end

end -- postUpdate()

function drumsModPack:onRender(t)	
	local player = Isaac.GetPlayer(0)
	local closest = nil
	local closestDice = nil
	local dist = 10000

	-- EID key toggle
	if Input.IsButtonTriggered(EIDConfig["HideKey"], 0) then
		EIDEnabled = not EIDEnabled;
	end
	if not EIDEnabled then return end

	-- EID functionality
	for i, entity in ipairs(Isaac.GetRoomEntities()) do
		local isModEntityDesc = false
		if EIDConfig["EnableEntityDescriptions"] and (__eidEntityDescriptions[entity.Type.."."..entity.Variant.."."..entity.SubType]~=nil or type(entity:GetData()["EID_Description"]) ~= type(nil)) then 
			isModEntityDesc= true
		end
		if  Game():GetRoom():GetType()==RoomType.ROOM_DICE and entity.Type==1000 and entity.Variant== 76 then closestDice= entity end

		if isModEntityDesc or (entity.Type == EntityType.ENTITY_PICKUP and (entity.Variant == PickupVariant.PICKUP_COLLECTIBLE or entity.Variant == PickupVariant.PICKUP_TRINKET or entity.Variant == PickupVariant.PICKUP_TAROTCARD or entity.Variant == PickupVariant.PICKUP_PILL) and entity.SubType>0) then
			local diff = entity.Position:__sub(player.Position);
			if diff:Length() < dist then
				closest = entity;
				dist = diff:Length();
			end  
		end
	end 
		
	if dist/40>tonumber(EIDConfig["MaxDistance"]) or not closest.Type == EntityType.ENTITY_PICKUP then
		if Game():GetRoom():GetType()==RoomType.ROOM_SACRIFICE and EIDConfig["DisplaySacrificeInfo"] then
			printTrinketDescription(sacrificeDescriptions[SacrificeCounter],"sacrifice")
		end
		if Game():GetRoom():GetType()==RoomType.ROOM_DICE and EIDConfig["DisplayDiceInfo"] and type(closestDice) ~= type(nil) then
			printTrinketDescription(diceDescriptions[closestDice.SubType+1],"dice")
		end
		return
	end
	
	
--Handle Indicators
	if EIDConfig["Indicator"] == "blink" then
		local c = 255-math.floor(255*((closest.FrameCount%40)/40))
		closest:SetColor(Color(1,1,1,1,c,c,c),1,1,false,false)
		closest:Render(Vector(0,0))
		closest:SetColor(Color(1,1,1,1,0,0,0),2,1,false,false)
		
	elseif EIDConfig["Indicator"] == "border" then
		local c = 255-math.floor(255*((closest.FrameCount%40)/40))
		closest:SetColor(Color(1,1,1,1,c,c,c),1,1,false,false)
		closest:Render(Vector(0,1))
		closest:Render(Vector(0,-1))
		closest:Render(Vector(1,0))
		closest:Render(Vector(-1,0))
		closest:SetColor(Color(1,1,1,1,0,0,0),2,1,false,false)
		closest:Render(Vector(0,0))
		
	elseif EIDConfig["Indicator"] == "highlight" then
		closest:SetColor(Color(1,1,1,1,255,255,255),1,1,false,false)
		closest:Render(Vector(0,1))
		closest:Render(Vector(0,-1))
		closest:Render(Vector(1,0))
		closest:Render(Vector(-1,0))
		closest:SetColor(Color(1,1,1,1,0,0,0),2,1,false,false)
		closest:Render(Vector(0,0))
		
	elseif EIDConfig["Indicator"] == "arrow" then
		ArrowSprite:Update()
		local ArrowOffset = Vector(0,-35)
		if closest.Variant ==100 and not closest:ToPickup():IsShopItem() then ArrowOffset = Vector(0,-62) end
		ArrowSprite:Render(Game():GetRoom():WorldToScreenPosition(closest.Position+ArrowOffset), Vector(0,0), Vector(0,0))
	end

--Handle Entities (specific)
	if EIDConfig["EnableEntityDescriptions"] and type(closest:GetData()["EID_Description"]) ~= type(nil) then
		printTrinketDescription({closest.Type,closest:GetData()["EID_Description"]},"custom")
		return
	end
	
--Handle Entities (omni)
	if EIDConfig["EnableEntityDescriptions"] and __eidEntityDescriptions[closest.Type.."."..closest.Variant.."."..closest.SubType] ~=nil then
		printTrinketDescription({closest.Type,getModDescription(__eidEntityDescriptions,closest.Type.."."..closest.Variant.."."..closest.SubType)},"custom")
		return
	end
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)then	EIDConfig["YPosition"] =EIDConfig["YPosition"] +30	end	
--Handle Trinkets
	if closest.Variant == PickupVariant.PICKUP_TRINKET then
		if closest.SubType <= 128 then
			printTrinketDescription(trinketdescriptions[closest.SubType],"trinket")
		elseif getModDescription(__eidTrinketDescriptions,closest.SubType) then
			printTrinketDescription({closest.SubType,getModDescription(__eidTrinketDescriptions,closest.SubType)},"trinket")
		else
			printTrinketDescription({closest.SubType,itemConfig:GetTrinket(closest.SubType).Description})
		end
--Handle Collectibles
	elseif closest.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		if HasCurseBlind() and EIDConfig["DisableOnCurse"] then
			renderQuestionMark() 
			return
		end
		if getModDescription(__eidItemDescriptions,closest.SubType) then
			local tranformation = "0"
			if  getModDescription(__eidItemTransformations,closest.SubType) then
				 tranformation = getModDescription(__eidItemTransformations,closest.SubType)
			end 
			printDescription({closest.SubType,tranformation,getModDescription(__eidItemDescriptions,closest.SubType)})
		elseif closest.SubType <= 552 then
			if getModDescription(__eidItemTransformations,closest.SubType) then
				printDescription({closest.SubType,getModDescription(__eidItemTransformations,closest.SubType),descriptarray[closest.SubType][3]})
			else		
				printDescription(descriptarray[closest.SubType])
			end
		else
			printDescription({closest.SubType,"",itemConfig:GetCollectible(closest.SubType).Description})
		end
--Handle Cards & Runes
    elseif closest.Variant == PickupVariant.PICKUP_TAROTCARD then
		if EIDConfig["DisplayCardInfo"] then
			if closest:ToPickup():IsShopItem() and not EIDConfig["DisplayCardInfoShop"] then renderQuestionMark() return end
			if getModDescription(__eidCardDescriptions,closest.SubType) then
				printTrinketDescription({closest.SubType,getModDescription(__eidCardDescriptions,closest.SubType)},"card")
			elseif closest.SubType <= 54 then 
				printTrinketDescription(cardDescriptions[closest.SubType],"card")
				CardSprite:Play(tostring(closest.SubType))
				CardSprite:Update()
				local offsetX = 0
				if EIDConfig["ShowItemName"] then offsetX = 10 end
				CardSprite:Render(Vector(EIDConfig["XPosition"]-9,EIDConfig["YPosition"]+(12+offsetX)*EIDConfig["Scale"]), Vector(0,0), Vector(0,0))
			else
				printTrinketDescription({closest.SubType,itemConfig:GetCard(closest.SubType).Description})
			end
		end
--Handle Pills
    elseif closest.Variant == PickupVariant.PICKUP_PILL then
		if EIDConfig["DisplayPillInfo"] then
			if closest:ToPickup():IsShopItem() and not EIDConfig["DisplayPillInfoShop"] then renderQuestionMark() return end
			
			local pillColor = closest.SubType
			local pool = Game():GetItemPool()
			local pillEffect = pool:GetPillEffect(pillColor)
			local identified = pool:IsPillIdentified(pillColor)
			if (identified or EIDConfig["ShowUnidentifiedPillDescriptions"]) then
				if getModDescription(__eidPillDescriptions,pillEffect) then
					printTrinketDescription({pillEffect,getModDescription(__eidPillDescriptions,pillEffect)},"pill")
				elseif pillEffect < 47 then 
					printTrinketDescription(pillDescriptions[pillEffect+1],"pill")
				else  
					Isaac.RenderScaledText(EIDConfig["ErrorMessage"], EIDConfig["XPosition"], EIDConfig["YPosition"],EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ErrorColor"][1] , EIDConfig["ErrorColor"][2], EIDConfig["ErrorColor"][3], EIDConfig["Transparency"])
				end
			else
				Isaac.RenderScaledText(unidentifiedPillMessage, EIDConfig["XPosition"], EIDConfig["YPosition"],EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ErrorColor"][1] , EIDConfig["ErrorColor"][2], EIDConfig["ErrorColor"][3], EIDConfig["Transparency"])
			end
			local pillsprite = closest:GetSprite()
			pillsprite.Scale = Vector(EIDConfig["Scale"]*0.75,EIDConfig["Scale"]*0.75)
			if EIDConfig["Indicator"] == "blink" then
				closest:SetColor(Color(1,1,1,1,0,0,0),0,0,false,false)
			end
			pillsprite:Update()
			local offsetX = 0
			if EIDConfig["ShowItemName"] and (identified or EIDConfig["ShowUnidentifiedPillDescriptions"]) then offsetX = 10 end
			pillsprite:Render(Vector(EIDConfig["XPosition"]+2*EIDConfig["Scale"],EIDConfig["YPosition"]+(11+offsetX)*EIDConfig["Scale"]), Vector(0,0), Vector(0,0))
			pillsprite.Scale = Vector(1,1)
			if EIDConfig["Indicator"] == "blink" then
				local c = 255-math.floor(255*((closest.FrameCount%40)/40))
				closest:SetColor(Color(1,1,1,1,c,c,c),0,0,false,false)
			end
		end
    end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)then	EIDConfig["YPosition"] =EIDConfig["YPosition"] -30	end
end

function drumsModPack:playerTakeDamage(TookDamage)
	local player = TookDamage:ToPlayer()

	-- Alchemy
	if player:HasCollectible(SymbolId.AER) and not player:HasCollectible(SymbolId.ORDO) then
		if math.random(100) <= 35 then
			local pickup = math.random(3)
			if pickup == 1 then
				player:AddCoins(-7)
				if player:GetNumCoins() > 4 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,4,player.Position,player.Velocity,player)
				end
			elseif pickup == 2 then
				player:AddKeys(-2)
				if player:GetNumKeys() > 1 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,1,player.Position,player.Velocity,player)
				end	
			else			
				player:AddBombs(-5)
				if player:GetNumBombs() > 2 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,2,player.Position,player.Velocity,player)
				end
			end
		end
	end
end

function onDamage(_,entity,_,_,source)
	if Game():GetRoom():GetType()==RoomType.ROOM_SACRIFICE and source.Type==0 then
		if SacrificeCounter<12 then
			SacrificeCounter= SacrificeCounter+1
		end
	end
end

function drumsModPack:entityTakeDamage(Damagedd,Dmg,DmgFlag,playerDmg)
	-- Alchemy
	local player = Isaac.GetPlayer(0)
	local Damaged = Damagedd:ToNPC()
	if playerDmg.EntityType == ENTITY_TEAR and SymbolStats.HasIgnisUpgrade then
		Damaged:AddBurn(EntityRef(player),100000,player.Damage * 0.8)
	end

end

function drumsModPack:entityUpdateAngels(entity)
  local player = Isaac.GetPlayer(0)
  local game = Game()
  local room = game:GetRoom()
  
  if entity.HitPoints <= 0 and 
  	 (room:GetType() == RoomType.ROOM_ANGEL or room:GetType() == RoomType.ROOM_SACRIFICE or room:GetType() == RoomType.ROOM_SUPERSECRET) and
     (player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)) and
     (entity.Type == EntityType.ENTITY_URIEL or entity.Type == EntityType.ENTITY_GABRIEL) then
    
    local rng = player:GetDropRNG()
    local spawnPos = Isaac.GetFreeNearPosition(entity.Position, 50)
    local tempPool
    local item
    local noTrinket = player:HasTrinket(TrinketType.TRINKET_NO)
      
    if game:IsGreedMode() then
      tempPool = greedPool
    else
      tempPool = angelPool
    end
    
    while true do
      local spawnActive = true
      local skipOnce = false
      local itemPos
      
      if #tempPool > 0 then
        itemPos = rng:RandomInt(#tempPool) + 1
        item = tempPool[itemPos]
      else
        if noTrinket then
          noTrinket = false
          skipOnce = true
          
          if game:IsGreedMode() then
            tempPool = greedActive
          else
            tempPool = angelActive
          end
        else
          item = 25
          break
        end
      end
      
      if noTrinket then
        local activePool
        
        if game:IsGreedMode() then
          activePool = greedActive
        else
          activePool = angelActive
        end
        
        if #activePool > 0 then
          for i, id in pairs(activePool) do
            if id == item then
              spawnActive = false
              break
            end
          end
        end
      end
      
      if not spawnActive or player:HasCollectible(item) then
        table.remove(tempPool, itemPos)
      elseif not skipOnce then
        break
      end
	end
	
	-- 50% chance to spawn Item after Key Pieces are obtained
	if random(50) then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, spawnPos, Vector(0,0), entity)
	else
		playSound(SoundEffect.SOUND_SCARED_WHIMPER)
	end
  end
end

function drumsModPack:entityKill(entity)
	
	-- Alchemy
	for playerNum = 0, Game():GetNumPlayers() - 1 do
		local player = Game():GetPlayer(playerNum)
		
		if player:HasCollectible(SymbolId.MORTEM) then
			SymbolStats.kills = SymbolStats.kills + 1
			if SymbolStats.kills == 15 then
				SymbolStats.kills = 0
				ran = math.random(7)
				if ran == 1 then
					SymbolStats.Mortem_DMG = SymbolStats.Mortem_DMG + 1
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				elseif ran == 2 then
					SymbolStats.Mortem_TH = SymbolStats.Mortem_TH + 1
					player:AddCacheFlags(CacheFlag.CACHE_RANGE)
				elseif ran == 3 then
					SymbolStats.Mortem_SS = SymbolStats.Mortem_SS + 1
					player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
				elseif ran == 4 then
					SymbolStats.Mortem_MS = SymbolStats.Mortem_MS + 1
					player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				elseif ran == 5 then
					player:AddCoins(5)
				elseif ran == 6 then
					player:AddBombs(3)
				elseif ran == 7 then
					player:AddKeys(2)
				end
			player:EvaluateItems()	
			end
		end
	end

end

-- Only triggers when Hush is dead
function drumsModPack:HushBlessing(NPC)
	-- White Poof particle effect
	local PoofParticle = Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		EffectVariant.POOF01,
		3,
		NPC.Position,
		Vector(0, 0),
		nil
	)
	PoofParticle:SetColor(Color(1, 1, 1, 1, 255, 255, 255), 120, 1, false, true)
	
	-- Crack the Sky effect for swag points (Wow! Pretty!)
	local PoofParticle2 = Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		EffectVariant.CRACK_THE_SKY,
		0,
		NPC.Position,
		Vector(0, 0),
		nil
	)
	PoofParticle2:SetColor(Color(1, 1, 1, 0.7, 0, 0, 0), 120, 1, false, true)
	
	-- Spawn Eden's Blessing
	Isaac.Spawn(
		EntityType.ENTITY_PICKUP,
		PickupVariant.PICKUP_COLLECTIBLE,
		CollectibleType.COLLECTIBLE_EDENS_BLESSING,
		NPC.Position,
		Vector(0, 0),
		nil
	)
end

function drumsModPack:onCoinInit(coin)
	if coin.SubType == CoinSubType.COIN_STICKYNICKEL then
		--spawn the effect
		local stickyEffect = Isaac.Spawn(UniquePickupsEntityType.ENTITY_STICKY_EFFECT, UniquePickupsEffectVariant.STICKY_NICKEL, UniquePickupsStickySubType.STICKY_NICKEL, coin.Position, coin.Velocity, coin)
		
		--get what animation to use
		local stickySprite = stickyEffect:GetSprite()
		local animation = "Idle"
		if Game():GetRoom():GetFrameCount() > 0 then
			animation = "Appear"
		end
		stickySprite:Play(animation, true)
		
		--set up the data
		local coinData = uniquePickupsModGetData(coin)
		coinData.WasStickyNickel = true
		local stickyData = uniquePickupsModGetData(stickyEffect)
		stickyData.StickyNickel = coin
	end
end

function drumsModPack:onCoinUpdate(coin)
	local coinData = uniquePickupsModGetData(coin)
	if coinData.WasStickyNickel then --check for our WasStickyNickel data
		if coin.SubType ~= CoinSubType.COIN_STICKYNICKEL then --it's no longer a sticky nickel
			coinData.WasStickyNickel = false
			local coinSprite = coin:GetSprite()
			coinSprite:Load("gfx/005.022_nickel.anm2", true) --revert nickel sprite to original
			coinSprite:Play("Idle", true)
		end
	end
end

function drumsModPack:onStickyEffectUpdate(stickyEffect)
	if stickyEffect.SubType == UniquePickupsStickySubType.STICKY_NICKEL then
		local removeEffect = true
		
		local stickyData = uniquePickupsModGetData(stickyEffect)
		if stickyData.StickyNickel then --check if StickyNickel isnt nil
			local coin = stickyData.StickyNickel
			if coin:Exists() then --check if the nickel exists
				if coin.SubType == CoinSubType.COIN_STICKYNICKEL then --check if the nickel is sticky
					stickyEffect.Position = coin.Position --force our position to the nickel's position
					removeEffect = false --make sure we dont remove this effect
				end
			end
		end
		
		if removeEffect then --remove the effect
			local stickySprite = stickyEffect:GetSprite()
			if stickySprite:IsPlaying("Disappear") then
				if stickySprite:GetFrame() >= 44 then
					stickyEffect:Remove()
				end
			else
				stickySprite:Play("Disappear", true)
			end
		end
	end
end

function drumsModPack:onPlayerEffectUpdate(player)

	-- Alchemy
	if player:HasCollectible(SymbolId.IGNIS) and not HasSymbol.Ignis then
		if player:GetName() == "The Forgotten" then
			player:AddNullCostume(SymbolCostumes.IgnisCostumeForgotten)
		elseif player:HasCollectible(80) or player:HasCollectible(118) or player:HasCollectible(230) or player:HasCollectible (399) or player:HasCollectible (159) or player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
			player:AddNullCostume(SymbolCostumes.IgnisBlackCostume)
		elseif player:HasCollectible(189) then
			player:AddNullCostume(SymbolCostumes.IgnisRedCostume)
		elseif player:HasCollectible(140) or player:HasCollectible(103) then
			player:AddNullCostume(SymbolCostumes.IgnisGreenCostume)
		elseif player:GetName() == "The Lost" then
			player:AddNullCostume(SymbolCostumes.IgnisWhiteCostume)
		elseif player:GetName() == "Keeper" then
			player:AddNullCostume(SymbolCostumes.IgnisGreyCostume)
		elseif player:GetName() == "???" then
			player:AddNullCostume(SymbolCostumes.IgnisBlueCostume)
		else
			player:AddNullCostume(SymbolCostumes.IgnisCostume)
		end
	end
	
	if player:HasCollectible(SymbolId.ORDO) and not HasSymbol.Ordo then
		player:AddNullCostume(SymbolCostumes.SalisCostume)
		average = (player:GetNumCoins() + player:GetNumBombs() + player:GetNumKeys()) / 3
		average = math.floor(average) + 1
		player:AddCoins(average - player:GetNumCoins())
		player:AddBombs(average - player:GetNumBombs())
		player:AddKeys(average - player:GetNumKeys())
	
	end
	
	if player:HasCollectible(SymbolId.VITAE) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	end
	
	if player:HasCollectible(SymbolId.TERRA) and not HasSymbol.Terra then
		player:AddNullCostume(SymbolCostumes.TerraCostume)
	end
	
	if player:HasCollectible(SymbolId.AER) and not HasSymbol.Aer then
		Isaac.DebugString("hola")
		Isaac.DebugString(SymbolCostumes.AerCostume)
		player:AddNullCostume(SymbolCostumes.AerCostume)
	end
	
	HasSymbol.Ignis = player:HasCollectible(SymbolId.IGNIS)
	HasSymbol.Aqua = player:HasCollectible(SymbolId.AQUA)
	HasSymbol.Aer = player:HasCollectible(SymbolId.AER)
	HasSymbol.Terra = player:HasCollectible(SymbolId.TERRA)
	HasSymbol.Ordo = player:HasCollectible(SymbolId.ORDO)
	HasSymbol.Vitae = player:HasCollectible(SymbolId.VITAE)
	HasSymbol.Mortem = player:HasCollectible(SymbolId.MORTEM)
	HasSymbol.Hermetic = player:HasTrinket(SymbolId.HERMETIC)
	
	
	if SymbolStats.HasIgnisUpgrade then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_TEAR then
				local TearData = entity:GetData()
				local Tear = entity:ToTear()
				if TearData.TunnelType == nil then
					TearData.TunnelType = 1
					if TearData.TunnelType == 1 then
						Tear:ChangeVariant(TearVariant.FIRE_MIND)
					end
				end
			end
		end
	end

	if SymbolStats.HasAerUpgrade then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_TEAR then
				local TearData = entity:GetData()
				local Tear = entity:ToTear()
				if TearData.TunnelType == nil then
					TearData.TunnelType = 1
					if TearData.TunnelType == 1 then
						entity:SetColor(Color(1.0,1.0,1.0,0.7,0.0,0.0,0.0),0,0,false,false)
						Tear.TearFlags = TearFlags.FLAG_SPECTRAL
					end			
				end
			end
		end
	end
	
	if SymbolStats.HasTerraUpgrade then
		player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
	end
	
	if SymbolStats.HasAquaUpgrade then
		local frame = game:GetFrameCount()
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_TEAR then
				local TearData = entity:GetData()
				local Tear = entity:ToTear()
				if frame % 4 == 0 then
					local AquaCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, Tear.Position, Vector(0,0), player):ToEffect()
					AquaCreep:SetTimeout(20)
					AquaCreep.CollisiplayerTakeDamage = player.Damage * 1.5
					AquaCreep.LifeSpan = 20
					AquaCreep:SetDamageSource(EntityType.ENTITY_PLAYER)
					AquaCreep:Update()
				end	
			end
		end
	end

	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
		
	if SymbolStats.HasTerraEffect then
		player:AddMaxHearts(4)
		player:AddHearts(4)
		SymbolStats.HadTerraEffect = true
		SymbolStats.HasTerraEffect = false
	end
		
	player:EvaluateItems()
	
end

function drumsModPack:openCrawlspaceWall()

	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_DUNGEON then
		local size =  room:GetGridSize()
		local width =  room:GetGridWidth()
		--removes 4 tiles in the wall so that you can enter the black market
		room:RemoveGridEntity (size-width-1, 0, false)
		room:RemoveGridEntity (size-width-2, 0, false)
		room:RemoveGridEntity (size-2*width-1, 0, false)
		room:RemoveGridEntity (size-2*width-2, 0, false)
	end

end

function drumsModPack:onCmd(cmd, param)
	if cmd == "EIDRefreshList" then
		Isaac.ConsoleOutput("Refreshing List...")
		loadEIDtextFromFile()
		EIDCgetDescriptions()
	end
end


--[[
	===================================================================================================================
	External Item Descriptions
	===================================================================================================================
]]--
function printDescription(desc)
	local Description = desc[3]
	local temp = EIDConfig["YPosition"]
	local itemTypes= {"null","passive","active","familiar","trinket"}
	local itemType = itemConfig:GetCollectible(desc[1]).Type
	
	--Display ItemType / Charge
	if EIDConfig["ShowItemType"] and (itemType ==3 or itemType== 4) then	
		local offsetX = 0
		if not EIDConfig["ShowItemName"]then	offsetX = 5*EIDConfig["Scale"]
			temp = temp+10*EIDConfig["Scale"] 
		end
		IconSprite:Play(itemTypes[itemType])
		IconSprite.Scale = Vector(EIDConfig["Scale"],EIDConfig["Scale"])
		IconSprite:Update()
		IconSprite:Render(Vector(EIDConfig["XPosition"]-3*EIDConfig["Scale"]+offsetX,temp+1*EIDConfig["Scale"]), Vector(0,0), Vector(0,0))
		if itemType ==3 then
			IconSprite:Play(itemConfig:GetCollectible(desc[1]).MaxCharges)
			IconSprite.Scale = Vector(EIDConfig["Scale"],EIDConfig["Scale"])
			IconSprite:Update()
			IconSprite:Render(Vector(EIDConfig["XPosition"]-3*EIDConfig["Scale"]+offsetX,temp+1*EIDConfig["Scale"]), Vector(0,0), Vector(0,0))
		end
		if not EIDConfig["ShowItemName"] then
			temp = temp+10*EIDConfig["Scale"]
		end
	end
	--Display Itemname
	if EIDConfig["ShowItemName"] then
		local offset = 1
		if EIDConfig["ShowItemType"]then	if itemType==3 then  offset = 9 else  offset = 6 end end
		Isaac.RenderScaledText(itemConfig:GetCollectible(desc[1]).Name, EIDConfig["XPosition"]+offset*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"],EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		temp = temp+10*EIDConfig["Scale"]
	end
	
	
	--Display Transformation
	if not(desc[2]=="0" or desc[2]=="" or desc[2]==nil ) then
		if EIDConfig["TransformationText"] then
			if EIDConfig["TransformationIcons"] and not(printTransformation(desc[2])=="Custom") then
				Isaac.RenderScaledText(printTransformation(desc[2]), EIDConfig["XPosition"]+16*EIDConfig["Scale"], temp-1,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TransformationColor"][1] , EIDConfig["TransformationColor"][2], EIDConfig["TransformationColor"][3], EIDConfig["Transparency"])
			elseif not(transformations[desc[2]]) then --Custom transformationname
				Isaac.RenderScaledText(desc[2], EIDConfig["XPosition"]+16*EIDConfig["Scale"], temp-1,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TransformationColor"][1] , EIDConfig["TransformationColor"][2], EIDConfig["TransformationColor"][3], EIDConfig["Transparency"])
			else
				Isaac.RenderScaledText(printTransformation(desc[2]), EIDConfig["XPosition"]+16*EIDConfig["Scale"], temp-1,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TransformationColor"][1] , EIDConfig["TransformationColor"][2], EIDConfig["TransformationColor"][3], EIDConfig["Transparency"])
			end
		end
		if EIDConfig["TransformationIcons"] and not(printTransformation(desc[2])=="Custom") then
			IconSprite:Play(printTransformation(desc[2]))
			IconSprite.Scale = Vector(EIDConfig["Scale"],EIDConfig["Scale"])
			IconSprite:Update()
			IconSprite:Render(Vector(EIDConfig["XPosition"]+5*EIDConfig["Scale"],temp+5*EIDConfig["Scale"]), Vector(0,0), Vector(0,0))
		end
		temp = temp+10*EIDConfig["Scale"]
	end
	for line in string.gmatch(Description, '([^#]+)') do
		local array={}
		local text = ""
		for word in string.gmatch(line, '([^ ]+)') do
			if string.len(text)+string.len(word)<= tonumber(EIDConfig["TextboxWidth"]) then
				text = text.." "..word
			else
				table.insert(array, text)
				text = word
			end
		end
		table.insert(array, text)
		for i, v in ipairs(array) do
			if i== 1 then 
					if string.sub(v, 2, 2)=="\001" or string.sub(v, 2, 2)=="\002"  or string.sub(v, 2, 2)=="\003" then 
						Isaac.RenderScaledText(string.sub(v, 2, 2)..string.sub(v,3,string.len(v)), EIDConfig["XPosition"], temp,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TextColor"][1] , EIDConfig["TextColor"][2], EIDConfig["TextColor"][3], EIDConfig["Transparency"])
					else
						Isaac.RenderScaledText("\007"..v, EIDConfig["XPosition"], temp,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TextColor"][1] , EIDConfig["TextColor"][2], EIDConfig["TextColor"][3], EIDConfig["Transparency"])
					end
			else
					Isaac.RenderScaledText("  "..v, EIDConfig["XPosition"], temp,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TextColor"][1] , EIDConfig["TextColor"][2], EIDConfig["TextColor"][3], EIDConfig["Transparency"])
			end
			temp = temp +10*EIDConfig["Scale"]
		end
	end
end

function printTrinketDescription(desc,typ)
	Description = desc[2]
	textboxWidth=tonumber(EIDConfig["TextboxWidth"])
	local temp = EIDConfig["YPosition"]
	--Display Itemname
	if EIDConfig["ShowItemName"] then
		if typ=="trinket" then
		Isaac.RenderScaledText(itemConfig:GetTrinket(desc[1]).Name, EIDConfig["XPosition"]+1*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		elseif typ=="card" then
		Isaac.RenderScaledText(itemConfig:GetCard(desc[1]).Name, EIDConfig["XPosition"]+1*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		elseif typ=="pill" then
		Isaac.RenderScaledText(itemConfig:GetPillEffect(desc[1]).Name, EIDConfig["XPosition"]+1*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		elseif typ=="sacrifice" then
		Isaac.RenderScaledText(sacrificeDescriptionHeader, EIDConfig["XPosition"]+1*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		elseif typ=="dice" then
		Isaac.RenderScaledText(diceDescriptionHeader, EIDConfig["XPosition"]+1*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		elseif typ=="custom" then
		Isaac.RenderScaledText(desc[2][1], EIDConfig["XPosition"]+1*EIDConfig["Scale"], temp-4,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["ItemNameColor"][1] , EIDConfig["ItemNameColor"][2], EIDConfig["ItemNameColor"][3], EIDConfig["Transparency"])
		Description= desc[2][2]
		end
		temp = temp+10*EIDConfig["Scale"]
	end
	for line in string.gmatch(Description, '([^#]+)') do
		local array={}
		local text = ""
		for word in string.gmatch(line, '([^ ]+)') do
			if string.len(text)+string.len(word)<=textboxWidth then
				text = text.." "..word
			else
				table.insert(array, text)
				text = word
			end
		end
		table.insert(array, text)
		for i, v in ipairs(array) do
			if i== 1 then 
					if string.sub(v, 2, 2)=="\001" or string.sub(v, 2, 2)=="\002" or string.sub(v, 2, 2)=="\003" then 
						Isaac.RenderScaledText(string.sub(v, 2, 2)..string.sub(v,3,string.len(v)), EIDConfig["XPosition"], temp,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TextColor"][1] , EIDConfig["TextColor"][2], EIDConfig["TextColor"][3], EIDConfig["Transparency"])
					else
						Isaac.RenderScaledText("\007"..v, EIDConfig["XPosition"], temp,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TextColor"][1] , EIDConfig["TextColor"][2], EIDConfig["TextColor"][3], EIDConfig["Transparency"])
					end
			else
					Isaac.RenderScaledText("  "..v, EIDConfig["XPosition"], temp,EIDConfig["Scale"],EIDConfig["Scale"], EIDConfig["TextColor"][1] , EIDConfig["TextColor"][2], EIDConfig["TextColor"][3],  EIDConfig["Transparency"])
			end
			temp = temp +10*EIDConfig["Scale"]
		end
	end
end

function printTransformation(S)
	local str="Custom";
	for i = 0, #transformations-1 do
		if (tonumber(S)==i) then
			str = tostring(transformations[i+1])
		end
	end
	return str
end

function renderQuestionMark() 
	IconSprite:Play("CurseOfBlind")
	IconSprite.Scale = Vector(EIDConfig["Scale"],EIDConfig["Scale"])
	IconSprite:Update()
	IconSprite:Render(Vector(EIDConfig["XPosition"]+5*EIDConfig["Scale"],EIDConfig["YPosition"]+5*EIDConfig["Scale"]), Vector(0,0), Vector(0,0))
	if Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)then	EIDConfig["YPosition"] =EIDConfig["YPosition"] -30	end
end

--[[
	===================================================================================================================
	UTILITY FUNCTIONS
	===================================================================================================================
]]--
function HasCurseBlind()
	local num = Game():GetLevel():GetCurses()
    local t={}
    while num>0 do
        rest=num%2
        t[#t+1]=rest
        num=(num-rest)/2
    end
    
	return #t>6 and t[7]==1 
end

function drumsModPack:_eternal_heart_joined(player)
    local previous_eternal_hearts = drumsModPack.num_eternal_hearts or 0
    local previous_stage = drumsModPack.current_stage or 0
    drumsModPack.num_eternal_hearts = player:GetEternalHearts()
    drumsModPack.current_stage = game:GetLevel():GetStage()

    if (
        previous_stage ~= drumsModPack.current_stage
        and previous_eternal_hearts == 1
        and drumsModPack.num_eternal_hearts == 0
    ) then
        playSound(SoundEffect.SOUND_SUPERHOLY)
    end
end

function drumsModPack:_book_used(player)
    if player:GetActiveItem() == CollectibleType.COLLECTIBLE_SATANIC_BIBLE then
        local previous_active_charge = self.active_charge or 0
        local previous_battery_charge = self.battery_charge or 0
        self.active_charge = player:GetActiveCharge()
        self.battery_charge = player:GetBatteryCharge()
        -- XXX: is there anything in the game that removes charges?
        local used_main_charge = (
            previous_active_charge > self.active_charge
            and self.active_charge == 0
        )
        local used_battery_charge = (
            previous_battery_charge > self.battery_charge
            and self.battery_charge == 0
        )
        if used_battery_charge or used_main_charge then
            -- player used satanic bible
            -- (add an animation because it has no animation by default)
            player:AnimateCollectible(
                player:GetActiveItem(),
                "UseItem",
                "PlayerPickup"
            )
        end
    end
end

function playSound(sound_effect)
	SFXManager():Play(sound_effect, 1.0, 0, false, 1.0);
end

function uniquePickupsModGetData(entity)
	local data = entity:GetData()
	if data.UniquePickups == nil then
		data.UniquePickups = {}
	end
	return data.UniquePickups
end

function string:split(sSeparator, nMax, bRegexp)
  
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
    
		local bPlain = not bRegexp
    	local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
    
		nMax = nMax or -1

		while nFirst and nMax ~= 0 do
      
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
      
		end
    
		aRecord[nField] = self:sub(nStart)
    
	end

	return aRecord
  
end

function random(x) 
    if math.random(0,100) <= x then 
		return true
	else 
		return false
    end 
end


--[[
	===================================================================================================================
	EID Community
	===================================================================================================================
]]--
function loadEIDtextFromFile()
	local load = Isaac.LoadModData(EIDC)
	--write file is new user
	if load == "" then
		Isaac.SaveModData(EIDC, "")
	end
	local checking = 0
	local thingtype = ""
	local thingname = ""
	local thingtext = ""
	for i = 1, #load do
		local substr = string.sub(load, i, i)
		if substr == "@" then
			checking = 1
			thingtype = ""
			thingname = ""
			thingtext = ""
		elseif checking == 1 then
			if substr == "I" or substr == "T" or substr == "C" or substr == "P" or substr == "F" then
				thingtype = substr
			elseif substr == ":" then
				checking = 2
			end
		elseif checking == 2 then
			if substr == ":" then
				checking = 3
			else
				thingname = thingname .. substr
			end
		elseif checking == 3 then
			if substr == ":" then
				checking = 4
				if thingtype == "I" then
					table.insert(ItemNames, thingname);table.insert(ItemDescriptions, thingtext);
				elseif thingtype == "T" then
					table.insert(TrinketNames, thingname);table.insert(TrinketDescriptions, thingtext);
				elseif thingtype == "C" then
					table.insert(CardNames, thingname);table.insert(CardDescriptions, thingtext);
				elseif thingtype == "P" then
					table.insert(PillNames, thingname);table.insert(PillDescriptions, thingtext);
				elseif thingtype == "F" then
					table.insert(TransformItemNames, thingname);table.insert(TransformDescriptions, thingtext);
				end
			else
				thingtext = thingtext .. substr
			end
		elseif checking == 4 then
			checking = 0
		end
	end
end

function EIDCgetDescriptions()
	--items
	for i = 1, #ItemNames do
		local itemID = Isaac.GetItemIdByName(ItemNames[i]);
		if itemID > 0 then
			__eidItemDescriptions[itemID] = ItemDescriptions[i];
		end
	end
	--trinkets
	for i = 1, #TrinketNames do
		local trinketID = Isaac.GetTrinketIdByName(TrinketNames[i]);
		if trinketID > 0 then
			__eidTrinketDescriptions[trinketID] = TrinketDescriptions[i];
		end
	end
	--cards
	for i = 1, #CardNames do
		local CardID = Isaac.GetCardIdByName(CardNames[i]);
		if CardID > 0 then
			__eidCardDescriptions[CardID] = CardDescriptions[i];
		end
	end
	--pills
	for i = 1, #PillNames do
		local PillID = Isaac.GetPillEffectByName(PillNames[i]);
		if PillID > 0 then
			__eidPillDescriptions[PillID] = PillDescriptions[i];
		end
	end
	--transformations
	for i = 1, #TransformItemNames do
		local itemID = Isaac.GetItemIdByName(TransformItemNames[i]);
		if itemID > 0 then
			__eidItemTransformations[itemID] = TransformDescriptions[i];
		end
	end
end

--[[
	===================================================================================================================
	SET CALLBACKS
	===================================================================================================================
]]--

drumsModPack:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, drumsModPack.postPlayerInit)
drumsModPack:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, drumsModPack.updateCache)
drumsModPack:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, drumsModPack.onEnterFloor)
drumsModPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, drumsModPack.onEnterRoom)

drumsModPack:AddCallback(ModCallbacks.MC_POST_UPDATE, drumsModPack.postUpdate)
drumsModPack:AddCallback(ModCallbacks.MC_POST_RENDER, drumsModPack.onRender)
drumsModPack:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,drumsModPack.onPlayerEffectUpdate)
drumsModPack:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, drumsModPack.onStickyEffectUpdate, UniquePickupsEffectVariant.STICKY_NICKEL)

drumsModPack:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, drumsModPack.onCoinInit, PickupVariant.PICKUP_COIN)
drumsModPack:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, drumsModPack.onCoinUpdate, PickupVariant.PICKUP_COIN)

drumsModPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, drumsModPack.playerTakeDamage, EntityType.ENTITY_PLAYER)
drumsModPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onDamage, EntityType.ENTITY_PLAYER)
drumsModPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, drumsModPack.entityTakeDamage)

drumsModPack:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, drumsModPack.entityKill)
drumsModPack:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, drumsModPack.HushBlessing, EntityType.ENTITY_HUSH)

drumsModPack:AddCallback(ModCallbacks.MC_NPC_UPDATE, drumsModPack.entityUpdateAngels, EntityType.ENTITY_URIEL)
drumsModPack:AddCallback(ModCallbacks.MC_NPC_UPDATE, drumsModPack.entityUpdateAngels, EntityType.ENTITY_GABRIEL)

drumsModPack:AddCallback(ModCallbacks.MC_USE_ITEM , drumsModPack.openCrawlspaceWall, CollectibleType.COLLECTIBLE_DADS_KEY)
drumsModPack:AddCallback(ModCallbacks.MC_USE_CARD , drumsModPack.openCrawlspaceWall, Card.CARD_GET_OUT_OF_JAIL)

drumsModPack:AddCallback(ModCallbacks.MC_EXECUTE_CMD, drumsModPack.onCmd);
 

--[[ CALLBACK LIST
	https://moddingofisaac.com/docs/group___enumerations.html
	https://moddingofisaac.com/docs/group__enums.html

	MC_NPC_UPDATE = 0,
	MC_POST_UPDATE = 1, // called after the game updates
	MC_POST_RENDER = 2, // called every frame
	MC_USE_ITEM = 3,
	MC_POST_PEFFECT_UPDATE = 4, // callback is a method that takes (EntityPlayer). Called for each player, each frame, after the player evaluates the effects of items that must be constantly evaluated. 
	MC_USE_CARD = 5,
	MC_FAMILIAR_UPDATE = 6
	MC_FAMILIAR_INIT = 7,
	MC_EVALUATE_CACHE = 8, // Callback is a method that takes (EntityPlayer, CacheFlag). Called one or more times when a player's stats must be re-evaluated, such as after picking up an item, using certain pills, manually calling EvaluateItems on EntityPlayer.
	MC_POST_PLAYER_INIT = 9, // called after the player is initialized (usually after starting the game)
	MC_USE_PILL = 10,
	MC_ENTITY_TAKE_DMG = 11,
	MC_POST_CURSE_EVAL = 12,
	MC_INPUT_ACTION = 13,
	MC_POST_NEW_LEVEL = 18, // triggers after transitioning a level/stage
	MC_POST_NEW_ROOM = 19, // triggers after entering a room
	MC_POST_EFFECT_UPDATE = 55 // (EntityEffect Effect) 
]]--

--[[
	EntityPlayer::AddCollectible(
		CollectibleType  	Type,
		integer  			Charge,
		boolean  			AddConsumables 
	) 	
]]--

-- [give ALL items]
-- lua for k,v in pairs(CollectibleType) do if not v ~= nil then Isaac.GetPlayer(0):AddCollectible(v, 0, false) end end
-- [print all items]
-- lua for _,v in pairs(CollectibleType) do if CollectibleType[v] then print(CollectibleType[v]) end end