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

/obj/item/candle/ghost/attack_ghost()
	if(!lit)
		if(prob(10))
			spook()
		light()

/obj/item/candle/proc/light(flavor_text = "<span class='warning'>[usr] lights the [name].</span>")
	if(!lit)
		lit = TRUE
		//src.damtype = "fire"
		for(var/mob/O in viewers(usr, null))
			O.show_message(flavor_text, 1)
		set_light(CANDLE_LUM, candle_color)
		START_PROCESSING(SSobj, src)

/obj/item/candle/ghost/proc/spook()
	visible_message("<span class='warning bold'>Out of the tip of the flame, a face appears. Horrifying.</span>")
	playsound(get_turf(src), 'sound/effects/screech.ogg', 50, 0)
	for(var/mob/living/carbon/M in hearers(4, src))
		M.confused += 10
		M.make_jittery(150)
	for(var/obj/machinery/light/L in range(4, src))
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
			if(lit)
				var/obj/item/candle/C = new /obj/item/candle(loc)
				C.lit = TRUE
			else
				new /obj/item/candle(loc)
			if(istype(loc, /mob))
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
		if(istype(src, /obj/item/trash/candle/ghost))
			new/obj/item/trash/candle/ghost(src.loc)
		else
			new/obj/item/trash/candle(src.loc)
		if(istype(loc, /mob))
			dropped()
		qdel(src)
	update_icon()
	if(istype(loc, /turf)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

/obj/item/candle/ghost/process()
	..()
	for(var/mob/living/carbon/M in range(4, src))
		if(M.dreaming)
			M.dreaming = 2

/obj/item/candle/attack_self(mob/user)
	if(lit)
		lit = FALSE
		update_icon()
		set_light(0)

/obj/item/candle/ghost/attack_self(mob/user)
	if(lit)
		to_chat(user, "<span class='notice'>You can't just extinguish it.</span>")