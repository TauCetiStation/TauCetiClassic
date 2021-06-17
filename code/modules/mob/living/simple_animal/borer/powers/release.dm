/obj/effect/proc_holder/borer/active/control/release
	name = "Release Control"
	desc = "Release control of your host's body."

/obj/effect/proc_holder/borer/active/control/release/activate(mob/living/carbon/user)
	user.release_control()
	
/mob/living/carbon/proc/release_control()
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	if(B.controlling)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain].</span>")
		to_chat(B.host_brain, "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>")
		B.ckey = ckey
		B.controlling = FALSE

	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	med_hud_set_status()
