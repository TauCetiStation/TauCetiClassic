/datum/aspect
	var/name = "Basic aspect"
	var/desc = "This aspect not used in game"
	//can only be increased if you select one aspect twice and more times
	var/power = 1
	//items for desire
	var/list/desire
	//stores all possible types of desire item
	var/list/desired_items_typecache
	//path for items which dont enter in desire list
	var/not_in_desire
	//add the rite in a sect
	var/rite

/datum/aspect/New()
	if(desire)
		desired_items_typecache = typecacheof(desire)
		if(not_in_desire)
			desired_items_typecache -= subtypesof(not_in_desire)

/datum/aspect/proc/sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return

//Gives mana from: any external organs, limbs, dead body and other meat
//Needed for: spells and rituals related to the theme of death, interaction with dead body, necromancy
/datum/aspect/mortem
	name = "Mortem" //death
	desc = "You can consider it necromancy"

	desire = list(/obj/item/organ/external, /obj/item/brain, /obj/item/weapon/reagent_containers/blood)

	rite = /datum/religion_rites/sacrifice

/datum/aspect/mortem/sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return

	if(istype(I, /obj/item/weapon/reagent_containers/blood))
		var/obj/item/weapon/reagent_containers/blood/blood = I
		if(!blood.reagents || blood.reagents && blood.reagents.total_volume <= 0)
			to_chat(L, "<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
			return
		religious_sect.adjust_favor(25, L)

	if(istype(I, /obj/item/organ/external) || istype(I, /obj/item/brain))
		religious_sect.adjust_favor(50, I)
	
	to_chat(L, "<span class='notice'>You offer [I]'s power to [pick(global.chaplain_religion.deity_names)], pleasing them.</span>")
	qdel(I)

//Gives mana from: sci-fi things, scientist points
//Needed for: spells and rituals related to the theme of sci-fi, future
/datum/aspect/progressus
	name = "Progressus" //science
	desc = "Sci-fi items and other science"

	desire = list(/obj/item/weapon/stock_parts, /obj/item/weapon/circuitboard, /obj/item/device/assembly,)

	not_in_desire = /obj/item/weapon/stock_parts/cell

	rite = /datum/religion_rites/synthconversion

/datum/aspect/progressus/sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return

	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/part = I
		religious_sect.adjust_favor(25 * part.rating, L)

	if(istype(I, /obj/item/weapon/circuitboard))
		religious_sect.adjust_favor(30, L)

	if(istype(I, /obj/item/device/assembly))
		var/obj/item/device/assembly/ass = I
		religious_sect.adjust_favor(10 * ass.w_class, L)

	to_chat(L, "<span class='notice'>You offer [I]'s power to [pick(global.chaplain_religion.deity_names)], pleasing them.</span>")
	qdel(I)

//Gives mana from: any food
//Needed for: spells and rituals related to the theme of food
/datum/aspect/fames
	name = "Fames" //hungry
	desc = "Can be considered it greed"

	desire = list(/obj/item/weapon/reagent_containers/food)

	rite = /datum/religion_rites/food

/datum/aspect/fames/sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/food = I
		if(!food.reagents || food.reagents && food.reagents.total_volume <= 0)
			to_chat(L, "<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
			return
		religious_sect.adjust_favor(round((food.reagents.reagent_list.len / 2) + 1) * food.reagents.total_volume, L)

	to_chat(L, "<span class='notice'>You offer [I]'s power to [pick(global.chaplain_religion.deity_names)], pleasing them.</span>")
	qdel(I)

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of weapon, his damage, buff etc
/datum/aspect/telum
	name = "Telum" //weapon
	desc = "Weapons and related things, war"

	//rite = /datum/religion_rites/create_weapons

//Gives mana from: minerals, sheet, steel, money etc
//Needed for: spells and rituals related to the theme of materials, his shell, manipulation of the molecular composition of the resource
/datum/aspect/metallum
	name = "Metallum" //resurces
	desc = "Manipulated on minerals, metallic, glass and others"

	desire = list(/obj/item/stack/sheet/glass, /obj/item/stack/sheet/metal, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/wood, /obj/item/stack/sheet/mineral, /obj/item/weapon/spacecash)

	//rite = /datum/religion_rites/create_materials

/datum/aspect/metallum/sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return

	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/material = I
		religious_sect.adjust_favor(material.amount * 5, L)

	to_chat(L, "<span class='notice'>You offer [I]'s power to [pick(global.chaplain_religion.deity_names)], pleasing them.</span>")
	qdel(I)

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
