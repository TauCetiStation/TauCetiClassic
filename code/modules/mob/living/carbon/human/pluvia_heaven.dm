/area/pluvia_heaven
	name = "Pluvia Heaven"
	icon_state = "unexplored"

/var/global/sochial_credit_threshold = 5

/mob/living/carbon/human/proc/bless()
	to_chat(src, "<span class='notice'>\ <font size=4>Высшая сила засвидетельствовала ваш подвиг. Врата рая ожидают вас.</span></font>")
	src.blessed = 1
	playsound_local(null, 'sound/effects/blessed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	var/image/eye = image('icons/mob/human_face.dmi', icon_state = "pluvia_ms_s")
	eye.plane = ABOVE_LIGHTING_PLANE
	add_overlay(eye)