/obj/structure/stool/bed/chair	//YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/objects.dmi'
	icon_state = "chair"
	buckle_lying = 0 //force people to sit up in chairs when buckled
	var/can_flipped = 0
	var/flipped = 0
	var/flip_angle = 0

	var/propelled = 0 // Check for fire-extinguisher-driven chairs

/obj/structure/stool/bed/chair/metal
	icon_state = "chair_g"
	can_flipped = 1
	var/behind = null
	var/behind_buckled = null

/obj/structure/stool/bed/chair/barber
	icon_state = "barber_chair"

/obj/structure/stool/bed/chair/metal/blue
	icon_state = "chair_blu"

/obj/structure/stool/bed/chair/metal/yellow
	icon_state = "chair_y"

/obj/structure/stool/bed/chair/metal/red
	icon_state = "chair_r"

/obj/structure/stool/bed/chair/metal/green
	icon_state = "chair_gr"

/obj/structure/stool/bed/chair/metal/white
	icon_state = "chair_w"

/obj/structure/stool/bed/chair/metal/black
	icon_state = "chair_bla"

/obj/structure/stool/bed/chair/metal/atom_init()
	behind = "chair_behind_g"
	. = ..()

/obj/structure/stool/bed/chair/metal/blue/atom_init()
	behind = "chair_behind_blu"
	. = ..()

/obj/structure/stool/bed/chair/metal/yellow/atom_init()
	behind = "chair_behind_y"
	. = ..()

/obj/structure/stool/bed/chair/metal/red/atom_init()
	behind = "chair_behind_r"
	. = ..()

/obj/structure/stool/bed/chair/metal/green/atom_init()
	behind = "chair_behind_gr"
	. = ..()

/obj/structure/stool/bed/chair/metal/white/atom_init()
	behind = "chair_behind_w"
	. = ..()

/obj/structure/stool/bed/chair/metal/black/atom_init()
	behind = "chair_behind_bla"
	. = ..()

/obj/structure/stool/bed/chair/Move(atom/newloc, direct)
	..()
	handle_rotation()

/obj/structure/stool/bed/chair/metal/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		icon_state = behind
	else
		icon_state = initial(icon_state)

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
		overlays += sarmrest
	else
		overlays -= sarmrest

/obj/structure/stool/bed/chair/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/stool/bed/chair/atom_init_late()
	handle_rotation()

/obj/structure/stool/bed/chair/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, "<span class='notice'>[SK] is not ready to be attached!</span>")
			return
		user.drop_item()
		var/obj/structure/stool/bed/chair/e_chair/E = new /obj/structure/stool/bed/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		E.dir = dir
		E.part = SK
		SK.loc = E
		SK.master = E
		qdel(src)

/obj/structure/stool/bed/chair/attack_hand(mob/user)
	if(can_flip(user))
		var/flip_time = 20	//2 sec without someone
		if(!isnull(buckled_mob))
			flip_time = 60	//6 sec with
		user.SetNextMove(CLICK_CD_MELEE)
		if(!flipped)
			user.visible_message("<span class='notice'>[usr] flips \the [src] down.</span>","<span class='notice'>You flips \the [src] down.")
			flip()
			if(buckled_mob && !buckled_mob.restrained())
				var/mob/living/L = buckled_mob
				unbuckle_mob()
				L.apply_effect(2, WEAKEN, 0)
				L.apply_damage(3, BRUTE, BP_HEAD)
		else if(!user.is_busy() && do_after(user, flip_time, target = usr))
			user.visible_message("<span class='notice'>[user] flips \the [src] up.</span>","<span class='notice'>You flips \the [src] up.")
			flip()
	else
		..()

/obj/structure/stool/bed/chair/user_buckle_mob(mob/living/M, mob/user)
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

/obj/structure/stool/bed/chair/handle_rotation()	//making this into a seperate proc so office chairs can call it on Move()
	if(src.dir == NORTH)
		src.layer = FLY_LAYER
	else
		src.layer = OBJ_LAYER

	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.update_canmove()

/obj/structure/stool/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		src.dir = turn(src.dir, 90)
		handle_rotation()
		return
	else
		if(ismouse(usr))
			return
		if(!usr || !isturf(usr.loc))
			return
		if(usr.incapacitated())
			return

		src.dir = turn(src.dir, 90)
		handle_rotation()
		return

/obj/structure/stool/bed/chair/proc/can_flip(mob/living/carbon/human/user)
	if(!user || !isturf(user.loc) || user.incapacitated() || user.lying || user.a_intent != "hurt"|| !can_flipped)
		return 0
	return 1

/obj/structure/stool/bed/chair/proc/flip()
	var/matrix/M = matrix(transform)
	var/offset_y = 0
	var/offset_x = 0
	var/new_angle = pick(90, 270)

	if(!flipped)
		M.TurnTo(0,new_angle)
		flip_angle = new_angle	//save our angle for future flip
		if(new_angle==90)
			offset_y = -4
			offset_x = 2
		else
			offset_y = -4
			offset_x = -2
		flipped = 1
		anchored = 0		//can be pulled
		buckle_movable = 0
		playsound(src.loc, 'sound/items/chair_fall.ogg', 25, 1)
	else
		M.TurnTo(flip_angle,0)
		flipped = 0
		anchored = initial(anchored)
		buckle_movable = initial(buckle_movable)

	animate(src, transform = M, pixel_y = offset_y, pixel_x = offset_x, time = 2, easing = EASE_IN|EASE_OUT)
	handle_rotation()

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
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
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
			playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(loc, "sparks", 50, 1)
			visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'>You hear [src] coming apart.</span>")
			new /obj/item/stack/sheet/wood(loc)
			qdel(src)
			return
	..()

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
		overlays += armrest
	else
		overlays -= armrest

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
	anchored = 0
	buckle_movable = 1
	can_flipped = 1

/obj/structure/stool/bed/chair/office/Move()
	..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if (occupant && (src.loc != occupant.loc))
			if (propelled)
				for (var/mob/O in src.loc)
					if (O != occupant)
						Bump(O)
			else
				unbuckle_mob()
	handle_rotation()

/obj/structure/stool/bed/chair/office/Bump(atom/A)
	..()
	if(!buckled_mob)	return

	if(propelled)
		var/mob/living/occupant = unbuckle_mob()
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, 0)
		occupant.apply_effect(6, WEAKEN, 0)
		occupant.apply_effect(6, STUTTER, 0)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			victim.apply_effect(6, STUN, 0)
			victim.apply_effect(6, WEAKEN, 0)
			victim.apply_effect(6, STUTTER, 0)
			victim.take_bodypart_damage(10)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/stool/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/stool/bed/chair/office/dark
	icon_state = "officechair_dark"
