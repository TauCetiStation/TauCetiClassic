#define RADIUS_TIP "Is slippery."

/datum/mechanic_tip/vis_radius
	tip_name = RADIUS_TIP
	description = "This object will cause you to slip up if stepped on."



/datum/component/vis_radius
	var/radius = 0

/datum/component/vis_radius/Initialize(_radius)
	radius = _radius
	var/atom/movable/AM = parent
	var/it = ((3 + (radius * 2)) * 4) - 4
	var/list/L = list()
	for(var/i in 0 to radius)
		L += i
	for(var/i in 1 to it)
		for(var/int in L)
			need_x = 
			need_y = 
			var/obj/effect/overlay/O = new
			O.icon = 'icons/mob/screen1.dmi'
			O.icon_state = "radius"
			O.layer = ABOVE_LIGHTING_LAYER
			O.x = AM.x +
			O.y = AM.y +



	var/mob/a = parent
	a.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "fwaaw", I)

	//RegisterSignal(parent, list(COMSIG_VISIBLE_RADIUS), .proc/Slip)
	var/datum/mechanic_tip/vis_radius/slip_tip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(slip_tip))

#undef RADIUS_TIP
