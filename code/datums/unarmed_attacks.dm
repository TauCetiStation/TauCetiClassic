/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/damType = BRUTE
	var/miss_sound = 'sound/effects/mob/hits/miss_1.ogg'
	var/sharp = FALSE
	var/edge = FALSE
	var/list/attack_sound

/datum/unarmed_attack/New()
	attack_sound = SOUNDIN_PUNCH_MEDIUM

/datum/unarmed_attack/proc/damage_flags()
	return (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")
	damage = 2

/datum/unarmed_attack/diona/podman
	damage = 1

/datum/unarmed_attack/slime_glomp
	attack_verb = list("glomp")
	damage = 5
	damType = CLONE

/datum/unarmed_attack/slime_glomp/New()
	attack_sound = list('sound/effects/attackblob.ogg')

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 2
	sharp = TRUE
	edge = TRUE

/datum/unarmed_attack/claws/New()
	attack_sound = list('sound/weapons/slice.ogg')

/datum/unarmed_attack/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 10	//they're huge! they should do a little more damage, i'd even go for 15-20 maybe...

/datum/unarmed_attack/claws/abomination
	attack_verb = list("slash", "claw", "lacerate")
	damage = 35

/datum/unarmed_attack/claws/serpentid
	attack_verb = list("mauled", "slashed", "struck", "pierced")
	damage = 6
	sharp = 1
	edge = 1
