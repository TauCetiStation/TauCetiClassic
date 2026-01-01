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
	var/gulp_size = 5
	max_integrity = 1 //glass is very fragile
	var/fragile = FALSE // cant be destroyed by throw
	flags = OPENCONTAINER
	item_action_types = list(/datum/action/item_action/hands_free/switch_lid)
	var/label_text = ""
	var/pickup_empty_sound = 'sound/items/glass_containers/bottle_take-empty.ogg'
	var/pickup_full_sound = 'sound/items/glass_containers/bottle_take-liquid.ogg'
	var/dropped_empty_sound = 'sound/items/glass_containers/bottle_put-empty.ogg'
	var/dropped_full_sound = 'sound/items/glass_containers/bottle_put-liquid.ogg'

	//var/list/
	can_be_placed_into = list(
		/obj/machinery/chem_master,
		/obj/machinery/chem_dispenser,
		/obj/machinery/reagentgrinder,
		/obj/machinery/juicer,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/weapon/storage,
		/obj/machinery/atmospherics/components/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/weapon/grenade/chem_grenade,
		/obj/machinery/bot/medbot,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disposal,
		/obj/machinery/apiary,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/computer/centrifuge,
		/obj/machinery/sleeper,
		/obj/machinery/smartfridge,
		/obj/machinery/biogenerator,
		/obj/machinery/hydroponics,
		/obj/machinery/constructable_frame,
		/obj/item/clothing/suit/space/rig)

/datum/action/item_action/hands_free/switch_lid
	name = "Switch Lid"

/obj/item/weapon/reagent_containers/glass/on_reagent_change()
	..()
	if (gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/weapon/reagent_containers/glass/atom_init()
	. = ..()
	base_name = name
	if(is_open_container())
		verbs += /obj/item/weapon/reagent_containers/glass/proc/gulp_whole

/obj/item/weapon/reagent_containers/glass/pickup(mob/living/user)
	. = ..()
	animate(src, transform = null, time = 0) //Restore bottle to its original position
	if(reagents.total_volume > 0)
		playsound(user, pickup_full_sound, VOL_EFFECTS_MASTER)
	else
		playsound(user, pickup_empty_sound, VOL_EFFECTS_MASTER)

/obj/item/weapon/reagent_containers/glass/dropped(mob/user)
	. = ..()
	if(isturf(loc) && (user.loc != loc))
		if(reagents.total_volume > 0)
			playsound(user, dropped_full_sound, VOL_EFFECTS_MASTER)
		else
			playsound(user, dropped_empty_sound, VOL_EFFECTS_MASTER)

/obj/item/weapon/reagent_containers/glass/examine(mob/user)
	..()
	if(!is_open_container())
		to_chat(user, "<span class='info'>Герметичная крышка полностью закрывает [CASE(src, ACCUSATIVE_CASE)] .</span>")

/obj/item/weapon/reagent_containers/glass/attack_self()
	..()
	if (is_open_container())
		to_chat(usr, "<span class = 'notice'>Вы закрываете крышку [CASE(src, GENITIVE_CASE)].</span>")
		flags ^= OPENCONTAINER
	else
		to_chat(usr, "<span class = 'notice'>Вы снимаете крышку [CASE(src, GENITIVE_CASE)].</span>")
		flags |= OPENCONTAINER
	update_icon()
	update_item_actions()

/obj/item/weapon/reagent_containers/glass/afterattack(atom/target, mob/user, proximity, params)
	if (!is_open_container() || !proximity)
		return

	for(var/type in src.can_be_placed_into)
		if(istype(target, type))
			return

	if(ismob(target))
		if(!reagents.total_volume)
			to_chat(user, "<span class = 'rose'>В [CASE(src, PREPOSITIONAL_CASE)] ничего нет.</span>")
			return
		var/mob/living/M = target

		if(M == user)
			if(user.a_intent == INTENT_HARM)
				reagents.standard_splash(target, user=user)
				M.visible_message("<span class='warning'>[usr] splashed the [src] all over!</span>", "<span class='warning'>You splashed the [src] all over!</span>")
				return
			if(!CanEat(user, M, src, "drink"))
				return
			else if(user.a_intent != INTENT_HELP)
				gulp_whole()
				return
			if(isliving(M))
				var/mob/living/L = M
				L.taste_reagents(reagents)
			to_chat(M, "<span class='notice'>You swallow a gulp of [src].</span>")
			if(reagents.total_volume)
				reagents.trans_to_ingest(M, gulp_size)
			playsound(M, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
			update_icon()
			return TRUE
		else if(user.a_intent != INTENT_HARM)
			if(!CanEat(user, M, src, "drink"))
				return
			M.visible_message("<span class='rose'>[user] attempts to feed [M] [src].</span>", \
							"<span class='warning'><B>[user]</B> attempts to feed you <B>[src]</B>.</span>")
			if(!do_mob(user, M))
				return
			M.visible_message("<span class='rose'>[user] feeds [M] [src].</span>", \
							"<span class='warning'><B>[user]</B> feeds you <B>[src]</B>.</span>")

			M.log_combat(user, "fed [name], reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

			if(reagents.total_volume)
				reagents.trans_to_ingest(M, gulp_size)

			playsound(M, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
			update_icon()
			return TRUE

		var/list/injected = list()
		for(var/datum/reagent/R in src.reagents.reagent_list)
			injected += R.name
		var/contained = get_english_list(injected)

		M.log_combat(user, "splashed with [name], reagents: [contained] (INTENT: [uppertext(user.a_intent)])")

		user.visible_message("<span class='rose'>[target] has been splashed with something by [user]!</span>")
		reagents.standard_splash(target, user=user)
		return

	else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us. Or FROM us TO it.
		var/obj/structure/reagent_dispensers/T = target
		if(T.transfer_from)
			T.try_transfer(T, src, user)
		else
			T.try_transfer(src, T, user)
	else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class = 'rose'>В [CASE(src, PREPOSITIONAL_CASE)] ничего нет.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class = 'rose'>[capitalize(CASE(target, NOMINATIVE_CASE))] [(ANYMORPH(target, "полон", "полна", "полно", "полны"))].</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class = 'notice'>Вы переливаете [trans] юнитов вещества в [CASE(target, ACCUSATIVE_CASE)].</span>")
		playsound(src, 'sound/effects/Liquid_transfer_mono.ogg', VOL_EFFECTS_MASTER) // Sound taken from "Eris" build

	//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.
	else if(istype(target, /obj/item/clothing/suit/space/space_ninja))
		return

	else if(istype(target, /obj/machinery/bunsen_burner))
		return

	else if(istype(target, /obj/machinery/smartfridge))
		return

	else if(istype(target, /obj/machinery/radiocarbon_spectrometer))
		return

	else if(istype(target, /obj/machinery/color_mixer))
		var/obj/machinery/color_mixer/CM = target
		if(CM.filling_tank_id)
			if(CM.beakers[CM.filling_tank_id])
				if(user.a_intent == INTENT_GRAB)
					var/obj/item/weapon/reagent_containers/glass/GB = CM.beakers[CM.filling_tank_id]
					GB.afterattack(src, user, proximity)
				else
					afterattack(CM.beakers[CM.filling_tank_id], user, proximity)
				CM.updateUsrDialog()
				CM.update_icon()
				return
			else
				to_chat(user, "<span class='warning'>You try to fill [user.a_intent == INTENT_GRAB ? "[src] up from a tank" : "a tank up"], but find it is absent.</span>")
				return


	else if(reagents && reagents.total_volume)
		to_chat(user, "<span class = 'notice'>Вы разлили содержимое на [CASE(target, ACCUSATIVE_CASE)].</span>")
		reagents.standard_splash(target, user=user)
		return

/obj/item/weapon/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitize_safe(input(user, "Введите имя для [CASE(src, GENITIVE_CASE)]","Этикетка", input_default(label_text)), MAX_NAME_LEN)
		if(length(tmp_label) > 10)
			to_chat(user, "<span class = 'rose'>Длина этикетки может составлять не более 10 символов.</span>")
		else
			to_chat(user, "<span class = 'notice'>Вы клеите этикетку \"[tmp_label]\".</span>")
			label_text = tmp_label
			update_name_label()

	else if(istype(I, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = I
		if(is_open_container() && reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class = 'rose'>[capitalize(CASE(src, NOMINATIVE_CASE))] [ANYMORPH(src, "полон", "полна", "полно", "полны")].</span>")
				return

			if(!N.use(1))
				return

			reagents.add_reagent("nanites2", 1)
	else
		return ..()

/obj/item/weapon/reagent_containers/glass/proc/update_name_label()
	if(label_text == "")
		name = base_name
	else
		name = "[base_name] ([label_text])"

/obj/item/weapon/reagent_containers/glass/bullet_act(obj/item/projectile/Proj, def_zone)
	if(Proj.checkpass(PASSGLASS))
		return PROJECTILE_FORCE_MISS

	return ..()

/obj/item/weapon/reagent_containers/glass/after_throw(datum/callback/callback)
	..()
	if(fragile)
		deconstruct()

/obj/item/weapon/reagent_containers/glass/deconstruct(damage_flag)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	var/obj/item/weapon/shard/S = new(loc)
	if(prob(75))
		S.throw_at(get_step(src, pick(alldirs)), rand(1, 6), 2)
	S.pixel_x = rand(-5, 5)
	S.pixel_y = rand(-5, 5)
	reagents.standard_splash(loc)
	..()

/obj/item/weapon/reagent_containers/glass/proc/gulp_whole()
	set category = "Object"
	set name = "Gulp Down"
	set src in view(1)

	if(usr.incapacitated())
		return

	if(!is_open_container())
		to_chat(usr, "<span class='notice'>You need to open [src]!</span>")
		return

	usr.visible_message("<span class='notice'>[usr] prepares to gulp down [src].</span>", "<span class='notice'>You prepare to gulp down [src].</span>")

	if(!CanEat(usr, usr, src, eatverb="gulp"))
		return

	if(!do_after(usr, reagents.total_volume, target=src, can_move=FALSE))
		usr.visible_message("<span class='warning'>[usr] splashed the [src] all over!</span>", "<span class='warning'>You splashed the [src] all over!</span>")
		reagents.standard_splash(loc, user=usr)
		return

	if(!CanEat(usr, usr, src, eatverb="gulp"))
		return

	if(isliving(usr))
		var/mob/living/L = usr
		L.taste_reagents(reagents)

	usr.visible_message("<span class='notice'>[usr] gulped down the whole [src]!</span>", "<span class='notice'>You gulped down the whole [src]!</span>")
	reagents.trans_to_ingest(usr, reagents.total_volume)
	playsound(usr, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(15, 55))

/obj/item/weapon/reagent_containers/glass/proc/refill_by_borg(user, refill, trans)
	reagents.add_reagent(refill, trans)
	to_chat(user, "Cyborg [src] refilled.")
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	cases = list("мензурка", "мензурки", "мензурке", "мензурку", "мензуркой", "мензурке")
	desc = "Это мензурка."
	gender = FEMALE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	m_amt = 0
	g_amt = 500
	volume = 60
	var/list/filling_states = list()
	possible_transfer_amounts = list(5,10,15,25,30,60)
	resistance_flags = CAN_BE_HIT
	fragile = TRUE

/obj/item/weapon/reagent_containers/glass/beaker/atom_init()
	. = ..()
	desc += " Может вместить до [volume] юнитов."
	filling_states = list(20, 40, 60, 80, 100)

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
	cut_overlays()

	if(reagents?.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state][get_filling_state()]")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

	if(!is_open_container())
		var/mutable_appearance/lid = mutable_appearance(icon, "lid_[icon_state]")
		add_overlay(lid)

/obj/item/weapon/reagent_containers/glass/beaker/proc/get_filling_state()
	var/percent = round((reagents.total_volume / volume) * 100)
	var/list/increments = list()
	for(var/x in filling_states)
		increments += text2num(x)
	if(!length(increments))
		return

	var/last_increment = increments[1]
	for(var/increment in increments)
		if(percent < increment)
			break

		last_increment = increment

	return last_increment

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	cases = list("большая мензурка", "большой мензурки", "большой мензурке", "большую мензурку", "большой мензуркой", "большой мензурке")
	desc = "Это большая мензурка."
	gender = FEMALE
	icon_state = "beakerlarge"
	g_amt = 5000
	volume = 150
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,150)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	cases = list("криостазисная мензурка", "криостазисной мензурки", "криостазисной мензурке", "криостазисную мензурку", "криостазисной мензуркой", "криостазисной мензурке")
	desc = "Криостазисная мензурка, позволяющая хранить химические вещества без протекания реакций."
	icon_state = "beakernoreact"
	g_amt = 500
	amount_per_transfer_from_this = 10
	flags = OPENCONTAINER | NOREACT

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	cases = list("блюспейс мензурка", "блюспейс мензурки", "блюспейс мензурке", "блюспейс мензурку", "блюспейс мензуркой", "блюспейс мензурке")
	desc = "Блюспейс мензурка, работающая на экспериментальной технологии."
	gender = FEMALE
	icon_state = "beakerbluespace"
	g_amt = 5000
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	flags = OPENCONTAINER
	resistance_flags = FULL_INDESTRUCTIBLE
	fragile = FALSE


/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	cases = list("пробирка", "пробирки", "пробирке", "пробирку", "пробиркой", "пробирке")
	desc = "Маленькая стеклянная пробирка."
	gender = FEMALE
	icon_state = "vial"
	g_amt = 250
	volume = 25
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/vial/update_icon()
	cut_overlays()

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
		add_overlay(filling)

	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		add_overlay(lid)


/obj/item/weapon/reagent_containers/glass/beaker/teapot
	name = "teapot"
	cases = list("чайник", "чайника", "чайнику", "чайник", "чайником", "чайнике")
	desc = "Элегантный чайник."
	gender = MALE
	icon_state = "teapot"
	item_state = "teapot"
	resistance_flags = FULL_INDESTRUCTIBLE
	fragile = FALSE


/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone/atom_init()
	. = ..()
	reagents.add_reagent("cryoxadone", 30)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric/atom_init()
	. = ..()
	reagents.add_reagent("sacid", 50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/slime

/obj/item/weapon/reagent_containers/glass/beaker/slime/atom_init()
	. = ..()
	reagents.add_reagent("slimejelly", 50)
	update_icon()


/obj/item/weapon/reagent_containers/glass/bucket
	name = "bucket"
	cases = list("ведро", "ведра", "ведру", "ведро", "ведром", "ведре")
	desc = "Это ведро."
	gender = NEUTER
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0
	w_class = SIZE_SMALL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = OPENCONTAINER
	body_parts_covered = HEAD
	slot_flags = SLOT_FLAGS_HEAD
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 3, bomb = 5, bio = 0, rad = 0)
	force = 5
	pickup_empty_sound = null
	pickup_full_sound = null
	dropped_empty_sound = null
	dropped_full_sound = null

/obj/item/weapon/reagent_containers/glass/bucket/attackby(obj/item/I, mob/user, params)
	if(isprox(I))
		to_chat(user, "<span class = 'notice'>You add [I] to [src].</span>")
		qdel(I)
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
		qdel(src)
		return

	if(iswelding(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.use(0,user))
			var/obj/item/clothing/head/helmet/battlebucket/BBucket = new(usr.loc)
			loc.visible_message("<span class = 'rose'>[src] is shaped into [BBucket] by [user.name] with the weldingtool.</span>", blind_message = "<span class = 'rose'>You hear welding.</span>")
			qdel(src)
		return

	return ..()

/obj/item/weapon/reagent_containers/glass/bucket/update_icon()
	cut_overlays()
	if (reagents.total_volume > 1)
		add_overlay("bucket_water")
	if (!is_open_container())
		add_overlay("lid_bucket")

/obj/item/weapon/reagent_containers/glass/bucket/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/bucket/full/atom_init()
	. = ..()
	reagents.add_reagent("water", volume)
	update_icon()
