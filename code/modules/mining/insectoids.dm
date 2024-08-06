/mob/living/simple_animal/hostile/asteroid/insectoid
	name = "insectoid"
	desc = "Большой космический жук, исконный обитатель этого астероида."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 1
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	melee_damage = 5
	attacktext = "gnaw"
	attack_sound = list('sound/weapons/bladeslice.ogg')
	aggro_vision_range = 9
	idle_vision_range = 2
	sight = SEE_MOBS | SEE_TURFS
	see_in_dark = 8
	w_class = SIZE_LARGE
	pull_size_ratio = 1
	var/underground = FALSE
	var/last_trap = 0
	var/trap_cooldown = 20 SECONDS

/mob/living/simple_animal/hostile/asteroid/insectoid/atom_init()
	. = ..()
	verbs.Add(/mob/living/simple_animal/hostile/asteroid/insectoid/proc/dig,
		/mob/living/simple_animal/hostile/asteroid/insectoid/proc/set_groundtrap,
		/mob/living/simple_animal/hostile/asteroid/insectoid/proc/set_rocktrap)

/mob/living/simple_animal/hostile/asteroid/insectoid/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE) // Bombs won't help
			adjustBruteLoss(maxHealth * 0.5)
		if(EXPLODE_HEAVY)
			adjustBruteLoss(maxHealth * 0.2)

/mob/living/simple_animal/hostile/asteroid/insectoid/proc/dig()
	set name = "Dig Underground"
	set desc = "Закопайтесь под землю."
	set category = "Insectoid"

	var/obj/effect/E = new /obj/effect/insectoid_dig(src.loc)
	if(do_after(src, 3 SECONDS, target = src))
		underground = !underground
		if(underground)
			density = 0
			alpha = 0
			speed = 3
		else
			density = 1
			alpha = initial(alpha)
			speed = initial(speed)
	qdel(E)

/mob/living/simple_animal/hostile/asteroid/insectoid/proc/set_groundtrap()
	set name = "Set Groundtrap"
	set desc = "Соорудите ловушку в земле."
	set category = "Insectoid"

	if(world.time < last_trap + trap_cooldown)
		to_chat(src, "<span class='notice'>Время ещё не пришло.</span>")
	else
		var/obj/effect/E = new /obj/effect/insectoid_dig(src.loc)
		if(do_after(src, 5 SECONDS, target = src))
			new /obj/item/mine/insectoid(src.loc)
		qdel(E)

/mob/living/simple_animal/hostile/asteroid/insectoid/proc/set_rocktrap(O in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Set Rocktrap"
	set desc = "Соорудите ловушку в каменной породе."
	set category = "Insectoid"

	if(underground)
		return
	if(O in oview(1))
		if(istype(O, /turf/simulated/mineral))
			var/turf/simulated/mineral/M = O
			M.set_trap()

/mob/living/simple_animal/hostile/asteroid/insectoid/Bump(atom/A)
	. = ..()
	if(A == loc)
		return

	if(underground && istype(A, /turf/simulated/mineral))
		forceMove(A) // can crawl under the ground and rocks


/obj/effect/insectoid_dig
	name = "Insectoid Dig"

/obj/item/mine/insectoid
	anchored = TRUE

/obj/item/mine/insectoid/try_trigger(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.visible_message("<span class='danger'>[H] steps on [src]!</span>")
		trigger_act(H)
		qdel(src)
	if(istype(AM, /obj/mecha))
		qdel(src)

/obj/item/mine/insectoid/trigger_act(mob/living/carbon/human/H)
	for(var/mob/living/M in range(src, 7))
		M.flash_eyes()
		var/dist = get_dist(src, M)
		M.adjustBruteLoss(30 / dist)
		M.Stun(5 / dist)

/obj/item/mine/insectoid/bullet_act(obj/item/projectile/Proj, def_zone)
	return

/obj/item/mine/insectoid/try_disarm(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/shovel))
		user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", "<span class='notice'>You start disarming [src].</span>")
		if(I.use_tool(src, user, 40, volume = 50))
			user.visible_message("<span class='notice'>[user] finishes disarming [src].</span>", "<span class='notice'>You finish disarming [src].</span>")
			qdel(src)


/datum/action/innate/insectoid
	check_flags = AB_CHECK_ALIVE

/datum/action/innate/insectoid/dig_underground
	name = "Закопаться под землю"
	button_icon = 'icons/turf/asteroid.dmi'
	button_icon_state = "asteroid_dug"

/datum/action/innate/insectoid/dig_underground/Activate()
	if(istype(owner, /mob/living/simple_animal/hostile/asteroid/insectoid))
		var/mob/living/simple_animal/hostile/asteroid/insectoid/I = owner
		I.dig()

/datum/action/innate/insectoid/set_trap
	name = "Соорудить ловушку"
	button_icon = 'icons/obj/items.dmi'
	button_icon_state = "beartrap1"

/datum/action/innate/insectoid/set_trap/Activate()
	if(istype(owner, /mob/living/simple_animal/hostile/asteroid/insectoid))
		var/mob/living/simple_animal/hostile/asteroid/insectoid/I = owner
		I.set_groundtrap()
