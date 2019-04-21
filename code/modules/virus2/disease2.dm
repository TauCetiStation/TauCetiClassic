/datum/disease2/disease
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = "Contact" // Can also be "Airborne"
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

/datum/disease2/disease/New()
	uniqueID = rand(0,10000)
	..()

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

	var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
	holder.effect = pick(possible_effects)
	holder.chance = rand(holder.effect.chance_minm, holder.effect.chance_maxm)
	return holder

/datum/disease2/disease/proc/addeffect(var/datum/disease2/effectholder/holder)
	if(holder == null)
		return
	if(effects.len < max_symptoms)
		effects += holder

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

/datum/disease2/disease/proc/reactsleeptoxin()
	if(effects.len > min_symptoms)
		effects -= pick(effects) //remove random effect

/datum/disease2/disease/proc/makerandom(greater=0)
	for(var/i in 1 to 4) //random viruses always have 4 effects
		if(greater)
			addeffect(getrandomeffect(i, 4))
		else
			addeffect(getrandomeffect(1, 2))
	uniqueID = rand(0,10000)
	infectionchance = rand(30,60)
	antigen |= text2num(pick(ANTIGENS))
	antigen |= text2num(pick(ANTIGENS))
	spreadtype = prob(60) ? "Airborne" : "Contact"

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
	if(stage <= 1 && clicks == 0 && !mob.is_infected_with_zombie_virus()) 	// with a certain chance, the mob may become immune to the disease before it starts properly
		if(prob(5))
			mob.antibodies |= antigen // 20% immunity is a good chance IMO, because it allows finding an immune person easily

	//Space antibiotics stop disease completely
	if(mob.reagents.has_reagent("spaceacillin"))
		if(!mob.is_infected_with_zombie_virus())
			if(stage == 1 && prob(20))
				src.cure(mob)
			return
		else
			if(prob(50)) //Antibiotics slow down zombie virus progression but dont stop it completely
				return

	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent("virusfood"))
		mob.reagents.remove_reagent("virusfood",0.1)
		clicks += 10

	//Moving to the next stage
	if(clicks > stage*100 && prob(10) && stage<effects.len)
		stage++

	//Do nasty effects
	for(var/i in 1 to effects.len)
		var/datum/disease2/effectholder/e = effects[i]
		if(i <= stage)
			e.runeffect(mob, src)

	//Short airborne spread
	if(src.spreadtype == "Airborne" && prob(10))
		spread(mob, 1)

	//fever
	mob.bodytemperature = max(mob.bodytemperature, min(310+2*stage ,mob.bodytemperature+2*stage))
	clicks+=speed

/datum/disease2/disease/proc/advance_stage()
	if(stage<effects.len)
		clicks = stage*100
		stage++

/datum/disease2/disease/proc/spread(mob/living/carbon/mob, radius = 1)
	for(var/mob/living/carbon/M in oview(radius,mob))
		if(airborne_can_reach(get_turf(mob), get_turf(M)))
			infect_virus2(M,src)

/datum/disease2/disease/proc/cure(mob/living/carbon/mob)
	for(var/datum/disease2/effectholder/e in effects)
		e.effect.deactivate(mob, e, src)
	mob.virus2.Remove("[uniqueID]")
	mob.hud_updateflag |= 1 << STATUS_HUD

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.stageprob = stageprob
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.affected_species = affected_species.Copy()
	for(var/datum/disease2/effectholder/holder in effects)
		var/datum/disease2/effectholder/newholder = new /datum/disease2/effectholder
		newholder.effect = new holder.effect.type
		newholder.chance = holder.chance
		newholder.multiplier = holder.multiplier
		newholder.effect.copy(holder, newholder, holder.effect)
		//newholder.stage = holder.stage
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
