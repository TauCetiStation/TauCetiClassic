/mob/var/suiciding = FALSE

/mob/living/carbon/human/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	var/permitted = FALSE

	var/datum/component/mood/mood = GetComponent(/datum/component/mood)
	if(mood)
		if(mood.spirit_level == 6 && mood.mood_level <= 3) // highest spirit level (worst) and mood level in the lower third
			permitted = TRUE

	if(!permitted)
		var/static/list/allowed = list(NUKE_OP, TRAITOR, WIZARD, HEADREV, CULTIST, CHANGELING)
		for(var/T in allowed)
			if(isrole(T, src))
				permitted = TRUE
				break

	if(!permitted)
		message_admins("[ckey] has tried to suicide, but they were not permitted due to not being antagonist as human and being in a good mood. [ADMIN_JMP(usr)]")
		to_chat(src, "No. Adminhelp if there is a legitimate reason.")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm != "Yes")
		return

	if(restrained())	//just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, "You can't commit suicide whilst restrained! ((You can type Ghost instead however.))")
		return

	suiciding = TRUE
	var/obj/item/held_item = get_active_hand()

	if(!held_item)
		to_chat(viewers(src), pick( \
			"<span class='warning'><b>[src] is attempting to bite \his tongue off! It looks like \he's trying to commit suicide.</b></span>", \
			"<span class='warning'><b>[src] is jamming \his thumbs into \his eye sockets! It looks like \he's trying to commit suicide.</b></span>", \
			"<span class='warning'><b>[src] is twisting \his own neck! It looks like \he's trying to commit suicide.</b></span>", \
			"<span class='warning'><b>[src] is holding \his breath! It looks like \he's trying to commit suicide.</b></span>" \
			))
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()
		return

	var/damagetype = held_item.suicide_act(src)
	if(!damagetype)
		to_chat(src, "You can't figure out how to commit suicide with [held_item]")
		suiciding = FALSE
		return

	var/is_brute = damagetype & BRUTELOSS
	var/is_burn = damagetype & FIRELOSS
	var/is_tox = damagetype & TOXLOSS
	var/is_oxy = damagetype & OXYLOSS
	var/damage_mod = (is_brute != 0) + (is_burn != 0) + (is_tox != 0) + (is_oxy != 0)

	if(damage_mod == 0) // smt went wrong let's crush
		suiciding = FALSE
		CRASH("Wrong damage type '[damagetype]' for suicide_act")

	//Do 175 damage divided by the number of damage types applied.
	var/dmg = 175 / damage_mod

	if(is_brute)
		adjustBruteLoss(dmg)

	if(is_burn)
		adjustFireLoss(dmg)

	if(is_tox)
		adjustToxLoss(dmg)

	if(is_oxy)
		adjustOxyLoss(dmg)

	updatehealth()

/mob/living/carbon/brain/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		suiciding = TRUE
		to_chat(viewers(loc), "<span class='warning'><b>[src]'s brain is growing dull and lifeless. It looks like it's lost the will to live.</b></span>")
		spawn(50)
			death(0)

/mob/living/carbon/monkey/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		if(restrained())
			to_chat(src, "You can't commit suicide whilst restrained! ((You can type Ghost instead however.))")
			return
		suiciding = TRUE
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		to_chat(viewers(src), "<span class='warning'><b>[src] is attempting to bite \his tongue. It looks like \he's trying to commit suicide.</b></span>")
		adjustOxyLoss(max(175- getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/silicon/ai/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		suiciding = TRUE
		to_chat(viewers(src), "<span class='warning'><b>[src] is powering down. It looks like \he's trying to commit suicide.</b></span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		suiciding = TRUE
		to_chat(viewers(src), "<span class='warning'><b>[src] is powering down. It looks like \he's trying to commit suicide.</b></span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

// Kill yourself and become a ghost (You will receive a confirmation prompt).
/mob/living/silicon/pai/proc/suicide()
	var/answer = tgui_alert(usr, "REALLY kill yourself? This action can't be undone.", "Confirm Suicide", list("Yes", "No"))
	if(answer == "Yes")
		var/obj/item/device/paicard/card = loc
		card.removePersonality()
		card.visible_message("<span class='notice'>[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"</span>", blind_message = "<span class='notice'>[src] bleeps electronically.</span>")
		death(0)
	else
		to_chat(src, "Aborting suicide attempt.")

/mob/living/carbon/xenomorph/humanoid/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		suiciding = TRUE
		to_chat(viewers(src), "<span class='warning'><b>[src] is thrashing wildly! It looks like \he's trying to commit suicide.</b></span>")
		//put em at -175
		adjustOxyLoss(max(175 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()


/mob/living/carbon/slime/verb/suicide()
	set hidden = 1
	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))

	if(confirm == "Yes")
		suiciding = TRUE
		setOxyLoss(100)
		adjustBruteLoss(100 - getBruteLoss())
		setToxLoss(100)
		setCloneLoss(100)

		updatehealth()
