////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = OPENCONTAINER
	slot_flags = SLOT_FLAGS_BELT

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/item/weapon/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "\red [src] is empty.")
		return
	if(!istype(M))
		return
	if(reagents.total_volume && M.try_inject(user, TRUE, TRUE, TRUE, TRUE))
		src.reagents.reaction(M, INGEST)
		if(M.reagents)

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.key]). Reagents: [contained]</font>")
			msg_admin_attack("[user.name] ([user.ckey]) injected [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			to_chat(user, "\blue [trans] units injected. [reagents.total_volume] units remaining in [src].")

	return

/obj/item/weapon/reagent_containers/hypospray/cmo //We need "another" hypo for CMO

/obj/item/weapon/reagent_containers/hypospray/cmo/atom_init()
	. = ..()
	reagents.add_reagent("tricordrazine", 30)


/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	volume = 5

/obj/item/weapon/reagent_containers/hypospray/autoinjector/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 5)
	flags &= ~OPENCONTAINER
	amount_per_transfer_from_this = volume
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack //goliath kiting
	name = "stimpack"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack/atom_init()
	. = ..()
	reagents.add_reagent("coffee", 13)
	reagents.add_reagent("hyperzine", 2)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M, mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"
