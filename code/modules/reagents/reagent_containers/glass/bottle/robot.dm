
/obj/item/weapon/reagent_containers/glass/bottle/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = OPENCONTAINER
	volume = 60
	var/reagent = ""
	resistance_flags = FULL_INDESTRUCTIBLE
	fragile = FALSE

/obj/item/weapon/reagent_containers/glass/bottle/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	reagent = "inaprovaline"

/obj/item/weapon/reagent_containers/glass/bottle/robot/inaprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 60)


/obj/item/weapon/reagent_containers/glass/bottle/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	reagent = "anti_toxin"

/obj/item/weapon/reagent_containers/glass/bottle/robot/antitoxin/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 60)
