local MyMod = RegisterMod("God Transformation", 1)
local game = Game()
local godhead = false

function MyMod:onCache()
  local player = Isaac.GetPlayer(0)
  if game:GetFrameCount() == 1 then  
    godhead = false
  end
   if not godhead and player:HasCollectible(CollectibleType.COLLECTIBLE_MIND) and player:HasCollectible(CollectibleType.COLLECTIBLE_BODY) and player:HasCollectible(CollectibleType.COLLECTIBLE_SOUL) then
    SFXManager():Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1)
    player:AddCollectible(331, 0, false)
    godhead = true
  end
  if godhead then
    game:GetLevel():AddAngelRoomChance(1)
    player:GetEffects():AddCollectibleEffect(179, true)
  end
end
MyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, MyMod.onCache)

function MyMod:canFly()
local player = Isaac.GetPlayer(0)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MIND) and player:HasCollectible(CollectibleType.COLLECTIBLE_BODY) and player:HasCollectible(CollectibleType.COLLECTIBLE_SOUL) then
    player.CanFly = true
  end
end
MyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MyMod.canFly)

MyMod:ForceError() --this function doesn't exist, we do this to cause an error intentionally