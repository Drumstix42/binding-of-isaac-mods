--require('mobdebug').start()
local cornucopia = RegisterMod( "Cornucopia", 1)

local modItem = Isaac.GetItemIdByName("Cornucopia")

local lastLevel

function SpawnConsumables(player)
  local rotate = 360/8
  local vel = Vector(0, -3.6)
  local spawnPos = player.Position
  local sub = 2
  local ran = math.random()
  if ran<0.2 then sub = 3 end
  if ran>0.6 then sub = 1 end
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, sub, spawnPos, vel, player)
  
  vel = vel:Rotated(rotate)
  sub = 1
  if math.random()<0.15 then sub = 2 end
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, sub, spawnPos, vel, player)
  
  vel = vel:Rotated(rotate)
  sub = 1
  if math.random()<0.15 then sub = 3 end
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, sub, spawnPos, vel, player)
  
  vel = vel:Rotated(rotate)
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, spawnPos, vel, player)
  
  vel = vel:Rotated(rotate)
  sub = 1
  if math.random()<0.7 then sub = 2 end
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, sub, spawnPos, vel, player)
  
  vel = vel:Rotated(rotate)
  sub = 3
  if math.random()<0.7 then sub = 8 end
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, sub, spawnPos, vel, player)
  
  vel = vel:Rotated(rotate)

  if math.random()<0.5 then
    --Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_RANDOM, spawnPos, vel, player)
    sub = math.random(1, Card.NUM_CARDS-1)
    --Isaac.DebugString("SPAWNING CARD "..tostring(sub))
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, sub, spawnPos, vel, player)
  else
    sub = math.random(1, PillColor.NUM_PILLS-1)
    --Isaac.DebugString("SPAWNING PILL "..tostring(sub))
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, sub, spawnPos, vel, player)
  end
  
  vel = vel:Rotated(rotate)
  sub = math.random(1, TrinketType.NUM_TRINKETS-1)
  --Trinket #47 (POLAROID_OBSOLETE) causes the game to crash, avoid spawning it
  if (sub==47) then sub = 46 end
  --Isaac.DebugString("SPAWNING TRINKET "..tostring(sub))
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, sub, spawnPos, vel, player)
end

function cornucopia:Update()
  local player = Isaac.GetPlayer(0); -- TODO: check each possible player for Collectible as an improvement
  --local level = Game():GetLevel():GetDungeonPlacementSeed()
  local level = Game():GetLevel():GetStage()
	if player:HasCollectible(modItem) then
    if lastLevel==nil then lastLevel = level end
    if lastLevel ~= level then
      math.randomseed(Game():GetFrameCount())
      player:AnimateCollectible(modItem, "UseItem", "Idle")
      SpawnConsumables(player)
    end
  end
  lastLevel = level
end

--cornucopia:AddCallback(ModCallbacks.MC_POST_UPDATE, cornucopia.Update) -- POST_UPDATE method not needed (unneccesary # of checks)
cornucopia:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, cornucopia.Update)

cornucopia:ForceError() --this function doesn't exist, we do this to cause an error intentionally