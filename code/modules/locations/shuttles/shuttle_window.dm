/obj/structure/window/reinforced/shuttle
	icon = 'code/modules/locations/shuttles/shuttle.dmi'
	dir = SOUTHWEST
	can_merge = 0

/obj/structure/window/reinforced/shuttle/attackby(obj/item/weapon/W, mob/user)
	if(!istype(W)) return//I really wish I did not need this

	if(istype(W, /obj/item/weapon/airlock_painter))
		change_paintjob(W, user)
		return
	user.SetNextMove(CLICK_CD_MELEE)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/state = G.state
			qdel(W)	//gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.apply_damage(7)
					take_damage(7)
					visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
				if(2)
					if (prob(50))
						M.Weaken(1)
					M.apply_damage(10)
					take_damage(9)
					visible_message("<span class='warning'><b>[user] bashes [M] against \the [src]!</b></span>")
				if(3)
					M.Weaken(5)
					M.apply_damage(20)
					take_damage(12)
					visible_message("<span class='warning'><big><b>[user] crushes [M] against \the [src]!</b></big></span>")
			return
	else if(user.a_intent == INTENT_HARM)
		if(W.damtype == BRUTE || W.damtype == BURN)
			take_damage(W.force)
			if(health <= 7)
				anchored = 0
				update_nearby_icons()
				step(src, get_dir(user, src))
		else
			playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
		return ..()

/obj/structure/window/reinforced/shuttle/mining
	icon = 'code/modules/locations/shuttles/shuttle_mining.dmi'
	dir = SOUTHWEST
	icon_state = "1"

/obj/structure/window/reinforced/shuttle/default
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	dir = SOUTHWEST

/obj/structure/window/reinforced/shuttle/update_icon()
	return

/obj/structure/shuttle/window/new_shuttle
	icon = 'code/modules/locations/shuttles/shuttle.dmi'
