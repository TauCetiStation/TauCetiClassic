/datum/emote/whimper
	key = "whimper"

	message_1p = "You whimper."
	message_3p = "whimpers."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone making a sad face."

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
	message_impaired_reception = "You see someone open their mouth wide and scary!"

	message_miming = "acts out a roar!"
	message_muzzled = "makes a loud noise!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/gasp
	key = "gasp"

	message_1p = "You gasp!"
	message_3p = "gasps!"

	message_impaired_production = "sucks in air violently!"
	message_impaired_reception = "You see someone sucking in air violently!"

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
	message_impaired_reception = "You see someone clutching their throat desperately!"

	message_miming = "chokes."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

	cloud = "cloud-gasp"


/datum/emote/moan
	key = "moan"

	message_1p = "You moan!"
	message_3p = "moans!"

	message_impaired_production = "moans silently."
	message_impaired_reception = "You see someone opening their mouth wide."

	message_miming = "appears to moan!"
	message_muzzled = "moans silently!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)


/datum/emote/cough
	key = "cough"

	message_1p = "You cough."
	message_3p = "coughs."

	message_impaired_production = "spasms violently!"
	message_impaired_reception = "You see someone moving their face forward as they open and close their mouth!"

	message_miming = "acts out a cough."
	message_muzzled = "appears to cough."

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)
