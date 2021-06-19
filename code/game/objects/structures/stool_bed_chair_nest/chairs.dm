/obj/structure/stool/bed/chair // YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/objects.dmi'
	icon_state = "chair"
	buckle_lying = FALSE // force people to sit up in chairs when buckled
	var/can_flipped = FALSE
	var/flipped = FALSE
	var/flip_angle = FALSE
	var/propelled = FALSE // Check for fire-extinguisher-driven chairs

	var/behind = null
	var/behind_buckled = null

	var/roll_sound = null // Janicart and office chair use this when moving.

/obj/structure/stool/bed/chair/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/stool/bed/chair/atom_init_late()
	handle_rotation()

/obj/structure/stool/bed/chair/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if(occupant && (src.loc != occupant.loc))
			if(propelled)
				for(var/mob/O in src.loc)
					if(O != occupant)
						Bump(O)
			else
				unbuckle_mob()
	else if(has_gravity(src) && roll_sound)
		playsound(src, roll_sound, VOL_EFFECTS_MASTER)
	handle_rotation()

/obj/structure/stool/bed/chair/Bump(atom/A)
	..()
	if(!buckled_mob)
		return

	if(propelled)
		on_propelled_bump(A)

/obj/structure/stool/bed/chair/proc/on_propelled_bump(atom/A)
	var/mob/living/occupant = unbuckle_mob()
	. = occupant
	occupant.throw_at(A, 3, propelled)
	shake_camera(occupant, 1, 1)
	occupant.apply_effect(2, STUN, 0)
	occupant.apply_effect(2, WEAKEN, 0)
	occupant.apply_effect(6, STUTTER, 0)
	playsound(src, 'sound/weapons/punch1.ogg', VOL_EFFECTS_MASTER)
	if(istype(A, /mob/living))
		var/mob/living/victim = A
		victim.apply_effect(4, STUN, 0)
		victim.apply_effect(4, WEAKEN, 0)
		victim.apply_effect(12, STUTTER, 0)
		victim.take_bodypart_damage(10)
	occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/stool/bed/chair/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, "<span class='notice'>[SK] is not ready to be attached!</span>")
			return
		var/obj/structure/stool/bed/chair/e_chair/E = new /obj/structure/stool/bed/chair/e_chair(src.loc)
		user.drop_from_inventory(SK, E)
		playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
		E.set_dir(dir)
		E.part = SK
		SK.master = E
		qdel(src)

/obj/structure/stool/bed/chair/attack_hand(mob/user)
	if(can_flip(user))
		var/flip_time = 20	//2 sec without someone
		if(!isnull(buckled_mob))
			flip_time = 60	//6 sec with
		user.SetNextMove(CLICK_CD_MELEE)
		if(!flipped)
			user.visible_message("<span class='notice'>[usr] flips \the [src] down.</span>","<span class='notice'>You flips \the [src] down.</span>")
			flip()
			if(buckled_mob && !buckled_mob.restrained())
				var/mob/living/L = buckled_mob
				unbuckle_mob()
				L.apply_effect(2, WEAKEN, 0)
				L.apply_damage(3, BRUTE, BP_HEAD)
		else if(!user.is_busy() && do_after(user, flip_time, target = usr))
			user.visible_message("<span class='notice'>[user] flips \the [src] up.</span>","<span class='notice'>You flips \the [src] up.</span>")
			flip()
	else
		..()

/obj/structure/stool/bed/chair/user_buckle_mob(mob/living/M, mob/user)
	if(dir == NORTH && !istype(src, /obj/structure/stool/bed/chair/schair/wagon/bench))
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER
	if(flipped)
		to_chat(usr, "<span class='notice'>You can't do it, while \the [src] is flipped.</span>")
		if(usr != M)
			to_chat(M, "<span class='warning'>Tried buckle you to \the [src].</span>")
	else
		..()

/obj/structure/stool/bed/chair/attack_tk(mob/user)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/stool/bed/chair/handle_rotation() // making this into a seperate proc so office chairs can call it on Move()
	if(dir == NORTH && buckled_mob)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		buckled_mob.set_dir(dir)
		buckled_mob.update_canmove()

/obj/structure/stool/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(!config.ghost_interaction && isobserver(usr))
		return
	if(ismouse(usr))
		return
	if(!usr || !isturf(usr.loc))
		return
	if(usr.incapacitated())
		return

	set_dir(turn(src.dir, 90))
	handle_rotation()
	return

/obj/structure/stool/bed/chair/post_buckle_mob(mob/living/M)
	. = ..()
	if(buckled_mob && behind)
		icon_state = behind
	else
		icon_state = initial(icon_state)
	if(dir == NORTH && buckled_mob && !istype(src, /obj/structure/stool/bed/chair/schair/wagon/bench))
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/stool/bed/chair/proc/can_flip(mob/living/carbon/human/user)
	if(!user || !isturf(user.loc) || user.incapacitated() || user.lying || user.a_intent != INTENT_HARM|| !can_flipped)
		return 0
	return 1

/obj/structure/stool/bed/chair/proc/flip()
	var/matrix/M = matrix(transform)
	var/offset_y = 0
	var/offset_x = 0
	var/new_angle = pick(90, 270)

	if(!flipped)
		M.TurnTo(0,new_angle)
		flip_angle = new_angle	// save our angle for future flip
		if(new_angle==90)
			offset_y = -4
			offset_x = 2
		else
			offset_y = -4
			offset_x = -2
		flipped = 1
		anchored = FALSE		// can be pulled
		buckle_movable = 0
		playsound(src, 'sound/items/chair_fall.ogg', VOL_EFFECTS_MASTER, 25)
	else
		M.TurnTo(flip_angle,0)
		flipped = 0
		anchored = initial(anchored)
		buckle_movable = initial(buckle_movable)

	animate(src, transform = M, pixel_y = offset_y, pixel_x = offset_x, time = 2, easing = EASE_IN|EASE_OUT)
	handle_rotation()

/obj/structure/stool/bed/chair/barber
	icon_state = "barber_chair"

/obj/structure/stool/bed/chair/metal
	icon_state = "chair_gray"
	can_flipped = 1
	behind = "chair_behind_gray"

/obj/structure/stool/bed/chair/metal/blue
	icon_state = "chair_blue"
	behind = "chair_behind_blue"

/obj/structure/stool/bed/chair/metal/yellow
	icon_state = "chair_yellow"
	behind = "chair_behind_yellow"

/obj/structure/stool/bed/chair/metal/red
	icon_state = "chair_red"
	behind = "chair_behind_red"

/obj/structure/stool/bed/chair/metal/green
	icon_state = "chair_green"
	behind = "chair_behind_green"

/obj/structure/stool/bed/chair/metal/white
	icon_state = "chair_white"
	behind = "chair_behind_white"

/obj/structure/stool/bed/chair/metal/black
	icon_state = "chair_black"
	behind = "chair_behind_black"

/obj/structure/stool/bed/chair/schair
	name = "shuttle chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/objects.dmi'
	icon_state = "schair"
	var/sarmrest = null

/obj/structure/stool/bed/chair/schair/atom_init()
	sarmrest = image("icons/obj/objects.dmi", "schair_armrest", layer = FLY_LAYER)
	. = ..()

/obj/structure/stool/bed/chair/schair/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		add_overlay(sarmrest)
	else
		cut_overlay(sarmrest)

// Chair types
/obj/structure/stool/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/stool/bed/chair/wood/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		user.SetNextMove(CLICK_CD_RAPID)
		new /obj/item/stack/sheet/wood(loc)
		qdel(src)
		return
	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/obj/item/weapon/melee/energy/blade/B = W
		if(B.active)
			user.do_attack_animation(src)
			user.SetNextMove(CLICK_CD_MELEE)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'>You hear [src] coming apart.</span>")
			new /obj/item/stack/sheet/wood(loc)
			qdel(src)
			return
	..()

/obj/structure/stool/bed/chair/noose //It's a "chair".
	name = "noose"
	desc = "Well this just got a whole lot more morbid."
	icon = 'icons/obj/objects.dmi'
	icon_state = "noose"
	layer = FLY_LAYER
	flags = NODECONSTRUCT
	var/mutable_appearance/overlay

/obj/structure/stool/bed/chair/noose/atom_init()
	. = ..()
	pixel_y += 16 //Noose looks like it's "hanging" in the air
	overlay = image(icon, "noose_overlay")
	overlay.layer = FLY_LAYER
	for(var/obj/item/stack/cable_coil/C in contents)
		color = C.color
		overlay.color = C.color
	add_overlay(overlay)

/obj/structure/stool/bed/chair/noose/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(overlay)
	return ..()

/obj/structure/stool/bed/chair/noose/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		layer = MOB_LAYER
		START_PROCESSING(SSobj, src)
		M.dir = SOUTH
		animate(M, pixel_y = M.lying ? initial(pixel_y) + 14 : initial(pixel_y) + 8, time = 8, easing = LINEAR_EASING)
	else
		layer = initial(layer)
		STOP_PROCESSING(SSobj, src)
		M.pixel_x = initial(M.pixel_x)
		pixel_x = initial(pixel_x)
		M.pixel_y = M.lying ? -6 : initial(M.pixel_y)

/obj/structure/stool/bed/chair/noose/user_unbuckle_mob(mob/living/user)
	if(!has_buckled_mobs())
		return
	if(user.is_busy())
		return
	if(buckled_mob != user)
		user.visible_message("<span class='notice'>[user] begins to untie the noose over [buckled_mob]'s neck...</span>")
		to_chat(user, "<span class='notice'>You begin to untie the noose over [buckled_mob]'s neck...</span>")
		if(!do_mob(user, buckled_mob, 10 SECONDS))
			return
		user.visible_message("<span class='notice'>[user] unties the noose over [buckled_mob]'s neck!</span>")
		to_chat(user,"<span class='notice'>You untie the noose over [buckled_mob]'s neck!</span>")
	else
		buckled_mob.visible_message("<span class='warning'>[buckled_mob] struggles to untie the noose over their neck!</span>")
		to_chat(buckled_mob,"<span class='notice'>You struggle to untie the noose over your neck... (Stay still for 15 seconds.)</span>")
		if(!do_after(buckled_mob, 15 SECONDS, target = src))
			if(buckled_mob && buckled_mob.buckled)
				to_chat(buckled_mob, "<span class='warning'>You fail to untie yourself!</span>")
			return
		if(!buckled_mob.buckled)
			return
		buckled_mob.visible_message("<span class='warning'>[buckled_mob] unties the noose over their neck!</span>")
		to_chat(buckled_mob,"<span class='notice'>You untie the noose over your neck!</span>")
	if(buckled_mob)
		buckled_mob.pixel_z = initial(buckled_mob.pixel_z)
		buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
		buckled_mob.AdjustWeakened(5)
		unbuckle_mob(buckled_mob)
	pixel_z = initial(pixel_z)
	pixel_x = initial(pixel_x)
	add_fingerprint(user)

/obj/structure/stool/bed/chair/noose/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!in_range(user, src) || user.stat || user.restrained() || !ishuman(M) || user.is_busy())
		return FALSE

	var/obj/item/organ/external/BP = M.bodyparts_by_name[BP_HEAD]
	if(!BP || BP.is_stump)
		to_chat(user, "<span class='warning'>[M] has no head!</span>")
		return FALSE

	if(M.loc != loc)
		return FALSE

	if(!can_hang())
		to_chat(user, "<span class='notice'>You need to have a stool or a chair under the noose to hang someone</span>")
		return FALSE

	add_fingerprint(user)
	message_admins("[key_name_admin(user)] attempted to hang [key_name(M)]. [ADMIN_JMP(M)]")
	M.visible_message("<span class='danger'>[user] attempts to tie \the [src] over [M]'s neck!</span>")
	if(user != M)
		to_chat(user, "<span class='notice'>It will take 15 seconds and you have to stand still.</span>")
	if(do_mob(user, M, user == M ? 3 : 15 SECONDS))
		if(buckle_mob(M))
			user.visible_message("<span class='warning'>[user] ties \the [src] over [M]'s neck!</span>")
			if(user == M)
				to_chat(M, "<span class='userdanger'>You tie \the [src] over your neck!</span>")
			else
				to_chat(M, "<span class='userdanger'>[user] ties \the [src] over your neck!</span>")
			playsound(src, 'sound/effects/noosed.ogg', VOL_EFFECTS_MASTER)
			message_admins("[key_name_admin(M)] was hanged by [key_name(user)]. [ADMIN_JMP(M)]")
			for(var/alert in M.alerts)
				var/obj/screen/alert/A = M.alerts[alert]
				if(A.master.icon_state == "noose") // our alert icon is terrible, let's build a new one
					A.cut_overlays()
					A.add_overlay(image(icon, "noose"))
					A.add_overlay(image(icon, "noose_overlay"))
			return TRUE
	user.visible_message("<span class='warning'>[user] fails to tie \the [src] over [M]'s neck!</span>")
	to_chat(user, "<span class='warning'>You fail to tie \the [src] over [M]'s neck!</span>")
	return FALSE

/obj/structure/stool/bed/chair/noose/process()
	if(!has_buckled_mobs())
		STOP_PROCESSING(SSobj, src)
		return
	if(can_hang()) // well you have to remove the support first
		return
	if(pixel_x >= 0)
		animate(src, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
		animate(buckled_mob, pixel_x = -3, pixel_y = 8, time = 45, easing = ELASTIC_EASING)
	else
		animate(src, pixel_x = 3, time = 45, easing = ELASTIC_EASING)
		animate(buckled_mob, pixel_x = 3, pixel_y = 8, time = 45, easing = ELASTIC_EASING)
	if(buckled_mob.mob_has_gravity())
		var/mob/living/carbon/human/bm = buckled_mob
		var/obj/item/organ/external/BP = bm.bodyparts_by_name[BP_HEAD]
		if(BP && !BP.is_stump)
			if(bm.stat != DEAD)
				if(!(NO_BREATH in bm.mutations))
					bm.adjustOxyLoss(5)
					if(prob(40))
						bm.emote("gasp")
				BP.take_damage(0.5, null, null, "Noose")
				if(prob(20))
					var/flavor_text = list("<span class='danger'>[bm]'s legs flail for anything to stand on.</span>",\
											"<span class='danger'>[bm]'s hands are desperately clutching the noose.</span>",\
											"<span class='danger'>[bm]'s limbs sway back and forth with diminishing strength.</span>")
					bm.visible_message(pick(flavor_text))
			playsound(src, 'sound/effects/noose_idle.ogg', VOL_EFFECTS_MASTER)
		else
			bm.visible_message("<span class='danger'>[bm] drops from the noose!</span>")
			bm.AdjustWeakened(5)
			bm.pixel_z = initial(bm.pixel_z)
			pixel_z = initial(pixel_z)
			bm.pixel_x = initial(bm.pixel_x)
			pixel_x = initial(pixel_x)
			unbuckle_mob(bm)

/obj/structure/stool/bed/chair/noose/proc/can_hang()
	var/turf/src_turf = get_turf(src)
	for(var/obj/structure/stool/bed/chair/S in src_turf)
		if(istype(S, /obj/structure/stool/bed/chair/noose))
			continue
		if(istype(S, /obj/structure/stool/bed/chair))
			var/obj/structure/stool/bed/chair/C = S
			if(!C.flipped)
				return TRUE
	return FALSE

/obj/structure/stool/bed/chair/noose/proc/rip(mob/user, forced = FALSE)
	if(user)
		user.visible_message("<span class='notice'>[user] cuts the noose.</span>", "<span class='notice'>You cut the noose.</span>")
	if(has_buckled_mobs() && buckled_mob.mob_has_gravity())
		buckled_mob.visible_message("<span class='danger'>[buckled_mob] falls over and hits the ground!</span>")
		to_chat(buckled_mob, "<span class='userdanger'>You fall over and hit the ground!</span>")
		buckled_mob.adjustBruteLoss(10)
		buckled_mob.AdjustWeakened(5)
		unbuckle_mob(buckled_mob)
	if(forced)
		var/obj/item/stack/cable_coil/C = new(get_turf(src))
		C.color = color
		C.amount = 20
	else
		var/obj/item/weapon/noose/N = new(get_turf(src))
		N.color = color
	qdel(src)

/obj/structure/stool/bed/chair/noose/attackby(obj/item/W, mob/user)
	if(iswirecutter(W))
		rip(user)
		return ..()
	if(!istype(W, /obj/item/weapon/grab))
		return ..()
	var/obj/item/weapon/grab/grab = W
	if(!ismob(grab.affecting))
		return
	if(user.is_busy())
		return
	var/mob/M = grab.affecting
	user_buckle_mob(M, user)

/obj/structure/stool/bed/chair/noose/attack_alien()
	..()

/obj/structure/stool/bed/chair/noose/attack_paw(mob/user)
	..()
	rip(user, TRUE)

/obj/structure/stool/bed/chair/noose/airlock_crush_act()
	rip(forced = TRUE)

/obj/structure/stool/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	var/armrest = null

/obj/structure/stool/bed/chair/comfy/atom_init()
	armrest = image("icons/obj/objects.dmi", "comfychair_armrest", layer = FLY_LAYER)
	. = ..()

/obj/structure/stool/bed/chair/comfy/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/stool/bed/chair/comfy/brown
	color = rgb(255,113,0)

/obj/structure/stool/bed/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/stool/bed/chair/comfy/teal
	color = rgb(0,255,255)

/obj/structure/stool/bed/chair/comfy/black
	color = rgb(167,164,153)

/obj/structure/stool/bed/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/stool/bed/chair/office
	anchored = FALSE
	buckle_movable = 1
	can_flipped = 1

	roll_sound = 'sound/effects/roll.ogg'

/obj/structure/stool/bed/chair/office/light
	icon_state = "officechair_white"
	behind = "officechair_white_behind"

/obj/structure/stool/bed/chair/office/dark
	icon_state = "officechair_dark"
	behind = "officechair_dark_behind"
