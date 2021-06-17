/obj/effect/proc_holder/borer/active/noncontrol/assume_control
	name = "Assume Control"
	desc = "Fully connect to the brain of your host."

/obj/effect/proc_holder/borer/active/noncontrol/assume_control/activate(mob/living/simple_animal/borer/B)
	if(B.assuming)
		to_chat(B, "You are already assuming a host body!")
		return

	if(!B.host)
		to_chat(B, "You are not inside a host body.")
		return

	if(B.incapacitated())
		to_chat(B, "You cannot do that in your current state.")
		return

	if(ishuman(B.host))
		var/mob/living/carbon/human/H = B.host
		if(!H.organs_by_name[O_BRAIN]) //this should only run in admin-weirdness situations, but it's here non the less - RR
			to_chat(B, "<span class='warning'>There is no brain here for us to command!</span>")
			return

	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	to_chat(B, "You begin delicately adjusting your connection to the host brain...")
	B.assuming = TRUE

	addtimer(CALLBACK(B, /mob/living/simple_animal/borer/proc/take_control), 300 + (B.host.brainloss * 5))

/mob/living/simple_animal/borer/proc/take_control()
	assuming = FALSE
	if(!host || !src || controlling)
		return

	to_chat(src, "<span class='warning'><B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B></span>")
	to_chat(host, "<span class='warning'><B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B></span>")

	host_brain.ckey = host.ckey
	host.ckey = ckey
	controlling = TRUE

	host.med_hud_set_status()
