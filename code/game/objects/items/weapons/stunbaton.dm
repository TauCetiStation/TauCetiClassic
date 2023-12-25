/obj/item/weapon/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	slot_flags = SLOT_FLAGS_BELT
	force = 10
	throwforce = 7
	w_class = SIZE_SMALL
	var/charges = 10
	var/status = 0
	var/mob/foundmob = "" //Used in throwing proc.
	var/agony = 60
	var/discharge_rate_per_minute = 2 //stunbaton loses it charges if not powered off
	sweep_step = 2

	origin_tech = "combat=2"

/obj/item/weapon/melee/baton/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/melee/baton/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</b></span>")
	return (FIRELOSS)

/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/weapon/melee/baton/attack_self(mob/living/user)
	. = ..()
	if(status && user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='warning'>You grab the [src] on the wrong side.</span>")
		user.apply_effect(agony * 2, AGONY, 0)
		discharge()
		return
	if(!handle_fumbling(user, src, SKILL_TASK_VERY_EASY, list(/datum/skill/police = SKILL_LEVEL_TRAINED), "<span class='notice'>You fumble around figuring out how to toggle [status ? "on" : "off"] [src]...</span>", can_move = TRUE))
		return
	if(charges > 0)
		set_status(user.a_intent, !status)
		to_chat(user, "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>")
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		update_icon()
	else
		set_status(user.a_intent, 0)
		to_chat(user, "<span class='warning'>\The [src] is out of charge.</span>")
	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/living/M, mob/living/user, def_zone)
	if(!status && user.a_intent != INTENT_HARM)
		user.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return
	if(user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='danger'>You accidentally hit yourself with the [src]!</span>")
		user.apply_effect(agony * 2, AGONY, 0)
		discharge()
		return
	. = ..()
	//legacy. Mob can be deleted after the attack, so we gotta be wary of that.
	if(QDELETED(M))
		return
	if(!.)
		return
	if(!status)
		playsound(src, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)
		return
	// Make hit harm-sound for enabled baton
	if(user.a_intent == INTENT_HARM)
		playsound(src, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)
	//Help for administration
	M.log_combat(user, "stunned (attempt) with [name]")
	if(charges < 0)
		return
	//cant stun anyone without charge in cell
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(50))
			return
	M.apply_effect(agony, AGONY, 0)
	discharge()
	playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/melee/baton/proc/attempt_change_work(datum/source, intent)
	SIGNAL_HANDLER
	set_status(intent, status)

/obj/item/weapon/melee/baton/proc/set_status(intent, value)
	if(intent == INTENT_HARM)
		force = initial(force)
	else
		force = 0
	if(value)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	status = value

/obj/item/weapon/melee/baton/equipped(mob/living/user, slot)
	. = ..()
	if(!istype(user))
		return
	if(slot == SLOT_L_HAND || slot == SLOT_R_HAND)
		set_status(user.a_intent, status)
		RegisterSignal(user, COMSIG_LIVING_INTENT_CHANGE, PROC_REF(attempt_change_work), override = TRUE)
	else
		UnregisterSignal(user, COMSIG_LIVING_INTENT_CHANGE)

/obj/item/weapon/melee/baton/dropped(mob/living/user)
	if(istype(user))
		UnregisterSignal(user, COMSIG_LIVING_INTENT_CHANGE)
	return ..()

/obj/item/weapon/melee/baton/proc/discharge(amount = 1)
	charges = max(0, charges - amount)
	if(charges <= 0)
		charges = 0
		set_status(INTENT_HARM, 0)
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		update_icon()

/obj/item/weapon/melee/baton/process()
	discharge(2 * discharge_rate_per_minute / 60)

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	if (prob(50))
		if(isliving(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(status)
				H.apply_effect(agony,AGONY,0)
				discharge()
				for(var/mob/M in player_list) if(M.key == src.fingerprintslast)
					foundmob = M
					break

				H.visible_message("<span class='danger'>[src], thrown by [foundmob.name], strikes [H]!</span>")

				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Hit by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
				msg_admin_attack("Flying [src.name], last touched by ([src.fingerprintslast]) hit [key_name(H)]", H)

/obj/item/weapon/melee/baton/emp_act(severity)
	discharge(severity * 5)

/obj/item/weapon/melee/baton/double
	name = "dualbaton"
	desc = "Some shadow genius in Nanotrasen Combat Research Division decided this was a good idea."
	icon_state = "doublebaton"
	item_state = "doublebaton"
	slot_flags = SLOT_FLAGS_BACK
	throwforce = 10
	w_class = SIZE_NORMAL
	charges = 20
	sweep_step = 2

	origin_tech = "combat=3"

/obj/item/weapon/melee/baton/double/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list()

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/baton/double, can_swipe))
	SCB.can_spin_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/baton/double, can_swipe))
	SCB.on_get_sweep_objects = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/baton/double, get_sweep_objs))
	AddComponent(/datum/component/swiping, SCB)

	var/datum/twohanded_component_builder/TCB = new
	TCB.force_wielded = 15
	TCB.force_unwielded = 10
	AddComponent(/datum/component/twohanded, TCB)

/obj/item/weapon/melee/baton/double/proc/can_swipe(mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

/obj/item/weapon/melee/baton/double/proc/get_sweep_objs(turf/start, obj/item/I, mob/user, list/directions, sweep_delay)
	var/list/directions_opposite = list()
	for(var/dir_ in directions)
		directions_opposite += turn(dir_, 180)

	var/list/sweep_objects = list()
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions, sweep_delay)
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions_opposite, sweep_delay)
	return sweep_objects

/obj/item/weapon/melee/baton/double/dropped(mob/user)
	..()
	status = FALSE
	update_icon()
