/*
	Movesets that are granted by virtue
	of belonging to a certain mob type.
*/
/datum/combat_moveset/living
	name = "Living Form Moveset"
	teach_combos = list(
		COMBO_DISARM,
		COMBO_PUSH,
		COMBO_DROPKICK,

		COMBO_CHARGE
	)

/datum/combat_moveset/human
	name = "Human Form Moveset"
	teach_combos = list(
		COMBO_DISARM,
		COMBO_PUSH,
		COMBO_SLIDE_KICK,
		COMBO_CAPTURE,
		COMBO_DROPKICK,

		COMBO_UPPERCUT,
		COMBO_SUPLEX,
		COMBO_DIVING_ELBOW_DROP,
		COMBO_CHARGE,
		COMBO_SPIN_THROW,

		COMBO_WAKE_UP
	)

/datum/combat_moveset/slime
	name = "Slime Form Moveset"
	teach_combos = list(
		COMBO_DISARM,
		COMBO_PUSH,
		COMBO_DROPKICK,

		COMBO_CHARGE
	)

/datum/combat_moveset/animal
	name = "Animal Form Moveset"
	teach_combos = list(
		COMBO_DISARM,
		COMBO_PUSH,
		COMBO_DROPKICK,

		COMBO_CHARGE
	)


/datum/combat_moveset/cqc //For traitors, nukies, headrevs, undercover cops and quality.
	name = "CQC Moveset"
	teach_combos = list(
		COMBO_CAPTURE_CQC,
		COMBO_KICK_CQC,
		COMBO_HIGHKICK_CQC
	)

/datum/combat_moveset/cult //For cultists.
	name = "Cult Moveset"
	teach_combos = list(
		COMBO_NECK_CULT,
		COMBO_EYES_CULT,
		COMBO_BLOOD_BOIL_CULT
	)

/datum/combat_moveset/changeling //For changelings.
	name = "Changeling Moveset"
	teach_combos = list(
		COMBO_SWIPE_CHANGELING
	)

/datum/combat_moveset/traitorchan //For traitorchans.
	name = "Traitorchan Moveset"
	teach_combos = list(
		COMBO_CAPTURE_CQC,
		COMBO_KICK_CQC,
		COMBO_HIGHKICK_CQC,

		COMBO_SWIPE_CHANGELING
	)
