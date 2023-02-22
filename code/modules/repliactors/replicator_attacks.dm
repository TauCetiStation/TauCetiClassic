/obj/item/projectile/disabler
	name = "bolt"
	icon_state = "bluelaser"
	light_color = "#0000ff"
	//light_power = 2
	//light_range = 2
	damage = 3
	damage_type = BURN
	agony = 20
	step_delay = 2


/mob/living/simple_animal/replicator/UnarmedAttack(atom/A)
	if(isliving(A) && !isreplicator(A) && a_intent == INTENT_HARM)
		var/mob/living/L = A
		do_attack_animation(L)
		visible_message("<span class='warning'>[src] attacks [A]!</span>")
		playsound(L, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER)
		L.apply_effects(0, 0, 0, 0, 1, 1, 0, 30, 0)
		SetNextMove(CLICK_CD_MELEE)
		L.set_lastattacker_info(src)
		L.log_combat(src, "replicator-attacked (INTENT: [uppertext(a_intent)])")
		return

	if(a_intent == INTENT_GRAB)
		INVOKE_ASYNC(src, .proc/disintegrate_turf, get_turf(A))
		return

	if(istype(A, /obj/structure/replicator_forcefield) && auto_construct_type == /obj/structure/bluespace_corridor)
		try_construct(get_turf(A))
		return

	if(istype(A, /turf))
		INVOKE_ASYNC(src, .proc/disintegrate, A)
		return

	if(istype(A, /obj))
		INVOKE_ASYNC(src, .proc/disintegrate, A)
		return

	if(istype(A, /mob/living/simple_animal/replicator))
		var/mob/living/simple_animal/replicator/R = A
		if(R.stat == DEAD)
			INVOKE_ASYNC(src, .proc/disintegrate, R)
		// repair
		return

/mob/living/simple_animal/replicator/RangedAttack(atom/A, params)
	// Adjacent() checks make this work in an unintuitive way otherwise.
	if(get_dist(src, A) <= 1 && a_intent == INTENT_GRAB)
		INVOKE_ASYNC(src, .proc/disintegrate_turf, get_turf(A))
		return

	if(a_intent == INTENT_HARM)
		SetNextMove(CLICK_CD_MELEE)
		playsound(src, 'sound/weapons/guns/gunpulse_taser2.ogg', VOL_EFFECTS_MASTER)
		var/obj/item/projectile/disabler/D = new(loc)
		D.Fire(A, src, params)

/mob/living/simple_animal/replicator/CtrlClickOn(atom/A)
	if(istype(A, /mob/living/simple_animal/replicator))
		var/mob/living/simple_animal/replicator/S = A
		if(!S.ckey)
			transfer_control(A)
			return
