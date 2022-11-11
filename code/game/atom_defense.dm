/// The essential proc to call when an atom must receive damage of any kind.
/atom/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir)
	if(!uses_integrity)
		CRASH("[src] had /atom/proc/take_damage() called on it without it being a type that has uses_integrity = TRUE!")
	if(QDELETED(src))
		CRASH("[src] taking damage after deletion")
	if(atom_integrity <= 0)
		CRASH("[src] taking damage while having <= 0 integrity")
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	damage_amount = run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(damage_amount < DAMAGE_PRECISION)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_TAKE_DAMAGE, damage_amount, damage_type, damage_flag, sound_effect, attack_dir) & COMPONENT_NO_TAKE_DAMAGE)
		return

	. = damage_amount

	update_integrity(atom_integrity - damage_amount, damage_flag)

/// Proc for recovering atom_integrity. Returns the amount repaired by
/atom/proc/repair_damage(amount)
	if(amount <= 0) // We only recover here
		return
	var/new_integrity = min(max_integrity, atom_integrity + amount)
	. = new_integrity - atom_integrity

	update_integrity(new_integrity)

/// Handles the integrity of an atom changing. This must be called instead of changing integrity directly.
/atom/proc/update_integrity(new_value, damage_flag = null)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!uses_integrity)
		CRASH("/atom/proc/update_integrity() was called on [src] when it doesnt use integrity!")
	var/old_value = atom_integrity
	new_value = max(0, new_value)
	if(atom_integrity == new_value)
		return
	atom_integrity = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_INTEGRITY_CHANGED, old_value, new_value)

	if(old_value < new_value)
		if(integrity_failure && atom_integrity > integrity_failure * max_integrity)
			atom_fix()
		return
	//DESTROYING FIRST
	if(new_value <= 0)
		atom_destruction(damage_flag)
		return
	//BREAKING SECOND
	if(integrity_failure && atom_integrity <= integrity_failure * max_integrity)
		atom_break(damage_flag)

/// This mostly exists to keep atom_integrity private. Might be useful in the future.
/atom/proc/get_integrity()
	SHOULD_BE_PURE(TRUE)
	return atom_integrity

///returns the damage value of the attack after processing the atom's various armor protections
/atom/proc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(!uses_integrity)
		CRASH("/atom/proc/run_atom_armor was called on [src] without being implemented as a type that uses integrity!")
	if(damage_flag == MELEE && damage_amount < damage_deflection)
		return 0
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor[damage_flag]
	return round(damage_amount * (100 - armor_protection)*0.01, DAMAGE_PRECISION)

///the sound played when the atom is damaged.
/atom/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

///Called to get the damage that hulks will deal to the atom.
/atom/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this atom, is affected by melee armor

/atom/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1) //used by attack_alien, attack_animal, and attack_slime
	if(!uses_integrity)
		CRASH("unimplemented /atom/proc/attack_generic()!")
	if(!(resistance_flags & CAN_BE_HIT))
		return
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user))

/// Called after the atom takes damage and integrity is below integrity_failure level
/atom/proc/atom_break(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_BREAK, damage_flag) // TODO use comsigs?

/// Called when integrity is repaired above the breaking point having been broken before
/atom/proc/atom_fix()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_FIX)

///what happens when the atom's integrity reaches zero.
/atom/proc/atom_destruction(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_DESTRUCTION, damage_flag)

///changes max_integrity while retaining current health percentage, returns TRUE if the atom got broken.
/atom/proc/modify_max_integrity(new_max)
	if(!uses_integrity)
		CRASH("/atom/proc/modify_max_integrity() was called on [src] when it doesnt use integrity!")
	var/current_integrity = atom_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max)) //don't destroy it as a result
		atom_integrity = current_integrity

	max_integrity = new_max

/// A cut-out proc for [/atom/proc/bullet_act] so living mobs can have their own armor behavior checks without causing issues with needing their own on_hit call
/atom/proc/check_projectile_armor(def_zone, obj/item/projectile/impacting_projectile, is_silent)
	return 0 // TODO? Do i really need to rewrite all bullet code?
