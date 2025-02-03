///////////////////////////////////////////

/obj/effect/proc_holder/spell/in_hand/mansus_grasp
	name = "Хватка Мансуса"
	desc = "Оглушает цель при прикосновении."
	action_icon_state = "mansus_grasp"
	action_background_icon_state = "bg_heretic"
	summon_path = /obj/item/weapon/magic/mansus_grasp
	charge_max = 10 SECONDS
	clothes_req = FALSE

/obj/item/weapon/magic/mansus_grasp
	name = "хватка Мансуса"
	invoke = "R'CH T'H TR'TH!"
	icon_state = "mansus_grasp"
	touch_spell = TRUE

	s_fire = 'sound/magic/MansusGrasp2.ogg'

/obj/item/weapon/magic/mansus_grasp/cast_touch(mob/living/L, mob/living/carbon/user)
	set waitfor = FALSE

	if(!istype(user) || !istype(L))
		return FALSE

	if(isheretic(L))
		return FALSE

	if(!L.Adjacent(src))
		return FALSE

	. = ..()

	L.adjustHalLoss(80)
	L.AdjustWeakened(5)
	L.emote("drool")
	to_chat(L, "<span class='heretic'>The Forbidden Knowledge is tearing your mind apart!</span>")

/obj/item/weapon/magic/mansus_grasp/attack(mob/living/M, mob/living/user, def_zone)
	if(!cast_touch(M, user))
		return FALSE
	if(s_fire)
		playsound(user, s_fire, VOL_EFFECTS_MASTER)
	if(invoke)
		user.say(invoke)
	return TRUE
///////////////////////////////////////////
