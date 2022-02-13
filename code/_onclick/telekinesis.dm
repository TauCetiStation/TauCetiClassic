/mob/proc/get_tk_range()
	return TK_MAXRANGE

/mob/proc/get_tk_level()
	if(stat)
		return TK_LEVEL_ZERO

	if(get_species() == SKRELL)
		. = TK_LEVEL_SKRELL
	else
		. = TK_LEVEL_NORMAL

	if(druggy)
		. += TK_BONUS_DRUGGED

	var/datum/component/mood/mood = GetComponent(/datum/component/mood)
	if(mood && mood.mood_level <= 2)
		. += TK_BONUS_UPSET

/mob/proc/has_tk_power(amount)
	return FALSE

// Spend some resource proportionally to the amount.
/mob/proc/spend_tk_power(amount)
	return

/mob/proc/can_tk(mana=0, level=TK_LEVEL_NORMAL)
	if(!get_tk_level() >= level)
		to_chat(src, "<span class='warning'>Such an action would require vastly superior psychokinetic skills.</span>")
		return FALSE
	if(!has_tk_power(mana))
		to_chat(src, "<span class='warning'>Not enough mental resources for such an action.</span>")
		return FALSE
	return TRUE

/mob/proc/resolve_tk(mana=0, level=TK_LEVEL_NORMAL)
	spend_tk_power(mana)

/mob/proc/try_tk(mana=0, level=TK_LEVEL_NORMAL)
	if(!can_tk(mana, level))
		return FALSE
	resolve_tk(mana, level)
	return TRUE

/*
	Pre-Tycheon telekinetics.

	* Click something with GRAB intent to focus the item.
	* Click something with any other intent to do a "normal tk attack", which defaults to your UnarmedAttack *at a distance*.
	* Click focused item in hand to do a tk self attack, which defaults to item's attack_self for /obj/item.
	* Click focused item onto anything else to do a telekinetic click, which defaults to your normal attackby, afterattack shenanigans for /obj/item.
	* Clicking with throw mode on throws the focused item.
*/

/*
	Telekinetic attack:

	By default, emulate the user's unarmed attack
*/
/atom/proc/attack_tk(mob/living/user)
	user.UnarmedAttack(src)

/*
	Telekinetic grab:

	By default, focuses the item.
*/
/atom/proc/telekinetic_grab(mob/living/user)
	var/obj/item/tk_grab/O = new(src)
	O.focus_object(src)
	user.put_in_active_hand(O)

/*
	Telekinetic self attack:

	This is similar to item attack_self, but applies to anything
	that you can grab with a telekinetic grab.
*/
/atom/proc/attack_self_tk(mob/living/user)
	return

/obj/item/attack_self_tk(mob/living/user)
	attack_self(user)

/*
	Telekinetic click:

	This is basically attackby for /obj/item in telekinetic grab.
*/
/atom/movable/proc/afterattack_tk(mob/living/user, atom/target, params)
	return

/obj/item/afterattack_tk(mob/living/user, atom/target, params)
	// TG calls this a "melee attack chain"
	if(target.Adjacent(src))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(src, user, params)
		if(!resolved && target && src)
			afterattack(target, user, TRUE, params)

		return

	afterattack(target, user, FALSE, params)

/*
	TK Grab Item

	* If you have not grabbed something, do a normal tk attack
	* If you have something, throw it at the target.  If it is already adjacent, do a normal attackby()
	* If you click what you are holding, or attack_self(), do an attack_self_tk() on it.
	* Deletes itself if it is ever not in your hand, or if you should have no access to TK.
*/
/obj/item/tk_grab
	name = "Telekinetic Grab"
	desc = "Magic."
	icon = 'icons/obj/magic.dmi'//Needs sprites
	icon_state = "2"
	flags = NOBLUDGEON | ABSTRACT
	//item_state = null
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

	var/atom/movable/focus = null

/obj/item/tk_grab/Destroy()
	UnregisterSignal(focus, list(COMSIG_PARENT_QDELETING))
	focus = null
	return ..()

/obj/item/tk_grab/proc/on_focus_deletion(datum/source)
	qdel(src)

/obj/item/tk_grab/dropped(mob/user)
	. = ..()
	if(!QDELETED(src))
		qdel(src)

// Allows equipping stuff while being handcuffed.
/obj/item/tk_grab/equipped(mob/user, slot)
	..()
	if(!istype(focus, /obj/item))
		return

	if((slot == SLOT_L_HAND) || (slot == SLOT_R_HAND))
		return

	if(!focus.Adjacent(user))
		return

	qdel(src)
	user.equip_to_slot_if_possible(focus, slot, del_on_fail = FALSE)

/obj/item/tk_grab/attack_self(mob/user)
	focus.attack_self_tk(user)
	update_icon()

/obj/item/tk_grab/be_thrown(mob/living/user, atom/target)
	if(!(TK in user.mutations))
		qdel(src)
		return null

	var/distance = get_dist(focus, target)
	if(distance > user.get_tk_range())
		to_chat(user, "<span class='notice'>Your mind won't reach that far.</span>")
		return null

	user.SetNextMove(3)

	if(focus.anchored)
		return null
	if(!isturf(focus.loc))
		return null
	if(!user.try_tk(mana=TK_MANA_PER_W_CLASS(focus.w_class)))
		return null

	apply_focus_overlay()
	focus.throw_at(target, 10, 1, user)
	update_icon()

	return null

/obj/item/tk_grab/afterattack(atom/target, mob/living/user, proximity, params)
	if(!(TK in user.mutations))
		qdel(src)
		return

	var/distance = get_dist(focus, target)
	if(distance > user.get_tk_range())
		to_chat(user, "<span class='notice'>Your mind won't reach that far.</span>")
		return

	user.SetNextMove(3)

	if(target == focus)
		target.attack_self_tk(user)
		return

	apply_focus_overlay()
	focus.afterattack_tk(user, target, params)
	update_icon()

/obj/item/tk_grab/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/tk_grab/mob_can_equip(mob/M, slot, disable_warning = 0)
	return TRUE

/obj/item/tk_grab/proc/focus_object(obj/target, mob/living/user)
	focus = target
	RegisterSignal(focus, COMSIG_PARENT_QDELETING, .proc/on_focus_deletion)
	update_icon()
	apply_focus_overlay()

/obj/item/tk_grab/proc/apply_focus_overlay()
	var/obj/effect/overlay/O = new /obj/effect/overlay(get_turf(focus))
	O.name = "sparkles"
	O.anchored = TRUE
	O.density = FALSE
	O.layer = FLY_LAYER
	O.set_dir(pick(cardinal))
	O.icon = 'icons/effects/effects.dmi'
	O.icon_state = "nothing"
	flick("empdisable",O)
	QDEL_IN(O, 5)

/obj/item/tk_grab/update_icon()
	overlays.Cut()
	var/image/I = image(focus.icon, focus.icon_state)
	I.appearance = focus
	I.plane = plane
	I.layer = layer + 0.1
	overlays += I
