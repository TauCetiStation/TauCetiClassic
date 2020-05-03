/datum/aspect
	var/name = "Basic aspect"
	var/desc = "This aspect not used in game"
	//used for give a god the information about aspect and desire items
	var/god_desc
	//can only be increased if you select one aspect twice and more times
	var/power = 1

// Return the amount of favour this item will give, if succesfully sacrificed.
/datum/aspect/proc/sacrifice(obj/item/I, mob/living/L)
	return 0

//Gives mana from: any external organs, limbs, dead body and other meat
//Needed for: spells and rituals related to the theme of death, interaction with dead body, necromancy
/datum/aspect/mortem
	name = ASPECT_DEATH
	desc = "You can consider it necromancy"

	god_desc = "Mortal humans can donate to increase your strength: blood bags, brains, internal organs and limbs."

/datum/aspect/mortem/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/reagent_containers/blood))
		var/blood_am = 0
		if(I.reagents)
			blood_am = I.reagents.get_reagent_amount("blood")
		return blood_am

	else if(istype(I, /obj/item/organ/external))
		return 50

	else if(istype(I, /obj/item/brain))
		return 100

	return 0

//Gives mana from: sci-fi things, scientist points
//Needed for: spells and rituals related to the theme of sci-fi, future
/datum/aspect/progressus
	name = ASPECT_SCIENCE
	desc = "Sci-fi items and other science"

	god_desc = "Homosapiens and other xenos races can present all sorts of scientific things, cuircuitboards and small electronic devices."

/datum/aspect/progressus/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/part = I
		return 25 * part.rating

	else if(istype(I, /obj/item/weapon/circuitboard))
		return 30

	else if(istype(I, /obj/item/device/assembly))
		return 10 * I.w_class

	return FALSE

//Gives mana from: any food
//Needed for: spells and rituals related to the theme of food
/datum/aspect/fames
	name = ASPECT_FOOD
	desc = "Can be considered it greed"

	god_desc = "Peasants are required to pay you food."

/datum/aspect/fames/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/reagent_containers/food) && I.reagents)
		var/favour_amount = 0
		for(var/datum/reagent/R in I.reagents.reagent_list)
			favour_amount += R.nutriment_factor * R.volume * 0.25
		return favour_amount

	return 0

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of weapon and armor, their damage, buff etc
/datum/aspect/telum
	name = ASPECT_WEAPON //with armor
	desc = "Weapons and related things, war"

//Gives mana from: minerals, sheet, steel, money etc
//Needed for: spells and rituals related to the theme of materials, his shell, manipulation of the molecular composition of the resource
/datum/aspect/metallum
	name = ASPECT_RESURCES
	desc = "Manipulated on minerals, metallic, glass and others"

	god_desc = "May the workers bring diverse resources to your mercy."

/datum/aspect/metallum/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/material = I
		return material.amount * 5
	return 0

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of spawn animal, creatures
/datum/aspect/partum
	name = ASPECT_SPAWN
	desc = "Create any bio-materials"

//Gives mana from: allows you to accumulate mana when you beat yourself near the altar
//Needed for: any spell in which there is damage to the chaplain or people around the altar should have this aspect.
/datum/aspect/cruciatu
	name = ASPECT_FLAGELLATION
	desc = "Self-flagellation, transformation of life energy into a magic"

//Gives mana from: any heal near the altar
//Needed for: spells and rituals related to the theme of heal, buff
/datum/aspect/salutis
	name = ASPECT_RESCUE
	desc = "Any heal, buff"

//Gives mana from: ghosts staying near the altar
//Needed for: spells and rituals related to the theme of ghosts
/datum/aspect/spiritus
	name = ASPECT_MYSTIC
	desc = "Any interaction with ghosts"

//Gives mana from: sacrificed charge
//Needed for: spells and rituals related to the theme of electrical equipment, electrical energy
/datum/aspect/technology
	name = ASPECT_TECH
	desc = "Accepts electrical energy, also manipulates any electrical equipment"

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of random, eg random heal
/datum/aspect/chaos
	name = ASPECT_CHAOS
	desc = "The meaning of the aspect is that its rituals and spells are random"

//Gives mana from: fools, how clowns
//Needed for: spells and rituals related to the theme of clown equipments, items
/datum/aspect/wacky
	name = ASPECT_WACKY
	desc = "Clownism"

	god_desc = "The Family urgently needs a lot of BANANAS and BANANIUM!!!"

/datum/aspect/wacky/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/bananapeel/honk))
		return 40
	if(istype(I, /obj/item/weapon/bananapeel))
		return 30
	if(istype(I, /obj/item/stack/sheet/mineral/clown))
		var/obj/item/stack/sheet/mineral/clown/banan = I
		return banan.amount * 60
	if(istype(I, /obj/item/weapon/ore/clown))
		return 50
	return FALSE

//Gives mana from: "silenced" spells at wizard/cult
//Needed for: spells and rituals related to the theme of muffle the magical abilities of the wizard/cult
/datum/aspect/absentia
	name = ASPECT_ABSENCE
	desc = "Silence, allows you to use the power of the magician or cult as you want"

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of dark, eviv, obcurse
/datum/aspect/obscurum
	name = ASPECT_OBSCURE
	desc = "Dark, darkness, obcurse, evil"

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of receiving light
/datum/aspect/lux
	name = ASPECT_LIGHT
	desc = "Light interaction"
