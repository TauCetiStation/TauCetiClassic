/obj/item/weapon/reagent_containers/blood
	name = "bloodpack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	volume = 200

	var/blood_type = null

/obj/item/weapon/reagent_containers/blood/atom_init()
	. = ..()
	if(blood_type != null)
		reagents.add_reagent("blood", 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_icon()

/obj/item/weapon/reagent_containers/blood/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/blood/update_icon()
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(0 to 9)			icon_state = "empty"
		if(10 to 50) 		icon_state = "half"
		if(51 to INFINITY)	icon_state = "full"

/obj/item/weapon/reagent_containers/blood/APlus
	name = "bloodpack A+"
	blood_type = "A+"

/obj/item/weapon/reagent_containers/blood/AMinus
	name = "bloodpack A-"
	blood_type = "A-"

/obj/item/weapon/reagent_containers/blood/BPlus
	name = "bloodpack B+"
	blood_type = "B+"

/obj/item/weapon/reagent_containers/blood/BMinus
	name = "bloodpack B-"
	blood_type = "B-"

/obj/item/weapon/reagent_containers/blood/OPlus
	name = "bloodpack O+"
	blood_type = "O+"

/obj/item/weapon/reagent_containers/blood/OMinus
	name = "bloodpack O-"
	blood_type = "O-"

/obj/item/weapon/reagent_containers/blood/empty
	name = "empty bloodpack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "empty"
