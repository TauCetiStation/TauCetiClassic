// Put holidays related quirks here. For further explanation and more reading material visit __DEFINES/qualities.dm and qualities/quality.dm
/datum/quality/holiday
	pools = list(
		QUALITY_POOL_HOLIDAYISH
	)

/datum/quality/holiday/skeleton
	name = "Skeleton"
	desc = "С вами произошел несчастный случай. К сожалению, из-за подозрительных связей вашего начальника, вы опять идёте на работу."
	requirement = "Человек, Унатх, Таяра, Скрелл или Вокс."

	species_required = list(HUMAN, UNATHI, TAJARAN, SKRELL, VOX)
	holidays_required = list(HALLOWEEN)

/datum/quality/holiday/skeleton/add_effect(mob/living/carbon/human/H, latespawn)
	H.makeSkeleton()
