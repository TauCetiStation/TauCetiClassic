//TOOLS RANDOM
/obj/random/tools/tool
	name = "Random Tool"
	desc = "This is a random tool."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
/obj/random/tools/tool/item_to_spawn()
		return pick(\
						/obj/item/weapon/screwdriver,\
						/obj/item/weapon/wirecutters,\
						/obj/item/weapon/weldingtool,\
						/obj/item/weapon/crowbar,\
						/obj/item/weapon/wrench,\
						/obj/item/device/flashlight\
					)


/obj/random/tools/technology_scanner
	name = "Random Scanner"
	desc = "This is a random technology scanner."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
/obj/random/tools/technology_scanner/item_to_spawn()
		return pick(\
						prob(5);/obj/item/device/t_scanner,\
						prob(2);/obj/item/device/radio,\
						prob(5);/obj/item/device/analyzer\
					)


/obj/random/tools/powercell
	name = "Random Powercell"
	desc = "This is a random powercell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
/obj/random/tools/powercell/item_to_spawn()
		return pick(\
						prob(10);/obj/item/weapon/stock_parts/cell/crap,\
						prob(40);/obj/item/weapon/stock_parts/cell,\
						prob(40);/obj/item/weapon/stock_parts/cell/high,\
						prob(9);/obj/item/weapon/stock_parts/cell/super,\
						prob(1);/obj/item/weapon/stock_parts/cell/hyper\
					)


/obj/random/tools/bomb_supply
	name = "Bomb Supply"
	desc = "This is a random bomb supply."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"
/obj/random/tools/bomb_supply/item_to_spawn()
		return pick(\
						/obj/item/device/assembly/igniter,\
						/obj/item/device/assembly/prox_sensor,\
						/obj/item/device/assembly/signaler,\
						/obj/item/device/multitool\
					)


/obj/random/tools/toolbox
	name = "Random Toolbox"
	desc = "This is a random toolbox."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
/obj/random/tools/toolbox/item_to_spawn()
		return pick(\
						prob(3);/obj/item/weapon/storage/toolbox/mechanical,\
						prob(2);/obj/item/weapon/storage/toolbox/electrical,\
						prob(1);/obj/item/weapon/storage/toolbox/emergency\
					)


/obj/random/tools/tech_supply
	name = "Random Tech Supply"
	desc = "This is a random piece of technology supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	spawn_nothing_percentage = 50
/obj/random/tools/tech_supply/item_to_spawn()
		return pick(\
						prob(3);/obj/random/tools/powercell,\
						prob(2);/obj/random/tools/technology_scanner,\
						prob(1);/obj/item/weapon/packageWrap,\
						prob(2);/obj/random/tools/bomb_supply,\
						prob(1);/obj/item/weapon/reagent_containers/spray/extinguisher,\
						prob(1);/obj/item/clothing/gloves/fyellow,\
						prob(3);/obj/item/stack/cable_coil/random,\
						prob(2);/obj/random/tools/toolbox,\
						prob(2);/obj/item/weapon/storage/belt/utility,\
						prob(5);/obj/random/tools/tool\
					)
/obj/random/tools/tech_supply/guaranteed
	spawn_nothing_percentage = 0
