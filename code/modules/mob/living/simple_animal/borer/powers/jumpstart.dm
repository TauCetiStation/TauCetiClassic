/obj/effect/proc_holder/borer/active/noncontrol/jumpstart
	name = "Host Reanimation"
	desc = "Emit a controlled electric shock to restore beating of host's heart."
	cost = 1
	cooldown = 60 SECONDS
	chemicals = 350
	var/healing = 100
	requires_upgrades = list(
		/obj/effect/proc_holder/borer/active/noncontrol/awakening_shock,
		/obj/effect/proc_holder/borer/enlarged_glands,
	)
	check_capability = FALSE
	check_docility = FALSE

/obj/effect/proc_holder/borer/active/noncontrol/jumpstart/activate()
	. = ..()
	if(holder.host.stat != DEAD)
		to_chat(holder, "Your host is already alive!")
		return FALSE
	
	var/all_damage = holder.host.getBruteLoss() + holder.host.getFireLoss() + holder.host.getOxyLoss() + holder.host.getToxLoss() + holder.host.getCloneLoss()
	if(all_damage - healing > 150)
		to_chat(holder, "Host body is too wounded to reanimate.")
		return FALSE
	
	to_chat(holder, "<span class='notice'>You prepare the host body for reanimation.</span>")
	var/dam_diff = all_damage - 150
	if(dam_diff > 0)
		holder.host.apply_damages(
			brute = -dam_diff * holder.host.getBruteLoss() / all_damage,
			burn  = -dam_diff * holder.host.getFireLoss() / all_damage,
			tox   = -dam_diff * holder.host.getToxLoss() / all_damage,
			oxy   = -dam_diff * holder.host.getOxyLoss() / all_damage,
			clone = -dam_diff * holder.host.getCloneLoss() / all_damage
		)

	var/mob/living/carbon/human/H = holder.host
	if(istype(H))
		H.return_to_body_dialog()
		var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
		IO?.heart_fibrillate()

	if(!do_after(holder, 5 SECONDS, target = holder.host))
		return
	
	holder.host.stat = UNCONSCIOUS

	holder.host.apply_effects(
		stutter = 5,
		weaken = 5
	)
	holder.host.make_jittery(30)

	if(istype(H))
		H.reanimate_body()
		var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
		IO?.heart_normalize()
		H.ChangeToHusk()

	addtimer(CALLBACK(src, .proc/reanimate_msg, holder.host), 5 SECONDS)

/obj/effect/proc_holder/borer/active/noncontrol/jumpstart/proc/reanimate_msg(mob/living/carbon/C)
	if(C.stat != DEAD)
		C.visible_message("<span class='danger'>With a hideous, rattling moan, [C] shudders back to life!</span>")
