
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

/datum/crafting_recipe/cable_restraints
	name = "Cable Restraints"
	reqs = list(/obj/item/stack/cable_coil = 15)
	result = /obj/item/weapon/handcuffs/cable
	category = CAT_MISC

/datum/crafting_recipe/sushimat
	name = "Sushi Mat"
	result = /obj/item/weapon/kitchen/sushimat
	time = 10
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/stack/cable_coil = 2)
	category = CAT_MISC

/datum/crafting_recipe/sushi_Ebi
	name = "Ebi Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Ebi
	category = CAT_FOOD

/datum/crafting_recipe/Ebi_maki
	name = "Ebi Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Ebi_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Ikura
	name = "Ikura Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/fish_eggs/salmon = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Ikura
	category = CAT_FOOD

/datum/crafting_recipe/Ikura_maki
	name = "Ikura Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/fish_eggs/salmon = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Ikura_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Inari
	name = "Inari Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/fried_tofu = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Inari
	category = CAT_FOOD

/datum/crafting_recipe/Inari_maki
	name = "Inari Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/fried_tofu = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Inari_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Sake
	name = "Sake Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/salmonmeat = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Sake
	category = CAT_FOOD

/datum/crafting_recipe/Sake_maki
	name = "Sake Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/salmonmeat = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Sake_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/salmonsteak = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_SmokedSalmon
	category = CAT_FOOD

/datum/crafting_recipe/SmokedSalmon_maki
	name = "Smoked Salmon Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/salmonsteak = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/SmokedSalmon_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Masago
	name = "Masago Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/fish_eggs/goldfish = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Masago
	category = CAT_FOOD

/datum/crafting_recipe/Masago_maki
	name = "Masago Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/fish_eggs/goldfish = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Masago_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Tobiko
	name = "Tobiko Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/fish_eggs/shark = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko
	category = CAT_FOOD

/datum/crafting_recipe/Tobiko_maki
	name = "Tobiko Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/fish_eggs/shark = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Tobiko_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko = 1,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg
	category = CAT_FOOD

/datum/crafting_recipe/TobikoEgg_maki
	name = "Tobiko Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko = 4,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/TobikoEgg_maki
	category = CAT_FOOD

/datum/crafting_recipe/Sake_maki
	name = "Sake Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko = 4,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/TobikoEgg_maki
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Tai
	name = "Tai Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/catfishmeat = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Tai
	category = CAT_FOOD

/datum/crafting_recipe/Tai_maki
	name = "Tai Makiroll"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/catfishmeat = 4,
	)
	tools = list(/obj/item/weapon/kitchen/sushimat)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/Tai_maki
	category = CAT_FOOD