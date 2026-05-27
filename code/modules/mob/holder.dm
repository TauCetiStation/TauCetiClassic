// Helper object for picking dionaea (and other creatures) up.
/obj/item/weapon/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_FLAGS_HEAD

/obj/item/weapon/holder/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/holder/atom_init_late()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/holder/process()
	if(istype(loc,/turf) || !(contents.len))
		for(var/mob/M in contents)
			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))
			M.reset_view()
		qdel(src)

/obj/item/weapon/holder/pickup(mob/living/user)
	. = ..()
	user.add_status_flags(PASSEMOTES)

/obj/item/weapon/holder/dropped(mob/living/carbon/user)
	..()
	user.remove_passemotes_flag()

/obj/item/weapon/holder/attackby(obj/item/I, mob/user, params)
	for(var/mob/M in contents)
		M.attackby(I, user, params)

// Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(mob/living/carbon/human/grabber)
	if(!istype(grabber))
		return
	if(!holder_type || buckled || anchored)
		return
	var/obj/item/weapon/holder/H = new holder_type(loc)
	forceMove(H)
	H.name = src.name
	H.attack_hand(grabber)

	to_chat(grabber, "You scoop up [src].")
	to_chat(src, "[grabber] scoops you up.")
	LAssailant = grabber

// Mob specific holders.
// todo: need parent holder/mob/* object
/obj/item/weapon/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"
	origin_tech = "magnets=3;biotech=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/diona/podkid
	name = "podkid"
	icon_state = "podkid"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	origin_tech = "magnets=3;engineering=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/syndi_drone
	name = "suspicious drone"
	desc = "It's a small maintenance robot. Why the hell do his eyes glow red?"
	icon_state = "drone_syndi"
	origin_tech = "programming=2;engineering=5;syndicate=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/syndi_drone/disguised
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/malf_drone
	name = "strange drone"
	desc = "Крайне странный дрон. В его мозгу поплавилась не одна микросхема."
	icon_state = "drone"
	origin_tech = "magnets=3;engineering=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/cat
	name = "cat"
	desc = "It's a cat. Meow."
	icon_state = "cat"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse
	name = "mouse"
	desc = "It's a small rodent."
	icon_state = "mouse_gray"
	w_class = SIZE_MINUSCULE
	flags = HEAR_PASS_SAY
	var/bitesize = 3

/obj/item/weapon/holder/mouse/atom_init()
	. = ..()
	create_reagents(6)

/obj/item/weapon/holder/mouse/pickup(mob/living/user)
	. = ..()
	sync_reagents_from_mouse()

/obj/item/weapon/holder/mouse/dropped(mob/living/carbon/user)
	sync_reagents_to_mouse()
	return ..()

/obj/item/weapon/holder/mouse/process()
	if(istype(loc,/turf) || !(contents.len))
		sync_reagents_to_mouse()
	return ..()

/obj/item/weapon/holder/mouse/attack_self(mob/user)
	if(isliving(user))
		return attack(user, user)
	return ..()

/obj/item/weapon/holder/mouse/proc/get_held_edible_animal()
	return locate(/mob/living/simple_animal/mouse) in contents

/obj/item/weapon/holder/mouse/proc/sync_reagents_from_mouse()
	var/mob/living/simple_animal/M = get_held_edible_animal()
	if(!M || !reagents)
		return
	reagents.clear_reagents()
	if(M.edible_nutriment > 0)
		reagents.add_reagent("nutriment", M.edible_nutriment)
	if(M.edible_protein > 0)
		reagents.add_reagent("protein", M.edible_protein)

/obj/item/weapon/holder/mouse/proc/sync_reagents_to_mouse()
	var/mob/living/simple_animal/M = get_held_edible_animal()
	if(!M || !reagents)
		return
	M.edible_nutriment = reagents.get_reagent_amount("nutriment")
	M.edible_protein = reagents.get_reagent_amount("protein")

/obj/item/weapon/holder/mouse/proc/reagent_list_text()
	if(reagents?.reagent_list?.len)
		var/data
		for(var/datum/reagent/R in reagents.reagent_list)
			data += "[R.id]([R.volume] units); "
		return data
	return "No reagents"

/obj/item/weapon/holder/mouse/attack(mob/living/M, mob/user, def_zone, silent = FALSE)
	if(!istype(M))
		return FALSE

	var/mob/living/carbon/human/H = M
	if(!istype(H) || !(H.species.name in list(TAJARAN, UNATHI, VOX)))
		if(M == user)
			to_chat(user, "<span class='warning'>Вам противно есть [CASE(src, GENITIVE_CASE)].</span>")
		else
			to_chat(user, "<span class='warning'>[M] не выглядит заинтересованным в поедании [CASE(src, GENITIVE_CASE)].</span>")
		return FALSE

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='rose'>От [CASE(src, GENITIVE_CASE)] ничего не осталось!</span>")
		user.drop_from_inventory(src)
		qdel(src)
		return FALSE

	if(!CanEat(user, M, src, "eat"))
		return FALSE

	var/fullness = H.get_satiation()
	if(H == user)
		if(fullness > (NUTRITION_LEVEL_FAT * (1 + H.overeatduration / 2000) + 100))
			to_chat(H, "<span class='rose'>Вы больше не в силах съесть даже хвост от [CASE(src, GENITIVE_CASE)].</span>")
			return FALSE
		else if(fullness > NUTRITION_LEVEL_NORMAL)
			to_chat(H, "<span class='notice'>Вы нехотя жуёте [CASE(src, ACCUSATIVE_CASE)].</span>")
		else if(fullness > NUTRITION_LEVEL_FED)
			to_chat(H, "<span class='notice'>Вы откусываете кусок от \the [src].</span>")
		else if(fullness > NUTRITION_LEVEL_HUNGRY)
			to_chat(H, "<span class='notice'>Вы голодно начинаете есть \the [src].</span>")
		else
			to_chat(H, "<span class='rose'>Вы жадно пожираете \the [src]!</span>")
	else
		if(fullness > (NUTRITION_LEVEL_FAT * (1 + H.overeatduration / 2000) + 100))
			user.visible_message("<span class='rose'>[user] не может заставить [H] проглотить ещё немного [src].</span>")
			return FALSE
		H.visible_message("<span class='rose'>[user] пытается скормить [H] [CASE(src, ACCUSATIVE_CASE)].</span>", \
			"<span class='warning'><B>[user]</B> пытается скормить вам <B>[CASE(src, ACCUSATIVE_CASE)]</B>.</span>")
		if(!do_mob(user, H))
			return FALSE
		H.log_combat(user, "fed [name], reagents: [reagent_list_text()] (INTENT: [uppertext(user.a_intent)])")
		H.visible_message("<span class='rose'>[user] скармливает [H] [CASE(src, ACCUSATIVE_CASE)].</span>", \
			"<span class='warning'><B>[user]</B> скармливает вам <B>[src]</B>.</span>")

	playsound(H, 'sound/items/eatfood.ogg', VOL_EFFECTS_MASTER, rand(20, 50))
	reagents.trans_to_ingest(H, min(bitesize, reagents.total_volume))
	sync_reagents_to_mouse()
	SEND_SIGNAL(H, COMSIG_HUMAN_ON_CONSUME, src)

	if(!reagents.total_volume)
		for(var/mob/living/simple_animal/eaten_animal in contents)
			eaten_animal.ghostize(bancheck = TRUE)
			qdel(eaten_animal)
		if(!silent)
			H.visible_message("<span class='notice'>[H] доедает [CASE(src, ACCUSATIVE_CASE)].</span>", "<span class='notice'>Вы доедаете [CASE(src, ACCUSATIVE_CASE)].</span>")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "food_type", /datum/mood_event/natural_food)
		SSStatistics.score.foodeaten++
		user.drop_from_inventory(src)
		qdel(src)
	return TRUE

/obj/item/weapon/holder/mouse/gray
	icon_state = "mouse_gray"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/white
	icon_state = "mouse_white"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/brown
	icon_state = "mouse_brown"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/nuke
	icon_state = "mouse_nuke"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/lizard
	parent_type = /obj/item/weapon/holder/mouse
	name = "lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	w_class = SIZE_MINUSCULE
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/lizard/get_held_edible_animal()
	return locate(/mob/living/simple_animal/lizard) in contents

/obj/item/weapon/holder/monkey
	name = "monkey"
	desc = "It's a monkey. Ook."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "monkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/farwa
	name = "farwa"
	desc = "It's a farwa."
	icon_state = "tajkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/stok
	name = "stok"
	desc = "It's a stok. stok."
	icon_state = "stokkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/neaera
	name = "neaera"
	desc = "It's a neaera."
	icon_state = "skrellkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/pluvia
	name = "pluvian"
	desc = "Оно никогда не существовало в дикой природе.."
	icon_state = "pluvian"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/punpun
	name = "punpun"
	icon_state = "punpun1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/nabber
	name = "larva"
	desc = "It's a sugar larva."
	icon_state = "nabber"
	flags = HEAR_PASS_SAY
	slot_flags = 0

/obj/item/weapon/holder/moth_small
	name = "small moth"
	desc = "It's a sugar moth."
	icon_state = "moth_plushie"
	flags = HEAR_PASS_SAY
	slot_flags = 0

/obj/item/weapon/holder/mothroach
	name = "mothroach"
	desc = "It's a sugar mothroach."
	icon_state = "mothroach"
	flags = HEAR_PASS_SAY
	slot_flags = 0

/obj/item/weapon/holder/snake
	name = "snake"
	desc = "It's a sugar larva."
	icon_state = "snake"
	flags = HEAR_PASS_SAY
	slot_flags = 0
