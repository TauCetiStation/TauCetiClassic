/mob/living/carbon/human
	var metadata

/mob/living/carbon/human/verb/examine_ooc()
	set name = "Examine OOC"
	set category = "OOC"
	set src in oview()

	if(!usr || !src)	return

	usr << "<font color='purple'>OOC-info: [src]</font>"
	if(metadata)
		usr << "<font color='purple'>[metadata]</font>"
	else
		usr << "<font color='purple'>Nothing of interest...</font>"