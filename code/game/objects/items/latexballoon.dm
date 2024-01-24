/obj/item/latexballon
	name = "Latex glove"
	desc = "" //todo
	icon_state = "latexballon"
	item_state = "lgloves"
	force = 0
	throwforce = 0
	w_class = SIZE_TINY
	throw_speed = 1
	throw_range = 15
	var/state
	var/datum/gas_mixture/air_contents = null

/obj/item/latexballon/proc/blow(obj/item/weapon/tank/tank)
	if (icon_state == "latexballon_bursted")
		return
	src.air_contents = tank.remove_air_volume(3)
	icon_state = "latexballon_blow"
	item_state = "latexballon"

/obj/item/latexballon/proc/burst()
	if (!air_contents)
		return
	playsound(src, 'sound/weapons/guns/Gunshot.ogg', VOL_EFFECTS_MASTER)
	icon_state = "latexballon_bursted"
	item_state = "lgloves"
	loc.assume_air(air_contents)

/obj/item/latexballon/ex_act(severity)
	burst()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)

/obj/item/latexballon/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	burst()

/obj/item/latexballon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C+100)
		burst()
	return

/obj/item/latexballon/attackby(obj/item/I, mob/user, params)
	..()
	if(I.can_puncture())
		burst()
