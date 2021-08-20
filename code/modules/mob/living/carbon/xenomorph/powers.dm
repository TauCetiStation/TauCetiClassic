/mob/living/carbon/xenomorph/proc/toggle_nvg(message = 1)
	if(stat != CONSCIOUS)
		return

	src.nightvision = !src.nightvision

	if(!src.nightvision)
		src.nightvisionicon.icon_state = "nightvision0"
	else if(src.nightvision == 1)
		src.nightvisionicon.icon_state = "nightvision1"

	update_sight()
	if(message)
		to_chat(src, "<span class='noticealien'>You adapt your eyes for [nightvision ? "dark":"light"] !</span>")
	else
		return

/mob/living/carbon/xenomorph/proc/hide()
	set name = "Спрятаться"
	set desc = "Позволяет прятаться под столами и другими предметами. Включается и отключается."
	set category = "Alien"

	if(incapacitated())
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		visible_message("<span class='danger'>[src] исчезает.</span>", "<span class='notice'>Сейчас вы прячетесь.</span>")
	else
		layer = MOB_LAYER
		visible_message("<span class='warning'>[src] появляется.</span>", "<span class='notice'>Вы больше не прячетесь.</span>")
