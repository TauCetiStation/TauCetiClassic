#define POWERFIST_MIN_PRESSURE 10 // kPa

/obj/item/weapon/melee/powerfist
	name = "power-fist"
	desc = "Металлическая перчатка с ударным поршневым механизмом наверху для дополнительной силы удара. Точно украдено у Унатхов."
	cases = list("силовой кастет","силового кастета","силовому кастету","силовой кастет","силовым кастетом","силовом кастете")
	icon_state = "powerfist_1"
	item_state = "powerfist"
	flags = CONDUCT
	attack_verb = list("whacked", "fisted", "power-punched")
	force = 20
	throwforce = 10
	throw_range = 7
	w_class = SIZE_TINY
	origin_tech = "combat=5;powerstorage=3;syndicate=3"
	can_embed = FALSE
	var/agony = 0
	var/base_force = 0
	var/fisto_setting = 1
	var/damage_mult_per_stage = 3
	var/obj/item/weapon/tank/tank = null //Tank used for the gauntlet's piston-ram.

/obj/item/weapon/melee/powerfist/atom_init(mapload, ...)
	. = ..()
	base_force = force

/obj/item/weapon/melee/powerfist/examine(mob/user)
	..()
	if(!in_range(user, src))
		to_chat(user,"<span class='notice'>Чтобы осмотреть манометр, нужно подойти поближе.</span>")
		return
	if(tank)
		to_chat(user,"<span class='notice'>Манометр показывает [tank.air_contents.return_pressure()] кПа внутри баллона.</span>")// initial_pressure


/obj/item/weapon/melee/powerfist/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tank))
		if(!tank)
			var/obj/item/weapon/tank/IT = I
			if(IT.volume <= 3)
				to_chat(user,"<span class='warning'>\The [IT] is too small for \the [src].</span>")
				return
			insertTank(IT, user)
		else
			removeTank(user)

	else if(iswrenching(I))
		fisto_setting = 1 + (fisto_setting % 3)
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		to_chat(user,"<span class='notice'>Вы поворачиваете клапан [CASE(src, DATIVE_CASE)] в [fisto_setting]й режим.</span>")
		update_icon()

	else if(isscrewing(I))
		removeTank(user)

	else
		return ..()

/obj/item/weapon/melee/powerfist/attack_self(mob/user)
	fisto_setting = 1 + (fisto_setting % 3)
	playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
	to_chat(user,"<span class='notice'>Вы поворачиваете клапан [CASE(src, DATIVE_CASE)] в [fisto_setting]й режим.</span>")
	update_icon()

/obj/item/weapon/melee/powerfist/AltClick(mob/user)
	if(tank)
		removeTank(user)

/obj/item/weapon/melee/powerfist/proc/removeTank(mob/living/carbon/human/user)
	if(!tank)
		to_chat(user,"<span class='notice'>Нечего отсоединять от [CASE(src, GENITIVE_CASE)].</span>")
		return
	to_chat(user,"<span class='notice'>Вы отсоединили баллон от [CASE(src, ACCUSATIVE_CASE)].</span>")
	user.put_in_hands(tank)
	tank = null

/obj/item/weapon/melee/powerfist/proc/insertTank(obj/item/weapon/tank/thetank, mob/living/carbon/human/user)
	if(tank)
		to_chat(user,"<span class='warning'>В [CASE(src, PREPOSITIONAL_CASE)] уже есть баллон.</span>")
		return

	if(!user.unEquip(thetank))
		return

	to_chat(user,"<span class='notice'>Вы подключаете баллон в [CASE(src, ACCUSATIVE_CASE)].</span>")
	tank = thetank
	thetank.forceMove(src)

/obj/item/weapon/melee/powerfist/attack(mob/living/target, mob/living/user, def_zone)
	if(!tank)
		to_chat(user,"<span class='warning'>Для работы [CASE(src, GENITIVE_CASE)] нужен баллон с газом!</span>")
		return FALSE

	var/initial_pressure = tank.air_contents.return_pressure()
	var/consumed_pressure = 0
	if(initial_pressure >= POWERFIST_MIN_PRESSURE)
#define K0 0.15//0.3
#define K1 0.175//0.115
#define K2 0.075//0.105
		// fixed ratio pressure removal for balance I guess, corresponds to 30%, 50%, 90%
		// to find coefficients use quadratic fit
		// 5 10 30?
		//var/datum/gas_mixture/M = tank.air_contents.remove_ratio(fisto_setting ** 2 * K2 - fisto_setting * K1 + K0)
		var/datum/gas_mixture/M = tank.air_contents.remove_ratio(fisto_setting ** 2 * K2 + fisto_setting * K1 + K0)
#undef K0
#undef K1
#undef K2
		// this is bogus, but real physics is too hard, this will do
		consumed_pressure = M.return_pressure()

	if(consumed_pressure < POWERFIST_MIN_PRESSURE)
		to_chat(user,"<span class='warning'>Ударный поршень [CASE(src, GENITIVE_CASE)] тихо шипит, для его работы нужно больше газа в баллоне!</span>")
		playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
		return FALSE

#define PRACTICAL_MAX_CONSUMED (10 * ONE_ATMOSPHERE * 0.9)
	// punch is the damage multiplier, under normal circumstances,
	// when player hits PRACTICAL_MAX_CONSUMED (approx 910 kPa)
	// punch will be 3, so we deal 3x base damage (20 -> 60)
	var/punch = consumed_pressure / PRACTICAL_MAX_CONSUMED * damage_mult_per_stage
#undef  PRACTICAL_MAX_CONSUMED

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	//harm
	force = 1.5 ** (fisto_setting - 1) * base_force// + base_force * punch

	if((user.get_species() == HUMAN && target.get_species() == UNATHI) || (target.get_species() == HUMAN && user.get_species() == UNATHI))
		playsound(src, 'sound/voice/mob/pain/male/passive_whiner_4.ogg', VOL_EFFECTS_MASTER)
		force += 5

	var/block_throw
	if(( check_shield_dir(target, get_dir(src, target))))
		block_throw = 0 //blocked
	else
		block_throw = 1

	switch(user.a_intent)
		if(INTENT_HELP )
			agony = 1.5 * force
			force = 1
			target.throw_at(throw_target, (fisto_setting - 1) * block_throw, 1)
		if(INTENT_PUSH)
			agony = 0.75 * force
			force = 0.25 * force
			if(!(BP_L_ARM == def_zone) && !(BP_R_ARM == def_zone))
				target.throw_at(throw_target,(2 * fisto_setting + punch) / 3 ** (1 - block_throw), 1)
				target.MakeConfused(0.2 * fisto_setting)
		if(INTENT_GRAB)
			agony = 0.25 * force
			force = 0.5 * force

			if(iscarbon(target))
				if(!check_shield_dir(target, get_dir(src, target)))
					target.crawling = TRUE
			else
				target.Stun(0.5 * fisto_setting)
		if(INTENT_HARM)
			agony = 0
			target.throw_at(throw_target, (fisto_setting - 1) * block_throw, 1)

	var/atom/movable/hand_item
														//obj/item/weapon/melee/powerfist/
	switch(def_zone)
		if(BP_HEAD, O_EYES, O_MOUTH)
			agony = 0.9 * agony
			force = 0.9 * force
			target.MakeConfused(0.05 * fisto_setting)
		if(BP_CHEST)
			force = 1.25 * force
		if(BP_GROIN)
			agony = agony + 0.5 * base_force * punch
			if(user.IsClumsy() || target.IsClumsy())
				playsound(src, 'sound/voice/mob/pain/male/passive_whiner_4.ogg', VOL_EFFECTS_MASTER)//звук поджопника
			else if(isloyal(user) || isloyal(target))
				playsound(src, 'sound/voice/mob/pain/female/passive_whiner_4.ogg', VOL_EFFECTS_MASTER)//элитный поджопник
		if(BP_L_ARM)	// need paralaze_arm or fake_break_arm
			hand_item = target.l_hand
			if(hand_item && (user.a_intent == INTENT_PUSH))
				target.drop_l_hand() // else not work
				hand_item.throw_at(throw_target, fisto_setting ** 2 , 1)

		if(BP_R_ARM)
			hand_item = target.r_hand
			if(hand_item && (INTENT_PUSH == user.a_intent))
				target.drop_r_hand()
				hand_item.throw_at(throw_target, fisto_setting ** 2 , 1)
		if(BP_L_LEG)
			target.crawling = TRUE  // need paralaze_leg or fake_break_leg
		if(BP_R_LEG)
			target.crawling = TRUE

	var/success = ..()
	//force = base_force

	if (success)
		target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as they punch [target.name]!</span>",
								"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
		new /obj/item/effect/kinetic_blast(target.loc)
		playsound(src, 'sound/weapons/guns/resonator_blast.ogg', VOL_EFFECTS_MASTER)
		playsound(src, 'sound/weapons/genhit2.ogg', VOL_EFFECTS_MASTER)

		if(agony > 0)
			target.apply_effect(agony, AGONY)

		return TRUE
	return FALSE

/obj/item/weapon/melee/powerfist/update_icon()
	icon_state = "powerfist_[fisto_setting]"

/obj/item/weapon/melee/powerfist/with_tank/atom_init()
	. = ..()
	var/obj/item/weapon/tank/oxygen/new_tank = new(src)
	tank = new_tank

#undef POWERFIST_MIN_PRESSURE
