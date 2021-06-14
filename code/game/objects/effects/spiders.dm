//generic procs copied from obj/effect/alien
/obj/effect/spider
	name = "web"
	desc = "It's stringy and sticky."
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	density = FALSE
	var/health = 15

//similar to weeds, but only barfed out by nurses manually
/obj/effect/spider/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/effect/spider/attackby(obj/item/weapon/W, mob/user)
	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
	user.SetNextMove(CLICK_CD_MELEE)

	var/damage = W.force / 4.0

	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.use(0, user))
			damage = 15
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)

	health -= damage
	healthcheck()

/obj/effect/spider/bullet_act(obj/item/projectile/Proj)
	..()
	health -= Proj.damage
	healthcheck()

/obj/effect/spider/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/effect/spider/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/obj/effect/spider/stickyweb
	icon_state = "stickyweb1"

/obj/effect/spider/stickyweb/atom_init()
	. = ..()
	if(prob(50))
		icon_state = "stickyweb2"

/obj/effect/spider/stickyweb/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return 1
	else if(istype(mover, /mob/living))
		if(prob(50))
			to_chat(mover, "<span class='warning'>You get stuck in \the [src] for a moment.</span>")
			return 0
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return 1

/obj/effect/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	var/amount_grown = 0

/obj/effect/spider/eggcluster/atom_init()
	. = ..()
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)

/obj/effect/spider/eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = rand(6,24)
		for(var/i=0, i<num, i++)
			new /mob/living/simple_animal/friendly/spiderling(src.loc)
		qdel(src)

/obj/effect/decal/cleanable/spiderling_remains
	name = "Spiderling remains"
	desc = "Awful"
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"

/obj/effect/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	health = 60

/obj/effect/spider/cocoon/atom_init()
	. = ..()
	icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/effect/spider/cocoon/container_resist()
	var/mob/living/user = usr
	if(user.is_busy()) return
	var/breakout_time = 2
	user.SetNextMove(100)
	user.last_special = world.time + 100
	to_chat(user, "<span class='notice'>You struggle against the tight bonds! (This will take about [breakout_time] minutes.)</span>")
	visible_message("You see something struggling and writhing in the [src]!")
	if(do_after(user,(breakout_time*60*10),target=src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/effect/spider/cocoon/Destroy()
	visible_message("<span class='warning'>\the [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.loc = src.loc
	return ..()
