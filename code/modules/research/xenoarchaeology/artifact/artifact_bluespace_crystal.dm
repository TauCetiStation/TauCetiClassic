/obj/machinery/artifact/bluespace_crystal
	name = "bluespace crystal"
	icon_state = "ano120"
	icon_num = 0
	density = 1
	being_used = 0
	need_inicial = 0
	anchored = 1
	light_color = "#24C1FF"
	var/health = 200
	var/anomaly_spawn_list = list ("gravitational anomaly" = 1, "flux wave anomaly" = 1, "bluespace anomaly" = 6, "pyroclastic anomaly" = 1, "vortex anomaly" = 1,)
//	filling_color = "#24C1FF"


/obj/machinery/artifact/bluespace_crystal/New()
	..()
	health = rand(150,300)
	my_effect = new /datum/artifact_effect/tesla(src)
	my_effect.trigger = 13 //TRIGGER_NEAR
	desc = "A blue strange crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano120"
	icon_num = 12
	set_light(4)

/obj/machinery/artifact/bluespace_crystal/tesla_act(var/power)
	tesla_zap(src, 1, power/2)
	return

/obj/machinery/artifact/bluespace_crystal/Destroy()
	var/turf/mainloc = get_turf(src)
	var/count_cristall = rand(1,5)
	for(var/i = 0;i<count_cristall;i++)
		new /obj/item/bluespace_crystal(mainloc)
	if(prob(80))
		var/obj/item/device/assembly/signaler/anomaly/anom = new /obj/item/device/assembly/signaler/anomaly(src)
		var/anomaly = pickweight(anomaly_spawn_list)
		switch(anomaly)
			if("gravitational anomaly")
				anom.origin_tech = "magnets=[rand(3,7)];powerstorage=[rand(2,5)]"
			if("flux wave anomaly")
				anom.origin_tech = "powerstorage=[rand(3,7)];programming=[rand(2,5)];plasmatech=[rand(2,5)]"
			if("bluespace anomaly")
				anom.origin_tech = "bluespace=[rand(3,7)];magnets=[rand(2,5)];powerstorage=[rand(2,5)]"
			if("pyroclastic anomaly")
				anom.origin_tech = "phorontech=[rand(3,7)];powerstorage=[rand(2,5)];biotech=[rand(3,7)]"
			if("vortex anomaly")
				anom.origin_tech = "materials=[rand(3,7)];combat=[rand(2,5)];engineering=[rand(2,5)]"

	tesla_zap(src,7,2500000)
	if(prob(50))
		teleport()
	..()

/obj/machinery/artifact/bluespace_crystal/proc/get_damage(var/damage)
	if(damage < 0)
		damage =0
	health = health - damage
	tesla_zap(src,round(damage/10),round(damage/5)*25000)
	if(health < 0)
		Destroy()

/obj/machinery/artifact/bluespace_crystal/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage))
		get_damage(Proj.damage)
	..()

/obj/machinery/artifact/bluespace_crystal/attackby(var/obj/item/weapon/W, var/mob/user)

	get_damage(W.force)
	..()

/obj/machinery/artifact/bluespace_crystal/proc/teleport()
	var/turf/T = get_turf(src)
	for (var/mob/living/M in range(7,T))
		M << "\red You are displaced by a strange force!"
		if(M.buckled)
			M.buckled.unbuckle_mob()

		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(M))
		sparks.start()
				//
		var/turf/N = pick(orange(get_turf(T), 50))
		do_teleport(M, N, 4)
		sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(M))
		sparks.start()

/obj/machinery/artifact/bluespace_crystal/ex_act(severity)
	get_damage(50*severity)

	return