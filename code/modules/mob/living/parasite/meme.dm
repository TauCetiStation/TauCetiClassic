//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

// === MEMETIC ANOMALY ===
// =======================

/**
This life form is a form of parasite that can gain a certain level of control
over its host. Its player will share vision and hearing with the host, and it'll
be able to influence the host through various commands.
**/

// The maximum amount of points a meme can gather.
var/global/const/MAXIMUM_MEME_POINTS = 750


// === PARASITE ===
// ================

// a list of all the parasites in the mob
/mob/var/list/parasites = list()

/mob/living/parasite
	var/mob/living/carbon/host // the host that this parasite occupies

/mob/living/parasite/Login()
	..()
	if(host)
		client.eye = host
	else
		client.eye = loc
	client.perspective = EYE_PERSPECTIVE
	SetSleeping(0)

/mob/living/parasite/proc/enter_host(mob/living/carbon/host)
	src.host = host
	loc = host
	host.parasites.Add(src)
	if(client)
		client.eye = host
	return TRUE

/mob/living/parasite/proc/exit_host()
	host.parasites.Remove(src)
	host = null
	loc = null
	return TRUE


// === MEME ===
// ============

/mob/living/parasite/meme
	var/meme_points = 100
	var/dormant = 0
	var/meme_death = "stoxin"
	var/list/indoctrinated = list()

/mob/living/parasite/meme/atom_init()
	. = ..()
	name = "[pick("Meme")] [rand(1000,9999)]"

/mob/living/parasite/meme/enter_host(mob/living/carbon/human/host)
	if(locate(/mob/living/parasite/meme) in host.parasites)
		return FALSE
	return ..()

/mob/living/parasite/meme/Life()
	..()


	if(client)
		if(blinded)
			client.eye = null
		else
			client.eye = host

	if(!host)
		return

	// recover meme points slowly
	var/gain = 3
	if(dormant) gain = 9 // dormant recovers points faster

	meme_points = min(meme_points + gain, MAXIMUM_MEME_POINTS)
	// if there are sleep toxins in the host's body, that's bad

	if (meme_death == "bdam")
		if(host.brainloss > 60)
			to_chat(src, "<span class='warning'><b>Something in your host's brain makes you lose consciousness.. you fade away..</b></span>")
			src.death()
			return
	else if (meme_death == "burns")
		if(host.on_fire)
			to_chat(src, "<span class='warning'><b>Something on your host's skin makes you unstable.. you fade away..</b></span>")
			src.death()
			return
	else if(host.reagents.has_reagent(meme_death))
		to_chat(src, "<span class='warning'><b>Something in your host's blood makes you lose consciousness.. you fade away..</b></span>")
		src.death()
		return

	// a host without brain is no good
	else if(!host.mind)
		to_chat(src, "<span class='warning'><b>Your host has no mind.. you fade away..</b></span>")
		src.death()
		return
	else if(host.stat == DEAD)
		to_chat(src, "<span class='warning'><b>Your host has died.. you fade away..</b></span>")
		src.death()
		return

	else if(host.blinded && host.stat != UNCONSCIOUS)
		src.blinded = 1
	else
		src.blinded = 0


/mob/living/parasite/meme/death()
	// make sure the mob is on the actual map before gibbing
	if(host) src.loc = host.loc
	src.stat = DEAD
	..()
	qdel(src)

// When a meme speaks, it speaks through its host
/mob/living/parasite/meme/say(message as text)
	if(dormant)
		to_chat(usr, "<span class='warning'>You're dormant!</span>")
		return
	if(!host)
		to_chat(usr, "<span class='warning'>You can't speak without host!</span>")
		return

	return host.say(message)

// Same as speak, just with whisper
/mob/living/parasite/meme/whisper(message as text)
	if(dormant)
		to_chat(usr, "<span class='warning'>You're dormant!</span>")
		return
	if(!host)
		to_chat(usr, "<span class='warning'>You can't speak without host!</span>")
		return

	return host.whisper(message)

// Make the host do things
/mob/living/parasite/meme/me_verb(message as text)
	set name = "Me"


	if(dormant)
		to_chat(usr, "<span class='warning'>You're dormant!</span>")
		return

	if(!host)
		to_chat(usr, "<span class='warning'>You can't emote without host!</span>")
		return

	return host.custom_emote(1, message)

// A meme understands everything their host understands
/mob/living/parasite/meme/say_understands(mob/other)
	if(!host)
		return 0

	return host.say_understands(other)

// Try to use amount points, return 1 if successful
/mob/living/parasite/meme/proc/use_points(amount)
	if(dormant)
		to_chat(usr, "<span class='warning'>You're dormant!</span>")
		return
	if(src.meme_points < amount)
		to_chat(src, "<b>* You don't have enough meme points(need [amount]).</b>")
		return 0

	src.meme_points -= round(amount)
	return 1

// Let the meme choose one of his indoctrinated mobs as target
/mob/living/parasite/meme/proc/select_indoctrinated(title, message)
	var/list/candidates

	// Can only affect other mobs thant he host if not blinded
	if(blinded)
		candidates = list()
		to_chat(src, "<span class='warning'>You are blinded, so you can not affect mobs other than your host.</span>")
	else
		candidates = indoctrinated.Copy()

	candidates.Add(src.host)

	var/mob/target = null
	if(candidates.len == 1)
		target = candidates[1]
	else
		var/selected

		var/list/text_candidates = list()
		var/list/map_text_to_mob = list()

		for(var/mob/living/carbon/human/M in candidates)
			text_candidates += M.real_name
			map_text_to_mob[M.real_name] = M

		selected = input(message,title) as null|anything in text_candidates
		if(!selected)
			return null

		target = map_text_to_mob[selected]

	return target


// A meme can make people hear things with the thought ability
/mob/living/parasite/meme/verb/Thought()
	set category = "Meme"
	set name	 = "Thought(50)"
	set desc     = "Implants a thought into the target, making them think they heard someone talk."

	if(meme_points < 50)
		// just call use_points() to give the standard failure message
		use_points(50)
		return

	var/list/candidates = indoctrinated.Copy()
	if(!(src.host in candidates))
		candidates.Add(src.host)

	var/mob/target = select_indoctrinated("Thought", "Select a target which will hear your thought.")

	if(!target)
		return

	var/speaker = sanitize(input("Select the voice in which you would like to make yourself heard.", "Voice") as null|text, MAX_NAME_LEN)
	if(!speaker)
		return

	var/message = sanitize(input("What would you like to say?", "Message") as null|text)
	if(!message)
		return

	// Use the points at the end rather than the beginning, because the user might cancel
	if(!use_points(50))
		return

	//message = say_quote(message)
	var/rendered = "<span class='game say'><span class='name'>[speaker]</span> <span class='message'><i>[message]</i></span></span>"
	//target.show_messageold(rendered)
	to_chat(target, rendered)
	to_chat(usr, "<i>You make [target] hear:</i> [rendered]")
	to_chat(observer_list, "[usr] makes [target] hear: [rendered]")
	log_say("Memetic Thought: [key_name(usr)] makes [key_name(target)] hear: [speaker] [message]")

// Mutes the host
/mob/living/parasite/meme/verb/Mute()
	set category = "Meme"
	set name	 = "Mute(250)"
	set desc     = "Prevents your host from talking for a while."

	if(!src.host) return
	if(!host.speech_allowed)
		to_chat(usr, "<span class='warning'>Your host already can't speak..</span>")
		return
	if(!use_points(250))
		return

	spawn
		// backup the host incase we switch hosts after using the verb
		var/mob/host = src.host

		to_chat(host, "<span class='warning'>Your tongue feels numb.. You lose your ability to speak.</span>")
		to_chat(usr, "<span class='warning'>Your host can't speak anymore.</span>")

		host.speech_allowed = 0

		sleep(1200)

		host.speech_allowed = 1
		to_chat(host, "<span class='warning'>Your tongue has feeling again..</span>")
		to_chat(usr, "<span class='warning'>[host] can speak again.</span>")

// Makes the host unable to emote
/mob/living/parasite/meme/verb/Paralyze()
	set category = "Meme"
	set name	 = "Paralyze(250)"
	set desc     = "Prevents your host from using emote for a while."

	if(!src.host)
		return
	if(!host.me_verb_allowed)
		to_chat(usr, "<span class='warning'>Your host already can't use body language..</span>")
		return
	if(!use_points(250))
		return

	spawn
		// backup the host incase we switch hosts after using the verb
		var/mob/host = src.host

		to_chat(host, "<span class='warning'>Your body feels numb.. You lose your ability to use body language.</span>")
		to_chat(usr, "<span class='warning'>Your host can't use body language anymore.</span>")

		host.me_verb_allowed = FALSE

		sleep(1200) // maybe it is better to use addtimer()? 120 seconds is too much

		host.me_verb_allowed = TRUE
		to_chat(host, "<span class='warning'>Your body has feeling again..</span>")
		to_chat(usr, "<span class='warning'>[host] can use body language again.</span>")



// Cause great agony with the host, used for conditioning the host
/mob/living/parasite/meme/verb/Agony()
	set category = "Meme"
	set name	 = "Agony(200)"
	set desc     = "Causes significant pain in your host."

	if(!src.host)
		return
	if(!use_points(200))
		return

	spawn
		// backup the host incase we switch hosts after using the verb
		var/mob/host = src.host

		host.paralysis = max(host.paralysis, 2)

		host.flash_weak_pain()
		to_chat(host, "<span class='warning'><font size=5>You feel excrutiating pain all over your body! It is so bad you can't think or articulate yourself properly..</font></span>")

		to_chat(usr, "<b>You send a jolt of agonizing pain through [host], they should be unable to concentrate on anything else for half a minute.</b>")

		host.emote("scream")

		for(var/i=0, i<10, i++)
			host.stuttering = 2
			sleep(50)
			if(prob(80))
				host.flash_weak_pain()
			if(prob(10))
				host.paralysis = max(host.paralysis, 2)
			if(prob(15))
				host.emote("twitch")
			else if(prob(15))
				host.emote("scream")
			else if(prob(10))
				host.emote("collapse")

			if(i == 10)
				to_chat(host, "<span class='warning'>THE PAIN! AGHH, THE PAIN! MAKE IT STOP! ANYTHING TO MAKE IT STOP!</span>")

		to_chat(host, "<span class='warning'>The pain subsides..</span>")

// Cause great joy with the host, used for conditioning the host
/mob/living/parasite/meme/verb/Joy()
	set category = "Meme"
	set name	 = "Joy(200)"
	set desc     = "Causes significant joy in your host."

	if(!src.host)
		return
	if(!use_points(200))
		return

	spawn
		var/mob/host = src.host
		host.druggy = max(host.druggy, 50)
		host.slurring = max(host.slurring, 10)

		to_chat(usr, "<b>You stimulate [host.name]'s brain, injecting waves of endorphines and dopamine into the tissue. They should now forget all their worries, particularly relating to you, for around a minute.</b>")

		to_chat(host, "<span class='warning'>You are feeling wonderful! Your head is numb and drowsy, and you can't help forgetting all the worries in the world.</span>")

		while(host.druggy > 0)
			sleep(10)

		to_chat(host, "<span class='warning'>You are feeling clear-headed again..</span>")

// Cause the target to hallucinate.
/mob/living/parasite/meme/verb/Hallucinate()
	set category = "Meme"
	set name	 = "Hallucinate(300)"
	set desc     = "Makes your host hallucinate, has a short delay."

	var/mob/living/target = select_indoctrinated("Hallucination", "Who should hallucinate?")

	if(!target)
		return
	if(!use_points(300))
		return

	target.hallucination += 100

	to_chat(usr, "<b>You make [target] hallucinate.</b>")

// Jump to a closeby target through a whisper
/mob/living/parasite/meme/verb/SubtleJump(mob/living/carbon/human/target as mob in human_list)
	set category = "Meme"
	set name	 = "Subtle Jump(350)"
	set desc     = "Move to a closeby human through a whisper."

	if(!istype(target, /mob/living/carbon/human) || !target.mind)
		to_chat(src, "<b>You can't jump to this creature..</b>")
		return
	if(!(target in view(1, host)+src))
		to_chat(src, "<b>The target is not close enough.</b>")
		return

	// Find out whether we can speak
	if (host.silent || (host.disabilities & 64))
		to_chat(src, "<b>Your host can't speak..</b>")
		return

	if(!use_points(350))
		return

	audible_message("<B>[host]</B> whispers something incoherent.", hearing_distance = 1)

	// Find out whether the target can hear
	if(target.disabilities & 32 || target.ear_deaf)
		to_chat(src, "<b>Your target doesn't seem to hear you..</b>")
		return

	if(target.parasites.len > 0)
		to_chat(src, "<b>Your target already is possessed by something..</b>")
		return

	src.exit_host()
	src.enter_host(target)

	to_chat(usr, "<b>You successfully jumped to [target].</b>")
	log_admin("[key_name(src)] has jumped to [target]")
	message_admins("[key_name_admin(src)] has jumped to [target] [ADMIN_JMP(src)]")

// Jump to a distant target through a shout
/mob/living/parasite/meme/verb/ObviousJump(mob/living/carbon/human/target as mob in human_list)
	set category = "Meme"
	set name	 = "Obvious Jump(750)"
	set desc     = "Move to any mob in view through a shout."

	if(!istype(target, /mob/living/carbon/human) || !target.mind)
		to_chat(src, "<b>You can't jump to this creature..</b>")
		return
	if(!(target in view(host)))
		to_chat(src, "<b>The target is not close enough.</b>")
		return

	// Find out whether we can speak
	if (host.silent || (host.disabilities & 64))
		to_chat(src, "<b>Your host can't speak..</b>")
		return

	if(!use_points(750))
		return

	audible_message("<B>[host]</B> screams something incoherent!", hearing_distance = 1)

	// Find out whether the target can hear
	if(target.disabilities & 32 || target.ear_deaf)
		to_chat(src, "<b>Your target doesn't seem to hear you..</b>")
		return

	if(target.parasites.len > 0)
		to_chat(src, "<b>Your target already is possessed by something..</b>")
		return

	src.exit_host()
	src.enter_host(target)

	to_chat(usr, "<b>You successfully jumped to [target].</b>")
	log_admin("[key_name(src)] has jumped to [target]")
	message_admins("[key_name_admin(src)] has jumped to [target] [ADMIN_JMP(src)]")

// Jump to an attuned mob for free
/mob/living/parasite/meme/verb/AttunedJump(mob/living/carbon/human/target as mob in human_list)
	set category = "Meme"
	set name	 = "Attuned Jump(0)"
	set desc     = "Move to a mob in sight that you have already attuned."

	if(!istype(target, /mob/living/carbon/human) || !target.mind)
		to_chat(src, "<b>You can't jump to this creature..</b>")
		return
	if(!(target in view(host)))
		to_chat(src, "<b>You need to make eye-contact with the target.</b>")
		return
	if(!(target in indoctrinated))
		to_chat(src, "<b>You need to attune the target first.</b>")
		return

	if(target.parasites.len > 0)
		to_chat(src, "<b>Your target already is possessed by something..</b>")
		return

	src.exit_host()
	src.enter_host(target)

	to_chat(usr, "<b>You successfully jumped to [target].</b>")

	log_admin("[key_name(src)] has jumped to [target]")
	message_admins("[key_name_admin(src)] has jumped to [target] [ADMIN_JMP(src)]")

// ATTUNE a mob, adding it to the indoctrinated list
/mob/living/parasite/meme/verb/Attune()
	set category = "Meme"
	set name	 = "Attune(400)"
	set desc     = "Change the host's brain structure, making it easier for you to manipulate him."

	if(host in src.indoctrinated)
		to_chat(usr, "<b>You have already attuned this host.</b>")
		return

	if(!host)
		return
	if(!use_points(400))
		return

	src.indoctrinated.Add(host)

	to_chat(usr, "<b>You successfully indoctrinated [host].</b>")
	to_chat(host, "<span class='warning'>Your head feels a bit roomier..</span>")

	log_admin("[key_name(src)] has attuned [host]")
	message_admins("[key_name_admin(src)] has attuned [host] [ADMIN_JMP(src)]")

// Enables the mob to take a lot more damage
/mob/living/parasite/meme/verb/Analgesic()
	set category = "Meme"
	set name	 = "Analgesic(500)"
	set desc     = "Combat drug that the host to move normally, even under life-threatening pain."

	if(!host)
		return
	if(!(host in indoctrinated))
		to_chat(usr, "<span class='warning'>You need to attune the host first.</span>")
		return
	if(!use_points(500))
		return

	to_chat(usr, "<b>You inject drugs into [host].</b>")
	to_chat(host, "<span class='warning'>You feel your body strengthen and your pain subside..</span>")
	host.analgesic = 60
	while(host.analgesic > 0)
		sleep(10)
	to_chat(host, "<span class='warning'>The dizziness wears off, and you can feel pain again..</span>")


/mob/proc/clearHUD()
	if(client)
		client.screen.Cut()

// Take control of the mob
/mob/living/parasite/meme/verb/Possession()
	set category = "Meme"
	set name	 = "Possession(500)"
	set desc     = "Take direct control of the host for a while."

	if(!host)
		return
	if(!(host in indoctrinated))
		to_chat(usr, "<span class='warning'>You need to attune the host first.</span>")
		return
	if(!use_points(500))
		return

	to_chat(usr, "<b>You take control of [host]!</b>")
	to_chat(host, "<span class='warning'>Everything goes black..</span>")

	spawn
		var/mob/dummy = new()
		dummy.loc = 0
		dummy.sight = BLIND

		var/datum/mind/host_mind = host.mind
		var/datum/mind/meme_mind = src.mind
		var/mob/living/carbon/human/H = host

		host_mind.transfer_to(dummy)
		meme_mind.transfer_to(host)
		host_mind.current.clearHUD()
		H.update_body()

		to_chat(dummy, "<span class='notice'>You feel very drowsy.. Your eyelids become heavy...</span>")

		log_admin("[key_name(src)] has taken possession of [host]([host_mind.key])")
		message_admins("[key_name_admin(src)] has taken possession of [host]([host_mind.key]) [ADMIN_JMP(src)]")

		sleep(600)

		log_admin("[key_name(src)] has lost possession of [host]([host_mind.key])")
		message_admins("[key_name_admin(src)] has lost possession of [host]([host_mind.key]) [ADMIN_JMP(src)]")

		meme_mind.transfer_to(src)
		host_mind.transfer_to(host)
		meme_mind.current.clearHUD()
		H.update_body()
		to_chat(src, "<span class='warning'>You lose control..</span>")

		qdel(dummy)

// Enter dormant mode, increases meme point gain
/mob/living/parasite/meme/verb/Dormant()
	set category = "Meme"
	set name	 = "Dormant(100)"
	set desc     = "Speed up point recharging, will force you to cease all actions until all points are recharged."

	if(!host)
		return
	if(!use_points(100))
		return

	to_chat(usr, "<b>You enter dormant mode.. You won't be able to take action until all your points have recharged.</b>")

	dormant = 1

	while(meme_points < MAXIMUM_MEME_POINTS)
		sleep(10)

	dormant = 0

	to_chat(usr, "<span class='warning'>You have regained all points and exited dormant mode!</span>")

/mob/living/parasite/meme/verb/Show_Points()
	set category = "Meme"

	to_chat(usr, "<b>Meme Points: [src.meme_points]/[MAXIMUM_MEME_POINTS]</b>")

// Stat panel to show meme points, copypasted from alien
/mob/living/parasite/meme/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Meme Points: [meme_points]")

// Game mode helpers, used for theft objectives
// --------------------------------------------
/mob/living/parasite/check_contents_for(t)
	if(!host)
		return 0

	return host.check_contents_for(t)

/*mob/living/parasite/check_contents_for_reagent(t)
	if(!host) return 0

	return host.check_contents_for_reagent(t) */
