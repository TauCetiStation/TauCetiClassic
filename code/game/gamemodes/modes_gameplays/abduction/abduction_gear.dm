#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2


//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with mind influence stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_combat"
	item_state = "armor"
	blood_overlay_type = "armor"
	origin_tech = "materials=5;biotech=4;powerstorage=5"
	item_action_types = list(/datum/action/item_action/hands_free/activate_vest)
	var/combat_cooldown = 10
	var/datum/icon_snapshot/disguise
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 50, rad = 50)

/datum/action/item_action/hands_free/activate_vest
	name = "Activate Vest"

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/AbductorCheck(mob/user)
	if(isabductor(user))
		return TRUE
	to_chat(user, "<span class='notice'>You can't figure how this works.</span>")
	return FALSE

/obj/item/clothing/suit/armor/abductor/vest/attack_self(mob/user)
	if(!AbductorCheck(user))
		return
	if(!isabductoragent(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	Adrenaline()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(src.loc))
		if(combat_cooldown != initial(combat_cooldown))
			to_chat(src.loc, "<span class='warning'>Combat injection is still recharging.</span>")
		var/mob/living/carbon/human/M = src.loc
		M.stat = CONSCIOUS
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
//		M.adjustStaminaLoss(-75)
		combat_cooldown = 0
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/vest/process()
	combat_cooldown++
	if(combat_cooldown == initial(combat_cooldown))
		STOP_PROCESSING(SSobj, src)


//SCIENCE TOOL
/obj/item/device/abductor/proc/AbductorCheck(mob/user)
	if(isabductor(user))
		return TRUE
	to_chat(user, "<span class='notice'>You can't figure how this works.</span>")
	return FALSE

/obj/item/device/abductor/gizmo
	name = "science tool"
	desc = "A dual-mode tool for retrieving specimens and scanning appearances. Scanning can be done through cameras."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gizmo_scan"
	item_state = "gizmo"
	origin_tech = "materials=5;programming=5;bluespace=6"
	var/mode = GIZMO_SCAN
	var/obj/machinery/abductor/console/console
	var/mob/living/marked = null

/obj/item/device/abductor/gizmo/attack_self(mob/user)
	if(!AbductorCheck(user))
		return
	if(!isabductorsci(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
		icon_state = "gizmo_mark"
	else
		mode = GIZMO_SCAN
		icon_state = "gizmo_scan"
	to_chat(user, "<span class='notice'>You switch the device to [mode==GIZMO_SCAN? "SCAN": "MARK"] MODE</span>")

/obj/item/device/abductor/gizmo/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	if(!isabductorsci(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	switch(mode)
		if(GIZMO_SCAN)
			scan(M, user)
		if(GIZMO_MARK)
			mark(M, user)


/obj/item/device/abductor/gizmo/afterattack(atom/target, mob/user, proximity, params)
	if(proximity)
		return
	if(!AbductorCheck(user))
		return
	if(!isabductorsci(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	if(!ismob(target))
		return
	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/device/abductor/gizmo/proc/scan(atom/target, mob/living/user)
	if(ishuman(target))
		if(console != null)
			console.AddSnapshot(target)
			to_chat(user, "<span class='notice'>You scan [target] and add them to the database.</span>")

/obj/item/device/abductor/gizmo/proc/mark(mob/target, mob/living/user)
	if(marked == target)
		to_chat(user, "<span class='notice'>This specimen is already marked.</span>")
		return
	if(isabductor(target) || istype(target, /mob/living/simple_animal/cow))
		marked = target
		to_chat(user, "<span class='notice'>You mark [target] for future retrieval.</span>")
	else
		prepare(target, user)

/obj/item/device/abductor/gizmo/proc/prepare(atom/target, mob/living/user)
	if(get_dist(target,user) > 1)
		to_chat(user, "<span class='warning'>You need to be next to the specimen to prepare it for transport.</span>")
		return
	if(user.is_busy())
		return
	to_chat(user, "<span class='notice'>You begin preparing [target] for transport...</span>")
	if(do_after(user, 100, target = target))
		marked = target
		to_chat(user, "<span class='notice'>You finish preparing [target] for transport.</span>")


//SILENCER
/obj/item/device/abductor/silencer
	name = "abductor silencer"
	desc = "A compact device used to shut down communications equipment."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "silencer"
	item_state = "silencer"
	origin_tech = "materials=5;programming=5"

/obj/item/device/abductor/silencer/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	radio_off(M, user)

/obj/item/device/abductor/silencer/afterattack(atom/target, mob/user, proximity, params)
	if(proximity)
		return
	if(!AbductorCheck(user))
		return
	radio_off(target, user)

/obj/item/device/abductor/silencer/proc/radio_off(atom/target, mob/living/user)
	if(!(user in (viewers(7, target))))
		return

	var/turf/targloc = get_turf(target)

	var/mob/living/carbon/human/M
	for(M in view(2, targloc))
		if(M == user)
			continue
		to_chat(user, "<span class='notice'>You silence [M]'s radio devices.</span>")
		radio_off_mob(M)

/obj/item/device/abductor/silencer/proc/radio_off_mob(mob/living/carbon/human/M)
	var/list/all_items = M.get_all_contents_type(/obj/item/device/radio)

	for(var/obj/item/device/radio/R in all_items)
		R.on = 0


//RECALL IMPLANT
/obj/item/weapon/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	item_action_types = list(/datum/action/item_action/hands_free/activate_implant)
	var/obj/machinery/abductor/pad/home
	var/cooldown = 30 SECONDS

/datum/action/item_action/hands_free/activate_implant
	name = "Activate Implant"
	check_flags = AB_CHECK_INSIDE

/obj/item/weapon/implant/abductor/attack_self()
	var/turf/T = get_turf(src)
	if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
		to_chat(imp_in, "<span class='warning'>WARNING! Bluespace interference has been detected in the location, preventing teleportation! Teleportation is canceled!</span>")
		return FALSE
	if(cooldown >= initial(cooldown))
		if(imp_in.buckled)
			imp_in.buckled.unbuckle_mob()
		home.Retrieve(imp_in)
		cooldown = 0
		INVOKE_ASYNC(src, PROC_REF(start_recharge), imp_in)
	else
		to_chat(imp_in, "<span class='warning'>You must wait [(300 - cooldown) / 10] seconds to use [src] again!</span>")
	return

/obj/item/weapon/implant/abductor/proc/start_recharge(mob/user = usr)
	var/datum/action/item_action/hands_free/activate_implant/A = locate(/datum/action/item_action/hands_free/activate_implant) in item_actions
	var/atom/movable/screen/cooldown_overlay/cooldowne = start_cooldown(A.button, initial(cooldown))
	while(cooldown < initial(cooldown))
		sleep(1)
		cooldown++
		if(cooldowne)
			cooldowne.tick()
	to_chat(imp_in, "<span class='warning'>Your [name] recharged!</span>")
	qdel(cooldowne)

//ALIEN DECLONER
/obj/item/weapon/gun/energy/decloner/alien
	name = "alien weapon"
	desc = "An odd device that resembles human weapon."
	origin_tech = "materials=6;biotech=4;combat=5"
	icon_state = "alienpistol"
	item_state = "alienpistol"
	ammo_type = list(/obj/item/ammo_casing/energy/declone/light)
	item_action_types = null

/obj/item/weapon/gun/energy/decloner/alien/special_check(mob/living/carbon/human/M)
	if(M.species.name != ABDUCTOR)
		to_chat(M, "<span class='notice'>You can't figure how this works.</span>")
		return FALSE
	return TRUE

//AGENT HELMET
/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Abduct with style - spiky style. Prevents digital tracking."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	origin_tech = "materials=5;biotech=5"

	var/obj/machinery/camera/helm_cam

	item_action_types = list(/datum/action/item_action/hands_free/activate_helmet)

/datum/action/item_action/hands_free/activate_helmet
	name = "Activate Helmet"

/obj/item/clothing/head/helmet/abductor/attack_self(mob/living/carbon/human/user)
	if(!isabductor(user))
		to_chat(user, "<span class='notice'>You can't figure how this works.</span>")
		return
	if(helm_cam)
		..(user)
	else
		var/computer_detected = FALSE
		var/obj/machinery/computer/security/abductor_ag/comp
		for(var/obj/machinery/computer/security/abductor_ag/C in range(2, get_turf(src)))
			if(C.network.len < 1)
				computer_detected = TRUE
				comp = C
				break
		if(!computer_detected)
			to_chat(user, "<span class='warning'>No computers nearby. Helmet deactivated.</span>")
			return
		icon_state = "alienhelmet_a"
		item_state = "alienhelmet_a"
		update_inv_mob()
		helm_cam = new /obj/machinery/camera(src)
		helm_cam.c_tag = "[user.real_name] Cam"
		helm_cam.replace_networks(list("Abductor[comp.team]"))

		comp.network = helm_cam.network

		helm_cam.hidden = 1
		to_chat(user, "<span class='notice'>Abductor detected. Camera activated.</span>")
		update_item_actions()
		return

/obj/item/clothing/head/helmet/abductor/equipped(mob/living/user, slot)
	. = ..()
	if(slot == SLOT_HEAD)
		RegisterSignal(user, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))
	else
		UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)

/obj/item/clothing/head/helmet/abductor/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)

/obj/item/clothing/head/helmet/abductor/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK

//ADVANCED BATON
#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

/obj/item/weapon/abductor_baton
	name = "advanced baton"
	desc = "A quad-mode baton used for incapacitation and restraining of specimens."
	var/mode = BATON_STUN
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wonderprodStun"
	item_state = "wonderprod"
	origin_tech = "materials=6;combat=5;biotech=7"
	slot_flags = SLOT_FLAGS_BELT
	force = 7
	w_class = SIZE_SMALL
	var/obj/machinery/abductor/console/console
	item_action_types = list(/datum/action/item_action/hands_free/toggle_mode)

/datum/action/item_action/hands_free/toggle_mode
	name = "Toggle Mode"

/obj/item/weapon/abductor_baton/proc/toggle(mob/living/user=usr)
	if(!isabductor(user))
		return
	if(!isabductoragent(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	if(!console || !console.baton_modules_bought)
		to_chat(user, "<span class='notice'>You need additional permissions from Mothership to use other modes of [name]!</span>")
		return
	mode = (mode + 1) % BATON_MODES
	var/txt
	switch(mode)
		if(BATON_STUN)
			txt = "stunning"
		if(BATON_SLEEP)
			txt = "sleep inducement"
		if(BATON_CUFF)
			txt = "restraining"
		if(BATON_PROBE)
			txt = "probing"

	to_chat(user, "<span class='notice'>You switch the baton to [txt] mode.</span>")
	update_icon()
	update_inv_mob()
	update_item_actions()

/obj/item/weapon/abductor_baton/update_icon()
	switch(mode)
		if(BATON_STUN)
			icon_state = "wonderprodStun"
			item_state = "wonderprodStun"
		if(BATON_SLEEP)
			icon_state = "wonderprodSleep"
			item_state = "wonderprodSleep"
		if(BATON_CUFF)
			icon_state = "wonderprodCuff"
			item_state = "wonderprodCuff"
		if(BATON_PROBE)
			icon_state = "wonderprodProbe"
			item_state = "wonderprodProbe"

/obj/item/weapon/abductor_baton/attack(mob/target, mob/living/user)
	if(!isabductor(user))
		return

	if(isrobot(target))
		..()
		return

	if(!isliving(target))
		return

	var/mob/living/L = target

	user.do_attack_animation(L)
	switch(mode)
		if(BATON_STUN)
			StunAttack(L,user)
		if(BATON_SLEEP)
			SleepAttack(L,user)
		if(BATON_CUFF)
			CuffAttack(L,user)
		if(BATON_PROBE)
			ProbeAttack(L,user)

/obj/item/weapon/abductor_baton/attack_self(mob/living/user)
	toggle(user)

/obj/item/weapon/abductor_baton/proc/StunAttack(mob/living/L,mob/living/user)
	L.set_lastattacker_info(user)

	L.Stun(7)
	L.Weaken(7)
	L.apply_effect(STUTTER, 7)

	L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
							"<span class='userdanger'>[user] has stunned you with [src]!</span>")
	playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)

	L.log_combat(user, "stunned with <b>[name]</b>")
	return

/obj/item/weapon/abductor_baton/proc/SleepAttack(mob/living/L,mob/living/user)
	if(L.stunned)
		L.SetSleeping(120 SECONDS)
	L.visible_message("<span class='danger'>[user] has induced sleep in [L] with [src]!</span>", \
							"<span class='userdanger'>You suddenly feel very drowsy!</span>")
	playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)

	L.log_combat(user, "put to sleep with \a [src]")
	return

/obj/item/weapon/abductor_baton/proc/CuffAttack(mob/living/L,mob/living/user)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/C = L
	if(!C.handcuffed)
		playsound(src, 'sound/weapons/cablecuff.ogg', VOL_EFFECTS_MASTER, 30)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with [src]!</span>", \
								"<span class='userdanger'>[user] begins shaping an energy field around your hands!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.equip_to_slot_or_del(new /obj/item/weapon/handcuffs/alien, SLOT_HANDCUFFED)
				to_chat(user, "<span class='notice'>You handcuff [C].</span>")
				L.log_combat(user, "handcuffed with \a [src]")
		else
			to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")
	return

/obj/item/weapon/abductor_baton/proc/ProbeAttack(mob/living/L,mob/living/user)
	var/species = "<span class='warning'>Unknown species</span>"
	var/gland = "<span class='warning'>Experimental gland <span class='danger'>wasn't</span> detected!</span>"

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		species = "<span class='notice'>[H.species.name]</span>"
		if(ischangeling(L))
			species = "<span class='warning'> Changeling lifeform</span>"
		var/obj/item/gland/temp = locate() in H
		if(temp)
			gland = "<span class='warning'>Experimental gland detected!</span>"

	to_chat(user, "<span class='notice'>Probing result:[species]</span>")
	to_chat(user, "[gland]")
	L.visible_message("<span class='danger'>[user] probes [L] with [src]!</span>", \
						"<span class='userdanger'>[user] probes you!</span>")

/obj/item/weapon/abductor_baton/examine(mob/user)
	..()
	switch(mode)
		if(BATON_STUN)
			to_chat(user, "<span class='warning'>The baton is in stun mode.</span>")
		if(BATON_SLEEP)
			to_chat(user, "<span class='warning'>The baton is in sleep inducement mode.</span>")
		if(BATON_CUFF)
			to_chat(user, "<span class='warning'>The baton is in restraining mode.</span>")
		if(BATON_PROBE)
			to_chat(user, "<span class='warning'>The baton is in probing mode.</span>")


//HANDCUFFS
/obj/item/weapon/handcuffs/alien
	name = "hard-light energy field"
	desc = "A hard-light field restraining the hands."
	icon_state = "handcuffAlien"
	origin_tech = "materials=5;combat=4;powerstorage=5"
	breakouttime = 450

/obj/item/weapon/handcuffs/alien/place_handcuffs()
	. = ..()
	if(.)
		flags = DROPDEL // no CONDUCT

// SURGICAL INSTRUMENTS
/obj/item/weapon/scalpel/alien
	name = "alien scalpel"
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.3

/obj/item/weapon/hemostat/alien
	name = "alien hemostat"
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.3

/obj/item/weapon/retractor/alien
	name = "alien retractor"
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.3

/obj/item/weapon/circular_saw/alien
	name = "alien saw"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "saw"
	toolspeed = 0.3

/obj/item/weapon/surgicaldrill/alien
	name = "alien drill"
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.3

/obj/item/weapon/cautery/alien
	name = "alien cautery"
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.3


// OPERATING TABLE / BEDS / LOCKERS	/ OTHER
/obj/machinery/optable/abductor
	name = "alien optable"
	desc = "Used for experiments on creatures."
	icon = 'icons/obj/abductor.dmi'
	var/holding = FALSE
	var/belt = null
	var/mob/living/carbon/fastened = null

/obj/machinery/optable/abductor/atom_init()
	belt = image("icons/obj/abductor.dmi", "belt", layer = FLY_LAYER)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/operating_table/abductor(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/adv/phasic/triphasic(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/adv/phasic/triphasic(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor/adv/super/quadratic(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()
/obj/machinery/optable/abductor/attack_hand(mob/living/carbon/C)
	if(!victim && !fastened)
		return

	//exclusion any bugs with grab
	if(!istype(C))
		return
	C.SetNextMove(CLICK_CD_MELEE)
	C.StopGrabs()

	holding = !holding

	var/atom/movable/overlay/animation = new /atom/movable/overlay(src.loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/obj/abductor.dmi'
	animation.layer = FLY_LAYER

	if(holding)
		fastened = victim
		//correction position of victim
		switch(fastened.lying_current)
			if(90)
				if(fastened.pixel_x != 2)
					fastened.pixel_x = 2
				animation.set_dir(2)
				set_dir(2)
			else
				if(fastened.pixel_x != -2)
					fastened.pixel_x = -2
				animation.set_dir(1)
				set_dir(1)
		if(fastened.pixel_y != -4)
			fastened.pixel_y = -4
		if(fastened.dir & (EAST|WEST|NORTH))
			fastened.set_dir(SOUTH)

		flick("belt_anim_on",animation)
		sleep(7)
		add_overlay(belt)
		fastened.anchored = TRUE
		fastened.SetStunned(INFINITY)
		fastened.can_be_pulled = FALSE
		qdel(animation)
	else
		cut_overlay(belt)
		switch(fastened.lying_current)
			if(90)	animation.set_dir(2)
			else	animation.set_dir(1)
		flick("belt_anim_off",animation)
		sleep(9)
		fastened.SetStunned(0)
		fastened.anchored = FALSE
		fastened.can_be_pulled = TRUE
		fastened = null
		qdel(animation)

/obj/structure/stool/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"

/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/abductor_table.dmi'
	flipable = FALSE // Fuck this shit, I am out...

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state  = "abductor"
	icon_opened = "abductoropen"
	icon_closed = "abductor"

/obj/item/weapon/bonegel/alien
	name = "alien ectoplasm"
	desc = "Contains ecotplasm. In the case of ingestion can cause to stomach pains."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "ectoplasm"

/obj/item/weapon/paper/abductor
	name = "Dissection Guide"
	icon_state = "alienpaper_words"
	info = {"<b>Препарирование для Чайников!</b><br>
<br>
 1.Добудьте свежую особь.<br>
 2.Положите особь на операционный стол.<br>
 3.Включите хирургические фиксаторы стола и выполните приготовления к операции.<br>
 4.Сделайте надрез скальпелем в области груди особи.<br>
 5.Остановите кровотечение с помощью щипцов.<br>
 6.Раскройте надрез хирургическим зажимом.<br>
 7.Вскройте грудную клетку пилой и раскройте с помощью щипцов.<br>
 8.Сделайте небольшое углубление во внутренностях особи дрелью. Это не так плохо для субъекта, как звучит.<br>
 9.Поместите внутрь разреза гланду. (Их можно получить в раздатчике гланд.)<br>
 10.Закройте вскрытую грудную клетку субъекта, замажьте гелем или эктоплазмой и прижгите рану.<br>
 11.Оденьте особь, чтобы не потревожить среду обитания.<br>
 12.Поместите субъект в устройство для экспериментов.<br>
 13.Выберите одну из настроек устройства и следуйте показанным там инструкциям.<br>
<br>
Поздравляем! Теперь вы почти настоящий ксенобиолог!"}

/obj/item/weapon/paper/abductor/atom_init()
	. = ..()
	verbs -= /obj/item/weapon/paper/verb/crumple

/obj/item/weapon/paper/abductor/update_icon()
	return

/obj/item/weapon/lazarus_injector/alien
	name = "heal injector"
	desc = "Everyone has second chance. One use only."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "abductor_hypo"

/obj/item/weapon/lazarus_injector/alien/revive(mob/living/target, mob/living/user)
	target.revive()
	loaded = FALSE
	user.visible_message("<span class='notice'>[user] injects [target] with [src], fully heal it.</span>")
	playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
	icon_state = "abductor_empty"

/obj/machinery/recharger/wallcharger/alien
	icon = 'icons/obj/abductor.dmi'
