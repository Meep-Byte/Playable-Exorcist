local exorcistMod = RegisterMod("The Exorcist", 1)
local game = Game()
local ExorcistType = Isaac.GetPlayerTypeByName("Exorcist", false)
local ACTIVE_MAGNUM_OPUS = Isaac.GetItemIdByName("Magnum Opus")
local ACTIVE_TOME_OF_BLIGHT = Isaac.GetItemIdByName("Tome of Blight")
local ACTIVE_SCOURGETOME = Isaac.GetItemIdByName("The Scourgetome")
local ROTTEN_KEY = Isaac.GetEntitySubTypeByName("Rotten Key")
local PURPLE_CANDLE = Isaac.GetItemIdByName("Purple Candle")
local COSTUME_PURPLE_CANDLE = Isaac.GetCostumeIdByPath("gfx/characters/thepurplecandle.anm2")
local DIY_TAXIDERMY_KIT = Isaac.GetItemIdByName("DIY Taxidermy Kit")
local TAINTED_GRAIL = Isaac.GetItemIdByName("Tainted Grail")
local HEART_OF_HERESY = Isaac.GetItemIdByName("Heart of Heresy")
local REMAINS_OF_HERESY = Isaac.GetItemIdByName("Remains of Heresy")
local MIND_OF_HERESY = Isaac.GetItemIdByName("Mind of Heresy")
local CHAINS_OF_CHASTITY = Isaac.GetItemIdByName("Chains of Chastity")
local LUST_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/chainsofchastity_broken.anm2")
local sound = SFXManager()

--Gives the exorcist Magnum Opus as his pocket active
function exorcistMod:exorcistInit(player)
    if player:GetPlayerType() ~= ExorcistType then
        return
    else
     player:SetPocketActiveItem(ACTIVE_MAGNUM_OPUS, ActiveSlot.SLOT_POCKET, true)
     local pools = game:GetItemPool()
     pools:RemoveCollectible(ACTIVE_MAGNUM_OPUS)
     player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
     player:EvaluateItems()
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, exorcistMod.exorcistInit)
function exorcistMod: applyExorcistStats(player, CacheFlag)
   if player:GetPlayerType() ~= ExorcistType then
   return
   else
   player.MaxFireDelay = player.MaxFireDelay - 1.25
   end
end
exorcistMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, exorcistMod.applyExorcistStats, CacheFlag.CACHE_FIREDELAY)
-- spawns ghosts on enemy kill if holding mangum opus
function exorcistMod:magnumOpusPassive(player)
    if player:GetActiveItem() == ACTIVE_MAGNUM_OPUS or player: GetActiveItem(ActiveSlot.SLOT_POCKET) == ACTIVE_MAGNUM_OPUS then
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.SpawnerEntity == nil then
        local data = entity:GetData()
        local stillentity = entity:ToNPC()
        if stillentity ~= nil then
            local pos = stillentity.Position
            local veloc = stillentity.Velocity
        if entity and stillentity:IsActiveEnemy(true) then
         if stillentity:IsDead() and data.IsHeckinDead == nil then
            data.IsHeckinDead = true
            if entity.Type == EntityType.ENTITY_EFFECT then
                return
            else
             local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0, pos, veloc, nil)
         end
        end
        end
    end
    end
    if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.ENEMY_GHOST then
        local data = entity:GetData()
        if data.haschanged == nil then
            local sprite = entity:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/spooky_ghosts.png")
            sprite:LoadGraphics()
            data.haschanged = 0
        end
    end
end
end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.magnumOpusPassive)
function exorcistMod:magnumOpusUse(_,_,player)
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.ENEMY_GHOST and entity.SubType == 0 then
            entity:Remove()
            local ghostminion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, entity.Position, Vector.Zero, player)
            local sprite = ghostminion:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/spookier_ghost.png")
            sprite:LoadGraphics()
            local ghostMinionEffect = ghostminion:ToEffect()
            if ghostMinionEffect ~= nil then
            ghostMinionEffect:SetTimeout(150)
            end
        end
    end
 return true
end
exorcistMod:AddCallback(ModCallbacks.MC_USE_ITEM, exorcistMod.magnumOpusUse, ACTIVE_MAGNUM_OPUS)

function exorcistMod:passiveVisualEffects(player)
    if player:GetPlayerType() ~= ExorcistType then
        return
    else
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.PURGATORY and entity.SubType == 0 then
                local data = entity:GetData()
                if data.haschanged == nil then
                    local sprite = entity:GetSprite()
                    sprite:ReplaceSpritesheet(0, "gfx/cool.png")
                    sprite:ReplaceSpritesheet(1, "gfx/really_cool.png")
                    sprite:LoadGraphics()
                    data.haschanged = 0
                end
            end
            if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.PURGATORY and entity.SubType == 1 then
                local data = entity:GetData()
                if data.haschanged == nil then
                    local sprite = entity:GetSprite()
                    sprite:ReplaceSpritesheet(0, "gfx/purgatory_soul.png")
                    sprite:ReplaceSpritesheet(1, "gfx/purgatory_soul.png")
                    sprite:LoadGraphics()
                    data.haschanged = 0
                end
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.passiveVisualEffects)

function exorcistMod:blightTomeProc(_,_,player)
    local playerPos = player.Position
    for i = 0, 5 do
        local nearbyPos = Isaac.GetFreeNearPosition(playerPos, 30)
        local lessNearbyPos = Vector((nearbyPos.X - math.random(-10, 10)),(nearbyPos.Y - math.random(-10, 10)))
        local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0,0, lessNearbyPos, Vector.Zero, player)
        maggot:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
        local data = maggot:GetData()
        if data.canSpawnCreep == nil then data.canSpawnCreep = true end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_USE_ITEM, exorcistMod.blightTomeProc, ACTIVE_TOME_OF_BLIGHT)

function exorcistMod:blightTomeMaggotBuff(player)
    if player:GetActiveItem() == ACTIVE_TOME_OF_BLIGHT then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_SMALL_MAGGOT and entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY) or entity.Type == EntityType.ENTITY_WHIPPER and entity.Variant == 1 and entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY) then
                if entity:IsDead() then
                    return
                else
                local data = entity:GetData()
                 if data.canSpawnCreep == true and game:GetFrameCount() % 20 == 0 then
                    local creeposition = entity.Position
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, creeposition, Vector.Zero, entity)
                    local creepEffect = creep:ToEffect()
                 end
                end
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.blightTomeMaggotBuff)

function exorcistMod:scourgeTomeProc(_,_,player)
    local playerPos = player.Position
    for i = 0, 2 do
        local room = game:GetRoom()
        local lessNearbyPos = room:GetRandomPosition(player.Size)
        local snapper = Isaac.Spawn(EntityType.ENTITY_WHIPPER, 1, 0, lessNearbyPos, Vector.Zero, player)
        snapper:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
        local data = snapper:GetData()
        local sprite = snapper:GetSprite()
        sprite:ReplaceSpritesheet(0, "gfx/snapper_body.png")
        sprite:ReplaceSpritesheet(1, "gfx/snapper_head.png")
        sprite:ReplaceSpritesheet(2, "gfx/snapper_body.png")
        sprite:LoadGraphics()
        if data.canSpawnCreep == nil then data.canSpawnCreep = true end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_USE_ITEM, exorcistMod.scourgeTomeProc, ACTIVE_SCOURGETOME)

function exorcistMod:replaceWithRottenKey(player)
    if player:GetActiveItem() == ACTIVE_TOME_OF_BLIGHT then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_KEY and entity.SubType == 1 then
                local RNG = player:GetCollectibleRNG(player:GetActiveItem())
                local diceRoll = RNG:RandomInt(40)
                if diceRoll == 10 then
                    local entityPos = entity.Position
                    entity:Remove()
                    local rottenKey = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY, ROTTEN_KEY, entityPos, Vector.Zero, nil)
                end
            end
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_KEY and entity.SubType == ROTTEN_KEY then
                local sprite = entity:GetSprite()
                if sprite:IsFinished("Collect") then
                    sound:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 1, 0, false, 1, 0)
                    player:RemoveCollectible(ACTIVE_TOME_OF_BLIGHT, false, ActiveSlot.SLOT_PRIMARY, true)
                    player:RemoveCollectible(ACTIVE_TOME_OF_BLIGHT, false, ActiveSlot.SLOT_SECONDARY, true)
                    player:AddCollectible(ACTIVE_SCOURGETOME, 0, true, ActiveSlot.SLOT_PRIMARY, 0)
                    entity:Remove()
                end
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.replaceWithRottenKey)

function exorcistMod:rottenKeyProc(rotkey)
    if rotkey.SubType == ROTTEN_KEY then
        local sprite = rotkey:GetSprite()
        sprite:Play("Collect", true)
        rotkey.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        rotkey.Velocity = Vector.Zero
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, exorcistMod. rottenKeyProc, PickupVariant.PICKUP_KEY)

function exorcistMod:addFlight(player)
    if player:HasCollectible(PURPLE_CANDLE) then
        player.CanFly = true
        player:AddNullCostume(COSTUME_PURPLE_CANDLE)
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, exorcistMod.addFlight, CacheFlag.CACHE_FLYING)

function exorcistMod:purpleCandlePassive(monster)
    for playerNum = 1, game:GetNumPlayers() do
    local player = Isaac.GetPlayer(playerNum)
    if player:HasCollectible(PURPLE_CANDLE) then
        local monsterpos = monster.Position
        local roll = math.random(100)
        if roll <= math.min(50, math.max(10,(20 * player.Luck))) then
            for i = 0, 5 do 
             local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, monsterpos, Vector((math.random(-5,5) *1.5),(math.random(-5,5) * 1.5)), nil)
             sound:Play(SoundEffect.SOUND_DEMON_HIT, 1, 0, false, 1, 0)
             fire.CollisionDamage = 20
             local sprite = fire:GetSprite()
             sprite:ReplaceSpritesheet(0, "gfx/fire_purple.png")
             sprite:LoadGraphics()
            end
        end
     end
end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, exorcistMod.purpleCandlePassive)
local canProc = true
function exorcistMod:taxidermyProc(tear)
    for playerNum = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(playerNum-1)
        if player:HasCollectible(DIY_TAXIDERMY_KIT) and player:GetPlayerType() ~= PlayerType.PLAYER_CAIN then
            local fireDir = player:GetFireDirection()
        local tearIndex = tear.TearIndex
        local tearPos = tear.Position
        local tearVeloc = tear.Velocity
        if tearIndex % 2 == 0  and canProc == true then
        canProc = false
        tear:Remove()
        if fireDir == Direction.LEFT or fireDir == Direction.RIGHT then
        for i = 0, 5 do
            local firedTear = player:FireTear(tearPos, Vector((tearVeloc.X / 2), ((tearVeloc.Y + 1)) * math.random(-2,2)), false, true, true, player, 0.5)
            firedTear.FallingAcceleration = math.random(2,4)
            firedTear.FallingSpeed = math.random(-20, -10)
            local sprite = firedTear:GetSprite()
            sprite:ReplaceSpritesheet( 0, "gfx/bullet_atlas.png")
            sprite:LoadGraphics()
            
        end
       else if fireDir == Direction.UP or fireDir == Direction.DOWN then
        for i = 0, 5 do
            local firedTear = player:FireTear(tearPos, Vector((tearVeloc.X + 1) * math.random(-2, 2), (tearVeloc.Y/2)), false, true, true, player, 0.5)
            firedTear.FallingAcceleration = math.random(2, 4)
            firedTear.FallingSpeed = math.random(-20, -10)
            local sprite = firedTear:GetSprite()
            sprite:ReplaceSpritesheet( 0, "gfx/bullet_atlas.png")
            sprite:LoadGraphics()
        end
       end
      end
      canProc = true
    end
end
end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, exorcistMod.taxidermyProc)

function exorcistMod:addGrailStatsOnNewFloor()
    for playerNum = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(playerNum - 1)
        if player:HasCollectible(TAINTED_GRAIL) then
            if player:GetBrokenHearts() == 11 then
                return
            else
             player:AddBrokenHearts(1)
             player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
             player:EvaluateItems()
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, exorcistMod.addGrailStatsOnNewFloor)
function exorcistMod:addGrailDamage(player)
    if player:HasCollectible(TAINTED_GRAIL) then
        local numBrokenHearts = player:GetBrokenHearts()
        player.Damage = player.Damage + (1 * numBrokenHearts)
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, exorcistMod.addGrailDamage, CacheFlag.CACHE_DAMAGE)

function exorcistMod:hereticHeartPassive(player)
    if player:HasCollectible(HEART_OF_HERESY) then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY) or entity:IsBoss() or player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_STRENGTH) then
                return
            else if player.Position:Distance(entity.Position) <= 50 then
             entity:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
            else
            entity:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
            end
        end
    end
end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.hereticHeartPassive)

function exorcistMod:remainsPassive(player)
    if player:HasCollectible(REMAINS_OF_HERESY) then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            local data = entity:GetData()
            if data.duration == nil then data.duration = 0 end
            if entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY) then
                return
            else if entity:HasEntityFlags(EntityFlag.FLAG_BURN) or entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) or entity:HasEntityFlags(EntityFlag.FLAG_FEAR)
                or entity:HasEntityFlags(EntityFlag.FLAG_POISON) or entity:HasEntityFlags(EntityFlag.FLAG_SLOW)  then
                    entity:ClearEntityFlags(EntityFlag.FLAG_BURN|EntityFlag.FLAG_CONFUSION|EntityFlag.FLAG_FEAR|EntityFlag.FLAG_POISON|EntityFlag.FLAG_SLOW)
                    data.duration = game:GetFrameCount() + 300
                   entity:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
                end
            end
            if game:GetFrameCount() == data.duration and entity:HasEntityFlags(EntityFlag.FLAG_WEAKNESS)then
                entity:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.remainsPassive)
local canFunction = true
local i = 0
local level = nil
local stage = nil
local seed = nil
function exorcistMod: mindInit()
level = game:GetLevel()
stage = level:GetStage()
seed = game:GetSeeds():GetStageSeed(stage)
canFunction = true
end

exorcistMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, exorcistMod.mindInit)
exorcistMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, exorcistMod.mindInit)

function exorcistMod:hereticMindPassive()
    if level == nil then
return
    else
    for playernum = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(playernum-1)
        if player:HasCollectible(MIND_OF_HERESY) and canFunction == true  then
            local roomIndex = level:GetRandomRoomIndex(false, seed)
            local room = level:GetRoomByIdx(roomIndex, -1)
            while room.VisitedCount >= 1 or room.DisplayFlags & 1<<0 == 1<<0 do
            seed = seed + 1
            roomIndex = level:GetRandomRoomIndex(false, seed)
            room = level:GetRoomByIdx(roomIndex, -1)
            i = i + 1
            if i == 20 then
            canFunction = false
            break
            end
            end
            if room.DisplayFlags & 1<<0 == 1<<0 then
                return
            else
            room.DisplayFlags = room.DisplayFlags + 1 << 0;
            level:UpdateVisibility()
            i = 0
            end
        end
    end
end
end

exorcistMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, exorcistMod.hereticMindPassive)
local isLust = false
function exorcistMod:chainStats(player,cacheflag)
    if cacheflag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        if player:HasCollectible(CHAINS_OF_CHASTITY) then
            if isLust == false then
            player.MoveSpeed = player.MoveSpeed - 0.30
            else if isLust == true then
            player.MoveSpeed = player.MoveSpeed + 0.30
            end
        end
        end
    end
    if cacheflag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if player:HasCollectible(CHAINS_OF_CHASTITY) then
            if isLust == true then
                player.Damage = player.Damage * 1.5
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, exorcistMod.chainStats)
function exorcistMod:chainTransformation()
    for playerNum = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(playerNum -1)
        if player:HasCollectible(CHAINS_OF_CHASTITY) then
        local keys = player:GetNumKeys()
        if keys >= 14 and isLust == false then
            isLust = true
        player:AddNullCostume(LUST_COSTUME)
        sound:Play(504, 1, 0, false, 1, 1)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        for i = 0, 9 do
        local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_GIB, 0, player.Position, Vector(math.random(-10,10), math.random(-10, 10)), nil)
        end
    end
    end
end
end
exorcistMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, exorcistMod.chainTransformation, PickupVariant.PICKUP_KEY)

function exorcistMod:chainPassive(player)
    if player:HasCollectible(CHAINS_OF_CHASTITY) and isLust == true then
        if game:GetFrameCount() % 5 == 0 then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector.Zero, nil)
            creep.CollisionDamage = player.Damage
            local creepEffect = creep:ToEffect()
            if creepEffect ~= nil then
            creepEffect:SetTimeout(100)
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, exorcistMod.chainPassive)
function exorcistMod:MagnumOpusSynergies(soul)
    for playerNum = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(playerNum -1)
        if player:GetPlayerType() == ExorcistType then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            local sprite = soul:GetSprite()
            local soulPos = soul.Position
            if sprite:IsFinished("Die") then
                local brim = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL, 0, soulPos, Vector.Zero, nil)
                brim.CollisionDamage = 20
                local brimEffect = brim:ToEffect()
                if brimEffect ~= nil then
                    brimEffect:SetTimeout(20)
                end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_120_VOLT) or player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
            local soulPos = soul.Position
            local entityList = Isaac.FindInRadius(soulPos, 40, 1<<3)
            for _, entity in ipairs(entityList) do
                local entityPos = entity.Position
                local laserDirection = Vector(soulPos.X - entityPos.X, soulPos.Y - entityPos.Y) * -1
                local laserAngle = laserDirection:GetAngleDegrees()
                if game:GetFrameCount() % 10 == 0 then
                    local electricity = EntityLaser.ShootAngle(10, soulPos, laserAngle, 10, Vector.Zero, soul)
                    electricity.MaxDistance = soulPos:Distance(entityPos) *1.5
                end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
            if game:GetFrameCount() % 30 == 0 then
                local soulPos = soul.Position
                local tear = player:FireTear(soulPos, Vector(math.random(-4,4), math.random(-4,4)), false, true, false, soul, 0.3)
                tear.TearFlags = TearFlags.TEAR_FETUS
                tear:ChangeVariant(50)
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_GIANT_CELL) then
            local soulPos = soul.Position
            local sprite = soul:GetSprite()
            if sprite:IsFinished("Die") then
                local roll = math.random(1,4)
                if roll == 1 then
                local minisaac = player:AddMinisaac(soulPos, true)
                local lsprite = minisaac:GetSprite()
                lsprite:ReplaceSpritesheet(0,"gfx/special_minisaac.png")
                lsprite:ReplaceSpritesheet(1,"gfx/special_minisaac.png")
                lsprite:LoadGraphics()
                end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
            local soulPos = soul.Position
            local playerPos = player.Position
            if game:GetFrameCount() % 15 == 0 then
            local dir = Vector(playerPos.X - soulPos.X, playerPos.Y - soulPos.Y):Normalized() * -1
            local techlaser = player:FireTechLaser(playerPos, LaserOffset.LASER_TECH1_OFFSET, dir, false, false, player, 0.5)
            techlaser.MaxDistance = playerPos:Distance(soulPos)
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
            local soulPos = soul.Position
            local velocity = soul.Velocity
            local data = soul:GetData()
            local sprite = soul:GetSprite()
            if sprite:IsFinished("Die") then
            return
            else
            if data.HasFiredLaser == nil then data.HasFiredLaser = 0 
            local laser = player:FireTechLaser(soulPos, LaserOffset.LASER_TECH1_OFFSET, velocity, false, false, soul, 1)
            local laserdata = laser:GetData()
            if laserdata.hasBeenInit == nil then laserdata.hasBeenInit = true end
            laser:SetTimeout(soul.Timeout)
            laser.Parent = soul
            end
        end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITOID) then
            local sprite = soul:GetSprite()
            local SoulPos = soul.Position
            if sprite:IsFinished("Die") then
                local roll = math.random(10)
                if roll == 1 then
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, 0, SoulPos, Vector.Zero, soul):ToEffect()
                creep.Scale = 2
                if creep ~= nil then
                creep:Update()
                end
                local pos = Isaac.GetFreeNearPosition(SoulPos, 34)
                for i = 0, 3 do
                player:ThrowBlueSpider(SoulPos, pos)
                end
            end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
            local soulPos = soul.Position
            local playerPos = player.Position
            local sprite = soul:GetSprite()
            local data = soul:GetData()
            if data.hasBeenShiv == nil then
                data.hasBeenShiv = true
                local knife = player:FireKnife(soul, 0, true, 0, 0)
                local knifedata = knife:GetData()
                if knifedata.hasinitialized == nil then knifedata.hasinitialized = true end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
            local soulPos = soul.Position
            local soulData = soul:GetData()
            local soulSprite = soul:GetSprite()
            if soulSprite:IsFinished("Die") then
                return
            else
            if soulData.HasBeenInitialized == nil then
               soulData.HasBeenInitialized = true
               local techXLaser = player:FireTechXLaser(soulPos, Vector.Zero, 40, soul, 0.5)
               techXLaser:SetTimeout(soul.Timeout)
               techXLaser:AddTearFlags(TearFlags.TEAR_CONTINUUM)
               techXLaser.Parent = soul
               local laserData = techXLaser:GetData()
               if laserData.hasinitialized == nil then laserData.hasinitialized = true
            end
        end
        end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
           local soulPos = soul.Position
           local sprite = soul:GetSprite()
           if soul.CollisionDamage == 5 then
            return
           else if sprite:IsFinished("Die") then
            for e = 0, 1 do
                local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL,0,soulPos, Vector(math.random(-5,5), math.random(-5,5)), soul)
                local data = ghost:GetData()
                if data.hasBeenSpawned == nil then
                    data.hasBeenSpawned = true
                    local ghostSprite = ghost:GetSprite()
                    ghostSprite:ReplaceSpritesheet(0, "gfx/spookier_ghost.png")
                    ghostSprite:LoadGraphics()
                    ghost.CollisionDamage = 5
                    ghost.SpriteScale = ghost.SpriteScale / 1.5
                    ghost:SetSize(14, Vector(1,1), 1)
                    local ghostEffect = ghost:ToEffect()
                    if ghostEffect ~= nil then
                     ghostEffect:SetTimeout(150)
                    end
                end
            end
           end
        end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH) then
            local soulPos = soul.Position
            local entityList = Isaac.FindInRadius(soulPos, 20, 1<<3)
            for _, entity in pairs(entityList) do
                local data = entity:GetData()
                if data.hasBeenFrozen == nil then
                    data.hasBeenFrozen = true
                    entity:AddMidasFreeze(EntityRef(player), 60)
                end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_POP) then
            local sprite = soul:GetSprite()
            local soulpos = soul.Position
            if sprite:IsFinished("Die") then
                for i = 0, 5 do
                    local tear = player:FireTear(soulpos, Vector(math.random(-7,7),math.random(-7,7)), false, true, false, soul, 1)
                    tear.TearFlags = player.TearFlags
                    tear:AddTearFlags(TearFlags.TEAR_POP)
                end
            end
        end
        break
    end

end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, exorcistMod.MagnumOpusSynergies, EffectVariant.HUNGRY_SOUL )

function exorcistMod:laserUpdate(laser)
local data = laser:GetData()
if data.hasBeenInit == true then
    local soul = laser:GetLastParent()
    local soulVelocity = soul.Velocity
    local angle = soulVelocity:GetAngleDegrees()
    laser.Position = soul.Position
    laser.Angle = angle
end
if data.hasinitialized == true then
    local soul = laser:GetLastParent()
    laser.Position = soul.Position
    laser.Velocity = soul.Velocity
end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, exorcistMod.laserUpdate)

function exorcistMod:knifeUpdate(knife)
    local data = knife:GetData()
    if data.hasinitialized == true then
        local soul = knife:GetLastParent()
        local soulVeloc = soul.Velocity
        local angle = soulVeloc:GetAngleDegrees()
        knife.Rotation = angle
        if game:GetFrameCount() % 60 == 0 then
            local entities = Isaac.FindInRadius(knife.Position, 200, 1<<3)
            for _, entity in pairs(entities) do
                if soul.Position:Distance(entity.Position) <= 40 then
                    return
                else
                local entityPos = entity.Position
                local knifePos = knife.Position
                local direction = Vector(knifePos.X - entityPos.X, knifePos.Y - entityPos.Y)* -1
                knife:Shoot( 1, direction:Length())
              
                break
                end
            end
        end
    end
end
exorcistMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, exorcistMod.knifeUpdate)