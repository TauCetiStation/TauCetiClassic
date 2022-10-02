//The Eminence is a unique mob that functions like the leader of the cult. It's incorporeal but can interact with the world in several ways.
/mob/camera/eminence
	name = "\the Emininence"
	real_name = "\the Eminence"
	desc = "The leader-elect of the servants of Ratvar."
	icon = 'icons/obj/cult.dmi'
	icon_state = "eminence"
	mouse_opacity = MOUSE_OPACITY_ICON
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	faction = "cult"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/turf/last_failed_turf
	var/lastWarning = 0
	var/image/eminence_image = null
	var/obj/item/weapon/storage/bible/tome/upgraded/tome
	COOLDOWN_DECLARE(command_point)

/mob/camera/eminence/atom_init()
	. = ..()
	tome = new(src) //Let's pretend that they have a special one
	tome.destr_cd = 10 SECONDS
	tome.rune_cd = 10 SECONDS
	tome.cost_coef = 1.5
	tome.build_cd = 5 SECONDS

/mob/camera/eminence/Destroy()
	. = ..()
	QDEL_NULL(eminence_image)
	QDEL_NULL(tome)
	STOP_PROCESSING(SSprocessing, src)

/mob/camera/eminence/Move(NewLoc, direct)
	if(NewLoc && !isspaceturf(NewLoc) && !istype(NewLoc, /turf/unsimulated/wall))
		forceMove(NewLoc)
		client.move_delay = world.time + 1 //What could possibly go wrong?

/mob/camera/eminence/process()
	for(var/turf/TT in range(5, src))
		if(min(prob(166 - (get_dist(src, TT) * 33)), 75))
			TT.atom_religify(my_religion) //Causes moving to leave a swath of proselytized area behind the Eminence

/mob/camera/eminence/Login()
	..()
	cult_religion.add_member(src)
	eminence_image = image(icon, src, icon_state)
	for(var/mob/M as anything in cult_religion.members)
		M.client?.images |= eminence_image //Only for clients
	if(cult_religion)
		if(cult_religion.eminence && cult_religion.eminence != src)
			cult_religion.remove_member(src)
			qdel(src)
			return
		else
			cult_religion.eminence = src
	tome.religion = cult_religion
	to_chat(src, "<span class='cult large'>Вы стали Возвышенным!</span>")
	to_chat(src, "<span class='cult'>Будучи Возвышенным, вы ведёте весь культ за собой. Весь культ услышит то, что вы скажите.</span>")
	to_chat(src, "<span class='cult'>Вы можете двигаться невзирая на стены, вы бестелесны, и в большинстве случаев не сможете напрямую влиять на мир, за исключением нескольких особых способов.</span>")
	eminence_help()
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(src) //So we get rid of duplicate actions; this also removes Hierophant network, since our say() goes across it anyway

	var/datum/action/innate/eminence/E
	for(var/V in subtypesof(/datum/action/innate/eminence))
		E = new V (src)
		E.Grant(src)

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
		visible_message("<span class='cult large'><b>Ты чувствуешь, как тьма врывается в твой мозг и формирует слова:</b> \"[capitalize(message)]\"</span>")
		playsound(src, 'sound/antag/eminence_hit.ogg', VOL_EFFECTS_MASTER)
	message = "<span class='big cult'><b>[SSticker.nar_sie_has_risen ? "Преосвященство" : "Возвышенный"]:</b> \"[message]\"</span>"
	for(var/mob/M as anything in servants_and_ghosts())
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [message]")
		else
			to_chat(M, message)

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

/mob/camera/eminence/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(src)
		return
	if(modifiers["middle"] || modifiers["ctrl"])
		issue_command(A)
		return

	if(tome.toggle_deconstruct)
		for(var/datum/building_agent/B in tome.religion.available_buildings)
			if(istype(A, B.building_type))
				tome.afterattack(A, src, TRUE, params)

	if(istype(A, /obj/structure/mineral_door/cult))
		var/obj/structure/mineral_door/cult/D = A
		D.attack_hand(src)
	else if(istype(A, /obj/structure/altar_of_gods/cult))
		var/obj/structure/altar_of_gods/alt = A
		alt.attackby(tome, src, params)
	else if(istype(A, /obj/structure/cult/tech_table))
		var/obj/structure/cult/tech_table/T = A
		T.attack_hand(src)
	else if(istype(A, /obj/structure/cult/forge))
		var/obj/structure/cult/forge/F = A
		F.attack_hand(src)
	else if(istype(A, /obj/structure/cult/anomaly))
		var/obj/structure/cult/anomaly/F = A
		F.destroying(my_religion)

/mob/camera/eminence/proc/issue_command(atom/movable/A)
	if(!COOLDOWN_FINISHED(src, command_point))
		to_chat(src, "<span class='cult'>Слишком рано для новой команды!</span>")
		return
	var/list/commands = list("Rally Here", "Regroup Here", "Avoid This Area", "Reinforce This Area")
	var/atom/movable/command_location = A
	var/roma_invicta = input(src, "Choose a command to issue to your cult!", "Issue Commands") as null|anything in commands
	if(!roma_invicta)
		return
	var/command_text = ""
	var/marker_icon
	switch(roma_invicta)
		if("Rally Here")
			command_text = "The Eminence orders an offensive rally at [command_location] to the GETDIR!"
			marker_icon = "eminence_rally"
		if("Regroup Here")
			command_text = "The Eminence orders a regroup to [command_location] to the GETDIR!"
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
		var/obj/effect/temp_visual/command_point/P = new (get_turf(A))
		P.icon_state = marker_icon
		COOLDOWN_START(src, command_point, 2 MINUTES)
		for(var/mob/M in servants_and_ghosts())
			to_chat(M, "<span class='large cult'>[replacetext(command_text, "GETDIR", dir2text(get_dir(M, command_location)))]</span>")
			M.playsound_local(M, 'sound/antag/eminence_command.ogg', VOL_EFFECTS_MASTER)
	else
		hierophant_message("<span class='large cult'>[command_text]</span>")
		for(var/mob/M in servants_and_ghosts())
			M.playsound_local(M, 'sound/antag/eminence_command.ogg', VOL_EFFECTS_MASTER)

//Used by the Eminence to coordinate the cult
/obj/effect/temp_visual/command_point
	name = "Маркер Возвышенного"
	desc = "Важная точка, помеченная Возвышенным."
	icon = 'icons/hud/actions.dmi'
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	duration = 300
	var/image/cult_vis

/obj/effect/temp_visual/command_point/atom_init(marker_icon)
	. = ..()
	cult_vis = image(icon, src, marker_icon)
	for(var/mob/M as anything in servants_and_ghosts())
		M.client.images |= cult_vis

	for(var/mob/M as anything in cult_religion.members)
		if(!isliving(M))
			continue
		var/mob/living/L = M
		if(get_dist(src, L) < 4) //Stand up and fight, almost no heal but stuns
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
				if(ishuman(L))
					var/mob/living/carbon/human/H = src
					H.restore_blood()
					H.full_prosthetic = null
					var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
					Heart?.heart_normalize()

/obj/effect/temp_visual/command_point/Destroy()
	. = ..()
	QDEL_NULL(cult_vis)

/mob/camera/eminence/proc/eminence_help()
	to_chat(src, "<span class='cult'>Вы можете взаимодействовать с внешним миром несколькими способами:</span>")
	to_chat(src, "<span class='cult'><b>Со всеми структурами культа </b>вы можете взаимодействовать как обычный культист, такими как алтарь, кузня, исследовательскими столами, аномалиями и дверьми.</span>")
	to_chat(src, "<span class='cult'><b>Средняя кнопка мыши или CTRL</b> для отдачи команды всему культу. Это может помочь даже в бою - убирает большинство причин, по которой последователь не может драться, кроме смертельных.</span>")
	to_chat(src, "<span class='cult'><b>Вернуться в Рай</b> телепортирует вас на алтари.</span>")
	to_chat(src, "<span class='cult'><b>Переместиться на станцию</b> телепортирует вас на случайную руну, которая вне Рая.</span>")
	to_chat(src, "<span class='cult'><b>Использовать том</b> имеет такие же функции, как если бы этот том был в руках обычного культиста. ВЫ НЕ МОЖЕТЕ АКТИВИРОВАТЬ РУНЫ САМОСТОЯТЕЛЬНО.</span>")
	to_chat(src, "<span class='cult'><b>Запретить/разрешить исследования</b> включив это, обычные последователи культа не смогут сами изучать, а отключив, сможете как и вы, так и остальные культисты</span>")
	to_chat(src, "<span class='cult'><b>Вернуться в Рай</b> телепортирует вас на алтари.</span>")
	to_chat(src, "<span class='cult'><b>Стереть свои руны</b> стирает все ваши руны в мире.</span>")
	to_chat(src, "<span class='cult'><b>Телепорт к последователю</b> позволяет вам телепортироваться к любого последователю в культе по вашему желанию.</span>")
