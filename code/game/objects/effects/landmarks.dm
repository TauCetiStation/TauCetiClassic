/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = TRUE
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/New()
	..()
	tag = text("landmark*[]", name)
	landmarks_list += src

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	return ..()

/obj/effect/landmark/atom_init()
	. = ..()

	switch(name)
		if("shuttle")
			shuttle_z = z
			return INITIALIZE_HINT_QDEL

		if("airtunnel_stop")
			airtunnel_stop = x

		if("airtunnel_start")
			airtunnel_start = x

		if("airtunnel_bottom")
			airtunnel_bottom = y

		if ("awaystart")
			awaydestinations += src

		if("monkey")
			monkeystart += loc
			return INITIALIZE_HINT_QDEL
		if("wizard")
			wizardstart += loc
			return INITIALIZE_HINT_QDEL
		//prisoners
		if("prisonwarp")
			prisonwarp += loc
			return INITIALIZE_HINT_QDEL
	//	if("mazewarp")
	//		mazewarp += loc
		if("Holding Facility")
			holdingfacility += loc
		if("tdome1")
			tdome1 += loc
		if("tdome2")
			tdome2 += loc
		if("tdomeadmin")
			tdomeadmin += loc
		if("tdomeobserve")
			tdomeobserve += loc
		//not prisoners
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			return INITIALIZE_HINT_QDEL
		if("blobstart")
			blobstart += loc
			return INITIALIZE_HINT_QDEL
		if("xeno_spawn")
			xeno_spawn += loc
			return INITIALIZE_HINT_QDEL
		if("ninjastart")
			ninjastart += loc
			return INITIALIZE_HINT_QDEL

/obj/effect/landmark/sound_source
	name = "Sound Source"

/obj/effect/landmark/sound_source/shuttle_docking
	name = "Shuttle Docking"

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = TRUE

/obj/effect/landmark/start/New()
	..()
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/new_player
	name = "New Player"

// Must be on New() rather than Initialize, because players will
// join before SSatom initializes everything.
/obj/effect/landmark/start/new_player/New(loc)
	..()
	newplayer_start += loc

/obj/effect/landmark/start/new_player/atom_init(mapload)
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/latejoin
	name = "JoinLate"

/obj/effect/landmark/latejoin/New(loc)
	..()
	latejoin += loc

/obj/effect/landmark/latejoin/atom_init(mapload)
	..()
	return INITIALIZE_HINT_QDEL

//Costume spawner landmarks

/obj/effect/landmark/costume/atom_init() // costume spawner, selects a random subclass and disappears
	..()
	var/list/options = typesof(/obj/effect/landmark/costume)
	var/PICK = options[rand(1, options.len)]
	new PICK(loc)
	return INITIALIZE_HINT_QDEL

//SUBCLASSES.  Spawn a bunch of items and disappear likewise
/obj/effect/landmark/costume/chicken/atom_init()
	..()
	new /obj/item/clothing/suit/chickensuit(loc)
	new /obj/item/clothing/head/chicken(loc)
	new /obj/item/weapon/reagent_containers/food/snacks/egg(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/gladiator/atom_init()
	..()
	new /obj/item/clothing/under/gladiator(loc)
	new /obj/item/clothing/head/helmet/gladiator(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/madscientist/atom_init()
	..()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(loc)
	new /obj/item/clothing/head/flatcap(loc)
	new /obj/item/clothing/suit/storage/labcoat/mad(loc)
	new /obj/item/clothing/glasses/gglasses(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/elpresidente/atom_init()
	..()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(loc)
	new /obj/item/clothing/head/flatcap(loc)
	new /obj/item/clothing/mask/cigarette/cigar/havana(loc)
	new /obj/item/clothing/shoes/boots(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/nyangirl/atom_init()
	..()
	new /obj/item/clothing/under/schoolgirl(loc)
	new /obj/item/clothing/head/kitty(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/maid/atom_init()
	..()
	new /obj/item/clothing/under/blackskirt(loc)
	var/CHOICE = pick(/obj/item/clothing/head/chep, /obj/item/clothing/head/rabbitears)
	new CHOICE(loc)
	new /obj/item/clothing/glasses/sunglasses/blindfold(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/butler/atom_init()
	..()
	new /obj/item/clothing/suit/wcoat(loc)
	new /obj/item/clothing/under/suit_jacket(loc)
	new /obj/item/clothing/head/that(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/scratch/atom_init()
	..()
	new /obj/item/clothing/gloves/white(loc)
	new /obj/item/clothing/shoes/white(loc)
	new /obj/item/clothing/under/scratch(loc)
	if (prob(30))
		new /obj/item/clothing/head/cueball(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/highlander/atom_init()
	..()
	new /obj/item/clothing/under/kilt(loc)
	new /obj/item/clothing/head/beret/red(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/prig/atom_init()
	..()
	new /obj/item/clothing/suit/wcoat(loc)
	new /obj/item/clothing/glasses/monocle(loc)
	var/CHOICE = pick( /obj/item/clothing/head/bowler, /obj/item/clothing/head/that)
	new CHOICE(loc)
	new /obj/item/clothing/shoes/black(loc)
	new /obj/item/weapon/cane(loc)
	new /obj/item/clothing/under/sl_suit(loc)
	new /obj/item/clothing/mask/fakemoustache(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/plaguedoctor/atom_init()
	..()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(loc)
	new /obj/item/clothing/head/plaguedoctorhat(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/nightowl/atom_init()
	..()
	new /obj/item/clothing/under/owl(loc)
	new /obj/item/clothing/mask/gas/owl_mask(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/waiter/atom_init()
	..()
	new /obj/item/clothing/under/waiter(loc)
	var/CHOICE = pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
	new CHOICE(loc)
	new /obj/item/clothing/suit/apron(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/pirate/atom_init()
	..()
	new /obj/item/clothing/under/pirate(loc)
	new /obj/item/clothing/suit/pirate(loc)
	var/CHOICE = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/head/bandana )
	new CHOICE(loc)
	new /obj/item/clothing/glasses/eyepatch(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/commie/atom_init()
	..()
	new /obj/item/clothing/under/soviet(loc)
	new /obj/item/clothing/head/ushanka(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/imperium_monk/atom_init()
	..()
	new /obj/item/clothing/suit/imperium_monk(loc)
	if (prob(25))
		new /obj/item/clothing/mask/gas/cyborg(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/holiday_priest/atom_init()
	..()
	new /obj/item/clothing/suit/holidaypriest(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/marisawizard/fake/atom_init()
	..()
	new /obj/item/clothing/head/wizard/marisa/fake(loc)
	new/obj/item/clothing/suit/wizrobe/marisa/fake(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/cutewitch/atom_init()
	..()
	new /obj/item/clothing/under/sundress(loc)
	new /obj/item/clothing/head/witchwig(loc)
	new /obj/item/weapon/staff/broom(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/fakewizard/atom_init()
	..()
	new /obj/item/clothing/suit/wizrobe/fake(loc)
	new /obj/item/clothing/head/wizard/fake(loc)
	new /obj/item/weapon/staff/(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/sexyclown/atom_init()
	..()
	new /obj/item/clothing/mask/gas/sexyclown(loc)
	new /obj/item/clothing/under/sexyclown(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/sexymime/atom_init()
	..()
	new /obj/item/clothing/mask/gas/sexymime(loc)
	new /obj/item/clothing/under/sexymime(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/blockway
	density = TRUE
