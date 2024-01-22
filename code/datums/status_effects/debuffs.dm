//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS

/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_canmove()
			if(needs_update_stat || issilicon(owner))
				owner.update_stat()

/datum/status_effect/incapacitating/on_remove()
	owner.update_canmove()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()

//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"

/datum/status_effect/incapacitating/stun/on_apply()
	. = ..()
	if(!.)
		return
	owner.stunned = TRUE
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, id)
	owner.drop_from_inventory(owner.l_hand)
	owner.drop_from_inventory(owner.r_hand)

/datum/status_effect/incapacitating/stun/on_remove()
	owner.stunned = FALSE
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, id)
	return ..()

//PARALYZED
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

/datum/status_effect/incapacitating/paralyzed/on_apply()
	. = ..()
	if(!.)
		return
	owner.paralysis = TRUE
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, id)

/datum/status_effect/incapacitating/paralyzed/on_remove()
	owner.paralysis = FALSE
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, id)
	return ..()

//WEAKENED
/datum/status_effect/incapacitating/weakened
	id = "weakened"

/datum/status_effect/incapacitating/weakened/on_apply()
	. = ..()
	if(!.)
		return
	owner.weakened = TRUE
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, id)
	owner.drop_from_inventory(owner.l_hand)
	owner.drop_from_inventory(owner.r_hand)

/datum/status_effect/incapacitating/weakened/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, id)
	owner.weakened = FALSE
	return ..()

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /atom/movable/screen/alert/status_effect/asleep
	needs_update_stat = TRUE
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	. = ..()
	if(.)
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner
		ADD_TRAIT(owner, TRAIT_IMMOBILIZED, id)

/datum/status_effect/incapacitating/sleeping/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	return ..()

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(human_owner && !human_owner.client)
		duration = max(duration, world.time + 1 SECOND)

	owner.adjustHalLoss(-0.5) //reduce stamina loss by 0.5 per tick, 10 per 2 seconds

	if(human_owner)
		human_owner.drowsyness = max(0, human_owner.drowsyness * 0.997)
		human_owner.slurring = max(0, human_owner.slurring * 0.997)
		human_owner.SetConfused(human_owner.confused * 0.997)
		human_owner.SetDrunkenness(human_owner.drunkenness * 0.997)

	if(prob(50))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health)
			if(!carbon_owner || !carbon_owner.hal_crit)
				owner.emote("snore")
	owner.drop_from_inventory(owner.l_hand)
	owner.drop_from_inventory(owner.r_hand)

/atom/movable/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

//STASIS
/datum/status_effect/incapacitating/stasis_bag // don't mistake with TG's stasis.
	id = "stasis_bag"
	duration = -1
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/stasis_bag
	var/last_dead_time

/datum/status_effect/incapacitating/stasis_bag/proc/update_time_of_death()
	if(last_dead_time)
		var/delta = world.time - last_dead_time
		var/new_timeofdeath = owner.timeofdeath + delta
		owner.timeofdeath = new_timeofdeath
		owner.tod = worldtime2text()
		last_dead_time = null
	if(owner.stat == DEAD)
		last_dead_time = world.time

/datum/status_effect/incapacitating/stasis_bag/proc/handle_stasis_bag()
	// First off, there's no oxygen supply, so the mob will slowly take brain damage
	owner.adjustBrainLoss(0.1)

	// Next, the method to induce stasis has some adverse side-effects, manifesting
	// as cloneloss
	owner.adjustCloneLoss(0.1)

/datum/status_effect/incapacitating/stasis_bag/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	. = ..()
	update_time_of_death()

/datum/status_effect/incapacitating/stasis_bag/tick()
	update_time_of_death()
	handle_stasis_bag()

/datum/status_effect/incapacitating/stasis_bag/on_remove()
	update_time_of_death()
	return ..()

/datum/status_effect/incapacitating/stasis_bag/be_replaced()
	update_time_of_death()
	return ..()

/atom/movable/screen/alert/status_effect/stasis_bag
	name = "Stasis Bag"
	desc = "Your biological functions have halted. You could live forever this way, but it's pretty boring."
	icon_state = "stasis"

/datum/status_effect/remove_trait
	id = "remove_traits"
	tick_interval = 10
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	var/trait
	var/trait_source

/datum/status_effect/remove_trait/on_creation(mob/living/new_owner, time_amount)
	duration = time_amount
	. = ..()
	REMOVE_TRAIT(owner, trait, trait_source)

/datum/status_effect/remove_trait/on_remove()
	ADD_TRAIT(owner, trait, trait_source)
	. = ..()

/datum/status_effect/remove_trait/wet_hands
	trait = TRAIT_WET_HANDS
	trait_source = QUALITY_TRAIT

/datum/status_effect/remove_trait/greasy_hands
	trait = TRAIT_GREASY_FINGERS
	trait_source = QUALITY_TRAIT

//Roundstart help for xeno
/datum/status_effect/young_queen_buff
	id = "queen_help"
	duration = 7 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/young_queen_buff
	examine_text = "Looks quite young"

/datum/status_effect/young_queen_buff/on_apply()
	. = ..()
	if(!isxeno(owner))
		return
	var/mob/living/carbon/xenomorph/Q = owner
	Q.maxHealth = Q.maxHealth * 2
	Q.health = Q.health * 2
	Q.heal_rate = Q.heal_rate * 2.5
	Q.plasma_rate = Q.plasma_rate * 1.5
	to_chat(Q, "<span class='alien large'>Пока ваш улей слаб, вам будет помогать Императрица. Некоторое время...</span>")

/datum/status_effect/young_queen_buff/on_remove()
	if(!isxeno(owner))
		return
	var/mob/living/carbon/xenomorph/Q = owner
	Q.bruteloss = Q.bruteloss / 2
	Q.fireloss = Q.fireloss / 2
	Q.maxHealth = Q.maxHealth / 2
	Q.update_health_hud()
	Q.heal_rate = Q.heal_rate / 2.5
	Q.plasma_rate = Q.plasma_rate / 1.5
	to_chat(Q, "<span class='alien large'>Императрица перестала активно поддерживать улей. Улей теперь должен заботиться о себе сам.</span>")

/atom/movable/screen/alert/status_effect/young_queen_buff
	name = "Помощь Императрицы"
	desc = "Некоторое время вы гораздо быстрее залечиваете свои раны, более живучи и у вас куда больше плазмы."
	icon_state = "alien_help"
	alerttooltipstyle = "alien"

/datum/status_effect/clumsy
	id = "clumsy"
	alert_type = /atom/movable/screen/alert/status_effect/clumsy
	status_type = STATUS_EFFECT_REFRESH
	var/applied_times = 1

/datum/status_effect/clumsy/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/clumsy/on_apply()
	. = ..()
	if(!iscarbon(owner))
		return FALSE
	if(HAS_TRAIT_FROM(owner, TRAIT_CLUMSY_IMMUNE, STATUS_EFFECT_TRAIT))
		if(prob(75))
			return FALSE
		REMOVE_TRAIT(owner, TRAIT_CLUMSY_IMMUNE, STATUS_EFFECT_TRAIT)
	ADD_TRAIT(owner, TRAIT_CLUMSY, STATUS_EFFECT_TRAIT)
	to_chat(owner, "<span class='warning'>You feel lightheaded</span>")

/datum/status_effect/clumsy/on_remove()
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, STATUS_EFFECT_TRAIT)
	ADD_TRAIT(owner, TRAIT_CLUMSY_IMMUNE, STATUS_EFFECT_TRAIT)

/atom/movable/screen/alert/status_effect/clumsy
	name = "Неуклюжесть"
	desc = "Вы чувствуете головокружение."
	icon_state = "woozy"

/// Hallucination status effect. How most hallucinations end up happening.
/datum/status_effect/hallucination
	id = "hallucination"
	alert_type = null
	tick_interval = 2 SECONDS
	/// Biotypes which cannot hallucinate.
	var/list/barred_biotypes = list()
	/// The lower range of when the next hallucination will trigger after one occurs.
	var/lower_tick_interval = 10 SECONDS
	/// The upper range of when the next hallucination will trigger after one occurs.
	var/upper_tick_interval = 60 SECONDS
	/// The cooldown for when the next hallucination can occur
	COOLDOWN_DECLARE(hallucination_cooldown)

/datum/status_effect/hallucination/on_creation(mob/living/new_owner, duration)
	if(isnum(duration))
		src.duration = duration
	return ..()

/datum/status_effect/hallucination/on_apply()
	if(owner.get_species() in barred_biotypes)
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_HEALTHSCAN,  PROC_REF(on_health_scan))
	if(iscarbon(owner))
		RegisterSignal(owner, COMSIG_CARBON_BUMPED_AIRLOCK_OPEN, PROC_REF(on_bump_airlock))

	return TRUE

/datum/status_effect/hallucination/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_LIVING_HEALTHSCAN,
		COMSIG_CARBON_BUMPED_AIRLOCK_OPEN,
	))

/// Signal proc for [COMSIG_LIVING_HEALTHSCAN]. Show we're hallucinating to (advanced) scanners.
/datum/status_effect/hallucination/proc/on_health_scan(datum/source, list/reflist)
	SIGNAL_HANDLER
	if(!reflist[2])
		return
	reflist[1] += "<span class='warning'>Subject is hallucinating.</span><br>"

/// Signal proc for [COMSIG_CARBON_BUMPED_AIRLOCK_OPEN], bumping an airlock can cause a fake zap.
/// This only happens on airlock bump, future TODO - make this chance roll for attack_hand opening airlocks too
/datum/status_effect/hallucination/proc/on_bump_airlock(mob/living/carbon/source, obj/machinery/door/airlock/bumped)
	SIGNAL_HANDLER

	// 1% chance to fake a shock.
	if(prob(99) || bumped.operating)
		return

	source.cause_hallucination(/datum/hallucination/shock, "hallucinated shock from [bumped]",)
	return STOP_BUMP

/datum/status_effect/hallucination/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, hallucination_cooldown))
		return

	COOLDOWN_START(src, hallucination_cooldown, rand(lower_tick_interval, upper_tick_interval))

/// Causes a fake "zap" to the hallucinator.
/datum/hallucination/shock
	var/electrocution_icon = 'icons/mob/human.dmi'
	var/electrocution_icon_state = "electrocuted_base"
	var/image/shock_image
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/New(mob/living/hallucinator)
	var/electrocuted_sprite = "electrocuted_generic"
	switch(hallucinator.get_species())
		if(UNATHI)
			electrocuted_sprite += "_unathi"
		if(TAJARAN)
			electrocuted_sprite += "_tajaran"
		if(SKRELL)
			electrocuted_sprite += "_skrell"
		if(VOX)
			electrocuted_sprite += "_vox"
	electrocution_icon_state = electrocuted_sprite
	return ..()

/datum/hallucination/shock/Destroy()
	if(shock_image)
		hallucinator.client?.images -= shock_image
		shock_image = null
	if(electrocution_skeleton_anim)
		hallucinator.client?.images -= electrocution_skeleton_anim
		electrocution_skeleton_anim = null

	return ..()

/datum/hallucination/shock/start()
	shock_image = image(hallucinator, hallucinator, dir = hallucinator.dir)
	shock_image.appearance_flags |= KEEP_APART
	shock_image.color = rgb(0, 0, 0)
	shock_image.override = TRUE

	electrocution_skeleton_anim = image(electrocution_icon, hallucinator, icon_state = electrocution_icon_state, layer = MOB_ELECTROCUTION_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART

	to_chat(hallucinator, "<span class='danger'>You feel a powerful shock course through your body!</span>")
	hallucinator.visible_message("<span class='warning'>[hallucinator] falls to the ground, shaking!</span>", ignored_mobs = hallucinator)
	hallucinator.client?.images |= shock_image
	hallucinator.client?.images |= electrocution_skeleton_anim

	hallucinator.playsound_local(null, 'sound/effects/electric_shock.ogg', VOL_EFFECTS_MASTER)
	hallucinator.adjustHalLoss(50)
	hallucinator.Stun(8)
	hallucinator.make_jittery(300) // Maximum jitter

	addtimer(CALLBACK(src, PROC_REF(reset_shock_animation)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shock_drop)), 2 SECONDS)
	QDEL_IN(src, 4 SECONDS)
	return TRUE

/datum/hallucination/shock/proc/reset_shock_animation()
	if(QDELETED(hallucinator))
		return

	hallucinator.client?.images -= shock_image
	shock_image = null

	hallucinator.client?.images -= electrocution_skeleton_anim
	electrocution_skeleton_anim = null

/datum/hallucination/shock/proc/shock_drop()
	if(QDELETED(hallucinator))
		return
	hallucinator.cause_hallucination(/datum/hallucination/fake_health_doll, "hallucinated shock from", specific_bodypart = list(BP_L_ARM, BP_R_ARM), random_pick_specific_part = TRUE)
	hallucinator.Weaken(8)

///Causes the target to see incorrect health damages on the healthdoll
/datum/hallucination/fake_health_doll
	/// The duration of the hallucination
	var/duration
	/// Assoc list of [ref to bodyparts] to [severity]
	var/list/bodyparts = list()
	/// Timer ID for when we're deleted
	var/del_timer_id

	var/list/specific_bodyparts_string = list()
	var/pick_random_specific = TRUE

/datum/hallucination/fake_health_doll/New(mob/living/hallucinator, duration = 50 SECONDS, list/specific_bodypart, random_pick_specific_part)
	src.duration = duration
	specific_bodyparts_string += specific_bodypart
	pick_random_specific = random_pick_specific_part
	return ..()

// So that the associated addition proc cleans it up correctly
/datum/hallucination/fake_health_doll/Destroy()
	if(del_timer_id)
		deltimer(del_timer_id)

	for(var/obj/item/organ/external/limb as anything in bodyparts)
		remove_bodypart(limb)

	hallucinator.update_health_hud()
	return ..()

/datum/hallucination/fake_health_doll/start()
	if(!ishuman(hallucinator))
		return FALSE
	var/mob/living/carbon/human/H = hallucinator
	if(!specific_bodyparts_string.len)
		add_fake_limb()
	else
		if(!pick_random_specific)
			for(var/i in specific_bodyparts_string)
				var/obj/item/organ/external/specific_limb = H.get_bodypart(i)
				add_fake_limb(specific_limb)
		else
			var/obj/item/organ/external/specific_limb = H.get_bodypart(pick(specific_bodyparts_string))
			add_fake_limb(specific_limb)
	del_timer_id = QDEL_IN(src, duration)
	return TRUE

/**
 * Adds a fake limb to the effect.
 *
 * specific_limb - optional, the specific limb to apply the effect to. If not passed, picks a random limb
 * seveirty - optional, the specific severity level to apply the effect. Clamped from 1 to 5. If not passed, picks a random number.
 */
/datum/hallucination/fake_health_doll/proc/add_fake_limb(obj/item/organ/external/specific_limb, severity)
	var/mob/living/carbon/human/human_mob = hallucinator

	var/obj/item/organ/external/picked = specific_limb || pick(human_mob.bodyparts)
	if(!(picked in bodyparts))
		RegisterSignal(picked, list(COMSIG_PARENT_QDELETING), PROC_REF(remove_bodypart))
		RegisterSignal(picked, COMSIG_BODYPART_UPDATING_HEALTH_HUD, PROC_REF(on_bodypart_hud_update))

	hallucinator.update_health_hud()

/// Remove a bodypart from our list, unregistering all associated signals and handling the reference
/datum/hallucination/fake_health_doll/proc/remove_bodypart(obj/item/organ/external/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_BODYPART_UPDATING_HEALTH_HUD))
	bodyparts -= source

/// Whenever a bodypart we're tracking has their health hud updated, override it with our fake overlay
/datum/hallucination/fake_health_doll/proc/on_bodypart_hud_update(obj/item/organ/external/source, mob/living/carbon/human/owner)
	SIGNAL_HANDLER

	var/mutable_appearance/fake_overlay = mutable_appearance('icons/hud/screen_gen.dmi', "[source.body_zone][5]") //bodyparts[source]
	owner.healthdoll.add_overlay(fake_overlay)
	return COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD
