/obj/structure/stool/bed/chair/pew
	name = "pew"
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "general_left"

	density = TRUE
	anchored = TRUE

	dir = NORTH

	// It's  a pew!
	layer = FLY_LAYER

	var/pew_icon = "general"
	var/append_icon_state = "_left"

/obj/structure/stool/bed/chair/pew/atom_init()
	. = ..()
	update_icon()

/obj/structure/stool/bed/chair/pew/post_buckle_mob(mob/living/M)
	return

/obj/structure/stool/bed/chair/pew/handle_rotation()
	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.update_canmove()

/obj/structure/stool/bed/chair/pew/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, loc) & dir)
		return !density
	return TRUE

/obj/structure/stool/bed/chair/pew/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(!density)
		return TRUE
	if(is_the_opposite_dir(dir, to_dir))
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/pew/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, O.loc) == dir)
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/pew/update_icon()
	icon_state = pew_icon + append_icon_state

/obj/structure/stool/bed/chair/pew/left
	// For mappers.
	icon_state = "general_left"
	append_icon_state = "_left"

/obj/structure/stool/bed/chair/pew/right
	icon_state = "general_right"
	append_icon_state = "_right"



/obj/effect/effect/bell
	name = "The Lord Voker"
	desc = "Ring-a-ding, let the station know you've got a nullrod and you ain't afraid to use it!"

	icon = 'icons/obj/big_bell.dmi'
	icon_state = "lord_Voker"

	density = FALSE
	anchored = TRUE

	pixel_x = -16
	pixel_y = -2

	layer = INFRONT_MOB_LAYER - 0.1

	mouse_opacity = MOUSE_OPACITY_OPAQUE

	var/next_swing = 0

	var/next_ring = 0
	var/next_global_ring = 0

	var/obj/structure/big_bell/base

	// The offset for pivoting.
	var/pivot_y = 12

/obj/effect/effect/bell/atom_init(mapload, obj/structure/big_bell/BB)
	. = ..()
	base = BB
	AddComponent(/datum/component/bounded, BB, 0, 0)

/obj/effect/effect/bell/Destroy()
	base.bell = null
	QDEL_NULL(base)
	return ..()

/obj/effect/effect/bell/proc/can_use(mob/user)
	if(!user.Adjacent(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/effect/effect/bell/proc/swing(angle, time, swing_am)
	if(next_swing > world.time)
		return
	next_swing = world.time + time

	if(prob(50))
		angle *= -1

	var/stop_swinging = world.time + time
	var/swing_time = time / swing_am

	var/angle_delta = angle / swing_am

	var/old_pixel_y = pixel_y
	pixel_y += pivot_y

	var/matrix/old_transform = transform
	var/matrix/pivot_transform = matrix(transform)
	pivot_transform.Translate(0, -pivot_y)

	transform = pivot_transform

	while(stop_swinging > world.time)
		if(QDELING(src))
			return
		if(angle >= -1 && angle <= 1)
			break
		if(swing_time <= 1)
			break

		var/matrix/M = matrix(pivot_transform)
		M.Turn(angle)
		animate(src, transform = M, time = swing_time * 0.5)
		animate(transform = pivot_transform, time = swing_time * 0.5)

		angle *= -1
		angle -= angle_delta

		sleep(swing_time)

	transform = old_transform
	pixel_y = old_pixel_y

/obj/effect/effect/bell/proc/stun_insides(force)
	for(var/mob/living/L in get_turf(src))
		if(L.crawling || L.resting)
			return

		var/ear_safety = 0
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(HULK in H.mutations)
				ear_safety += 1
			if(istype(H.head, /obj/item/clothing/head/helmet))
				ear_safety += 1

		to_chat(L, "<span class='danger'>[name] rings all throughout your mind!</span>")

		ear_safety *= 1 / force

		if(ear_safety > 1)
			L.Stun(1)
		else if(ear_safety > 0)
			L.Weaken(1)
		else
			L.Weaken(3)
			L.ear_damage += rand(0, 5)
			L.ear_deaf = max(L.ear_deaf, 15)

/obj/effect/effect/bell/proc/adjust_strength(def_val, strength, strength_coeff, max_val)
	return min(round(def_val + strength * strength_coeff), max_val)

/obj/effect/effect/bell/proc/ring(mob/user, strength)
	if(next_ring > world.time)
		to_chat(user, "<span class='notice'>The bell is still swinging. Please wait [round((next_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return
	next_ring = world.time + 3 SECONDS

	visible_message("[bicon(src)] <span class='notice'>[src] rings, strucken by [user].</span>")

	var/shake_duration = adjust_strength(2, strength, 0.25, 4)
	var/shake_strength = adjust_strength(0, strength, 0.1, 3)

	if(shake_strength > 0)
		shake_camera(user, shake_duration, shake_strength)
	playsound(src, 'sound/effects/bell.ogg', VOL_EFFECTS_MASTER, 75, null)

	var/swing_angle = adjust_strength(6, strength, 0.25, 16)

	stun_insides(1)

	INVOKE_ASYNC(src, .proc/swing, swing_angle, 2 SECONDS, 2)

/obj/effect/effect/bell/proc/ring_global(mob/user, strength)
	if(!user.mind || !user.mind.holy_role)
		ring(user, strength)
		return

	if(next_global_ring > world.time)
		to_chat(user, "<span class='warning'>You can't alarm the whole station so often! Please wait [round((next_global_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return

	if(alert(user, "Are you sure you want to alert the entire station with [src]?", "[src]", "Yes", "No") == "No")
		return
	var/ring_msg = capitalize(sanitize(input(user, "What do you want to ring on [src]?", "Enter message") as null|text))
	if(!ring_msg)
		return

	if(!can_use(user))
		return

	if(!user.mind || !user.mind.holy_role)
		ring(user, strength)
		return

	if(next_global_ring > world.time)
		to_chat(user, "<span class='warning'>You can't alarm the whole station so often! Please wait [round((next_global_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return
	next_global_ring = world.time + 10 MINUTES

	visible_message("[bicon(src)] <span class='warning'>[src] rings loudly, strucken by [user]!</span>")

	var/shake_duration = adjust_strength(4, strength, 0.25, 16)
	var/shake_strength = adjust_strength(1, strength, 0.1, 5)

	if(shake_strength > 0)
		shake_camera(user, shake_duration, shake_strength)

	for(var/mob/M in player_list)
		if(M.z == z)
			// Why do they call them voice announcements if it's just global announcements?
			M.playsound_local(null, 'sound/effects/big_bell.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, 75)
			to_chat(M, "[bicon(src)] <span class='game say'><b>[src]</b> rings, \"[ring_msg]\"</span>")

	var/swing_angle = adjust_strength(12, strength, 0.25, 32)

	stun_insides(2)

	INVOKE_ASYNC(src, .proc/swing, swing_angle, 9 SECONDS, 6)

/obj/effect/effect/bell/attackby(obj/item/I, mob/user)
	if(user.a_intent == INTENT_HARM)
		ring_global(user, I.force)
	else
		ring(user, I.force)

/obj/effect/effect/bell/attack_paw(mob/living/user)
	attack_hand(user)

/obj/effect/effect/bell/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM)
		ring_global(user, 1)
	else
		ring(user, 1)

/obj/structure/big_bell
	name = "bell base"
	desc = "Ring-a-ding, let the station know you've got a nullrod and you ain't afraid to use it!"
	icon = 'icons/obj/big_bell.dmi'
	icon_state = "bell_base"

	density = TRUE
	anchored = TRUE

	pixel_x = -16
	pixel_y = -2

	layer = INFRONT_MOB_LAYER

	var/obj/effect/effect/bell/bell

/obj/structure/big_bell/atom_init()
	. = ..()
	bell = new(loc, src)

/obj/structure/big_bell/Destroy()
	QDEL_NULL(bell)
	return ..()

/obj/structure/big_bell/attackby(obj/item/I, mob/user)
	if(iswrench(I) && !user.is_busy(src) && I.use_tool(src, user, 40, volume = 50))
		anchored = !anchored
		visible_message("<span class='warning'>[src] has been [anchored ? "secured to the floor" : "unsecured from the floor"] by [user].</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
		return

	return ..()

/obj/structure/big_bell/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return istype(mover) && mover.checkpass(PASSCRAWL)

/obj/structure/big_bell/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, atom/movable/caller)
	return istype(caller) && caller.checkpass(PASSCRAWL)

/obj/structure/big_bell/CheckExit(atom/movable/mover, target)
	return istype(mover) && mover.checkpass(PASSCRAWL)
