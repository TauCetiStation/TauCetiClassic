/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	immune_to_ssd = TRUE
	me_verb_allowed = 0 //Can't use the emote proc, it's a freaking immobile brain
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"

/mob/living/carbon/brain/atom_init()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	. = ..()

/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		ghostize(bancheck = TRUE)		//Ghostize checks for key so nothing else is necessary.
	return ..()

/mob/living/carbon/brain/say_understands(other)//Goddamn is this hackish, but this say code is so odd
	if(isautosay(other))
		if(!(container && isMMI(container)))
			return 0
		else
			return 1
	if (isAI(other))
		if(!(container && isMMI(container)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/decoy))
		if(!(container && isMMI(container)))
			return 0
		else
			return 1
	if (ispAI(other))
		if(!(container && isMMI(container)))
			return 0
		else
			return 1
	if (isrobot(other))
		if(!(container && isMMI(container)))
			return 0
		else
			return 1
	if (ishuman(other))
		return 1
	if (isslime(other))
		return 1
	return ..()


/mob/living/carbon/brain/update_canmove()
	canmove = in_contents_of(/obj/mecha)

/mob/living/carbon/brain/update_hud()
	reload_fullscreen()
