local mod = RegisterMod("Revamped Special Rooms", 1)
local game = Game()
local sound = SFXManager()
local rng = RNG()

--===== MC_POST_PICKUP_UPDATE =====--

function mod:pickupupdate(pickup)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	-- Transparent choice items --
	if pickup.Type == 5 and pickup.Variant == 100 and pickup.TheresOptionsPickup and pickup:GetData().choice_item == nil then
		pickup:GetData().choice_item = true
		pickup:SetColor(Color(1.0, 1.0, 1.0, 0.65, 0, 0, 0), 0, 0, false, false)
	end
end

--===== MC_POST_EFFECT_UPDATE =====--

function mod:posteffect(entity)
	local room = game:GetLevel():GetCurrentRoom()
	-- Devil Room --
	if room:GetType() == RoomType.ROOM_DEVIL then
		if entity.Type == 1000 and entity.Variant == 6 then -- Devil Statue
			local sprite = entity:GetSprite()
			if game:GetDevilRoomDeals() > 0 then
				if entity:GetData().glowstatue_check == nil then
					entity:GetData().glowstatue_check = true
					sprite:Load("gfx/devil_statue.anm2", true)
					sprite:Play("Idle", true)
				end
			end
		end
	end
end

--===== MC_POST_PICKUP_INIT =====--

function mod:pickupinit(pickup)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomVariant = roomDesc.Data.Variant
	-- Improved shop sales --
	if (room:GetType() == RoomType.ROOM_SHOP and game:IsGreedMode() == false)
	or room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPER_SECRET or room:GetType() == RoomType.ROOM_LIBRARY then
		if pickup:IsShopItem() then
			local price = pickup.Price
			-- Heart --
			if pickup.Variant == 10 then
				pickup:Morph(5, 10, 0, false)
				pickup.Price = price
			end
			-- Key --
			if pickup.Variant == 30 then
				if rng:RandomInt(10) > 1 then
					pickup:Morph(5, 30, 0, false)
					pickup.Price = price
				else
					pickup:Morph(5, 30, 3, false)
					pickup.Price = price
				end
			end
			-- Bomb --
			if pickup.Variant == 40 then
				pickup:Morph(5, 40, 0, false)
				pickup.Price = price
				if pickup.SubType == 3 or pickup.SubType == 5 then
					pickup:Morph(5, 40, 2, false)
					pickup.Price = price
				end
			end
			-- Battery / Trinket / Sack --
			if pickup.Variant == 90 and rng:RandomInt(2) == 1 then
				if rng:RandomInt(5) == 1 then
					pickup:Morph(5, 69, 0, false)
					pickup.Price = price
				else
					pickup:Morph(5, 350, 0, false)
					pickup.Price = price
				end
			end
		end
	end
end

--===== MC_PRE_PICKUP_COLLISION =====--

function mod:pickupcollision(entity, collider, low)
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomVariant = roomDesc.Data.Variant
	-- Stock Shop --
	if room:GetType() == RoomType.ROOM_SHOP then
		if roomVariant == 61 or roomVariant == 62 or roomVariant == 63 or roomVariant == 64 or roomVariant == 65 then -- Stock Shop
			if entity.Type == 5 and entity.Variant == 100 and collider.Type == EntityType.ENTITY_PLAYER and entity:IsShopItem() == false then
				for i, ent in pairs(Isaac.GetRoomEntities()) do
					if ent.Type == 17 then -- Shopkeeper
						ent:Remove()
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01 , 0, ent.Position, Vector(0,0), nil) -- Smoke Effect
						local greed = Isaac.Spawn(299, 0, 0, ent.Position, Vector(0,0), ent) -- Greed Gaper
						greed:AddEntityFlags(EntityFlag.FLAG_APPEAR)
						for j = 0, DoorSlot.NUM_DOOR_SLOTS -1 do
							local door = room:GetDoor(j)
							if door ~= nil then
								door:Close(true) -- Close Doors
							end
						end
					end
				end
			end
		end
	end
end

--===== MC_POST_NEW_ROOM =====--

function mod:postroom()
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomVariant = roomDesc.Data.Variant
	-- Secret rooms with two items --
	if room:GetType() == RoomType.ROOM_SECRET and room:IsFirstVisit() then
		if roomVariant == 101 or roomVariant == 102 or roomVariant == 103 or roomVariant == 104 or roomVariant == 105 then
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 and entity.Variant == 100 then
					entity:ToPickup().TheresOptionsPickup = true
				end
			end
		end
	end
end

--===== MC_POST_NEW_LEVEL =====--

function mod:postlevel()
	local room = game:GetLevel():GetCurrentRoom()
	-- Disable Mom's Dressing Table in spawn --
	for i, entity in pairs(Isaac.GetRoomEntities()) do
		if entity.Type == 6 and entity.Variant == 12 then
			entity:Remove()
		end
	end
	-- Krampus Spawn --
	if game:GetDevilRoomDeals() <= 0 then -- Pact Check
		game:SetStateFlag(GameStateFlag.STATE_KRAMPUS_SPAWNED, true)
	else
		if rng:RandomInt(10) > 2 then -- 80% Chance to block Krampus spawn chance
			game:SetStateFlag(GameStateFlag.STATE_KRAMPUS_SPAWNED, true)
		else
			game:SetStateFlag(GameStateFlag.STATE_KRAMPUS_SPAWNED, game:HasEncounteredBoss(EntityType.ENTITY_FALLEN, 1))
		end
	end
end

-- Callbacks --
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.pickupupdate)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.posteffect)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.pickupinit)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.pickupcollision)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.postroom)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.postlevel)
---------------

mod:ForceError() --this function doesn't exist, we do this to cause an error intentionally