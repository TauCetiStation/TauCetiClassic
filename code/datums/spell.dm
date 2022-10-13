/obj/effect/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.

var/global/list/spells = typesof(/obj/effect/proc_holder/spell) //needed for the badmin verb for now

/obj/effect/proc_holder/spell
	name = "Spell"
	desc = "A wizard spell."
	panel = "Spells"//What panel the proc holder needs to go on.
	density = FALSE
	opacity = 0
	var/sound = null //The sound the spell makes when it is cast

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?

	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"

	/****RELIGIOUS ASPECT****/
	var/favor_cost = 0 //cost
	var/divine_power = 0 //control of spell power depending on the aspect
	var/list/needed_aspects
	/****RELIGIOUS ASPECT****/

	var/plasma_cost = 0 //for xenomorph powers

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/clothes_req = TRUE //see if it requires clothes
	var/stat_allowed = FALSE //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell; outer radius for aoe spells
	var/message = "" //whatever it says to the guy affected by it
	var/selection_type = "view" //can be "range" or "view"

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/centcomm_cancast = TRUE //Whether or not the spell should be allowed on z2

	var/datum/action/spell_action/action = null
	var/action_icon = 'icons/hud/actions.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_spell"
	var/static/list/casting_clothes

/obj/effect/proc_holder/spell/Destroy()
	QDEL_NULL(action)
	return ..()

/obj/effect/proc_holder/spell/proc/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell

	if(((!user.mind) || !(src in user.mind.spell_list)) && !(src in user.spell_list))
		if(try_start)
			to_chat(user, "<span class='red'> You shouldn't have this spell! Something's wrong.</span>")
		return FALSE

	if(is_centcom_level(user.z) && !centcomm_cancast) //Certain spells are not allowed on the centcomm zlevel
		return FALSE

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				if(charge_counter < charge_max)
					if(try_start)
						to_chat(user, "[name] is still recharging.")
					return FALSE
			if("charges")
				if(!charge_counter)
					if(try_start)
						to_chat(user, "[name] has no charges left.")
					return FALSE

		if(favor_cost > 0 && user.mind.holy_role)
			if(user.my_religion.favor < favor_cost)
				if(try_start)
					to_chat(user, "<span class ='warning'>You need [favor_cost - user.my_religion.favor] more favors.</span>")
				return FALSE

	if(user.stat != CONSCIOUS && !stat_allowed)
		if(try_start)
			to_chat(user, "Not when you're incapacitated.")
		return FALSE

	if(plasma_cost && isxeno(user))
		var/mob/living/carbon/xenomorph/alien = user
		if(!alien.check_enough_plasma(plasma_cost))
			if(try_start)
				to_chat(user, "<span class='warning'>Not enough plasma stored.</span>")
			return FALSE

	if(ishuman(user) || ismonkey(user))
		if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
			if(try_start)
				user.say("Mmmf mrrfff!")
			return FALSE

	if(clothes_req) //clothes check
		if(!ishuman(user))
			if(try_start)
				to_chat(user, "You aren't a human, Why are you trying to cast a human spell, silly non-human? Casting human spells is for humans.")
			return FALSE
		var/mob/living/carbon/human/H = user
		if(!H.wear_suit?.GetComponent(/datum/component/magic_item/wizard))
			if(try_start)
				to_chat(user, "I don't feel strong enough without my robe.")
			return FALSE
		if(!H.shoes?.GetComponent(/datum/component/magic_item/wizard))
			if(try_start)
				to_chat(user, "I don't feel strong enough without my sandals.")
			return FALSE
		if(!H.head?.GetComponent(/datum/component/magic_item/wizard))
			if(try_start)
				to_chat(user, "I don't feel strong enough without my hat.")
			return FALSE

	if(try_start && !skipcharge)
		switch(charge_type)
			if("recharge")
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
			if("charges")
				charge_counter-- //returns the charge if the targets selecting fails
			if("holdervar")
				adjust_var(user, holder_var_type, holder_var_amount)

		if(favor_cost > 0 && user.mind.holy_role)
			user.my_religion.adjust_favor(-favor_cost)  //steals favor from spells per favor

	return TRUE

/obj/effect/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount

	switch(invocation_type)
		if("shout")
			if(prob(50))//Auto-mute? Fuck that noise
				user.say(invocation)
			else
				user.say(replacetext(invocation," ", "`"))
		if("whisper")
			if(prob(50))
				user.whisper(invocation)
			else
				user.whisper(replacetext(invocation," ", "`"))
	if(sound)
		playsound(user, sound, VOL_EFFECTS_MASTER)

/obj/effect/proc_holder/spell/atom_init()
	. = ..()
	charge_counter = charge_max
	if(!casting_clothes)
		casting_clothes = typecacheof(list(/obj/item/clothing/suit/wizrobe, /obj/item/clothing/suit/space/rig/wizard,
		/obj/item/clothing/head/wizard, /obj/item/clothing/head/helmet/space/rig/wizard))
	if(plasma_cost)
		name += " ([plasma_cost])"

/obj/effect/proc_holder/spell/Click()
	if(cast_check())
		choose_targets()
	return TRUE

/obj/effect/proc_holder/spell/proc/choose_targets(mob/user = usr) //depends on subtype - /targeted or /aoe_turf
	return

/obj/effect/proc_holder/spell/proc/start_recharge(mob/user = usr)
	var/atom/movable/screen/cooldown_overlay/cooldown = start_cooldown(action.button, charge_max)
	while(charge_counter < charge_max)
		sleep(1)
		charge_counter++
		if(cooldown)
			cooldown.tick()

	qdel(cooldown)

/obj/effect/proc_holder/spell/proc/perform(list/targets, recharge = 1, mob/user = usr) //if recharge is started is important for the trigger spells
	before_cast(targets, user)
	invocation(user)
	if(charge_type == "recharge" && recharge)
		INVOKE_ASYNC(src, .proc/start_recharge, user)
	cast(targets, user)
	after_cast(targets, user)

/obj/effect/proc_holder/spell/proc/before_cast(list/targets, mob/user = usr)
	if(overlay)
		for(var/atom/target in targets)
			var/location
			if(isliving(target))
				location = target.loc
			else if(isturf(target))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = TRUE
			spell.density = FALSE
			QDEL_IN(spell, overlay_lifespan)

/obj/effect/proc_holder/spell/proc/after_cast(list/targets, mob/user = usr)
	for(var/atom/target in targets)
		var/location
		if(isliving(target))
			location = target.loc
			if(message)
				to_chat(target, message)
		else if(isturf(target))
			location = target

		if(sparks_spread)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()

/obj/effect/proc_holder/spell/proc/cast(list/targets, mob/user = usr)
	return

/obj/effect/proc_holder/spell/proc/revert_cast(mob/user = usr) //resets recharge or readds a charge
	switch(charge_type)
		if("recharge")
			charge_counter = charge_max
		if("charges")
			charge_counter++
		if("holdervar")
			adjust_var(user, holder_var_type, -holder_var_amount)

	if(favor_cost > 0 && user.mind.holy_role)
		user.my_religion.adjust_favor(favor_cost)

/obj/effect/proc_holder/spell/proc/adjust_var(mob/living/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
	switch(type)
		if("bruteloss")
			target.adjustBruteLoss(amount)
		if("fireloss")
			target.adjustFireLoss(amount)
		if("toxloss")
			target.adjustToxLoss(amount)
		if("oxyloss")
			target.adjustOxyLoss(amount)
		if("stunned")
			target.AdjustStunned(amount)
		if("weakened")
			target.AdjustWeakened(amount)
		if("paralysis")
			target.AdjustParalysis(amount)
		else
			target.vars[type] += amount //I bear no responsibility for the runtimes that'll happen if you try to adjust non-numeric or even non-existant vars
	return

/obj/effect/proc_holder/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, 1 for one selectable target in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = TRUE //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/include_user = FALSE //if it includes usr in the target list

/obj/effect/proc_holder/spell/aoe_turf //affects all turfs in view or range (depends)
	var/inner_radius = -1 //for all your ring spell needs

/obj/effect/proc_holder/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(max_targets)
		if(0) //unlimited
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				targets += target

			if(!include_user && (user in targets))
				targets -= user
		if(1) //single target can be picked
			if(range < 0)
				targets += user // use spell/no_target instead
			else
				var/list/possible_targets = list()

				for(var/mob/living/M in view_or_range(range, user, selection_type))
					if(!include_user && user == M)
						continue
					var/image/I = image(M.icon, M.icon_state)
					I.appearance = M
					possible_targets[M] = I

				if(possible_targets.len == 1) //We have only one possible target
					targets += possible_targets[1]
				else //We have 2 and more targets
					var/radial_choose = show_radial_menu(user, user, possible_targets, tooltips = TRUE)
					if(radial_choose)
						targets += radial_choose
		else
			var/list/possible_targets = list()
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				possible_targets += target
			if(!include_user && (user in possible_targets))
				possible_targets -= user

			for(var/i in 1 to max_targets)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					targets += pick_n_take(possible_targets)
				else
					targets += pick(possible_targets)

	if(!targets.len) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets, user=user)

/obj/effect/proc_holder/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range, user, selection_type))
		if(!(target in view_or_range(inner_radius, user, selection_type)))
			targets += target

	if(!targets.len) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets, user=user)

/obj/effect/proc_holder/spell/no_target/choose_targets(mob/user = usr)
	perform(list(user), user=user)


/obj/effect/proc_holder/spell/proc/can_cast(mob/user = usr)
	return cast_check(FALSE, user, FALSE)
