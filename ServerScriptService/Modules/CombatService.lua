local CombatService = {
    Players = {}
}

local WeaponModels

local CombatShared = require(game.ReplicatedStorage.Modules.Combat.CombatShared)
local SharedUtils = require(game.ReplicatedStorage.SharedUtils)

local function DefaultMultipliers()
	return {
		RageRegeneration = 1;
		RageEfficiency = 1;
	}
end

local function DefaultRaceInformation()
	return {
		Name = 'testRace',
		Variables = {
			BaseRageRegeneration = 5;
			ExceedingRaceTop = 20;
			ExceedingRageLifetime = 3;
		}
	}
end

local function DefaultSequenceData()
    return {
        HitCount = 0
    }
end

local function DefaultPlayerData()
    return {
        Weapon = false :: table?,
        WeaponSecondary = false :: table?,

        SequenceActive = false,
		SequenceQueue = {},
		
		Rage = 100,
		Multipliers = DefaultMultipliers(),
		Race = DefaultRaceInformation(),

        CurSequenceData = DefaultSequenceData()
    }
end

function CombatService:OnCharacterAdded(player, character)
    local playerData = self.Players[player]

    if not playerData.Weapon then
        return
    end

    self.Bridges.Combat.WeaponEquip:FireToAllExcept(player, player, playerData.Weapon.Name)
end

function CombatService:AddPlayer(player: Player)
    self.Players[player] = DefaultPlayerData()
    CombatShared:AddPlayer(player)

    -- placeholder
    -- self:EquipWeapon(player, "TestSword")

    if player.Character then
        self:OnCharacterAdded(player, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        self:OnCharacterAdded(player, player.Character)
    end)
end

function CombatService:Start()
    WeaponModels = self.Assets:WaitForChild("Models"):WaitForChild("Weapons")

    local bridges = self.Bridges.Combat

    bridges.GetPlayersWeapon:Connect(function(player)
        local allWeapons = {}

        for plr: Player, data in pairs(self.Players) do
            if not data.Weapon and not data.WeaponSecondary then
                continue
            end

            allWeapons[plr.UserId] = {
                Primary = data.Weapon and data.Weapon.Name,
                Secondary = data.WeaponSecondary and data.WeaponSecondary.Name
            }
        end

        bridges.GetPlayersWeapon:FireTo(player, allWeapons)
    end)

    bridges.NextSequence:Connect(function(player: Player, startTime: number)
        self:NextSequence(player, startTime)
    end)

    bridges.Hit:Connect(function(player: Player, target: Model, limb: BasePart, limbHitCF: CFrame, characterOrientation: CFrame, sequenceIndex: number)
        self:Hit(player, target, limb, limbHitCF, characterOrientation, sequenceIndex)
    end)

    for _, player in pairs(game.Players:GetPlayers()) do
        self:AddPlayer(player)
    end

    game.Players.PlayerAdded:Connect(function(player)
        self:AddPlayer(player)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        self.Players[player] = nil
    end)
end

function CombatService:UnequipWeapon(player: Player, isSecondary: boolean?, _noReplicate: boolean?)
    local playerData = self.Players[player]

    local weaponKeyvalue = isSecondary and "WeaponSecondary" or "Weapon"

    playerData[weaponKeyvalue] = nil

    if not _noReplicate then
		self.Bridges.Combat.WeaponUnequip:FireAll(player, isSecondary)
    end
    CombatShared:PlayerRemoveWeapon(player, isSecondary)
end

-- TODO: re-scramble weapon slots after both slots are occupied
function CombatService:EquipWeapon(player: Player, weaponName: string, isSecondary: boolean?, _noReplicate: boolean?)
    local playerData =  self.Players[player]

    -- if self.Players[player].Weapon then
    --     self.Players[player].Weapon.Model:Destroy()
    -- end
    -- if playerData.Weapon and playerData.WeaponSecondary then
    --     warn("weapon slots occupied")
    --     return
    -- end

    local weaponData = table.clone(CombatShared:GetWeaponData(weaponName))

    -- local weaponModel = WeaponModels[weaponData.Category][weaponName]:Clone()

    local weaponPlayerData = {
        Name = weaponName,
        -- Model = weaponModel,

        Data = weaponData,
    }

    if isSecondary then
        playerData.WeaponSecondary = weaponPlayerData

        if not _noReplicate then
            self.Bridges.Combat.WeaponEquip:FireAll(player, weaponName, true)
        end

        CombatShared:PlayerSetWeapon(player, weaponName, true)
    else
        playerData.Weapon = weaponPlayerData

        if not _noReplicate then
			self.Bridges.Combat.WeaponEquip:FireAll(player, weaponName)
        end

        CombatShared:PlayerSetWeapon(player, weaponName)
    end

    print("weapon equipped")
end

function CombatService:NextSequence(player: Player, startTime: number)
    local dt = startTime and (workspace:GetServerTimeNow() - startTime) or 0

    if dt > 0.45 then
        warn("delta compensation too high")
        dt = 0
    end

    local playerData = self.Players[player]

    if playerData.SequenceActive then
        warn("sequence active. sent to queue")
        table.insert(playerData.SequenceQueue, true)
        self.Bridges.Combat.SyncSequence:FireTo(player, CombatShared:GetCurrentSequence(player))
        return
    end

    local curSequence = CombatShared:GetToNextSequenceCombo(player)
    playerData.SequenceActive = true

    playerData.CurSequenceData = DefaultSequenceData()

    local attackSequence = CombatShared:GetAttackSequence(player, curSequence)

    task.wait(attackSequence.AnimationLength - dt)

    playerData.SequenceActive = false
    -- playerData.CurSequenceData = false

    if playerData.SequenceQueue[1] then
        table.remove(playerData.SequenceQueue, 1)
        self:NextSequence(player)
    end
end

function CombatService:Hit(player: Player, target: Model, limb: BasePart, limbHitCF: CFrame, characterOrientation: CFrame, sequenceIndex: number)
    local playerData = self.Players[player]

    -- NaN
    if sequenceIndex ~= sequenceIndex then
        return
    end

    local combatWeapon = CombatShared:GetCombatWeapon(player)
    if combatWeapon.LastSequenceCombo ~= sequenceIndex then
        warn("illegal sequence index, expected "..tostring(combatWeapon.LastSequenceCombo).." got "..tostring(sequenceIndex))
        return
    end

    local attackSequence = CombatShared:GetAttackSequence(player, sequenceIndex)

    if not attackSequence then
        warn("invalid sequence")
        return
    end

    local hitCap = attackSequence.HitCap or 1
    if playerData.CurSequenceData.HitCount >= hitCap then
        warn("attempted to hit more than allowed hit cap")
        return
    end

    if not self:ValidateHit(player, target, limb, limbHitCF, characterOrientation, attackSequence) then
        warn("invalid hit")
        return
    end

    local NPCService = require(script.Parent.NPCService)

    playerData.CurSequenceData.HitCount += 1

    local damage = attackSequence.Damage

    -- if dual wielding: multiplies damage by 1.5x
    -- do more with this in the future
    if playerData.Weapon and playerData.WeaponSecondary then
        damage *= 1.5
    end

    NPCService:DealDamage(target, player, damage)
end

function CombatService:ValidateHit(player: Player, target: Model, limb: BasePart, limbHitCF: CFrame, characterOrientation: CFrame, attackSequence: table): boolean
    if not target:IsDescendantOf(workspace.NPCs) then
        return false
    end

    if not limb:IsDescendantOf(target) then
        return false
    end

    if (limb.Position - limbHitCF.Position).Magnitude > 15 then
        print((limb.Position - limbHitCF.Position).Magnitude)
        return false
    end

    local hitbox = CombatShared:GetHitboxData(attackSequence.Hitbox)

    local character: Model = player.Character

    -- TODO: this need to be synced better with different hitbox types like box and attach
    -- TODO: make this use CombatHitbox.lua rather than recreating it
    -- give some leniency
    local size = hitbox.Size * 3.5
    local zone = {
        CFrame = CFrame.new(character.HumanoidRootPart.Position) * characterOrientation,
        Size = size
    }

    if hitbox.Attach then
        zone.CFrame = ( CFrame.new(character[hitbox.Attach].Position) * characterOrientation ) * (hitbox.Offset or Vector3.new())
    end

    if not SharedUtils.IsInZone(limbHitCF.Position, zone) then
        print("not in zone")
        return false
    end

    return true
end

function CombatService:AddRage(player: Player)
	local playerData = self.Players[player]
	
	local incrementValue = playerData.Multipliers.RageRegeneration * playerData.Race.Variables.BaseRageRegeneration
	local rageAmount = playerData.Rage + incrementValue
	local exceedingAmount = math.clamp(rageAmount - 100,0,playerData.Race.Variables.ExceedingRageTop + playerData.Multipliers.ExceedingRage)
	
	playerData.Rage = rageAmount - exceedingAmount
	playerData.ExceedingRage = exceedingAmount
	
	if exceedingAmount >= 1 then
		if playerData.ExceedingRageLifetime then 
			task.cancel(playerData.ExceedingRageLifetime)
		end
		playerData.ExceedingRageLifetime = task.delay(playerData.Race.Variables.ExceedingRageLifetime,function()
			playerData.ExceedingRage = 0;
		end)
	end
end

function CombatService:RemoveRage(player: Player, Cost: number)
	local playerData = self.Players[player]
	
	if playerData.Rage < Cost then return false end
	local leftoverCost = Cost - playerData.ExceedingRage
	if leftoverCost > 0 then
		playerData.Rage -= leftoverCost
		playerData.ExceedingRage = 0
	else 
		playerData.ExceedingRage -= Cost
	end

	return true,playerData.Rage + playerData.ExceedingRage
end

return CombatService
