
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

	cut_overlays()
	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_bottle")
		add_overlay(lid)

/obj/item/weapon/reagent_containers/glass/bottle/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("inaprovaline" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/kyphotorin
	name = "kyphotorin bottle"
	desc = "A small bottle. Contains kyphotorin - used for treatment. Only works at high temperature."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("kyphotorin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("toxin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine. Do not drink, it is very poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("synaptizine" = 5)

/obj/item/weapon/reagent_containers/glass/bottle/phoron
	name = "phoron bottle"
	desc = "A small bottle of phoron. Do not drink, it is very poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("phoron" = 5)

/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("cyanide" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle of sleep toxins. Just the fumes make you sleepy."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("stoxin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("chloralhydrate" = 15)

/obj/item/weapon/reagent_containers/glass/bottle/sanguisacid
	name = "Sanguis acid Bottle"
	desc = "A small bottle of Sanguis Acid. Burns the blood inside the body. Only works on humanoids."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("sanguisacid" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/bonebreaker
	name = "BB EX-01 Bottle"
	desc = "A small bottle of BB EX-01, also known as Bonebreaker toxin."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("bonebreaker" = 5)

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("anti_toxin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("mutagen" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("ammonia" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("diethylamine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("pacid" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/acid
	name = "Sulphuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Sulphuric Acid"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("sacid" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "bottle1"
	list_reagents = list("adminordrazine" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	list_reagents = list("capsaicin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("frostoil" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/chefspecial
	name = "Chef's Special bottle"
	desc = "A small bottle of Chef's Special. How fragrantly!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	list_reagents = list("chefspecial" = 5)

/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin
	name = "alphaamanitin bottle"
	desc = "A small bottle of alpha-amanitin. Did you like mushrooms?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("alphaamanitin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin/syndie
	list_reagents = list("alphaamanitin" = 20)

/obj/item/weapon/reagent_containers/glass/bottle/carpotoxin
	name = "carpotoxin bottle"
	desc = "A small bottle of carpotoxin. Upon receipt of substance no carp was not injured."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("carpotoxin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/zombiepowder
	name = "zombiepowder bottle"
	desc = "A small bottle of zombiepowder. We are not responsible for the uprising of dead."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("zombiepowder" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/ambrosium
	name = "ambrosium bottle"
	desc = "A small bottle of ambrosium. It smells sweet."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("ambrosium" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/jenkem
	name = "space jenkem bottle"
	desc = "A small bottle of space jenkem. Say goodbye to your liver if you wanna try this."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("jenkem" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/peridaxon
	name = "peridaxon bottle"
	desc = "A small bottle of peridaxon."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("peridaxon" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/lexorin
	name = "lexorin bottle"
	desc = "A small bottle of lexorin."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	list_reagents = list("lexorin" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye
	name = "hair dye bottle"
	desc = "A small bottle of hair dye."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/white
	name = "white hair dye bottle"
	list_reagents = list("whitehairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/red
	name = "red hair dye bottle"
	list_reagents = list("redhairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blue
	name = "blue hair dye bottle"
	list_reagents = list("bluehairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/green
	name = "green hair dye bottle"
	list_reagents = list("greenhairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/black
	name = "black hair dye bottle"
	list_reagents = list("blackhairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/brown
	name = "brown hair dye bottle"
	list_reagents = list("brownhairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blond
	name = "blond hair dye bottle"
	list_reagents = list("blondhairdye" = 30)

/obj/item/weapon/reagent_containers/glass/bottle/hair_growth_accelerator
	name = "hair growth accelerator bottle"
	desc = "A small bottle of hair growth accelerator."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle2"
	list_reagents = list("hair_growth_accelerator" = 30)
