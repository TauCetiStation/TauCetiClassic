/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

	show_examine_log = FALSE

/mob/living/captive_brain/say_understands(mob/other, datum/language/speaking)
	var/mob/living/simple_animal/borer/my_borer = loc
	if(!istype(loc))
		return FALSE
	return other == my_borer.host

/mob/living/captive_brain/say(message)

	if (client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if(istype(loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = loc
		to_chat(src, "You whisper silently, \"[message]\"")
		to_chat(B.host, "The captive mind of [src] whispers, \"[message]\"")

		for (var/mob/M in player_list)
			if (isnewplayer(M))
				continue
			if(M.stat == DEAD &&  M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
				to_chat(M, "[FOLLOW_LINK(M, src)] The captive mind of [src] whispers, \"[message]\"")

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "Маленькое существо, похожее на слизняка."
	speak_emote = list("шипит")
	emote_hear = list("шипит")
	response_help  = "pokes the"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = FALSE
	pass_flags = PASSTABLE
	ventcrawler = 2
	w_class = SIZE_MINUSCULE

	var/truename // Name used for brainworm-speak.
	var/generation = 1
	var/static/list/borer_names = list(
		"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
		"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
		)

	var/static/list/banned_species = list(IPC, GOLEM, SLIME, DIONA)

	var/dominate_cd = 0                        // Cooldown for dominate victim
	var/assuming = FALSE
	var/chemicals = 10                         // Chemicals used for reproduction and spitting neurotoxin.
	var/const/max_chemicals = 250              // Maximum chemicals
	var/mob/living/carbon/host                 // Carbon host for the brain worm.
	var/mob/living/captive_brain/host_brain    // Used for swapping control of the body back and forth.
	var/controlling = FALSE                    // Used in human death check.
	var/docile = FALSE                         // Sugar can stop borers from acting.
	var/leaving = FALSE
	var/has_reproduced = FALSE                 // Whether or not the borer has reproduced, for objective purposes.

	show_examine_log = FALSE

/mob/living/simple_animal/borer/atom_init(mapload, request_ghosts = FALSE, gen = 1)
	. = ..()
	generation = gen
	truename = "[borer_names[min(generation, borer_names.len)]] [rand(1000, 9999)]"
	real_name = truename

	host_brain = new/mob/living/captive_brain(src)
	if(request_ghosts)
		create_spawner(/datum/spawner/living/borer, src)

/mob/living/simple_animal/borer/attack_ghost(mob/dead/observer/O)
	try_request_n_transfer(O, "Cortical Borer, are you sure?", ROLE_GHOSTLY, , show_warnings = TRUE)

/mob/living/simple_animal/borer/Life()
	..()

	if(!host)
		return

	if(stat != CONSCIOUS && host.stat != CONSCIOUS)
		return

	if(host.reagents.has_reagent("sugar") && !docile)
		docile = TRUE
		var/mob/msg_to = controlling ? host : src
		to_chat(msg_to, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
	else if(docile)
		docile = FALSE
		var/mob/msg_to = controlling ? host : src
		to_chat(msg_to, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")

	if(chemicals < max_chemicals)
		chemicals++

	if(controlling)
		if(docile)
			to_chat(host, "<span class='notice'>You are feeling far too docile to continue controlling your host...</span>")
			host.release_control()
			return
		if(prob(5))
			host.adjustBrainLoss(rand(1,2))
		if(prob(host.getBrainLoss() * 0.05))
			host.emote("[pick(list("blink", "choke", "drool", "twitch", "gasp"))]")

/mob/living/simple_animal/borer/say_understands(mob/other, datum/language/speaking)
	return host == other

/mob/living/simple_animal/borer/say(message)

	message = capitalize(sanitize(message))
	if(!message)
		return

	log_say("[key_name(src)] : [message]")

	if (stat == DEAD)
		return say_dead(message)

	if (stat != CONSCIOUS)
		return

	if (client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	if (message[1] == "*")
		return emote(copytext(message, 2))

	if (message[1] == ";") //Brain borer hivemind.
		return borer_speak(message)

	if(!host)
		to_chat(src, "You have no host to speak to.")
		return //No host, no audible speech.

	to_chat(src, "You drop words into [host]'s mind: \"[message]\"")
	to_chat(host, "Your own thoughts speak: \"[message]\"")

	for (var/mob/M in player_list)
		if (isnewplayer(M))
			continue
		if(M.stat == DEAD &&  M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
			to_chat(M, "[FOLLOW_LINK(M, src)] [truename] whispers to [host], \"[message]\"")


/mob/living/simple_animal/borer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Chemicals: [chemicals]/[max_chemicals]")

/mob/living/simple_animal/borer/proc/borer_speak(message)
	if(!message)
		return

	for(var/mob/M as anything in mob_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || isobserver(M)))
			to_chat(M, "<i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i>")

// VERBS!
/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Dominate Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - dominate_cd < 300)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	if(host)
		to_chat(src, "You cannot do that from within a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot do that in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != DEAD && !(C.get_species() in banned_species))
			choices += C

	if(world.time - dominate_cd < 300)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") as null|anything in choices
	if(!M || incapacitated() || host)
		return

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	to_chat(src, "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>")
	to_chat(M, "<span class='warning'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
	M.Stun(3)
	M.Weaken(3)

	dominate_cd = world.time

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(assuming)
		to_chat(src, "You are already assuming a host body!")
		return

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot do that in your current state.")
		return

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		if(!H.organs_by_name[O_BRAIN]) //this should only run in admin-weirdness situations, but it's here non the less - RR
			to_chat(src, "<span class='warning'>There is no brain here for us to command!</span>")
			return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	to_chat(src, "You begin delicately adjusting your connection to the host brain...")
	assuming = TRUE

	addtimer(CALLBACK(src, PROC_REF(take_control)), 300 + (host.brainloss * 5))

/mob/living/simple_animal/borer/proc/take_control()
	assuming = FALSE
	if(!host || !src || controlling)
		return

	to_chat(src, "<span class='warning'><B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B></span>")
	to_chat(host, "<span class='warning'><B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B></span>")

	host_brain.ckey = host.ckey
	host.ckey = ckey
	controlling = TRUE

	host.verbs += /mob/living/carbon/proc/release_control
	host.verbs += /mob/living/carbon/proc/punish_host
	host.verbs += /mob/living/carbon/proc/spawn_larvae

	host.med_hud_set_status()

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals(50)"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot secrete chemicals in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in list("bicaridine","tramadol","nuka_cola","alkysine")
	if(!chem)
		return

	if(chemicals < 50)
		to_chat(src, "You don't have enough chemicals!")
		return

	if(!host || controlling || docile || incapacitated()) //Sanity check.
		return

	to_chat(src, "<span class='warning'><B>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</B></span>")
	host.reagents.add_reagent(chem, 15)
	chemicals -= 50

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot leave your host in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(src, "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.")

	leaving = TRUE

	if(host.stat == CONSCIOUS)
		to_chat(host, "An odd, uncomfortable pressure begins to build inside your skull, behind your ear...")

	addtimer(CALLBACK(src, PROC_REF(let_go)), 200)

/mob/living/simple_animal/borer/proc/let_go()
	if(!host || !src || QDELETED(host) || QDELETED(src))
		return
	if(!leaving)
		return
	if(controlling)
		return
	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return
	to_chat(src, "You wiggle out of [host]'s ear and plop to the ground.")

	leaving = FALSE

	if(host.stat == CONSCIOUS)
		to_chat(host, "Something slimy wiggles out of your ear and plops to the ground!")

	detatch()

/mob/living/simple_animal/borer/proc/detatch()
	if(!host)
		return

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]

		BP.implants -= src
		if(H.glasses?.hud_list)
			for(var/hud in H.glasses.hud_list)
				var/datum/atom_hud/AH = global.huds[hud]
				AH.remove_hud_from(src)

	forceMove(get_turf(host))
	controlling = FALSE

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae

	if(host_brain.ckey)
		ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"
	host.parasites -= src
	host = null

/mob/living/simple_animal/borer/verb/infest()
	set category = "Borer"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != DEAD && Adjacent(C) && !(C.get_species() in banned_species))
			choices += C

	var/mob/living/carbon/C = input(src, "Who do you wish to infest?") as null|anything in choices
	if(!C || incapacitated() || host)
		return

	if(!Adjacent(C))
		return

	if(C.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.check_head_coverage())
			to_chat(src, "You cannot get through that host's protective gear.")
			return

	if(is_busy())
		return

	to_chat(C, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(src, "You slither up [C] and begin probing at their ear canal...")

	if(!do_after(src, 50, target = C))
		to_chat(src, "As [C] moves away, you are dislodged and fall to the ground.")
		return

	if(!C || !src)
		return

	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(C.stat == DEAD)
		to_chat(src, "That is not an appropriate target.")
		return

	if(!(C in view(1, src)))
		to_chat(src, "They are no longer in range!")
		return

	to_chat(src, "You wiggle into [C]'s ear.")
	if(C.stat == CONSCIOUS)
		to_chat(C, "Something disgusting and slimy wiggles into your ear!")

	host = C
	forceMove(C)

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		BP.implants += src
		H.sec_hud_set_implants()

	host_brain.name = C.name
	host_brain.real_name = C.real_name
	host.parasites += src

// Borers will not be blind in ventilation
/mob/living/simple_animal/borer/is_vision_obstructed()
	if(istype(loc, /obj/machinery/atmospherics/pipe))
		return FALSE
	return ..()

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/borer/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Borer"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

/mob/living/simple_animal/borer/transfer_personality(client/candidate)

	if(!candidate)
		return

	ckey = candidate.ckey

	var/datum/faction/borers/B = find_faction_by_type(/datum/faction/borers)
	if(B)
		add_faction_member(B, src)
