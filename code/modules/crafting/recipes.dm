
/datum/crafting_recipe
	var/name = ""                   // in-game display name
	var/reqs[] = list()             // type paths of items consumed associated with how many are needed
	var/result                      // type path of item resulting from this craft
	var/tools[] = list()            // type paths of items needed but not consumed
	var/time = 30                   // time in deciseconds
	var/parts[] = list()            // type paths of items that will be placed in the result
	var/chem_catalysts[] = list()   // like tools but for reagents

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

/datum/crafting_recipe/wirerod
	name = "Wirerod"
	result = /obj/item/weapon/wirerod
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/rods = 1)
	time = 20

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/weapon/twohanded/spear
	reqs = list(/obj/item/weapon/wirerod = 1,
				/obj/item/weapon/shard = 1)
	time = 40

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/weapon/melee/cattleprod
	reqs = list(/obj/item/weapon/wirerod = 1,
				/obj/item/weapon/wirecutters = 1)
	time = 40

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/weapon/legcuffs/bola
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20 // 15 faster than crafting them by hand!

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

//   CROSSBOW craft

/datum/crafting_recipe/crossbowframe1
	name = "Crossbow(1 stage)"
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = /obj/item/weapon/crossbowframe1
	time = 35

/datum/crafting_recipe/crossbowframe2
	name = "Crossbow(2 stage)"
	reqs = list(/obj/item/weapon/crossbowframe1 = 1,
				/obj/item/stack/rods = 3)
	result = /obj/item/weapon/crossbowframe2
	time = 35

/datum/crafting_recipe/crossbowframe3
	name = "Crossbow(3 stage)"
	reqs = list(/obj/item/weapon/crossbowframe2 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/crossbowframe3
	time = 35

/datum/crafting_recipe/crossbowframe4
	name = "Crossbow(4 stage)"
	reqs = list(/obj/item/weapon/crossbowframe3 = 1,
				/obj/item/stack/cable_coil = 5)
	result = /obj/item/weapon/crossbowframe4
	time = 35

/datum/crafting_recipe/crossbowframe5
	name = "Crossbow(5 stage)"
	reqs = list(/obj/item/weapon/crossbowframe4 = 1,
				/obj/item/stack/sheet/mineral/plastic = 3)
	result = /obj/item/weapon/crossbowframe5
	time = 40

/datum/crafting_recipe/crossbowframe6
	name = "Crossbow(6 stage)"
	reqs = list(/obj/item/weapon/crossbowframe5 = 1,
				/obj/item/stack/cable_coil = 5)
	result = /obj/item/weapon/crossbowframe6
	time = 40

/datum/crafting_recipe/crossbow
	name = "Combat crossbow"
	reqs = list(/obj/item/weapon/crossbowframe6 = 1)
	tools = list(/obj/item/weapon/screwdriver)
	result = /obj/item/weapon/crossbow
	time = 45

//   PNEUMO-GUN craft

/datum/crafting_recipe/cannonframe1
	name = "Pneumo-gun(1 stage)"
	reqs = list(/obj/item/stack/sheet/metal = 10)
	result = /obj/item/weapon/cannonframe1
	time = 35

/datum/crafting_recipe/cannonframe2
	name = "Pneumo-gun(2 stage)"
	reqs = list(/obj/item/weapon/cannonframe1 = 1,
				/obj/item/pipe = 1)
	result = /obj/item/weapon/cannonframe2
	time = 35

/datum/crafting_recipe/cannonframe3
	name = "Pneumo-gun(3 stage)"
	reqs = list(/obj/item/weapon/cannonframe2 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/cannonframe3
	time = 45

/datum/crafting_recipe/cannonframe4
	name = "Pneumo-gun(4 stage)"
	reqs = list(/obj/item/weapon/cannonframe3 = 1,
				/obj/item/stack/sheet/metal = 5)
	result = /obj/item/weapon/cannonframe4
	time = 35

/datum/crafting_recipe/cannonframe5
	name = "Pneumo-gun(5 stage)"
	reqs = list(/obj/item/weapon/cannonframe4 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/cannonframe5
	time = 40

/datum/crafting_recipe/cannonframe6
	name = "Pneumo-gun(6 stage)"
	reqs = list(/obj/item/weapon/cannonframe5 = 1,
				/obj/item/device/transfer_valve = 1)
	result = /obj/item/weapon/cannonframe6
	time = 40

/datum/crafting_recipe/pneumatic
	name = "Pneumatic gun"
	reqs = list(/obj/item/weapon/cannonframe6 = 1)
	tools = list(/obj/item/weapon/weldingtool)
	result = /obj/item/weapon/storage/pneumatic
	time = 45