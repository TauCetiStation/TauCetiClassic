// We share overlays for all fluid turfs to sync icon animation.
var/list/fluid_images = list()
/proc/get_fluid_icon(img_state)
	if(!fluid_images[img_state])
		fluid_images[img_state] = image('icons/effects/liquids.dmi',img_state)
	return fluid_images[img_state]

#define FLUID_EVAPORATION_POINT 3          // Depth a fluid begins self-deleting
#define FLUID_DELETING -1                  // Depth a fluid counts as qdel'd
#define FLUID_SHALLOW 200                  // Depth shallow icon is used
#define FLUID_DEEP 800                     // Depth deep icon is used
#define FLUID_MAX_ALPHA 180
#define FLUID_MIN_ALPHA 30
#define FLUID_MAX_DEPTH FLUID_DEEP*4

/atom/proc/is_flooded(lying_mob, absolute) // code/modules/fluid/fluid_flooding.dm
	return

/mob/proc/handle_drowning()     // code/modules/fluid/fluid_drowning.dm
	return

/mob/proc/can_drown()           // code/modules/fluid/fluid_drowning.dm
	return FALSE

/atom/proc/water_act(depth) // code/modules/fluid/fluid_water_act.dm
	return

/atom/proc/return_fluid()       // code/modules/fluid/fluid_turf.dm
	return null

/atom/proc/check_fluid_depth(min)
	return 0

/atom/proc/get_fluid_depth()
	return 0

/datum/admins/proc/spawn_fluid_verb()
	set name = "Spawn Water"
	set desc = "Flood the turf you are standing on."
	set category = "Debug"
	if(!check_rights(R_SPAWN))
		return
	var/mob/user = usr
	if(istype(user) && user.client)
		user.client.spawn_fluid_proc()

/client/proc/spawn_fluid_proc()
	return
