/mob/living/carbon/monkey/gib()
	var/atom/movable/overlay/animation = new(loc)
	flick(icon('icons/mob/mob.dmi', "gibbed-m"), animation)
	..()
	QDEL_IN(animation, 2 SECOND)

/mob/living/carbon/monkey/dust()
	new /obj/effect/decal/cleanable/ash(loc)
	dust_process()

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD

	if(!gibbed)
		visible_message("<b>The [name]</b> lets out a faint chimper as it collapses and stops moving...")

	update_canmove()

	. = ..(gibbed)
	if(. && virus2.len)
		for(var/datum/disease2/disease/V as anything in virus2)
			SEND_SIGNAL(V, COMSIG_MOB_DIED, src, gibbed)

