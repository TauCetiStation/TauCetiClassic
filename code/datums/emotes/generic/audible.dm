/datum/emote/whimper
	key = "whimper"

	message_1p = "You whimper."
	message_3p = "whimpers."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "makes a sad face."

	message_miming = "whimpers."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)


/datum/emote/roar
	key = "roar"

	message_1p = "You roar!"
	message_3p = "roars!"

	message_impaired_production = "makes a loud noise!"

	message_miming = "acts out a roar!"
	message_muzzled = "makes a loud noise!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/roar/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user)] mouth wide and scary!"

/datum/emote/gasp
	key = "gasp"

	message_1p = "You gasp!"
	message_3p = "gasps!"

	message_impaired_production = "sucks in air violently!"
	message_impaired_reception = "sucks in air violently!"

	message_miming = "appears to be gasping!"
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

	cloud = "cloud-gasp"


/datum/emote/choke
	key = "choke"

	message_1p = "You choke."
	message_3p = "chokes."

	message_impaired_production = "makes a weak noise."

	message_miming = "chokes."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

	cloud = "cloud-gasp"

/datum/emote/choke/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user)] throat desperately!"

/datum/emote/moan
	key = "moan"

	message_1p = "You moan!"
	message_3p = "moans!"

	message_impaired_production = "moans silently."

	message_miming = "appears to moan!"
	message_muzzled = "moans silently!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)

/datum/emote/moan/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user)] mouth wide"

/datum/emote/cough
	key = "cough"

	message_1p = "You cough."
	message_3p = "coughs."

	message_impaired_production = "spasms violently!"

	message_miming = "acts out a cough."
	message_muzzled = "appears to cough."

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

/datum/emote/cough/get_impaired_msg(mob/user)
	return "moves [P_THEIR(user)] face forward as [P_THEY(user)] open and close [P_THEIR(user)] mouth!"
