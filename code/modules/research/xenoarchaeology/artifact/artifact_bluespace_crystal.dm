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
	var/anomaly_spawn_list = list ("gravitational anomaly" = 1, "flux wave anomaly" = 1, "bluespace anomaly" = 1, "pyroclastic anomaly" = 1, "vortex anomaly" = 1,)
//	filling_color = "#24C1FF"


/obj/machinery/artifact/bluespace_crystal/New()
	..()
	my_effect = new /datum/artifact_effect/tesla(src)
	my_effect.trigger = 13 //TRIGGER_NEAR
	desc = "A blue strange crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano120"
	icon_num = 12
	set_light(4)

/obj/machinery/artifact/bluespace_crystal/tesla_act(power)
	tesla_zap(src, 1, power/2)
	return

/obj/machinery/artifact/bluespace_crystal/Destroy()
	var/turf/mainloc = get_turf(src)
	var/count_cristall = rand(1,5)
	for(var/i = 0;i<count_cristall;i++)
		new /obj/item/bluespace_crystal(mainloc)
	var/obj/item/device/assembly/signaler/anomaly/anom = new /obj/item/device/assembly/signaler/anomaly(src)
	var/anomaly = pickweight(anomaly_spawn_list)
	switch(anomaly)
		if("gravitational anomaly")
			anom.origin_tech = "magnets=8;powerstorage=4"
		if("flux wave anomaly")
			anom.origin_tech = "powerstorage=8;programming=4;phorontech=4"
		if("bluespace anomaly")
			anom.origin_tech = "bluespace=8;magnets=5;powerstorage=3"
		if("pyroclastic anomaly")
			anom.origin_tech = "phorontech=8;powerstorage=4;biotech=6"
		if("vortex anomaly")
			anom.origin_tech = "materials=8;combat=4;engineering=4"

	tesla_zap(src,7,2500000)
	return ..()

/obj/machinery/artifact/bluespace_crystal/proc/get_damage(damage)
	if(damage < 0)
		damage =0
	health = health - damage
	tesla_zap(src,round(damage/10),round(damage/5)*25000)
	if(health < 0)
		Destroy()

/obj/machinery/artifact/bluespace_crystal/bullet_act(obj/item/projectile/Proj)
	if(prob(Proj.damage))
		get_damage(Proj.damage)
	..()

/obj/machinery/artifact/bluespace_crystal/attackby(obj/item/weapon/W, mob/user)

	get_damage(W.force)
	..()

/obj/machinery/artifact/bluespace_crystal/ex_act(severity)
	get_damage(50*severity)

	return
