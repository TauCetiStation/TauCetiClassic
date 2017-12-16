
/datum/crafting_recipe
	var/name = ""                   // in-game display name
	var/reqs[] = list()             // type paths of items consumed associated with how many are needed
	var/result                      // type path of item resulting from this craft
	var/tools[] = list()            // type paths of items needed but not consumed
	var/time = 30                   // time in deciseconds
	var/parts[] = list()            // type paths of items that will be placed in the result
	var/chem_catalysts[] = list()   // like tools but for reagents
	var/category = CAT_NONE         // where it shows up in the crafting UI
	var/subcategory = CAT_NONE

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/weapon/grenade/iedcasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/device/assembly/igniter = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans = 1)
	parts = list(/obj/item/weapon/reagent_containers/food/drinks/cans = 1)
	time = 15
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/wirerod
	name = "Wirerod"
	result = /obj/item/weapon/wirerod
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/rods = 1)
	time = 20
	category = CAT_ASSEMBLY

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/weapon/twohanded/spear
	reqs = list(/obj/item/weapon/wirerod = 1,
				/obj/item/weapon/shard = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/weapon/melee/cattleprod
	reqs = list(/obj/item/weapon/wirerod = 1,
				/obj/item/weapon/wirecutters = 1)
	time = 40
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/weapon/legcuffs/bola
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20//15 faster than crafting them by hand!
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/toysword
	name = "Toy Sword"
	reqs = list(/obj/item/weapon/light/bulb = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/stack/sheet/mineral/plastic = 4)
	result = /obj/item/toy/sword
	category = CAT_MISC
