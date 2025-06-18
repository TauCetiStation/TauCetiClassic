
//malfunctioning combat drones
/mob/living/simple_animal/hostile/retaliate/malf_drone
	name = "Сombat drone"
	desc = "Автоматический боевой дрон, вооруженный новейшим вооружением и обладающий высокой прочностью корпуса."
	icon = 'icons/mob/monsters.dmi'
	icon_state = "drone_100"
	icon_living = "drone_100"
	icon_dead = "drone_0"
	ranged = TRUE
	amount_shoot = 2
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("ТРЕВОГА!",
	"Обнар-р-р-ружены вражде-б-б-бные существа.",
	"Установлены па-раметр-рр-ры потенциальной уг-г-грозыы.",
	"Перевод под-под-подсистемы в боевой режим. Тревога аль-ф-фа.",
	"Поиск враж-ж-ждебных единиц...")
	emote_see = list("beeps menacingly","whirrs threateningly","scans its immediate vicinity")
	health = 300
	maxHealth = 300
	retreat_distance = 3
	minimum_distance = 3
	speed = 8
	projectiletype = /obj/item/projectile/beam/xray
	projectilesound = 'sound/weapons/guns/gunpulse_laser3.ogg'
	destroy_surroundings = FALSE
	faction = "malf_drone"
	animalistic = FALSE

	var/datum/effect/effect/system/ion_trail_follow/ion
	var/disabled = FALSE
	var/has_loot = TRUE

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

/mob/living/simple_animal/hostile/retaliate/malf_drone/atom_init()
	. = ..()
	loot_list = list(
	/obj/item/stack/sheet/plasteel = rand(1, 3),
	/obj/item/stack/rods = rand(1, 3),
	/obj/item/weapon/shard = rand(1, 3))
	ion = new /datum/effect/effect/system/ion_trail_follow()
	ion.set_up(src)
	ion.start()

/mob/living/simple_animal/hostile/retaliate/malf_drone/Process_Spacemove(movement_dir = 0)
	return 1

//self repair systems have a chance to bring the drone back to life
/mob/living/simple_animal/hostile/retaliate/malf_drone/Life()

	//repair a bit of damage
	if(prob(1))
		visible_message("<span class='warning'>[bicon(src)] [src] начинает дергаться. Некоторые из его поврежденных систем восстанавливаются.</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		health += maxHealth * 0.25

	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

	update_icon()
	return ..()

/mob/living/simple_animal/hostile/retaliate/malf_drone/update_icon()
	if(disabled)
		icon_state = "drone_0"
		return

	icon_state = "drone_[get_percent_health()]"

/mob/living/simple_animal/hostile/retaliate/malf_drone/proc/get_percent_health()
	return min(round(health * 100 / maxHealth, 25), 100)

//ion rifle!
/mob/living/simple_animal/hostile/retaliate/malf_drone/emp_act(severity)
	disable(rand(70, 140) * (severity + 1))
	health -= rand(15, 30) * (severity + 1)

/mob/living/simple_animal/hostile/retaliate/malf_drone/proc/disable(time)
	visible_message("<span class='notice'>[bicon(src)] [src] внезапно выключается!</span>")
	disabled = TRUE
	stat = UNCONSCIOUS
	wander = FALSE
	speak_chance = 0
	addtimer(CALLBACK(src, PROC_REF(enable)), time)

/mob/living/simple_animal/hostile/retaliate/malf_drone/proc/enable()
	visible_message("<span class='notice'>[bicon(src)] [src] включается.</span>")
	disabled = FALSE
	stat = CONSCIOUS
	wander = TRUE
	speak_chance = initial(speak_chance)

/mob/living/simple_animal/hostile/retaliate/malf_drone/death()
	visible_message("<span class='notice'>[bicon(src)] [src] разваливается на части.</span>")
	..()
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/malf_drone/Destroy()
	QDEL_NULL(ion)
	//some random debris left behind
	if(has_loot)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		//also drop dummy circuit boards deconstructable for research (loot)
		var/obj/item/weapon/circuitboard/C

		//spawn 1-4 boards of a random type
		var/num_boards = rand(1, 4)
		var/list/options = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
		for(var/i = 0, i < num_boards, i++)
			var/chosen = pick_n_take(options)
			switch(chosen)
				if(1)
					C = new(loc)
					C.name = "Drone CPU motherboard"
					C.origin_tech = "programming=[rand(4, 6)]"

				if(2)
					C = new(loc)
					C.name = "Drone neural interface"
					C.origin_tech = "biotech=[rand(4, 6)]"

				if(3)
					C = new(loc)
					C.name = "Drone suspension processor"
					C.origin_tech = "magnets=[rand(4, 6)]"

				if(4)
					C = new(loc)
					C.name = "Drone shielding controller"
					C.origin_tech = "bluespace=[rand(4, 6)]"

				if(5)
					C = new(loc)
					C.name = "Drone power capacitor"
					C.origin_tech = "powerstorage=[rand(4, 6)]"

				if(6)
					C = new(loc)
					C.name = "Drone hull reinforcer"
					C.origin_tech = "materials=[rand(4, 6)]"

				if(7)
					C = new(loc)
					C.name = "Drone auto-repair system"
					C.origin_tech = "engineering=[rand(4, 6)]"

				if(8)
					C = new(loc)
					C.name = "Drone phoron overcharge counter"
					C.origin_tech = "phorontech=[rand(4, 6)]"

				if(9)
					C = new(loc)
					C.name = "Drone targetting circuitboard"
					C.origin_tech = "combat=[rand(4, 6)]"

				if(10)
					C = new(loc)
					C.name = "Corrupted drone morality core"
					C.origin_tech = "syndicate=[rand(4, 6)]"

	return ..()

/mob/living/simple_animal/hostile/retaliate/malf_drone/dangerous
	health = 400
	maxHealth = 400
	retreat_distance = 7
	minimum_distance = 7
