#define BORER_MODE_DETACHED 0
#define BORER_MODE_SEVERED 1
#define BORER_MODE_ATTACHED_HEAD 2
#define BORER_MODE_ATTACHED_CHEST 3
#define BORER_MODE_ATTACHED_ARM 4
#define BORER_MODE_ATTACHED_LEG 5

var/global/borer_chem_types_head = typesof(/datum/borer_chem/head) - /datum/borer_chem - /datum/borer_chem/head
var/global/borer_chem_types_chest = typesof(/datum/borer_chem/chest) - /datum/borer_chem - /datum/borer_chem/chest
var/global/borer_chem_types_arm = typesof(/datum/borer_chem/arm) - /datum/borer_chem - /datum/borer_chem/arm
var/global/borer_chem_types_leg = typesof(/datum/borer_chem/leg) - /datum/borer_chem - /datum/borer_chem/leg
var/global/borer_unlock_types_head = typesof(/datum/unlockable/borer/head) - /datum/unlockable/borer - /datum/unlockable/borer/head - /datum/unlockable/borer/head/chem_unlock - /datum/unlockable/borer/head/verb_unlock
var/global/borer_unlock_types_chest = typesof(/datum/unlockable/borer/chest) - /datum/unlockable/borer - /datum/unlockable/borer/chest - /datum/unlockable/borer/chest/chem_unlock - /datum/unlockable/borer/chest/verb_unlock
var/global/borer_unlock_types_arm = typesof(/datum/unlockable/borer/arm) - /datum/unlockable/borer - /datum/unlockable/borer/arm - /datum/unlockable/borer/arm/chem_unlock - /datum/unlockable/borer/arm/verb_unlock
var/global/borer_unlock_types_leg = typesof(/datum/unlockable/borer/leg) - /datum/unlockable/borer - /datum/unlockable/borer/leg - /datum/unlockable/borer/leg/chem_unlock - /datum/unlockable/borer/leg/verb_unlock

/mob/living/simple_animal/borer
	name = "borer"
	real_name = "borer"
	desc = "A small, quivering sluglike creature"
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes the"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 6
	min_oxy = 16
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	layer = MOB_LAYER
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 1)
	density = FALSE
	a_intent = "harm"
	stop_automated_movement = TRUE
	attacktext = "nips"
	friendly = "prods"
	wander = FALSE
	pass_flags = PASSTABLE
	universal_understand = TRUE
	ventcrawler = 2

	var/busy = FALSE // So we aren't trying to lay many eggs at once.

	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/hostlimb = null						// Which limb of the host is inhabited by the borer.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/list/avail_chems = list()
	var/list/unlocked_chems_head = list()
	var/list/unlocked_chems_chest = list()
	var/list/unlocked_chems_arm = list()
	var/list/unlocked_chems_leg = list()
	var/list/avail_abilities = list()         // Unlocked powers.
	var/list/attached_verbs_head = list(/obj/item/verbs/borer/attached_head)
	var/list/attached_verbs_chest = list(/obj/item/verbs/borer/attached_chest)
	var/list/attached_verbs_arm = list(/obj/item/verbs/borer/attached_arm)
	var/list/attached_verbs_leg = list(/obj/item/verbs/borer/attached_leg)
	var/list/severed_verbs = list(/obj/item/verbs/borer/severed)
	var/list/detached_verbs = list(/obj/item/verbs/borer/detached)
	var/numChildren = 0

	var/datum/research_tree/borer/research
	var/list/verb_holders = list()
	var/list/borer_avail_unlocks_head = list()
	var/list/borer_avail_unlocks_chest = list()
	var/list/borer_avail_unlocks_arm = list()
	var/list/borer_avail_unlocks_leg = list()

	var/channeling = FALSE //For abilities that require constant expenditure of chemicals.
	var/channeling_night_vision = FALSE
	var/channeling_bone_sword = FALSE
	var/channeling_bone_shield = FALSE

	var/static/list/name_prefixes = list("Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary", "Septenary", "Octonary", "Nonary", "Denary")
	var/name_prefix_index = 1

	var/can_assume_control = TRUE
	var/can_lay_eggs = TRUE
	var/can_damage_host_brain = TRUE

/mob/living/simple_animal/borer/whisper()
	return FALSE

/mob/living/simple_animal/borer/atom_init(mapload, loc, egg_prefix_index = 1)
	.=..()
	name_prefix_index = min(egg_prefix_index, 10)
	truename = "[name_prefixes[name_prefix_index]] [capitalize(pick(list("Alpha", "Beta", "Gamma", "Sigma")))] [rand(1,9999)]"
	host_brain = new/mob/living/captive_brain(src)

	if(name == initial(name))
		name = "[name] ([rand(1, 1000)])"
		real_name = name
	update_verbs(BORER_MODE_DETACHED)

	research = new (src)

	for(var/ultype in borer_unlock_types_head)
		var/datum/unlockable/borer/head/U = new ultype()
		if(U.id != "")
			borer_avail_unlocks_head.Add(U)
	for(var/ultype in borer_unlock_types_chest)
		var/datum/unlockable/borer/chest/U = new ultype()
		if(U.id != "")
			borer_avail_unlocks_chest.Add(U)
	for(var/ultype in borer_unlock_types_arm)
		var/datum/unlockable/borer/arm/U = new ultype()
		if(U.id != "")
			borer_avail_unlocks_arm.Add(U)
	for(var/ultype in borer_unlock_types_leg)
		var/datum/unlockable/borer/leg/U = new ultype()
		if(U.id != "")
			borer_avail_unlocks_leg.Add(U)


/mob/living/simple_animal/borer/Life()
	..()
	if(host)
		if(!stat && !host.stat)
			if(health < 20)
				health += 0.5
			if(chemicals < 250 && !channeling)
				chemicals++
			if(controlling)
				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss / 20))
					host.say("*[pick(list("blink", "blink_r", "choke", "aflap", "drool", "twitch", "twitch_s", "gasp"))]")

	if(client)
		regular_hud_updates()

/mob/living/simple_animal/borer/proc/make_neutered()
	can_assume_control = FALSE
	can_lay_eggs = FALSE
	can_damage_host_brain = FALSE
	desc += ", it seems friendly"

/mob/living/simple_animal/borer/regular_hud_updates()
	var/severity = 0

	var/healthpercent = (health/maxHealth)*100

	switch(healthpercent)
		if(100 to INFINITY)
			healths.icon_state = "borer_health0"
		if(75 to 100)
			healths.icon_state = "borer_health1"
			severity = 2
		if(50 to 75)
			healths.icon_state = "borer_health2"
			severity = 3
		if(25 to 50)
			healths.icon_state = "borer_health3"
			severity = 4
		if(1 to 25)
			healths.icon_state = "borer_health4"
			severity = 5
		else
			healths.icon_state = "borer_health5"
			severity = 6

	if(severity > 0)
		overlay_fullscreen("damage", /obj/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("damage")

/mob/living/simple_animal/borer/proc/update_verbs(mode_in,monkey_host_in)
	var/mode = mode_in
	var/monkey_host = FALSE
	if(monkey_host_in)
		monkey_host = TRUE
	if(verb_holders.len>0)
		for(var/VH in verb_holders)
			qdel(VH)
	verb_holders=list()
	var/list/verbtypes = list()
	avail_chems.len = 0
	switch(mode)
		if(BORER_MODE_DETACHED) // 0
			verbtypes = detached_verbs
		if(BORER_MODE_SEVERED) // 1
			verbtypes = severed_verbs
		if(BORER_MODE_ATTACHED_HEAD) // 2
			verbtypes = attached_verbs_head
			for(var/chemtype in borer_chem_types_head)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_head
		if(BORER_MODE_ATTACHED_CHEST) // 3
			verbtypes = attached_verbs_chest
			for(var/chemtype in borer_chem_types_chest)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_chest
		if(BORER_MODE_ATTACHED_ARM) // 4
			verbtypes=attached_verbs_arm
			for(var/chemtype in borer_chem_types_arm)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name]=C
			avail_chems += unlocked_chems_arm
		if(BORER_MODE_ATTACHED_LEG) // 5
			verbtypes = attached_verbs_leg
			for(var/chemtype in borer_chem_types_leg)
				var/datum/borer_chem/C = new chemtype()
				if(!C.unlockable)
					avail_chems[C.name] = C
			avail_chems += unlocked_chems_leg
	for(var/verbtype in verbtypes)
		verb_holders += new verbtype(src)
	verbs -= /mob/living/simple_animal/borer/proc/bond_brain
	if (monkey_host)
		verbs += /mob/living/simple_animal/borer/proc/bond_brain


/mob/living/simple_animal/borer/Topic(href, href_list)

	switch(href_list["act"])
		if("detach")
			to_chat(src, "<span class='danger'>You feel dazed, and then appear outside of your host!</span>")
			if(host)
				to_chat(host, "<span class='info'>You no longer feel the presence in your mind!</span>")
			detach()
		if("release")
			if(host)
				host.do_release_control()
		if("verbs")
			update_verbs(!isnull(host))
		if("add_chem")
			var/chemID = input("Chem name (ex: creatine):","Chemicals") as text|null
			if(isnull(chemID))
				return
			var/datum/borer_chem/C = new /datum/borer_chem()
			C.id = chemID
			var/datum/reagent/chem = chemical_reagents_list[C.id]
			C.name = chem.name
			C.cost = 0
			avail_chems[C.name] = C
			to_chat(usr, "ADDED!")
			to_chat(src, "<span class='info'>You learned how to secrete [C.name]!</span>")


/mob/living/simple_animal/borer/say(m)
	var/message = m
	message = trim(copytext(message, 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if(!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (copytext(message, 1, 2) == "*")
		to_chat(src, "<span class = 'notice'>This type of mob doesn't support this. Use the Me verb instead.</span>")
		return

	if (copytext(message, 1, 2) == ";") // Brain borer hivemind.
		return borer_speak(copytext(message,2))

	if(!host)
		to_chat(src, "You have no host to speak to.")
		return // No host, no audible speech.

	var/encoded_message = html_encode(message)

	to_chat(src, "You drop words into [host]'s body: <span class='borer2host'>\"[encoded_message]\"</span>")
	if(host)
		to_chat(host, "<b>Something speaks within you:</b> <span class='borer2host'>\"[encoded_message]\"</span>")
	else if(hostlimb == BP_HEAD)
		to_chat(host, "<b>Your mind speaks to you:</b> <span class='borer2host'>\"[encoded_message]\"</span>")
	else
		to_chat(host, "<b>Your [limb_to_name(hostlimb)] speaks to you:</b> <span class='borer2host'>\"[encoded_message]\"</span>")
	var/list/borers_in_host = host.get_brain_worms()
	borers_in_host.Remove(src)
	if(borers_in_host.len)
		for(var/I in borers_in_host)
			to_chat(I, "<b>[truename]</b> speaks from your host's [limb_to_name(hostlimb)]: <span class='borer2host'>\"[encoded_message]\"</span>")

	var/turf/T = get_turf(src)
	log_say("[truename] [key_name(src)] (@[T.x],[T.y],[T.z]) -> [host]([key_name(host)]) Borer->Host Speech: [message]")

	for(var/mob/M in player_list)
		if(isnewplayer(M))
			continue
		if(istype(M,/mob/dead/observer)  && (M.client && M.client.prefs.toggles & CHAT_GHOSTEARS || (get_turf(src) in view(M))))
			var/controls = "<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>F</a>"
			if(M.client.holder)
				controls+= " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
			var/rendered="<span class='thoughtspeech'>Thought-speech, <b>[truename]</b> ([controls]) in <b>[host]</b>'s [limb_to_name(hostlimb)]: [encoded_message]</span>"
			M.show_message(rendered, 2) //Takes into account blindness and such.

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/dead/observer)))
			to_chat(M, "<i>Thought-speech, <b>[truename]</b> -> <b>[host]:</b> [copytext(html_encode(message), 2)]</i>")


/mob/living/simple_animal/borer/Stat()
	..()
	if(statpanel("Status"))
		stat("Health", health)
		stat("Chemicals", chemicals)


// VERBS!
/mob/living/simple_animal/borer/proc/borer_speak(m)
	var/message = m
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your brethren."
	if(!message)
		return
	if(src.stat)
		to_chat(src, "<span class='warning'>You cannot transmit over the cortical hivemind in your current state.</span>")
		return

	var/turf/T = get_turf(src)
	log_say("[truename] [key_name(src)] (@[T.x],[T.y],[T.z]) Borer Cortical Hivemind: [message]")

	for(var/mob/M in mob_list)
		if(isnewplayer(M))
			continue

		if(istype(M, /mob/living/simple_animal/borer) || (istype(M,/mob/dead/observer) && M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
			var/controls = ""
			if(isobserver(M))
				controls = " (<a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>F</a>"
				if(M.client.holder)
					controls += " | <A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>"
				controls += ") in [host]"

			to_chat(M, "<span class='cortical'>Cortical link, <b>[truename]</b>[controls]: [message]</span>")

/mob/living/simple_animal/borer/proc/bond_brain()
	set category = "Alien"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host. This can ruin a relationship between you and your host, so be careful."

	if(!can_assume_control)
		to_chat(src, "<span class='info'>You are conditioned not to assume control of your host's mind.</span>")
		return

	if(!check_can_do(TRUE))
		return

	if(hostlimb != BP_HEAD)
		to_chat(src, "<span class='info'>You are not attached to your host's brain.</span>")
		return

	if(chemicals <= 150)
		to_chat(src, "<span class='info'>You do not have enough chemicals stored.</span>")
		return

	var/delay_mult = 1
	to_chat(src, "<span class='info'>You begin delicately adjusting your connection to the host brain...</span>")
	var/mob/living/carbon/C = host
	if(istype(C, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		if(H.bodyparts_by_name[BP_HEAD].implants.Find(/obj/item/weapon/implant/mindshield) || H.bodyparts_by_name[BP_HEAD].implants.Find(/obj/item/weapon/implant/mindshield/loyalty))
			to_chat(src, "<span class='info'>...But you feel something pushing back from the host's mind.</span>")
			to_chat(host, "<span class='info'>You feel a slight tingling sensation coming from the inside of your head.</span>")
			delay_mult = 1.5

	chemicals -= 150
	spawn((300 + (host.brainloss * 5)) * delay_mult)

		if(!host || !src || controlling)
			return
		else
			do_bonding(TRUE)

/mob/living/simple_animal/borer/proc/do_bonding(rpt)
	var/rptext
	if(!rpt)
		rptext = rpt
	else
		rptext = TRUE
	if(!host || host.stat==DEAD || !src || controlling || research.unlocking)
		return

	if(rptext)
		to_chat(src, "<span class='danger'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>")
		to_chat(host, "<span class='danger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>")

	host_brain.ckey = host.ckey
	host_brain.name = host.real_name
	host.ckey = src.ckey
	controlling = TRUE

	host.verbs += /mob/living/carbon/proc/release_control

/mob/living/simple_animal/borer/proc/damage_brain()
	set category = "Alien"
	set name = "Retard Host"
	set desc = "Give the host a bit of brain damage. Can be healed with alkysine."

	if(!can_damage_host_brain)
		to_chat(src, "<span class='info'>You are conditioned not to damage your host.</span>")
		return

	if(!check_can_do(TRUE))
		return
	if(chemicals >= 30)
		to_chat(src, "<span class='danger'>You twitch your probosci.</span>")
		to_chat(host, "<span class='danger'>You feel something twitch in your head, and get a horrible headache!</span>")
		chemicals -= 30
		host.adjustBrainLoss(15)
	else
		to_chat(src, "<span class='info'>You do not have enough chemicals stored.</span>")
		return()


/mob/living/simple_animal/borer/proc/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	if(!check_can_do(TRUE))
		return

	research.display(src)

/mob/living/simple_animal/borer/proc/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!check_can_do(TRUE))
		return

	var/chem_name = input("Select a chemical to secrete.", "Chemicals") as null|anything in avail_chems
	if(!chem_name)
		return

	var/datum/borer_chem/chem = avail_chems[chem_name]

	var/max_amount = 50
	if(chem.cost > 0)
		max_amount = round(chemicals / chem.cost)

	if(max_amount == 0)
		to_chat(src, "<span class='warning'>You don't have enough energy to even synthesize one unit!</span>")
		return

	var/units = input("Enter dosage in units.\n\nMax: [max_amount]\nCost: [chem.cost]/unit","Chemicals") as num

	units = round(units)

	if(units < 1)
		to_chat(src, "<span class='warning'>You cannot synthesize this little.</span>")
		return

	if(chemicals < chem.cost * units)
		to_chat(src, "<span class='warning'>You don't have enough energy to synthesize this much!</span>")
		return

	if(!host || controlling || !src || stat)
		return

	if(chem.id == BLOOD)
		if(istype(host, /mob/living/carbon/human))
			var/mob/living/carbon/human/N = host
			if(N.species && !N.species.flags[NO_BLOOD])
				host.vessel.add_reagent(chem.id, units)
			else
				to_chat(src, "<span class='notice'>Your host seems to be a species that doesn't use blood.<span>")
				return
	else
		host.reagents.add_reagent(chem.id, units)

	to_chat(src, "<span class='info'>You squirt a measure of [chem.name] from your reservoirs into [host]'s bloodstream.</span>")
	chemicals -= chem.cost * units


/mob/living/simple_animal/borer/proc/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/severed = istype(loc, /obj/item/organ/external)
	if(!host && !severed)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot leave your host while unconscious.</span>")
		return

	if(channeling)
		to_chat(src, "<span class='warning'>You cannot do this while your focus is directed elsewhere.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot leave your host in your current state.</span>")
		return

	if(research.unlocking && !severed)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	var/response = alert(src, "Are you -sure- you want to abandon your current host?\n(This will take a few seconds and cannot be halted!)","Are you sure you want to abandon host?","Yes","No")
	if(response != "Yes")
		return

	if(!src)
		return

	if(severed)
		if(istype(loc, /obj/item/organ/external/head))
			to_chat(src, "<span class='info'>You begin disconnecting from \the [loc]'s synapses and prodding at its internal ear canal.</span>")
		else
			to_chat(src, "<span class='info'>You begin disconnecting from \the [loc]'s nerve endings and prodding at the surface of its skin.</span>")
	else
		if(hostlimb == BP_HEAD)
			to_chat(src, "<span class='info'>You begin disconnecting from \the [host]'s synapses and prodding at their internal ear canal.</span>")
		else
			to_chat(src, "<span class='info'>You begin disconnecting from \the [host]'s nerve endings and prodding at the surface of their skin.</span>")

	var/leave_time = 200
	if(severed)
		leave_time = 20

	spawn(leave_time)

		if((!host && !severed) || !src)
			return

		if(src.stat)
			to_chat(src, "<span class='warning'>You cannot abandon [host ? host : "\the [loc]"] in your current state.</span>")
			return

		if(channeling)
			to_chat(src, "<span class='warning'>You cannot abandon [host ? host : "\the [loc]"] while your focus is directed elsewhere.</span>")
			return

		if(controlling)
			to_chat(src, "<span class='warning'>You're too busy controlling your host.</span>")
			return

		if(research.unlocking)
			to_chat(src, "<span class='warning'>You are busy evolving.</span>")
			return

		if(severed)
			if(istype(loc, /obj/item/organ/external/head))
				to_chat(src, "<span class='info'>You wiggle out of the ear of \the [loc] and plop to the ground.</span>")
			else
				to_chat(src, "<span class='info'>You wiggle out of \the [loc] and plop to the ground.</span>")
		else
			if(hostlimb == BP_HEAD)
				to_chat(src, "<span class='info'>You wiggle out of \the [host]'s ear and plop to the ground.</span>")
			else
				to_chat(src, "<span class='info'>You wiggle out of \the [host]'s [limb_to_name(hostlimb)] and plop to the ground.</span>")

		detach()

// Try to reset everything, also while handling invalid host/host_brain states.
/mob/living/simple_animal/borer/proc/detach()
	if(host)
		if(istype(host,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = host
			var/obj/item/organ/external/implanted = H.bodyparts_by_name[hostlimb]
			implanted.implants -= src

	src.forceMove(get_turf(src))
	controlling = FALSE

	reset_view(null)
	machine = null

	if(host)
		host.reset_view(null)
		host.machine = null

		host.verbs -= /mob/living/carbon/proc/release_control
		host.verbs -= /mob/living/carbon/proc/punish_host

		// Remove any unlocks that affect the host.
		for(var/uid in research.unlocked.Copy())
			var/datum/unlockable/borer/U = research.get(uid)
			if(U)
				if(U.remove_on_detach)
					U.relock()
				U.on_detached()

	if(host_brain && host_brain.ckey)
		src.ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"

	host = null
	hostlimb = null
	channeling = 0
	update_verbs(BORER_MODE_DETACHED)

/client/proc/borer_infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	var/mob/living/simple_animal/borer/B = mob
	if(!istype(B))
		return
	B.infest()

/mob/living/simple_animal/borer/proc/limb_to_name(l)
	var/limb
	if(!l)
		return
	else
		limb = l
	var/limbname = ""
	switch(limb)
		if(BP_HEAD)
			limbname = BP_HEAD
		if(BP_CHEST)
			limbname = BP_CHEST
		if(BP_R_ARM)
			limbname = "right arm"
		if(BP_L_ARM)
			limbname = "left arm"
		if(BP_R_LEG)
			limbname = "right leg"
		if(BP_L_LEG)
			limbname = "left leg"
	return limbname

/mob/living/simple_animal/borer/proc/limb_to_mode(l)
	var/limb
	if(!l)
		return
	else
		limb = l
	var/mode = 0
	switch(limb)
		if(BP_HEAD)
			mode = BORER_MODE_ATTACHED_HEAD
		if(BP_CHEST)
			mode = BORER_MODE_ATTACHED_CHEST
		if(BP_R_ARM)
			mode = BORER_MODE_ATTACHED_ARM
		if(BP_L_ARM)
			mode = BORER_MODE_ATTACHED_ARM
		if(BP_R_LEG)
			mode = BORER_MODE_ATTACHED_LEG
		if(BP_L_LEG)
			mode = BORER_MODE_ATTACHED_LEG
	return mode

/mob/living/simple_animal/borer/proc/infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot infest a target while unconscious.</span>")
		return

	if(channeling)
		to_chat(src, "<span class='warning'>You cannot do this while your focus is directed elsewhere.</span>")

	if(stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != DEAD && src.Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src)
		return

	if(!(src.Adjacent(M)))
		return

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/N = M
		if(N.species && N.species.flags[NO_BLOOD])
			to_chat(src, "<span class='warning'>This host does not seem suitable.")
			return

	var/area = src.zone_sel.selecting
	var/region = BP_HEAD

	if(istype(M, /mob/living/carbon/human))
		switch(area)
			if(BP_HEAD)
				region = BP_HEAD
			if(O_MOUTH)
				region = BP_HEAD
			if(O_EYES)
				region = BP_HEAD
			if(BP_CHEST)
				region = BP_CHEST
			if(BP_GROIN)
				region = BP_CHEST
			if(BP_R_ARM)
				region = BP_R_ARM
			if(BP_L_ARM)
				region = BP_L_ARM
			if(BP_R_LEG)
				region = BP_R_LEG
			if(BP_L_LEG)
				region = BP_L_LEG

		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/O = H.bodyparts_by_name[region]
		if(O.status & ORGAN_ROBOT)
			to_chat(src, "You cannot infest this host's inorganic [limb_to_name(region)]!")
			return
		if((O.status & ORGAN_DESTROYED))
			to_chat(src, "This host does not have a [limb_to_name(region)]!")
			return
		var/result = H.check_thickmaterial(H.bodyparts_by_name[region])
		if(result)
			to_chat(src, "You cannot get through the protective gear on that host's [limb_to_name(region)].")
			return

	if(M.has_brain_worms(region))
		to_chat(src, "This host's [limb_to_name(region)] is already infested!")
		return

	switch(region)
		if(BP_HEAD)
			to_chat(src, "You slither up [M] and begin probing at their ear canal...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing at your ear canal...</span>")
		if(BP_CHEST)
			to_chat(src, "You slither up [M] and begin probing just below their sternum...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing just below your sternum...</span>")
		if(BP_R_ARM)
			to_chat(src, "You slither up [M] and begin probing at their right arm...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing at your right arm...</span>")
		if(BP_L_ARM)
			to_chat(src, "You slither up [M] and begin probing at their left arm...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your leg and probing at your left arm...</span>")
		if(BP_R_LEG)
			to_chat(src, "You slither up [M]'s right leg and begin probing at the back of their knee...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your right leg and probing just behind your knee...</span>")
		if(BP_L_LEG)
			to_chat(src, "You slither up [M]'s left leg and begin probing at the back of their knee...")
			to_chat(M, "<span class='sinister'>You feel something slithering up your left leg and probing just behind your knee...</span>")

	if(!do_after(src,50, M))
		to_chat(src, "As [M] moves away, you are dislodged and fall to the ground.")
		return

	if(!M || !src)
		return

	if(src.stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(M.stat == DEAD)
		to_chat(src, "That is not an appropriate target.")
		return

	if(M.has_brain_worms(region))
		to_chat(src, "This host's [limb_to_name(region)] is already infested!")
		return

	if(M in view(1, src))
		to_chat(src, "[region == BP_HEAD ? "You wiggle into [M]'s ear." : "You burrow under [M]'s skin."]")
		src.perform_infestation(M, region)

		return
	else
		to_chat(src, "They are no longer in range!")
		return

/mob/living/simple_animal/borer/proc/perform_infestation(target, br)
	var/mob/living/carbon/M = target
	var/body_region = BP_HEAD
	if(br)
		body_region = br
	if(!M || !istype(M))
		error("[src]: Unable to perform_infestation on [M]!")
		return FALSE

	hostlimb = body_region

	update_verbs(limb_to_mode(hostlimb),ismonkey(M)) // Must be called before being removed from turf. (BYOND verb transfer bug)

	src.host = M
	src.forceMove(M)

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.bodyparts_by_name[body_region]
		BP.implants += src

	host_brain.name = M.name
	host_brain.real_name = M.real_name

	// Tell our upgrades that we've attached.
	for(var/uid in research.unlocked.Copy())
		var/datum/unlockable/borer/U = research.get(uid)
		if(U)
			U.on_attached()

// So we can hear our host doing things.
// NOTE:  We handle both visible and audible emotes because we're a brainslug that can see the impulses and shit.
/mob/living/simple_animal/borer/proc/host_emote(var/list/args)
	src.show_message(args["message"], args["m_type"])
	host_brain.show_message(args["message"], args["m_type"])

// copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/borer/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if(stat == UNCONSCIOUS)
		return

	if (layer != TURF_LAYER + 0.2)
		layer = TURF_LAYER + 0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))



/mob/living/simple_animal/borer/proc/reproduce()
	set name = "Reproduce"
	set desc = "Spawn offspring in the form of an egg."
	set category = "Alien"

	if(!can_lay_eggs)
		to_chat(src, "<span class='info'>You are conditioned not to reproduce.</span>")
		return

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot reproduce while unconscious.</span>")
		return

	if(stat)
		to_chat(src, "You cannot reproduce in your current state.")
		return

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return

	if(busy)
		to_chat(src, "<span class='warning'>You are already doing something.</span>")
		return

	if(chemicals >= 100)
		busy = TRUE
		to_chat(src, "<span class='warning'>You strain, trying to push out your young...</span>")
		visible_message("<span class='warning'>\The [src] begins to struggle and strain!</span>")
		var/turf/T = get_turf(src)
		if(do_after(src, 5 SECONDS, T))
			to_chat(src, "<span class='danger'>You twitch and quiver as you rapidly excrete an egg from your sluglike body.</span>")
			visible_message("<span class='danger'>\The [src] heaves violently, expelling a small, gelatinous egg!</span>")
			chemicals -= 100
			numChildren++
			playsound(T, 'sound/effects/splat.ogg', 50, 1)
			var/obj/item/weapon/reagent_containers/food/snacks/borer_egg/E = new (T)
			E.child_prefix_index = (name_prefix_index + 1)
		busy = FALSE

	else
		to_chat(src, "You do not have enough chemicals stored to reproduce.")
		return()

/mob/living/simple_animal/borer/proc/transfer_personality(client/candidate)
	if(!candidate)
		return
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Borer"
		// tl;dr
		to_chat(src, "<span class='danger'>You are a Borer!</span>")
		to_chat(src, "<span class='info'>You are a small slug-like parasyte that attaches to your host's body.  Your only goals are to survive and procreate. However, there are those who would like to destroy you, and most hosts don't like to cooperate.  Being helpful to your host could be your best option for survival.</span>")
		to_chat(src, "<span class='info'>Borers can speak with other borers over the Cortical Link.  To do so, release control and use <code>say \";message\"</code>.  To communicate with your host only, speak normally. Your chemicals regenerate only while in a host.</span>")
		to_chat(src, "<span class='info'><b>New:</b> To get new abilities for you and your host, use <em>Evolve</em> to unlock things.</span>")

/mob/living/simple_animal/borer/proc/taste_blood()
	set name = "Taste Blood"
	set desc = "See if there's anything within the blood of your host."
	set category = "Alien"

	if(!check_can_do(TRUE))
		return

	to_chat(src, "<span class='info'>You taste the blood of your host, and process it for abnormalities.</span>")
	if(!isnull(host.reagents))
		var/dat = ""
		if(host.reagents.reagent_list.len > 0)
			for (var/datum/reagent/R in host.reagents.reagent_list)
				if(R.id == BLOOD)
					continue // Like we need to know that blood contains blood.
				dat += "\n \t <span class='notice'>[R] ([R.volume] units)</span>"
		if(dat)
			to_chat(src, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(src, "<span class='notice'>No active chemical agents found in [host]'s blood.</span>")
	else
		to_chat(src, "<span class='notice'>No significant chemical agents found in [host]'s blood.</span>")


/mob/living/simple_animal/borer/attack_ghost(mob/dead/observer/O)
	if(!(src.key))
		if(O.can_reenter_corpse)
			var/response = alert(O,"Do you want to take it over?","This borer has no soul","Yes","No")
			if(response == "Yes")
				if(!(src.key))
					src.transfer_personality(O.client)
				else if(src.key)
					to_chat(src, "<span class='notice'>Somebody jumped your claim on this borer and is already controlling it. Try another </span>")
		else if(!(O.can_reenter_corpse))
			to_chat(O,"<span class='notice'>While the borer may be mindless, you have recently ghosted and thus are not allowed to take over for now.</span>")

/mob/living/simple_animal/borer/proc/passout(wait_time, send_message)
	var/wtime = 0
	if(!wait_time)
		return
	if(send_message)
		to_chat(src, "<span class='warning'>You lose consciousness due to overexertion.</span>")
	wtime = min(wait_time, 60)
	stat = UNCONSCIOUS
	spawn(0)
		sleep(wtime * 10)
		stat = CONSCIOUS
		to_chat(src, "<span class='notice'>You have regained consciousness.</span>")

/mob/living/simple_animal/borer/proc/check_can_do(check_channeling)
	if(!host)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return FALSE

	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do this while unconscious.</span>")
		return FALSE

	if(stat)
		to_chat(src, "<span class='warning'>You cannot do this in your current state.</span>")
		return FALSE

	if(controlling)
		to_chat(src, "<span class='warning'>You're too busy controlling your host.</span>")
		return FALSE

	if(host.stat==DEAD)
		to_chat(src, "<span class='warning'>You cannot do that in your host's current state.</span>")
		return FALSE

	if(research.unlocking)
		to_chat(src, "<span class='warning'>You are busy evolving.</span>")
		return FALSE

	if(check_channeling)
		if(channeling)
			to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
			return FALSE

	return TRUE

/mob/living/simple_animal/borer/start_pulling(atom/movable/AM) // Prevents mouse from pulling things
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return
