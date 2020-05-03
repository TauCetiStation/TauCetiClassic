/*
	This datum is used to neatly package all of chaplain's choices and etc
	and save them somewhere for future reference.
*/

// This proc is called from tickers setup, right after economy is done, but before any characters are spawned.
// TO-DO: make cultists, and other antags use this in some way? ~Luduk
/proc/setup_religions()
	global.chaplain_religion = new /datum/religion/chaplain

/datum/religion
	// The name of this religion.
	var/name = ""
	// Lore of this religion. Is displayed to "God(s)". If none is set, chaplain will be prompted to set up their own lore.
	var/lore = ""
	var/static/list/lore_by_name = list(
	)

	/****ASPECTS****/
	// The religion 'Mana'
	var/favor = 0 //MANA!
	// The max amount of favor the religion can have
	var/max_favor = 3000
	// Determines which spells God can use.
	var/list/allow_spell = list(
	/obj/effect/proc_holder/spell/targeted/spawn_bible,
	/obj/effect/proc_holder/spell/targeted/heal,
	/obj/effect/proc_holder/spell/targeted/heal/damage,
	/obj/effect/proc_holder/spell/targeted/blessing,
	/obj/effect/proc_holder/spell/targeted/charge/religion,
	/obj/effect/proc_holder/spell/targeted/food,
	/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal,
	/obj/effect/proc_holder/spell/targeted/grease,
	)
	// Spells that combine with aspects and cast to God
	var/list/spells = list()
	// Choosed aspects
	var/list/aspects = list()
	// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list = list()
	/****ASPECTS****/

	// List of names of deities of this religion.
	// There is no "default" deity, please specify one for your religion here.
	var/list/deity_names = list()
	var/static/list/deity_names_by_name = list(
		"Christianity" = list("Lord", "God", "Saviour", "Yahweh", "Jehovah", "Father", "Space-Jesus"),
		"Satanism" = list("Satana", "Lucifer", "Baphomet", "Leviathan"),
		"Yog'Sotherie" = list("Cthulhu", "Katuluu", "Kachoochoo", "Kutulu", "The Great Dreamer", "The Sleeper of R'lyeh"),
		"Islam" = list("Allah"),
		"Scientology" = list("Xenu", "Xemu"),
		"Chaos" = list("Chaos", "Khorne", "Slaanesh", "Nurlge", "Tzeentch", "Malal"),
		"Imperium" = list("God Emperor of Mankind"),
		"Toolboxia" = list("The Toolbox"),
		"Science" = list("The Scientific Method"),
		"Technologism" = list("Omnissiah", "Machine God", "Broken God"),
		"Clownism" = list("Honkmother", "The Harlequin", "Laughing God", "First fool"),
		"Buddhism" = list("Vairocana", "Aksobhya", "Ratnasambhava", "Amoghasiddhi", "Bhaisajyaguru", "Vajradhara", "Samanthabhadra", "Tara"),
		"Atheism" = list("Self", "I"),
	)

	var/datum/bible_info/bible_info
	// Default is /datum/bible_info/custom, if one is not specified here.
	var/static/list/bible_info_by_name = list(
		"Christianity" = /datum/bible_info/bible,
		"Satanism" = /datum/bible_info/satanism,
		"Yog'Sotherie" = /datum/bible_info/necronomicon,
		"Islam" = /datum/bible_info/islam,
		"Scientology" = /datum/bible_info/scientology,
		"Chaos" = /datum/bible_info/book_of_lorgar,
		"Imperium" = /datum/bible_info/book_of_lorgar/imperial_truth,
		"Toolboxia" = /datum/bible_info/toolbox,
		"Science" = /datum/bible_info/science,
		"Tecnologism" = /datum/bible_info/techno,
		"Clownism" = /datum/bible_info/scrapbook,
		"Buddhism" = /datum/bible_info/bible/buddhism,
		"Atheism" = /datum/bible_info/atheist,
	)

	/*
	var/lecturn_icon_state
	// Default one is "general".
	var/static/list/lecturn_info_by_name = list(
	)
	*/

	var/pews_icon_state
	// Default one is "general".
	var/static/list/pews_info_by_name = list(
		"Default" = "general",
		"Christianity" = "christianity",
		"Satanism" = "dead",
		"Yog'Sotherie" = "cthulhu",
		"Islam" = "islam",
		"Toolboxia" = "toolbox",
		"Science" = "science",
		"Technologism" = "singulo",
		"Clownism" = "clown",
		"Atheism" = "void",
		"Slime" = "slime",
		"NanoTrasen" = "nanotrasen",
	)

	var/altar_icon_state
	// Default one is "altar"
	var/static/list/altar_info_by_name = list(
		"Default" = "altar",
		"Christianity" = "chirstianaltar",
		"Satanism" = "satanaltar",
		"Toolboxia" = "toolboxaltar",
		"Science" = "technologyaltar",
		"NanoTrasen" = "altar",
		"Chaos" = "chaosaltar",
		"Imperium" = "imperialaltar",
		"Druid" = "druidaltar"
	)

	// Default is "0" TO-DO: convert this to icon_states. ~Luduk
	var/carpet_dir
	var/static/list/carpet_dir_by_name = list(
		"Default" = 0,
		"Scientology" = 8,
		"Christianity" = 2,
		"Atheism" = 10,
		"Islam" = 4,
	)

/datum/religion/New()
	create_default()
	religify(/area/station/civilian/chapel)

/datum/religion/proc/gen_bible_info()
	if(bible_info_by_name[name])
		var/info_type = bible_info_by_name[name]
		bible_info = new info_type(src)
	else
		bible_info = new /datum/bible_info/custom(src)

/datum/religion/proc/create_default()
	name = pick(DEFAULT_RELIGION_NAMES)

	lore = lore_by_name[name]
	if(!lore)
		lore = ""

	deity_names = deity_names_by_name[name]
	if(!deity_names)
		world.log << "ERROR IN SETTING UP RELIGION: [name] HAS NO DEITIES WHATSOVER. HAVE YOU SET UP RELIGIONS CORRECTLY?"
		deity_names = list("Error")

	gen_bible_info()

	update_structure_info()

/datum/religion/proc/update_structure_info()
	var/carpet_dir = carpet_dir_by_name[name]
	if(!carpet_dir)
		carpet_dir = 0

	/*
	var/lecturn_info = lecturn_info_by_name[name]
	if(lecturn_info)
		lecturn_icon_state = lecturn_info
	else
		lecturn_info_state = "general"
	*/

	var/pews_info = pews_info_by_name[name]
	if(pews_info)
		pews_icon_state = pews_info
	else
		pews_icon_state = "general"
	
	var/altar_info = altar_info_by_name[name]
	if(altar_info)
		altar_icon_state = altar_info
	else
		altar_icon_state = altar_info_by_name["Default"]

/datum/religion/proc/religify(areatype)
	var/list/to_religify = get_area_all_atoms(areatype)

	for(var/atom/A in to_religify)
		if(istype(A, /turf/simulated/floor) && A.icon_state == "carpetsymbol")
			A.dir = carpet_dir
		else if(istype(A, /obj/structure/stool/bed/chair/pew))
			var/obj/structure/stool/bed/chair/pew/P = A
			P.pew_icon = pews_icon_state
			P.update_icon()
		else if(istype(A, /obj/structure/altar_of_gods))
			var/obj/structure/altar_of_gods/G = A
			G.icon_state = altar_icon_state
			G.update_icon()

// This proc returns a bible object of this religion, spawning it at a given location.
/datum/religion/proc/spawn_bible(atom/location)
	var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(location)
	bible_info.apply_to(B)
	B.deity_name = pick(deity_names)
	B.god_lore = lore
	return B



// This subtype is used for integrating this system with current chaplain anything.
/datum/religion/chaplain

/datum/religion/chaplain/proc/gen_pos_bible_variants()
	var/list/variants = list()
	for(var/info_type in subtypesof(/datum/bible_info))
		var/datum/bible_info/BB = new info_type(src)
		if(!BB.name)
			continue
		variants[BB.name] = BB
	return variants

/datum/religion/chaplain/proc/create_by_chaplain(mob/living/carbon/human/chaplain)
	var/new_religion = sanitize_safe(input(chaplain, "You are the crew services officer. Would you like to change your religion? Default is [name], in SPACE.", "Name change", name), MAX_NAME_LEN)
	if(!new_religion)
		new_religion = name
	else
		name = new_religion
		deity_names = deity_names_by_name[name] ? deity_names_by_name[name] : list("Space-Jesus")

	feedback_set_details("religion_name","[new_religion]")

	var/deity_name = pick(deity_names)
	var/new_deity = sanitize_safe(input(chaplain, "Would you like to change your deity? Default is [deity_name].", "Name change", deity_name), MAX_NAME_LEN)
	if(!new_deity)
		new_deity = deity_name
	else
		// Currently no polyteistic support. ~Luduk
		deity_names = list(new_deity)

	gen_bible_info()

	var/obj/item/weapon/storage/bible/B = spawn_bible(chaplain)
	if(!B.god_lore)
		var/new_lore = sanitize_safe(input(chaplain, "You can come up with the lore of your god in [new_religion] religion.", "Lore for new god", ""), MAX_MESSAGE_LEN)
		B.god_lore = new_lore
		lore = new_lore

	chaplain.equip_to_slot_or_del(B, SLOT_L_HAND)

	var/list/bible_variants = gen_pos_bible_variants()

	var/accepted = FALSE
	var/choose_timeout = world.time + 1 MINUTE
	var/new_book_style = bible_info.name

	while(!accepted)
		if(!B)
			break // prevents possible runtime errors
		new_book_style = input(chaplain, "Which bible style would you like?") in bible_variants

		var/datum/bible_info/BB = bible_variants[new_book_style]
		if(BB)
			BB.apply_visuals_to(B)
			bible_info = BB

			chaplain.update_inv_l_hand() // so that it updates the bible's item_state in his hand

		switch(input(chaplain,"Look at your bible - is this what you want?") in list("Yes","No"))
			if("Yes")
				accepted = TRUE
			if("No")
				if(choose_timeout <= world.time)
					to_chat(chaplain, "Welp, out of time, buddy. You're stuck. Next time choose faster.")
					accepted = TRUE

	feedback_set_details("religion_deity","[new_deity]")
	feedback_set_details("religion_book","[new_book_style]")

	// Update the looks of the chapel.
	update_structure_info()
	religify(/area/station/civilian/chapel)

// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion/chaplain/proc/adjust_favor(amount = 0, mob/living/L)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if(favor + amount > max_favor)
		. = (max_favor - favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = between(0, favor + amount,  max_favor)

// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion/chaplain/proc/set_favor(amount = 0, mob/living/L)
	favor = between(0, amount, max_favor)
	return favor

// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion/chaplain/proc/on_riteuse(mob/living/user, obj/structure/altar_of_gods/AOG)

/datum/religion/chaplain/proc/satisfy_requirements(element, datum/aspect/A)
	return element <= A.power

// Give our gods all needed spells which in /list/spells
/datum/religion/chaplain/proc/give_god_spells(mob/living/simple_animal/shade/god/G)
	if(gods_list.len == 0)
		return

	var/datum/callback/pred = CALLBACK(src, .proc/satisfy_requirements)
	for(var/spell in allow_spell)
		var/obj/effect/proc_holder/spell/S = new spell()
		var/list/spell_aspects = S.needed_aspect

		if(is_sublist_assoc(spell_aspects, aspects, pred))
			spells |= spell

		QDEL_NULL(S)

	for(var/spell in spells)
		var/obj/effect/proc_holder/spell/S = new spell()
		for(var/datum/aspect/aspect in global.chaplain_religion.aspects)
			if(S.needed_aspect[aspect])
				S.divine_power *= aspect.power
		G.AddSpell(S)

// Generate new rite_list
/datum/religion/chaplain/proc/update_rites()
	if(rites_list.len != 0)
		var/listylist = generate_rites_list()
		rites_list = listylist

///Generates a list of rites with 'name' = 'type', used for examine altar_of_god
/datum/religion/chaplain/proc/generate_rites_list()
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
