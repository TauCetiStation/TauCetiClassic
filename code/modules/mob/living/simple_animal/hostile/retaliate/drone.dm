
//malfunctioning combat drones
/mob/living/simple_animal/hostile/retaliate/malf_drone
	name = "combat drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "drone_100"
	icon_living = "drone_100"
	icon_dead = "drone_0"
	ranged = TRUE
	amount_shoot = 3
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("ALERT.","Hostile-ile-ile entities dee-twhoooo-wected.","Threat parameterszzzz- szzet.","Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly","whirrs threateningly","scans its immediate vicinity")
	stop_automated_movement_when_pulled = 0
	health = 300
	maxHealth = 300
	retreat_distance = 3
	minimum_distance = 3
	speed = 8
	projectiletype = /obj/item/projectile/beam/drone
	projectilesound = 'sound/weapons/guns/gunpulse_laser3.ogg'
	destroy_surroundings = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail

	//0 - retaliate, only attack enemies that attack it
	//1 - hostile, attack everything that comes near

	var/explode_chance = 0
	var/disabled = 0
	var/exploding = FALSE

	//Drones aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	var/has_loot = 1
	faction = "malf_drone"

	animalistic = FALSE

/mob/living/simple_animal/hostile/retaliate/malf_drone/atom_init()
	. = ..()
	loot_list = list(/obj/item/stack/sheet/plasteel = rand(1, 3), /obj/item/stack/rods = rand(1, 3), /obj/item/weapon/shard = rand(1, 3))
	if(prob(5))
		projectiletype = /obj/item/projectile/beam/pulse/drone
		projectilesound = 'sound/weapons/guns/gunpulse2.ogg'
	ion_trail = new
	ion_trail.set_up(src)
	ion_trail.start()

/mob/living/simple_animal/hostile/retaliate/malf_drone/Process_Spacemove(movement_dir = 0)
	return 1

//self repair systems have a chance to bring the drone back to life
/mob/living/simple_animal/hostile/retaliate/malf_drone/Life()

	//emps and lots of damage can temporarily shut us down
	if(disabled)
		stat = UNCONSCIOUS
		disabled -= 2
		wander = FALSE
		speak_chance = 0
		if(disabled <= 0)
			stat = CONSCIOUS
			wander = TRUE
			speak_chance = initial(speak_chance)

	//repair a bit of damage
	if(prob(1))
		src.visible_message("<span class='warning'>[bicon(src)] [src] shudders and shakes as some of it's damaged systems come back online.</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		health += maxHealth * 0.3

	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

	if(health < maxHealth * 0.25) //if health gets too low, shut down
		explode_chance = 20
		exploding = FALSE
		if(!disabled)
			src.visible_message("<span class='notice'>[bicon(src)] [src] suddenly shuts down!</span>")
			disabled = rand(15, 40)

	if(!exploding && !disabled && prob(explode_chance))
		if(prob(explode_chance))
			exploding = TRUE
			stat = UNCONSCIOUS
			wander = TRUE
			var/time_to_explosion = rand(40, 100)
			src.visible_message("<span class='boldannounce'>[bicon(src)] [src] sparks and shakes, it can EXPLODE in [time_to_explosion / 10] seconds!</span>")
			spawn(time_to_explosion)
				if(!disabled && exploding)
					explosion(src.loc, 0, 1, 4, 7)
	update_icon()
	..()

/mob/living/simple_animal/hostile/retaliate/malf_drone/proc/update_icon()
	if(disabled)
		icon_state = "drone_0"
		return

	icon_state = "drone_[get_percent_health()]"

/mob/living/simple_animal/hostile/retaliate/malf_drone/proc/get_percent_health()
	return min(round(health * 100 / maxHealth, 25), 100)

//ion rifle!
/mob/living/simple_animal/hostile/retaliate/malf_drone/emp_act(severity)
	health -= rand(3, 15) * (severity + 1)
	disabled = rand(15, 40)

/mob/living/simple_animal/hostile/retaliate/malf_drone/death()
	src.visible_message("<span class='notice'>[bicon(src)] [src] suddenly breaks apart.</span>")
	..()
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/malf_drone/Destroy()
	QDEL_NULL(ion_trail)
	//some random debris left behind
	if(has_loot)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		var/obj/O

		for(var/obj/item in loot_list)
			O = new item.type(src.loc)
			step_to(O, get_turf(pick(view(7, src))))


		//also drop dummy circuit boards deconstructable for research (loot)
		var/obj/item/weapon/circuitboard/C

		//spawn 1-4 boards of a random type
		var/spawnees = 0
		var/num_boards = rand(1, 4)
		var/list/options = list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512)
		for(var/i=0, i<num_boards, i++)
			var/chosen = pick(options)
			options.Remove(options.Find(chosen))
			spawnees |= chosen

		if(spawnees & 1)
			C = new(src.loc)
			C.name = "Drone CPU motherboard"
			C.origin_tech = "programming=[rand(3,6)]"

		if(spawnees & 2)
			C = new(src.loc)
			C.name = "Drone neural interface"
			C.origin_tech = "biotech=[rand(3,6)]"

		if(spawnees & 4)
			C = new(src.loc)
			C.name = "Drone suspension processor"
			C.origin_tech = "magnets=[rand(3,6)]"

		if(spawnees & 8)
			C = new(src.loc)
			C.name = "Drone shielding controller"
			C.origin_tech = "bluespace=[rand(3,6)]"

		if(spawnees & 16)
			C = new(src.loc)
			C.name = "Drone power capacitor"
			C.origin_tech = "powerstorage=[rand(3,6)]"

		if(spawnees & 32)
			C = new(src.loc)
			C.name = "Drone hull reinforcer"
			C.origin_tech = "materials=[rand(3,6)]"

		if(spawnees & 64)
			C = new(src.loc)
			C.name = "Drone auto-repair system"
			C.origin_tech = "engineering=[rand(3,6)]"

		if(spawnees & 128)
			C = new(src.loc)
			C.name = "Drone phoron overcharge counter"
			C.origin_tech = "phorontech=[rand(3,6)]"

		if(spawnees & 256)
			C = new(src.loc)
			C.name = "Drone targetting circuitboard"
			C.origin_tech = "combat=[rand(3,6)]"

		if(spawnees & 512)
			C = new(src.loc)
			C.name = "Corrupted drone morality core"
			C.origin_tech = "syndicate=[rand(3,6)]"

	return ..()

/obj/item/projectile/beam/drone
	damage = 15

/obj/item/projectile/beam/pulse/drone
	damage = 10
