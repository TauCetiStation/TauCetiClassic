
/obj/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start."
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything


// creates a new object and deletes itself
/obj/random/New()
	..()
	if (!prob(spawn_nothing_percentage))
		spawn_item()
	qdel(src)


// this function should return a specific item to spawn
/obj/random/proc/item_to_spawn()
	return 0


// creates the random item
/obj/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return (new build_path(src.loc))
//GUNS RANDOM
/obj/random/handgun
	name = "Random Handgun"
	desc = "This is a random security sidearm."
	icon = 'icons/obj/gun.dmi'
	icon_state = "sigi250"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/sigi,\
					prob(1);/obj/item/weapon/gun/projectile/sigi/spec)

/obj/random/projectile
	name = "Random Projectile Weapon"
	desc = "This is a random security weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/shotgun,\
					prob(1);/obj/item/weapon/gun/projectile/shotgun/combat)
//TOOLS RANDOM
/obj/random/tool
	name = "Random Tool"
	desc = "This is a random tool."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
	item_to_spawn()
		return pick(/obj/item/weapon/screwdriver,\
					/obj/item/weapon/wirecutters,\
					/obj/item/weapon/weldingtool,\
					/obj/item/weapon/crowbar,\
					/obj/item/weapon/wrench,\
					/obj/item/device/flashlight)


/obj/random/technology_scanner
	name = "Random Scanner"
	desc = "This is a random technology scanner."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_to_spawn()
		return pick(prob(5);/obj/item/device/t_scanner,\
					prob(2);/obj/item/device/radio,\
					prob(5);/obj/item/device/analyzer)


/obj/random/powercell
	name = "Random Powercell"
	desc = "This is a random powercell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_to_spawn()
		return pick(prob(10);/obj/item/weapon/stock_parts/cell/crap,\
					prob(40);/obj/item/weapon/stock_parts/cell,\
					prob(40);/obj/item/weapon/stock_parts/cell/high,\
					prob(9);/obj/item/weapon/stock_parts/cell/super,\
					prob(1);/obj/item/weapon/stock_parts/cell/hyper)


/obj/random/bomb_supply
	name = "Bomb Supply"
	desc = "This is a random bomb supply."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"
	item_to_spawn()
		return pick(/obj/item/device/assembly/igniter,\
					/obj/item/device/assembly/prox_sensor,\
					/obj/item/device/assembly/signaler,\
					/obj/item/device/multitool)


/obj/random/toolbox
	name = "Random Toolbox"
	desc = "This is a random toolbox."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/storage/toolbox/mechanical,\
					prob(2);/obj/item/weapon/storage/toolbox/electrical,\
					prob(1);/obj/item/weapon/storage/toolbox/emergency)


/obj/random/tech_supply
	name = "Random Tech Supply"
	desc = "This is a random piece of technology supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	spawn_nothing_percentage = 50
	item_to_spawn()
		return pick(prob(3);/obj/random/powercell,\
					prob(2);/obj/random/technology_scanner,\
					prob(1);/obj/item/weapon/packageWrap,\
					prob(2);/obj/random/bomb_supply,\
					prob(1);/obj/item/weapon/extinguisher,\
					prob(1);/obj/item/clothing/gloves/fyellow,\
					prob(3);/obj/item/weapon/cable_coil,\
					prob(2);/obj/random/toolbox,\
					prob(2);/obj/item/weapon/storage/belt/utility,\
					prob(5);/obj/random/tool)
/obj/random/tech_supply/guaranteed
	spawn_nothing_percentage = 0

// FOOD RANDOM

/obj/random/food_trash
	name = "Random Trash Pile"
	desc = "This is a random piece of trash."
	icon = 'icons/obj/trash.dmi'
	icon_state = "sosjerky"
	item_to_spawn()
		return pick(subtypesof(/obj/item/trash))

/obj/random/drink_can
	name = "Random Drink Can Pile"
	desc = "This is a random drink can."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/cans))

/obj/random/food_snack
	name = "Random Snack Food Pile"
	desc = "This is a random snack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
	item_to_spawn()
		return pick(prob(2);/obj/item/weapon/reagent_containers/food/snacks/candy,\
					prob(2);/obj/item/weapon/reagent_containers/food/drinks/dry_ramen,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/chips,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/sosjerky,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/no_raisin,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie,\
					prob(2);/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers)

/obj/random/drink_bottle
	name = "Random Snack Food Pile"
	desc = "This is a random snack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "grapesoda"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/bottle))

/obj/random/food_without_garbage
	name = "Random Food Supply with Garbage"
	desc = "This is a random food for junkyard."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"
	item_to_spawn()
		return pick(prob(5);/obj/random/food_snack,\
					prob(1);/obj/random/drink_bottle,\
					prob(2);/obj/random/drink_can)

/obj/random/food_with_garbage
	name = "Random Food Supply with Garbage"
	desc = "This is a random food for junkyard."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"
	item_to_spawn()
		return pick(prob(5);/obj/random/food_snack,\
					prob(1);/obj/random/drink_bottle,\
					prob(2);/obj/random/drink_can,\
					prob(16);/obj/random/food_trash)
//MEDICAL RANDOM
/obj/random/pills
	name = "Random Pill Bottle"
	desc = "This is a random pill bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill_canister"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/storage/pill_bottle/))

/obj/random/medkit
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
	item_to_spawn()
		return pick(prob(5);/obj/item/weapon/storage/firstaid/regular,\
					prob(3);/obj/item/weapon/storage/firstaid/fire,\
					prob(3);/obj/item/weapon/storage/firstaid/toxin,\
					prob(3);/obj/item/weapon/storage/firstaid/o2,\
					prob(2);/obj/item/weapon/storage/firstaid/adv,\
					prob(1);/obj/item/weapon/storage/firstaid/tactical)

/obj/random/syringe
	name = "Random Syringe"
	desc = "This is a random syringe."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
	item_to_spawn()
		return pick(prob(2);/obj/item/weapon/reagent_containers/syringe/inaprovaline,\
					prob(2);/obj/item/weapon/reagent_containers/syringe/antitoxin,\
					prob(2);/obj/item/weapon/reagent_containers/syringe/antiviral,\
					prob(10);/obj/item/weapon/reagent_containers/syringe)

/obj/random/medical_tool
	name = "Random Surgery Equipment"
	desc = "This is a random medical surgery equipment."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	item_to_spawn()
		return pick(prob(1);/obj/item/weapon/circular_saw,\
					prob(1);/obj/item/weapon/scalpel,\
					prob(1);/obj/item/weapon/bonesetter,\
					prob(1);/obj/item/weapon/FixOVein,\
					prob(1);/obj/item/weapon/bonegel,\
					prob(1);/obj/item/weapon/cautery,\
					prob(1);/obj/item/weapon/surgicaldrill,\
					prob(1);/obj/item/weapon/retractor,\
					prob(1);/obj/item/weapon/tank/anesthetic,\
					prob(1);/obj/item/clothing/mask/breath/medical,\
					prob(1);/obj/item/weapon/reagent_containers/spray/cleaner,\
					prob(1);/obj/item/weapon/storage/box/gloves,\
					prob(1);/obj/item/weapon/storage/box/masks)

/obj/random/dna_injector
	name = "Random DNA injector"
	desc = "This is a random dna injector syringe."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/dnainjector))

/obj/random/medical_single_item
	name = "Random small medical item"
	desc = "This is a random small medical item."
	icon = 'icons/obj/items.dmi'
	icon_state = "ointment"
	item_to_spawn()
		return pick(subtypesof(/obj/item/stack/medical) - /obj/item/stack/medical/advanced)

/obj/random/chemical_bottle
	name = "Random Chemical bottle"
	desc = "This is a random Chemical bottle."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	item_to_spawn()
		return pick(prob(5);/obj/item/weapon/reagent_containers/glass/bottle/ammonia,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/diethylamine,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/toxin,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/stoxin,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,\
					prob(3);/obj/item/weapon/reagent_containers/glass/bottle/mutagen,\
					prob(3);/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate,\
					prob(1);/obj/item/weapon/reagent_containers/glass/bottle/random)

/obj/random/medical_supply
	name = "Random medical supply"
	desc = "This is a random medical supply."
	icon = 'icons/obj/items.dmi'
	icon_state = "traumakit"
	item_to_spawn()
		return pick(prob(20);/obj/random/medical_single_item,\
					prob(15);/obj/random/syringe,\
					prob(10);/obj/random/chemical_bottle,\
					prob(8);/obj/random/medkit,\
					prob(8);/obj/random/medical_tool,\
					prob(6);/obj/random/pills,\
					prob(1);/obj/random/dna_injector)