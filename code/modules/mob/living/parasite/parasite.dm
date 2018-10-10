// === PARASITE ===
// ================

// a list of all the parasites in the mob
mob/living/carbon/var/list/parasites = list()

mob/living/parasite
	var/mob/living/carbon/host // the host that this parasite occupies

/mob/living/parasite/Login()
	..()
	if(host)
		client.eye = host
	else
		client.eye = loc
	client.perspective = EYE_PERSPECTIVE
	sleeping = 0

/mob/living/parasite/proc/enter_host(mob/living/carbon/host)
	src.host = host
	loc = host
	host.parasites.Add(src)
	if(client)
		client.eye = host
	return TRUE

/mob/living/parasite/proc/exit_host()
	host.parasites.Remove(src)
	host = null
	loc = null
	return TRUE