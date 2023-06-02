//The Eminence is a unique mob that functions like the leader of the cult. It's incorporeal but can interact with the world in several ways.
/mob/camera/eminence
	name = "\the Eminence"
	real_name = "\the Eminence"
	desc = "The leader-elect of the servants of Nar-Sie."
	icon = 'icons/obj/cult.dmi'
	icon_state = "eminence"
	mouse_opacity = MOUSE_OPACITY_ICON
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	faction = "cult"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	universal_understand = TRUE
	universal_speak = TRUE
	var/obj/item/weapon/storage/bible/tome/eminence/tome //They have a special one
	var/mob/living/cameraFollow = null
	COOLDOWN_DECLARE(command_point)
	COOLDOWN_DECLARE(point_to)

	show_examine_log = FALSE

/mob/camera/eminence/atom_init()
	. = ..()
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/my_religion, "eminence", image(icon, src, icon_state), src, cult_religion)
	tome = new(src)
	AddComponent(/datum/component/logout_spawner, /datum/spawner/living/eminence) //By hand cuz mob level

/mob/camera/eminence/Destroy()
	QDEL_NULL(tome)
	global.cult_religion.eminence = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/mob/camera/eminence/Move(NewLoc, direct)
	if(NewLoc && !isspaceturf(NewLoc) && !istype(NewLoc, /turf/unsimulated/wall))
		abstract_move(NewLoc)
		cameraFollow = null
		client.move_delay = world.time + 0.7 //What could possibly go wrong?

/mob/camera/eminence/proc/start_process()
	START_PROCESSING(SSreligion, src)

/mob/camera/eminence/process()
	for(var/turf/TT in range(5, src))
		if(min(prob(166 - (get_dist(src, TT) * 33)), 75))
			TT.atom_religify(my_religion) //Causes moving to leave a swath of proselytized area behind the Eminence

/mob/camera/eminence/Login()
	..()
	sync_mind()
	var/datum/religion/cult/R = global.cult_religion
	if(R.eminence && R.eminence != src)
		R.remove_member(src)
		qdel(src)
		return
	R.eminence = src
	tome.religion = R
	R.add_member(src, CULT_ROLE_HIGHPRIEST)
	to_chat(src, "<span class='cult large'>Вы стали Возвышенным!</span>")
	to_chat(src, "<span class='cult'>Будучи Возвышенным, вы ведёте весь культ за собой. Весь культ услышит то, что вы скажите.</span>")
	to_chat(src, "<span class='cult'>Вы можете двигаться невзирая на стены, вы бестелесны, и в большинстве случаев не сможете напрямую влиять на мир, за исключением нескольких особых способов.</span>")

	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(src)

	var/datum/action/innate/eminence/E
	for(var/V in subtypesof(/datum/action/innate/eminence))
		E = new V (src)
		E.Grant(src)

/mob/camera/eminence/proc/eminence_help()
	to_chat(src, "<span class='cult'>Вы можете взаимодействовать с внешним миром несколькими способами:<br>\
		Со всеми структурами культа вы можете взаимодействовать как обычный культист, такими как алтарь, кузня, исследовательскими столами, пыточной, аномалиями и дверьми.<br>\
		Средняя кнопка мыши или CTRL для отдачи команды всему культу. Это может помочь даже в бою - убирает большинство причин, по которой последователь не может драться, кроме смертельных. \
		Живой последователь, попавший под действие приказа более не будет оглушён, ослеплён и сможет продолжить свой бой.<br>\
		\"Переместиться на алтарь\" телепортирует вас на алтари.<br>\
		\"Переместиться на станцию к руне\" телепортирует вас на случайную руну, которая вне Рая.<br>\
		\"Использовать том\" имеет такие же функции, как если бы этот том был в руках обычного культиста. ВЫ НЕ МОЖЕТЕ АКТИВИРОВАТЬ РУНЫ САМОСТОЯТЕЛЬНО.<br>\
		\"Запретить/разрешить исследования\" включив это, обычные последователи культа не смогут сами изучать, а отключив, сможете как и вы, так и остальные культисты<br>\
		\"Стереть свои руны\" стирает все ваши руны в мире.<br>\
		\"Телепорт к последователю\" позволяет вам телепортироваться к любого последователю в культе по вашему желанию.</span>")

/mob/camera/eminence/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	var/response = tgui_alert(src, "Are you -sure- you want to return to Nar-Sie?\n You can't change your mind so choose wisely!","Are you sure you want to ghost?", list("Stay as Eminence","Return to Nar-Sie"))
	if(response != "Return to Nar-Sie")
		return

	SSStatistics.add_leave_stat(mind, "Ghosted")
	ghostize(can_reenter_corpse = FALSE)

/mob/camera/eminence/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(!(ignore_spam || forced) && client.handle_spam_prevention(message,MUTE_IC))
			return
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	log_say(message)
	if(SSticker.nar_sie_has_risen)
		visible_message("<span class='cult large'><b>Ты слышишь голос из ниоткуда:</b> \"[capitalize(message)]\"</span>")
		playsound(src, 'sound/antag/eminence_hit.ogg', VOL_EFFECTS_MASTER)
	cult_religion.send_message_to_members("[message]", SSticker.nar_sie_has_risen ? "Преосвященство" : "Возвышенный", 4, src)

/mob/camera/eminence/can_use_topic(src_object)
	if(!client)
		return STATUS_CLOSE
	if(get_dist(src_object, src) <= client.view)
		return STATUS_INTERACTIVE

	return STATUS_CLOSE

/mob/camera/eminence/physical_can_use_topic(src_object)
	return STATUS_INTERACTIVE

/mob/camera/eminence/physical_obscured_can_use_topic(src_object)
	return STATUS_INTERACTIVE

/mob/camera/eminence/default_can_use_topic(src_object)
	return STATUS_INTERACTIVE

/mob/camera/eminence/get_active_hand()
	return tome

/mob/camera/eminence/DblClickOn(atom/A, params)
	if(client.click_intercept) // handled in normal click.
		return
	SetNextMove(CLICK_CD_AI)

	if(ismob(A) && (A != src))
		eminence_track(A)

/mob/camera/eminence/proc/eminence_track(mob/target)
	set waitfor = FALSE
	if(!istype(target))
		return
	var/mob/camera/eminence/U = usr
	U.cameraFollow = target
	to_chat(U, "Now tracking [target.name].")

	new/datum/orbit(src, target, FALSE)
	if (!orbiting) //something failed, and our orbit datum deleted itself
		return
	var/matrix/initial_transform = matrix(transform)
	cached_transform = initial_transform

/mob/camera/eminence/stop_orbit()
	qdel(orbiting)
	transform = cached_transform

/mob/camera/eminence/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1
	if(client.click_intercept) // comes after object.Click to allow buildmode gui objects to be clicked
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK]) //No need to check it twice
		if(modifiers[MIDDLE_CLICK])
			if(!COOLDOWN_FINISHED(src, point_to))
				return
			point_at(A)
			COOLDOWN_START(src, point_to, 3 SECONDS)
			return
		A.examine(src)
		return
	if(modifiers[MIDDLE_CLICK] || modifiers[CTRL_CLICK])
		issue_command(A)
		return

	if(tome.toggle_deconstruct)
		for(var/datum/building_agent/B in tome.religion.available_buildings)
			if(istype(A, B.building_type))
				tome.afterattack(A, src, TRUE, params)

	if(istype(A, /obj/structure/cult/anomaly) || istype(A, /turf/unsimulated/floor/cult)) //Anomaly or cult floor
		for(var/obj/structure/cult/anomaly/F in range(1, A))
			F.destroying(my_religion)
	else if(istype(A, /obj/structure/altar_of_gods/cult)) //Altar
		var/obj/structure/altar_of_gods/alt = A
		alt.attackby(tome, src, params)
	else if(istype(A, /obj/structure/cult/tech_table)) //Research table
		var/obj/structure/cult/tech_table/T = A
		T.attack_hand(src)
	else if(istype(A, /obj/structure/cult/forge)) //Forge
		var/obj/structure/cult/forge/F = A
		F.attack_hand(src)
	else if(istype(A, /obj/structure/mineral_door/cult)) //Door
		var/obj/structure/mineral_door/cult/D = A
		D.attack_hand(src)
	else if(istype(A, /obj/machinery/optable/torture_table)) //Torture table
		var/obj/machinery/optable/torture_table/tab = A
		tab.attackby(tome, src, params)

	A.add_hiddenprint(src)
	if(world.time <= next_move)
		return
	SetNextMove(CLICK_CD_AI)

/mob/camera/eminence/Topic(href, href_list)
	if(usr != src)
		return
	if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		if(istype(target))
			eminence_track(target)

/mob/camera/eminence/proc/issue_command(atom/movable/A)
	if(!COOLDOWN_FINISHED(src, command_point))
		to_chat(src, "<span class='cult'>Слишком рано для новой команды!</span>")
		return
	var/list/commands = list("Rally Here", "Regroup Here", "Avoid This Area", "Reinforce This Area")
	var/roma_invicta = tgui_input_list(src, "Какой приказ отдать культу?", "Отдать Приказ", commands)
	if(!roma_invicta)
		return
	var/command_text = ""
	var/marker_icon
	switch(roma_invicta)
		if("Rally Here")
			command_text = "The Eminence orders an offensive rally at [A] to the GETDIR!"
			marker_icon = "eminence_rally"
		if("Regroup Here")
			command_text = "The Eminence orders a regroup to [A] to the GETDIR!"
			marker_icon = "eminence_rally"
		if("Avoid This Area")
			command_text = "The Eminence has designated the area to your GETDIR as dangerous and to be avoided!"
			marker_icon = "eminence_avoid"
		if("Reinforce This Area")
			command_text = "The Eminence orders the defense and fortification of the area to your GETDIR!"
			marker_icon = "eminence_reinforce"
	if(marker_icon)
		if(!COOLDOWN_FINISHED(src, command_point)) //Player can double click to issue two commands
			to_chat(src, "<span class='cult'>Слишком рано для новой команды!</span>")
			return
		new /obj/effect/temp_visual/command_point (get_turf(A), marker_icon)
		command_buff(get_turf(A))
		COOLDOWN_START(src, command_point, 2 MINUTES)
		for(var/mob/M in servants_and_ghosts())
			to_chat(M, "<span class='large cult'>[replacetext(command_text, "GETDIR", dir2text(get_dir(M, A)))]</span>")
			M.playsound_local(M, 'sound/antag/eminence_command.ogg', VOL_EFFECTS_MASTER)
	else
		cult_religion.send_message_to_members("<span class='large'>[command_text]</span>")
		for(var/mob/M in servants_and_ghosts())
			M.playsound_local(M, 'sound/antag/eminence_command.ogg', VOL_EFFECTS_MASTER)

/mob/camera/eminence/point_at(atom/pointed_atom)
	..(pointed_atom, /obj/effect/decal/point/eminence)

//Used by the Eminence to coordinate the cult
/obj/effect/temp_visual/command_point
	name = "Маркер Возвышенного"
	desc = "Важная точка, помеченная Возвышенным."
	icon = 'icons/hud/actions.dmi'
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	duration = 300

/obj/effect/temp_visual/command_point/atom_init(mapload, marker_icon)
	. = ..()
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/my_religion, "command_point", image('icons/hud/actions.dmi', src, marker_icon), src, cult_religion)

/mob/camera/eminence/proc/command_buff(turf/T)
	for(var/mob/M as anything in global.cult_religion.members)
		if(!isliving(M))
			continue
		var/mob/living/L = M
		if(get_dist(T, L) < 4) //Stand up and fight, almost no heal but stuns
			if(L.stat == DEAD)
				continue
			if(L.reagents)
				L.reagents.clear_reagents()
			L.beauty.AddModifier("stat", additive=L.beauty_living)
			L.setOxyLoss(0)
			L.setHalLoss(0)
			L.SetParalysis(0)
			L.SetStunned(0)
			L.SetWeakened(0)
			L.setDrugginess(0)
			L.nutrition = NUTRITION_LEVEL_NORMAL
			L.bodytemperature = T20C
			L.blinded = 0
			L.eye_blind = 0
			L.setBlurriness(0)
			L.ear_deaf = 0
			L.ear_damage = 0
			L.stat = CONSCIOUS
			L.SetDrunkenness(0)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.shock_stage = 0
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					H.restore_blood()
					H.full_prosthetic = null
					var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
					Heart?.heart_normalize()
