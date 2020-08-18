#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2


//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with mind influence stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state = "armor"
	blood_overlay_type = "armor"
	origin_tech = "materials=5;biotech=4;powerstorage=5"
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 15, bomb = 15, bio = 15, rad = 15)
	action_button_name = "Activate"
	action_button_is_hands_free = 1
	var/mode = VEST_STEALTH
	var/stealth_active = 0
	var/combat_cooldown = 10
	var/datum/icon_snapshot/disguise
	var/stealth_armor = list(melee = 15, bullet = 15, laser = 15, energy = 15, bomb = 15, bio = 15, rad = 15)
	var/combat_armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 50, rad = 50)

	action_button_name = "Toggle Vest"

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			armor = combat_armor
			icon_state = "vest_combat"
			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_wear_suit()
			return
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			armor = stealth_armor
			icon_state = "vest_stealth"
			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_wear_suit()
			return

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = 1
	if(ishuman(src.loc))
		var/mob/living/carbon/human/M = src.loc
		spawn(0)
			anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)
		M.name_override = disguise.name
		M.icon = disguise.icon
		M.icon_state = disguise.icon_state
		M.copy_overlays(disguise, TRUE)
		M.update_inv_r_hand()
		M.update_inv_l_hand()
	return

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = 0
	if(ishuman(src.loc))
		var/mob/living/carbon/human/M = src.loc
		spawn(0)
			anim(M.loc,M,'icons/mob/mob.dmi',,"uncloak",,M.dir)
		M.name_override = null
		M.cut_overlays()
		M.regenerate_icons()
	return

/obj/item/clothing/suit/armor/abductor/vest/attack_reaction(mob/living/L, reaction_type, mob/living/carbon/human/T = null)
	if(reaction_type == REACTION_ITEM_TAKE)
		return

	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/IsAbductor(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.name != ABDUCTOR)
			return 0
		return 1
	return 0

/obj/item/clothing/suit/armor/abductor/vest/proc/AbductorCheck(user)
	if(IsAbductor(user))
		return 1
	to_chat(user, "<span class='notice'>You can't figure how this works.</span>")
	return 0

/obj/item/clothing/suit/armor/abductor/vest/proc/AgentCheck(user)
	var/mob/living/carbon/human/H = user
	return H.agent

/obj/item/clothing/suit/armor/abductor/vest/attack_self(mob/user)
	if(!AbductorCheck(user))
		return
	if(!AgentCheck(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(src.loc))
		if(combat_cooldown != initial(combat_cooldown))
			to_chat(src.loc, "<span class='warning'>Combat injection is still recharging.</span>")
		var/mob/living/carbon/human/M = src.loc
		M.stat = CONSCIOUS
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		M.lying = 0
		M.update_canmove()
//		M.adjustStaminaLoss(-75)
		combat_cooldown = 0
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/vest/process()
	combat_cooldown++
	if(combat_cooldown == initial(combat_cooldown))
		STOP_PROCESSING(SSobj, src)


//SCIENCE TOOL
/obj/item/device/abductor/proc/IsAbductor(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.name != ABDUCTOR)
			return 0
		return 1
	return 0

/obj/item/device/abductor/proc/AbductorCheck(user)
	if(IsAbductor(user))
		return 1
	to_chat(user, "<span class='notice'>You can't figure how this works.</span>")
	return 0

/obj/item/device/abductor/proc/ScientistCheck(user)
	var/mob/living/carbon/human/H = user
	return H.scientist

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
	if(!ScientistCheck(user))
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
	if(!ScientistCheck(user))
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
	if(!ScientistCheck(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
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

/obj/item/device/abductor/gizmo/proc/mark(atom/target, mob/living/user)
	if(marked == target)
		to_chat(user, "<span class='notice'>This specimen is already marked.</span>")
		return
	if(ishuman(target))
		if(IsAbductor(target))
			marked = target
			to_chat(user, "<span class='notice'>You mark [target] for future retrieval.</span>")
		else
			prepare(target, user)
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
	var/list/all_items = M.GetAllContents()

	for(var/obj/I in all_items)
		if(istype(I,/obj/item/device/radio))
			var/obj/item/device/radio/r = I
			r.on = 0


//RECALL IMPLANT
/obj/item/weapon/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
//	activated = 1
	var/obj/machinery/abductor/pad/home
	var/cooldown = 30

	action_button_name = "Activate Implant"
	action_button_is_hands_free = 1

/obj/item/weapon/implant/abductor/attack_self()
	if(cooldown == initial(cooldown))
		if(imp_in.buckled)
			imp_in.buckled.unbuckle_mob()
		home.Retrieve(imp_in)
		cooldown = 0
		START_PROCESSING(SSobj, src)
	else
		to_chat(imp_in, "<span class='warning'>You must wait [30 - cooldown] seconds to use [src] again!</span>")
	return

/obj/item/weapon/implant/abductor/process()
	if(cooldown < initial(cooldown))
		cooldown++
		if(cooldown == initial(cooldown))
			STOP_PROCESSING(SSobj, src)


//ALIEN DECLONER
/obj/item/weapon/gun/energy/decloner/alien
	name = "alien weapon"
	desc = "An odd device that resembles human weapon."
	origin_tech = "materials=6;biotech=4;combat=5"
	icon_state = "alienpistol"
	item_state = "alienpistol"

/obj/item/weapon/gun/energy/decloner/alien/special_check(mob/living/carbon/human/M)
	if(M.species.name != ABDUCTOR)
		to_chat(M, "<span class='notice'>You can't figure how this works.</span>")
		return 0
	return 1

/obj/item/weapon/gun/energy/decloner/alien
	ammo_type = list(/obj/item/ammo_casing/energy/declone/light)


//AGENT HELMET
/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Abduct with style - spiky style. Prevents digital tracking."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	origin_tech = "materials=5;biotech=5"
	action_button_name = "Activate Helmet"

	var/team
	var/obj/machinery/camera/helm_cam

/obj/item/clothing/head/helmet/abductor/attack_self(mob/living/carbon/human/user)
	if(!IsAbductor(user))
		to_chat(user, "<span class='notice'>You can't figure how this works.</span>")
		return
	if(helm_cam)
		..(user)
	else
		icon_state = "alienhelmet_a"
		item_state = "alienhelmet_a"
		user.update_inv_head()
		team = user.team
		helm_cam = new /obj/machinery/camera(src)
		helm_cam.c_tag = "[user.real_name] Cam"
		helm_cam.replace_networks(list("Abductor[team]"))

		for(var/obj/machinery/computer/security/abductor_ag/C in computer_list)
			if(C.team == team)
				if(C.network.len < 1)
					C.network = helm_cam.network

		helm_cam.hidden = 1
		blockTracking = 1
		to_chat(user, "<span class='notice'>Abductor detected. Camera activated.</span>")
		return

/obj/item/clothing/head/helmet/abductor/proc/IsAbductor(mob/living/user)
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	if(!H.species)
		return 0
	if(H.species.name != ABDUCTOR)
		return 0
	return 1


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
	w_class = ITEM_SIZE_NORMAL
	action_button_name = "Toggle Mode"

/obj/item/weapon/abductor_baton/proc/toggle(mob/living/user=usr)
	if(!IsAbductor(user))
		return
	if(!AgentCheck(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
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
	user.update_inv_l_hand()
	user.update_inv_r_hand()

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

/obj/item/weapon/abductor_baton/proc/IsAbductor(mob/living/user)
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	if(!H.species)
		return 0
	if(H.species.name != ABDUCTOR)
		return 0
	return 1

/obj/item/weapon/abductor_baton/proc/AgentCheck(user)
	var/mob/living/carbon/human/H = user
	return H.agent

/obj/item/weapon/abductor_baton/attack(mob/target, mob/living/user)
	if(!IsAbductor(user))
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
	user.lastattacked = L
	L.lastattacker = user

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
				C.handcuffed = new /obj/item/weapon/handcuffs/alien(C)
				C.update_inv_handcuffed()
				to_chat(user, "<span class='notice'>You handcuff [C].</span>")
				L.log_combat(user, "handcuffed with \a [src]")
		else
			to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")
	return

/obj/item/weapon/abductor_baton/proc/ProbeAttack(mob/living/L,mob/living/user)
	L.visible_message("<span class='danger'>[user] probes [L] with [src]!</span>", \
						"<span class='userdanger'>[user] probes you!</span>")

	var/species = "<span class='warning'>Unknown species</span>"
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.dna && H.dna.species)
			species = "<span clas=='notice'>[H.species.name]</span>"
		if(L.mind && L.mind.changeling)
			species = "<span class='warning'>Changeling lifeform</span>"
	to_chat(user, "<span class='notice'>Probing result: </span>[species]")

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
	flags = DROPDEL // no CONDUCT
	origin_tech = "materials=5;combat=4;powerstorage=5"
	breakouttime = 450


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
	var/holding = 0
	var/belt = null
	var/mob/living/carbon/fastened = null

/obj/machinery/optable/abductor/atom_init()
	belt = image("icons/obj/abductor.dmi", "belt", layer = FLY_LAYER)
	. = ..()

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
				animation.dir = 2
				src.dir = 2
			else
				if(fastened.pixel_x != -2)
					fastened.pixel_x = -2
				animation.dir = 1
				src.dir = 1
		if(fastened.pixel_y != -4)
			fastened.pixel_y = -4
		if(fastened.dir & (EAST|WEST|NORTH))
			fastened.dir = SOUTH

		flick("belt_anim_on",animation)
		sleep(7)
		add_overlay(belt)
		fastened.anchored = 1
		fastened.SetStunned(INFINITY)
		qdel(animation)
	else
		cut_overlay(belt)
		switch(fastened.lying_current)
			if(90)	animation.dir = 2
			else	animation.dir = 1
		flick("belt_anim_off",animation)
		sleep(9)
		fastened.SetStunned(0)
		fastened.anchored = 0
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
	info = {"<b>Dissection for Dummies</b><br>
<br>
 1.Acquire fresh specimen.<br>
 2.Put the specimen on operating table.<br>
 3.Apply surgical drapes preparing for dissection.<br>
 4.Apply scalpel to specimen torso.<br>
 5.Stop the bleeders and retract skin<br>
 6.Make with a circular saw in the chest of subject hole and secure it with retractor.<br>
 7.Make some space with the drill. Don't worry, it's not so bad for subject as it sounds.<br>
 8.Insert replacement gland (Retrieve one from gland storage).<br>
 8.<b>OPTIONAL</b> Close hole in chest of subject, lubricate it with ectoplasm and cauterize the wound.<br>
 9.Consider dressing the specimen back to not disturb the habitat.<br>
 10.Put the specimen in the experiment machinery.<br>
 11.Choose one of the machine options and follow displayed instructions.<br>
<br>
Congratulations! You are now trained for xenobiology research!"}

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

/obj/item/weapon/lazarus_injector/alien/afterattack(atom/target, mob/user, proximity, params)
	if(!loaded)
		return
	if(isliving(target))
		var/mob/living/M = target
		M.revive()
		loaded = 0
		user.visible_message("<span class='notice'>[user] injects [M] with [src], fully heal it.</span>")
		playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
		icon_state = "abductor_empty"

/obj/machinery/recharger/wallcharger/alien
	icon = 'icons/obj/abductor.dmi'
