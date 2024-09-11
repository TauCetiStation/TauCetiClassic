/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0

	var/light_range_on = 1.5
	var/light_power_on = 3
	var/last_keyboard_sound = 0 // prevents keyboard sounds spam

	var/state_broken_preset = null // used if we want to choose icon_state that is going to be used
	var/state_nopower_preset = null

/obj/machinery/computer/atom_init(mapload, obj/item/weapon/circuitboard/C)
	. = ..()
	computer_list += src
	if(C && istype(C))
		circuit = C
	else
		if(circuit)
			circuit = new circuit(null)
		else
			resistance_flags |= FULL_INDESTRUCTIBLE // no circuit = INDESTRUCTIBLE cuz we cant build it
	power_change()

/obj/machinery/computer/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list && (last_keyboard_sound <= world.time))
		if(iscarbon(usr))
			playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
			last_keyboard_sound = world.time + 8

/obj/machinery/computer/Destroy()
	computer_list -= src
	return ..()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER, 70, TRUE)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 75, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/machinery/computer/atom_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
		set_light(0)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	if(flags & NODECONSTRUCT)
		return ..()
	deconstruction()
	if(circuit) //no circuit, no computer frame
		var/obj/structure/computerframe/A = new /obj/structure/computerframe(loc)
		A.set_dir(dir)
		A.circuit = circuit
		A.anchored = TRUE
		transfer_fingerprints_to(A)
		circuit = null
		if(stat & BROKEN)
			if(user)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
			else
				playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER, 70, TRUE)
			new /obj/item/weapon/shard(loc)
			A.state = 3
			A.icon_state = "3"
		else
			if(user)
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
			A.state = 4
			A.icon_state = "4"
	for(var/obj/C in src)
		C.forceMove(loc)
	..()

/obj/machinery/computer/emp_act(severity)
	if(prob(20 / severity))
		set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(25))
				qdel(src)
				return
			else if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/x in verbs)
		verbs -= x
	set_broken()

/obj/machinery/computer/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(prob(Proj.damage))
		set_broken()

/obj/machinery/computer/update_icon()
	..()
	icon_state = initial(icon_state)
	// Broken
	if(stat & BROKEN)
		if(state_broken_preset)
			icon_state = state_broken_preset
		else
			icon_state = "[initial(icon_state)]b"
	// Powered
	else if(stat & NOPOWER)
		if(state_nopower_preset)
			icon_state = state_nopower_preset
		else
			icon_state = "[initial(icon_state)]0"

/obj/machinery/computer/power_change()
	..()
	update_icon()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(light_range_on, light_power_on)
	return

/obj/machinery/computer/turn_light_off()
	. = ..()
	stat |= NOPOWER
	update_icon()
	update_power_use()

/obj/machinery/computer/proc/set_broken()
	if(circuit) //no circuit, no breaking
		stat |= BROKEN
		update_icon()
	return

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = replacetext(text, "\n", "<BR>")
	return text

/obj/machinery/computer/attackby(obj/item/I, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>It's too complicated for you.</span>")
		return
	if(isscrewing(I) && circuit && !(flags&NODECONSTRUCT))
		if(user.is_busy(src)) return
		if(I.use_tool(src, user, 20, volume = 50))
			deconstruct(TRUE)
	if(iswrenching(I))
		if(user.is_busy(src))
			return

		var/list/possible_directions = list()
		for(var/direction_to_check in (cardinal - NORTH - dir))
			possible_directions += dir2text(direction_to_check)

		var/dir_choise = input(user, "Choose the direction where to turn \the [src].", "Choose the direction.", null) as null|anything in possible_directions

		if(!dir_choise || !user || !(user in range(1, src)) || user.is_busy(src))
			return

		if(I.use_tool(src, user, 20, volume = 50) && src && I)
			user.visible_message("<span class='notice'>[user] turns \the [src] [dir_choise].</span>", "<span class='notice'>You turn \the [src] [dir_choise].</span>")
			set_dir(text2dir(dir_choise))

/obj/machinery/computer/verb/rotate()
	set category = "Object"
	set name = "Rotate"
	set src in oview(1)

	// virtual present
	if (isAI(usr) || ispAI(usr))
		return
	// state restrict
	if(!Adjacent(usr) || usr.incapacitated() || usr.lying || usr.is_busy(src))
		return
	// species restrict
	if(!usr.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>It's too complicated for you.</span>")
		return

	var/obj/item/I = usr.get_active_hand()

	if (!I || !iswrenching(I))
		to_chat(usr, "<span class='warning'>You need to hold a wrench in your active hand to do this.</span>")
		return

	var/list/possible_directions = list()
	for(var/direction_to_check in (cardinal - NORTH - dir))
		possible_directions += dir2text(direction_to_check)

	var/dir_choise = input(usr, "Choose the direction where to turn \the [src].", "Choose the direction.", null) as null|anything in possible_directions

	if(!dir_choise || !usr || !(usr in range(1, src)) || usr.is_busy(src))
		return

	if(I.use_tool(src, usr, 20, volume = 50) && src && I)
		usr.visible_message("<span class='notice'>[usr] turns \the [src] [dir_choise].</span>","<span class='notice'>You turn \the [src] [dir_choise].</span>")
		set_dir(text2dir(dir_choise))

/obj/machinery/computer/attack_hand(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(HULK in H.mutations)
			if(stat & (BROKEN))
				return 1
			if(H.a_intent == INTENT_HARM)
				H.visible_message("<span class='danger'>[H.name] smashes [src] with \his mighty arms!</span>")
				set_broken()
				return 1
			else
				H.visible_message("<span class='danger'>[H.name] stares cluelessly at [src] and drools.</span>")
				return 1
		if(HAS_TRAIT_FROM(H, TRAIT_WET_HANDS, QUALITY_TRAIT))
			var/emp_luck = rand(1, 20)
			if(emp_luck > 12)
				emp_act(1)
				to_chat(H, "<span class='warning'>You pressed something and sparks appeared.</span>")
				return 1
			else if(emp_luck <= 2)
				emp_act(2)
				to_chat(H, "<span class='warning'>You pressed something and everything is gone.</span>")
				return 1
			else if(emp_luck == 10)
				emp_act(3)
				to_chat(H, "<span class='warning'>You poured water on the device.</span>")
				return 1
	. = ..()

/obj/machinery/computer/attack_paw(mob/user)
	if(circuit)
		user.SetNextMove(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(prob(10))
			user.visible_message("<span class='danger'>[user.name] smashes the [src.name] with \his paws.</span>",
			"<span class='danger'>You smash the [src.name] with your paws.</span>",
			"<span class='danger'>You hear a smashing sound.</span>")
			set_broken()
			return
	user.visible_message("<span class='danger'>[user.name] smashes against the [src.name] with \his paws.</span>",
	"<span class='danger'>You smash against the [src.name] with your paws.</span>",
	"<span class='danger'>You hear a clicking sound.</span>")

/obj/machinery/computer/attack_alien(mob/user)
	if(isxenoqueen(user))
		attack_hand(user)
		return
	else
		to_chat(user, "You don't want to break these thing")

/obj/machinery/computer/attack_hulk(mob/living/simple_animal/hulk/user)
	. = ..()

	if(.)
		return TRUE
	if(!istype(user))
		return

	user.SetNextMove(CLICK_CD_INTERACT)
	user.do_attack_animation(src)
	playsound(user, 'sound/effects/hulk_hit_computer.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='warning'>You hit the computer, glass fragments hurt you!</span>")
	user.health -= rand(2,4)
	if(prob(40))
		set_broken()
		to_chat(user, "<span class='warning'>You broke the computer.</span>")
	return TRUE

/obj/machinery/computer/proc/print_document(text, docname)
	var/obj/item/weapon/paper/Paper = new /obj/item/weapon/paper()
	Paper.info = text
	Paper.update_icon()
	Paper.name = docname
	Paper.forceMove(loc)

/obj/machinery/computer/proc/print_photo(datum/data/record/record, docname)
	var/datum/picture/Picture = new()
	Picture.fields["img"] = record.fields["image"]
	Picture.fields["author"] = record.fields["author"]
	Picture.fields["mob_names"] = list(record.fields["name"]=/mob/living/carbon/human)
	Picture.fields["desc"] = "You can see [record.fields["name"]] on the photo"
	Picture.fields["icon"] = record.fields["icon"]
	Picture.fields["tiny"] = record.fields["small_icon"]
	Picture.fields["pixel_x"] = rand(-10, 10)
	Picture.fields["pixel_y"] = rand(-10, 10)
	var/obj/item/weapon/photo/Photo = new/obj/item/weapon/photo()
	Photo.name = docname
	Photo.forceMove(loc)
	Photo.construct(Picture)
