/datum/component/talking_atom
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/list/heard_words = list()
	var/last_talk_time = 0
	var/talk_interval = 50
	var/talk_chance = 10

/datum/component/talking_atom/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/talking_atom/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(catchMessage))

	var/atom/movable/talking_parent = parent
	talking_parent.flags ^= HEAR_TA_SAY // only one such component currently
	                                    // need to refactore/optimise hear code and get rid of HEAR_TA_SAY
	                                    // or make common hear_say component for atoms and make talking_atom use this new comp

/datum/component/talking_atom/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)

	var/atom/movable/talking_parent = parent
	talking_parent.flags ^= HEAR_TA_SAY

/datum/component/talking_atom/process()
	if(heard_words.len >= 1 && world.time > last_talk_time + talk_interval && prob(talk_chance))
		SaySomething()

/datum/component/talking_atom/proc/catchMessage(datum/source, msg, mob/speaker)
	var/atom/movable/talking_parent = parent

	var/list/seperate = list()
	if(findtext(msg,"(("))
		return
	else if(findtext(msg,"))"))
		return
	else if(findtext(msg," ")==0)
		return
	else
		/*var/l = lentext(msg)
		if(findtext(msg," ",l,l+1)==0)
			msg+=" "*/
		seperate = splittext(msg, " ")

	for(var/Xa = 1,Xa<seperate.len,Xa++)
		var/next = Xa + 1
		if(heard_words.len > 20 + rand(10,20))
			heard_words.Remove(heard_words[1])
		if(!heard_words["[lowertext(seperate[Xa])]"])
			heard_words["[lowertext(seperate[Xa])]"] = list()
		var/list/w = heard_words["[lowertext(seperate[Xa])]"]
		if(w)
			w.Add("[lowertext(seperate[next])]")
		//world << "Adding [lowertext(seperate[next])] to [lowertext(seperate[Xa])]"

	if(prob(30))
		var/list/options = list("[talking_parent] seems to be listening intently to [speaker]...",\
			"[talking_parent] seems to be focussing on [speaker]...",\
			"[talking_parent] seems to turn it's attention to [speaker]...")
		talking_parent.loc.visible_message("<span class='notice'>[bicon(talking_parent)] [pick(options)]</span>")

	if(prob(20))
		spawn(2)
			SaySomething(pick(seperate))

/*/obj/item/weapon/talkingcrystal/proc/debug()
	//set src in view()
	for(var/v in heard_words)
		to_chat(world, "[uppertext(v)]")
		var/list/d = heard_words["[v]"]
		for(var/X in d)
			to_chat(world, "[X]")*/

/datum/component/talking_atom/proc/SaySomething(word = null)
	var/atom/movable/talking_parent = parent

	var/msg
	var/limit = rand(max(5,heard_words.len/2))+3
	var/text
	if(!word)
		text = "[pick(heard_words)]"
	else
		text = pick(splittext(word, " "))
	text = capitalize(text)
	var/q = 0
	msg+=text
	//TODO:CYRILLIC
	if(msg=="What" | msg == "Who" | msg == "How" | msg == "Why" | msg == "Are")
		q=1

	text=lowertext(text)
	for(var/ya,ya <= limit,ya++)

		if(heard_words.Find("[text]"))
			var/list/w = heard_words["[text]"]
			text=pick(w)
		else
			text = "[pick(heard_words)]"
		msg+=" [text]"
	if(q)
		msg+="?"
	else
		if(rand(0,10))
			msg+="."
		else
			msg+="!"

	// todo: bad copypaste of say code, some mobs will not hear it
	var/list/listening = viewers(talking_parent)
	for(var/mob/M as anything in observer_list)
		if (!M.client)
			continue //skip leavers
		if(M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
			listening |= M

	for(var/mob/M in listening)
		to_chat(M, "[bicon(talking_parent)] <b>[talking_parent]</b> reverberates, <span class='notice'>\"[msg]\"</span>")
	last_talk_time = world.time
