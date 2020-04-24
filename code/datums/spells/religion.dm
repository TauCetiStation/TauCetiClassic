/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_bible
	name = "Create bible"
	desc = "Bible"

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	favor_cost = 10
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_amt = 0

	action_icon_state = "bible"

	summon_type = list(/obj/item/weapon/storage/bible)

/obj/effect/proc_holder/spell/targeted/heal
	name = "Heal"
	favor_cost = 10 //TODO
	charge_max = 120 //TODO
	clothes_req = 0
	invocation = "none"
	range = 6
	sound = 'sound/magic/heal.ogg' //TODO
	selection_type = "range"

	action_icon_state = "heal"

	divine_power = -10 //power

/obj/effect/proc_holder/spell/targeted/heal/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target
	while(targets.len)
		target = targets[targets.len]
		targets -= target
		if(istype(target))
			break

	if(!ishuman(target))
		to_chat(user, "<span class='notice'>It'd be stupid to give [target] such a life improvement!</span>")
		return

	var/mob/living/carbon/human/H = target
	if(!(H in oview(range))) // If they are not in overview after selection.
		to_chat(user, "<span class='warning'>They are too far away!</span>")
		return

	H.apply_damages(divine_power, divine_power, divine_power)
	cast_with_favor()

/obj/effect/proc_holder/spell/targeted/heal/damage
	name = "Damage"
	sound = 'sound/magic/Repulse.ogg'

	action_icon_state = "god_default"
	divine_power = 5 //power

/obj/effect/proc_holder/spell/targeted/blessing //TODO
	name = "Blessing"

	divine_power = 5 //power
	action_icon_state = "god_default"

/obj/effect/proc_holder/spell/targeted/charge //TODO
	name = "Charge electricity"

	divine_power = 5 //range
	action_icon_state = "god_default"

/obj/effect/proc_holder/spell/targeted/food //TODO
	name = "Spawn food"

	divine_power = 5 //count
	action_icon_state = "god_default"

/obj/effect/proc_holder/spell/targeted/forcewall/religion //TODO
	name = "Create energy wall"

	divine_power = 5 //CD
	action_icon_state = "god_default"

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal
	name = "Create random friendly animal"

	divine_power = 5 //count
	action_icon_state = "god_default"
