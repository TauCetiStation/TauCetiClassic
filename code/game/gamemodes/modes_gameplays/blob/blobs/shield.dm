/obj/structure/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "Some blob creature thingy."
	opacity = TRUE
	max_integrity = 75
	fire_resist = 2

/obj/structure/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/shield/CanPass(atom/movable/mover, turf/target, height=0)
	return istype(mover) && mover.checkpass(PASSBLOB)

/obj/structure/blob/shield/reflective
	name = "reflective blob"
	icon_state = "blob_reflect"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	max_integrity = 30 //Normal blob
	brute_resist = 1 //Normal is 4
	fire_resist = 1 //2 welder hits
	var/static/list/reflects = list(/obj/item/projectile/energy, /obj/item/projectile/beam, /obj/item/projectile/pyrometer,
		/obj/item/projectile/plasma, /obj/item/projectile/bullet/stunshot)

/obj/structure/blob/shield/reflective/bullet_act(obj/item/projectile/P, def_zone)
	if(is_type_in_list(P,reflects))
		if(istype(P, /obj/item/projectile/beam/emitter))
			return ..()
		else if(istype(P, /obj/item/projectile/plasma))
			P.damage /= 4
			return ..()

		//Basically all of other energy type projes...
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, 0, 0, -1, 1, -2, 2, -3, 3)
			var/new_y = P.starting.y + pick(0, 0, 0, 0, -1, 1, -2, 2, -3, 3)
			var/turf/curloc = get_turf(src)
			if(OV) //If we have an overmind to blame this shot on
				P.redirect(new_x, new_y, curloc, OV) //Stolen from armor' deflection
				return PROJECTILE_FORCE_MISS
			P.redirect(new_x, new_y, curloc) //Stolen from armor' deflection
			return PROJECTILE_FORCE_MISS
	return ..()
