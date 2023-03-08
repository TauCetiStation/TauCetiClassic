/mob/living/carbon/monkey/gib()
	var/atom/movable/overlay/animation = new(loc)
	flick(icon('icons/mob/mob.dmi', "gibbed-m"), animation)
	..()
	QDEL_IN(animation, 2 SECOND)

/mob/living/carbon/monkey/dust()
	dust_process()
	new /obj/effect/decal/cleanable/ash(loc)

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)
		return
	
	stat = DEAD

	if(!gibbed)
		visible_message("<b>The [name]</b> lets out a faint chimper as it collapses and stops moving...")

	update_canmove()

	return ..(gibbed)
