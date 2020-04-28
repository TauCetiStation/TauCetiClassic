/**
  * # Religious Sects
  *
  * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
  *
  * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  *
  */
/datum/religion/religion_sect
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
/// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list = list()
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

/datum/religion/religion_sect/New()
	on_select()

///Generates a list of rites with 'name' = 'type'
/datum/religion/religion_sect/proc/generate_rites_list()
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
/datum/religion/religion_sect/proc/on_select()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span>")

/// Activates when the sect sacrifices an item. Can provide additional benefits to the sacrificer, which can also be dependent on their holy role! If the item is suppose to be eaten, here is where to do it. NOTE INHER WILL NOT DELETE ITEM FOR YOU!!!!
/datum/religion/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/L)
	return adjust_favor(default_item_favor, L)

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion/religion_sect/proc/adjust_favor(amount = 0, mob/living/L)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if(favor + amount > max_favor)
		. = (max_favor-favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = between(0, favor + amount,  max_favor)

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion/religion_sect/proc/set_favor(amount = 0, mob/living/L)
	favor = between(0, amount, max_favor)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion/religion_sect/proc/on_riteuse(mob/living/user, obj/structure/altar_of_gods/AOG)

/datum/religion/religion_sect/proc/satisfy_requirements(element, datum/aspect/A)
	return element >= A.power

/datum/religion/religion_sect/proc/give_god_spells(mob/living/simple_animal/shade/god/G) //TODO
	if(gods_list.len == 0)
		return

	var/datum/callback/pred = CALLBACK(src, .proc/satisfy_requirements)
	for(var/spell in allow_spell)
		var/obj/effect/proc_holder/spell/S = new spell()
		var/list/spell_aspects = S.needed_aspect

		if(is_sublist_assoc(spell_aspects, sect_aspects, pred))
			spells |= spell

		QDEL_NULL(S)

	for(var/spell in spells)
		var/obj/effect/proc_holder/spell/S = new spell()
		G.AddSpell(S)

/datum/religion/religion_sect/proc/update_rites()
	if(rites_list.len != 0)
		var/listylist = generate_rites_list()
		rites_list = listylist

/datum/religion/religion_sect/puritanism
	name = "The Puritan of "
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"
	aspect_preset = list(/datum/aspect/salutis, /datum/aspect/lux, /datum/aspect/spiritus)
	rites_list = list()

/datum/religion/religion_sect/technophile
	name = "The Technomancers of "
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte."
	aspect_preset = list(/datum/aspect/technology, /datum/aspect/progressus, /datum/aspect/metallum)
	rites_list = list()

/datum/religion/religion_sect/custom
	name = "Custom "
	desc = "Follow the orders of your god."
	convert_opener = "I am the first to enter here.."
	allow_aspect = TRUE
