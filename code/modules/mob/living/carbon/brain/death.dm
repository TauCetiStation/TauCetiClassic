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
	var/old_loc = loc
	..()
	if(container && isMMI(container))
		qdel(container)//Gets rid of the MMI if there is one
	if(istype(old_loc, /obj/item/brain))
		qdel(old_loc)//Gets rid of the brain item
