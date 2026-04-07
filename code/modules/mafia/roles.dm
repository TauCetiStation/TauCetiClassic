/datum/mafia_role
	var/name = "Ассистент"
	var/desc = "Вы член экипажа без каких-либо особых способностей."
	var/win_condition = "убить мафию и одиночных убийц."
	var/team = MAFIA_TEAM_TOWN
	///how the random setup chooses which roles get put in
	var/role_type = TOWN_OVERFLOW

	var/player_key
	var/mob/living/carbon/human/body
	var/obj/effect/landmark/mafia/assigned_landmark

	///role flags (special status of roles like detection immune)
	var/role_flags = NONE
	///how many votes submitted when you vote. used in voting, but not victory
	var/vote_power = 1
	///stop spam vote for
	var/next_vote = 0
	///what they get equipped with when they are revealed
	var/datum/outfit/revealed_outfit = /datum/outfit/mafia/assistant
	///action = uses
	var/list/actions = list()
	var/list/targeted_actions = list()
	///what the role gets when it wins a game

	///so mafia have to also kill them to have a majority
	var/game_status = MAFIA_ALIVE

	///icon state in the mafia dmi of the hud of the role, used in the mafia ui
	var/hud_icon = "hudassistant"
	///icon state in the mafia dmi of the hud of the role, used in the mafia ui
	var/revealed_icon = "assistant"
	///set this to something cool for antagonists and their window will look different
	var/special_theme

	var/list/role_notes = list()

/**
 * Tests if a visitor can actually perform an action on this role. Verbose on purpose!
 *
 * Will return false if: Your visit is roleblocked, they have perished, or your visit was interrupted
 */
/datum/mafia_role/proc/can_action(datum/mafia_controller/game, datum/mafia_role/visitor, action)
	if(visitor.game_status == MAFIA_DEAD)
		to_chat(visitor.body, "<span class='danger'>Вы мертвы!</span>")
		return FALSE
	if(role_flags & ROLE_ROLEBLOCKED)
		to_chat(visitor.body, "<span class='danger'>Ваше [action] было заблокировано!</span>")
		return FALSE
	if(game_status != MAFIA_ALIVE && !(visitor.role_flags & ROLE_ACTIONONDEAD)) //They're already dead
		to_chat(visitor.body, "<span class='danger'>[body.real_name] погиб до того, как вы смогли прийти!</span>")
		return FALSE
	if(SEND_SIGNAL(src,COMSIG_MAFIA_ON_VISIT,game,visitor) & MAFIA_VISIT_INTERRUPTED) //visited a warden. something that prevents you by visiting that person
		to_chat(visitor.body, "<span class='danger'>Ваше [action] было прервано!</span>")
		return FALSE
	return TRUE

/**
 * Tests kill immunities, if nothing prevents the kill, kills this role.
 *
 * Does not count as visiting, see visit proc.
 */
/datum/mafia_role/proc/kill(datum/mafia_controller/game, datum/mafia_role/attacker, lynch=FALSE)
	if(SEND_SIGNAL(src,COMSIG_MAFIA_ON_KILL,game,attacker,lynch) & MAFIA_PREVENT_KILL)
		return FALSE
	game_status = MAFIA_DEAD
	body.death()
	if(lynch)
		reveal_role(game, verbose = TRUE)
	if(!(player_key in game.spectators)) //people who played will want to see the end of the game more often than not
		game.spectators += player_key
	return TRUE

/datum/mafia_role/Destroy(force, ...)
	QDEL_NULL(body)
	. = ..()

/datum/mafia_role/proc/greet()
	body.playsound_local(null, 'sound/ambience/ambifailure.ogg', VOL_EFFECTS_MASTER)
	to_chat(body,"<span class='danger'>Вы [name].</span>")
	to_chat(body,"<span class='danger'>[desc]</span>")
	switch(team)
		if(MAFIA_TEAM_MAFIA)
			to_chat(body,"<span class='danger'>Вы и ваши сообщники выиграете, если превзойдете численностью членов экипажа.</span>")
		if(MAFIA_TEAM_TOWN)
			to_chat(body,"<span class='danger'>Вы член экипажа. Определите, кто является убийцей и казните их.</span>")
		if(MAFIA_TEAM_SOLO)
			to_chat(body,"<span class='danger'>Вы не привязаны ни к городу, ни к мафии. Выполните свои задачи.</span>")

/datum/mafia_role/proc/reveal_role(datum/mafia_controller/game, verbose = FALSE)
	if((role_flags & ROLE_REVEALED))
		return
	if(verbose)
		game.send_message("<span class='big boldnotice'>Стало известно, что истинная роль [body] [game_status == MAFIA_ALIVE ? "это" : "была"] [name]!</span>")
	var/list/oldoutfit = body.get_equipped_items()
	for(var/thing in oldoutfit)
		qdel(thing)
	special_reveal_equip(game)
	body.equipOutfit(revealed_outfit)
	role_flags |= ROLE_REVEALED

/datum/mafia_role/proc/special_reveal_equip(datum/mafia_controller/game)
	return

/datum/mafia_role/proc/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	return

/datum/mafia_role/proc/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	if((role_flags & ROLE_ROLEBLOCKED))
		return FALSE
	return TRUE

/datum/mafia_role/proc/add_note(note)
	role_notes += note

/datum/mafia_role/proc/check_total_victory(alive_town, alive_mafia) //solo antags can win... solo.
	return FALSE

/datum/mafia_role/proc/block_team_victory(alive_town, alive_mafia) //solo antags can also block team wins.
	return FALSE

/datum/mafia_role/proc/show_help(clueless)
	var/list/result = list()
	var/team_desc = ""
	var/team_span = ""
	switch(team)
		if(MAFIA_TEAM_TOWN)
			team_desc = "Городу"
			team_span = "nicegreen"
		if(MAFIA_TEAM_MAFIA)
			team_desc = "Мафии"
			team_span = "red"
		if(MAFIA_TEAM_SOLO)
			team_desc = "никому"
			team_span = "comradio"
	result += "<span class='notice'>["<span class='bold'>[name]</span>"] привязан к <span class='[team_span]'>[team_desc]</span></span>"
	result += "<span class='boldnotice'>\"[desc]\"</span>"
	result += "<span class='notice'>Задача [name]: [win_condition]</span>"
	to_chat(clueless, result.Join("</br>"))

/datum/mafia_role/detective
	name = "Детектив"
	desc = "Каждую ночь вы можете узнать принадлежность одного человека к какой-либо команде."
	revealed_outfit = /datum/outfit/mafia/detective
	role_type = TOWN_INVEST

	hud_icon = "huddetective"
	revealed_icon = "detective"

	targeted_actions = list("Investigate")

	var/datum/mafia_role/current_investigation

/datum/mafia_role/detective/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,PROC_REF(investigate))

/datum/mafia_role/detective/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/detective/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>Вы можете проверять только живых людей.</span>")
		return
	to_chat(body,"<span class='warning'>Этой ночью вы проверите [target.body.real_name].</span>")
	current_investigation = target

/datum/mafia_role/detective/proc/investigate(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_investigation)
		return

	var/datum/mafia_role/target = current_investigation
	current_investigation = null
	if(!target.can_action(game, src, "расследование"))
		return
	if((target.role_flags & ROLE_UNDETECTABLE))
		to_chat(body,"<span class='warning'>Ваше расследование показало, что [target.body.real_name] является истинным членом экипажа.</span>")
		add_note("N[game.turn] - [target.body.real_name] - Город")
	else
		var/team_text
		var/fluff
		switch(target.team)
			if(MAFIA_TEAM_TOWN)
				team_text = "Город"
				fluff = "истинным членом экипажа."
			if(MAFIA_TEAM_MAFIA)
				team_text = "Мафия"
				fluff = "жестоким и отвратительным мутантом!"
			if(MAFIA_TEAM_SOLO)
				team_text = "Одиночка"
				fluff = "злодеем со своими целями..."
		to_chat(body,"<span class='warning'>Ваше расследование показало, что [target.body.real_name] является [fluff]</span>")
		add_note("N[game.turn] - [target.body.real_name] - [team_text]")

/datum/mafia_role/psychologist
	name = "Психолог"
	desc = "ОДИН РАЗ ЗА ИГРУ вы можете посетить кого-то и раскрыть его истинную роль поутру."
	revealed_outfit = /datum/outfit/mafia/psychologist
	role_type = TOWN_INVEST

	hud_icon = "hudpsychologist"
	revealed_icon = "psychologist"

	targeted_actions = list("Reveal")
	var/datum/mafia_role/current_target
	var/can_use = TRUE

/datum/mafia_role/psychologist/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,PROC_REF(therapy_reveal))

/datum/mafia_role/psychologist/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || !can_use || game.phase == MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE || (target.role_flags & ROLE_REVEALED) || target == src)
		return FALSE

/datum/mafia_role/psychologist/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	to_chat(body,"<span class='warning'>Вы раскроете [target.body.real_name] этой ночью.</span>")
	current_target = target

/datum/mafia_role/psychologist/proc/therapy_reveal(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return
	var/datum/mafia_role/target = current_target
	current_target = null
	if(!target.can_action(game, src, "раскрытие роли"))
		return
	add_note("N[game.turn] - [target.body.real_name] - Раскрыл истинную роль")
	to_chat(body,"<span class='warning'>Вы раскрыли истинную роль [target]!</span>")
	target.reveal_role(game, verbose = TRUE)
	can_use = FALSE

/datum/mafia_role/chaplain
	name = "Священник"
	desc = "Вы можете общаться с духами мертвых каждой ночью, чтобы раскрыть роли мертвых членов экипажа."
	revealed_outfit = /datum/outfit/mafia/chaplain
	role_type = TOWN_INVEST
	hud_icon = "hudchaplain"
	revealed_icon = "chaplain"
	role_flags = ROLE_ACTIONONDEAD

	targeted_actions = list("Pray")
	var/datum/mafia_role/current_target

/datum/mafia_role/chaplain/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,PROC_REF(commune))

/datum/mafia_role/chaplain/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_DEAD && target != src && !(target.role_flags & ROLE_REVEALED)

/datum/mafia_role/chaplain/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	to_chat(body,"<span class='warning'>Этой ночью вы будете говорить с духом [target.body.real_name].</span>")
	current_target = target

/datum/mafia_role/chaplain/proc/commune(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return
	var/datum/mafia_role/target = current_target
	current_target = null
	if(!target.can_action(game, src, "общение"))
		return
	if(target)
		to_chat(body,"<span class='warning'>Вы призываете дух [target.body.real_name] и узнаете что его роль - <b>[target.name]</b>.</span>")
		add_note("N[game.turn] - [target.body.real_name] - [target.name]")

/datum/mafia_role/md
	name = "Врач"
	desc = "Каждую ночь вы можете защитить одного человека от смерти."
	revealed_outfit = /datum/outfit/mafia/md
	role_type = TOWN_PROTECT
	hud_icon = "hudmedicaldoctor"
	revealed_icon = "medicaldoctor"

	targeted_actions = list("Protect")
	var/datum/mafia_role/current_protected

/datum/mafia_role/md/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,PROC_REF(protect))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,PROC_REF(end_protection))

/datum/mafia_role/md/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	if((target.role_flags & ROLE_VULNERABLE) && (target.role_flags & ROLE_REVEALED)) //do not give the option to protect roles that your protection will fail on
		return FALSE
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/md/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>Вы можете защищать только живых людей.</span>")
		return
	to_chat(body,"<span class='warning'>Этой ночью вы защитите [target.body.real_name].</span>")
	current_protected = target

/datum/mafia_role/md/proc/protect(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_protected)
		return
	var/datum/mafia_role/target = current_protected
	//current protected is unset at the end, as this action ends at a different phase
	if(!target.can_action(game, src, "медицинское содействие"))
		return

	RegisterSignal(target,COMSIG_MAFIA_ON_KILL,PROC_REF(prevent_kill))
	add_note("N[game.turn] - Защитил [target.body.real_name]")

/datum/mafia_role/md/proc/prevent_kill(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if((current_protected.role_flags & ROLE_VULNERABLE))
		to_chat(body,"<span class='warning'>Человек, которого вы пытались защитить, не может быть спасен.</span>")
		return
	to_chat(body,"<span class='warning'>Человек, которого вы защитили сегодня был подвергнут атаке.</span>")
	to_chat(current_protected.body,"<span class='greentext'>Вас атаковали этой ночью, но кто-то вас спас.</span>")
	return MAFIA_PREVENT_KILL

/datum/mafia_role/md/proc/end_protection(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_protected)
		UnregisterSignal(current_protected,COMSIG_MAFIA_ON_KILL)
		current_protected = null

/datum/mafia_role/officer
	name = "Офицер Охраны"
	desc = "Каждую ночь вы можете попробовать защитить одного человека. Если его атакуют, вы отомстите, убив нападающего ценой своей жизни."
	revealed_outfit = /datum/outfit/mafia/security
	revealed_icon = "securityofficer"
	hud_icon = "hudsecurityofficer"
	role_type = TOWN_PROTECT
	role_flags = ROLE_CAN_KILL

	targeted_actions = list("Defend")
	var/datum/mafia_role/current_defended

/datum/mafia_role/officer/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,PROC_REF(defend))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,PROC_REF(end_defense))

/datum/mafia_role/officer/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	if((role_flags & ROLE_VULNERABLE) && (target.role_flags & ROLE_REVEALED)) //do not give the option to protect roles that your protection will fail on
		return FALSE
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/officer/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>Вы можете защищать только живых людей.</span>")
		return
	to_chat(body,"<span class='warning'>Этой ночью вы защитите [target.body.real_name].</span>")
	current_defended = target

/datum/mafia_role/officer/proc/defend(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_defended)
		return
	var/datum/mafia_role/target = current_defended
	//current defended is unset at the end, as this action ends at a different phase
	if(!target.can_action(game, src, "патрулирование"))
		return
	if(target)
		RegisterSignal(target,COMSIG_MAFIA_ON_KILL,PROC_REF(retaliate))
		add_note("N[game.turn] - Защитил [target.body.real_name]")

/datum/mafia_role/officer/proc/retaliate(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(current_defended.role_flags & ROLE_VULNERABLE)
		to_chat(body,"<span class='warning'>Человек, которого вы пытались защитить, не может быть спасен. Вы не можете атаковать убийцу.</span>")
		return
	to_chat(body,"<span class='warning'>Человек, которого вы защитили, сегодня был подвергнут атаке.</span>")
	to_chat(current_defended.body,"<span class='userdanger'>Вас атаковали этой ночью, но охрана спасла вас.</span>")
	if(attacker.kill(game,src,FALSE)) //you attack the attacker
		to_chat(attacker.body, "<span class='userdanger'>Охрана устроила вам засаду!</span>")
	kill(game,attacker,FALSE) //the attacker attacks you, they were able to attack the target so they can attack you.
	return MAFIA_PREVENT_KILL

/datum/mafia_role/officer/proc/end_defense(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_defended)
		UnregisterSignal(current_defended,COMSIG_MAFIA_ON_KILL)
		current_defended = null

/datum/mafia_role/lawyer
	name = "Адвокат"
	desc = "Днем вы можете выбрать человека, которому будете давать ночью подробную юридическую консультацию, предотвращая ночные действия."
	revealed_outfit = /datum/outfit/mafia/lawyer
	role_type = TOWN_SUPPORT
	hud_icon = "hudlawyer"
	revealed_icon = "lawyer"

	targeted_actions = list("Advise")
	var/datum/mafia_role/current_target

/datum/mafia_role/lawyer/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,PROC_REF(roleblock))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,PROC_REF(release))

/datum/mafia_role/lawyer/proc/roleblock(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return

	var/datum/mafia_role/target = current_target
	if(!target.can_action(game, src, "блокирование роли")) //roleblocking a warden moment
		current_target = null
		return

	to_chat(target.body,"<span class='big bold red'>ВЫ БЫЛИ ЗАБЛОКИРОВАНЫ! ЭТОЙ НОЧЬЮ ВЫ НИЧЕГО НЕ МОЖЕТЕ ДЕЛАТЬ.</span>")
	add_note("N[game.turn] - [target.body.real_name] - Заблокирован")
	target.role_flags |= ROLE_ROLEBLOCKED

/datum/mafia_role/lawyer/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(target == src)
		return FALSE
	if(game.phase == MAFIA_PHASE_NIGHT)
		return FALSE
	if(target.game_status != MAFIA_ALIVE)
		return FALSE

/datum/mafia_role/lawyer/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(target == current_target)
		current_target = null
		to_chat(body,"<span class='warning'>Этой ночью вы решили никого не блокировать.</span>")
	else
		current_target = target
		to_chat(body,"<span class='warning'>Этой ночью вы заблокируете [target.body.real_name].</span>")

/datum/mafia_role/lawyer/proc/release(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_target)
		current_target.role_flags &= ~ROLE_ROLEBLOCKED
		current_target = null

/datum/mafia_role/hop
	name = "Начальник Персонала"
	desc = "Один раз за игру вы можете раскрыть себя, утраивая силу своего голоса, но потеряв возможность быть защищенным."
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	hud_icon = "hudheadofpersonnel"
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop

	targeted_actions = list("Reveal")

/datum/mafia_role/hop/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || game.phase == MAFIA_PHASE_NIGHT || game.turn == 1 || target.game_status != MAFIA_ALIVE || target != src || (role_flags & ROLE_REVEALED))
		return FALSE

/datum/mafia_role/hop/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	reveal_role(game, TRUE)
	role_flags |= ROLE_VULNERABLE
	vote_power = 3

/datum/mafia_role/hos
	name = "Начальник Охраны"
	desc = "Вы можете решить казнить кого-то ночью, раскрывая его роль. Если ваша цель будет мирным членом экипажа, вы умрете в начале следующей ночи."
	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL | ROLE_UNIQUE
	revealed_outfit = /datum/outfit/mafia/hos
	revealed_icon = "headofsecurity"
	hud_icon = "hudheadofsecurity"

	targeted_actions = list("Execute")
	var/datum/mafia_role/execute_target

/datum/mafia_role/hos/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,PROC_REF(execute))

/datum/mafia_role/hos/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/hos/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	to_chat(body,"<span class='warning'>Вы решили казнить [target.body.real_name] этой ночью.</span>")
	execute_target = target

/datum/mafia_role/hos/proc/execute(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!execute_target)
		return
	var/datum/mafia_role/target = execute_target
	execute_target = null
	if(!target.can_action(game, src, "убийство"))
		return
	if(!target.kill(game,src,FALSE))//protection
		to_chat(body,"<span class='danger'>Ваша попытка казнить [target.body.real_name] была предотвращена или [target.body.real_name] обладает иммунитетом!</span>")
	else
		to_chat(target.body, "<span class='userdanger'>Вы были казнены Начальником Охраны!</span>")
		target.reveal_role(game, verbose = TRUE)
		if(target.team == MAFIA_TEAM_TOWN)
			to_chat(body,"<span class='userdanger'>Вы убили невинного члена экипажа. Ты умрёшь завтра ночью!.</span>")
			RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,PROC_REF(internal_affairs))
			role_flags |= ROLE_VULNERABLE

/datum/mafia_role/hos/proc/internal_affairs(datum/mafia_controller/game)
	to_chat(body,"<span class='userdanger'>Вы были убиты Агентом Внутренних Дел НаноТрейзен!</span>")
	reveal_role(game, verbose = TRUE)
	kill(game,src,FALSE) //you technically kill yourself but that shouldn't matter


//just helps read better
#define WARDEN_NOT_LOCKDOWN 0//will NOT kill visitors tonight
#define WARDEN_WILL_LOCKDOWN 1 //will kill visitors tonight

/datum/mafia_role/warden
	name = "Начальник Тюрьмы"
	desc = "Вы можете один раз запереться на ночь, убив всех посетителей. ПРЕДУПРЕЖДЕНИЕ: Это также убивает жителей города!"

	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL
	revealed_outfit = /datum/outfit/mafia/warden
	revealed_icon = "warden"
	hud_icon = "hudwarden"

	actions = list("Lockdown")
	var/charges = 1
	var/protection_status = WARDEN_NOT_LOCKDOWN


/datum/mafia_role/warden/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,PROC_REF(night_start))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,PROC_REF(night_end))

/datum/mafia_role/warden/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!charges)
		to_chat(body,"<span class='danger'>Вы уже запирались в этой игре!</span>")
		return
	if(game.phase == MAFIA_PHASE_NIGHT)
		to_chat(body,"<span class='danger'>У вас нет времени запираться, ночь уже наступила.</span>")
		return
	if(protection_status == WARDEN_WILL_LOCKDOWN)
		to_chat(body,"<span class='danger'>Вы решаете не запираться на ночь.</span>")
	else
		to_chat(body,"<span class='danger'>Вы решаете запереться, убивая всех посетителей.</span>")
	protection_status = !protection_status

/datum/mafia_role/warden/proc/night_start(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == WARDEN_WILL_LOCKDOWN)
		to_chat(body,"<span class='danger'>Все посетители ночью получат выстрел картечи в лицо.</span>")
		RegisterSignal(src,COMSIG_MAFIA_ON_VISIT,PROC_REF(self_defense))

/datum/mafia_role/warden/proc/night_end(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == WARDEN_WILL_LOCKDOWN)
		charges--
		UnregisterSignal(src,COMSIG_MAFIA_ON_VISIT)
		to_chat(body,"<span class='danger'>Вы больше не защищены. Вы потратили свою силу.</span>")
		protection_status = WARDEN_NOT_LOCKDOWN

/datum/mafia_role/warden/proc/self_defense(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	to_chat(body,"<span class='userdanger'>Вы застрелили посетителя!</span>")
	to_chat(attacker,"<span class='userdanger'>Вы посетили Начальника Тюрьмы!</span>")
	attacker.kill(game, src, lynch = FALSE)
	return MAFIA_VISIT_INTERRUPTED

#undef WARDEN_NOT_LOCKDOWN
#undef WARDEN_WILL_LOCKDOWN

///MAFIA ROLES/// they're the "anti-town" working to kill off townies to win

/datum/mafia_role/mafia
	name = "Генокрад"
	desc = "Вы член улья генокрадов. Используй ':z' чтобы разговаривать со своими коллегами."
	team = MAFIA_TEAM_MAFIA
	role_type = MAFIA_REGULAR
	hud_icon = "hudchangeling"
	revealed_icon = "changeling"

	revealed_outfit = /datum/outfit/mafia/changeling
	special_theme = "syndicate"
	win_condition = "превзойдите численностью город и никакая роль одиночного убийцы не сможет Вас остановить."

/datum/mafia_role/mafia/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,PROC_REF(mafia_text))

/datum/mafia_role/mafia/proc/mafia_text(datum/mafia_controller/source)
	SIGNAL_HANDLER

	to_chat(body,"<b>Голосуйте, кого вы хотите убить ночью. Убийца будет выбран случайно из числа проголосовавших.</b>")

//better detective for mafia
/datum/mafia_role/mafia/thoughtfeeder
	name = "Пожиратель Разума"
	desc = "Вы - вариация генокрада, которая питается памятью других. Используй ':z' чтобы разговаривать со своими коллегами и посещайте людей по ночам, чтобы узнать их роль."
	role_type = MAFIA_SPECIAL
	hud_icon = "hudthoughtfeeder"
	revealed_icon = "thoughtfeeder"

	targeted_actions = list("Learn Role")
	var/datum/mafia_role/current_investigation

/datum/mafia_role/mafia/thoughtfeeder/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,PROC_REF(investigate))

/datum/mafia_role/mafia/thoughtfeeder/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/mafia/thoughtfeeder/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	to_chat(body,"<span class='warning'>Вы будете наслаждаться воспоминаниями [target.body.real_name] ночью.</span>")
	current_investigation = target

/datum/mafia_role/mafia/thoughtfeeder/proc/investigate(datum/mafia_controller/game)
	SIGNAL_HANDLER
	if(!current_investigation)
		return

	var/datum/mafia_role/target = current_investigation
	current_investigation = null
	if(!target.can_action(game, src, "пожирание разума"))
		add_note("N[game.turn] - [target.body.real_name] - Не может быть расследован")
		return
	if((target.role_flags & ROLE_UNDETECTABLE))
		to_chat(body,"<span class='warning'>Память [target.body.real_name] показывает, что он является Ассистентом.</span>")
		add_note("N[game.turn] - [target.body.real_name] - Ассистент")
	else
		to_chat(body,"<span class='warning'>Память [target.body.real_name] показывает, что он является [target.name].</span>")
		add_note("N[game.turn] - [target.body.real_name] - [target.name]")

///SOLO ROLES/// they range from anomalous factors to deranged killers that try to win alone.

/datum/mafia_role/traitor
	name = "Предатель"
	desc = "Вы предатель-одиночка. Вы невосприимчивы к ночным убийствам, но можете убивать каждую ночь. Убейте всех, чтобы победить."
	win_condition = "убей всех."
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_KILL
	role_flags = ROLE_CAN_KILL
	revealed_outfit = /datum/outfit/mafia/traitor
	revealed_icon = "traitor"
	hud_icon = "hudtraitor"
	special_theme = "neutral"

	targeted_actions = list("Night Kill")
	var/datum/mafia_role/current_victim

/datum/mafia_role/traitor/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,PROC_REF(nightkill_immunity))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_KILL_PHASE,PROC_REF(try_to_kill))

/datum/mafia_role/traitor/check_total_victory(alive_town, alive_mafia) //serial killers just want teams dead, they cannot be stopped by killing roles anyways
	return alive_town + alive_mafia <= 1

/datum/mafia_role/traitor/block_team_victory(alive_town, alive_mafia) //no team can win until they're dead
	return TRUE //while alive, town AND mafia cannot win (though since mafia know who is who it's pretty easy to win from that point)

/datum/mafia_role/traitor/proc/nightkill_immunity(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(game.phase == MAFIA_PHASE_NIGHT && !lynch)
		to_chat(body,"<span class='userdanger'>Вы были атакованы, но им придётся приложить больше усилий, чтобы усмирить тебя.</span>")
		return MAFIA_PREVENT_KILL

/datum/mafia_role/traitor/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(game.phase != MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE || target == src)
		return FALSE

/datum/mafia_role/traitor/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	current_victim = target
	to_chat(body,"<span class='warning'>Вы попытаетесь убить [target.body.real_name] ночью.</span>")

/datum/mafia_role/traitor/proc/try_to_kill(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_victim)
		return
	var/datum/mafia_role/target = current_victim
	current_victim = null
	if(!target.can_action(game, src, "ночное убийство"))
		return
	if(game_status == MAFIA_ALIVE)
		if(!target.kill(game,src,FALSE))
			to_chat(body,"<span class='danger'>Ваша попытка убить [target.body.real_name] была предотвращена!</span>")
		else
			to_chat(target.body, "<span class='userdanger'>Вы были убиты Предателем!</span>")

/datum/mafia_role/nightmare
	name = "Кошмар"
	desc = "Вы монстр-одиночка. Вас нельзя обнаружить с помощью детективных ролей. Вы можете мерцать светом в любой комнате каждую ночь, становясь невосприимчивым к атакам из них. Дальше, по желанию можете убить всех людей в выбранных комнатах, либо продолжить в них мерцать. Убейте всех, чтобы победить."
	win_condition = "убей всех."
	revealed_outfit = /datum/outfit/mafia/nightmare
	role_flags = ROLE_UNDETECTABLE | ROLE_CAN_KILL
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_KILL
	special_theme = "neutral"
	hud_icon = "hudnightmare"
	revealed_icon = "nightmare"

	targeted_actions = list("Flicker", "Hunt")
	var/list/flickering = list()
	var/datum/mafia_role/flicker_target

/datum/mafia_role/nightmare/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,PROC_REF(flickering_immunity))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_KILL_PHASE,PROC_REF(flicker_or_hunt))

/datum/mafia_role/nightmare/check_total_victory(alive_town, alive_mafia) //nightmares just want teams dead
	return alive_town + alive_mafia <= 1

/datum/mafia_role/nightmare/block_team_victory(alive_town, alive_mafia) //no team can win until they're dead
	return TRUE //while alive, town AND mafia cannot win (though since mafia know who is who it's pretty easy to win from that point)

/datum/mafia_role/nightmare/special_reveal_equip()
	body.set_species(SHADOWLING)
	body.cut_overlays()
	var/image/I = image('icons/mob/shadowling.dmi', body, "shadowling_ascended")
	body.add_overlay(I)
	var/image/ascend = image(icon = 'icons/mob/shadowling.dmi', icon_state = "shadowling_ascended_ms", layer = ABOVE_LIGHTING_LAYER)
	ascend.plane = ABOVE_LIGHTING_PLANE
	body.add_overlay(ascend)

/datum/mafia_role/nightmare/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || game.phase != MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE)
		return FALSE
	if(action == "Flicker")
		return target != src && !(target in flickering)
	return target == src

/datum/mafia_role/nightmare/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(target == flicker_target)
		to_chat(body,"<span class='warning'>Вы ничего не будете делать ночью.</span>")
		flicker_target = null
	flicker_target = target
	if(action == "Flicker")
		to_chat(body,"<span class='warning'>Вы будете мерцать светом в комнате [target.body.real_name] ночью.</span>")
	else
		to_chat(body,"<span class='danger'>Вы будете охотиться за всеми, в комнате с мерцающим светом.</span>")

/datum/mafia_role/nightmare/proc/flickering_immunity(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER
	if(!attacker)
		return //no chance man, that's a town lynch

	if(attacker in flickering)
		to_chat(body,"<span class='userdanger'>Вас кто-то атаковал в мерцающей комнате. Вы скрылись в тенях.</span>")
		return MAFIA_PREVENT_KILL

/datum/mafia_role/nightmare/proc/flicker_or_hunt(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!flicker_target)
		return
	var/datum/mafia_role/target = flicker_target
	flicker_target = null
	if(!target.can_action(game, src, "мерцание")) //flickering a warden
		return

	if(target != src) //flicker instead of hunt
		to_chat(target.body, "<span class='userdanger'>Свет начинает мерцать и тускнеть. Вы в опасности.</span>")
		flickering += target
		return
	for(var/r in flickering)
		var/datum/mafia_role/role = r
		if(role && role.game_status == MAFIA_ALIVE)
			to_chat(role.body, "<span class='userdanger'>Тёмная фигура появляется из темноты!</span>")
			role.kill(game,src,FALSE)
		flickering -= role

//just helps read better
#define FUGITIVE_NOT_PRESERVING 0//will not become night immune tonight
#define FUGITIVE_WILL_PRESERVE 1 //will become night immune tonight

/datum/mafia_role/fugitive
	name = "Беглец"
	desc = "Вы в бегах. Вы можете стать невосприимчивым к ночным убийствам два раза. Вы выигрываете, дожив до конца игры с кем угодно."
	win_condition = "доживите до конца игры с кем угодно."
	revealed_outfit = /datum/outfit/mafia/fugitive
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudfugitive"

	actions = list("SelfPreservation")
	var/charges = 2
	var/protection_status = FUGITIVE_NOT_PRESERVING

/datum/mafia_role/fugitive/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,PROC_REF(night_start))
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,PROC_REF(night_end))
	RegisterSignal(game,COMSIG_MAFIA_GAME_END,PROC_REF(survived))

/datum/mafia_role/fugitive/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!charges)
		to_chat(body,"<span class='danger'>У вас закончились припасы, и ты больше не сможешь себя защитить.</span>")
		return
	if(game.phase == MAFIA_PHASE_NIGHT)
		to_chat(body,"<span class='danger'>У вас нет времени готовиться, ночь уже наступила.</span>")
		return
	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,"<span class='danger'>Вы решаете не готовиться к ночи.</span>")
	else
		to_chat(body,"<span class='danger'>Вы решаете подготовиться к ужасной ночи.</span>")
	protection_status = !protection_status

/datum/mafia_role/fugitive/proc/night_start(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,"<span class='danger'>Ваша подготовка завершена. Ничто не сможет вас убить ночью!</span>")
		RegisterSignal(src,COMSIG_MAFIA_ON_KILL,PROC_REF(prevent_death))

/datum/mafia_role/fugitive/proc/night_end(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == FUGITIVE_WILL_PRESERVE)
		charges--
		UnregisterSignal(src,COMSIG_MAFIA_ON_KILL)
		var/nights = pluralize_russian(charges, "одну ночь", "две ночи", "несколько ночей")
		to_chat(body,"<span class='danger'>Вы больше не защищены. Вы имеете припасов еще на [nights].</span>")
		protection_status = FUGITIVE_NOT_PRESERVING

/datum/mafia_role/fugitive/proc/prevent_death(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	to_chat(body,"<span class='userdanger'>Вы были атакованы! К счастью, вы были готовы к этому!</span>")
	return MAFIA_PREVENT_KILL

/datum/mafia_role/fugitive/proc/survived(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(game_status == MAFIA_ALIVE)
		game.send_message("<span class='comradio'>!! ПОБЕДА БЕГЛЕЦА !!</span>")

#undef FUGITIVE_NOT_PRESERVING
#undef FUGITIVE_WILL_PRESERVE

/datum/mafia_role/obsessed
	name = "Одержимый"
	desc = "Вы полностью потерялись в своём разуме. Вы победите, казнив свою Одержимость, прежде чем убьют тебя в этой суматохе. Одержимость назначается в первую же ночь."
	win_condition = "казни свою Одержимость."
	revealed_outfit = /datum/outfit/mafia/obsessed
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudobsessed"
	revealed_icon = "obsessed"

	var/datum/mafia_role/obsession
	var/lynched_target = FALSE

/datum/mafia_role/obsessed/New(datum/mafia_controller/game) //note: obsession is always a townie
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,PROC_REF(find_obsession))

/datum/mafia_role/obsessed/proc/find_obsession(datum/mafia_controller/game)
	SIGNAL_HANDLER

	var/list/all_roles_shuffle = shuffle(game.all_roles)
	for(var/role in all_roles_shuffle)
		var/datum/mafia_role/possible = role
		if(possible.team == MAFIA_TEAM_TOWN && possible.game_status != MAFIA_DEAD)
			obsession = possible
			break
	if(!obsession)
		obsession = pick(all_roles_shuffle) //okay no town just pick anyone here
	//if you still don't have an obsession you're playing a single player game like i can't help your dumb ass
	to_chat(body, "<span class='userdanger'>[obsession.body.real_name] - твоя Одержимость! Пусть её казнят, чтобы победить!</span>")
	add_note("N[game.turn] - Я поклялся увидеть, как мою Одержимость, [obsession.body.real_name], казнят!") //it'll always be N1 but whatever
	RegisterSignal(obsession,COMSIG_MAFIA_ON_KILL,PROC_REF(check_victory))
	UnregisterSignal(game,COMSIG_MAFIA_SUNDOWN)

/datum/mafia_role/obsessed/proc/check_victory(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	UnregisterSignal(source,COMSIG_MAFIA_ON_KILL)
	if(game_status == MAFIA_DEAD)
		return
	if(lynch)
		game.send_message("<span class='comradio'>!! ПОБЕДА ОДЕРЖИМОГО !!</span>")
		reveal_role(game, FALSE)
	else
		to_chat(body, "<span class='userdanger'>Вы провалили свою цель казнить [obsession.body.real_name]!</span>")

/datum/mafia_role/clown
	name = "Клоун"
	desc = "Если вас казнят, то вы забираете с собой одного из ваших избирателей (ВИНОВЕН или воздержался) и побеждаете. ХОНК!"
	win_condition = "пусть они казнят сами себя!"
	revealed_outfit = /datum/outfit/mafia/clown
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudclown"
	revealed_icon = "clown"

/datum/mafia_role/clown/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,PROC_REF(prank))

/datum/mafia_role/clown/proc/prank(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(lynch)
		var/datum/mafia_role/victim = pick(game.judgement_guilty_votes + game.judgement_abstain_votes)
		game.send_message("<span class='clown'>[body.real_name] БЫЛ КЛОУНОМ! ХОНК! Он забирает [victim.body.real_name] со своей последней шуткой.</span>")
		game.send_message("<span class='clown'>!! ПОБЕДА КЛОУНА !!</span>")
		victim.kill(game,FALSE)
