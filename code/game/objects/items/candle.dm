var/global/list/obj/item/candle/ghost/ghost_candles = list()
#define CANDLE_LUMINOSITY	3

/obj/item/candle
	name = "white candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."

	icon = 'icons/obj/candle.dmi'
	icon_state = "white_candle"
	item_state = "white_candle"

	var/candle_color
	w_class = ITEM_SIZE_TINY

	var/wax = 0
	var/lit = FALSE
	light_color = LIGHT_COLOR_FIRE

	var/infinite = FALSE
	var/start_lit = FALSE

	var/faded_candle = /obj/item/trash/candle

/obj/item/candle/atom_init()
	. = ..()
	wax = rand(600, 800)
	if(start_lit)
		// No visible message
		light(flavor_text = FALSE)
	update_icon()

/obj/item/candle/proc/light(flavor_text = "<span class='warning'>[usr] lights the [name].</span>")
	if(!lit)
		lit = TRUE
		//src.damtype = "fire"
		visible_message(flavor_text)
		set_light(CANDLE_LUMINOSITY, 1)
		START_PROCESSING(SSobj, src)
		playsound(src, 'sound/items/matchstick_light.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/item/candle/update_icon()
	var/lighning_stage
	if(wax > 450)
		lighning_stage = 1
	else if(wax > 200)
		lighning_stage = 2
	else
		lighning_stage = 3
	icon_state = "[initial(icon_state)][lighning_stage][lit ? "_lit" : ""]"
	if(lit)
		item_state = "[initial(icon_state)]_lit"
	else
		item_state = "[initial(icon_state)]"
	if(istype(loc, /mob))
		var/mob/M = loc
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.l_hand == src)
				M.update_inv_l_hand()
			if(H.r_hand == src)
				M.update_inv_r_hand()

/obj/item/candle/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.isOn()) // Badasses dont get blinded by lighting their candle with a welding tool
			light("<span class='warning'>[user] casually lights the [name] with [I].</span>")
	else if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = I
		if(L.lit)
			light()
	else if(istype(I, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = I
		if(M.lit)
			light()
	else if(istype(I, /obj/item/candle))
		var/obj/item/candle/C = I
		if(C.lit)
			light()
	else
		return ..()

/obj/item/candle/get_current_temperature()
	if(lit)
		return 1000
	else
		return 0

/obj/item/candle/extinguish()
	var/obj/item/candle/C = new faded_candle(loc)
	if(istype(loc, /mob))
		var/mob/M = loc
		M.drop_from_inventory(src, null)
		M.put_in_hands(C)

	qdel(src)

/obj/item/candle/process()
	if(!lit)
		return
	if(!infinite)
		wax--
	if(!wax)
		extinguish()
		return
	update_icon()
	if(istype(loc, /turf)) // start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

/obj/item/candle/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] blows out the [src].</span>")
		lit = FALSE
		update_icon()
		set_light(0)
		STOP_PROCESSING(SSobj, src)

 // Ghost candle
/obj/item/candle/ghost
	name = "black candle"

	icon_state = "black_candle"
	item_state = "black_candle"

	light_color = LIGHT_COLOR_GHOST_CANDLE

	faded_candle = /obj/item/trash/candle/ghost

/obj/item/candle/ghost/atom_init()
	. = ..()
	ghost_candles += src

/obj/item/candle/ghost/Destroy()
	ghost_candles -= src
	return ..()

/obj/item/candle/ghost/attack_ghost()
	if(!lit)
		src.light("<span class='warning'>\The [name] suddenly lights up.</span>")
		if(prob(10))
			spook()

/obj/item/candle/ghost/attack_self(mob/user)
	if(lit)
		to_chat(user, "<span class='notice'>You can't just extinguish it.</span>")

/obj/item/candle/ghost/proc/spook()
	visible_message("<span class='warning bold'>Out of the tip of the flame, a face appears.</span>")
	playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	for(var/mob/living/carbon/M in hearers(4, get_turf(src)))
		if(!iscultist(M))
			M.confused += 10
			M.make_jittery(150)

	var/list/targets = list()
	for(var/turf/T in range(4))
		targets += T
	light_off_range(targets, src)

/obj/item/candle/ghost/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
		return

	if(istype(I, /obj/item/weapon/book/tome))
		spook()
		light()
		return

	var/chaplain_check = FALSE

	if(isliving(user))
		var/mob/living/L = user
		if(L.getBrainLoss() >= 60 || L.mind.holy_role || L.mind.role_alt_title == "Paranormal Investigator")
			chaplain_check = TRUE

	if(chaplain_check)
		var/mob/living/L = user
		if(!lit && istype(I, /obj/item/weapon/storage/bible))
			var/obj/item/weapon/storage/bible/B = I
			if(B.icon_state == "necronomicon")
				spook()
				light()
			else
				for(var/mob/living/carbon/M in range(4, src))
					to_chat(M, "<span class='notice'>You feel slight delight, as all curses pass away...</span>")
					M.apply_damages(-1,-1,-1,-1,0,0)
					light()
			return

		if(istype(I, /obj/item/weapon/nullrod))
			var/obj/item/candle/C = new /obj/item/candle(loc)
			if(lit)
				C.light("")
			C.wax = wax
			if(istype(loc, /mob))
				L.put_in_hands(C)
			qdel(src)
			return

		if(istype(I, /obj/item/trash/candle))
			to_chat(user, "<span class='warning'>The wax begins to corrupt and pulse like veins as it merges itself with the [src], impressive.</span>")
			user.confused += 10 // Sights of this are not pleasant.
			if(ishuman(L) && prob(10))
				var/mob/living/carbon/human/H = L
				H.invoke_vomit_async()
			wax += 50
			qdel(I)
			return

	return ..()

/obj/item/candle/red
	name = "red candle"

	icon_state = "red_candle"
	item_state = "red_candle"

	faded_candle = /obj/item/trash/candle/red

 // Infinite candle (Admin item)
/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

#undef CANDLE_LUMINOSITY
