/datum/aspect
	var/name = "Basik aspect"
	//can only be increased if you select one aspect twice
	var/power = 1
	//items for desire, depends on power
	var/list/desire
	//path for items which dont enter in desire list
	var/not_in_desire
	//add the rite in a sect
	var/rite

/datum/aspect/mortem
	name = "Mortem" //death

	desire = list(/obj/item/organ/external, /obj/item/brain, /obj/item/weapon/reagent_containers/blood)

	rite = /datum/religion_rites/sacrifice

/datum/aspect/progressus
	name = "Progressus" //science

	desire = list(/obj/item/weapon/stock_parts, /obj/item/weapon/circuitboard, /obj/item/device/assembly,)

	not_in_desire = /obj/item/weapon/stock_parts/cell

	rite = /datum/religion_rites/synthconversion

/datum/aspect/fames
	name = "Fames" //hungry

	desire = list(/obj/item/weapon/reagent_containers/food)

	rite = /datum/religion_rites/food

/datum/aspect/telum
	name = "Telum" //weapon

	//rite = /datum/religion_rites/create_weapons

/datum/aspect/metallum
	name = "Metallum" //resurces

	desire = list(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/metal, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/wood, /obj/item/stack/sheet/mineral, /obj/item/weapon/spacecash)

	//rite = /datum/religion_rites/create_materials

/datum/aspect/partum
	name = "Partum" //spawn

/datum/aspect/cruciatu
	name = "Cruciatu" //self-flagellation

/datum/aspect/salutis
	name = "Salutis" //salvations

	rite = /datum/religion_rites/pray

/datum/aspect/spiritus
	name = "Spiritus" //Mistic

/datum/aspect/technology
	name = "Technology" //Techonogis

	rite = /datum/religion_rites/synthconversion

/datum/aspect/chao
	name = "Chao" //chaos

/datum/aspect/wacky
	name = "Wacky" //wacky

/datum/aspect/absentia
	name = "Absentia" //absence

/datum/aspect/obscurum
	name = "Obscurum" //obscure

/datum/aspect/lux
	name = "Lux" //light
