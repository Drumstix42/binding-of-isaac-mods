local Mod = RegisterMod("Yum Heart And Maggys Bow", 1)

local GameState = {}
--local json = require("json")

local yumHeart = {
    collectible = CollectibleType.COLLECTIBLE_YUM_HEART
}

if not __eidItemDescriptions then 
	__eidItemDescriptions = {} 
end 

__eidItemDescriptions[CollectibleType.COLLECTIBLE_YUM_HEART] = "Heal 1 red heart#Drops red heart if used on full health"

function Mod:GameStart()
    --GameState = json.decode(Mod:LoadData())
    if GameState.HasVoidYumHeart == nil then
        GameState.HasVoidYumHeart = false
    elseif GameState.HasVoidYumHeart then
        yumHeart.collectible = CollectibleType.COLLECTIBLE_VOID
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.GameStart)

--function Mod:GameExit()
	--Mod:SaveData(json.encode(GameState))
--end
--Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Mod.GameExit)
--Mod:AddCallback(ModCallbacks.MC_POST_GAME_END, Mod.GameExit)

function Mod:ActivateVoid(collectible, rng)
    local entities = Isaac.GetRoomEntities()
	for i=1, #entities do
		if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_COLLECTIBLE and entities[i].SubType == CollectibleType.COLLECTIBLE_YUM_HEART then
			entities[i]:Remove()
			GameState.HasVoidYumHeart = true
            yumHeart.collectible = CollectibleType.COLLECTIBLE_VOID
            Mod.preYumHeartUse() 
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.ActivateVoid, CollectibleType.COLLECTIBLE_VOID)

function Mod:constantPlayerUpdate(player)
    if Game():GetFrameCount() == 1 then
        GameState.HasVoidYumHeart = false
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then   
        local data = player:GetData()
        if data.currentHearts == nil then
            data.currentHearts = player:GetHearts()
        end
        if data.currentMaxHearts == nil then
            data.currentMaxHearts = player:GetMaxHearts()
        end
        if data.pickedUpHeart == nil then
            data.pickedUpHeart = false
        end
        if player:GetHearts() > data.currentHearts and not data.pickedUpHeart and player:GetMaxHearts() == data.currentMaxHearts then
            player:AddHearts(player:GetHearts() - data.currentHearts)
            data.currentHearts = player:GetHearts()
        elseif data.pickedUpHeart then
            data.currentHearts = player:GetHearts()
            data.currentMaxHearts = player:GetMaxHearts()
            data.pickedUpHeart = false
        else 
            data.currentHearts = player:GetHearts()
            data.currentMaxHearts = player:GetMaxHearts()
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Mod.constantPlayerUpdate)

function Mod:hasPickedUpRedHeart(pickup, collider, low)
    if collider.Type == EntityType.ENTITY_PLAYER and pickup.Variant == PickupVariant.PICKUP_HEART and collider:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
        local data = collider:ToPlayer():GetData()
        data.pickedUpHeart = true
    end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.hasPickedUpRedHeart)

function Mod:preYumHeartUse(collectible, rng)
    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
        if collectible == yumHeart.collectible then
            local data = player:GetData()
            data.preUseHearts = player:GetMaxHearts() - player:GetHearts()
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, Mod.preYumHeartUse)

function Mod:activateYumHeart(yumheart, rng)
    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
        local data = player:GetData()
        if data.preUseHearts == 0 then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
                Mod:dropHearts(4, i-1)
            else
                Mod:dropHearts(2, i-1)
            end
        else
            local healed = 2
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
                healed = 4
            end
            if healed - data.preUseHearts > 0 then 
                Mod:dropHearts(healed - data.preUseHearts, i-1)
            end
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.activateYumHeart, yumHeart.collectible)

function Mod:dropHearts(amount, playerid)
    local player = Isaac.GetPlayer(playerid)
    local y = player.Position.Y
    local x = player.Position.X
    if amount == 1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, Vector(x,(y+20)), Vector(0,0), nil)
    elseif amount == 2 then    
        local random = math.random(4)
        local heartSubType
        if random < 4 then
            heartSubType = HeartSubType.HEART_FULL
        else
            heartSubType = HeartSubType.HEART_SCARED
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartSubType, Vector(x,(y+20)), Vector(0,0), nil)
    elseif amount == 3 then 
        local random = math.random(4)
        local heartSubType
        if random < 4 then
            heartSubType = HeartSubType.HEART_FULL
        else
            heartSubType = HeartSubType.HEART_SCARED
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartSubType, Vector(x,(y+20)), Vector(0,0), nil)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, Vector(x,(y+20)), Vector(0,0), nil)
    elseif amount >= 4 then 
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, Vector(x,(y+20)), Vector(0,0), nil)
    end
end

Mod:ForceError() --this function doesn't exist, we do this to cause an error intentionally