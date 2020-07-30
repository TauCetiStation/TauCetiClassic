/** 
  * SMOKE
  *  Summons smoke in radius of user.
  *  Not sure why this would be useful (it's not) but whatever. Ninjas need their smoke bombs.
  */
/obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke()
	set name = "Smoke Bomb"
	set desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	set category = "Ninja Ability"
	set popup_menu = 0//Will not see it when right clicking.

	if(!ninjacost(,2))
		var/mob/living/carbon/human/U = affecting
		var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
		smoke.set_up(10, 0, U.loc)
		smoke.start()
		playsound(U, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)
		s_bombs--
		s_coold = 1
		to_chat(U, "<span class='info'>There are <B>[s_bombs]</B> smoke bombs remaining.</span>")
	return
