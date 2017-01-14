////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	flags = OPENCONTAINER

	action_button_name = "Switch Lid"

	var/label_text = ""

	//var/list/
	can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/weapon/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/weapon/grenade/chem_grenade,
		/obj/machinery/bot/medbot,
		/obj/machinery/computer/pandemic,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disposal,
		/obj/machinery/apiary,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/computer/centrifuge,
		/obj/machinery/sleeper,
		/obj/machinery/smartfridge/,
		/obj/machinery/biogenerator,
		/obj/machinery/hydroponics,
		/obj/machinery/constructable_frame)

/obj/item/weapon/reagent_containers/glass/New()
	..()
	base_name = name

/obj/item/weapon/reagent_containers/glass/examine(mob/user)
	..()
	if(!is_open_container())
		to_chat(user, "<span class='info'>Airtight lid seals it completely.</span>")

/obj/item/weapon/reagent_containers/glass/attack_self()
	..()
	if (is_open_container())
		to_chat(usr, "<span class = 'notice'>You put the lid on \the [src].</span>")
		flags ^= OPENCONTAINER
	else
		to_chat(usr, "<span class = 'notice'>You take the lid off \the [src].</span>")
		flags |= OPENCONTAINER
	update_icon()

/obj/item/weapon/reagent_containers/glass/afterattack(obj/target, mob/user , flag)

	if (!is_open_container() || !flag)
		return

	for(var/type in src.can_be_placed_into)
		if(istype(target, type))
			return

	if(ismob(target) && target.reagents && reagents.total_volume)
		to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")

		var/mob/living/M = target
		var/list/injected = list()
		for(var/datum/reagent/R in src.reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been splashed with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to splash [M.name] ([M.key]). Reagents: [contained]</font>")
		msg_admin_attack("[user.name] ([user.ckey]) splashed [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		for(var/mob/O in viewers(world.view, user))
			O.show_message(text("<span class = 'rose'>[] has been splashed with something by []!</span>", target, user), 1)
		src.reagents.reaction(target, TOUCH)
		spawn(5) src.reagents.clear_reagents()
		return
	else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume && target.reagents)
			to_chat(user, "<span class = 'rose'>[target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class = 'rose'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class = 'notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class = 'rose'>[src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class = 'rose'>[target] is full.</span>")
			return

		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class = 'notice'>You transfer [trans] units of the solution to [target].</span>")

	//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.
	else if(istype(target, /obj/item/clothing/suit/space/space_ninja))
		return

	else if(istype(target, /obj/machinery/bunsen_burner))
		return

	else if(istype(target, /obj/machinery/smartfridge))
		return

	else if(istype(target, /obj/machinery/radiocarbon_spectrometer))
		return

	else if(reagents && reagents.total_volume)
		to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")
		src.reagents.reaction(target, TOUCH)
		spawn(5) src.reagents.clear_reagents()
		var/turf/T = get_turf(src)
		message_admins("[key_name_admin(usr)] splashed [src.reagents.get_reagents()] on [target], location ([T.x],[T.y],[T.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>)")
		log_game("[usr.ckey]([usr]) splashed [src.reagents.get_reagents()] on [target], location ([T.x],[T.y],[T.z])")
		return

/obj/item/weapon/reagent_containers/glass/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitize(copytext(input(user, "Enter a label for [src.name]","Label",src.label_text), 1, MAX_NAME_LEN))
		if(length(tmp_label) > 10)
			to_chat(user, "<span class = 'rose'>The label can be at most 10 characters long.</span>")
		else
			to_chat(user, "<span class = 'notice'>You set the label to \"[tmp_label]\".</span>")
			src.label_text = tmp_label
			src.update_name_label()
	if (istype(W, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = W
		if(src.is_open_container() && src.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(src.reagents.total_volume >= src.reagents.maximum_volume)
				to_chat(user, "<span class = 'rose'>[src] is full.</span>")
				return

			src.reagents.add_reagent("nanites2", 1)
			N.use(1)

/obj/item/weapon/reagent_containers/glass/proc/update_name_label()
	if(src.label_text == "")
		src.name = src.base_name
	else
		src.name = "[src.base_name] ([src.label_text])"

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	m_amt = 0
	g_amt = 500

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]-10"
			if(10 to 24) 	filling.icon_state = "[icon_state]10"
			if(25 to 49)	filling.icon_state = "[icon_state]25"
			if(50 to 74)	filling.icon_state = "[icon_state]50"
			if(75 to 79)	filling.icon_state = "[icon_state]75"
			if(80 to 90)	filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	g_amt = 5000
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	g_amt = 500
	volume = 50
	amount_per_transfer_from_this = 10
	flags = OPENCONTAINER | NOREACT

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology. Can hold up to 300 units."
	icon_state = "beakerbluespace"
	g_amt = 5000
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	flags = OPENCONTAINER


/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	g_amt = 250
	volume = 25
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	New()
		..()
		reagents.add_reagent("cryoxadone", 30)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric
	New()
		..()
		reagents.add_reagent("sacid", 50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/slime
	New()
		..()
		reagents.add_reagent("slimejelly", 50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = OPENCONTAINER
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD

/obj/item/weapon/reagent_containers/glass/bucket/attackby(obj/D, mob/user)
	if(isprox(D))
		to_chat(user, "<span class = 'notice'>You add [D] to [src].</span>")
		qdel(D)
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
		user.drop_from_inventory(src)
		qdel(src)
	if (istype(D, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = D
		if(WT.remove_fuel(0,user))
			user.remove_from_mob(src)
			var/obj/item/clothing/head/helmet/battlebucket/BBucket = new(usr.loc)
			for (var/mob/M in viewers(src))
				M.show_message("<span class = 'rose'>[src] is shaped into [BBucket] by [user.name] with the weldingtool.</span>", 3, "<span class = 'rose'>You hear welding.</span>", 2)
			qdel(src)
		return

/obj/item/weapon/reagent_containers/glass/bucket/update_icon()
	overlays.Cut()
	if (reagents.total_volume > 1)
		overlays += "bucket_water"
	if (!is_open_container())
		overlays += "lid_bucket"

/obj/item/weapon/reagent_containers/glass/bucket/on_reagent_change()
	update_icon()
