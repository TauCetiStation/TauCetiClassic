
/datum/crafting_recipe
	var/name = ""                   // in-game display name
	var/reqs[] = list()             // type paths of items consumed associated with how many are needed
	var/result                      // type path of item resulting from this craft
	var/tools[] = list()            // type paths of items needed but not consumed
	var/time = 30                   // time in deciseconds
	var/parts[] = list()            // type paths of items that will be placed in the result
	var/chem_catalysts[] = list()   // like tools but for reagents

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/weapon/legcuffs/bola
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 20 // 15 faster than crafting them by hand!

/datum/crafting_recipe/cable_restraints
	name = "Cable Restraints"
	reqs = list(/obj/item/stack/cable_coil = 15)
	result = /obj/item/weapon/handcuffs/cable
	parts = list(/obj/item/stack/cable_coil = 1)

/datum/crafting_recipe/noose
	name = "Noose"
	reqs = list(/obj/item/stack/cable_coil = 25)
	result = /obj/item/weapon/noose
	parts = list(/obj/item/stack/cable_coil = 1)

//   SHIELD craft

/datum/crafting_recipe/bucklerframe1
	name = "Щиток 1 фаза"
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = /obj/item/weapon/bucklerframe1
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 25

/datum/crafting_recipe/bucklerframe2
	name = "Щиток 2 фаза"
	reqs = list(/obj/item/weapon/bucklerframe1 = 1)
	tools = list(/obj/item/weapon/smith_hammer)
	result = /obj/item/weapon/bucklerframe3
	time = 35

/datum/crafting_recipe/bucklerframe3
	name = "Щиток"
	reqs = list(/obj/item/weapon/bucklerframe3 = 1,
				/obj/item/weapon/ore/iron = 1)
	result = /obj/item/weapon/shield/buckler
	time = 15

/datum/crafting_recipe/harpoon
	name = "Стрела"
	reqs = list(/obj/item/stack/sheet/wood = 1)
	result =/obj/item/weapon/arrow/harpoon
	time = 1

//   CROSSBOW craft

/datum/crafting_recipe/crossbowframe1
	name = "Арбалет (1 стадия)"
	reqs = list(/obj/item/stack/sheet/wood = 5)
	result = /obj/item/weapon/crossbowframe1
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 35

/datum/crafting_recipe/crossbowframe2
	name = "Арбалет "
	reqs = list(/obj/item/weapon/crossbowframe1 = 1,
	/obj/item/weapon/ore/iron = 1)
	result = /obj/item/weapon/crossbow
	time = 35

/datum/crafting_recipe/alebard
	name = "Алебарда"
	reqs = list(/obj/item/stack/sheet/wood = 1,
				/obj/item/weapon/ore/iron = 4,
				/obj/item/weapon/ore/coal = 1,
				/obj/item/weapon/ore/silver = 1)
	result = /obj/item/weapon/spear
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 40

/datum/crafting_recipe/armor
	name = "Броня Ополчения"
	reqs = list(/obj/item/weapon/ore/iron = 4,
				/obj/item/weapon/ore/coal = 2,/obj/item/weapon/ore/silver = 2)
	result = /obj/item/clothing/suit/armor/milita
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 40

/datum/crafting_recipe/helmet
	name = "Шлем Ополчения"
	reqs = list(/obj/item/weapon/ore/iron = 1,
				/obj/item/weapon/ore/coal = 1)
	result = /obj/item/clothing/head/helmet/milita
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 40

/datum/crafting_recipe/gorget
	name = "Горжет Ополчения"
	reqs = list(/obj/item/stack/medical/bruise_pack/rags = 3)
	result = /obj/item/clothing/mask/milita
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 40

/datum/crafting_recipe/milita_boots
	name = "Солиднее башмаков"
	reqs = list(/obj/item/stack/medical/bruise_pack/rags = 1)
	result = /obj/item/clothing/shoes/boots
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 10

/datum/crafting_recipe/milita_gloves
	name = "Перчатки"
	reqs = list(/obj/item/stack/medical/bruise_pack/rags = 1)
	result = /obj/item/clothing/gloves/black
	tools = list(/obj/item/weapon/smith_hammer,/obj/structure/vilage/anvil)
	time = 10



// Vilage Food
/datum/crafting_recipe/troglodit_pie
	name = "Грибной пирожок"
	reqs = list(/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice = 1,/obj/item/weapon/reagent_containers/food/snacks/dough = 1,/obj/structure/vilage/velikiy_sup,/obj/structure/bonfire)
	result =/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	time = 15

/datum/crafting_recipe/uncursed_chicken
	name = "Препарат Проктонис"
	reqs = list(/obj/item/weapon/reagent_containers/food/snacks/dough = 1,/datum/reagent/consumable/drink/milk = 5,/obj/structure/vilage/velikiy_sup,/obj/structure/bonfire)
	result =/obj/item/uncurs_ointment
	time = 15

//Money

/datum/crafting_recipe/gold_coin
	name = "Золотая фальшивая монетка"
	reqs = list(/obj/item/weapon/ore/gold = 1)
	result =/obj/item/stack/money/gold/fake
	tools = list(/obj/structure/vilage/coin_machine)
	time = 10

/datum/crafting_recipe/silver_coin
	name = "Серебряная фальшивая монетка"
	reqs = list(/obj/item/weapon/ore/silver = 1)
	result =/obj/item/stack/money/silver/fake
	tools = list(/obj/structure/vilage/coin_machine)
	time = 10