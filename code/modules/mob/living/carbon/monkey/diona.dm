/*
  Tiny babby plant critter plus procs.
*/

//Mob defines.
/mob/living/carbon/monkey/diona
	name = "diona nymph"
	voice_name = "diona nymph"
	speak_emote = list("chirrups")
	icon_state = "nymph1"
	hazard_low_pressure = DIONA_HAZARD_LOW_PRESSURE
	var/list/donors = list()
	var/ready_evolve = 0
	var/mob/living/carbon/human/gestalt = null
	var/allowedinjecting = list("nutriment",
                                "orangejuice",
                                "tomatojuice",
                                "limejuice",
                                "carrotjuice",
                                "milk",
                                "coffee"
                               )
	race = DIONA
	var/datum/reagent/injecting = null
	universal_understand = FALSE // Dionaea do not need to speak to people
	universal_speak = FALSE      // before becoming an adult. Use *chirp.
	holder_type = /obj/item/weapon/holder/diona
	blood_datum = /datum/dirt_cover/green_blood


/mob/living/carbon/monkey/diona/is_facehuggable()
	return FALSE

/mob/living/carbon/monkey/diona/grabReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	if(attacker.get_species() == DIONA)
		visible_message("<span class='notice'>[attacker] starts to merge [src] into themselves.</span>","<span class='notice'>You start merging [src] into you.</span>")
		if(attacker.is_busy() || !do_after(attacker, 4 SECONDS, target = src))
			return TRUE
		merging(attacker)
		return TRUE
	return ..()

/mob/living/carbon/monkey/diona/atom_init()
	. = ..()
	gender = NEUTER
	dna.mutantrace = "plant"
	greaterform = DIONA
	add_language("Rootspeak")

/mob/living/carbon/monkey/diona/proc/merging(mob/living/carbon/human/M)
	var/count = 0
	for(var/mob/living/carbon/monkey/diona in M)
		count++
	if(count >= 3)
		visible_message(src, "<span class='notice'>[M]'s body seems to repel [src], as it attempts to twine with it's being.</span>")
		return
	to_chat(M, "You feel your being twine with that of [src] as it merges with your biomass.")
	M.status_flags |= PASSEMOTES
	to_chat(src, "You feel your being twine with that of [M] as you merge with its biomass.")
	forceMove(M)
	gestalt = M

/mob/living/carbon/monkey/diona/proc/splitting(mob/living/carbon/human/M)
	to_chat(src.loc, "You feel a pang of loss as [src] splits away from your biomass.")
	to_chat(src, "You wiggle out of the depths of [M]'s biomass and plop to the ground.")
	gestalt = null
	forceMove(get_turf(src))
	M.remove_passemotes_flag()
//Verbs after this point.

/mob/living/carbon/monkey/diona/verb/merge()

	set category = "Diona"
	set name = "Merge with gestalt"
	set desc = "Merge with another diona."

	if(gestalt)
		return

	if(incapacitated())
		to_chat(src, "<span class='warning'>You must be conscious to do this.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/C in view(1,src))
		if(C.get_species() == DIONA)
			choices += C
	var/mob/living/carbon/human/M = input(src,"Who do you wish to merge with?") in null|choices
	if(!M || !src || !(src.Adjacent(M)))
		return
	if(is_busy() || !do_after(src, 40, target = M))
		return
	merging(M)

/mob/living/carbon/monkey/diona/verb/split()

	set category = "Diona"
	set name = "Split from gestalt"
	set desc = "Split away from your gestalt as a lone nymph."

	if(!gestalt)
		return

	if(incapacitated())
		to_chat(src, "<span class='warning'>You must be conscious to do this.</span>")
		return
	splitting(gestalt)

/mob/living/carbon/monkey/diona/verb/pass_knowledge()

	set category = "Diona"
	set name = "Pass Knowledge"
	set desc = "Teach the gestalt your own known languages."

	if(!gestalt)
		return

	if(gestalt.incapacitated(null))
		to_chat(src, "<span class='warning'>[gestalt] must be conscious to do this.</span>")
		return
	if(incapacitated())
		to_chat(src, "<span class='warning'>You must be conscious to do this.</span>")
		return

	if(gestalt.nutrition < 230)
		to_chat(src, "<span class='notice'>It would appear, that [gestalt] does not have enough nutrition to accept your knowledge.</span>")
		return
	if(nutrition < 230)
		to_chat(src, "<span class='notice'>It would appear, that you do not have enough nutrition to pass knowledge onto [gestalt].</span>")
		return

	var/list/langdiff = languages - gestalt.languages
	if(langdiff.len == 0)
		to_chat(src, "<span class='notice'>It would appear, that [gestalt] already knows all you could give.</span>")
		return

	var/datum/language/L = pick(langdiff)
	to_chat(gestalt, "<span class ='notice'>It would seem [src] is trying to pass on their knowledge onto you.</span>")
	to_chat(src, "<span class='notice'>You concentrate your willpower on transcribing [L.name] onto [gestalt], this may take a while.</span>")
	if(is_busy() || !do_after(src, 40, target = gestalt))
		return
	gestalt.add_language(L.name)
	nutrition -= 30
	gestalt.nutrition -= 30
	to_chat(src, "<span class='notice'>It would seem you have passed on [L.name] onto [gestalt] succesfully.</span>")
	to_chat(gestalt, "<span class='notice'>It would seem you have acquired knowledge of [L.name]!</span>")
	if(prob(50))
		to_chat(src, "<span class='warning'>You momentarily forget [L.name]. Is this how memory wiping feels?</span>")
		remove_language(L.name)

/mob/living/carbon/monkey/diona/verb/synthesize()

	set category = "Diona"
	set name = "Synthesize"
	set desc = "Synthesize chemicals inside gestalt's body."

	if(!gestalt)
		return

	if(incapacitated())
		to_chat(src, "<span class='warning'>You must be conscious to do this.</span>")
		return

	if(nutrition < 210)
		to_chat(src, "<span class='warning'>You do not have enough nutriments to perform this action.</span>")
		return

	if(injecting)
		switch(alert("Would you like to stop injecting, or change chemical?","Choose.","Stop injecting","Change chemical"))
			if("Stop injecting")
				injecting = null
				return
			if("Change chemical")
				injecting = null
	var/V = input(src,"What do you wish to inject?") in null|allowedinjecting

	if(V)
		injecting = V

/mob/living/carbon/monkey/diona/verb/fertilize_plant()

	set category = "Diona"
	set name = "Fertilize plant"
	set desc = "Turn your food into nutrients for plants."

	var/list/trays = list()
	for(var/obj/machinery/hydroponics/tray in range(1))
		if(tray.nutrilevel < 10)
			trays += tray

	var/obj/machinery/hydroponics/target = input("Select a tray:") as null|anything in trays

	if(!src || !target || target.nutrilevel == 10) return //Sanity check.

	src.nutrition -= ((10-target.nutrilevel)*5)
	target.nutrilevel = 10
	src.visible_message("<span class='warning'>[src] secretes a trickle of green liquid from its tail, refilling [target]'s nutrient tray.</span>","<span class='warning'>You secrete a trickle of green liquid from your tail, refilling [target]'s nutrient tray.</span>")

/mob/living/carbon/monkey/diona/verb/eat_weeds()

	set category = "Diona"
	set name = "Eat Weeds"
	set desc = "Clean the weeds out of soil or a hydroponics tray."

	var/list/trays = list()
	for(var/obj/machinery/hydroponics/tray in range(1))
		if(tray.weedlevel > 0)
			trays += tray

	var/obj/machinery/hydroponics/target = input("Select a tray:") as null|anything in trays

	if(!src || !target || target.weedlevel == 0) return //Sanity check.

	src.reagents.add_reagent("nutriment", target.weedlevel)
	target.weedlevel = 0
	src.visible_message("<span class='warning'>[src] begins rooting through [target], ripping out weeds and eating them noisily.</span>","<span class='warning'>You begin rooting through [target], ripping out weeds and eating them noisily.</span>")

/mob/living/carbon/monkey/diona/verb/evolve()

	set category = "Diona"
	set name = "Evolve"
	set desc = "Grow to a more complex form."

	if(!is_alien_whitelisted(src, DIONA) && config.usealienwhitelist)
		to_chat(src, alert("You are currently not whitelisted to play as a full diona."))
		return 0

	if(gestalt)
		to_chat(src, "You can not grow, while being inside [gestalt].")
		return

	if(donors.len < 5)
		to_chat(src, "You are not yet ready for your growth...")
		return

	if(nutrition < 400)
		to_chat(src, "You have not yet consumed enough to grow...")
		return

	src.split()
	src.visible_message("<span class='warning'>[src] begins to shift and quiver, and erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea.</span>","<span class='warning'>You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients to surge with growth, splitting into a tangle of at least a dozen new dionaea. We have attained our gestalt form.</span>")

	var/mob/living/carbon/human/adult = new(get_turf(src.loc))
	adult.set_species(DIONA)

	if(istype(loc,/obj/item/weapon/holder/diona))
		var/obj/item/weapon/holder/diona/L = loc
		src.loc = L.loc
		qdel(L)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)
	adult.regenerate_icons()

	adult.name = "diona ([rand(100,999)])"
	adult.real_name = adult.name
	adult.ckey = src.ckey

	for (var/obj/item/W in src.contents)
		src.drop_from_inventory(W)
	qdel(src)

/mob/living/carbon/monkey/diona/verb/steal_blood()
	set category = "Diona"
	set name = "Steal Blood"
	set desc = "Take a blood sample from a suitable donor."

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in oview(1,src))
		choices += H

	var/mob/living/carbon/human/M = input(src,"Who do you wish to take a sample from?") in null|choices

	if(!M || !src) return

	if(M.species.flags[NO_BLOOD])
		to_chat(src, "<span class='warning'>That donor has no blood to take.</span>")
		return

	if(donors.Find(M.real_name))
		to_chat(src, "<span class='warning'>That donor offers you nothing new.</span>")
		return

	src.visible_message("<span class='warning'>[src] flicks out a feeler and neatly steals a sample of [M]'s blood.</span>","<span class='warning'>You flick out a feeler and neatly steal a sample of [M]'s blood.</span>")
	donors += M.real_name
	for(var/datum/language/L in M.languages)
		languages |= L

	spawn(25)
		update_progression()

/mob/living/carbon/monkey/diona/proc/update_progression()

	if(!donors.len)
		return

	if(donors.len == 5)
		ready_evolve = 1
		to_chat(src, "<span class='notice'>You feel ready to move on to your next stage of growth.</span>")
	else if(donors.len == 3)
		universal_understand = 1
		to_chat(src, "<span class='notice'>You feel your awareness expand, and realize you know how to understand the creatures around you.</span>")
	else
		to_chat(src, "<span class='notice'>The blood seeps into your small form, and you draw out the echoes of memories and personality from it, working them into your budding mind.</span>")


/mob/living/carbon/monkey/diona/say_understands(mob/other,datum/language/speaking = null)

	if (istype(other, /mob/living/carbon/human) && !speaking)
		if(languages.len >= 2) // They have sucked down some blood.
			return 1
	return ..()

/mob/living/carbon/monkey/diona/say(var/message)
	var/verb = "says"
	var/message_range = world.view

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (Muted).</span>")
			return

	message = copytext_char(trim(message), 1, MAX_MESSAGE_LEN)

	if(stat == DEAD)
		return say_dead(message)

	var/datum/language/speaking = parse_language(message)
	if(speaking)
		verb = speaking.speech_verb
		message = trim(copytext_char(message,2+length_char(speaking.key)))

	if(!message || stat)
		return

	..(message, speaking, verb, null, null, message_range, null)
