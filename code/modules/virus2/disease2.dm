#define POOL_POSITIVE_VIRUS "pool_positive_virus"
#define POOL_NEUTRAL_VIRUS "pool_neutral_virus"
#define POOL_NEGATIVE_VIRUS "pool_negative_virus"
var/global/list/virus_types_by_pool

#define NANITE_SHOCK_IMMUNE 0 << 1
#define NANITE_EMP_IMMUNE   1 << 1

//Nanite excess thresholds
#define NANITE_EXCESS_VOMIT 100
#define NANITE_EXCESS_BURST 350

/datum/disease2/disease
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = DISEASE_SPREAD_CONTACT
	var/stage = 1
	var/stageprob = 10
	var/dead = 0
	var/clicks = 0
	var/uniqueID = 0
	var/list/datum/disease2/effectholder/effects = list()
	var/antigen = 0 // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here
	var/min_symptoms = 2
	var/max_symptoms = 6
	var/cooldown_mul = 1
	var/list/affected_species = list(HUMAN , UNATHI , SKRELL , TAJARAN)
	var/list/spread_types = list(DISEASE_SPREAD_AIRBORNE = 2, DISEASE_SPREAD_CONTACT = 2, DISEASE_SPREAD_BLOOD = 6)

	var/nanite_volume = 100		//amount of nanites in the system, used as fuel for nanite programs
	var/max_nanites = 500		//maximum amount of nanites in the system
	var/regen_rate = 0.5		//nanites generated per second
	var/safety_threshold = 50	//how low nanites will get before they stop processing

/datum/disease2/disease/New()
	uniqueID = rand(0,10000)
	..()
	RegisterSignal(src, COMSIG_HANDLE_VIRUS, PROC_REF(on_process))
	RegisterSignal(src, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(src, COMSIG_MOB_DIED, PROC_REF(on_death))
	RegisterSignal(src, COMSIG_ATOM_ELECTROCUTE_ACT, PROC_REF(on_shock))

/datum/disease2/disease/proc/on_process(datum/source, atom/host)
	if(istype(host, /obj/machinery/hydroponics))
		adjust_nanites(null, regen_rate)
		affect_plants(host)
	else if(istype(host, /mob/living/carbon))
		var/mob/living/carbon/mob = host
		if(!IS_IN_STASIS(mob))
			adjust_nanites(null, regen_rate)
		activate(mob)

/datum/disease2/disease/proc/consume_nanites(amount, force = FALSE)
	if(!force)
		if(safety_threshold && (nanite_volume - amount < safety_threshold))
			return FALSE
	adjust_nanites(null, -amount)
	return (nanite_volume > 0)

/**
 * Handles how nanites leave the host's body if they find out that they're currently exceeding the maximum supported amount
 *
 * IC explanation:
 * Normally nanites simply discard excess volume by slowing replication or 'sweating' it out in imperceptible amounts,
 * but if there is a large excess volume, likely due to a programming change that leaves them unable to support their current volume,
 * the nanites attempt to leave the host as fast as necessary to prevent nanite poisoning. This can range from minor oozing to nanites
 * rapidly bursting out from every possible pathway, causing temporary inconvenience to the host.
 */
/datum/disease2/disease/proc/reject_excess_nanites(atom/host)
	if(!isliving(host))
		return
	var/mob/living/mob = host
	var/excess = nanite_volume - max_nanites
	nanite_volume = max_nanites

	switch(excess)
		//Nanites getting rejected in massive amounts, but still enough to make a semi-orderly exit through vomit
		if((NANITE_EXCESS_VOMIT + 0.1) to NANITE_EXCESS_BURST)
			if(iscarbon(mob))
				var/mob/living/carbon/C = mob
				C.vomit(vomit_type = VOMIT_NANITE)
		//Way too many nanites, they just leave through the closest exit before they harm/poison the host
		if((NANITE_EXCESS_BURST + 0.1) to INFINITY)
			mob.visible_message("<span class='userdanger'>A torrent of metallic grey slurry violently bursts out of [mob]'s face and floods out of [mob] skin!</span>",
								"<span class='userdanger'>A torrent of metallic grey slurry violently bursts out of your eyes, ears, and mouth, and floods out of your skin!</span>")
			//nanites coming out of your eyes
			mob.become_nearsighted(EYE_DAMAGE_TEMPORARY_TRAIT)
			addtimer(CALLBACK(mob, /mob.proc/cure_nearsighted, EYE_DAMAGE_TEMPORARY_TRAIT), 60 SECONDS, TIMER_STOPPABLE)
			mob.apply_effects(stun = 10, weaken = 15, paralyze = 5, eyeblur = 5, agony = 25)
			if(iscarbon(mob))
				var/mob/living/carbon/C = mob
				//nanites coming out of your ears
				C.ear_deaf += 30
				//nanites coming out of your mouth
				C.vomit(vomit_type = VOMIT_NANITE)

///Modifies the current nanite volume, then checks if the nanites are depleted or exceeding the maximum amount
/datum/disease2/disease/proc/adjust_nanites(datum/source, amount, atom/host)
	SIGNAL_HANDLER

	nanite_volume += amount
	//a large loss of nanites is accompanied by a small amount of blood loss in humans
	if(amount <= -5)
		if(ishuman(host))
			var/mob/living/carbon/human/H = host
			// Normal blood value is 560, value when nanites can deactivate is 336
			H.blood_remove(abs(amount))
	if(nanite_volume > max_nanites)
		reject_excess_nanites(host)
	if(nanite_volume <= 0) //oops we ran out
		qdel(src)

/datum/disease2/disease/proc/on_emp(datum/source, atom/host, severity)
	SIGNAL_HANDLER
	nanite_volume *= (rand(60, 90) * 0.01) //Lose 10-40% of nanites
	adjust_nanites(null, -(rand(5, 50)), host) //Lose 5-50 flat nanite volume
	for(var/datum/disease2/effectholder/NP as anything in effects)
		NP.effect.on_emp(source, severity, src)

/datum/disease2/disease/proc/on_shock(datum/source, atom/host, shock_damage, siemens_coeff = 1, flags = NONE)
	SIGNAL_HANDLER
	if(shock_damage < 1)
		return
	nanite_volume *= (rand(45, 80) * 0.01) //Lose 20-55% of nanites
	adjust_nanites(null, -(rand(5, 50)), host)  //Lose 5-50 flat nanite volume
	for(var/datum/disease2/effectholder/NP as anything in effects)
		NP.effect.on_shock(source, shock_damage, src)

/datum/disease2/disease/proc/on_death(datum/source, atom/host, gibbed)
	SIGNAL_HANDLER
	for(var/datum/disease2/effectholder/NP as anything in effects)
		NP.effect.on_death(source, gibbed, src)

/datum/disease2/disease/proc/haseffect(datum/disease2/effect/checkeffect)
	for(var/datum/disease2/effectholder/e in effects)
		if(e.effect.type == checkeffect.type)
			return TRUE
	return FALSE

/datum/disease2/disease/proc/getrandomeffect(minlevel = 1, maxlevel = 4)
	var/list/datum/disease2/effect/possible_effects = list()
	for(var/e in subtypesof(/datum/disease2/effect))
		var/datum/disease2/effect/f = new e
		if (f.level > maxlevel)	//we don't want such strong effects
			continue
		if (f.level < minlevel)
			continue
		if(haseffect(f))
			continue
		possible_effects += f
	if(!possible_effects.len)
		return null

	var/datum/disease2/effectholder/holder = get_new_effectholder(pick(possible_effects))
	return holder

/datum/disease2/disease/proc/get_new_effectholder(datum/disease2/effect/based_effect)
	var/datum/disease2/effectholder/new_ef_holder = new /datum/disease2/effectholder
	new_ef_holder.effect = based_effect
	new_ef_holder.chance = rand(based_effect.chance_minm, based_effect.chance_maxm)
	return new_ef_holder

/datum/disease2/disease/proc/addeffect(datum/disease2/effectholder/holder)
	if(holder == null)
		return
	if(effects.len < max_symptoms)
		effects += holder
		holder.on_adding()

/datum/disease2/disease/proc/radiate()
	effects = shuffle(effects)
	affected_species = get_infectable_species()

/datum/disease2/disease/proc/reactfood()
	addeffect(getrandomeffect(1,1))

/datum/disease2/disease/proc/reacttoxin()
	addeffect(getrandomeffect(2,2))

/datum/disease2/disease/proc/reactsynaptizine()
	addeffect(getrandomeffect(3,3))

/datum/disease2/disease/proc/reactphoron()
	addeffect(getrandomeffect(4,4))

/datum/disease2/disease/proc/remove_effect(datum/disease2/effectholder/ef_holder)
	if(effects.len <= min_symptoms)
		return FALSE
	effects -= ef_holder
	UnregisterSignal(ef_holder, COMSIG_HANDLE_VIRUS)
	return TRUE

/datum/disease2/disease/proc/reactsleeptoxin()
	//remove random effect
	remove_effect(pick(effects))

/datum/disease2/disease/proc/get_random_effect_total(minlvl = 1, maxlvl = 4, pool_name = null)
	var/static/list/pool_distribution = list(
		POOL_POSITIVE_VIRUS = 25,
		POOL_NEUTRAL_VIRUS = 25,
		POOL_NEGATIVE_VIRUS = 50,
	)
	var/pickedpool = pool_name ? pool_name : pickweight(pool_distribution)
	var/list/effects_pool_list = list()
	for(var/type as anything in global.virus_types_by_pool[pickedpool])
		var/datum/disease2/effect/e = new type
		effects_pool_list += e
	for(var/datum/disease2/effect/e as anything in effects_pool_list)
		if(e.level > maxlvl)
			effects_pool_list -= e
		if(e.level < minlvl)
			effects_pool_list -= e
		if(haseffect(e))
			effects_pool_list -= e
	if(!effects_pool_list.len)
		//recursive
		return get_random_effect_total(max(minlvl - 1, 1), maxlvl + 1, pickedpool)

	var/datum/disease2/effect/effect = pick(effects_pool_list)
	var/datum/disease2/effectholder/holder = get_new_effectholder(effect)
	effects_pool_list -= effect
	for(var/eff as anything in effects_pool_list)
		qdel(eff)
	return holder

/datum/disease2/disease/proc/makerandom(greater = 0, spread_vector)
	for(var/i in 1 to 4) //random viruses always have 4 effects
		if(greater)
			addeffect(get_random_effect_total(i, 4))
		else
			addeffect(get_random_effect_total(1, 2))
	uniqueID = rand(0,10000)
	infectionchance = rand(30,60)
	antigen |= text2num(pick(ANTIGENS))
	antigen |= text2num(pick(ANTIGENS))
	if(spread_vector)
		spreadtype = spread_vector
	else
		spreadtype = pickweight(spread_types)

	if(all_species.len)
		affected_species = get_infectable_species()

/proc/get_infectable_species()
	var/list/meat = list()
	var/list/res = list()
	for (var/specie in all_species)
		var/datum/species/S = all_species[specie]
		if(!S.flags[VIRUS_IMMUNE] && S.name)
			meat += S.name
	if(meat.len)
		var/num = rand(1,meat.len)
		for(var/i=0,i<num,i++)
			var/picked = pick(meat)
			meat -= picked
			res += picked
	return res

/datum/disease2/disease/proc/activate(mob/living/carbon/mob)
	if(dead)
		cure(mob)
		return

	if(mob.stat == DEAD)
		return

	if(HAS_TRAIT(mob, TRAIT_VACCINATED))
		return

	if(stage <= 1 && clicks == 0 && !mob.is_infected_with_zombie_virus()) 	// with a certain chance, the mob may become immune to the disease before it starts properly
		if(prob(5))
			mob.antibodies |= antigen // 20% immunity is a good chance IMO, because it allows finding an immune person easily

	//Space antibiotics stop disease completely
	if(mob.reagents.has_reagent("spaceacillin"))
		if(!mob.is_infected_with_zombie_virus())
			if(stage == 1 && prob(20))
				cure(mob)
			return
		else
			if(prob(50)) //Antibiotics slow down zombie virus progression but dont stop it completely
				return

	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent("virusfood"))
		mob.reagents.remove_reagent("virusfood",0.1)
		clicks += 10

	//fever
	mob.adjust_bodytemperature(2 * stage, max_temp = BODYTEMP_NORMAL + 2 * stage)
	activate_symptom(mob)

/datum/disease2/disease/proc/activate_symptom(atom/A)
	//Moving to the next stage
	if(clicks > stage * 100 && prob(10) && stage < effects.len)
		stage++

	//Do nasty effects
	for(var/i in 1 to effects.len)
		var/datum/disease2/effectholder/e = effects[i]
		if(i <= stage)
			e.runeffect(A, src)

	//Short airborne spread
	if(spreadtype == DISEASE_SPREAD_AIRBORNE && prob(10))
		spread(A, 1)

	clicks += speed

/datum/disease2/disease/proc/affect_plants(obj/machinery/hydroponics/tray)
	activate_symptom(tray)

/datum/disease2/disease/proc/advance_stage()
	if(stage<effects.len)
		clicks = stage*100
		stage++

/datum/disease2/disease/proc/spread(atom/A, radius = 1)
	if(ismob(A))
		spread_mob(A, radius)
		return
	if(istype(A, /obj/machinery/hydroponics))
		spread_plant(A, radius)

/datum/disease2/disease/proc/spread_mob(mob/living/carbon/mob, radius = 1)
	if(spreadtype == DISEASE_SPREAD_BLOOD)
		return
	for(var/mob/living/carbon/M in oview(radius, mob))
		if(airborne_can_reach(get_turf(mob), get_turf(M)))
			infect_virus2(M, src)
			mob.med_hud_set_status()

/datum/disease2/disease/proc/spread_plant(obj/machinery/hydroponics/my_tray, radius = 1)
	if(spreadtype != DISEASE_SPREAD_AIRBORNE)
		return
	if(!my_tray.can_be_infected(src))
		return
	for(var/obj/machinery/hydroponics/tray in range(radius, my_tray))
		tray.infect_planttray_virus2(src)

/datum/disease2/disease/proc/deactivate(atom/A)
	for(var/datum/disease2/effectholder/e in effects)
		e.effect.deactivate(A, e, src)

/datum/disease2/disease/proc/cure(mob/living/carbon/mob)
	deactivate(mob)
	mob.virus2.Remove("[uniqueID]")
	mob.med_hud_set_status()

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.stageprob = stageprob
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.affected_species = affected_species.Copy()
	for(var/datum/disease2/effectholder/holder in effects)
		var/datum/disease2/effect/copied_effect = new holder.effect.type
		var/datum/disease2/effectholder/newholder = get_new_effectholder(copied_effect)
		newholder.chance = holder.chance
		newholder.multiplier = holder.multiplier
		newholder.effect.copy(holder, newholder, holder.effect)
		disease.effects += newholder
	return disease

/datum/disease2/disease/proc/issame(datum/disease2/disease/disease)
	var/list/types = list()
	var/list/types2 = list()
	for(var/datum/disease2/effectholder/d in effects)
		types += d.effect.type
	var/equal = 1

	for(var/datum/disease2/effectholder/d in disease.effects)
		types2 += d.effect.type

	for(var/type in types)
		if(!(type in types2))
			equal = 0

	if (antigen != disease.antigen)
		equal = 0
	return equal

/proc/virus_copylist(list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		res["[V.uniqueID]"] = V.getcopy()
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name()
	.= "stamm #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/data/record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_info()
	var/r = {"
	<small>Analysis determined the existence of a GNAv2-based viral lifeform.</small><br>
	<u>Designation:</u> [name()]<br>
	<u>Antigen:</u> [antigens2string(antigen)]<br>
	<u>Transmitted By:</u> [spreadtype]<br>
	<u>Rate of Progression:</u> [stageprob * 10]<br>
	<u>Species Affected:</u> [jointext(affected_species, ", ")]<br>
"}

	r += "<u>Symptoms:</u><br>"
	for(var/datum/disease2/effectholder/E in effects)
		r += "[E.effect.name]    "
		r += "<small><u>Strength:</u> [E.effect.level >= 3 ? "Severe" : E.effect.level > 1 ? "Above Average" : "Average"]    "
		r += "<u>Verosity:</u> [E.chance * 15]</small><br>"

	return r

/datum/disease2/disease/proc/addToDB()
	if ("[uniqueID]" in virusDB)
		return 0
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigens2string(antigen)
	v.fields["spread type"] = spreadtype
	virusDB["[uniqueID]"] = v
	return 1

/proc/virus2_lesser_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G

	if(!candidates.len)	return

	candidates = shuffle(candidates)

	infect_mob_random_lesser(candidates[1])

/proc/virus2_greater_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return

	candidates = shuffle(candidates)

	infect_mob_random_greater(candidates[1])

/proc/virology_letterhead(report_name)
	return {"
		<center><h1><b>[report_name]</b></h1></center>
		<center><small><i>[station_name()] Virology Lab</i></small></center>
		<hr>
"}

/obj/machinery/disease2
	allowed_checks = ALLOWED_CHECK_TOPIC
