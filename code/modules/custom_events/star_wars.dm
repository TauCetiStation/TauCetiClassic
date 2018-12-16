
/turf/unsimulated/floor/glass_floor
	name = "floor"
	icon = 'code/modules/custom_events/icons.dmi'
	icon_state = "glassfloor1"

/turf/unsimulated/floor/glass_floor/atom_init()
	icon_state = "glassfloor_[rand(1, 6)]"

/obj/structure/sign/SW
	icon = 'code/modules/custom_events/icons.dmi'
	icon_state = "SW_republic_emblem"
	desc = "That's a strange emblem of an unknown empire."

/obj/structure/sign/SW/republic
	name = "\improper Galactical Republic"
	icon_state = "SW_republic_emblem"

/obj/structure/sign/SW/empire
	name = "\improper Galactical Empire"
	icon_state = "SW_republic_emblem"

/obj/structure/sign/SW/rebels
	name = "\improper Rebels Emblem"
	icon_state = "SW_republic_rebels"

/obj/effect/proc_holder/spell/targeted/suffocation_sith
	name = "Suffocation"
	desc = "Stuns and suffocates a target for a decent duration."
	panel = "Shadowling Abilities"
	charge_max = 10
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/suffocation_sith/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target))
			charge_counter = charge_max
			return
		if(target.stat)
			charge_counter = charge_max
			return
		var/mob/living/carbon/human/M = target
		usr.visible_message("<span class='warning'><b>[usr] raises his hand</b></span>")
		target.visible_message("<span class='danger'>[target] freezes in place, chokes and holds his neck...</span>")
		to_chat(target, "<span class='userdanger'>You cant breathe!</span>")
		target.Stun(10)
		M.silent += 10
		M.emote("gasp")
		M.adjustOxyLoss(rand(5,10))
		sleep(30)
		M.emote("gasp")
		M.adjustOxyLoss(rand(5,10))
