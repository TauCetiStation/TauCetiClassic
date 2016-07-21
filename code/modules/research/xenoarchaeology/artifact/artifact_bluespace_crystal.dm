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

/obj/machinery/artifact/bluespace_crystal/tesla_act(var/power)
	tesla_zap(src, 1, power/2)
	return

/obj/machinery/artifact/bluespace_crystal/Destroy()
	var/turf/mainloc = get_turf(src)
	var/count_cristall = rand(1,10)
	for(var/i = 0;i<count_cristall;i++)
		new /obj/item/bluespace_crystal(mainloc)
	tesla_zap(src,7,2500000)
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

/obj/machinery/artifact/bluespace_crystal/ex_act(severity)
	var/damage = 150
	get_damage(((damage/5) - (severity * 5)))

	return