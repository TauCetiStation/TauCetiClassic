/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	unacidable = TRUE // Just to be sure.
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in human_list)
		dat += text("    <B>[]</B> -  []<BR>", M.name, M.get_assignment())
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	P.update_icon()
	//SN src = null
	qdel(src)
	return
