/mob/proc/in_view(turf/T)
	return view(T)

/mob/camera/Eye/in_view(turf/T)
	var/list/viewed = new
	for(var/mob/living/carbon/human/H in human_list)
		if(get_dist(H, T) <= 7)
			viewed += H
	return viewed
