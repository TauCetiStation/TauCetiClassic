/datum/role/changeling
	name = CHANGELING
	id = CHANGELING
	required_pref = ROLE_CHANGELING

	antag_hud_type = ANTAG_HUD_CHANGELING
	antag_hud_name = "changeling"

	restricted_jobs = list("AI", "Cyborg", "Security Cadet", "Security Officer", "Warden", "Head of Security", "Captain", "Blueshield Officer")
	restricted_species_flags = list(IS_PLANT, IS_SYNTHETIC, NO_SCAN)
	logo_state = "change-logoa"

	stat_type = /datum/stat/role/changeling
	moveset_type = /datum/combat_moveset/changeling

	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 1
	var/chem_storage = 50
	var/chem_recharge_slowdown = 0
	var/sting_range = 1
	var/changelingID = "Changeling" // flavor ID like Theta/Tau/etc.
	var/unique_changeling_marker // unique ID like DNA but secret
	var/geneticdamage = 0
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
	var/absorbedamount = 0 //precise amount of ppl absorbed

	var/atom/movable/screen/lingchemdisplay
	var/atom/movable/screen/lingstingdisplay

/datum/role/changeling/OnPostSetup(laterole = FALSE)
	. = ..()
	antag.current.make_changeling()
	set_changeling_identifications()

	var/mob/living/carbon/human/H = antag.current
	if(istype(H))
		H.fixblood(FALSE) // to add changeling marker

	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "changeling", /datum/mood_event/changeling)

/datum/role/changeling/proc/set_changeling_identifications()
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

	unique_changeling_marker = md5("\ref[src]")

/datum/role/changeling/Greet(greeting, custom)
	if(!..())
		return FALSE

	antag.current.playsound_local(null, 'sound/antag/ling_aler.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='danger'>Воспользуйтесь \":g message\" для коммуникации с остальными Генокрадами. Помните: вы поглощаете все образцы ДНК, которые поглотила ваша жертва-генокрад.</span>")
	to_chat(antag.current, "<span class='notice'>Мы - Генокрад, существа из далёких уголков космоса. У нас есть задачи на этой станции, которые нужно выполнить, используя свою сообразительность и при необходимости свои генетические возможности (возле вкладки Status в правой-верхней части экрана, у вас появилась вкладка - Changelling, в которой можно приобрети и использовать новые мутации).</span>")
	if(antag.current.mind && antag.current.mind.assigned_role == "Clown")
		to_chat(antag.current, "Вы развились за пределы своей клоунской природы, что позволит вам пользоваться оружием без вреда для вас.")
		REMOVE_TRAIT(antag.current, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)

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

/datum/role/changeling/add_ui(datum/hud/hud)
	if(!lingchemdisplay)
		lingchemdisplay = new /atom/movable/screen/chemical_display
	if(!lingstingdisplay)
		lingstingdisplay = new /atom/movable/screen/current_sting

	lingchemdisplay.add_to_hud(hud)
	lingstingdisplay.add_to_hud(hud)

/datum/role/changeling/remove_ui(datum/hud/hud)
	lingchemdisplay.remove_from_hud(hud)
	lingstingdisplay.remove_from_hud(hud)

/datum/role/changeling/RemoveFromRole(datum/mind/M, msg_admins)
	SEND_SIGNAL(antag.current, COMSIG_CLEAR_MOOD_EVENT, "changeling")
	M.current.remove_changeling_powers(FALSE)
	to_chat(antag.current, "<span class ='danger'>Ваш геном слабеет, а вместе с ним и засыпают ваши силы! \
		ТЫ более не генокрад, и теперь нынешний облик - твой единственный!</span>")
	. = ..()

/datum/role/changeling/proc/changelingRegen()
	chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
	geneticdamage = max(0, geneticdamage-1)

	if(antag?.current?.hud_used)
		lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[chem_charges]</font></div>"

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
		. += printplayer(E?.mind)
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
			if(S.chemical_cost >= 0 && S.can_be_used_by(antag.current))
				statpanel("[S.panel]", ((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""), S)


#define OVEREATING_AMOUNT 6
/datum/role/changeling/proc/handle_absorbing()
	var/mob/living/carbon/human/changeling = antag.current

	if(absorbedamount == round(OVEREATING_AMOUNT / 2))
		to_chat(changeling, "<span class='warning'>Поглощение многих генов заставило нас осознать, что мы на полпути к превращению в Мерзость - большую угрозу для всех, даже для нас. Нам следует быть аккуратнее с поглощениями.</span>")

	else if(absorbedamount == OVEREATING_AMOUNT - 1)
		to_chat(changeling, "<span class='warning'>Мы ощущаем грань, за которой находится еще более отвратительное и невообразимое человеку обличие - <B>это необратимо</B>.</span>")

	else if(absorbedamount == OVEREATING_AMOUNT)
		to_chat(changeling, "<span class='danger'>Мы ощущаем, как наша плоть мутирует. Мы забываем всё. Новые конечности прорываются наружу, на их концах - смертоносные когти. Мы преобразились. <B>Мы - МЕРЗОСТЬ</B>. Конец близится.</span>")
		for(var/obj/item/I in changeling) //drops all items
			changeling.drop_from_inventory(I)
		changeling.Stun(10)
		addtimer(CALLBACK(src, PROC_REF(turn_to_abomination)), 30)

/datum/role/changeling/proc/turn_to_abomination()
	var/mob/living/carbon/human/changeling = antag.current
	changeling.set_species(ABOMINATION)
	changeling.name = "[changelingID]"
	changeling.real_name = changeling.name
	geneticpoints += 6

	notify_ghosts("\A [changelingID], changeling as a new abomination, at [get_area(changeling)]!", source = changeling, action = NOTIFY_ORBIT, header = "Abomination")
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, "<font size='7' color='red'><b>A terrible roar is coming from somewhere around the station.</b></font>")
			M.playsound_local(null, 'sound/antag/abomination_start.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

#undef OVEREATING_AMOUNT
