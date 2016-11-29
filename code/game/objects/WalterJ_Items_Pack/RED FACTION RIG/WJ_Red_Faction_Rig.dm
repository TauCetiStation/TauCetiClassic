/obj/item/clothing/head/helmet/space/rig/RF_mining
	icon = 'code/game/objects/WalterJ_Items_Pack/RED FACTION RIG/WJ_Red_Faction_Rig.dmi'
	icon_custom = 'code/game/objects/WalterJ_Items_Pack/RED FACTION RIG/WJ_Red_Faction_Rig.dmi'
	name = "Red mining helmet"
	desc = "A special mining helmet designed for work in a hazardous, low pressure environment."

	icon_state = "rig0-RedMiner"
	item_state = "rig0-RedMiner"
	item_color = "RedMiner"

	armor = list(melee = 40, bullet = 10, laser = 10,energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/RF_mining
	icon = 'code/game/objects/WalterJ_Items_Pack/RED FACTION RIG/WJ_Red_Faction_Rig.dmi'
	icon_custom = 'code/game/objects/WalterJ_Items_Pack/RED FACTION RIG/WJ_Red_Faction_Rig.dmi'
	name = "Red mining hardsuit"
	desc = "A special suit that protects against hazardous, has reinforced plating."

	icon_state = "rig-RedMiner"
	item_state = "rig-RedMiner"
	item_color = "RedMiner"

	armor = list(melee = 40, bullet = 11, laser = 10,energy = 5, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)
