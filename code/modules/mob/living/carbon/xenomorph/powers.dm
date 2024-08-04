#define ALREADY_STRUCTURE_THERE(user) (locate(/obj/structure/alien/air_plant) in get_turf(user))      || (locate(/obj/structure/alien/egg) in get_turf(user)) \
                             || (locate(/obj/structure/mineral_door/resin) in get_turf(user))   || (locate(/obj/structure/alien/resin/wall) in get_turf(user)) \
                             || (locate(/obj/structure/alien/resin/membrane) in get_turf(user)) || (locate(/obj/structure/stool/bed/nest) in get_turf(user))

#define CHECK_WEEDS(user) (locate(/obj/structure/alien/weeds) in get_turf(user))

/mob/living/carbon/xenomorph/proc/check_enough_plasma(cost)
	if(getPlasma() < cost)
		return FALSE
	return TRUE

//----------------------------------------------
//-----------------Plant Weeds------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/weeds
	name = "Plant Weeds"
	desc = "Plants some alien weeds."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "plant_weeds"
	plasma_cost = 50
	sound = 'sound/effects/resin_build.ogg'

/obj/effect/proc_holder/spell/no_target/weeds/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(locate(/obj/structure/alien/weeds/node) in get_turf(user))
		if(try_start)
			to_chat(user, "<span class='warning'>There is already a weed's node.</span>")
		return FALSE
	if(!isturf(user.loc) || isspaceturf(user.loc))
		if(try_start)
			to_chat(user, "<span class='warning'>Bad place for a garden!</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/no_target/weeds/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/xenomorph/alien = user
	alien.adjustToxLoss(-plasma_cost)
	user.visible_message("<span class='notice'><B>[user]</B> has planted some alien weeds.</span>", "<span class='notice'>You plant some alien weeds.</span>")
	new /obj/structure/alien/weeds/node(user.loc)

//----------------------------------------------
//-----------------Lay Egg----------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "lay_egg"
	plasma_cost = 75
	sound = 'sound/effects/resin_build.ogg'

/obj/effect/proc_holder/spell/no_target/lay_egg/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(ALREADY_STRUCTURE_THERE(user))
		if(try_start)
			to_chat(user, "<span class='warning'>There is already a structure there.</span>")
		return FALSE
	if(!CHECK_WEEDS(user))
		if(try_start)
			to_chat (user, "<span class='warning'>You can lay egg on weeds only.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/no_target/lay_egg/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/xenomorph/alien = user
	alien.adjustToxLoss(-plasma_cost)
	user.visible_message("<span class='notice'><B>[user] has laid an egg!</B></span>")
	new /obj/structure/alien/egg(user.loc)

//----------------------------------------------
//-----------Plant Air Generator----------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/air_plant
	name = "Plant Air Generator"
	desc = "Plant an air regenerating plant."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "air_plant"
	plasma_cost = 200
	sound = 'sound/effects/resin_build.ogg'

/obj/effect/proc_holder/spell/no_target/air_plant/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(ALREADY_STRUCTURE_THERE(user))
		if(try_start)
			to_chat(user, "<span class='warning'>There is already a structure there.</span>")
		return FALSE
	if(!CHECK_WEEDS(user))
		if(try_start)
			to_chat (user, "<span class='warning'>You can only build on weeds.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/no_target/air_plant/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/xenomorph/alien = user
	alien.adjustToxLoss(-plasma_cost)
	user.visible_message("<span class='notice'><B>[user]</B> has planted some alien weeds.</span>", "<span class='notice'>You plant some alien weeds.</span>")
	new /obj/structure/alien/air_plant(user.loc)

//----------------------------------------------
//-----------------Whisper----------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/targeted/xeno_whisp
	name = "Whisper"
	desc = "Whisper to someone."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "xeno_whisper"
	plasma_cost = 10
	range = 7
	var/msg = ""

/obj/effect/proc_holder/spell/targeted/xeno_whisp/before_cast(list/targets, mob/user)
	msg = sanitize(input("Message:", "Alien Whisper") as text|null)

/obj/effect/proc_holder/spell/targeted/xeno_whisp/invocation(mob/user = usr)
	if(!msg)
		return	//do not play sound if there is no message
	..()

/obj/effect/proc_holder/spell/targeted/xeno_whisp/cast(list/targets, mob/user = usr)
	if(!msg)
		return
	var/mob/living/carbon/xenomorph/alien = user
	alien.adjustToxLoss(-plasma_cost)
	var/mob/living/M = targets[1]
	log_say("AlienWhisper: [key_name(user)]->[key_name(M)] : [msg]")
	to_chat(M, "<span class='noticealien'>You hear a strange, alien voice in your head... <I>[msg]</I></span>")
	to_chat(user, "<span class='noticealien'>You said: \"<I>[msg]</I>\" to [M]</span>")
	msg = ""

//----------------------------------------------
//---------------Transfer Plasma----------------
//----------------------------------------------

/obj/effect/proc_holder/spell/targeted/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfer Plasma to another alien."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "transfer_plasma"
	range = 1
	plasma_cost = 0	//How much plasma to transfer?

/obj/effect/proc_holder/spell/targeted/transfer_plasma/before_cast(list/targets, mob/user)
	var/mob/living/M = targets[1]
	if(!isxeno(M))
		to_chat(user, "<span class='warning'>You can only transfer plasma to xenomorphs.</span>")
		return
	var/amount = input("Amount:", "Transfer Plasma to [M]") as num
	if(amount)
		var/mob/living/carbon/xenomorph/alien = user
		if(!alien.check_enough_plasma(amount))
			to_chat(user, "<span class='warning'>Not enough plasma stored.</span>")
			return
		plasma_cost = abs(round(amount))

/obj/effect/proc_holder/spell/targeted/transfer_plasma/cast(list/targets, mob/user = usr)
	if(!plasma_cost)
		return
	var/mob/living/carbon/xenomorph/M = targets[1]
	if(get_dist(user, M) <= 1)
		var/mob/living/carbon/xenomorph/alien = user
		alien.adjustToxLoss(-plasma_cost)
		M.adjustToxLoss(plasma_cost)
		to_chat(M, "<span class='noticealien'>[user] has transfered [plasma_cost] plasma to you.</span>")
		to_chat(user, "<span class='noticealien'>You have transfered [plasma_cost] plasma to [M]</span>")
	else
		to_chat(user, "<span class='warning'>You need to be closer.</span>")
	plasma_cost = 0

//----------------------------------------------
//-------------------Screech--------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/targeted/screech
	name = "Screech!"
	desc = "Emit a screech that stuns prey."
	charge_max = 900
	charge_type = "recharge"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	range = 7
	max_targets = 0	//unlimited
	plasma_cost = 200
	action_icon_state = "queen_screech"
	sound = 'sound/voice/xenomorph/queen_roar.ogg'

/obj/effect/proc_holder/spell/targeted/screech/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/xenomorph/humanoid/alien = user
	alien.adjustToxLoss(-plasma_cost)
	alien.create_shriekwave(shriekwaves_left = 15)
	for(var/mob/living/L as anything in targets)
		if(L.stat == DEAD || isxeno(L) || L.flags & GODMODE)
			continue
		if(!ishuman(L))
			to_chat(L, "<span class='danger'>You feel strong vibrations.</span>")
			L.Stun(2)
			continue
		var/mob/living/carbon/human/H = L
		if(H.sdisabilities & DEAF || istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
			to_chat(H, "<span class='danger'>You feel strong vibrations and quiet noise...</span>")
			H.Stun(2)
			continue
		if(H.species.flags[NO_BREATHE] || H.species.flags[NO_PAIN]) // so IPCs, dioneae, abductors, skeletons, zombies, shadowlings, golems and vox armalis get less debuffs
			to_chat(H, "<span class='danger'>You feel strong vibrations and loud noise, but you're strong enough to stand it!</span>")
			H.Stun(2)
			continue

		to_chat(H, pick("<font color='red' size='7'>RRRRRRAAAAAAAAAAAAAAAAAAGHHHHHH! MY EA-A-ARS! ITS TOO LO-O-O-O-O-O-UD! NGGGHHHHHHH!</font>", "<font color='red' size='7'>VVNNNGGGGHHHHHHH! MY EARS! ITS TOO LOUD! HHHHHHOOO!</font>"))
		H.SetSleeping(0)
		H.AdjustStuttering(20)
		H.Weaken(3)
		if(prob(30)) // long stun
			H.playsound_local(null, 'sound/effects/mob/earring_30s.ogg', VOL_EFFECTS_MASTER)
			H.Stun(10)
			H.ear_deaf += 30
			if(H.stat == CONSCIOUS) // human is trying to yell and hear themselve.
				H.visible_message("<B>[H.name]</B> falls to their [pick("side", "knees")], covers their [pick("head", "ears")] and [pick("shrivels their face in agony", "it looks like screams loud")]!", "<span class='warning'>You're trying to scream in hopes of hearing your voice...</span>")
				if(H.gender == FEMALE)
					H.playsound_local(null, 'sound/effects/mob/earring_yell_female.ogg', VOL_EFFECTS_MASTER)
				else
					H.playsound_local(null, 'sound/effects/mob/earring_yell_male.ogg', VOL_EFFECTS_MASTER)
			H.Paralyse(4)
		else // short stun
			H.ear_deaf += 15
			H.playsound_local(null, 'sound/effects/mob/earring_15s.ogg', VOL_EFFECTS_MASTER)
			H.Stun(5)
			H.Paralyse(2)

//----------------------------------------------
//----------------Secrete Resin-----------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "secrete_resin"
	sound = 'sound/effects/resin_build.ogg'
	plasma_cost = 75
	var/build_name = null
	var/static/list/builds_image
	var/list/buildings = list("resin door" = /obj/structure/mineral_door/resin,
							"resin wall" = /obj/structure/alien/resin/wall,
							"resin membrane" = /obj/structure/alien/resin/membrane,
							"resin nest" = /obj/structure/stool/bed/nest)

/obj/effect/proc_holder/spell/no_target/resin/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(ALREADY_STRUCTURE_THERE(user))
		if(try_start)
			to_chat(user, "<span class='warning'>There is already a structure there.</span>")
		return FALSE
	if(!CHECK_WEEDS(user))
		if(try_start)
			to_chat (user, "<span class='warning'>You can only build on weeds.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/no_target/resin/before_cast(list/targets, mob/user)
	if(!builds_image)
		builds_image = list()
		for(var/name in buildings)
			var/obj/type = buildings[name]
			builds_image[name] = image(icon = initial(type.icon), icon_state = initial(type.icon_state))

	var/choice = show_radial_menu(user, user, builds_image, tooltips = TRUE)
	if(!choice)
		return
	if(!do_after(user, 4 SECONDS, target = user))
		return
	build_name = choice

/obj/effect/proc_holder/spell/no_target/resin/invocation(mob/user = usr)
	if(!build_name)
		return
	..()

/obj/effect/proc_holder/spell/no_target/resin/cast(list/targets, mob/user = usr)
	if(!build_name)
		return
	if(!cast_check())
		return
	var/mob/living/carbon/xenomorph/humanoid/alien = user
	alien.adjustToxLoss(-plasma_cost)
	user.visible_message("<span class='notice'><B>[user]</B> vomits up a thick purple substance and begins to shape it.</span>", "<span class='notice'>You shape a [build_name].</span>")
	var/type = buildings[build_name]
	new type(user.loc)
	build_name = null

//----------------------------------------------
//---------------------Hide---------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/hide
	name = "Спрятаться"
	desc = "Позволяет прятаться под столами и другими предметами. Включается и отключается."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "xeno_hide"

/obj/effect/proc_holder/spell/no_target/hide/cast(list/targets, mob/user = usr)
	if (user.layer != TURF_LAYER+0.2)
		user.layer = TURF_LAYER+0.2
		user.visible_message("<span class='danger'>[user] исчезает.</span>", "<span class='notice'>Сейчас вы прячетесь.</span>")
	else
		user.layer = MOB_LAYER
		user.visible_message("<span class='warning'>[user] появляется.</span>", "<span class='notice'>Вы больше не прячетесь.</span>")

//----------------------------------------------
//---------------Drone Evolve-------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/evolve_to_queen
	name = "Evolve"
	desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	plasma_cost = 500
	action_icon_state = "drone_evolve"

/obj/effect/proc_holder/spell/no_target/evolve_to_queen/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(!isturf(user.loc))
		if(try_start)
			to_chat(user, "<span class='warning'>You cannot evolve when you are inside something.</span>")
		return FALSE
	var/no_queen = TRUE
	for(var/mob/living/carbon/xenomorph/humanoid/queen/Q as anything in alien_list[ALIEN_QUEEN])
		if(Q.stat == DEAD || !Q.key)
			continue
		no_queen = FALSE
	if(!no_queen)
		if(try_start)
			to_chat(user, "<span class='notice'>We already have an alive queen.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/no_target/evolve_to_queen/cast(list/targets, mob/user = usr)
	to_chat(user, "<span class='notice'>You begin to evolve!</span>")
	user.visible_message("<span class='notice'><B>[user] begins to twist and contort!</B></span>")
	if(!do_after(user, 10 SECONDS, target = user))
		return
	var/mob/living/carbon/xenomorph/humanoid/alien = user
	alien.adjustToxLoss(-plasma_cost)
	var/mob/living/carbon/xenomorph/humanoid/queen/new_xeno = new (user.loc)
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.real_name

	var/datum/faction/infestation/F = find_faction_by_type(/datum/faction/infestation)//Buff only for the first queen
	if(F.start_help)
		new_xeno.apply_status_effect(/datum/status_effect/young_queen_buff)
		F.start_help = FALSE

	qdel(alien)

//----------------------------------------------
//---------------Larva Evolve-------------------
//----------------------------------------------

/obj/effect/proc_holder/spell/no_target/larva_evolve
	name = "Эволюция"
	desc = "Превратиться во взрослого ксеноморфа."
	charge_max = 0
	charge_type = "none"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcomm_cancast = FALSE
	action_background_icon_state = "bg_alien"
	action_icon_state = "alien_evolve_larva"
	var/list/castes = list("Охотник" = /mob/living/carbon/xenomorph/humanoid/hunter,
							"Страж" = /mob/living/carbon/xenomorph/humanoid/sentinel,
							"Трутень" = /mob/living/carbon/xenomorph/humanoid/drone)

/obj/effect/proc_holder/spell/no_target/larva_evolve/cast_check(skipcharge = FALSE, mob/user = usr, try_start = TRUE)
	if(!isturf(user.loc))
		if(try_start)
			to_chat(user, "<span class='warning'>Вы не можете эволюционировать, когда находитесь внутри чего-то.</span>")
		return FALSE
	var/mob/living/carbon/xenomorph/larva/larva = user
	if(larva.amount_grown < larva.max_grown)
		if(try_start)
			to_chat(user, "<span class='warning'>Вы еще не выросли.</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/no_target/larva_evolve/cast(list/targets, mob/user = usr)
	var/queen = FALSE
	var/drone = FALSE
	for(var/mob/living/carbon/xenomorph/humanoid/queen/Q as anything in alien_list[ALIEN_QUEEN])
		if(Q.stat == DEAD || !Q.key)
			continue
		queen = TRUE
	for(var/mob/living/carbon/xenomorph/A as anything in alien_list[ALIEN_DRONE])
		if(A.stat == DEAD || !A.key)
			continue
		drone = TRUE
		break	//we don't care how many drones there are

	var/evolve_now = null
	var/chosen_caste = null
	if(!queen && !drone)
		evolve_now = tgui_alert(user, "Сейчас вы можете превратиться только в трутня, так как среди ксеноморфов нет в живых ни одного трутня либо королевы.", "Улей в опасности!", list("Быть Трутнем", "Отмена"))
		if(evolve_now == "Отмена")
			return
		chosen_caste = "Трутень"
	else
		evolve_now = tgui_alert(user, "Вы уверены что хотите сейчас эволюционировать?",, list("Да","Нет"))
		if(evolve_now == "Нет")
			return
		to_chat(user, {"<br><span class='notice'><b>Вы превращаетесь во взрослого ксеноморфа! Пора выбрать одну из трех каст:</b></span>
		<B>Охотники</B> <span class='notice'>- сильны и подвижны, способны охотиться вдали от улья и быстро перемещаться по вентиляционным шахтам. Охотники производят плазму медленно и имеют небольшие запасы.</span>
		<B>Стражи</B> <span class='notice'>- защитники улья, и они смертельно опасны как вблизи, так и на расстоянии. Менее подвижны, чем охотники, но имеют большие запасы плазмы.</span>
		<B>Трутни</B> <span class='notice'>- рабочий класс, они обустраивают улей, быстро производят плазму и имеют самый большой её запас. Только трутни могут стать королевой ксеноморфов.</span><br>"})

		var/list/alien_image = list()
		for(var/caste in castes)
			var/mob/A = castes[caste]
			alien_image[caste] = image(icon = initial(A.icon), icon_state = initial(A.icon_state))

		chosen_caste = show_radial_menu(user, user, alien_image, tooltips = TRUE)
		if(!chosen_caste)
			return

	to_chat(user, "<span class='alien'>Подождите пока закончится процесс эволюции.</span>")
	if(!do_after(user, 10 SECONDS, target = user))
		return

	var/mob/living/carbon/xenomorph/humanoid/alien = castes[chosen_caste]
	var/mob/new_xeno = new alien(user.loc)
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.real_name
	qdel(user)

/obj/effect/proc_holder/spell/no_target/xenowinds
	name = "Эмиссия форона"
	desc = "Выпустить небольшое облачко накопленного форона."
	charge_max = 1200
	charge_type = "recharge"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	action_background_icon_state = "bg_alien"
	plasma_cost = 120
	action_icon_state = "rot"

/obj/effect/proc_holder/spell/no_target/xenowinds/cast(list/targets, mob/living/user = usr)
	if(!istype(user))
		return
	var/turf/T = get_turf(user)
	user.visible_message("<span class='warning'><B>[user]</B> emits faint purple cloud.</span>", "<span class='notice'>You let some phoron out.</span>")
	user.adjustToxLoss(-plasma_cost)
	T.assume_gas("phoron", 25, user.bodytemperature) // give 25 moles of phoron (approx. 0.25% of air in room like Bar)

#undef ALREADY_STRUCTURE_THERE
#undef CHECK_WEEDS
