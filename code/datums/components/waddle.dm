/datum/component/waddle
	var/waddle_height
	var/list/waddle_angles

/datum/component/waddle/Initialize(_waddle_height, _waddle_angles, list/waddle_on)
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE

	waddle_height = _waddle_height
	waddle_angles = _waddle_angles

	if(ismob(parent))
		RegisterSignal(parent, waddle_on, .proc/waddle_mob)
	else if(isobj(parent))
		RegisterSignal(parent, waddle_on, .proc/waddle_obj)

/datum/component/waddle/proc/waddle_mob(atom/movable/AM, dir)
	var/mob/M = parent
	if(!M.incapacitated() && !M.crawling && !M.notransform && !M.anchored)
		var/matrix/old_transform = M.transform
		animate(M, pixel_z = waddle_height, time = 0)
		animate(pixel_z = 0, transform = turn(M.transform, pick(waddle_angles)), time=2)
		animate(pixel_z = 0, transform = old_transform, time = 0)

/datum/component/waddle/proc/waddle_obj(atom/movable/AM, dir)
	var/obj/O = parent
	if(!O.anchored)
		var/matrix/old_transform = O.transform
		animate(O, pixel_z = waddle_height, time = 0)
		animate(pixel_z = 0, transform = turn(O.transform, pick(waddle_angles)), time=2)
		animate(pixel_z = 0, transform = old_transform, time = 0)
