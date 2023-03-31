return {
	Data = {
		RequestSaveFilesPreview = "RequestSaveFilesPreview",
	},

	CharacterSelection = {
		Create = "CreateCharacter",
		CharacterCreation = "CharacterCreation",
		EnterWorld = "EnterWorld"
	},

	Quest = {
		Abandon = "QuestAbandon",
		Completed = "QuestCompleted",

		LineRegister = "QuestLineRegister",
		SoloRegister = "SoloQuestRegister",

		SoloRefresh = "SoloQuestRefresh",

		Start = "QuestStart",
		Track = "QuestTrack",
		Untrack = "QuestUntrack",

		Update = "QuestUpdate",
		DataLoad = "QuestsDataLoad",
	},

	QuestGiver = {
		Accept = "QuestGiveAccept",
	},

	Inventory = {
		ItemAdded = "InventoryItemAdded",
		ItemsAdded = "InventoryMultipleItemsAdded",
		ItemsAmountAdded = "InventorySingleItemAddedMultipleTimes", -- does as it says
		ItemStacked = "InventoryItemStacked",
		ItemRemoving = "InventoryItemRemoving",
		CurrencyAdded = "InventoryCurrencyAdded",
		CurrencySubtracted = "InventoryCurrencySubtracted",
		Replicate = "InventoryReplicate",
		Discard = "InventoryDiscard",
		UnequipBag = "InventoryUnequipBag",
		SwitchInventorySlots = "InventorySwitchInventorySlots",
		EquipBag = "InventoryEquipBag",

		ActionItem = "InventoryActionUse",
	},

	Loot = {
		Take = "TakeLoot",
		AutoTake = "AutoTakeLoot",
		NewSpot = "NewLootSpot",
		RemoveSpot = "RemoveLootSpot",
		RequestSpots = "RequestLootSpots",
	},

	AutoLoot = {
		Loot = "AutoLoot",
		Log = "AutoLootLog",
		ConfigChange = "AutoLootConfigChange",
		ConfigChangeMult = "AutoLootConfigChangeMult",
		DataLoad = "AutoLootConfigDataLoad"
	},

	Merchant = {
		Purchase = "MerchantPurchase",
		Sell = "MerchantSell",
		BuybackInsert = "MerchantBuybackInsert",
		BuybackRemove = "MerchantBuybackRemove",
		BuybackReduce = "MerchantBuybackReduce",
		RegisterMerchant = "MerchantRegister",
		GetAllMerchants = "MerchantGetAll",
	},

	Equipment = {
		Replicate = "EquipmentReplicate",
		Add = "EquipmentAdd",

		Equip = "EquipmentEquip",
		Unequip = "EquipmentUnequip",

		ToggleHideHelmet = "EquipmentHideToggle",
	},

	Mount = {
		MountAdded = "MountMountAdded",
		Replicate = "MountReplicate",
		MountEquip = "MountMountEquip",
		MountUnequip = "MountMountUnequip",
		MountAssignHotbar = "MountMountAssignHotbar",

		MountEquipParticle = "MountEquipParticle"
	},

	Experience = {
		Incremented = "Experience_Incremented",
		DataLoad = "Experience_DataLoad"
	},

	NetworkId = {
		New = "NewNetworkId",
		Remove = "RemoveNetworkId",

		RequesAllIds = "RequesAllIds",
		AllIdsReceived = "AllIdsReceived",
	},

	NPCs = {
		AddNPC = "AddNPC",
		TakeDamage = "NPCTakeDamage"
	},

	Combat = {
		-- AddEffect = "AddEffect",
		-- Attack = "Attack",
		-- EquipSkill = "EquipSkill",
		-- ActivateSkill = "ActivateSkill"
		GetPlayersWeapon = "CombatGetPlayersWeapon",

		NextSequence = "NextSequence",
		SyncSequence = "SyncSequence",

		Hit = "CombatHit",
		RageUpdated = "RageUpdated",

		WeaponEquip = "CombatWeaponEquip",
		WeaponUnequip = "CombatWeaponUnequip",
	}
}
