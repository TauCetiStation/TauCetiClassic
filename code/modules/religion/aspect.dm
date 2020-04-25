/datum/aspect
	var/name = "Basik aspect"
	//can only be increased if you select one aspect twice
	var/power = 1
	//items for desire, depends on power
	var/list/desire
	//path for items which dont enter in desire list
	var/not_in_desire
	//add the spell in a sect
	var/list/spells
	//add the rite in a sect
	var/rite

/datum/aspect/mortem
	name = "Mortem" //death

	desire = list(
		list(/obj/item/organ/external, /obj/item/brain,),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown, /obj/item/weapon/reagent_containers/blood)
	)

	spells = list(
		/obj/effect/proc_holder/spell/targeted/heal/damage,
	)

	rite = /datum/religion_rites/sacrifice

/datum/aspect/progressus
	name = "Progressus" //science

	desire = list(
		list(/obj/item/weapon/stock_parts,),
		list(/obj/item/weapon/circuitboard, /obj/item/device/assembly,)
	)

	not_in_desire = /obj/item/weapon/stock_parts/cell

	spells = list(/obj/effect/proc_holder/spell/targeted/charge/religion,)

/datum/aspect/messis
	name = "Messis" //farm

	desire = list(
		list(/obj/item/weapon/reagent_containers/food/snacks/grown,),
		list(/obj/item/seeds,)
	)

	spells = list(/obj/effect/proc_holder/spell/targeted/heal,)

	rite = /datum/religion_rites/food

/datum/aspect/fames
	name = "Fames" //hungry

	desire = list(
		list(/obj/item/weapon/reagent_containers/food/snacks,),
		list(/obj/item/weapon/reagent_containers/food/drinks,)
	)

	spells = list(/obj/effect/proc_holder/spell/targeted/food,)

	rite = /datum/religion_rites/food

/datum/aspect/telum
	name = "Telum" //weapon

	desire = list(
		list(/obj/item/weapon/gun,),
		list(/obj/item/weapon/melee,)
	)

	spells = list(/obj/effect/proc_holder/spell/targeted/blessing,)

/datum/aspect/metallum
	name = "Metallum" //resurces

	desire = list(
		list(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/metal, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/wood),
		list(/obj/item/stack/sheet/mineral,)
	)

	spells = list(/obj/effect/proc_holder/spell/targeted/forcewall/religion)

/datum/aspect/partum
	name = "Partum" //weapon

	desire = list(
		list(/obj/item/weapon/reagent_containers/food/snacks/meat, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat, /obj/item/weapon/reagent_containers/food/drinks/milk, /obj/item/weapon/reagent_containers/food/drinks/soymilk),
		list(/obj/item/weapon/reagent_containers/food/snacks/grown,)
	)

	spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal)

	rite = /datum/religion_rites/sacrifice
