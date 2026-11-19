/proc/blow_kiss(mob/user, atom/target, params, target_told = FALSE)
	if(!isturf(user.loc))
		return FALSE

	var/turf/target_turf = get_turf(target)
	if(!target_turf || target_turf == get_turf(user))
		return FALSE

	var/obj/item/projectile/kiss/blown = new(get_turf(user))
	blown.target_told = target_told
	blown.Fire(target, user, params)
	return TRUE


/obj/item/weapon/kiss
	name = "kiss"
	desc = "Ждёт, когда его отправят по адресу."
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	item_state = "nothing"
	flags = ABSTRACT|DROPDEL|NOBLUDGEON
	w_class = SIZE_TINY

// Always blown, never swung, so an adjacent click has to fire it too.
/obj/item/weapon/kiss/melee_attack_chain(atom/target, mob/user, params)
	afterattack(target, user, TRUE, params)

/obj/item/weapon/kiss/afterattack(atom/target, mob/user, proximity, params)
	if(get_turf(target) == get_turf(user))
		to_chat(user, "<span class='notice'>Слишком близко.</span>")
		return

	if(!blow_kiss(user, target, params))
		return

	user.visible_message("<b>[user]</b> <i>посылает воздушный поцелуй в сторону [target].</i>", "<span class='notice'>Вы посылаете воздушный поцелуй в сторону [target].</span>")
	qdel(src)


/obj/item/projectile/kiss
	name = "kiss"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE
	damage = 0
	nodamage = 1
	fake = 1
	kill_count = 10
	step_delay = 0.5
	// The panel already addressed the intended target; anybody it hits instead was told nothing.
	var/target_told = FALSE

/obj/item/projectile/kiss/check_miss(mob/living/L)
	return FALSE

// Living targets skip bullet_act on purpose: armour, shields, combat logs and a userdanger line.
/obj/item/projectile/kiss/Bump(atom/A, forced = 0)
	if(bumped && !forced)
		return FALSE

	if(!isliving(A))
		return ..()

	bumped = TRUE
	land_on(A)
	qdel(src)
	return TRUE

/obj/item/projectile/kiss/proc/land_on(mob/living/target)
	// Something disguised as scenery takes it the way scenery would: no sound, no message.
	if(!target.can_be_interacted_with())
		return

	if(target.stat != CONSCIOUS)
		return

	playsound(target, 'sound/effects/kiss.ogg', VOL_EFFECTS_MASTER)

	// The sender's emote already named this target; only somebody it hit instead was told nothing.
	if(target_told && target == original)
		return

	if(firer)
		target.show_message("<b>[firer]</b> <i>посылает вам воздушный поцелуй.</i>", SHOWMSG_VISUAL, "Вы слышите чмок.", SHOWMSG_AUDIO)
