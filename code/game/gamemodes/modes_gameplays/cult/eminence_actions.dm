//Animated fading color on client's screen
/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/C
	if(ismob(mob_or_client))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(isclient(mob_or_client))
		C = mob_or_client

	if(!istype(C))
		return

	var/animate_color = C.color
	C.color = flash_color
	animate(C, color = animate_color, time = flash_time)

//Eminence actions below this point
/datum/action/innate/eminence
	name = "Умение Возвышенного"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "warp_down"
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

//Returns to the heaven
/datum/action/innate/eminence/heaven_jump
	name = "Переместиться на алтарь"
	button_icon_state = "abscond"

/datum/action/innate/eminence/heaven_jump/Activate()
	if(!length(cult_religion.altars))
		to_chat(src, "<span class='bold cult'>У вас нет алтарей!</span>")
		return
	owner.forceMove(get_turf(pick(global.cult_religion.altars)))
	owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', VOL_EFFECTS_MASTER)
	flash_color(owner, flash_time = 25)

//Warps to the Station
/datum/action/innate/eminence/station_jump
	name = "Переместиться на станцию к руне"
	button_icon_state = "warp_down"

/datum/action/innate/eminence/station_jump/Activate()
	var/list/possible_runes = list()
	for(var/obj/effect/rune/rune as anything in global.cult_religion.runes)
		if(!is_centcom_level(rune.z))
			possible_runes += rune
	if(length(possible_runes))
		owner.forceMove(get_turf(pick(possible_runes)))
		owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', VOL_EFFECTS_MASTER)
		flash_color(owner, flash_time = 25)
	else
		to_chat(owner, "<span class='warning'>Нет рун вне Рая, что бы на них телепортироваться!</span>")

//Activates tome
/datum/action/innate/eminence/tome
	name = "Использовать том"
	action_type = AB_ITEM

/datum/action/innate/eminence/tome/Grant(mob/T)
	. = ..()
	var/mob/camera/eminence/E = owner
	target = E.tome
	button.UpdateIcon()

/datum/action/innate/eminence/tome/Activate()
	var/obj/item/I = target
	I.attack_self(usr)

//Forbids research to cultists
/datum/action/innate/eminence/forbid_research
	name = "Запретить/разрешить исследования"
	button_icon_state = "research"
	action_type = AB_INNATE

/datum/action/innate/eminence/forbid_research/Activate()
	for(var/mob/L as anything in global.cult_religion.members)
		to_chat(L, "<span class='cult'>Возвышенный [global.cult_religion.research_forbidden ? "РАЗРЕШИЛ" : "ЗАПРЕТИЛ"] самостоятельное исследование последователям!</span>")
	global.cult_religion.research_forbidden = !global.cult_religion.research_forbidden

//Activates tome
/datum/action/innate/eminence/del_runes
	name = "Стереть свои руны"
	button_icon_state = "del_runes"
	action_type = AB_INNATE

/datum/action/innate/eminence/del_runes/Activate()
	. = ..()
	var/list/L = LAZYACCESS(owner.my_religion.runes_by_ckey, owner.ckey)
	for(var/obj/effect/rune/R in L)
		qdel(R)
		to_chat(owner, "<span class='warning'>Все вами начерченные руны были стёрты.</span>")

//Teleports to any cultist
/datum/action/innate/eminence/teleport2cultist
	name = "Телепорт к последователю"
	button_icon_state = "eminence_teleport"
	action_type = AB_INNATE

/datum/action/innate/eminence/teleport2cultist/Activate()
	. = ..()
	var/list/cultists = list()
	var/count = 0
	for(var/mob/M as anything in global.cult_religion.members - owner)
		count++
		cultists["[count]) [M.real_name][M.stat == DEAD ? " (DEAD)" : ""]"] = M

	var/target = tgui_input_list(owner, "Выберите последователя для телепорта", "Телепорт к последователю", cultists)
	if(target)
		owner.forceMove(get_turf(cultists[target]))
		owner.playsound_local(null, 'sound/magic/magic_missile.ogg', VOL_EFFECTS_MASTER)
		flash_color(owner, flash_time = 25)
