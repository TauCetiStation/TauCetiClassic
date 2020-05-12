/obj/effect/proc_holder/spell/targeted/lighting_shock
	name = "Lighting Shock"
	desc = "Hold your target with electricity for 5 seconds. Disarms target making drop all in hands and impossibility pick up it again."
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 220
	charge_counter = 0
	clothes_req = 1
	stat_allowed = 0
	invocation = "WEAP'OL DRAP VENO!"
	invocation_type = "shout"
	range = 7
	selection_type = "range"
	action_icon_state = "summons"
	var/static/list/compatible_mobs = null

/obj/effect/proc_holder/spell/targeted/lighting_shock/atom_init()
	. = ..()
	if(!compatible_mobs)
		compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey, /mob/living/carbon/monkey/punpun, /mob/living/carbon/human/tajaran, /mob/living/carbon/human/skrell, /mob/living/carbon/human/unathi, /mob/living/carbon/human/diona, /mob/living/carbon/human/abductor, /mob/living/carbon/human/golem, /mob/living/carbon/human/vox)

/obj/effect/proc_holder/spell/targeted/lighting_shock/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target
	while(targets.len)
		target = targets[targets.len]
		targets -= target
		if(istype(target) && !(target.handcuffed))
			break

	if(!(target.type in compatible_mobs))
		to_chat(user, "<span class='notice'>It'd be stupid to disarm [target]!</span>")
		return

	if(!(target in oview(range)))//If they are not  in overview after selection.
		to_chat(user, "<span class='notice'>They are too far away!</span>")
		return

	target.visible_message("<span class='danger'>[target] looks like is being blocked by something from the outside world...</span>", \
						   "<span class='danger'>You feel how strange powers holding you...</span>")

	playsound(target, 'sound/effects/electricity.ogg', VOL_EFFECTS_MASTER)

	// makes target drop weapons to floor
	target.drop_from_inventory(target.l_hand)
	target.drop_from_inventory(target.r_hand)

	// don't let target pick up items, overlays for lighting effects
	target.add_overlay(image(icon = 'icons/effects/effects.dmi', icon_state = "electricity"))
	target.next_click = world.time + 50
	// after time let target pick up items, removing overlays

	sleep(50)
	target.cut_overlay(image(icon = 'icons/effects/effects.dmi', icon_state = "electricity"))
