/mob/var/suiciding = 0

/mob/living/carbon/human/verb/suicide()
	set hidden = 1

	if (stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if (!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return


	var/permitted = 0
	var/list/allowed = list("Syndicate","traitor","Wizard","Head Revolutionary","Cultist","Changeling")
	for(var/T in allowed)
		if(mind.special_role == T)
			permitted = 1
			break

	if(!permitted)
		message_admins("[ckey] has tried to suicide, but they were not permitted due to not being antagonist as human. [ADMIN_JMP(usr)]")
		to_chat(src, "No. Adminhelp if there is a legitimate reason.")
		return

	if (suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		if(restrained())	//just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
			to_chat(src, "You can't commit suicide whilst restrained! ((You can type Ghost instead however.))")
			return
		suiciding = 1
		var/obj/item/held_item = get_active_hand()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(damagetype)
				var/damage_mod = 1
				switch(damagetype) //Sorry about the magic numbers.
								   //brute = 1, burn = 2, tox = 4, oxy = 8
					if(15) //4 damage types
						damage_mod = 4

					if(6, 11, 13, 14) //3 damage types
						damage_mod = 3

					if(3, 5, 7, 9, 10, 12) //2 damage types
						damage_mod = 2

					if(1, 2, 4, 8) //1 damage type
						damage_mod = 1

					else //This should not happen, but if it does, everything should still work
						damage_mod = 1

				//Do 175 damage divided by the number of damage types applied.
				if(damagetype & BRUTELOSS)
					adjustBruteLoss(175/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(175/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(175/damage_mod)

				if(damagetype & OXYLOSS)
					adjustOxyLoss(175/damage_mod)

				//If something went wrong, just do normal oxyloss
				if(!(damagetype | BRUTELOSS) && !(damagetype | FIRELOSS) && !(damagetype | TOXLOSS) && !(damagetype | OXYLOSS))
					adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				updatehealth()
				return


		to_chat(viewers(src), pick("<span class='warning'><b>[src] is attempting to bite \his tongue off! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='warning'><b>[src] is jamming \his thumbs into \his eye sockets! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='warning'><b>[src] is twisting \his own neck! It looks like \he's trying to commit suicide.</b></span>", \
							"<span class='warning'><b>[src] is holding \his breath! It looks like \he's trying to commit suicide.</b></span>"))
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
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

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		to_chat(viewers(loc), "<span class='warning'><b>[src]'s brain is growing dull and lifeless. It looks like it's lost the will to live.</b></span>")
		spawn(50)
			death(0)
			suiciding = 0

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

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		if(restrained())
			to_chat(src, "You can't commit suicide whilst restrained! ((You can type Ghost instead however.))")
			return
		suiciding = 1
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

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
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

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		to_chat(viewers(src), "<span class='warning'><b>[src] is powering down. It looks like \he's trying to commit suicide.</b></span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/silicon/pai/verb/suicide()
	set category = "pAI Commands"
	set desc = "Kill yourself and become a ghost (You will receive a confirmation prompt)."
	set name = "pAI Suicide"
	var/answer = input("REALLY kill yourself? This action can't be undone.", "Suicide", "No") in list ("Yes", "No")
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

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
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

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		setOxyLoss(100)
		adjustBruteLoss(100 - getBruteLoss())
		setToxLoss(100)
		setCloneLoss(100)

		updatehealth()
