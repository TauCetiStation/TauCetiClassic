
/datum/crafting_recipe
	var/name = ""                   // in-game display name
	var/reqs[] = list()             // type paths of items consumed associated with how many are needed
	var/result                      // type path of item resulting from this craft
	var/tools[] = list()            // type paths of items needed but not consumed
	var/time = 30                   // time in deciseconds
	var/parts[] = list()            // type paths of items that will be placed in the result
	var/chem_catalysts[] = list()   // like tools but for reagents
	var/required_proficiency
	var/list/blacklist = list()		///type paths of items explicitly not allowed as an ingredient

/datum/crafting_recipe/proc/on_craft_completion(mob/user, atom/result)
	return

/datum/crafting_recipe/crossbow_bolt
	name = "Crossbow Bolt"
	result = /obj/item/weapon/arrow
	reqs = list(/obj/item/stack/rods = 1)
	tools = list(/obj/item/weapon/wirecutters)
	time = 1
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_NONE)


/datum/crafting_recipe/can_grenade_igniter
	name = "Can Grenade (igniter)"
	result = /obj/item/weapon/grenade/cancasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/device/assembly/igniter = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans = 1)
	parts = list(/obj/item/weapon/reagent_containers/food/drinks/cans = 1,
				/obj/item/stack/cable_coil = 1)
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/can_grenade_rag
	name = "Can Grenade (rag)"
	result = /obj/item/weapon/grenade/cancasing/rag
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/stack/medical/bruise_pack/rags = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans = 1)
	parts = list(/obj/item/weapon/reagent_containers/food/drinks/cans = 1,
				/obj/item/stack/cable_coil = 1)
	time = 30
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)

/datum/crafting_recipe/wirerod
	name = "Wirerod"
	result = /obj/item/weapon/wirerod
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/rods = 1)
	time = 20
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)
/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/weapon/spear
	reqs = list(/obj/item/weapon/wirerod = 1,
				/obj/item/weapon/shard = 1)
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)
/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/weapon/melee/cattleprod
	reqs = list(/obj/item/weapon/wirerod = 1,
				/obj/item/weapon/wirecutters = 1)
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/weapon/legcuffs/bola
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20 // 15 faster than crafting them by hand!
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/toysword
	name = "Toy Sword"
	reqs = list(/obj/item/weapon/light/bulb = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/mineral/plastic = 4)
	result = /obj/item/toy/sword

/datum/crafting_recipe/cable_restraints
	name = "Cable Restraints"
	reqs = list(/obj/item/stack/cable_coil = 15)
	result = /obj/item/weapon/handcuffs/cable
	parts = list(/obj/item/stack/cable_coil = 1)
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)

/datum/crafting_recipe/noose
	name = "Noose"
	reqs = list(/obj/item/stack/cable_coil = 25)
	result = /obj/item/weapon/noose
	parts = list(/obj/item/stack/cable_coil = 1)

//   SHIELD craft

/datum/crafting_recipe/bucklerframe1
	name = "Shield(1 stage)"
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = /obj/item/weapon/bucklerframe1
	time = 25

/datum/crafting_recipe/bucklerframe2
	name = "Shield(2 stage)"
	reqs = list(/obj/item/weapon/bucklerframe1 = 1)
	tools = list(/obj/item/weapon/wirecutters)
	result = /obj/item/weapon/bucklerframe2
	time = 35

/datum/crafting_recipe/bucklerframe3
	name = "Shield(3 stage)"
	reqs = list(/obj/item/weapon/bucklerframe2 = 1,
				/obj/item/weapon/handcuffs/cable = 1)
	result = /obj/item/weapon/bucklerframe3
	time = 35

/datum/crafting_recipe/bucklerframe4
	name = "Shield(4 stage)"
	reqs = list(/obj/item/weapon/bucklerframe3 = 1,
				/obj/item/stack/sheet/plasteel = 4)
	result = /obj/item/weapon/bucklerframe4
	time = 35

/datum/crafting_recipe/buckler
	name = "Wooden shield"
	reqs = list(/obj/item/weapon/bucklerframe4 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/shield/buckler
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)

//   CROSSBOW craft

/datum/crafting_recipe/crossbowframe1
	name = "Crossbow(1 stage)"
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = /obj/item/weapon/crossbowframe1
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/crossbowframe2
	name = "Crossbow(2 stage)"
	reqs = list(/obj/item/weapon/crossbowframe1 = 1,
				/obj/item/stack/rods = 3)
	result = /obj/item/weapon/crossbowframe2
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)
/datum/crafting_recipe/crossbowframe3
	name = "Crossbow(3 stage)"
	reqs = list(/obj/item/weapon/crossbowframe2 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/crossbowframe3
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/crossbowframe4
	name = "Crossbow(4 stage)"
	reqs = list(/obj/item/weapon/crossbowframe3 = 1,
				/obj/item/stack/cable_coil = 5)
	result = /obj/item/weapon/crossbowframe4
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/crossbowframe5
	name = "Crossbow(5 stage)"
	reqs = list(/obj/item/weapon/crossbowframe4 = 1,
				/obj/item/stack/sheet/mineral/plastic = 3)
	result = /obj/item/weapon/crossbowframe5
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)


/datum/crafting_recipe/crossbowframe6
	name = "Crossbow(6 stage)"
	reqs = list(/obj/item/weapon/crossbowframe5 = 1,
				/obj/item/stack/cable_coil = 5)
	result = /obj/item/weapon/crossbowframe6
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/datum/crafting_recipe/crossbow
	name = "Combat crossbow"
	reqs = list(/obj/item/weapon/crossbowframe6 = 1)
	tools = list(/obj/item/weapon/screwdriver)
	result = /obj/item/weapon/crossbow
	time = 45
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

//   PNEUMO-GUN craft

/datum/crafting_recipe/cannonframe1
	name = "Pneumo-gun(1 stage)"
	reqs = list(/obj/item/stack/sheet/metal = 10)
	result = /obj/item/weapon/cannonframe1
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/cannonframe2
	name = "Pneumo-gun(2 stage)"
	reqs = list(/obj/item/weapon/cannonframe1 = 1,
				/obj/item/pipe = 1)
	result = /obj/item/weapon/cannonframe2
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/cannonframe3
	name = "Pneumo-gun(3 stage)"
	reqs = list(/obj/item/weapon/cannonframe2 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/cannonframe3
	time = 45
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/cannonframe4
	name = "Pneumo-gun(4 stage)"
	reqs = list(/obj/item/weapon/cannonframe3 = 1,
				/obj/item/stack/sheet/metal = 5)
	result = /obj/item/weapon/cannonframe4
	time = 35
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/cannonframe5
	name = "Pneumo-gun(5 stage)"
	reqs = list(/obj/item/weapon/cannonframe4 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/cannonframe5
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/cannonframe6
	name = "Pneumo-gun(6 stage)"
	reqs = list(/obj/item/weapon/cannonframe5 = 1,
				/obj/item/device/transfer_valve = 1)
	result = /obj/item/weapon/cannonframe6
	time = 40
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/pneumatic
	name = "Pneumatic gun"
	reqs = list(/obj/item/weapon/cannonframe6 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/storage/pneumatic
	time = 45
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)


/datum/crafting_recipe/durathread
	name = "durathread suit"
	reqs = list(/obj/item/weapon/grown/durathread = 3,
	/obj/item/stack/medical/bruise_pack/rags = 5,
	/obj/item/stack/cable_coil = 15)
	tools = list(/obj/item/weapon/wirecutters = 1)
	result = /obj/item/clothing/under/durathread
	time = 30
	required_proficiency = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/datum/crafting_recipe/durathread/armor
	name = "durathread vest"
	reqs = list(/obj/item/weapon/grown/durathread = 5,
	/obj/item/stack/medical/bruise_pack/rags = 5,
	/obj/item/stack/cable_coil = 15)
	result = /obj/item/clothing/suit/armor/vest/durathread
	time = 60

/datum/crafting_recipe/durathread/coat
	name = "durathread coat"
	reqs = list(/obj/item/weapon/grown/durathread = 20,
	/obj/item/stack/medical/bruise_pack/rags = 10,
	/obj/item/stack/cable_coil = 30)
	time = 100
	result = /obj/item/clothing/suit/armor/duracoat

/datum/crafting_recipe/durathread/helm
	name = "durathread helmet"
	reqs = list(/obj/item/weapon/grown/durathread = 10,
	/obj/item/stack/sheet/metal = 10,
	/obj/item/stack/cable_coil = 15)
	result = /obj/item/clothing/head/helmet/durathread
	time = 60


/datum/crafting_recipe/armband_red
	name = "Armband red"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband
	time = 30

/datum/crafting_recipe/armband_cargo
	name = "Armband cargo"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband/cargo
	time = 30

/datum/crafting_recipe/armband_engine
	name = "Armband engine"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband/engine
	time = 30

/datum/crafting_recipe/armband_science
	name = "Armband science"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband/science
	time = 30

/datum/crafting_recipe/armband_hydro
	name = "Armband hydro"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband/hydro
	time = 30

/datum/crafting_recipe/armband_med
	name = "Armband med"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband/med
	time = 30

/datum/crafting_recipe/armband_medgreen
	name = "Armband medgreen"
	reqs = list(/obj/item/stack/sheet/cloth = 1)
	tools = list(/obj/item/toy/crayon/spraycan)
	result = /obj/item/clothing/accessory/armband/medgreen
	time = 30

/datum/crafting_recipe/makeshift_shiv
	name = "Glass shiv"
	reqs = list(/obj/item/stack/sheet/cloth = 1,
				/obj/item/weapon/shard = 1)
	blacklist = list(/obj/item/weapon/shard/phoron)
	result = /obj/item/weapon/kitchenknife/makeshift_shiv
	time = 10

/datum/crafting_recipe/makeshift_shiv_phoron
	name = "Phoron glass shiv"
	reqs = list(/obj/item/stack/sheet/cloth = 1,
				/obj/item/weapon/shard/phoron = 1)
	result = /obj/item/weapon/kitchenknife/makeshift_shiv/phoron
	time = 10

