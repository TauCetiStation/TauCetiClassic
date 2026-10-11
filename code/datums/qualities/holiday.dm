// Put holidays related quirks here. For further explanation and more reading material visit __DEFINES/qualities.dm and qualities/quality.dm
/datum/quality/holiday
	// todo: return QUALITY_POOL_HOLIDAYISH if there is more such qualities in the future
	pools = list(
		QUALITY_POOL_QUIRKIEISH
	)

/datum/quality/holiday/skeleton
	name = "Skeleton"
	desc = "С вами произошел несчастный случай. К сожалению, из-за подозрительных связей вашего начальства, вы опять идёте на работу."
	requirement = "Человек, Унатх, Таяра, Скрелл или Вокс."

	species_required = list(HUMAN, UNATHI, TAJARAN, SKRELL, VOX)
	holidays_required = list(HALLOWEEN)

/datum/quality/holiday/skeleton/add_effect(mob/living/carbon/human/H, latespawn)
	H.makeSkeleton()


/datum/quality/holiday/smoll
	name = "Smoll"
	desc = "По какой-то причине вы всегда недолюбливали мышей."
	requirement = "Нет."

	holidays_required = list(APRIL_FOOLS)

/datum/quality/holiday/smoll/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, ELEMENT_TRAIT_SMOLL, INNATE_TRAIT)
