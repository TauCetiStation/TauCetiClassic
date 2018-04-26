var/global/list/obj/item/candle/ghost/ghost_candles = list()

/obj/item/candle
	name = "red candle"
	desc = "A candle."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle"
	item_state = "candle"
	var/candle_color
	w_class = 1

	var/wax = 200
	var/lit = FALSE

/obj/item/candle/ghost
	name = "black candle"
	icon_state = "gcandle"
	item_state = "gcandle"
	candle_color = "#a2fad1"

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

/obj/item/candle/proc/light(flavor_text = "<span class='warning'>[usr] lights the [name].</span>")
	if(!src.lit)
		lit = TRUE
		//src.damtype = "fire"
		visible_message(flavor_text)
		set_light(CANDLE_LUM, 1, candle_color)
		START_PROCESSING(SSobj, src)

/obj/item/candle/ghost/proc/spook()
	visible_message("<span class='warning bold'>Out of the tip of the flame, a face appears.</span>")
	playsound(get_turf(src), 'sound/effects/screech.ogg', 50, 0)
	for(var/mob/living/carbon/M in hearers(4, get_turf(src)))
		if(!iscultist(M))
			M.confused += 10
			M.make_jittery(150)
	for(var/obj/machinery/light/L in range(4, get_turf(src)))
		L.on = TRUE
		L.broken()

/obj/item/candle/update_icon()
	var/i
	if(wax>150)
		i = 1
	else if(wax>80)
		i = 2
	else
		i = 3
	icon_state = "[initial(icon_state)][i][lit ? "_lit" : ""]"

/obj/item/candle/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a welding tool
			light("\red [user] casually lights the [name] with [W].")
	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light()
	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit)
			light()
	else if(istype(W, /obj/item/candle))
		var/obj/item/candle/C = W
		if(C.lit)
			light()

/obj/item/candle/ghost/attackby(obj/item/weapon/W, mob/living/carbon/human/user)
	..()
	if(istype(W, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = W
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
	if(istype(W, /obj/item/weapon/book/tome))
		spook()
		light()
	if(user.getBrainLoss() >= 60 || user.mind.assigned_role == "Chaplain" || user.mind.role_alt_title == "Paranormal Investigator")
		if(!lit && istype(W, /obj/item/weapon/storage/bible))
			var/obj/item/weapon/storage/bible/B = W
			if(B.icon_state == "necronomicon")
				spook()
				light()
			else
				for(var/mob/living/carbon/M in range(4, src))
					to_chat(M, "<span class='notice'>You feel slight delight, as all curses pass away...</span>")
					M.apply_damages(-1,-1,-1,-1,0,0)
					light()
		if(istype(W, /obj/item/weapon/nullrod))
			var/obj/item/candle/C = new /obj/item/candle(loc)
			if(lit)
				C.light()
			C.wax = wax
			if(istype(loc, /mob))
				user.put_in_hands(C)
				dropped()
			qdel(src)
		if(istype(W, /obj/item/trash/candle))
			to_chat(user, "<span class='warning'>The wax begins to corrupt and pulse like veins as it merges itself with the [src], impressive.</span>")
			user.confused += 10 // Sights of this are not pleasant.
			if(prob(10) && user.nutrition > 20)
				user.vomit()
			wax += 50
			user.drop_item()
			qdel(W)

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	if(!wax)
		var/obj/item/candle/C
		if(istype(src, /obj/item/candle/ghost))
			C = new /obj/item/trash/candle/ghost(src.loc)
		else
			C = new /obj/item/trash/candle(src.loc)
		if(istype(loc, /mob))
			var/mob/M = loc
			M.put_in_hands(C)
			dropped()
		qdel(src)
	update_icon()
	if(istype(loc, /turf)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

/obj/item/candle/attack_self(mob/user)
	if(lit)
		lit = FALSE
		update_icon()
		set_light(0)

/obj/item/candle/ghost/attack_self(mob/user)
	if(lit)
		to_chat(user, "<span class='notice'>You can't just extinguish it.</span>")