/datum/role/changeling
	name = CHANGELING
	id = CHANGELING
	required_pref = ROLE_CHANGELING
	special_role = CHANGELING

	antag_hud_type = ANTAG_HUD_CHANGELING
	antag_hud_name = "changeling"

	restricted_jobs = list("AI", "Cyborg", "Security Cadet", "Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	protected_traitor_prob = PROB_PROTECTED_RARE
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

/datum/role/changeling/New()
	. = ..()
	if(.)
		set_changelingID()

/datum/role/changeling/OnPostSetup(var/laterole = FALSE)
	. = ..()
	antag.current.make_changeling()

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

/datum/role/changeling/ForgeObjectives()
	AppendObjective(/datum/objective/absorb)
	AppendObjective(/datum/objective/assassinate)
	AppendObjective(/datum/objective/steal)
	if(prob(80))
		AppendObjective(/datum/objective/survive)
	else
		AppendObjective(/datum/objective/escape)

/datum/role/changeling/proc/changelingRegen()
	if(antag)
		chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
		geneticdamage = max(0, geneticdamage-1)

		antag.current.invisibility = 0
		antag.current.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[chem_charges]</font></div>"

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

/datum/role/changeling/PostMindTransfer(mob/living/new_character, mob/living/old_character)
	new_character.make_changeling() // Will also restore any & all genomes/powers we have

/datum/role/changeling/GetScoreboard()
	. = ..()
	. += "<br><b>Changeling ID:</b> [changelingID]"
	. += "<br><b>Genomes Absorbed:</b> [absorbedcount]"
	. += "<br><b>Stored Essences:</b>"
	for(var/mob/living/parasite/essence/E in essences)
		. += printplayerwithicon(E)
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
	var/dat = ""
	dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];changeling_autoobjectives=1;'>Randomize objectives!</a><br>"
	if(absorbed_dna.len && (antag.current.real_name != absorbed_dna[1]) )
		dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];changeling_initialdna=1'>Transform to initial appearance</a><br>"
	return dat

/datum/role/changeling/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["changeling_autoobjectives"])
		ForgeObjectives()
		to_chat(usr, "<span class='notice'>The objectives for changeling [M.key] have been generated. You can edit them and anounce manually.</span>")

	else if(href_list["changeling_initialdna"])
		if(!absorbed_dna.len)
			to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
		else
			antag.current.dna = absorbed_dna[1]
			antag.current.real_name = antag.current.dna.real_name
			antag.current.UpdateAppearance()
			domutcheck(antag.current, null)
