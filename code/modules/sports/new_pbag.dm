/mob/living/pbag
	name = "punching bag"
	desc = "It's made by some goons."

	icon = 'code/modules/sports/pbag.dmi'
	icon_state = "pbag"
	var/my_icon_state = "pbag" // Used so after a swing we fall correctly in async calls.

	density = FALSE
	anchored = TRUE

	maxHealth = 100

	var/swinging = FALSE

/mob/living/pbag/atom_init()
	. = ..()

	if(!anchored)
		hang()

	color = random_color()
	alive_mob_list -= src

/mob/living/pbag/attack_ghost(mob/dead/observer/attacker)
	if(ckey)
		to_chat(attacker, "<span class='notice'>[src] is already possesed.</span>")
		return

	if(stat)
		to_chat(attacker, "<span class='notice'>[src] seems to be too upbeat to be possesed.</span>")
		return

	ghostize(can_reenter_corpse = FALSE) // If there was a @ckey before or something.
	ckey = attacker.ckey
	qdel(attacker)

/mob/living/pbag/ghostize(can_reenter_corpse = TRUE, bancheck = FALSE)
	return ..(can_reenter_corpse = FALSE, bancheck = FALSE)

/mob/living/pbag/UnarmedAttack(atom/A)
	INVOKE_ASYNC(src, /mob/living/pbag.proc/swing)

/mob/living/pbag/on_lay_down()
	drop_down()
	resting = FALSE

/mob/living/pbag/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(ckey)
		INVOKE_ASYNC(src, /mob/living/pbag.proc/swing)

/mob/living/pbag/say(message, datum/language/speaking = null, verb="says", alt_name="", italics=FALSE, message_range = world.view, list/used_radios = list(), sound/speech_sound, sound_vol, sanitize = TRUE, message_mode = FALSE)
	if(ckey)
		. = ..(message, verb = "whispers", message_range = 1)

/mob/living/pbag/emote(act, type, message)
	if(ckey)
		visible_message("<span class='notice'>[bicon(src)] [src] swings ominously...</span>")
		INVOKE_ASYNC(src, /mob/living/pbag.proc/swing)

/mob/living/pbag/helpReaction(mob/living/attacker)
	if(!anchored)
		hang(attacker)

/mob/living/pbag/death()
	return

/mob/living/pbag/Life()
	if(anchored)
		handle_combat()

/mob/living/pbag/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, used_weapon = null)
	if(!anchored)
		return

	hit(damage, damagetype)

	var/flags_mes = ""
	if(damage_flags & (DAM_SHARP|DAM_EDGE))
		flags_mes = ", the attack was sharp"

	var/wep_mes = ""
	if(used_weapon)
		wep_mes = "with [used_weapon] "

	var/def_zone_txt = ""
	switch(def_zone)
		if(BP_HEAD)
			def_zone_txt = "the upper part"
		if(BP_CHEST)
			def_zone_txt = "the middle part"
		if(BP_GROIN)
			def_zone_txt = "the lower part"
		if(BP_L_ARM)
			def_zone_txt = "slightly to the left of the middle part"
		if(BP_R_ARM)
			def_zone_txt = "slightly to the right of the middle part"
		if(BP_L_LEG)
			def_zone_txt = "slightly to the left of the lower part"
		if(BP_R_LEG)
			def_zone_txt = "slightly to the right of the lower part"
		if(O_EYES)
			def_zone_txt = "the upper part"
		if(O_MOUTH)
			def_zone_txt = "the upper part"

	var/mes = "[bicon(src)] [src] has been hit [wep_mes]for [damage] [damagetype] damage in [def_zone_txt][flags_mes]."
	visible_message("<span class='notice'>[mes]</span>")

/mob/living/pbag/apply_effect(effect = 0, effecttype = STUN, blocked = 0)
	if(!anchored)
		return

	if(effecttype == WEAKEN || effecttype == PARALYZE)
		drop_down()
	visible_message("<span class='notice'>[bicon(src)] [src] was [effecttype]ed for [effect] seconds.</span>")

/mob/living/pbag/proc/hit(damage, damagetype)
	if(damagetype != BRUTE)
		return

	if(!anchored)
		return

	adjustBruteLoss(damage)
	if(bruteloss > maxHealth)
		drop_down()
	else
		INVOKE_ASYNC(src, .proc/swing, damage)

/mob/living/pbag/proc/drop_down()
	if(ckey)
		var/mob/dead/observer/ghost = ghostize(can_reenter_corpse = FALSE)
		if(ghost)
			to_chat(ghost, "<span class='warning'>You have been punched out of existence!</span>")
			var/dir_throw = pick(cardinal)
			var/turf/T = get_step(src, dir_throw)
			for(var/i in 1 to 5)
				T = get_step(T, dir_throw)
			ghost.throw_at(T, 7, 5, src) // It will say that the bad "thrown" the ghost out. Sounds fun.

	anchored = FALSE
	icon_state = "pbagdown"
	my_icon_state = "pbagdown"
	playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
	animate(src, pixel_y = pixel_y - 4, time = 1)

/mob/living/pbag/proc/swing(time = rand(0.5 SECONDS, 2 SECONDS))
	if(swinging)
		return
	time = min(time, 2 SECONDS)
	swinging = TRUE
	icon_state = "pbaghit"
	sleep(time)
	icon_state = my_icon_state
	swinging = FALSE

/mob/living/pbag/verb/hang(mob/living/user)
	set name = "Hang Bag"
	set category = "Object"
	set src in view(1)

	if(!user)
		user = usr

	if(isliving(user))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		user.visible_message("<span class='notice'>[user] [anchored ? "secures" : "unsecures"] \the [src].</span>",
			"<span class='notice'>You [anchored? "secure":"undo"] \the [src].</span>",
			"<span class='notice'>You hear a ratchet.</span>")

		if(anchored)
			icon_state = "pbag"
			my_icon_state = "pbag"
			pixel_y = 0
			rejuvenate()
		else
			drop_down()

/mob/living/pbag/has_head(targetzone = null)
	return TRUE

/mob/living/pbag/has_arm(targetzone = null)
	return TRUE

/mob/living/pbag/has_leg(targetzone = null)
	return TRUE
