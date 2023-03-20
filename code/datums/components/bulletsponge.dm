#define BULLETSPONGE_TIP "Is a bulletsponge."

/datum/mechanic_tip/bulletsponge
	tip_name = BULLETSPONGE_TIP
	description = "This object will pull every bullet and laser to it."

/datum/component/bulletsponge/Initialize()
	var/datum/mechanic_tip/bulletsponge/bs = new
	parent.AddComponent(/datum/component/mechanic_desc, list(bs))

/datum/component/bulletsponge/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(BULLETSPONGE_TIP))
	return ..()
