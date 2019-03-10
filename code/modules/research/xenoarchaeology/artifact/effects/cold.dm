// inverse of /datum/artifact_effect/heat
/datum/artifact_effect/cold
	effect_name = "Cold"
	var/target_temp

/datum/artifact_effect/cold/New()
	..()
	target_temp = rand(0, 180)
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	effect_type = pick(EFFECT_ORGANIC, EFFECT_BLUESPACE, EFFECT_SYNTH)

/datum/artifact_effect/cold/DoEffectTouch(mob/user)
	if(holder)
		to_chat(user, "<span class='notice'>A chill passes up your spine!</span>")
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			env.temperature = max(env.temperature - rand(5,50), 0)

/datum/artifact_effect/cold/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.temperature > target_temp)
			env.temperature -= pick(0, 0, 1)
		if(prob(80))
			var/turf/T = get_turf(holder)
			for(var/obj/O in range(effectrange, T))
				if(O.anchored)
					continue
				if(prob(30))
					return
				if(istype(O, /obj/item) && !istype(O, /obj/item/weapon/ice_shell))
					O.visible_message("<span class='notice'>A thick layer of ice covers \the [O]!</span>")
					var/obj/item/weapon/ice_shell/I = new /obj/item/weapon/ice_shell(O.loc)
					I.cover_item(O)


/obj/item/weapon/ice_shell
	name = "piece of ice"
	desc = "It's simply a chunk of ice."
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "ice_shell"
	item_state = "shard"
	force = 15
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	w_class = ITEM_SIZE_SMALL
	var/item_inside = null
	var/strength = 20

/obj/item/weapon/ice_shell/proc/cover_item(obj/item/O)
	O.loc = src
	item_inside = TRUE
	desc += " There is [O] inside of it. How did it get here?"
	update_icon()

/obj/item/weapon/ice_shell/update_icon()
	overlays.Cut()
	if(item_inside)
		underlays = getFlatIcon(item_inside)

/obj/item/weapon/ice_shell/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(item_inside && W.force > 2)
		strength -= W.force
		if(strength <= 0)
			visible_message("<span class='warning'>A [src] breaks apart, revealing \the [item_inside] inside!</span>")
			for(var/obj/O in src)
				O.loc = get_turf(src)
			item_inside = null
			qdel(src)
			return
