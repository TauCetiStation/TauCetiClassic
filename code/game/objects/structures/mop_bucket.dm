/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/atom_init()
	create_reagents(100)
	. = ..()
	mopbucket_list += src

/obj/structure/mopbucket/Destroy()
	mopbucket_list -= src
	return ..()

/obj/structure/mopbucket/is_open_container()
	return TRUE

/obj/structure/mopbucket/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[src] contains [reagents.total_volume] unit\s of water!")

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>[src] is out of water!</span>")
		else
			reagents.trans_to(I, 5)
			user.SetNextMove(CLICK_CD_INTERACT)
			to_chat(user, "<span class='notice'>You wet [I] in [src].</span>")
			playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER, 25)
	else
		..()

/obj/structure/mopbucket/on_reagent_change()
	update_icon()

/obj/structure/mopbucket/update_icon()
	cut_overlays()
	if(reagents.total_volume > 1)
		add_overlay("mopbucket_water")
