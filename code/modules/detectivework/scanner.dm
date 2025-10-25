/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	icon = 'icons/obj/detective_work.dmi'
	icon_state = "detective_scanner"
	item_state_world = "detective_scanner_world"
	item_state = "detective_scanner"
	w_class = SIZE_SMALL
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "engineering=4;biotech=2;programming=5"
	item_action_types = list(/datum/action/item_action/print_forensic_report, /datum/action/item_action/clear_records)

	var/scanning = FALSE
	var/list/log = list()

/obj/item/device/detective_scanner/attack_self(mob/user)
	var/search = sanitize(input("Enter name, fingerprint or blood DNA.", "Find record") as text)

	if(!search || user.stat || user.incapacitated())
		return
	search = lowertext(search) //This is here so that it doesn't run 'lowertext()' until the checks have passed.

	var/name
	var/fingerprint = "FINGERPRINT NOT FOUND"
	var/dna = "BLOOD DNA NOT FOUND"

	// I really, really wish I didn't have to split this into two seperate loops. But the datacore is awful.

	for(var/record in data_core.general) // Search in the 'general' datacore
		var/datum/data/record/S = record
		if(S && (search == lowertext(S.fields["fingerprint"]) || search == lowertext(S.fields["name"]))) // Get Fingerprint and Name
			name = S.fields["name"]
			fingerprint = S.fields["fingerprint"]
			break

	for(var/record in data_core.medical) // Then search in the 'medical' datacore
		var/datum/data/record/M = record
		if(M && (search == lowertext(M.fields["b_dna"]) || name == M.fields["name"])) // Get Blood DNA
			dna = M.fields["b_dna"]

			if(fingerprint == "FINGERPRINT NOT FOUND") // We have searched for DNA, and so do not have the relevant information from the fingerprint records.
				name = M.fields["name"]
				for(var/gen_record in data_core.general)
					var/datum/data/record/S = gen_record
					if(S && (name == S.fields["name"]))
						fingerprint = S.fields["fingerprint"]
						break
			else //Eveything's been set, break the loop
				break

	if(name)
		to_chat(user, "<span class='notice'>Match found in station records: <b>[name]</b></span><br>\
		<i>Fingerprint:</i><span class='notice'> [fingerprint]</span><br>\
		<i>Blood DNA:</i><span class='notice'> [dna]</span>")
	else
		to_chat(user, "<span class='warning'>No match found in station records.</span>")


/datum/action/item_action/print_forensic_report
	name = "Print Report"

/datum/action/item_action/print_forensic_report/Activate()
	var/obj/item/device/detective_scanner/D = target
	D.print_scanner_report()

/obj/item/device/detective_scanner/proc/print_scanner_report()
	if(length(log) && !scanning)
		scanning = TRUE
		to_chat(usr, "<span class='notice'>Printing report, please wait...</span>")
		playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)

		addtimer(CALLBACK(src, PROC_REF(make_paper), log), 2 SECONDS) // Create our paper
		log = list() // Clear the logs
		scanning = FALSE
	else
		to_chat(usr, "<span class='warning'>The scanner has no logs or is in use.</span>")


/obj/item/device/detective_scanner/proc/make_paper(log) // Moved to a proc because 'spawn()' is evil
	var/obj/item/weapon/paper/P = new(get_turf(src))
	P.name = "paper- 'Scanner Report'"
	P.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
	P.info += jointext(log, "<BR>")
	P.info += "<HR><B>Notes:</B><BR>"
	P.info_links = P.info
	P.update_icon()

	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(P)
		to_chat(M, "<span class='notice'>Report printed. Log cleared.</span>")

/datum/action/item_action/clear_records
	name = "Clear Scanner Records"

/datum/action/item_action/clear_records/Activate()
	var/obj/item/device/detective_scanner/D = target
	D.clear_scanner()
	return

/obj/item/device/detective_scanner/proc/clear_scanner()
	if(length(log) && !scanning)
		log = list()
		playsound(loc, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), usr, "<span class='notice'>Scanner logs cleared.</span>"), 1.5 SECONDS) //Timer so that it clears on the 'ding'
	else
		to_chat(usr, "<span class='warning'>The scanner has no logs or is in use.</span>")

/obj/item/device/detective_scanner/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	scan(A, user)

/obj/item/device/detective_scanner/attack(mob/living/carbon/human/M, mob/user)
	scan(M, user)
	return

/obj/item/device/detective_scanner/proc/scan(atom/A, mob/user)
	if(!scanning)
		if(loc != user)
			return

		user.visible_message("[user] starts scanning [A] with [src].",
		"<span class='notice'>You start scanning [A]. The scanner is buzzing...</span>")
		scanning = TRUE
		if(do_after(user, 1 SECONDS, target = user))
			if(!A || !user.Adjacent(A))
				to_chat(user, "<span class='warning'>Failed to scan [A].</span>")
				scanning = FALSE
				return
			// GATHER INFORMATION

			//Make our lists
			var/list/fingerprints = list()
			var/list/blood = list()
			var/list/fibers = list()
			var/list/reagents = list()

			var/target_name = A.name

			// Start gathering

			if(length(A.blood_DNA))
				blood = A.blood_DNA.Copy()

			if(length(A.suit_fibers))
				fibers = A.suit_fibers.Copy()

			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(istype(H.dna, /datum/dna) && !H.gloves)
					fingerprints += md5(H.dna.uni_identity)

			else if(!ismob(A))

				if(length(A.fingerprints))
					fingerprints = A.fingerprints.Copy()

				// Only get reagents from non-mobs.
				if(A.reagents && length(A.reagents.reagent_list))

					for(var/datum/reagent/R in A.reagents.reagent_list)
						reagents[R.name] = R.volume

						// Get blood data from the blood reagent.
						if(istype(R, /datum/reagent/blood))

							if(R.data["blood_DNA"] && R.data["blood_type"])
								var/blood_DNA = R.data["blood_DNA"]
								var/blood_type = R.data["blood_type"]
								blood[blood_DNA] = blood_type


			// We gathered everything. Display the results to the holder of the scanner.
			var/found_something = FALSE
			add_log("<B>[worldtime2text()] - [target_name]</B>", FALSE)

			// Fingerprints
			if(length(fingerprints))
				add_log("<span class='notice'><B>Prints:</B></span>")
				for(var/finger in fingerprints)
					add_log("[finger]")
				found_something = TRUE

			// Blood
			if(length(blood))
				add_log("<span class='notice'><B>Blood:</B></span>")
				found_something = TRUE
				for(var/B in blood)
					add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")

			//Fibers
			if(length(fibers))
				add_log("<span class='notice'><B>Fibers:</B></span>")
				for(var/fiber in fibers)
					add_log("[fiber]")
				found_something = TRUE

			//Reagents
			if(length(reagents))
				add_log("<span class='notice'><B>Reagents:</B></span>")
				for(var/R in reagents)
					add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
				found_something = TRUE

			// Get a new user
			var/mob/holder = null
			if(ismob(loc))
				holder = loc

			if(!found_something)
				add_log("<I># No forensic traces found #</I>", FALSE) // Don't display this to the holder user
				if(holder)
					to_chat(holder, "<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [A]!</span>")
			else
				if(holder)
					to_chat(holder, "<span class='notice'>You finish scanning [A].</span>")

			add_log("---------------------------------------------------------", FALSE)
			scanning = FALSE
		else
			scanning = FALSE

/obj/item/device/detective_scanner/proc/add_log(msg, broadcast = TRUE)
	if(scanning)
		if(broadcast && ismob(loc))
			var/mob/M = loc
			to_chat(M, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")
