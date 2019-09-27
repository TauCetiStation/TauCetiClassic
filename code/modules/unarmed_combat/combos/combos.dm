#define COMBO_DISARM "Weapon Disarm"
#define COMBO_PUSH "Push"
#define COMBO_SUPLEX "Suplex"

/datum/combat_combo/disarm
	name = COMBO_DISARM
	combo_icon_state = "weapon_disarm"
	fullness_lose_on_execute = 20
	combo_elements = list(I_DISARM, I_DISARM, I_DISARM, I_DISARM)

	allowed_target_zones = TARGET_ZONE_ALL

/datum/combat_combo/disarm/execute(mob/living/victim, mob/living/attacker)
	for(var/obj/item/weapon/gun/G in list(victim.get_active_hand(), victim.get_inactive_hand()))
		var/chance = 0
		if(victim.get_active_hand() == G)
			chance = 40
		else
			chance = 20

		if(prob(chance))
			victim.visible_message("<span class='danger'>[victim]'s [G] goes off during struggle!</span>")
			var/list/turfs = list()
			for(var/turf/T in view(7, victim))
				turfs += T
			var/turf/target = pick(turfs)
			return G.afterattack(target, victim)

	victim.drop_item()
	victim.visible_message("<span class='warning'><B>[attacker] has disarmed [victim]!</B></span>")



/datum/combat_combo/push
	name = COMBO_PUSH
	combo_icon_state = "push"
	fullness_lose_on_execute = 50
	combo_elements = list(COMBO_DISARM, I_DISARM, I_DISARM, I_DISARM)

	allowed_target_zones = TARGET_ZONE_ALL

/datum/combat_combo/push/execute(mob/living/victim, mob/living/attacker)
	var/target_zone
	if(attacker.zone_sel)
		target_zone = attacker.zone_sel.selecting
	else
		target_zone = ran_zone(BP_CHEST)

	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
		armor_check = victim.run_armor_check(BP, "melee")

	victim.apply_effect(3, WEAKEN, armor_check)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has pushed [victim] to the ground!</span>")



/datum/combat_combo/suplex
	name = COMBO_SUPLEX
	combo_icon_state = "suplex"
	fullness_lose_on_execute = 75
	combo_elements = list(I_HURT, I_HURT, I_HURT, I_GRAB)

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/suplex/animate_combo(mob/living/victim, mob/living/attacker)
	sleep(3)
	var/DTM = get_dir(attacker, victim)
	var/victim_dir = get_dir(victim, attacker)
	var/shift_x = 0
	var/shift_y = 0
	switch(DTM)
		if(NORTH)
			shift_y = 32
		if(SOUTH)
			shift_y = -32
		if(WEST)
			shift_x = -32
		if(EAST)
			shift_x = 32
	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y

	victim.Stun(2)
	attacker.Stun(2) // So he doesn't do something funny during the trick.

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, time = 5)
	sleep(5)
	attacker.forceMove(victim.loc)
	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y

	var/matrix/M = matrix()
	M.Turn(pick(90, -90))
	var/matrix/victim_M = victim.transform
	prev_pix_x = victim.pixel_x
	prev_pix_y = victim.pixel_y
	animate(victim, transform = M, time = 2)
	sleep(2)
	animate(victim, pixel_y = victim.pixel_y + 15, time = 5)
	sleep(5)
	animate(victim, pixel_x = victim.pixel_x - shift_x, pixel_y = victim.pixel_y - 15 - shift_y, time = 2)
	sleep(2)
	victim.transform = victim_M
	victim.forceMove(get_step(victim, victim_dir))
	victim.pixel_x = prev_pix_x
	victim.pixel_y = prev_pix_y

	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(BP_CHEST)
		armor_check = victim.run_armor_check(BP, "melee")

	victim.apply_effect(6, WEAKEN, armor_check)
	victim.adjustBruteLoss(20)

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has thrown [victim] over their shoulder!</span>")

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/suplex/execute(mob/living/victim, mob/living/attacker)
	return

#undef COMBO_DISARM
#undef COMBO_PUSH
#undef COMBO_SUPLEX
