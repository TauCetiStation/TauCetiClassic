/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	pressure_resistance = 5
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite


/obj/structure/mopbucket/New()
	create_reagents(100)


/obj/structure/mopbucket/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[src] contains [reagents.total_volume] unit\s of water!")


/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "[src] is out of water!</span>")
		else
			reagents.trans_to(I, 5)
			to_chat(user, "<span class='notice'>You wet [I] in [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/structure/mopbucket/on_reagent_change()
	update_icon()

/obj/structure/mopbucket/update_icon()
	overlays.Cut()
	if(reagents.total_volume > 1)
		overlays += "mopbucket_water"
