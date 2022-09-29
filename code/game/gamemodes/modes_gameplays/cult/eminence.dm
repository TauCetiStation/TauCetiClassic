//The Eminence is a unique mob that functions like the leader of the cult. It's incorporeal but can interact with the world in several ways.
/mob/camera/eminence
	name = "\the Emininence"
	real_name = "\the Eminence"
	desc = "The leader-elect of the servants of Ratvar."
	icon = 'icons/mob/actions_clockcult.dmi'
	icon_state = "eminence"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
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
	tome = new(src)

/mob/camera/eminence/Destroy()
	. = ..()
	QDEL_NULL(eminence_image)
	QDEL_NULL(tome)

/mob/camera/eminence/CanPass(atom/movable/mover, turf/target)
	return TRUE

/mob/camera/eminence/Move(NewLoc, direct)
	var/OldLoc = loc
	if(NewLoc && !istype(NewLoc, /turf/environment/space))
		//var/turf/T = get_turf(NewLoc)
		/*if(!SSticker.nar_sie_has_risenen)
			if(locate(/obj/effect/blessing, T))
				if(last_failed_turf != T)
					T.visible_message("<span class='warning'>[T] suddenly emits a ringing sound!</span>", null, null, null, src)
					playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 75, FALSE)
					last_failed_turf = T
				if((world.time - lastWarning) >= 30)
					lastWarning = world.time
					to_chat(src, "<span class='warning'>This turf is consecrated and can't be crossed!</span>")
				return
			if(istype(get_area(T), /area/chapel))
				if((world.time - lastWarning) >= 30)
					lastWarning = world.time
					to_chat(src, "<span class='warning'>The Chapel is hallowed ground under a heretical deity, and can't be accessed!</span>")
				return
		else*/
		if(SSticker.nar_sie_has_risen)
			for(var/turf/TT in range(5, src))
				if(prob(166 - (get_dist(src, TT) * 33)))
					TT.atom_religify(my_religion) //Causes moving to leave a swath of proselytized area behind the Eminence
		forceMove(NewLoc)
		Moved(OldLoc, direct)

/mob/camera/eminence/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/camera/eminence/Login()
	..()
	cult_religion.add_member(src)
	eminence_image = image(icon, src, icon_state)
	for(var/mob/M in cult_religion.members)
		M.client?.images |= eminence_image //Only for clients
	if(cult_religion)
		if(cult_religion.eminence && cult_religion.eminence != src)
			cult_religion.remove_member(src)
			qdel(src)
			return
		else
			cult_religion.eminence = src
	tome.religion = my_religion
	to_chat(src, "<span class='cult large'>You have been selected as the Eminence!</span>")
	to_chat(src, "<span class='cult'>As the Eminence, you lead the cultists. Anything you say will be heard by the entire cult.</span>")
	to_chat(src, "<span class='cult'>Though you can move through walls, you're also incorporeal, and largely can't interact with the world except for a few ways.</span>")
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
		visible_message("<span class='cult big'><b>Ты чувствуешь, как тьма врывается в твой мозг и формирует слова:</b> \"[capitalize(message)]\"</span>")
		//playsound(src, 'sound/machines/clockcult/ark_scream.ogg', 50, FALSE)
	message = "<span class='big cult'><b>[SSticker.nar_sie_has_risen ? "Преосвященство" : "Возвышенный"]:</b> \"[message]\"</span>"
	for(var/mob/M in servants_and_ghosts())
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [message]")
		else
			to_chat(M, message)

/mob/camera/eminence/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(src)
		return
	if(modifiers["middle"] || modifiers["ctrl"])
		issue_command(A)
		return

	if(istype(A, /obj/structure/mineral_door/cult))
		var/obj/structure/mineral_door/cult/D = A
		D.attack_hand(src)
	else if(istype(A, /obj/structure/altar_of_gods/cult))
		var/obj/structure/altar_of_gods/alt = A
		alt.attackby(tome, src)
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
	var/list/commands
	var/atom/movable/command_location
	if(A == src)
		commands = list("Defend the Ark!", "Advance!", "Retreat!", "Generate Power", "Build Defenses (Bottom-Up)", "Build Defenses (Top-Down)")
	else
		command_location = A
		commands = list("Rally Here", "Regroup Here", "Avoid This Area", "Reinforce This Area")
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
		if("Power This Structure")
			command_text = "[command_location] to your GETDIR has no power! Turn it on and make sure there's a sigil of transmission nearby!"
			marker_icon = "eminence_unlimited_power"
		if("Repair This Structure")
			command_text = "The Eminence orders that [command_location] to your GETDIR should be repaired ASAP!"
			marker_icon = "eminence_repair"
		if("Defend the Ark!")
			command_text = "The Eminence orders immediate defense of the Ark!"
		if("Advance!")
			command_text = "The Eminence commands you push forward!"
		if("Retreat!")
			command_text = "The Eminence has sounded the retreat! Fall back!"
		if("Generate Power")
			command_text = "The Eminence orders more power! Build power generations on the station!"
		if("Build Defenses (Bottom-Up)")
			command_text = "The Eminence orders that defenses should be built starting from the bottom of Reebe!"
		if("Build Defenses (Top-Down)")
			command_text = "The Eminence orders that defenses should be built starting from the top of Reebe!"
	if(marker_icon)
		new /obj/effect/temp_visual/ratvar/command_point(get_turf(A), marker_icon)
		COOLDOWN_START(src, command_point, 2 MINUTES)
		for(var/mob/M in servants_and_ghosts())
			to_chat(M, "<span class='large_brass'>[replacetext(command_text, "GETDIR", dir2text(get_dir(M, command_location)))]</span>")
			M.playsound_local(M, 'sound/antag/eminence_command.ogg', 75, VOL_EFFECTS_MASTER)

	else
		hierophant_message("<span class='bold large cult'>[command_text]</span>")
		for(var/mob/M in servants_and_ghosts())
			M.playsound_local(M, 'sound/antag/eminence_command.ogg', 75, VOL_EFFECTS_MASTER)


/obj/effect/temp_visual/ratvar/warp_marker/atom_init()
	. = ..()
	animate(src, alpha = 255, time = 50)

//Used by the Eminence to coordinate the cult
/obj/effect/temp_visual/ratvar/command_point
	name = "Маркер Возвышенного"
	desc = "Важная точка, помеченная Возвышенным."
	icon = 'icons/mob/actions_clockcult.dmi'
	icon_state = "eminence"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	duration = 300
	var/image/cult_vis

/obj/effect/temp_visual/ratvar/command_point/atom_init(marker_icon)
	. = ..()
	cult_vis = image(icon, src, marker_icon)
	for(var/mob/M in servants_and_ghosts())
		M.client.images |= cult_vis
		if(!isliving(M))
			return
		var/mob/living/L = M
		if(get_dist(src, L) >= 3) //Remove stuns
			if(L.reagents)
				L.reagents.clear_reagents()
			L.beauty.AddModifier("stat", additive=L.beauty_living)
			L.setOxyLoss(0)
			L.setHalLoss(0)
			L.SetParalysis(0)
			L.SetStunned(0)
			L.SetWeakened(0)
			L.setDrugginess(0)
			L.radiation = 0
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

/obj/effect/temp_visual/ratvar/command_point/Destroy()
	. = ..()
	QDEL_NULL(cult_vis)

/mob/camera/eminence/proc/eminence_help()
	to_chat(src, "<span class='bold cult'>Вы можете взаимодействовать с внешним миром несколькими способами:</span>")
	to_chat(src, "<span class='cult'><b>Со всеми структурами культа </b> вы можете взаимодействовать как обычный культист</span>")
	to_chat(src, "<span class='cult'><b>Средняя кнопка мыши или CTRL</b> для отдачи команы всему культу. Это может помочь даже в бою.</span>")

//Eminence actions below this point
/datum/action/innate/eminence
	name = "Умение Возвышенного"
	//desc = "You shouldn't see this. File a bug report!"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "clockcult"
	background_icon_state = "bg_cult"
	action_type = AB_INNATE

/datum/action/innate/eminence/IsAvailable()
	if(!iseminence(owner))
		qdel(src)
		return
	return ..()

//Lists available powers
/datum/action/innate/eminence/power_list
	name = "Помощь по умениям"
	button_icon_state = "eminence_rally"

/datum/action/innate/eminence/power_list/Activate()
	var/mob/camera/eminence/E = owner
	E.eminence_help()

/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/C
	if(ismob(mob_or_client))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(istype(mob_or_client, /client))
		C = mob_or_client

	if(!istype(C))
		return

	var/animate_color = C.color
	C.color = flash_color
	animate(C, color = animate_color, time = flash_time)

//Returns to the heaven
/datum/action/innate/eminence/heaven_jump
	name = "Вернуться в Рай"
	button_icon_state = "abscond"

/datum/action/innate/eminence/heaven_jump/Activate()
	if(cult_religion)
		if(!length(cult_religion.altars))
			to_chat(src, "<span class='bold cult'>У культа нет алтарей!</span>")
			return
		owner.forceMove(get_turf(pick(cult_religion.altars)))
		owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', 50, TRUE)
		flash_color(owner, flash_time = 25)
	else
		to_chat(owner, "<span class='warning'>Случилось что-то ужасное! Время достать богов по этому поводу!</span>")

//Warps to the Station
/datum/action/innate/eminence/station_jump
	name = "Переместиться на станцию"
	button_icon_state = "warp_down"

/datum/action/innate/eminence/station_jump/Activate()
	if(cult_religion)
		for(var/obj/effect/rune/rune as anything in cult_religion.runes)
			if(!is_centcom_level(rune.z))
				owner.forceMove(get_turf(pick(cult_religion.runes)))
				owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', 50, TRUE)
				flash_color(owner, flash_time = 25)
				break

//Activates tome
/datum/action/innate/eminence/tome
	name = "Использовать том"

/datum/action/innate/eminence/tome/New(Target)
	. = ..()
	var/mob/camera/eminence/E = owner
	button_icon = E.tome.icon
	button_icon_state = E.tome.icon_state
	button.UpdateIcon()

/datum/action/innate/eminence/tome/Activate()
	var/mob/camera/eminence/E = owner
	E.tome.attack_self(E)
