/*
Contains helper procs for airflow, handled in /connection_group.
*/

/mob
	COOLDOWN_DECLARE(last_airflow_stun)

/mob/proc/airflow_stun()
	if(stat == DEAD)
		return FALSE
	if(!COOLDOWN_FINISHED(src, last_airflow_stun))
		return FALSE
	if(!(status_flags & CANWEAKEN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return FALSE
	if(buckled)
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return FALSE
	if(!lying)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")
	Stun(2)
	Weaken(5)
	COOLDOWN_START(src, last_airflow_stun, vsc.airflow_stun_cooldown)

/mob/living/silicon/airflow_stun()
	return

/mob/living/simple_animal/construct/airflow_stun()
	return

/mob/living/simple_animal/hulk/airflow_stun()
	return

/mob/living/simple_animal/special/scp173/airflow_stun()
	return

/mob/living/carbon/slime/airflow_stun()
	return

/mob/living/carbon/human/airflow_stun()
	if(shoes?.flags & AIR_FLOW_PROTECT)
		return FALSE
	if(wear_suit?.flags & AIR_FLOW_PROTECT)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_FAT))
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return FALSE
	..()

/atom/movable/proc/check_airflow_movable(n)
	if(anchored)
		return FALSE

	return n >= vsc.airflow_dense_pressure

/mob/check_airflow_movable(n)
	if(status_flags & GODMODE)
		return FALSE
	if(buckled || anchored)
		return FALSE
	return n >= vsc.airflow_heavy_pressure

/mob/living/silicon/check_airflow_movable()
	return FALSE

/mob/living/carbon/human/check_airflow_movable(n)
	if(shoes && (shoes.flags & AIR_FLOW_PROTECT))
		return FALSE
	if(wear_suit && (wear_suit.flags & AIR_FLOW_PROTECT))
		return FALSE
	return ..()

/obj/item/check_airflow_movable(n)
	var/obj/item/I = src
	switch(I.w_class)
		if(SIZE_MINUSCULE, SIZE_TINY)
			if(n < vsc.airflow_lightest_pressure)
				return FALSE
		if(SIZE_SMALL)
			if(n < vsc.airflow_light_pressure)
				return FALSE
		if(SIZE_NORMAL, SIZE_BIG)
			if(n < vsc.airflow_medium_pressure)
				return FALSE
		if(SIZE_LARGE)
			if(n < vsc.airflow_heavy_pressure)
				return FALSE
		if(SIZE_HUMAN to INFINITY)
			if(n < vsc.airflow_dense_pressure)
				return FALSE

	return ..()

/atom/movable
	var/tmp/turf/airflow_dest
	var/tmp/airflow_speed = 0
	var/tmp/airborne_acceleration = 0
	COOLDOWN_DECLARE(last_airflow)

/atom/movable/proc/AirflowDest(n, turf/dest, repelled)
	set waitfor = FALSE
	if(dest == loc)
		step_away(src, loc)
	if(ismob(src))
		ADD_TRAIT(src, TRAIT_ARIBORN, TRAIT_ARIBORN_AIRFLOW)
		to_chat(src, "<span clas='danger'>You are [repelled ? "pushed" : "sucked"] away by airflow!</span>")
	COOLDOWN_START(src, last_airflow, vsc.airflow_delay)
	var/airflow_falloff = 9 - get_dist_euclidian(src, dest)
	if(airflow_falloff < 1)
		return
	airflow_dest = dest
	airflow_speed = clamp(n * (9 / airflow_falloff), 1, 9)
	airborne_acceleration = 0
	var/od
	var/sleep_time
	var/airflow_time = 7
	var/xo = dest.x - src.x
	var/yo = dest.y - src.y
	if(repelled)
		xo = -xo
		yo = -yo
		// update airflow_dest for proper step_towards
		airflow_dest = locate(clamp(src.x + xo, 1, world.maxx), clamp(src.y + yo, 1, world.maxy), src.z)

	while(airflow_speed > 0)
		airflow_speed = airflow_speed - vsc.airflow_speed_decay
		sleep_time = 0
		if(airflow_speed > 7)
			if(airflow_time++ >= airflow_speed)
				sleep_time = SSAIR_TICK_MULTIPLIER
		else
			sleep_time = max(1, 10 - (airflow_speed + 3)) * SSAIR_TICK_MULTIPLIER
		if(sleep_time)
			sleep(sleep_time)
			if(!(isturf(loc) && airflow_speed > 0))
				break
		if (loc == airflow_dest)
			airflow_dest = locate(clamp(src.x + xo, 1, world.maxx), clamp(src.y + yo, 1, world.maxy), src.z)
		od = !density
		density = TRUE
		step_towards(src, airflow_dest)
		if(od)
			density = FALSE
		var/mob/M = src
		if(istype(M) && M.client)
			M.setMoveCooldown(vsc.airflow_mob_slowdown)
		airborne_acceleration++

	airflow_dest = null
	airflow_speed = 0
	airborne_acceleration = 0
	REMOVE_TRAIT(src, TRAIT_ARIBORN, TRAIT_ARIBORN_AIRFLOW)

/atom/movable/Bump(atom/A)
	if(airflow_speed > 0)
		if(airborne_acceleration > 1)
			airflow_hit(A)
		else if(ishuman(src))
			to_chat(src, "<span class='notice'>You are pinned against [A] by airflow!</span>")
			airflow_speed = 0
	return ..()

/atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0

/obj/airflow_hit(atom/A)
	visible_message("<span class='danger'>\The [src] slams into \a [A]!</span>", blind_message = "<span class='danger'>You hear a loud slam!</span>")
	playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER, 25)
	..()

/obj/item/airflow_hit(atom/A)
	airflow_speed = 0

/mob/airflow_hit(atom/A)
	visible_message("<span class='danger'>\The [src] slams into \a [A]!</span>", blind_message = "<span class='danger'>You hear a loud slam!</span>")
	playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER, 25)
	var/weak_amt
	if(isitem(A))
		var/obj/item/I = A
		weak_amt = I.w_class
	else
		weak_amt = rand(1, 5)
	Stun(weak_amt * 0.5)
	Weaken(weak_amt)
	..()

/mob/living/simple_animal/construct/airflow_hit(atom/A)
	return

/mob/living/simple_animal/hulk/airflow_hit(atom/A)
	return

/mob/living/simple_animal/special/scp173/airflow_hit(atom/A)
	return

/mob/living/carbon/human/airflow_hit(atom/A)
	playsound(src, pick(SOUNDIN_PUNCH_MEDIUM), VOL_EFFECTS_MASTER, 25)
	var/obj/item/airbag/I = locate() in get_contents()
	if(I)
		I.deploy(src)
		return

	var/b_loss = min(airflow_speed, 2*airborne_acceleration) * vsc.airflow_damage

	if(b_loss > 0)
		if(prob(33))
			loc.add_blood(src)
			bloody_body(src)

		var/blocked = run_armor_check(BP_HEAD,MELEE)
		apply_damage(b_loss / 3, BRUTE, BP_HEAD, blocked, 0, "Airflow")

		blocked = run_armor_check(BP_CHEST,MELEE)
		apply_damage(b_loss / 3, BRUTE, BP_CHEST, blocked, 0, "Airflow")

		blocked = run_armor_check(BP_GROIN,MELEE)
		apply_damage(b_loss / 3, BRUTE, BP_GROIN, blocked, 0, "Airflow")

	if(airflow_speed > 10)
		var/airflow_paralysis = round(airflow_speed * vsc.airflow_stun)
		Paralyse(airflow_paralysis)
		Stun(airflow_paralysis + 3)
	else
		Stun(round(airflow_speed * vsc.airflow_stun / 2))
	..()

/zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/movable/A in T)
			if(!A.simulated || A.anchored || istype(A, /obj/effect) || isobserver(A))
				continue
			. += A
