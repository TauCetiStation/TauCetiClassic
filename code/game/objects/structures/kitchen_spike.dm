//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = TRUE
	anchored = FALSE

	max_integrity = 200
	resistance_flags = CAN_BE_HIT

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

/obj/structure/kitchenspike_frame/deconstruct(disassembled)
	new /obj/item/stack/sheet/metal(loc, 4)
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

	max_integrity = 250
	resistance_flags = CAN_BE_HIT

/obj/structure/kitchenspike/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/kitchenspike/attackby(obj/item/I, mob/user)
	if(isprying(I))
		if(buckled_mob)
			to_chat(user, "<span class='notice'>You can't do that while something's on the spike!</span>")
			return
		if(user.is_busy() || !I.use_tool(src, user, 2 SECONDS, volume = 100))
			return
		to_chat(user, "<span class='notice'>You pry the spikes out of the frame.</span>")
		deconstruct(TRUE)
		return

	else if(istype(I, /obj/item/weapon/grab))
		if(user.is_busy())
			return

		var/obj/item/weapon/grab/G = I
		if(!isliving(G.affecting))
			to_chat(user, "<span class='danger'>You can't use that on the spike!</span>")
			return

		var/mob/living/M = G.affecting
		if(M.buckled || M.anchored || buckled_mob || !do_mob(user, src, 12 SECONDS))
			return

		M.forceMove(loc)

		if(buckle_mob(M))
			M.visible_message(
				"<span class='danger'>[user] slams [M] onto the meat spike!</span>",
				"<span class='userdanger'>[user] slams you onto the meat spike!</span>",
				"<span class='notice'>You hear a squishy wet noise.</span>")

		return

	..()

/obj/structure/kitchenspike/deconstruct(disassembled)
	if(disassembled)
		var/obj/structure/meatspike_frame = new /obj/structure/kitchenspike_frame(loc)
		transfer_fingerprints_to(meatspike_frame)
	else
		new /obj/item/stack/sheet/metal(loc, 4)
	new /obj/item/stack/rods(loc, 4)
	..()

/obj/structure/kitchenspike/buckle_mob(mob/living/M)
	if(!..())
		return FALSE

	playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER, 25)
	M.emote("scream")
	if(iscarbon(M)) //So you don't get human blood when you spike a giant spidere
		var/turf/pos = get_turf(M)
		pos.add_blood_floor(M)
	M.adjustBruteLoss(30)
	M.set_dir(2)
	var/matrix/m = matrix(M.transform)
	m.Turn(180)
	animate(M, transform = m, time = 3)
	M.pixel_y = M.default_pixel_y
	return TRUE

/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/carbon/human/user)
	if(!buckled_mob || user.is_busy())
		return

	var/mob/living/L = buckled_mob
	add_fingerprint(user)
	if(L != user)
		L.visible_message(
			"<span class='notice'>[user.name] tries to pull [L.name] free of the [src]!</span>",
			"<span class='warning'>[user.name] is trying to pull you off the [src], opening up fresh wounds!</span>",
			"<span class='italics'>You hear a squishy wet noise.</span>")
		if(!do_after(user, 30 SECONDS, target = user))
			if(buckled_mob == L)
				L.visible_message(
					"<span class'notice'>[user.name] fails to free [L.name]!</span>",
					"<span class='warning'>[user.name] fails to pull you off of the [src].</span>")
			return

	else
		L.visible_message(
			"<span class='warning'>[L.name] struggles to break free from the [src]!</span>",
			"<span class='notice'>You struggle to break free from the [src], exacerbating your wounds! (Stay still for two minutes.)</span>",
			"<span class='italics'>You hear a wet squishing noise..</span>")
		L.adjustBruteLoss(15)
		if(!do_after(L, 2 MINUTES, target = src))
			if(buckled_mob == L)
				to_chat(L, "<span class='warning'>You fail to free yourself!</span>")
			return

	if(buckled_mob != L)
		return

	var/matrix/m = matrix(L.transform)
	m.Turn(180)
	animate(L, transform = m, time = 3)
	L.pixel_y = L.default_pixel_y
	L.adjustBruteLoss(15)
	visible_message("<span class='danger'>[L] falls free of the [src]!</span>")
	unbuckle_mob()
	L.emote("scream")
	L.AdjustWeakened(10)
