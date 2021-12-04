/datum/role/changeling
	name = CHANGELING
	id = CHANGELING
	required_pref = ROLE_CHANGELING

	antag_hud_type = ANTAG_HUD_CHANGELING
	antag_hud_name = "changeling"

	restricted_jobs = list("AI", "Cyborg", "Security Cadet", "Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_species_flags = list(IS_PLANT, IS_SYNTHETIC, NO_SCAN)
	logo_state = "change-logoa"

	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 1
	var/chem_storage = 50
	var/chem_recharge_slowdown = 0
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/list/purchasedpowers = list()
	var/mimicing = ""
	var/datum/dna/chosen_dna
	var/obj/effect/proc_holder/changeling/sting/chosen_sting
	var/space_suit_active = 0
	var/instatis = 0
	var/strained_muscles = 0
	var/list/essences = list()
	var/mob/living/parasite/essence/trusted_entity
	var/mob/living/parasite/essence/controled_by
	var/delegating = FALSE

/datum/role/changeling/OnPostSetup(laterole = FALSE)
	. = ..()
	antag.current.make_changeling()
	set_changelingID()

/datum/role/changeling/proc/set_changelingID()
	var/honorific
	if(antag.current.gender == FEMALE)
		honorific = "Ms."
	else
		honorific = "Mr."
	if(greek_pronunciation.len)
		changelingID = pick(greek_pronunciation)
		if(changelingID == "Tau") // yeah, cuz we can
			geneticpoints++
		greek_pronunciation -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/role/changeling/Greet(greeting, custom)
	if(!..())
		return FALSE

	antag.current.playsound_local(null, 'sound/antag/ling_aler.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='danger'>Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</span>")

	if(antag.current.mind && antag.current.mind.assigned_role == "Clown")
		to_chat(antag.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
		antag.current.mutations.Remove(CLUMSY)

	return TRUE

/datum/role/changeling/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/absorb)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/steal)
	if(prob(80))
		AppendObjective(/datum/objective/survive)
	else
		AppendObjective(/datum/objective/escape)
	return TRUE

/datum/role/changeling/RemoveFromRole(datum/mind/M, msg_admins)
	antag?.current?.hud_used.lingchemdisplay.invisibility = 101
	. = ..()

/datum/role/changeling/proc/changelingRegen()
	if(!antag)
		return
	chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
	geneticdamage = max(0, geneticdamage-1)

	if(antag.current?.hud_used?.lingchemdisplay)
		antag.current.hud_used.lingchemdisplay.invisibility = 0
		antag.current.hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[chem_charges]</font></div>"

/datum/role/changeling/proc/GetDNA(dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna

/datum/role/changeling/process()
	changelingRegen()
	..()

/datum/role/changeling/GetScoreboard()
	. = ..()
	. += "<br><b>Changeling ID:</b> [changelingID]"
	. += "<br><b>Genomes Absorbed:</b> [absorbedcount]"
	. += "<br><b>Stored Essences:</b><br>"
	for(var/mob/living/parasite/essence/E in essences)
		. += printplayerwithicon(E?.mind)
		. += "<br>"
	if(purchasedpowers.len)
		. += "<br><b>[changelingID] used the following abilities: </b>"
		var/i = 0
		for(var/obj/effect/proc_holder/changeling/C in purchasedpowers)
			if(C.genomecost >= 1)
				. += "<br><b>#[++i]</b>: [C.name]"
	else
		. += "<br>Changeling was too autistic and did't buy anything."

/datum/role/changeling/extraPanelButtons()
	var/dat = ..()
	if(absorbed_dna.len && (antag.current.real_name != absorbed_dna[1]) )
		dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];changeling_initialdna=1'>(Transform to initial appearance)</a>"
	return dat

/datum/role/changeling/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["changeling_initialdna"])
		if(!absorbed_dna.len)
			to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
		else
			antag.current.dna = absorbed_dna[1]
			antag.current.real_name = antag.current.dna.real_name
			antag.current.UpdateAppearance()
			domutcheck(antag.current, null)

/datum/role/changeling/StatPanel()
	stat(null, "Chemical Storage: [chem_charges]/[chem_storage]")
	stat(null, "Genetic Damage Time: [geneticdamage]")
	stat(null, "Absorbed DNA: [absorbedcount]")
	if(purchasedpowers.len)
		for(var/P in purchasedpowers)
			var/obj/effect/proc_holder/changeling/S = P
			if(S.chemical_cost >= 0 && S.can_be_used_by(antag?.current))
				statpanel("[S.panel]", ((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""), S)


#define OVEREATING_AMOUNT 6
/datum/role/changeling/proc/handle_absorbing()
	var/mob/living/carbon/human/changeling = antag.current

	if(absorbedcount == round(OVEREATING_AMOUNT / 2))
		to_chat(changeling, "<span class='warning'>Absorbing that many made us realise that we are halfway to becoming a threat to all - even ourselves. We should be more careful with absorbings.</span>")

	else if(absorbedcount == OVEREATING_AMOUNT - 1)
		to_chat(changeling, "<span class='warning'>We feel like we're near the edge to transforming to something way more brutal and inhuman - <B>and there will be no way back</B>.</span>")

	else if(absorbedcount == OVEREATING_AMOUNT)
		to_chat(changeling, "<span class='danger'>We feel our flesh mutate, ripping all our belongings from our body. Additional limbs burst out of our chest along with deadly claws - we've become <B>The Abomination</B>. The end approaches.</span>")
		for(var/obj/item/I in changeling) //drops all items
			changeling.drop_from_inventory(I)
		changeling.Stun(10)
		addtimer(CALLBACK(src, .proc/turn_to_abomination), 30)

/datum/role/changeling/proc/turn_to_abomination()
	var/mob/living/carbon/human/changeling = antag.current
	changeling.set_species(ABOMINATION)
	changeling.name = "[changelingID]"
	changeling.real_name = changeling.name
	geneticpoints += 6

	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, "<font size='7' color='red'><b>A terrible roar is coming from somewhere around the station.</b></font>")
			M.playsound_local(null, 'sound/antag/abomination_start.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

#undef OVEREATING_AMOUNT
