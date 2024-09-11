// === MEMETIC ANOMALY ===
// =======================

/**
This life form is a form of parasite that can gain a certain level of control
over its host. Its player will share vision and hearing with the host, and it'll
be able to influence the host through various commands.
**/

// The maximum amount of points a meme can gather.
var/global/const/MAXIMUM_MEME_POINTS = 750


// === PARASITE ===
// ================

// a list of all the parasites in the mob
/mob/var/list/parasites = list()

/mob/living/parasite
	var/mob/living/carbon/host // the host that this parasite occupies
	show_examine_log = FALSE

/mob/living/parasite/Login()
	..()
	if(host)
		client.eye = host
	else
		client.eye = loc
	client.perspective = EYE_PERSPECTIVE
	SetSleeping(0)

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

/mob/proc/clearHUD()
	if(client)
		client.screen.Cut()

// Game mode helpers, used for theft objectives
// --------------------------------------------
/mob/living/parasite/check_contents_for(t)
	if(!host)
		return 0

	return host.check_contents_for(t)

/*mob/living/parasite/check_contents_for_reagent(t)
	if(!host) return 0

	return host.check_contents_for_reagent(t) */
