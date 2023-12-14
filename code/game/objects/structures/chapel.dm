/obj/structure/stool/bed/chair/pew
	name = "pew"
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "general_left"

	density = TRUE
	anchored = TRUE

	dir = NORTH

	// It's  a pew!
	layer = FLY_LAYER

	var/pew_icon = "general"
	var/append_icon_state = "_left"

/obj/structure/stool/bed/chair/pew/atom_init()
	. = ..()
	update_icon()

/obj/structure/stool/bed/chair/pew/post_buckle_mob(mob/living/M)
	return

/obj/structure/stool/bed/chair/pew/handle_rotation()
	if(buckled_mob)
		buckled_mob.set_dir(dir)
		buckled_mob.update_canmove()

/obj/structure/stool/bed/chair/pew/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, loc) & dir)
		return !density
	return TRUE

/obj/structure/stool/bed/chair/pew/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(!density)
		return TRUE
	if(is_the_opposite_dir(dir, to_dir))
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/pew/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, O.loc) == dir)
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/pew/update_icon()
	icon_state = pew_icon + append_icon_state

/obj/structure/stool/bed/chair/pew/left
	// For mappers.
	icon_state = "general_left"
	append_icon_state = "_left"

/obj/structure/stool/bed/chair/pew/right
	icon_state = "general_right"
	append_icon_state = "_right"



ADD_TO_GLOBAL_LIST(/obj/effect/effect/bell, bells)
/obj/effect/effect/bell
	name = "The Lord Voker"
	desc = "Ring-a-ding, let the station know you've got a nullrod and you ain't afraid to use it!"

	icon = 'icons/obj/big_bell.dmi'
	icon_state = "lord_Voker"

	density = FALSE
	anchored = TRUE

	pixel_x = -16
	pixel_y = -2

	layer = BELL_LAYER

	mouse_opacity = MOUSE_OPACITY_OPAQUE

	var/next_swing = 0

	var/next_ring = 0
	var/next_global_ring = 0

	var/obj/structure/big_bell/base

	// The offset for pivoting.
	var/pivot_y = 12

/obj/effect/effect/bell/atom_init(mapload, obj/structure/big_bell/BB)
	. = ..()
	base = BB
	AddComponent(/datum/component/bounded, BB, 0, 0, null, null, FALSE)

/obj/effect/effect/bell/Destroy()
	if(!QDELING(base))
		QDEL_NULL(base)
	return ..()

/obj/effect/effect/bell/proc/can_use(mob/user)
	if(!user.Adjacent(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/effect/effect/bell/proc/swing(angle, time, swing_am)
	if(next_swing > world.time)
		return
	next_swing = world.time + time

	if(prob(50))
		angle *= -1

	var/stop_swinging = world.time + time
	var/swing_time = time / swing_am

	var/angle_delta = angle / swing_am

	var/old_pixel_y = pixel_y
	pixel_y += pivot_y

	var/matrix/old_transform = transform
	var/matrix/pivot_transform = matrix(transform)
	pivot_transform.Translate(0, -pivot_y)

	transform = pivot_transform

	while(stop_swinging > world.time)
		if(QDELING(src))
			return
		if(angle >= -1 && angle <= 1)
			break
		if(swing_time <= 1)
			break

		var/matrix/M = matrix(pivot_transform)
		M.Turn(angle)
		animate(src, transform = M, time = swing_time * 0.5)
		animate(transform = pivot_transform, time = swing_time * 0.5)

		angle *= -1
		angle -= angle_delta

		sleep(swing_time)

	transform = old_transform
	pixel_y = old_pixel_y

/obj/effect/effect/bell/proc/stun_insides(force)
	for(var/mob/living/L in get_turf(src))
		if(L.crawling)
			return

		var/ear_safety = 0
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(HULK in H.mutations)
				ear_safety += 1
			if(istype(H.head, /obj/item/clothing/head/helmet))
				ear_safety += 1

		to_chat(L, "<span class='danger'>[name] rings all throughout your mind!</span>")

		ear_safety *= 1 / force

		if(ear_safety > 1)
			L.Stun(1)
		else if(ear_safety > 0)
			L.Stun(1)
			L.Weaken(1)
		else
			L.Stun(3)
			L.Weaken(3)
			L.ear_damage += rand(0, 5)
			L.ear_deaf = max(L.ear_deaf, 15)

/obj/effect/effect/bell/proc/adjust_strength(def_val, strength, strength_coeff, max_val)
	return min(round(def_val + strength * strength_coeff), max_val)

/obj/effect/effect/bell/proc/ring(mob/user, strength)
	if(next_ring > world.time)
		to_chat(user, "<span class='notice'>The bell is still swinging. Please wait [round((next_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return
	next_ring = world.time + 3 SECONDS

	visible_message("[bicon(src)] <span class='notice'>[src] rings, strucken by [user].</span>")

	var/shake_duration = adjust_strength(2, strength, 0.25, 4)
	var/shake_strength = adjust_strength(0, strength, 0.1, 3)

	if(shake_strength > 0)
		shake_camera(user, shake_duration, shake_strength)
	playsound(src, 'sound/effects/bell.ogg', VOL_EFFECTS_MASTER, 75, null)

	var/swing_angle = adjust_strength(6, strength, 0.25, 16)

	stun_insides(1)

	INVOKE_ASYNC(src, PROC_REF(swing), swing_angle, 2 SECONDS, 2)

/obj/effect/effect/bell/proc/announce_global(text, strength)
	for(var/mob/M in player_list)
		if(M.z == z)
			// Why do they call them voice announcements if it's just global announcements?
			M.playsound_local(null, 'sound/effects/big_bell.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, 75)
			to_chat(M, "[bicon(src)] <span class='game say'><b>[src]</b> rings, \"[text]\"</span>")

	var/swing_angle = adjust_strength(12, strength, 0.25, 32)

	stun_insides(2)

	INVOKE_ASYNC(src, PROC_REF(swing), swing_angle, 9 SECONDS, 6)

/obj/effect/effect/bell/proc/ring_global(mob/user, strength)
	if(!user.mind || !user.mind.holy_role)
		ring(user, strength)
		return

	if(next_global_ring > world.time)
		to_chat(user, "<span class='warning'>You can't alarm the whole station so often! Please wait [round((next_global_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return

	if(tgui_alert(user, "Are you sure you want to alert the entire station with [src]?", "[src]", list("Yes", "No")) == "No")
		return
	var/ring_msg = capitalize(sanitize(input(user, "What do you want to ring on [src]?", "Enter message") as null|text))
	if(!ring_msg)
		return

	if(!can_use(user))
		return

	if(!user.mind || !user.mind.holy_role)
		ring(user, strength)
		return

	if(next_global_ring > world.time)
		to_chat(user, "<span class='warning'>You can't alarm the whole station so often! Please wait [round((next_global_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return
	next_global_ring = world.time + 10 MINUTES

	visible_message("[bicon(src)] <span class='warning'>[src] rings loudly, strucken by [user]!</span>")
	var/shake_duration = adjust_strength(4, strength, 0.25, 16)
	var/shake_strength = adjust_strength(1, strength, 0.1, 5)

	if(shake_strength > 0)
		shake_camera(user, shake_duration, shake_strength)

	announce_global(ring_msg, strength)

/obj/effect/effect/bell/attackby(obj/item/I, mob/user)
	if(user.a_intent == INTENT_HARM)
		ring_global(user, I.force)
	else
		ring(user, I.force)

/obj/effect/effect/bell/attack_paw(mob/living/user)
	attack_hand(user)

/obj/effect/effect/bell/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM)
		ring_global(user, 1)
	else
		ring(user, 1)

/obj/structure/big_bell
	name = "bell base"
	desc = "Ring-a-ding, let the station know you've got a nullrod and you ain't afraid to use it!"
	icon = 'icons/obj/big_bell.dmi'
	icon_state = "bell_base"

	density = TRUE
	anchored = TRUE

	pixel_x = -16
	pixel_y = -2

	layer = INFRONT_MOB_LAYER

	var/obj/effect/effect/bell/bell

/obj/structure/big_bell/atom_init()
	. = ..()
	bell = new(loc, src)

/obj/structure/big_bell/Destroy()
	if(!QDELING(bell))
		QDEL_NULL(bell)
	return ..()

/obj/structure/big_bell/attackby(obj/item/I, mob/user)
	if(iswrenching(I) && !user.is_busy(src) && I.use_tool(src, user, 40, volume = 50))
		anchored = !anchored
		visible_message("<span class='warning'>[src] has been [anchored ? "secured to the floor" : "unsecured from the floor"] by [user].</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
		return

	return ..()

/obj/structure/big_bell/CanPass(atom/movable/mover, turf/target, height=0)
	return istype(mover) && mover.checkpass(PASSCRAWL)

/obj/structure/big_bell/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, atom/movable/caller)
	return istype(caller) && caller.checkpass(PASSCRAWL)

/obj/structure/big_bell/CheckExit(atom/movable/mover, target)
	return istype(mover) && mover.checkpass(PASSCRAWL)


/obj/structure/stool/bed/chair/lectern
	name = "lectern"
	desc = "Уверовавший в свою безгрешность умирает нераскаявшимся."
	icon = 'icons/obj/lectern.dmi'
	icon_state = "lectern"

	layer = INFRONT_MOB_LAYER

	density = FALSE
	anchored = TRUE

	material = /obj/item/stack/sheet/wood

	can_flipped = TRUE

	var/next_speech
	var/speech_cooldown = 0.5 SECONDS

	var/next_shake
	var/shake_cooldown = 0.5 SECONDS

	var/saved_text = ""

	var/paragraph_size = RUNECHAT_MESSAGE_MAX_LENGTH - 10
	var/max_paragraph_buffer = 10

	var/obj/item/weapon/storage/internal/book

	var/mutable_appearance/lectern_overlay
	var/mutable_appearance/book_overlay
	var/mutable_appearance/emblem_overlay

/obj/structure/stool/bed/chair/lectern/atom_init()
	. = ..()

	book = new(src)
	book.set_slots(slots = 1, slot_size = SIZE_NORMAL)
	book.w_class = SIZE_NORMAL

	book.can_hold = list(
		/obj/item/weapon/spellbook,
		/obj/item/weapon/book,
		/obj/item/weapon/storage/bible,
	)

	RegisterSignal(book, list(COMSIG_STORAGE_ENTERED), PROC_REF(add_book))
	RegisterSignal(book, list(COMSIG_STORAGE_EXITED), PROC_REF(remove_book))

	lectern_overlay = mutable_appearance(icon, "lectern_overlay")
	lectern_overlay.layer = INFRONT_MOB_LAYER

	book_overlay = mutable_appearance(icon, "book")
	book_overlay.layer = INFRONT_MOB_LAYER

	emblem_overlay = mutable_appearance(icon, "general")
	emblem_overlay.layer = INFRONT_MOB_LAYER
	lectern_overlay.add_overlay(emblem_overlay)
	add_overlay(emblem_overlay)

/obj/structure/stool/bed/chair/lectern/Destroy()
	QDEL_NULL(lectern_overlay)
	QDEL_NULL(book_overlay)
	QDEL_NULL(emblem_overlay)
	QDEL_NULL(book)
	return ..()

/obj/structure/stool/bed/chair/lectern/proc/get_text_from(obj/item/I)
	if(istype(I, /obj/item/weapon/book))
		var/obj/item/weapon/book/B = I
		return B.dat

	if(istype(I, /obj/item/weapon/storage/bible))
		var/obj/item/weapon/storage/bible/B = I
		if(!B.religion)
			return ""
		if(length(B.religion.rites_by_name) <= 0)
			return ""
		var/list/pos_rites = B.religion.rites_by_name.Copy()
		while(pos_rites.len > 0)
			var/rite_name = pick(B.religion.rites_by_name)
			pos_rites -= rite_name

			var/datum/religion_rites/RR = B.religion.rites_by_name[rite_name]
			if(length(RR.ritual_invocations) <= 0)
				continue

			return pick(RR.ritual_invocations)

	if(istype(I, /obj/item/weapon/spellbook))
		var/obj/item/weapon/spellbook/SB = I
		if(length(SB.entries) <= 0)
			return ""

		var/datum/spellbook_entry/SE = pick(SB.entries)
		return SE.desc

	return ""

/obj/structure/stool/bed/chair/lectern/proc/get_text()
	if(saved_text)
		return fragment_text()

	if(length(book.contents) <= 0)
		return ""

	var/obj/item/I = pick(book.contents)
	saved_text = get_text_from(I)
	return fragment_text()

/obj/structure/stool/bed/chair/lectern/proc/fragment_text()
	var/static/list/delims = list(" ", ".", ",", ":", "!", "?")

	var/txt_end = length_char(saved_text)

	var/start = 1
	var/end = min(txt_end, paragraph_size)

	if(end == txt_end)
		var/fragment = saved_text
		saved_text = ""
		return fragment

	var/min_delim_pos = paragraph_size + max_paragraph_buffer
	for(var/delim in delims)
		var/delim_pos = findtext_char(saved_text, delim, end, end + max_paragraph_buffer)
		if(delim_pos == 0)
			continue

		if(delim_pos < min_delim_pos)
			min_delim_pos = delim_pos

	end = min_delim_pos

	var/fragment = copytext_char(saved_text, start, end + 1)
	saved_text = copytext_char(saved_text, end + 1, txt_end + 1)

	return fragment

/obj/structure/stool/bed/chair/lectern/proc/add_book(datum/source, obj/item/I)
	add_overlay(book_overlay)
	icon_state = "[initial(icon_state)]_book"
	lectern_overlay.add_overlay(book_overlay)

/obj/structure/stool/bed/chair/lectern/proc/remove_book(datum/source, obj/item/I)
	saved_text = ""
	cut_overlay(book_overlay)
	icon_state = "[initial(icon_state)]"
	lectern_overlay.cut_overlay(book_overlay)

/obj/structure/stool/bed/chair/lectern/AltClick(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.incapacitated())
		return
	if(!H.Adjacent(src))
		return
	if(!H.IsAdvancedToolUser())
		return

	if(H != buckled_mob)
		return

	if(H.a_intent == INTENT_HARM)
		if(next_shake > world.time)
			return
		next_shake = world.time + shake_cooldown

		shake_act(1)
		return

	if(next_speech > world.time)
		return
	next_speech = world.time + shake_cooldown

	var/txt = get_text()
	if(txt == "")
		return

	H.say(txt)

/obj/structure/stool/bed/chair/lectern/attack_hand(mob/user)
	if(anchored && book.handle_attack_hand(user))
		return

	return ..()

/obj/structure/stool/bed/chair/lectern/MouseDrop(obj/over_object)
	if(anchored && book.handle_mousedrop(usr, over_object))
		return

	return ..()

/obj/structure/stool/bed/chair/lectern/can_flip(mob/living/carbon/human/user)
	if(anchored)
		return FALSE
	return ..()

/obj/structure/stool/bed/chair/lectern/attackby(obj/item/weapon/W, mob/user, params)
	if(iswrenching(W))
		if(flipped)
			to_chat(user, "<span class='notice'>You need to flip [src] back upright.</span>")
			return

		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		can_buckle = !can_buckle
		to_chat(user, "<span class='notice'>You have [anchored ? "secured" : "unsecured"] [src].</span>")
		return

	if(isprying(W))
		if(anchored)
			to_chat(user, "<span class='notice'>You need to unsecure [src] first.</span>")
			return
		if(!flipped)
			to_chat(user, "<span class='notice'>You need to flip [src] over.</span>")
			return
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You are disassembling [src].</span>")
		for(var/obj/item/I as anything in src)
			I.forceMove(loc)
		new material(loc)
		qdel(src)
		return

	if(anchored && book.attackby(W, user, params))
		return

	return ..()

/obj/structure/stool/bed/chair/lectern/handle_rotation()
	if(dir == NORTH)
		layer = BELOW_MOB_LAYER
	else
		layer = INFRONT_MOB_LAYER

	if(buckled_mob)
		buckled_mob.set_dir(dir)
		buckled_mob.update_canmove()

/obj/structure/stool/bed/chair/lectern/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		layer = BELOW_MOB_LAYER
		M.pixel_y = 12
		update_buckle_mob(M)
		add_overlay(lectern_overlay)

	else
		if(dir == NORTH)
			layer = BELOW_MOB_LAYER
		else
			layer = INFRONT_MOB_LAYER
		M.pixel_y = M.default_pixel_y
		cut_overlay(lectern_overlay)

/obj/structure/stool/bed/chair/lectern/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE

	return get_dir(target, loc) & dir

/obj/structure/stool/bed/chair/lectern/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(!density)
		return TRUE

	return is_the_opposite_dir(dir, to_dir)

/obj/structure/stool/bed/chair/lectern/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, O.loc) != dir)
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/lectern/update_icon()
	return
