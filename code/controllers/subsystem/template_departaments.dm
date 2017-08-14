var/datum/subsystem/template_departaments/SStemplated

/datum/subsystem/template_departaments
	name = "Template Departaments"
	wait = 100
	priority = 0
	can_fire = 0
	init_order = SS_INIT_TEMPLDEP

/datum/subsystem/template_departaments/New()
	NEW_SS_GLOBAL(SStemplated)

/datum/subsystem/template_departaments/Initialize(timeofday, zlevel)
	loadTemplateDepartaments()
	..()
