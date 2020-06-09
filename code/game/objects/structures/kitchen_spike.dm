//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = TRUE
	anchored = FALSE

/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(anchored && istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.use(4))
			to_chat(user, "<span class='notice'>You add spikes to the frame.</span>")
			var/obj/F = new /obj/structure/kitchenspike(src.loc)
			transfer_fingerprints_to(F)
			qdel(src)
	else
		..()

/obj/structure/kitchenspike
	name = "meatspike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = FALSE
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = FALSE

/obj/structure/kitchenspike/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/kitchenspike/attackby(obj/item/I, mob/user)
	if(iscrowbar(I))
		if(!src.buckled_mob)
			if(user.is_busy()) return
			if(I.use_tool(src, user, 20, volume = 100))
				to_chat(user, "<span class='notice'>You pry the spikes out of the frame.</span>")
				new /obj/item/stack/rods(loc, 4)
				var/obj/F = new /obj/structure/kitchenspike_frame(src.loc,)
				transfer_fingerprints_to(F)
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't do that while something's on the spike!</span>")
	else if(istype(I, /obj/item/weapon/grab))
		if(user.is_busy())
			return

		var/obj/item/weapon/grab/G = I
		if(istype(G.affecting, /mob/living))
			if(!buckled_mob)
				if(do_mob(user, src, 120))
					if(buckled_mob) //to prevent spam/queing up attacks
						return
					if(G.affecting.buckled)
						return
					var/mob/living/H = G.affecting
					playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER, 25)
					H.visible_message("<span class='danger'>[user] slams [G.affecting] onto the meat spike!</span>", \
					                  "<span class='userdanger'>[user] slams you onto the meat spike!</span>", \
					                  "<span class='notice'>You hear a squishy wet noise.</span>")
					H.forceMove(src.loc)
					H.emote("scream")
					if(istype(H, /mob/living/carbon)) //So you don't get human blood when you spike a giant spidere
						var/turf/simulated/pos = get_turf(H)
						pos.add_blood_floor(H)
					H.adjustBruteLoss(30)
					H.buckled = src
					H.dir = 2
					buckled_mob = H
					var/matrix/m = matrix(H.transform)
					m.Turn(180)
					animate(H, transform = m, time = 3)
					H.pixel_y = H.default_pixel_y
					qdel(G)
		else
			to_chat(user, "<span class='danger'>You can't use that on the spike!</span>")
	else
		..()

/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/carbon/human/user)
	if(buckled_mob)
		if(user.is_busy())
			return

		var/mob/living/L = buckled_mob
		if(L != user)
			if(user.is_busy()) return
			L.visible_message(\
				"<span class='notice'>[user.name] tries to pull [L.name] free of the [src]!</span>",\
				"<span class='warning'>[user.name] is trying to pull you off the [src], opening up fresh wounds!</span>",\
				"<span class='italics'>You hear a squishy wet noise.</span>")
			if(!do_after(user, 300, target = user))
				if(L && L.buckled)
					L.visible_message(\
					"<span class'notice'>[user.name] fails to free [L.name]!</span>",\
					"<span class='warning'>[user.name] fails to pull you off of the [src].</span>")
				return

		else
			L.visible_message(\
			"<span class='warning'>[L.name] struggles to break free from the [src]!</span>",\
			"<span class='notice'>You struggle to break free from the [src], exacerbating your wounds! (Stay still for two minutes.)</span>",\
			"<span class='italics'>You hear a wet squishing noise..</span>")
			L.adjustBruteLoss(15)
			if(!do_after(L, 1200, target = src))
				if(L && L.buckled)
					to_chat(L, "<span class='warning'>You fail to free yourself!</span>")
				return

		if(!L.buckled)
			return

		var/matrix/m = matrix(L.transform)
		m.Turn(180)
		animate(L, transform = m, time = 3)
		L.pixel_y = L.default_pixel_y
		L.adjustBruteLoss(15)
		visible_message(text("<span class='danger'>[L] falls free of the [src]!</span>"))
		unbuckle_mob()
		L.emote("scream")
		L.AdjustWeakened(10)
