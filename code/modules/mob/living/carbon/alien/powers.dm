/mob/living/carbon/alien/proc/toggle_nvg(message = 1)
	var/obj/item/organ/brain/xeno/BRAIN = organs_by_name[BP_BRAIN]
	if(BRAIN)
		if(stat != CONSCIOUS)
			return

		src.nightvision = !src.nightvision

		if(!src.nightvision)
			src.see_in_dark = 8
			src.see_invisible = SEE_INVISIBLE_MINIMUM
			BRAIN.nightvisionicon.icon_state = "nightvision0"
		else if(src.nightvision == 1)
			src.see_in_dark = 4
			src.see_invisible = 45
			BRAIN.nightvisionicon.icon_state = "nightvision1"

		if(message)
			to_chat(src, "<span class='noticealien'>You adapt your eyes for [nightvision ? "dark":"light"] !</span>")
