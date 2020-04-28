/datum/aspect
	var/name = "Basic aspect"
	var/desc = "This aspect not used in game"
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
	desc = "You can consider it necromancy"

	desire = list(/obj/item/organ/external, /obj/item/brain, /obj/item/weapon/reagent_containers/blood)

	rite = /datum/religion_rites/sacrifice

/datum/aspect/progressus
	name = "Progressus" //science
	desc = "Sci-fi items and other science"

	desire = list(/obj/item/weapon/stock_parts, /obj/item/weapon/circuitboard, /obj/item/device/assembly,)

	not_in_desire = /obj/item/weapon/stock_parts/cell

	rite = /datum/religion_rites/synthconversion

/datum/aspect/fames
	name = "Fames" //hungry
	desc = "Can be considered it greed"

	desire = list(/obj/item/weapon/reagent_containers/food)

	rite = /datum/religion_rites/food

/datum/aspect/telum
	name = "Telum" //weapon
	desc = "Weapons and related things, war"

	//rite = /datum/religion_rites/create_weapons

/datum/aspect/metallum
	name = "Metallum" //resurces
	desc = "Manipulated on minerals, metallic, glass and others"

	desire = list(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/metal, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/wood, /obj/item/stack/sheet/mineral, /obj/item/weapon/spacecash)

	//rite = /datum/religion_rites/create_materials

/datum/aspect/partum
	name = "Partum" //spawn
	desc = "Create any bio-materials"

/datum/aspect/cruciatu
	name = "Cruciatu" //self-flagellation
	desc = "Self-flagellation, transformation of life energy into a magic"

/datum/aspect/salutis
	name = "Salutis" //rescue
	desc = "Any heal, buff"

	rite = /datum/religion_rites/pray

/datum/aspect/spiritus
	name = "Spiritus" //mystic
	desc = "Any interaction with ghosts"

/datum/aspect/technology
	name = "Arsus" //techonogies
	desc = "Accepts electrical energy, also manipulates any electrical equipment"

	rite = /datum/religion_rites/synthconversion

/datum/aspect/chaos
	name = "Chaos" //random
	desc = "The meaning of the aspect is that its rituals and spells are random"

/datum/aspect/wacky
	name = "Rabidus" //wacky
	desc = "Clownism"

/datum/aspect/absentia
	name = "Absentia" //absence
	desc = "Silence, allows you to use the power of the magician or cult as you want"

/datum/aspect/obscurum
	name = "Obscurum" //obscure
	desc = "Dark, darkness, obcurse, evil"

/datum/aspect/lux
	name = "Lux" //light
	desc = "Light interaction"
