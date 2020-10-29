local crowheadmod = RegisterMod("Crow Head", 1);
local itemid = Isaac.GetItemIdByName("Crow Head");
local defaultchance = 0.01;

if not __eidItemDescriptions then         
  __eidItemDescriptions = {};
end	
__eidItemDescriptions[itemid] = "Sometimes spawn a half soul heart when killing an enemy.#Chance increases with luck.";


debug_text = " "

function crowheadmod:entitydamage(entity,amount,flag,source,num)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(itemid) then
		local chance = defaultchance + 0.0033333333333333*player.Luck
		if chance > 0.12 then
			chance = 0.12
		end
		if entity:IsVulnerableEnemy() and amount >= entity.HitPoints and source.Type < 9 then
			local temp = math.random()
			if temp <= chance then
				Isaac.Spawn(5, 10, 8, entity.Position, Vector(0, 0), nil)
			end
		end
	end
end


crowheadmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG , crowheadmod.entitydamage);

crowheadmod:ForceError() --this function doesn't exist, we do this to cause an error intentionally