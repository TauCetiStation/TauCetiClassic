/**
  * # Religious Sects
  *
  * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
  *
  * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  *
  */
/datum/religion_sect
/// Name of the religious sect
	var/name = "Religious Sect Base Type"
/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
/// Opening message when someone gets converted
	var/convert_opener
/// Does this require something before being available as an option?
	var/starter = TRUE
/// The Sect's 'Mana'
	var/favor = 0 //MANA!
/// The max amount of favor the sect can have
	var/max_favor = 3000
/// The default value for an item that can be sacrificed
	var/default_item_favor = 5
/// Turns into 'desired_items_typecache', lists the types that can be sacrificed barring optional features in can_sacrifice()
	var/list/desired_items = list()
/// Autopopulated by `desired_items`
	var/list/desired_items_typecache
/// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list = list()
/// Changes the Altar of Gods icon
	var/altar_icon
/// Changes the Altar of Gods icon_state
	var/altar_icon_state
/// Determines which spells God can use.
	var/list/allow_spell = list(
	/obj/effect/proc_holder/spell/targeted/spawn_bible,
	/obj/effect/proc_holder/spell/targeted/heal,
	/obj/effect/proc_holder/spell/targeted/heal/damage,
	/obj/effect/proc_holder/spell/targeted/blessing,
	/obj/effect/proc_holder/spell/targeted/charge/religion,
	/obj/effect/proc_holder/spell/targeted/food,
	/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal,
	)
/// Spells that combine with aspects and cast to God
	var/list/spells = list()
/// Choosed aspects
	var/list/sect_aspects = list()
/// Allow choose aspect in sect
	var/allow_aspect = FALSE
/// Fast choose aspects
	var/list/datum/aspect/aspect_preset

/datum/religion_sect/New()
	on_select()

///Generates a list of rites with 'name' = 'type'
/datum/religion_sect/proc/generate_rites_list()
	for(var/i in rites_list)
		if(!ispath(i))
			continue
		var/datum/religion_rites/RI = i
		var/name_entry = "[initial(RI.name)]"
		if(initial(RI.desc))
			name_entry += " - [initial(RI.desc)]"
		if(initial(RI.favor_cost))
			name_entry += " ([initial(RI.favor_cost)] favor)"

		. += list("[name_entry]\n" = i)

/// Activates once selected
/datum/religion_sect/proc/on_select()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span>")

/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering.
/datum/religion_sect/proc/can_sacrifice(obj/item/I, mob/living/L)
	. = TRUE
	if(!is_type_in_typecache(I, desired_items_typecache))
		return FALSE

/// Activates when the sect sacrifices an item. Can provide additional benefits to the sacrificer, which can also be dependent on their holy role! If the item is suppose to be eaten, here is where to do it. NOTE INHER WILL NOT DELETE ITEM FOR YOU!!!!
/datum/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/L)
	return adjust_favor(default_item_favor, L)

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/L)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if((favor + amount > max_favor))
		. = (max_favor-favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = between(0, favor + amount,  max_favor)

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/L)
	favor = between(0, amount, max_favor)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, obj/structure/altar_of_gods/AOG)

/datum/religion_sect/proc/greater_or_equal(element, datum/aspect/A)
	return element >= A.power

/datum/religion_sect/proc/give_god_spells(mob/living/simple_animal/shade/god/G) //TODO
	if(gods_list.len == 0)
		return

	var/datum/callback/pred = CALLBACK(src, .proc/greater_or_equal)
	for(var/spell in allow_spell)
		var/obj/effect/proc_holder/spell/S = new spell()
		var/list/spell_aspects = S.needed_aspect

		if(is_sublist_assoc(spell_aspects, sect_aspects, pred))
			spells |= spell

		QDEL_NULL(S)

	for(var/spell in spells)
		var/obj/effect/proc_holder/spell/S = new spell()
		G.AddSpell(S)

/datum/religion_sect/proc/update_desire(ignore_path)
	if(desired_items.len != 0)
		desired_items_typecache = typecacheof(desired_items)
		if(ignore_path)
			desired_items_typecache -= subtypesof(ignore_path)
	else 
		for(var/i in sect_aspects)
			var/datum/aspect/asp = sect_aspects[i]
			if(asp.desire)
				desired_items_typecache = typecacheof(asp.desire)
				if(asp.not_in_desire)
					desired_items_typecache -= subtypesof(asp.not_in_desire)
	
/datum/religion_sect/proc/update_rites()
	if(rites_list.len != 0)
		var/listylist = generate_rites_list()
		rites_list = listylist

/datum/religion_sect/puritanism
	name = "Puritanism (Default)"
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"
	//altar_icon_state = "christianaltar"
	aspect_preset = list(/datum/aspect/salutis, /datum/aspect/lux, /datum/aspect/spiritus)
	rites_list = list()
	desired_items = list()

/datum/religion_sect/technophile
	name = "Technophile"
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte."
	//altar_icon_state = "technoaltar"
	aspect_preset = list(/datum/aspect/technology, /datum/aspect/progressus, /datum/aspect/metallum)
	rites_list = list()
	desired_items = list()

/datum/religion_sect/technophile/can_sacrifice(obj/item/I, mob/living/L)
	if(!..())
		return FALSE
	var/obj/item/weapon/stock_parts/cell/the_cell = I
	if(the_cell.charge < 3000)
		to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity amounts of power.</span>")
		return FALSE
	return TRUE

/datum/religion_sect/technophile/on_sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return
	var/obj/item/weapon/stock_parts/cell/the_cell = I
	adjust_favor(round(the_cell.charge/500), L)
	to_chat(L, "<span class='notice'>You offer [the_cell]'s power to [pick(global.chaplain_religion.deity_names)], pleasing them.</span>")
	qdel(I)

/datum/religion_sect/custom
	name = "Custom religion"
	desc = "Follow the orders of your god."
	convert_opener = "I am the first to enter here.."
	allow_aspect = TRUE

/datum/religion_sect/custom/can_sacrifice(obj/item/I, mob/living/L)
	if(!..())
		return FALSE

	if(istype(I, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/gun = I
		if(!gun.magazine)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without magazine.</span>")
			return FALSE
		if(gun.magazine && gun.magazine.ammo_count() == 0)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without bullet in magazine.</span>")
			return FALSE

	if(istype(I, /obj/item/clothing/suit/armor))
		var/obj/item/clothing/suit/armor/arm = I
		var/all_armor = 0
		for(var/i in arm.armor)
			all_armor += i
		if(all_armor == 0)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without armor.</span>")
			return FALSE

	if(istype(I, /obj/item/weapon/melee))
		var/obj/item/weapon/melee/mel = I
		if(mel.force == 0)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without damage.</span>")
			return FALSE

	if(istype(I, /obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food = I
		if(food.reagents.total_volume == 0)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
			return FALSE

	if(istype(I, /obj/item/weapon/reagent_containers/blood))
		var/obj/item/weapon/reagent_containers/blood/blood = I
		if(blood.reagents.total_volume == 0)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
			return FALSE

	if(istype(I, /obj/item/seeds))
		var/obj/item/seeds/seed = I
		if(seed.potency < 0)
			to_chat("<span class='notice'>[pick(global.chaplain_religion.deity_names)] does not accept pity [I] without useful material.</span>")
			return FALSE

	return TRUE

/datum/religion_sect/custom/on_sacrifice(obj/item/I, mob/living/L)
	if(!is_type_in_typecache(I, desired_items_typecache))
		return

	if(istype(I, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/cell = I
		adjust_favor(round(cell.charge / 200), L)
	
	if(istype(I, /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/energy = I
		adjust_favor(25 * energy.w_class * energy.w_class, L)

	if(istype(I, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/gun = I
		adjust_favor(gun.magazine.ammo_count() * gun.chambered.BB.damage * 1.5, L)

	if(istype(I, /obj/item/clothing/suit/armor))
		var/obj/item/clothing/suit/armor/arm = I
		var/all_armor = 0
		for(var/i in arm.armor)
			all_armor += i
		adjust_favor(all_armor * 0.6, L)

	if(istype(I, /obj/item/weapon/melee))
		var/obj/item/weapon/melee/mel = I
		adjust_favor(mel.force * 5, L)

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/food = I
		adjust_favor(round((food.reagents.reagent_list.len / 2) + 1) * food.reagents.total_volume, L)

	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/material = I
		adjust_favor(material.amount * 5, L)

	if(istype(I, /obj/item/organ/external) || istype(I, /obj/item/brain))
		adjust_favor(50, L)

	if(istype(I, /obj/item/weapon/reagent_containers/blood))
		adjust_favor(25, L)

	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/part = I
		adjust_favor(25 * part.rating, L)

	if(istype(I, /obj/item/weapon/circuitboard))
		adjust_favor(30, L)

	if(istype(I, /obj/item/device/assembly))
		var/obj/item/device/assembly/ass = I
		adjust_favor(10 * ass.w_class, L)

	if(istype(I, /obj/item/seeds))
		var/obj/item/seeds/seed = I
		adjust_favor(seed.potency * 1.5, L)

	to_chat(L, "<span class='notice'>You offer [I]'s power to [pick(global.chaplain_religion.deity_names)], pleasing them.</span>")
	qdel(I)
