/mob/living/simple_animal/hostile/doom
	name = "monster"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom32.dmi'
	icon_state = "imp"
	icon_living = "imp"
	icon_dead = "imp_dead"
	speak_chance = 0
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	speed = 3
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 20
	health = 20
	harm_intent_damage = 5
	melee_damage = 3
	attacktext = "punch"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	unsuitable_atoms_damage = 15
	environment_smash = 1
	faction = "hell"
	status_flags = CANPUSH

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

	footstep_type = FOOTSTEP_MOB_SHOE

	var/throw_after_melee_attack_range = 0
	var/attackedlastturn = FALSE

/mob/living/simple_animal/hostile/doom/death()
	..()
	if(prob(30))
		new /obj/effect/gibspawner/generic (src.loc)
		visible_message("<span class='warning'><b>[src]</b> is blown apart!</span>")
		qdel(src)
	return

/mob/living/simple_animal/hostile/doom/attackby(obj/item/O, mob/user)
	. = ..()
	if(O.force && O.force > 3 && stat != CONSCIOUS)
		new /obj/effect/gibspawner/generic (src.loc)
		visible_message("<span class='warning'><b>[src]</b> is blown apart!</span>")
		qdel(src)

/mob/living/simple_animal/hostile/doom/UnarmedAttack(atom/A)
	if(attackedlastturn)
		attackedlastturn = FALSE
		return FALSE
	attackedlastturn = TRUE
	if(throw_after_melee_attack_range)
		if(ishuman(A))
			var/mob/living/M = A
			to_chat(M, "<span class='userdanger'>You're thrown back by [src]!</span>")
			var/atom/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(M, src)))
			M.throw_at(throwtarget, throw_after_melee_attack_range, 1, src)
	..()

/mob/living/simple_animal/hostile/doom/imp
	name = "imp"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom32.dmi'
	icon_state = "imp"
	icon_living = "imp"
	icon_dead = "imp_dead"
	maxHealth = 15
	health = 15
	move_to_delay = 5
	melee_damage = 3
	destroy_surroundings = FALSE

/mob/living/simple_animal/hostile/doom/revenant
	name = "revenant"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom32.dmi'
	icon_state = "revenant"
	icon_living = "revenant"
	icon_dead = "revenant_dead"
	var/icon_shoot = "revenant_shoot"

	maxHealth = 10
	health = 10

	move_to_delay = 5
	ranged = TRUE
	retreat_distance = 2
	minimum_distance = 2
	projectiletype = /obj/item/projectile/magic/fireball
	projectilesound = 'sound/magic/Fireball.ogg'
	ranged_cooldown = 5

/mob/living/simple_animal/hostile/doom/revenant/OpenFire(target)
	. = ..()
	flick(icon_shoot, src)


/mob/living/simple_animal/hostile/doom/cacodemon
	name = "cacodemon"
	desc = "Оно парит в воздухе, изрыгает огонь и может похвастаться чертовски большим ртом. Вам конец, если вы подойдете слишком близко к этому чудовищу."
	icon = 'icons/mob/doom/doom32.dmi'
	icon_state = "cacodemon"
	icon_living = "cacodemon"
	icon_dead = "cacodemon_dead"

	maxHealth = 30
	health = 30

	move_to_delay = 6
	ranged = TRUE
	retreat_distance = 3
	minimum_distance = 3
	projectiletype = /obj/item/projectile/magic/fireball
	projectilesound = 'sound/magic/Fireball.ogg'
	ranged_cooldown = 4

/mob/living/simple_animal/hostile/doom/cacodemon/death()
	..()
	new /obj/effect/gibspawner/generic (src.loc)
	visible_message("<span class='warning'><b>[src]</b> is blown apart!</span>")
	qdel(src)
	return

/mob/living/simple_animal/hostile/doom/hellknight
	name = "hell knight"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom64.dmi'
	icon_state = "hellknight"
	icon_living = "hellknight"
	icon_dead = "hellknight_dead"
	pixel_x = -16
	layer = FLY_LAYER
	move_to_delay = 8

	maxHealth = 40
	health = 40
	melee_damage = 6
	turns_per_move = 1
	speed = 2

	throw_after_melee_attack_range = 1

/mob/living/simple_animal/hostile/doom/spidermastermind
	name = "spider mastermind"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom64.dmi'
	icon_state = "spidermastermind"
	icon_living = "spidermastermind"
	icon_dead = "spidermastermind_dead"
	pixel_x = -16
	layer = FLY_LAYER

	maxHealth = 35
	health = 35
	melee_damage = 4
	move_to_delay = 6
	turns_per_move = 1
	speed = 3

	throw_after_melee_attack_range = 3

/mob/living/simple_animal/hostile/doom/cyberdemon
	name = "cyber demon"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom128.dmi'
	icon_state = "cyberdemon"
	icon_living = "cyberdemon"
	icon_dead = "cyberdemon_dead"
	pixel_x = -32
	layer = FLY_LAYER
	move_to_delay = 10

	maxHealth = 70
	health = 70
	speed = 1
	melee_damage = 14
	turns_per_move = 4

	throw_after_melee_attack_range = 20

/mob/living/simple_animal/hostile/doom/devil
	name = "devil himself"
	desc = "Исчадие ада."
	icon = 'icons/mob/doom/doom96.dmi'
	icon_state = "devil"
	icon_living = "devil"
	icon_dead = "devil_dead"
	pixel_x = -32
	layer = FLY_LAYER
	move_to_delay = 100000

	maxHealth = 1000
	health = 1000
	speed = 10
	melee_damage = 30
	turns_per_move = 1000

	throw_after_melee_attack_range = 20
// portal
/obj/effect/anomaly/bluespace/hell_portal
	name = "ужасающий портал"
	desc = "Кажется, если ударить его - портал можно разрушить."
	icon = 'icons/obj/cult.dmi'
	light_color = "#ff0000"
	icon_state = "portal"
	layer = INFRONT_MOB_LAYER

	var/list/spawn_list = list(/mob/living/simple_animal/hostile/doom/imp = 3, /mob/living/simple_animal/hostile/doom/revenant = 1)
	var/spawns = 3
	var/portal_health = 40

	var/need_bound = FALSE

	var/enabled = TRUE
	COOLDOWN_DECLARE(hell_spawn_cd)
	COOLDOWN_DECLARE(hell_disabled_cd)

/obj/effect/anomaly/bluespace/hell_portal/Bumped(atom/A)
	return

/obj/effect/anomaly/bluespace/hell_portal/atom_init(mapload, bound = FALSE)
	. = ..()
	need_bound = bound

	enable()
	COOLDOWN_START(src, hell_spawn_cd, 5 SECONDS)
	START_PROCESSING(SSobj, src)

/obj/effect/anomaly/bluespace/hell_portal/attackby(obj/item/O, mob/user)
	. = ..()
	if(enabled)
		visible_message("<span class='warning'><b>[src]</b> is hit by [user] with [O] but the portal is too strong right now!</span>")
	else if(O.force < 1)
		visible_message("<span class='notice'><b>[src]</b> is hit by [user] but [O] is too weak!</span>")
	else
		visible_message("<span class='warning'><b>[src]</b> is hit by [user] but [O]! Its becoming weaker!</span>")
		portal_health = portal_health - O.force

/obj/effect/anomaly/bluespace/hell_portal/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(enabled)
		visible_message("<span class='warning'><b>[src]</b> is hit by [Proj] but the portal is too strong right now!</span>")
	else if(!Proj.damage)
		visible_message("<span class='notice'><b>[src]</b> is hit by [Proj] but its too weak!</span>")
	else
		visible_message("<span class='warning'><b>[src]</b> is hit by [Proj]! Its becoming weaker!</span>")
		portal_health = portal_health - Proj.damage

/obj/effect/anomaly/bluespace/hell_portal/process()
	if(QDELETED(src))
		return

	if(portal_health <= 0)
		visible_message("<span class='warning'><b>[src]</b> finally closes!</span>")
		qdel(src)

	if(!enabled && COOLDOWN_FINISHED(src, hell_disabled_cd))
		enable()

	if(spawns < 1 && enabled)
		disable()

	if(!enabled)
		return

	if(COOLDOWN_FINISHED(src, hell_spawn_cd))
		var/newmonstertype = pickweight(spawn_list)
		new newmonstertype(get_turf(src))
		spawns--
		COOLDOWN_START(src, hell_spawn_cd, 5 SECONDS)

/obj/effect/anomaly/bluespace/hell_portal/Destroy()
	disable()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/anomaly/bluespace/hell_portal/proc/enable()
	icon_state = "portal"
	spawns = initial(spawns)
	enabled = TRUE

/obj/effect/anomaly/bluespace/hell_portal/proc/disable()
	icon_state = "portal_weak"
	spawns = 0
	COOLDOWN_START(src, hell_disabled_cd, 4 MINUTES)
	enabled = FALSE

/obj/effect/anomaly/bluespace/hell_portal/attack_hand(mob/living/user)
	do_teleport(user, locate(user.x, user.y, user.z), 10)

/obj/effect/anomaly/bluespace/hell_portal/light
	spawn_list = list(/mob/living/simple_animal/hostile/doom/imp = 6, /mob/living/simple_animal/hostile/doom/revenant = 2, /mob/living/simple_animal/hostile/doom/cacodemon = 1)
	spawns = 3

/obj/effect/anomaly/bluespace/hell_portal/normal
	spawn_list = list(/mob/living/simple_animal/hostile/doom/imp = 2, /mob/living/simple_animal/hostile/doom/revenant = 1, /mob/living/simple_animal/hostile/doom/cacodemon = 1, /mob/living/simple_animal/hostile/doom/hellknight = 1)
	spawns = 4

/obj/effect/anomaly/bluespace/hell_portal/hard
	spawn_list = list(/mob/living/simple_animal/hostile/doom/imp = 2, /mob/living/simple_animal/hostile/doom/revenant = 1, /mob/living/simple_animal/hostile/doom/cacodemon = 1, /mob/living/simple_animal/hostile/doom/hellknight = 1, /mob/living/simple_animal/hostile/doom/spidermastermind = 1)
	spawns = 5

// portal event

/datum/event/portalstohell
	announceWhen = 5
	endWhen      = 40
	announcement = new /datum/announcement/centcomm/hellportals

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 30

/datum/event/portalstohell/announce()
	if(pick_turfs.len)
		announcement.play()

/datum/event/portalstohell/start()
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/simulated/floor/T in block(locate(1, 1, Z), locate(world.maxx, world.maxy, Z)))
			pick_turfs += T

	for(var/i in 1 to number_of_wormholes)
		var/turf/T = pick(pick_turfs)
		wormholes += new /obj/effect/anomaly/bluespace/hell_portal/light(T)

/datum/event/portalstohell/tick()
	if(activeFor % shift_frequency == 0)
		for(var/obj/effect/anomaly/bluespace/hell_portal/O in wormholes)
			var/turf/T = pick(pick_turfs)
			if(T)
				O.loc = T

/datum/event/portalstohell/end()
	QDEL_LIST(wormholes)
	wormholes.Cut()
