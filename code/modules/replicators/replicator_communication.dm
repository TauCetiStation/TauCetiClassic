/mob/living/simple_animal/hostile/proc/filter_swears(message)
	var/static/list/swears = list(
		regex(@"(о?)([ёе]б)([ауоиеыёнлсбт]?)") =  "$1реплик$3",
		regex(@"([ёе]пт)") =  "бупт",
		regex(@"(су[чк])") =  "малорот",
		regex(@"хуй") =  "кристалл",
		regex(@"(о?)(ху)([оиеёяю])") =  "$1кристалл$3",
		regex(@"хер") =  "кристалл",
		regex(@"хрен") =  "кристалл",
		regex(@"(елд)([аеоы])") =  "кристалл$2",
		regex(@"п[ие]зд") =  "узл",
		regex(@"манд") =  "узл",
		regex(@"бля") =  "бип",
		regex(@"дерьм") =  "паутин",
		regex(@"г[ао][мв]е?н") =  "паутин",
		regex(@"д[еи]би[клч]") =  "малоротик",
		regex(@"идиот") =  "малоротик",
		regex(@"лох") =  "малоротик",
		regex(@"лош(ара|ок|пед)") =  "малоротик",
		regex(@"ублюд") =  "малорот",
		regex(@"даун") =  "треснут",
		regex(@"мраз") =  "тесл",
		regex(@"гнид") =  "тесл",
		regex(@"сра[тлн]") =  "фрактал",
		regex(@"зас[еи]р") =  "зафрактал",
		regex(@"пид[ао]р") =  "генератор",
		regex(@"педик") =  "генератор",
		regex(@"шлю[хш]") =  "дрон",
		regex(@"шалав") =  "дрон",
		regex(@"муд") =  "рой",
		regex(@"залуп") =  "блюспейс",
		regex(@"чмо") =  "реплика",
		regex(@"г[ао]ндон") =  "портал",
		regex(@"жоп") =  "рун",
		regex(@"дроч") =  "строй",
		regex(@"др[иы]с") =  "свис",
		regex(@"трах") =  "строй",
		regex(@"малаф") =  "паутин",
		regex(@"с[сц]а([тл])") =  "ви$1",
		regex(@"с[сц]у") =  "вью",
		regex(@"с[сц]ан") =  "паутин",
		regex(@"бзд") =  "вис",
		regex(@"п[её]рд?(н?)") =  "вис$1",
	)
	return replace_characters(message, swears)

/mob/living/simple_animal/hostile/replicator/say(message)
	if(stat != CONSCIOUS)
		return

	message = sanitize(message)

	if(!message)
		return

	if(message[1] == "*")
		return emote(copytext(message, 2))

	message = add_period(capitalize(filter_swears(lowertext(trim(message)))))

	var/indicator = say_test(message)
	var/ending = ""
	if(indicator == 1)
		ending = "?"
	else if(indicator == 2)
		ending = "!"

	log_say("[key_name(src)] : [message]")

	emote("beep[ending]")

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.announce_swarm(last_controller_ckey, message, announcer=src)

/datum/faction/replicators/proc/send_to_chat(mob/target, message, unprocessed_message, mob/speaker=null)
	if(speaker && target.client && target.client.prefs.show_runechat)
		var/list/span_list = list()
		if(copytext_char(message, -2) == "!!")
			span_list.Add("yell")
		target.show_runechat_message(speaker, null, capitalize(unprocessed_message), span_list)

	to_chat(target, message)

/datum/faction/replicators/proc/swarm_chat_message(presence_name, message, font_size, announcer=null)
	var/list/listening = list()

	for(var/mob/M as anything in mob_list)
		if(!M.client)
			continue

		if(M.mind && M.mind.GetRole(REPLICATOR))
			listening |= M

		else if(isobserver(M))
			listening |= M

	for(var/m in listening)
		var/mob/M = m

		var/message_span_class = "message replicator"
		if(announcer && get_dist(announcer, M) < 7)
			message_span_class += " bold"

		var/channel = "<span class='replicator'>\[???\]</span>"
		var/speaker_name = "<b>[presence_name]</b>"

		var/jump_button = ""
		if(announcer && isreplicator(M))
			jump_button = " <a href='?src=\ref[announcer];replicator_jump=1'>(JMP)</a>"

		if(isobserver(M))
			speaker_name = "[FOLLOW_LINK(M, announcer)] [speaker_name]"

		send_to_chat(
			M,
			"<font size='[font_size]'>[speaker_name] [channel] announces, <span class='[message_span_class]'>\"[message]\"</span>[jump_button]</font>",
			message,
			speaker=announcer,
		)

/datum/faction/replicators/proc/announce_swarm(presence_ckey, message, atom/announcer=null)
	var/font_size = 2.0

	var/datum/replicator_array_info/RAI = ckey2info[presence_ckey]
	var/datum/replicator_array_info/RAI_max = ckey2info[max_goodwill_ckey]

	if(RAI && RAI_max && RAI_max.swarms_goodwill > 0.0)
		var/goodwill_coeff = RAI.swarms_goodwill / RAI_max.swarms_goodwill
		var/goodwill_font_size = clamp(CEIL(goodwill_coeff * 3.0) + 1.0, 2.0, 4.0)

		font_size = goodwill_font_size

	swarm_chat_message(RAI.presence_name, message, font_size, announcer=announcer)

// Mines currently also use this.
/datum/faction/replicators/proc/drone_message(atom/drone, message, transfer=FALSE, dismantle=FALSE, objection_time=0)
	if(isreplicator(drone))
		var/mob/living/simple_animal/hostile/replicator/R = drone
		R.objection_end_time = world.time + objection_time

	for(var/r in members)
		var/datum/role/replicator/R = r
		if(!R.antag)
			continue
		var/jump_button = transfer ? " <a href='?src=\ref[drone];replicator_jump=1'>(JMP)</a>" : ""
		var/dismantle_button = dismantle ? " <a href='?src=\ref[drone];replicator_kill=1'>(KILL)</a>" : ""
		var/objection_button = objection_time > 0 ? " <a href='?src=\ref[drone];replicator_objection=1;id='>(OBJ)</a>" : ""
		var/processed_message = "<b>[drone.name]</b> <span class='replicator'>\[???\]</span> requests, <span class='message'><span class='replicator'>\"[message]\"</span></span>[jump_button][dismantle_button][objection_button]"

		send_to_chat(R.antag.current, processed_message, message, speaker=drone)

/datum/faction/replicators/proc/object_communicate(atom/object, tone, message, transfer=FALSE)
	object.visible_message("<b>[object]</b> <i>beeps[tone]</i>")

	var/indicator = say_test(tone)

	var/image/emote_bubble = image('icons/mob/emote.dmi', src, "robot[indicator]", EMOTE_LAYER)
	emote_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	flick_overlay(emote_bubble, global.clients, 3 SECONDS)
	QDEL_IN(emote_bubble, 3 SECONDS)

	playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER, 75)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.drone_message(object, message, transfer=transfer)
