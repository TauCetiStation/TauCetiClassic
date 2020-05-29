/obj/effect/effect/forcefield
	name = "forcefield"

	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"

	layer = INFRONT_MOB_LAYER

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	density = FALSE
	anchored = TRUE

/obj/effect/effect/forcefield/rune
	name = "blood aura"

	icon = 'icons/obj/rune.dmi'
	icon_state = "1"

/obj/effect/effect/forcefield/rune/atom_init()
	. = ..()
	icon_state = "[rand(1, 6)]"

/*
 * A forcefield component.
 *
 * Provides protection for max_health amount of damage. If damage is higher than the health of shield - shield will absorb all it can,
 * get destroyed, but not pass excess damage.
 * After destroying shield waits for reactivate_time before beggining to rechage.
 * Shields require recharge_time amount of ticks to get fully charged from 0 health to max_health.
 *
 * Currently only /mob-s utilize the check_shields() mechanic, but forcefields can be applied to any /atom.
 */
/datum/component/forcefield
	/// The name of the shield.
	var/name

	/// Current amount of health of this forcefield.
	var/health = 0
	/// Maximal amount of damage that can be absorbed by this forcefield.
	var/max_health = 0

	/// Time it takes for a shield to be back up after complete destruction.
	var/reactivation_time = 0
	// Time it takes for a shield to be recharged from 0 to maxHealth health.
	var/recharge_time = 0

	/// Whether the user can interact with anything outside of the shield.
	var/permit_interaction = FALSE

	/// Whether shield only appears on hit.
	var/appear_on_hit = FALSE

	/// An overlay of the shield.
	var/atom/shield_overlay
	var/matrix/default_transform
	var/def_pixel_x = 0
	var/def_pixel_y = 0
	var/chat_shield = ""

	// These are private.
	/// Whether the shield is currently up.
	var/active = FALSE
	/// How much charge should be incremented by each process tick.
	var/charge_per_tick = 0
	/// Who is protected by this shield.
	var/list/atom/protected
	/// A cooldown for on_hit_anim.
	var/next_hit_anim = 0

	var/static/reactivate_sound = 'sound/effects/forcefield_reactivate.ogg'
	var/static/destroy_sound = 'sound/effects/forcefield_destroy.ogg'
	var/static/hit_sounds = list('sound/effects/forcefield_hit1.ogg', 'sound/effects/forcefield_hit2.ogg')

/datum/component/forcefield/Initialize(name, max_health, reactivation_time, recharge_time, atom/shield_overlay, appear_on_hit = FALSE, permit_interaction = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.name = name

	src.max_health = max_health
	health = max_health

	src.reactivation_time = reactivation_time
	src.recharge_time = recharge_time

	src.appear_on_hit = appear_on_hit

	src.permit_interaction = permit_interaction

	if(shield_overlay)
		src.shield_overlay = shield_overlay
		default_transform = shield_overlay.transform
		def_pixel_x = shield_overlay.pixel_x
		def_pixel_y = shield_overlay.pixel_y
		chat_shield = "[bicon(shield_overlay)] "

	charge_per_tick = max_health / recharge_time

	if(istype(parent, /obj/item))
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/toggle)

	RegisterSignal(parent, list(COMSIG_FORCEFIELD_PROTECT), .proc/start_protecting)
	RegisterSignal(parent, list(COMSIG_FORCEFIELD_UNPROTECT), .proc/stop_protecting)

	shield_up()

/datum/component/forcefield/Destroy()
	shield_down()
	QDEL_NULL(shield_overlay)

	for(var/atom/A in protected)
		stop_protecting(A)

	protected = null
	return ..()

/*
 * Charge the shield up. Is not used a lot, called each 2 processor ticks.
 */
/datum/component/forcefield/process()
	add_charge(charge_per_tick)

/// Reactivate the shield.
/datum/component/forcefield/proc/reactivate()
	if(istype(parent, /obj/item))
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/toggle)

	playsound(parent, reactivate_sound, VOL_EFFECTS_MASTER)
	shield_up()

/datum/component/forcefield/proc/destroy()
	if(istype(parent, /obj/item))
		UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/toggle)

	playsound(parent, destroy_sound, VOL_EFFECTS_MASTER)
	shield_down()
	addtimer(CALLBACK(src, .proc/reactivate), reactivation_time)

/// Adjust all the visuals to damage.
/datum/component/forcefield/proc/update_visuals()
	if(shield_overlay)
		shield_overlay.alpha = health * 200 / max_health

/// Add charge, stopping the recharge on max_health logic included.
/datum/component/forcefield/proc/add_charge(amount)
	health += amount
	update_visuals()
	if(health >= max_health)
		health = max_health
		STOP_PROCESSING(SSfastprocess, src)

/// React to damage, destroying on health = 0 logic included. Return TRUE if an attack is blocked.
/datum/component/forcefield/proc/react_to_damage(atom/victim, damage, attack_text)
	health -= damage
	update_visuals()
	if(health <= 0)
		victim.visible_message("[chat_shield]<span class='warning'>[capitalize(name)] blocks [attack_text], and is destroyed!</span>")
		health = 0
		destroy()
	else
		victim.visible_message("[chat_shield]<span class='notice'>[capitalize(name)] blocks [attack_text].</span>")
		START_PROCESSING(SSfastprocess, src)
	return TRUE

/// Call this proc to pull the shield up, prohibiting clicking.
/datum/component/forcefield/proc/shield_up()
	active = TRUE
	if(!appear_on_hit)
		show_shield_all()

	if(!permit_interaction)
		for(var/prot_atom in protected)
			if(ismob(prot_atom))
				RegisterSignal(prot_atom, list(COMSIG_MOB_CLICK), .proc/internal_click)

	for(var/prot_atom in protected)
		if(isliving(prot_atom))
			var/mob/living/L = prot_atom
			// It's outside of the shield.
			if(L.pulling)
				L.visible_message("<span class='warning bold'>[name] has broken [protected]'s grip on [L.pulling]!</span>")
				L.stop_pulling()

			for(var/obj/item/weapon/grab/G in L.GetGrabs())
				if(G.affecting)
					L.visible_message("<span class='warning bold'>[name] has broken [L]'s grip on [G.affecting]!</span>")
				qdel(G)

		RegisterSignal(prot_atom, list(COMSIG_LIVING_CHECK_SHIELDS), .proc/on_hit)

	START_PROCESSING(SSfastprocess, src)

/// Call this proc to put the shield down, allowing clicking.
/datum/component/forcefield/proc/shield_down()
	active = FALSE
	if(!appear_on_hit)
		hide_shield_all()

	if(!permit_interaction)
		for(var/prot_atom in protected)
			if(ismob(prot_atom))
				UnregisterSignal(prot_atom, list(COMSIG_MOB_CLICK))

	for(var/prot_atom in protected)
		UnregisterSignal(prot_atom, list(COMSIG_LIVING_CHECK_SHIELDS))
	STOP_PROCESSING(SSfastprocess, src)

/// Deforms deform in some ways. (not) Used in on_hit animations.
/datum/component/forcefield/proc/deformation_effects(deformation_factor, atom/deform)
	/*
	deform.pixel_x += rand(-deformation_factor * 10, deformation_factor * 10) * 0.1
	deform.pixel_y += rand(-deformation_factor * 10, deformation_factor * 10) * 0.1
	*/
	return

/// Revert all the deformation effects after a hit.
/datum/component/forcefield/proc/revert_deformation(deformation_factor)
	sleep(deformation_factor * 2)
	animate(shield_overlay, transform = default_transform,
		pixel_x = def_pixel_x, pixel_y = def_pixel_y, time = 2)

/// All the logic that occurs when shield is hit.
/datum/component/forcefield/proc/on_hit(datum/source, atom/attacker, damage, attack_text, hit_dir)
	if(attacker == parent && permit_interaction)
		return NONE

	if(appear_on_hit)
		on_hit_anim(source, damage)
	else if(next_hit_anim <= world.time)
		var/deformation_factor = TRANSLATE_RANGE(damage, 0.0, max_health, 1.0, 10.0)

		deformation_effects(deformation_factor, shield_overlay)

		INVOKE_ASYNC(src, .proc/revert_deformation, deformation_factor)

		next_hit_anim = deformation_factor * 2 + 2

	playsound(source, pick(hit_sounds), VOL_EFFECTS_MASTER)

	if(react_to_damage(source, damage, attack_text))
		return COMPONENT_ATTACK_SHIELDED
	return NONE

/datum/component/forcefield/proc/toggle()
	// Can't toggle what's broken.
	if(health == 0)
		return

	if(active)
		shield_down()
	else
		shield_up()

/// Is called if src is appear_on_hit. Handles the appear-dissapear animation for the shield.
/datum/component/forcefield/proc/on_hit_anim(atom/victim, damage)
	if(!shield_overlay)
		return
	if(next_hit_anim > world.time)
		return
	next_hit_anim = world.time + 2 SECONDS

	var/deformation_factor = TRANSLATE_RANGE(damage, 0.0, max_health, 1.0, 6.0)

	update_visuals()
	var/image/I = image(shield_overlay.icon, shield_overlay.icon_state)
	I.appearance = shield_overlay
	I.loc = victim

	deformation_effects(deformation_factor, I)

	var/list/observers = list()
	for(var/mob/observer in viewers(protected))
		if(observer.client)
			observers += observer.client

	flick_overlay(I, observers, 2 SECONDS)
	animate(I, alpha = 0, time = 2 SECONDS)
	QDEL_IN(I, 2 SECONDS)

/// Is called if src is not appear_on_hit. Handles the shield appearing above all protected.
/datum/component/forcefield/proc/show_shield_all()
	if(!shield_overlay)
		return

	for(var/atom/movable/AM in protected)
		show_shield(AM)

/// Adds the shield overlay to atom/victim.
/datum/component/forcefield/proc/show_shield(atom/movable/victim)
	victim.vis_contents += shield_overlay

/// Is called whenever a not appear_on_hit shield is toggled off.
/datum/component/forcefield/proc/hide_shield_all()
	if(!shield_overlay)
		return

	for(var/atom/movable/AM in protected)
		hide_shield(AM)

/// Removes the shield overlay from atom/victim.
/datum/component/forcefield/proc/hide_shield(atom/movable/victim)
	victim.vis_contents -= shield_overlay

/// Handle clicks from a thing that is shielded.
/datum/component/forcefield/proc/internal_click(datum/source, atom/target, params)
	if(permit_interaction)
		return NONE

	if(!active)
		return NONE

	var/mob/clicker = source

	if(clicker == target)
		return NONE
	if(target in clicker.get_contents())
		return NONE

	// This click should be prevented. Our "default" behaviour is to just
	// allow examination of the target instead.
	clicker.face_atom(target)
	if(clicker.client && clicker.client.eye == clicker)
		clicker.examinate(target)

	return COMPONENT_CANCEL_CLICK

/// Start protecting an atom.
/datum/component/forcefield/proc/start_protecting(datum/source, atom/A)
	LAZYADD(protected, A)

	RegisterSignal(A, list(COMSIG_PARENT_QDELETED), CALLBACK(src, .proc/stop_protecting, A))
	if(active)
		show_shield(A)

/datum/component/forcefield/proc/stop_protecting(datum/source, atom/A)
	UnregisterSignal(A, list(COMSIG_PARENT_QDELETED))
	if(active)
		hide_shield(A)

	LAZYREMOVE(protected, A)
