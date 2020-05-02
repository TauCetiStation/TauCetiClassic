/datum/aspect
	var/name = "Basic aspect"
	var/desc = "This aspect not used in game"
	//used for give a god the information about aspect and desire items
	var/god_desc
	//can only be increased if you select one aspect twice and more times
	var/power = 1
	//add the rite in a sect
	var/rite

/datum/aspect/proc/sacrifice(obj/item/I, mob/living/L)
	return

//Gives mana from: any external organs, limbs, dead body and other meat
//Needed for: spells and rituals related to the theme of death, interaction with dead body, necromancy
/datum/aspect/mortem
	name = "Mortem" //death
	desc = "You can consider it necromancy"

	god_desc = "Mortal humans can donate to increase your strength: blood bags, brains, internal organs and limbs."

	rite = /datum/religion_rites/sacrifice

/datum/aspect/mortem/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/reagent_containers/blood))
		var/obj/item/weapon/reagent_containers/blood/blood = I
		if(!blood.reagents || blood.reagents && blood.reagents.total_volume <= 0)
			to_chat(L, "<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
			return FALSE
		global.chaplain_religion.adjust_favor(25, L)
		return TRUE

	else if(istype(I, /obj/item/organ/external) || istype(I, /obj/item/brain))
		global.chaplain_religion.adjust_favor(50, I)
		return TRUE
	
	return FALSE

//Gives mana from: sci-fi things, scientist points
//Needed for: spells and rituals related to the theme of sci-fi, future
/datum/aspect/progressus
	name = "Progressus" //science
	desc = "Sci-fi items and other science"

	god_desc = "Homosapiens and other xenos races can present all sorts of scientific things, cuircuitboards and small electronic devices."

/datum/aspect/progressus/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/part = I
		global.chaplain_religion.adjust_favor(25 * part.rating, L)
		return TRUE

	else if(istype(I, /obj/item/weapon/circuitboard))
		global.chaplain_religion.adjust_favor(30, L)
		return TRUE

	else if(istype(I, /obj/item/device/assembly))
		var/obj/item/device/assembly/ass = I
		global.chaplain_religion.adjust_favor(10 * ass.w_class, L)
		return TRUE

	return FALSE

//Gives mana from: any food
//Needed for: spells and rituals related to the theme of food
/datum/aspect/fames
	name = "Fames" //hungry
	desc = "Can be considered it greed"

	god_desc = "Peasants are required to pay you food."

	rite = /datum/religion_rites/food

/datum/aspect/fames/sacrifice(obj/item/I, mob/living/L)
	if(I.reagents)
		var/favour_amount = 0
		for(var/datum/reagent/R in I.reagents.reagent_list)
			if(istype(R, /datum/reagent/consumable) || istype(R, /datum/reagent/nutriment) || istype(R, /datum/reagent/vitamin))
				favour_amount += R.nutriment_factor * R.volume

		if(favour_amount > 0 && favour_amount < 100)
			global.chaplain_religion.adjust_favor(favour_amount, L)
			return TRUE
		if(favour_amount >= 100 && favour_amount < 200) // balance
			global.chaplain_religion.adjust_favor(favour_amount/2, L)
			return TRUE
		if(favour_amount >= 200 && favour_amount < 300)
			global.chaplain_religion.adjust_favor(favour_amount/3, L)
			return TRUE
		if(favour_amount >= 300)
			global.chaplain_religion.adjust_favor(favour_amount/4, L)
			return TRUE

	to_chat(L, "<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
	return FALSE

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of weapon and armor, their damage, buff etc
/datum/aspect/telum
	name = "Telum" //weapon and armor
	desc = "Weapons and related things, war"

	//rite = /datum/religion_rites/create_weapons

//Gives mana from: minerals, sheet, steel, money etc
//Needed for: spells and rituals related to the theme of materials, his shell, manipulation of the molecular composition of the resource
/datum/aspect/metallum
	name = "Metallum" //resurces
	desc = "Manipulated on minerals, metallic, glass and others"

	god_desc = "May the workers bring diverse resources to your mercy."

	//rite = /datum/religion_rites/create_materials

/datum/aspect/metallum/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/stack/sheet) && !istype(I, /obj/item/stack/sheet/mineral/clown))
		var/obj/item/stack/sheet/material = I
		global.chaplain_religion.adjust_favor(material.amount * 5, L)
		return TRUE
	return FALSE

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of spawn animal, creatures
/datum/aspect/partum
	name = "Partum" //spawn
	desc = "Create any bio-materials"

//Gives mana from: allows you to accumulate mana when you beat yourself near the altar
//Needed for: any spell in which there is damage to the chaplain or people around the altar should have this aspect.
/datum/aspect/cruciatu
	name = "Cruciatu" //self-flagellation
	desc = "Self-flagellation, transformation of life energy into a magic"

//Gives mana from: any heal near the altar
//Needed for: spells and rituals related to the theme of heal, buff
/datum/aspect/salutis
	name = "Salutis" //rescue
	desc = "Any heal, buff"

	rite = /datum/religion_rites/pray

//Gives mana from: ghosts staying near the altar
//Needed for: spells and rituals related to the theme of ghosts
/datum/aspect/spiritus
	name = "Spiritus" //mystic
	desc = "Any interaction with ghosts"

//Gives mana from: sacrificed charge
//Needed for: spells and rituals related to the theme of electrical equipment, electrical energy
/datum/aspect/technology
	name = "Arsus" //techonogies
	desc = "Accepts electrical energy, also manipulates any electrical equipment"

	rite = /datum/religion_rites/synthconversion

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of random, eg random heal
/datum/aspect/chaos
	name = "Chaos" //random
	desc = "The meaning of the aspect is that its rituals and spells are random"

//Gives mana from: fools, how clowns
//Needed for: spells and rituals related to the theme of clown equipments, items
/datum/aspect/wacky
	name = "Rabidus" //wacky
	desc = "Clownism"

	god_desc = "The Family urgently needs a lot of BANANAS and BANANIUM!!!"

/datum/aspect/wacky/sacrifice(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/weapon/bananapeel/honk))
		global.chaplain_religion.adjust_favor(40, L)
		return TRUE
	if(istype(I, /obj/item/weapon/bananapeel))
		global.chaplain_religion.adjust_favor(30, L)
		return TRUE
	if(istype(I, /obj/item/stack/sheet/mineral/clown))
		var/obj/item/stack/sheet/mineral/clown/banan = I
		global.chaplain_religion.adjust_favor(banan.amount * 60, L)
		return TRUE
	if(istype(I, /obj/item/weapon/ore/clown))
		global.chaplain_religion.adjust_favor(50, L)
		return TRUE
	return FALSE

//Gives mana from: "silenced" spells at wizard/cult
//Needed for: spells and rituals related to the theme of muffle the magical abilities of the wizard/cult
/datum/aspect/absentia
	name = "Absentia" //absence
	desc = "Silence, allows you to use the power of the magician or cult as you want"

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of dark, eviv, obcurse
/datum/aspect/obscurum
	name = "Obscurum" //obscure
	desc = "Dark, darkness, obcurse, evil"

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of receiving light
/datum/aspect/lux
	name = "Lux" //light
	desc = "Light interaction"
