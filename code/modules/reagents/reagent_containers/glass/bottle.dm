
//Not to be confused with /obj/item/weapon/reagent_containers/food/drinks/bottle

/obj/item/weapon/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "bottle1"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	flags = OPENCONTAINER
	volume = 30
	var/filler_margin_y = 11
	var/filler_height = 7
	var/current_offset = -1

/obj/item/weapon/reagent_containers/glass/bottle/atom_init()
	. = ..()
	if(!icon_state)
		icon_state = "bottle[rand(1,3)]"

/obj/item/weapon/reagent_containers/glass/bottle/update_icon()
	current_offset = show_filler_on_icon(filler_margin_y, filler_height, current_offset)

	overlays.Cut()
	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_bottle")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/glass/bottle/kyphotorin
	name = "kyphotorin bottle"
	desc = "A small bottle. Contains kyphotorin - used to recover bones."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/kyphotorin/atom_init()
	. = ..()
	reagents.add_reagent("kyphotorin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/toxin/atom_init()
	. = ..()
	reagents.add_reagent("toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine. Do not drink, it is very poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/synaptizine/atom_init()
	. = ..()
	reagents.add_reagent("synaptizine", 10)

/obj/item/weapon/reagent_containers/glass/bottle/phoron
	name = "phoron bottle"
	desc = "A small bottle of phoron. Do not drink, it is very poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/phoron/atom_init()
	. = ..()
	reagents.add_reagent("phoron", 5)

/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/cyanide/atom_init()
	. = ..()
	reagents.add_reagent("cyanide", 30)

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle of sleep toxins. Just the fumes make you sleepy."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/stoxin/atom_init()
	. = ..()
	reagents.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate/atom_init()
	. = ..()
	reagents.add_reagent("chloralhydrate", 15)		//Intentionally low since it is so strong. Still enough to knock someone out.

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/mutagen/atom_init()
	. = ..()
	reagents.add_reagent("mutagen", 30)

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/ammonia/atom_init()
	. = ..()
	reagents.add_reagent("ammonia", 30)

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine/atom_init()
	. = ..()
	reagents.add_reagent("diethylamine", 30)

/obj/item/weapon/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/flu_virion/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/advance/flu(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion
	name = "Epiglottis virion culture bottle"
	desc = "A small bottle. Contains Epiglottis virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/advance/voice_change(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion
	name = "Liver enhancement virion culture bottle"
	desc = "A small bottle. Contains liver enhancement virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/advance/heal(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion
	name = "Hullucigen virion culture bottle"
	desc = "A small bottle. Contains hullucigen virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/advance/hullucigen(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/pierrot_throat(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/cold/atom_init()
	. = ..()
	var/datum/disease/advance/F = new /datum/disease/advance/cold(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/random
	name = "Random culture bottle"
	desc = "A small bottle. Contains a random disease."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/random/atom_init()
	. = ..()
	var/datum/disease/advance/F = new(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/retrovirus/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

/obj/item/weapon/reagent_containers/glass/bottle/gbs/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(20)
	reagents = R
	R.my_atom = src
	var/datum/disease/F = new /datum/disease/gbs
	var/list/data = list("virus"= F)
	R.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/fake_gbs(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)
/*
/obj/item/weapon/reagent_containers/glass/bottle/rhumba_beat
	name = "Rhumba Beat culture bottle"
	desc = "A small bottle. Contains The Rhumba Beat culture in synthblood medium."//Or simply - General BullShit
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

/obj/item/weapon/reagent_containers/glass/bottle/rhumba_beat/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(20)
	reagents = R
	R.my_atom = src
	var/datum/disease/F = new /datum/disease/rhumba_beat
	var/list/data = list("virus"= F)
	R.add_reagent("blood", 20, data)
*/

/obj/item/weapon/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/brainrot/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/brainrot(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/magnitis/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/magnitis(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/wizarditis/atom_init()
	. = ..()
	var/datum/disease/F = new /datum/disease/wizarditis(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/pacid/atom_init()
	. = ..()
	reagents.add_reagent("pacid", 30)


/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine/atom_init()
	. = ..()
	reagents.add_reagent("adminordrazine", 30)


/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin/atom_init()
	. = ..()
	reagents.add_reagent("capsaicin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/frostoil/atom_init()
	. = ..()
	reagents.add_reagent("frostoil", 30)


/obj/item/weapon/reagent_containers/glass/bottle/chefspecial
	name = "Chef's Special bottle"
	desc = "A small bottle of Chef's Special. How fragrantly!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/weapon/reagent_containers/glass/bottle/chefspecial/atom_init()
	. = ..()
	reagents.add_reagent("chefspecial", 5)

/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin
	name = "alphaamanitin bottle"
	desc = "A small bottle of alpha-amanitin. Did you like mushrooms?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin/atom_init()
	. = ..()
	reagents.add_reagent("alphaamanitin", 30)


/obj/item/weapon/reagent_containers/glass/bottle/carpotoxin
	name = "carpotoxin bottle"
	desc = "A small bottle of carpotoxin. Upon receipt of substance no carp was not injured."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/carpotoxin/atom_init()
	. = ..()
	reagents.add_reagent("carpotoxin", 30)


/obj/item/weapon/reagent_containers/glass/bottle/zombiepowder
	name = "zombiepowder bottle"
	desc = "A small bottle of zombiepowder. We are not responsible for the uprising of dead."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/zombiepowder/atom_init()
	. = ..()
	reagents.add_reagent("zombiepowder", 30)


/obj/item/weapon/reagent_containers/glass/bottle/peridaxon
	name = "peridaxon bottle"
	desc = "A small bottle of peridaxon."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/peridaxon/atom_init()
	. = ..()
	reagents.add_reagent("peridaxon", 30)

/obj/item/weapon/reagent_containers/glass/bottle/lexorin
	name = "lexorin bottle"
	desc = "A small bottle of peridaxon."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"

/obj/item/weapon/reagent_containers/glass/bottle/lexorin/atom_init()
	. = ..()
	reagents.add_reagent("lexorin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/nanites
	name = "nantes bottle"
	desc = "A small bottle of peridaxon."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/nanites/atom_init()
	. = ..()
	reagents.add_reagent("nanites", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye
	name = "hair dye bottle"
	desc = "A small bottle of hair dye."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/white
	name = "white hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/red
	name = "red hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blue
	name = "blue hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/green
	name = "green hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/black
	name = "black hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/brown
	name = "brown hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blond
	name = "blond hair dye bottle"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/white/atom_init()
	. = ..()
	reagents.add_reagent("whitehairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/red/atom_init()
	. = ..()
	reagents.add_reagent("redhairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/green/atom_init()
	. = ..()
	reagents.add_reagent("greenhairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blue/atom_init()
	. = ..()
	reagents.add_reagent("bluehairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/black/atom_init()
	. = ..()
	reagents.add_reagent("blackhairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/brown/atom_init()
	. = ..()
	reagents.add_reagent("brownhairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blond/atom_init()
	. = ..()
	reagents.add_reagent("blondhairdye", 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_growth_accelerator
	name = "hair growth accelerator bottle"
	desc = "A small bottle of hair growth accelerator."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/hair_growth_accelerator/atom_init()
	. = ..()
	reagents.add_reagent("hair_growth_accelerator", 30)
