#define SHIELDGEN_STATE_OFF 0
#define SHIELDGEN_STATE_ON 1

/obj/machinery/forts_shieldgen
	name = "shield generator"
	desc = "Shield generator, allows living creatures to pass through but not projectiles. Not resistant to EMP."
	var/list/created_field = list()
	var/state = SHIELDGEN_STATE_OFF
	var/field_radius = 5
	density = TRUE
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"

/obj/machinery/forts_shieldgen/proc/get_shielded_turfs()
	var/list/out = list()
	for(var/turf/T in range(field_radius, src))
		if(get_dist(src,T) == field_radius)
			out.Add(T)

	return out

/obj/machinery/forts_shieldgen/attack_hand(mob/user)
	if(user.is_busy(src) || !do_after(user, 5 SECONDS, target = src))
		return
	if(state == SHIELDGEN_STATE_OFF)
		activate()
		return
	deactivate()

/obj/machinery/forts_shieldgen/proc/activate()
	playsound(src, 'sound/machines/cfieldstart.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	anchored = TRUE
	state = SHIELDGEN_STATE_ON
	icon_state = "shieldon"

	var/list/covered_turfs = get_shielded_turfs()
	var/turf/T = get_turf(src)
	if(T in covered_turfs)
		covered_turfs.Remove(T)
	for(var/turf/O in covered_turfs)
		var/obj/effect/energy_field/forts/ef = new(O)
		ef.strength = 50
		ef.density = TRUE
		ef.anchored = TRUE
		ef.invisibility = 0
		created_field.Add(ef)

	covered_turfs = null

/obj/machinery/forts_shieldgen/proc/deactivate()
	playsound(src, 'sound/machines/cfieldfail.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -4)
	anchored = FALSE
	state = SHIELDGEN_STATE_OFF
	icon_state = "shieldoff"

	for(var/obj/effect/energy_field/forts/ef in created_field)
		created_field.Remove(ef)
		qdel(ef)

/obj/machinery/forts_shieldgen/emp_act(severity)
	if(state == SHIELDGEN_STATE_OFF)
		return
	deactivate()
	explosion(loc, 0, 1, 6)
