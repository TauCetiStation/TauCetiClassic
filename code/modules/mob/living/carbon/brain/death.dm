/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed && container && isMMI(container))//If not gibbed but in a container.
		container.visible_message("<span class='warning'><B>[src]'s MMI flatlines!</B></span>", blind_message = "<span class='warning'>You hear something flatline.</span>")
		container.icon_state = "mmi_dead"
	stat = DEAD

	update_sight()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)	//mind. ?

	return ..(gibbed)

/mob/living/carbon/brain/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

//	flick("gibbed-m", animation)
	gibs(loc, dna)

	dead_mob_list -= src
	if(container && isMMI(container))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/brain))
			qdel(loc)//Gets rid of the brain item
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)
