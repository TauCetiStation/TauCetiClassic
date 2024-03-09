//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150
#define CLONE_INITIAL_DAMAGE     190    //Clones in clonepods start with 190 cloneloss damage and 190 brainloss damage, thats just logical


/obj/machinery/clonepod
	anchored = TRUE
	name = "cloning pod"
	cases = list("капсула клонирования", "капсулы клонирования", "капсуле клонирования", "капсулу клонирования", "капсулой клонирования", "капсуле клонирования" )
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	allowed_checks = ALLOWED_CHECK_NONE
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/biomass = CLONE_BIOMASS * 3
	var/speed_coeff
	var/efficiency
	light_color = "#00ff00"

/obj/machinery/clonepod/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonepod(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/clonepod/RefreshParts()
	..()

	speed_coeff = 0
	efficiency = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = (efficiency * 15) + 10
	if(heal_level > 100)
		heal_level = 100

//Find a dead mob with a brain and client.
/proc/find_dead_player(find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/M in player_list)
		//Dead people only thanks!
		if((M.stat != DEAD) || (!M.client))
			continue
		//They need a brain!
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.has_brain())
				continue
		//They must return in the body
		else if(isobserver(M))
			var/mob/dead/observer/O = M
			if(!O.can_reenter_corpse)
				continue

		if(M.ckey == find_key)
			selected = M
			break

	return selected

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	cases = list("имплант здоровья", "импланта здоровья", "импланту здоровья", "имплант здоровья", "имплантом здоровья", "импланте здоровья")
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if (!src.implanted)
		return "ERROR"
	else
		if(isliving(src.implanted))
			var/mob/living/L = src.implanted
			src.healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if (!src.healthstring)
			src.healthstring = "ERROR"
		return src.healthstring

/obj/machinery/clonepod/examine(mob/user)
	if(..(user, 3))
		if ((isnull(occupant)) || (stat & NOPOWER))
			return
		if ((!isnull(occupant)) && (occupant.stat != DEAD))
			var/completion = (100 * ((occupant.health + 100) / (heal_level + 100)))
			to_chat(user, "Воссоздание клона завершено на [round(completion)]%.")

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(datum/dna2/record/R)
	if(panel_open)
		return FALSE
	if(mess || attempting)
		return FALSE
	var/datum/mind/clonemind = locate(R.mind)
	if(!istype(clonemind, /datum/mind)) //not a mind
		return FALSE
	if(clonemind.current && clonemind.current.stat != DEAD) //mind is associated with a non-dead body
		return FALSE
	if(clonemind.active) //somebody is using that mind
		if(ckey(clonemind.key) != R.ckey )
			return FALSE

	src.attempting = TRUE //One at a time!!
	src.locked = TRUE

	src.eject_wait = TRUE
	spawn(30)
		src.eject_wait = FALSE

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name) //to prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name

	src.icon_state = "pod_1"
	//Get the clone body ready
	H.adjustCloneLoss(CLONE_INITIAL_DAMAGE) //Yeah, clones start with very low health, not with random, because why would they start with random health
	H.adjustBrainLoss(CLONE_INITIAL_DAMAGE)
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	clonemind.transfer_to(H)
	H.ckey = R.ckey
	to_chat(H, "<span class='notice'><b>Разум медленно возвращается в ваше регенерирующее тело...</b><br><i>Так вот, как ощущается клонирование...</i></span>")

	for(var/V in R.quirks)
		new V(H)

	// -- Mode/mind specific stuff goes here
	if(global.cult_religion)
		if(occupant.mind in global.cult_religion.members_minds)
			global.cult_religion.add_member(occupant, occupant.mind.holy_role)

	// -- End mode specific stuff

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna = R.dna
	H.UpdateAppearance()
	//if(efficiency > 2)
	//	for(var/A in bad_se_blocks)
	//		setblock(H.dna.struc_enzymes, A, construct_block(0,2))
	if(efficiency > 5 && prob(20))
		randmutg(H)
	if(efficiency < 3 && prob(50))
		randmutb(H)
	H.dna.UpdateSE()
	H.dna.UpdateUI()

	H.f_style = "Shaved"
	if(R.dna.species == HUMAN) //no more xenos losing ears/tentacles
		H.h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
	H.suiciding = FALSE
	src.attempting = FALSE
	return TRUE

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()

	if(stat & NOPOWER) //Autoeject if power is lost
		if (src.occupant)
			src.locked = 0
			go_out()
		return

	if((src.occupant) && (src.occupant.loc == src))

		if((src.occupant.stat == DEAD) || (src.occupant.suiciding) || !occupant.key)  //Autoeject corpses and suiciding dudes.
			src.locked = 0
			go_out()
			connected_message("Клон отбракован: мёртв.")
			return

		else if(src.occupant.cloneloss > (100 - src.heal_level))
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-((speed_coeff/2)))

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-((speed_coeff/2)))

			//So clones don't die of oxyloss in a running pod.
			if (occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				occupant.reagents.add_reagent("inaprovaline", 60)

			//So clones will remain asleep for long enough to get them into cryo (Bay RP edit)
			if (occupant.reagents.get_reagent_amount("stoxin") < 10)
				occupant.reagents.add_reagent("stoxin", 5)
			if (occupant.reagents.get_reagent_amount("chloralhydrate") < 1)
				occupant.reagents.add_reagent("chloralhydrate", 1)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((src.occupant.cloneloss <= (100 - src.heal_level)) && (!src.eject_wait) || src.occupant.health >= 100)
			connected_message("Процесс клонирования завершён.")
			src.locked = 0
			go_out()
			return

	else if ((!src.occupant) || (src.occupant.loc != src))
		src.occupant = null
		if (src.locked)
			src.locked = 0
		if (!src.mess && !panel_open)
			icon_state = "pod_0"
		use_power(200)
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W, mob/user)
	if(!(occupant || mess || locked))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]",W))
			return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (!check_access(W))
			to_chat(user, "<span class='danger'>Отказано в доступе.</span>")
			return
		if ((!src.locked) || (isnull(src.occupant)))
			return
		if ((src.occupant.health < -20) && (src.occupant.stat != DEAD))
			to_chat(user, "<span class='danger'>Отказано в доступе.</span>")
			return
		else
			src.locked = 0
			to_chat(user, "Система разблокирована.")
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		to_chat(user, "<span class='notice'>[CASE(src, NOMINATIVE_CASE)] обрабатывает [CASE(W, ACCUSATIVE_CASE)].</span>")
		biomass += 50
		qdel(W)
		return
	else
		..()

/obj/machinery/clonepod/emag_act(mob/user)
	if(isnull(src.occupant))
		return FALSE
	user.SetNextMove(CLICK_CD_INTERACT)
	to_chat(user, "Вы активировали экстренное извлечение.")
	src.locked = 0
	go_out()
	return TRUE

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
		return 0
	if (!message)
		return 0

	src.connected.temp = message
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(!usr)
		return
	if (usr.incapacitated())
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if (src.locked)
		return

	if (src.mess) //Clean that mess and dump those gibs!
		src.mess = 0
		gibs(src.loc)
		src.icon_state = "pod_0"
		return

	if (!(src.occupant))
		return
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.icon_state = "pod_0"
	src.eject_wait = 0 //If it's still set somehow.
	domutcheck(src.occupant) //Waiting until they're out before possible monkeyizing.
//	occupant.add_side_effect("Bad Stomach") // Give them an extra side-effect for free.
	src.occupant = null

	src.biomass -= CLONE_BIOMASS

	return

/obj/machinery/clonepod/proc/malfunction()
	if(src.occupant)
		connected_message("Критическая ошибка!")
		src.mess = 1
		src.icon_state = "pod_g"
		occupant.ghostize()
		spawn(5)
			qdel(src.occupant)
			src.occupant = null
	return

/obj/machinery/clonepod/relaymove(mob/user)
	if (user.incapacitated())
		return
	go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/(severity*efficiency))) malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A as anything in src)
		A.loc = src.loc
		ex_act(severity)
	qdel(src)

/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "Diskette Box"
	cases = list("коробка для дискет", "коробки для дискет", "коробке для дискет", "коробку для дискет", "коробкой для дискет", "коробке для дискет")
	icon_state = "disk_box"

/obj/item/weapon/storage/box/disks/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "H-87 Cloning Apparatus Manual"
	cases = list("руководство по аппарату для клонирования H-87",  "руководства по аппарату для клонирования H-87", "руководству по аппарату для клонирования H-87", "руководство по аппарату для клонирования H-87", "руководством по аппарату для клонирования H-87", "руководстве по аппарату для клонирования H-87")
	info = {"<h4>Подготовка</h4>
	Поздравляем, ваша станция приобрела промышленный аппарат клонирования H-87!<br>
	Использование H-87 такое же простое, как и нейрохирургия! Просто поместите гуманоида в капсулу, запустите сканирование и создайте новый профиль.<br>
	<b>Это всё, что нужно сделать!</b><br>
	<i>Важно отметить, что аппарат не умеет клонировать мартышек и прочих маленьких созданий, включая и неорганических. До такого мы пока не дошли. Гематомы могут привести к ошибкам в сканировании.</i><br>
	<p>Профили для клонирования можно посмотреть в специальной вкладке. При сканировании в органика вживляется специальный имплант, информацию с которого можно получить в профиле органика.
	Удаление генетического профиля возможно лишь с доступом \[глав станции\]</p>
	<h4>Клонирование из профиля</h4>
	Для клонирования, нужно нажать кнопку "Клонировать" рядом с выбранным профилем<br>
	Мы соблюдаем соглашение о неразглашении конфиденциальной информации, поэтому клонирование живых членов экипажа аппаратом H-87 невозможно.<br>
	<br>
	<p>Система капсулы для клонирования воспроизводит практически идеального клона пациента из профиля за 90 секунд.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Пожалуйста, учтите, что клоны могут обладать генетическими дефектами из-за резких перестановок ДНК.</i><br>
	<h4>Управление профилями</h4>
	<p>H-87 (а также стандартный аппарат для генетики) может принимать дискеты с генетической информацией.
	Эти дискеты используются для передачи генетической информации между аппаратами.
	Загрузка или отправка станет возможна, как вы вставите дискету в аппарат.</p><br>
	<i>Хорошая дискета - один из методов противостоять вышеописанным перестановкам ДНК!</i><br>
	<br>
	<font size=1>Продукт лицензирован компанией Thinktronic Systems, LTD.</font>"}

#undef CLONE_INITIAL_DAMAGE
