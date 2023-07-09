/obj/item/projectile/disabler
	name = "bolt"
	desc = "A tiny crystal of death."
	icon_state = "projectile"
	icon = 'icons/mob/replicator.dmi'
	light_color = "#0000ff"
	damage = 2
	damage_type = BURN
	agony = 8
	step_delay = 2
	dispersion = 1
	impact_force = 1
	pass_flags = PASSTABLE | PASSGLASS
	// Okay, so yeah, this is bullshit. BUT:
	// Laserproof armor has siemens_coefficient of 0, which means it protects from mines
	// Thus it shouldn't also protect you from pew pew.
	flag = BULLET

/obj/item/projectile/disabler/on_hit(atom/target)
	..()
	spit_prismaline(src, target, 1.5)


/mob/living
	var/next_replicator_explosion = 0

/mob/living/simple_animal/hostile/replicator/proc/check_for_explosion(mob/living/L)
	if(L.stat == CONSCIOUS && !L.lying && !L.crawling)
		return

	if(L.next_replicator_explosion > world.time)
		return
	L.next_replicator_explosion = world.time + 3 SECONDS

	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, do_attack_animation), L, null, TRUE, "disintegrate", null)
	playsound(L, 'sound/weapons/crystal_explosion.ogg', VOL_EFFECTS_MASTER, vol=150)

/mob/living/simple_animal/hostile/replicator/UnarmedAttack(atom/A)
	if(isliving(A) && !isreplicator(A) && a_intent == INTENT_HARM)
		var/mob/living/L = A
		visible_message("<span class='warning'>[src] attacks [A]!</span>")

		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		var/additional_damage = FR.energy / 10000

		var/target_zone = get_targetzone()
		L.apply_damage(3.0 + disabler_damage_increase * 2.25, BRUTE, target_zone, 0.0, NONE)
		L.apply_effects(0, 0, 0, 0, 2, 1, 0, 10.0 + disabler_damage_increase * 7.5 + additional_damage * 0.3, 0)
		L.silent = max(L.silent, 2)

		if(L.stat == CONSCIOUS && !L.lying && !L.crawling)
			addtimer(CALLBACK(src, PROC_REF(check_for_explosion), A), 2 SECONDS)

		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, do_attack_animation), L)
		if(!attack_sound.len)
			playsound(L, 'sound/weapons/crystal_hit.ogg', VOL_EFFECTS_MASTER)
		else
			playsound(L, pick(attack_sound), VOL_EFFECTS_MASTER)

		SetNextMove(CLICK_CD_MELEE)
		L.set_lastattacker_info(src)
		L.log_combat(src, "replicator-attacked (INTENT: [uppertext(a_intent)]) (CONTROLLER: [last_controller_ckey])")
		scatter_offset()

		spit_prismaline(src, L, 1.0)

		last_melee_attack = world.time
		return

	if(a_intent == INTENT_GRAB)
		INVOKE_ASYNC(src, PROC_REF(disintegrate_turf), get_turf(A))
		return

	if(istype(A, /obj/structure/forcefield_node))
		if(locate(/obj/machinery/power/replicator_generator) in A.loc)
			return
		var/obj/effect/proc_holder/spell/no_target/replicator_construct/replicate/replicate_spell = locate() in src
		if(replicate_spell)
			replicate_spell.Click()
		return

	if(istype(A, /obj/structure/replicator_forcefield) && auto_construct_type == /obj/structure/bluespace_corridor)
		try_construct(get_turf(A))
		return

	if(istype(A, /turf))
		INVOKE_ASYNC(src, PROC_REF(disintegrate), A)
		return

	if(istype(A, /obj))
		INVOKE_ASYNC(src, PROC_REF(disintegrate), A)
		return

	if(isreplicator(A))
		var/mob/living/simple_animal/hostile/replicator/R = A
		if(R == src || R.stat == DEAD || !R.is_controlled())
			INVOKE_ASYNC(src, PROC_REF(disintegrate), A)
		return

	if(isliving(A))
		INVOKE_ASYNC(src, PROC_REF(disintegrate), A)
		return

/mob/living/simple_animal/hostile/replicator/RangedAttack(atom/A, params)
	// Adjacent() checks make this work in an unintuitive way otherwise.
	if(get_dist(src, A) <= 1 && a_intent == INTENT_GRAB)
		INVOKE_ASYNC(src, PROC_REF(disintegrate_turf), get_turf(A))
		return

	if(a_intent == INTENT_HARM && get_turf(A) && get_turf(src))
		SetNextMove(CLICK_CD_MELEE)

		if(!attack_sound.len)
			playsound(src, 'sound/weapons/guns/gunpulse_taser2.ogg', VOL_EFFECTS_MASTER)
		else
			playsound(src, pick(attack_sound), VOL_EFFECTS_MASTER)

		var/obj/item/projectile/disabler/D = new(loc)
		D.color = color

		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		var/additional_damage = FR.energy / 10000

		D.damage += disabler_damage_increase * 1.5 + additional_damage * 0.1
		D.agony += disabler_damage_increase * 6.0 + additional_damage * 0.3

		D.pixel_x += rand(-1, 1)
		D.pixel_y += rand(-1, 1)
		INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/item/projectile, Fire), A, src, params)
		scatter_offset()

		newtonian_move(get_dir(A, src))

/mob/living/simple_animal/hostile/replicator/CtrlClickOn(atom/A)
	if(!isreplicator(A))
		return
	if(stat == DEAD)
		return
	transfer_control(A)

/mob/living/simple_animal/hostile/replicator/attacked_by(obj/item/I, mob/living/user, def_zone, power)
	power /= armor["melee"]
	return ..()

/mob/living/simple_animal/hostile/replicator/do_attack_animation(atom/A, end_pixel_y, has_effect = TRUE, visual_effect_icon, visual_effect_color)
	if(!visual_effect_icon)
		visual_effect_icon = "disarm"
	if(!visual_effect_color)
		visual_effect_color = color
	return ..(A, end_pixel_y, has_effect, visual_effect_icon, visual_effect_color)

var/global/list/replicator_mines = list()
ADD_TO_GLOBAL_LIST(/obj/item/mine/replicator, replicator_mines)

/obj/item/mine/replicator/proc/pretend_disintegration()
	if(fake_disintegrating)
		return
	fake_disintegrating = TRUE
	var/amount = rand(1, 3)
	for (var/i in 1 to amount)
		playsound(src, 'sound/machines/cyclotron.ogg', VOL_EFFECTS_MASTER)
		sleep(rand(1, 3))
		if(QDELING(src))
			fake_disintegrating = FALSE
			return
		playsound(src, 'sound/mecha/UI_SCI-FI_Compute_01_Wet.ogg', VOL_EFFECTS_MASTER)
	fake_disintegrating = FALSE

/obj/item/mine/replicator
	name = "mine"
	desc = "A floating barely visible crystal of immense energy. You can imagine it hurts to step onto."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "trap"
	layer = 3
	anchored = TRUE

	max_integrity = 15
	resistance_flags = CAN_BE_HIT | FIRE_PROOF

	var/armed = TRUE

	var/being_disarmed = FALSE

	var/creator_ckey

	var/fake_disintegrating = FALSE

/obj/item/mine/replicator/deconstruct()
	try_trigger()
	qdel(src)

/obj/item/mine/replicator/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return
	to_chat(user, "<span class='notice'>At least if you are not elegant enough to dance around it's trappings.</span>")

/obj/item/mine/replicator/try_trigger(atom/movable/AM)
	if(isreplicator(AM))
		return
	if(istype(AM, /obj/item/projectile/disabler))
		return
	if(!anchored)
		return
	if(being_disarmed)
		return
	if(!armed)
		return

	if(!iscarbon(AM) && !issilicon(AM) && !istype(AM, /obj/mecha))
		return

	AM.visible_message("<span class='danger'>[AM] steps on [src]!</span>")
	trigger_act(AM)

/obj/item/mine/replicator/atom_init()
	. = ..()
	name = "mine ([rand(0, 999)])"

/obj/item/mine/replicator/proc/do_audiovisual_effects(atom/movable/AM)
	playsound(src, 'sound/misc/mining_reward_0.ogg', VOL_EFFECTS_MASTER)

	var/image/I = image('icons/mob/replicator.dmi', AM, "dismantle", MOB_ELECTROCUTION_LAYER + 0.1)

	flick_overlay_view(I, AM, 12)

	audible_message("<b>[src]</b> <i>buzzes.</i>", "You see a light flicker.", hearing_distance = 7, ignored_mobs = observer_list)

/obj/item/mine/replicator/trigger_act(atom/movable/AM)
	if(!armed)
		return
	armed = FALSE
	update_icon()

	addtimer(CALLBACK(src, PROC_REF(rearm)), 8 SECONDS)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()

	if(istype(AM, /obj/mecha))
		var/obj/mecha/M = AM

		do_audiovisual_effects(M)

		M.emp_act(1)

		M.take_damage(50, ENERGY)

		M.can_move = FALSE
		VARSET_IN(M, can_move, TRUE, 2 SECONDS)

		var/area/A = get_area(src)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		var/datum/replicator_array_info/RAI = FR.ckey2info[creator_ckey]
		if(RAI)
			RAI.mine_triggers += 1

		FR.object_communicate(src, "!", "Mine trigger event at [A.name].", transfer=TRUE)
		return

	if(isliving(AM))
		var/mob/living/L = AM

		do_audiovisual_effects(L)

		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		var/datum/replicator_array_info/RAI = FR.ckey2info[creator_ckey]
		if(RAI)
			RAI.mine_triggers += 1

		var/additional_damage = FR.energy / 10000

		var/stepped_by = pick(BP_R_LEG, BP_L_LEG)
		L.electrocute_act(15 + additional_damage * 0.5, src, siemens_coeff = 1.0, def_zone = stepped_by) // electrocute act does a message.
		L.Stun(2)

		L.silent = max(L.silent, 2)

		var/area/A = get_area(src)
		FR.object_communicate(src, "!", "Mine trigger event at [A.name].", transfer=TRUE)

/obj/item/mine/replicator/disarm()
	new /obj/item/weapon/stock_parts/capacitor/adv/super/quadratic(loc)
	qdel(src)

/obj/item/mine/replicator/try_disarm(obj/item/I, mob/user)
	if((I && !ispulsing(I)))
		return

	being_disarmed = TRUE
	update_icon()

	user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", "<span class='notice'>You start disarming [src].</span>")
	var/erase_time = length(global.alive_replicators) > 0 ? SKILL_TASK_DIFFICULT : SKILL_TASK_TRIVIAL
	if(I.use_tool(src, user, erase_time, volume = 50))
		user.visible_message("<span class='notice'>[user] finishes disarming [src].</span>", "<span class='notice'>You finish disarming [src].</span>")

		disarm()
		return

	being_disarmed = FALSE
	update_icon()

/obj/item/mine/replicator/proc/rearm()
	playsound(src, 'sound/effects/stealthoff.ogg', VOL_EFFECTS_MASTER, 75)
	armed = TRUE
	update_icon()

/obj/item/mine/replicator/update_icon()
	if(being_disarmed)
		icon_state = "traparmed"
		alpha = 255
		return

	if(armed)
		alpha = 45
		icon_state = "traparmed"
	else
		icon_state = "trap"
		alpha = 255

/obj/item/mine/replicator/Topic(href, href_list)
	if(href_list["replicator_jump"])
		var/mob/M = usr
		if(!isreplicator(M))
			return
		var/mob/living/simple_animal/hostile/replicator/R = M
		if(R.incapacitated())
			return
		if(!R.mind)
			return

		for(var/r in global.alive_replicators)
			var/mob/living/simple_animal/hostile/replicator/other = r
			if(other.is_controlled())
				continue
			if(get_dist(src, other) > 7)
				continue
			if(!R.transfer_control(other, alert=FALSE))
				continue

		to_chat(R, "<span class='notice'>Other presence is already attending this situation.</span>")
		return

	return ..()

/obj/item/mine/replicator/emp_act(severity)
	. = ..()
	armed = FALSE
	update_icon()

	addtimer(CALLBACK(src, PROC_REF(rearm)), (8 SECONDS / severity))
