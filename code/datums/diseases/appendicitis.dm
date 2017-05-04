/datum/disease/appendicitis // Dunno if we need this disease at all with appendix as organ.
	form = "Condition"
	name = "Appendicitis"
	max_stages = 4
	spread = "Acute"
	cure = "Surgery"
	agent = "Appendix"
	affected_species = list(S_HUMAN)
	permeability_mod = 1
	contagious_period = 9001 //slightly hacky, but hey! whatever works, right?
	desc = "If left untreated the subject will become very weak, and may vomit often."
	severity = "Medium"
	longevity = 1000
	hidden = list(0, 1)
	stage_minimum_age = 160 // at least 200 life ticks per stage

/datum/disease/appendicitis/stage_act()
	..()

	if(istype(affected_mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = affected_mob
		if(H.client && H.stat != DEAD)
			var/obj/item/organ/appendix/A = H.organs_by_name[BP_APPENDIX]
			A.inflamed = 1
			A.update_icon()
	src.cure() // no need to keep disease, because organ will handle everything we need.
