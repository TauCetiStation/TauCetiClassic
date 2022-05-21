/datum/hud/proc/brain_hud()
	return

/datum/hud/proc/blob_hud()
	add_pwr_display(/atom/movable/screen/blob_power)
	add_healths(/atom/movable/screen/blob_health)

/datum/hud/proc/changeling_essence_hud()
	var/mob/living/parasite/essence/E = mymob

	add_essence_voice()
	add_phantom()

	add_internals()
	add_healths()
	add_health_doll()

	get_screen(/atom/movable/screen/essence/ling_abilities)

	if(E.is_changeling)
		get_screen(/atom/movable/screen/essence/return_to_body)
