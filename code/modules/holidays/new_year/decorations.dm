#define FLICKER_CD_MAX 5
#define FLICKER_CD_MIN 4

/obj/item/decoration
	name = "decoration"
	desc = "Winter is coming!"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "santa"
	layer = 4.1

/obj/item/decoration/attack_hand(mob/user)
	var/choice = input("Do you want to take \the [src]?") in list("Yes", "Cancel")
	if(choice == "Yes" && get_dist(src, user) <= 1)
		..()

/obj/item/decoration/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(iswallturf(target))
		usr.remove_from_mob(src)
		forceMove(target)

// Garland
/obj/item/decoration/garland
	name = "garland"
	desc = "Beautiful lights! Shinee!"
	icon_state = "garland_1"
	var/icon_state_off = "garland"
	var/light_colors = list("#ff0000", "#6111ff", "#ffa500", "#44faff")
	var/on = TRUE
	var/brightness = 4
	var/random = TRUE
	var/variations = 3
	glow_icon = 'icons/holidays/new_year/decorations.dmi'

/obj/item/decoration/garland/long
	icon_state = "garland_1"
	icon_state_off = "garland_1"
	glow_icon_state = "garland_1_lights"
	random = FALSE

/obj/item/decoration/garland/medium
	icon_state = "garland_2"
	icon_state_off = "garland_2"
	glow_icon_state = "garland_2_lights"
	random = FALSE

/obj/item/decoration/garland/short
	icon_state = "garland_3"
	icon_state_off = "garland_3"
	glow_icon_state = "garland_3_lights"
	random = FALSE

/obj/item/decoration/garland/proc/update_garland()
	if(on)
		icon_state = "[icon_state_off]_on"
		set_light(brightness)
	else
		icon_state = "[icon_state_off]"
		set_light(0)

/obj/item/decoration/garland/atom_init()
	. = ..()
	if(random)
		icon_state_off = "garland_[rand(1, variations)]"
		glow_icon_state = "[icon_state_off]_lights"

	light_color = pick(light_colors)
	update_garland()

/obj/item/decoration/garland/attack_self(mob/user)
	. = ..()
	if(user.is_busy())
		return
	if(do_after(user, 5, target = src))
		toggle()

/obj/item/decoration/garland/verb/toggle()
	set name = "Toggle garland"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr
	on = !on
	C.visible_message("<span class='notice'>[C] turns \the [src] [on ? "on" : "off"].</span>", "<span class='notice'>You turn \the [src] [on ? "on" : "off"].</span>")
	update_garland()

// Tinsels
/obj/item/taperoll/tinsel
	name = "new year tinsel"
	cases = list("моток новогодней гирлянды", "мотка новогодней гирлянды", "мотку новогодней гирлянды", "моток новогодней гирлянды", "мотком новогодней гирлянды", "мотке новогодней гирлянды")
	desc = "Смотри! Смотри! Кругом белым-бело. Гляди, как ясно и светло!"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "tinsel_start"
	tape_type = /obj/effect/ebeam/tinsel
	icon_base = "tinsel"

/obj/item/taperoll/tinsel/create_beam(mob/user, turf/From, turf/To)
	var/datum/beam/beam = From.Beam(To, tape_type::icon_state, tape_type::icon, time=INFINITY, maxdistance=10, beam_type=tape_type, loose_factor = 0.7, dense_beam = FALSE)
	if(!beam)
		return

	var/obj/effect/ebeam/tape/tape = pick(beam.elements)
	if(tape)
		user.visible_message("<span class='notice'>[user] натягивает [CASE(tape, ACCUSATIVE_CASE)].</span>")

	qdel(src)

/obj/effect/ebeam/tinsel
	name = "new year tinsel"
	icon_state = "tinsel"
	cases = list("новогодняя гирлянда", "новогодней гирлянды", "новогодней гирлянде", "новогоднюю гирлянду", "новогодней гирляндой", "новогодней гирлянде")
	mouse_opacity = MOUSE_OPACITY_ICON
	layer = INFRONT_MOB_LAYER

	var/taperoll = /obj/item/taperoll/tinsel

	decoration_icon = 'icons/holidays/new_year/tinsel.dmi'

/obj/effect/ebeam/tinsel/attack_hand(mob/user)
	. = ..()
	user.visible_message("<span class='notice'>[user] сматывает [CASE(src, ACCUSATIVE_CASE)]!</span>")
	user.SetNextMove(CLICK_CD_INTERACT)

	var/obj/item/I = new taperoll(get_turf(src))
	user.put_in_hands(I)
	owner.End()


/obj/item/taperoll/tinsel/fluffy
	name = "new year fluffy tinsel"
	cases = list("моток мишуры", "мотка мишуры", "мотку мишуры", "моток мишуры", "мотком мишуры", "мотке мишуры")
	desc = "С новым годом! С новым счастьем"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "tinsel_green_start"
	tape_type = /obj/effect/ebeam/tinsel/fluffy

	icon_base = "tinsel_green"

/obj/effect/ebeam/tinsel/fluffy
	name = "new year fluffy tinsel"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "tinsel_green"
	cases = list("мишура", "мишуры", "мишуре", "мишуру", "мишурой", "мишуре")

	taperoll = /obj/item/taperoll/tinsel/fluffy
	decoration_icon = null

/obj/item/taperoll/tinsel/fluffy/red
	tape_type = /obj/effect/ebeam/tinsel/fluffy/red
	icon_state = "tinsel_red_start"
	icon_base = "tinsel_red"

/obj/effect/ebeam/tinsel/fluffy/red
	icon_state = "tinsel_red"
	taperoll = /obj/item/taperoll/tinsel/fluffy/red

/obj/item/taperoll/tinsel/fluffy/blue
	tape_type = /obj/effect/ebeam/tinsel/fluffy/blue
	icon_state = "tinsel_blue_start"
	icon_base = "tinsel_blue"

/obj/effect/ebeam/tinsel/fluffy/blue
	icon_state = "tinsel_blue"
	taperoll = /obj/item/taperoll/tinsel/fluffy/blue

/obj/item/taperoll/tinsel/fluffy/yellow
	tape_type = /obj/effect/ebeam/tinsel/fluffy/yellow
	icon_state = "tinsel_yellow_start"
	icon_base = "tinsel_yellow"

/obj/effect/ebeam/tinsel/fluffy/yellow
	icon_state = "tinsel_yellow"
	taperoll = /obj/item/taperoll/tinsel/fluffy/yellow


/obj/effect/spawner/tape/tinsel
	name = "new year tinsel spawner"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "tinselspawn"

	tape_type = /obj/effect/ebeam/tinsel
	dense_tape = FALSE

/obj/effect/spawner/tape/tinsel/fluffy
	name = "new year fluffy tinsel spawner"
	icon_state = "fluffytinselspawn"

	tape_type = /obj/effect/ebeam/tinsel/fluffy

/obj/effect/spawner/tape/tinsel/fluffy/atom_init()
	tape_type = pick(typesof(/obj/effect/ebeam/tinsel/fluffy))
	..()

// Snowflakes
/obj/item/decoration/snowflake
	name = "snowflake"
	desc = "Snowflakes from very soft and pleasant to touch material."
	icon_state = "snowflakes_1"

/obj/item/decoration/snowflake/atom_init()
	. = ..()
	icon_state = "snowflakes_[rand(1, 4)]"

// Snowman head
/obj/item/decoration/snowman
	name = "snowman head"
	desc = "Snowman head, which looks right into your soul."
	icon_state = "snowman"

// Xmas tree
/obj/item/device/flashlight/lamp/fir/special
	name = "present xmas tree"
	desc = "Hello, happy holidays, we have got presents..."

	layer = FLY_LAYER
	var/gifts_dealt = 0
	var/flicker_raising = FALSE
	var/light_flicker = 5

/obj/item/device/flashlight/lamp/fir/special/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/clickplace)

/obj/item/device/flashlight/lamp/fir/special/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return

	if(light_flicker >= FLICKER_CD_MAX)
		flicker_raising = FALSE
	else if(light_flicker <= FLICKER_CD_MIN)
		flicker_raising = TRUE
	light_color = pick("#39ff49", "#ff2f2f", "#248aff", "#fffa18")
	light_flicker += flicker_raising ? 1 : -1
	set_light(light_flicker)

/obj/item/device/flashlight/lamp/fir/special/attack_self(mob/user)
	. = ..()
	if(!.)
		return
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/device/flashlight/lamp/fir/special/examine(mob/user)
	..()
	if(!gifts_dealt || ((world.time - gifts_dealt) > 5000))
		to_chat(user, "<span class='notice'>Looks like there is something stuck between the branches... Have you been a good boy this year?</span>")
	to_chat(user, "<span class='notice'>You can place a wrapped item here as a gift to someone special.</span>")

/obj/item/device/flashlight/lamp/fir/special/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		return ..()
	if(I.flags & ABSTRACT)
		return
	if(istype(I, /obj/item/weapon/gift))
		var/obj/item/weapon/gift/present = I
		var/recipient = sanitize(input("Who is that present for? Write a name (Do it right):") as text|null)
		var/sender = sanitize(input("Enter your name:") as text|null)
		if(src && recipient && sender && present && get_dist(src, user) <= 1)
			present.recipient = recipient
			present.sender = sender
			user.drop_from_inventory(present, src)
			user.visible_message("[user] gently puts a gift under \the [src] .", "<span class='notice'>You gently put a gift under \the [src].</span>")
		return
	user.visible_message("<span class='notice'>[user] stands on \his tiptoes to hang [I] on [src].</span>")
	if(!do_after(user, 10, TRUE, src))
		to_chat(user, "<span class='warning'>You fail to hang [I] on [src]!</span>")
		return
	. = ..()
	if(istype(I, /obj/item/organ/external/head))
		I.set_dir(2) // Rotate head face to us
		I.transform = turn(null, null)	//Turn it to initial angle
	I.layer = layer + 0.1

/obj/item/device/flashlight/lamp/fir/special/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/how_many_gifts = 0
	var/choosen_gift
	for(var/O in src.contents)
		if(istype(O, /obj/item/weapon/gift))
			var/obj/item/weapon/gift/present = O
			if(present.recipient == H.name)
				how_many_gifts++
				choosen_gift = present
	if(how_many_gifts)
		var/obj/item/weapon/gift/G = choosen_gift
		to_chat(user, "<span class='notice'>Looks like there is [how_many_gifts] gifts for you under the tree!</span>")
		visible_message("<span class='notice'>[H] takes a gift from \the [src].</span>",
			"<span class='notice'>You take a gift from \the [src].</span>")
		G.forceMove(H.loc)
		user.put_in_active_hand(G)
	else
		shake()
	return

/obj/item/device/flashlight/lamp/fir/special/verb/shake()
	set name = "Shake tree"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr

	if(iscarbon(C))
		if(!gifts_dealt || ((world.time - gifts_dealt) > 5000))

			C.visible_message("<span class='notice'>[C] shakes [src].</span>","<span class='notice'>You shake [src].</span>")

			var/bad_boy = 0
			for(var/datum/job/job in SSjob.all_occupations)
				if(jobban_isbanned(C, job.title))
					bad_boy += 1
			if(!bad_boy)
				to_chat(C, "<span class='notice'>You understand that this year you was good boy!</span>")
				C.adjustBruteLoss(-1)
				C.adjustToxLoss(-1)
				C.adjustFireLoss(-1)
			if(bad_boy >= 5)
				to_chat(C, "<span class='notice'>You understand that this year you was bad boy!</span>")
				C.adjustBruteLoss(10)
				C.adjustToxLoss(10)
				C.adjustFireLoss(10)

			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			if(prob(10))
				new	/obj/item/weapon/present/special(src.loc)
				new	/obj/item/weapon/present/special(src.loc)
				new	/obj/item/weapon/present/special(src.loc)
			else
				new /obj/item/weapon/present(src.loc)
				new /obj/item/weapon/present(src.loc)
				new /obj/item/weapon/present(src.loc)
			gifts_dealt = world.time
		else
			C.visible_message("<span class='notice'>[C] shakes [src].</span>", "<span class='notice'>You shake [src] but nothing happens. Have patience!</span>")

/obj/item/device/flashlight/lamp/fir/special/alternative
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/snowman
	name = "snowman"
	desc = "That's a snowman. He is staring at you. Where is his hat, though?"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "snowman_s"
	anchored = FALSE

	max_integrity = 50
	damage_deflection = 5
	resistance_flags = CAN_BE_HIT

/obj/structure/snowman/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/clothing/head/that))
		if(icon_state == "snowman_s")
			qdel(W)
			icon_state = "snowman_hat"
			visible_message("<span class='notice'>[user] puts a hat on the snowman. He looks happy!</span>",
			"<span class='notice'>You put a hat on the snowman. He looks happy!</span>")
		else
			to_chat(user, "<span class='warning'>But snowman already has a hat!</span>")
		return
	..()

/obj/structure/snowman/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(. && !QDELING(src))
		visible_message("<span class='notice'>[src] is damaged!</span>")

/obj/structure/snowman/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	visible_message("<span class='warning'>[src] is destroyed!</span>")
	for(var/i in 1 to 6)
		new /obj/item/snowball(loc)
	if(icon_state == "snowman_hat")
		new /obj/item/clothing/head/that(loc)
	..()


/obj/item/device/flashlight/lamp/fir_small
	name = "small fir"
	desc = "Маленькая ёлочка."
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "small_christmas_tree"
	brightness_on = 2
	light_power = 0.6
	light_color = list("#ff0000", "#6111ff", "#ffa500", "#44faff")

	glow_icon = 'icons/holidays/new_year/decorations.dmi'
	glow_icon_state = "small_christmas_tree_lights"


/obj/item/decoration/wreath
	name = "chistmas wreath"
	desc = "Merry Christmas!"
	icon_state = "wreath"

#undef FLICKER_CD_MAX
#undef FLICKER_CD_MIN
