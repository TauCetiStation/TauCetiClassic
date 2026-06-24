/obj/item/weapon/reagent_containers/bio_supplements_cartridge
	name = "Bio-BADs-V cartridge"
	desc = "This cartridge contains a liquid that looks far from pleasant. Perhaps there's a reason it was sealed so tightly."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bio_cartridge_w"
	flags = OPENCONTAINER
	w_class = SIZE_TINY
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 25, 50)

/obj/item/weapon/reagent_containers/bio_supplements_cartridge/atom_init()
	. = ..()
	reagents.add_reagent("bio_supplements", 50)

/obj/item/weapon/reagent_containers/bio_supplements_cartridge/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/bio_supplements_cartridge/update_icon()
	var/ratio = reagents.total_volume / volume
	var/suffix
	if(ratio > 0.5)
		suffix = ""
	else if(ratio > 0)
		suffix = "50"
	else
		suffix = "0"

	item_state = "bio_cartridge[suffix]"
	item_state_world = "bio_cartridge[suffix]_w"
	item_state_inventory = "bio_cartridge[suffix]"
	update_world_icon()

/obj/item/weapon/reagent_containers/bio_supplements_cartridge/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!reagents.total_volume)
		return
	if(target.is_open_container() && target.reagents)
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return
		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units to [target].</span>")
		playsound(src, 'sound/effects/Liquid_transfer_mono.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/reagent_containers/bio_supplements_cartridge/empty

/obj/item/weapon/reagent_containers/bio_supplements_cartridge/empty/atom_init()
	. = ..()
	reagents.clear_reagents()
