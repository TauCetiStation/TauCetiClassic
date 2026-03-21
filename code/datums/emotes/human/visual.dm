/datum/emote/human/bow
	key = "bow"

	message_1p = "You bow."
	message_3p = "bows."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/yawn
	key = "yawn"

	message_1p = "You yawn."
	message_3p = "yawns."

	message_impaired_reception = "You hear someone yawn."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/blink
	key = "blink"

	message_1p = "You blink."
	message_3p = "blinks."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/wink
	key = "wink"

	message_1p = "You wink."
	message_3p = "winks."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/grin
	key = "grin"

	message_1p = "You grin."
	message_3p = "grins."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/drool
	key = "drool"

	message_1p = "You drool."
	message_3p = "drools."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/smile
	key = "smile"

	message_1p = "You smile."
	message_3p = "smiles."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/frown
	key = "frown"

	message_1p = "You frown."
	message_3p = "frowns."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/eyebrow
	key = "eyebrow"

	message_1p = "You raise an eyebrow."
	message_3p = "raises an eyebrow."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/shrug
	key = "shrug"

	message_1p = "You shrug."
	message_3p = "shrugs."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/nod
	key = "nod"

	message_1p = "You nod."
	message_3p = "nods."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/shake
	key = "shake"

	message_1p = "You shake your head."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)

/datum/emote/human/shake/get_emote_message_3p(mob/living/carbon/human/user)
	return "shakes [P_THEIR(user)] head."


/datum/emote/human/twitch
	key = "twitch"

	message_1p = "You twitch."
	message_3p = "twitches."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/human/deathgasp
	key = "deathgasp"

	message_1p = "You seize up and fall limp, your eyes dead and lifeless..."

	message_impaired_reception = "You hear a thud."

	message_type = SHOWMSG_VISUAL

	required_intentional_stat = CONSCIOUS

/datum/emote/human/deathgasp/get_emote_message_3p(mob/living/carbon/human/user)
	return "seizes up and falls limp, [P_THEIR(user)] eyes dead and lifeless..."

/datum/emote/human/flip
	key = "flip"

	message_type = SHOWMSG_VISUAL


	message_1p = "You are doing a flip."
	message_3p = "does a flip."
	required_stat = CONSCIOUS

	required_bodyparts = list(BP_R_LEG, BP_L_LEG)


/datum/emote/human/flip/do_emote(mob/living/carbon/human/user)
	if(user.stunned || user.weakened)
		return
	if(user.crawling)
		message_1p = "You are doing a tactical roll."
		message_3p = "does a tactical roll."
	else
		message_1p = "You are doing a flip."
		message_3p = "does a flip."
	. = ..()
	var/cw = pick(TRUE, FALSE)
	user.SpinAnimation(7, 1, cw)
	if(istype(user.buckled, /obj/structure/stool/bed/chair) && prob(80))
		var/obj/structure/stool/bed/chair/ch = user.buckled
		if((ch.can_flipped == TRUE) && (ch.flipped == FALSE))
			user.visible_message("<span class='notice'>[user] flips \the [ch.name] down.</span>","<span class='notice'>You flip \the [ch.name] down.</span>")
			ch.flip()
			ch.unbuckle_mob()
			user.apply_effect(2, WEAKEN, 0)
			user.apply_damage(3, BRUTE, BP_HEAD)
	else if(user.crawling)
		user.adjustHalLoss(20)
		user.throw_at(get_step(user, user.dir), 1, 1)
	else if(prob(1) || (user.drunkenness >= DRUNKENNESS_SLUR))
		user.visible_message("<span class='warning'>[user] does a bad flip and lands right on his head. That must be pretty nasty!</span>","<span class='warning'OUCH!</span>")
		user.apply_effect(10, WEAKEN, 0)
		user.apply_damage(20, BRUTE, BP_HEAD)
		user.adjustBrainLoss(5)
