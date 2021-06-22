/obj/effect/proc_holder/borer/active/noncontrol/jumpstart
	name = "Host Reanimation"
	desc = "Emit a controlled electric shock to restore beating of host's heart."
	cost = 1
	cooldown = 60 SECONDS
	chemicals = 350
	var/healing = 100
	requires_t = list(
		/obj/effect/proc_holder/borer/active/noncontrol/awakening_shock,
		/obj/effect/proc_holder/borer/enlarged_glands,
	)

/obj/effect/proc_holder/borer/active/noncontrol/jumpstart/activate(mob/living/simple_animal/borer/B)
	if(B.host.stat != DEAD)
		to_chat(B, "Your host is already alive!")
		return
	
	var/all_damage = B.host.getBruteLoss() + B.host.getFireLoss() + B.host.getOxyLoss() + B.host.getToxLoss() + B.host.getCloneLoss()
	if(all_damage - healing > 150)
		to_chat(B, "Host body is too wounded to reanimate.")
		return
	
	if(!..())
		return
	to_chat(B, "<span class='notice'>You prepare the host body for reanimation.</span>")
	var/dam_diff = all_damage - 150
	if(dam_diff > 0)
		B.host.apply_damages(
			brute = -dam_diff * B.host.getBruteLoss() / all_damage,
			burn  = -dam_diff * B.host.getFireLoss() / all_damage,
			tox   = -dam_diff * B.host.getToxLoss() / all_damage,
			oxy   = -dam_diff * B.host.getOxyLoss() / all_damage,
			clone = -dam_diff * B.host.getCloneLoss() / all_damage
		)

	var/mob/living/carbon/human/H = B.host
	if(istype(H))
		H.return_to_body_dialog()
		var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
		IO?.heart_fibrillate()

	if(!do_after(B, 5 SECONDS, target = B.host))
		return
	
	B.host.stat = UNCONSCIOUS

	B.host.apply_effects(
		stutter = 5,
		weaken = 5
	)
	B.host.make_jittery(30)

	if(istype(H))
		H.reanimate_body()
		var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
		IO?.heart_normalize()
		H.ChangeToHusk()

	addtimer(CALLBACK(src, .proc/reanimate_msg, B.host), 5 SECONDS)

/obj/effect/proc_holder/borer/active/noncontrol/jumpstart/proc/reanimate_msg(mob/living/carbon/C)
	if(C.stat != DEAD)
		C.visible_message("<span class='danger'>With a hideous, rattling moan, [C] shudders back to life!</span>")
