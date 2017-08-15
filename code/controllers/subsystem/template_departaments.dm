var/datum/subsystem/template_departments/SStempldep

/datum/subsystem/template_departments
	name = "Template Departaments"
	wait = 100
	priority = 0
	can_fire = 0
	flags = SS_NO_FIRE
	init_order = SS_INIT_TEMPLDEP

/datum/subsystem/template_departments/New()
	NEW_SS_GLOBAL(SStempldep)

/datum/subsystem/template_departments/Initialize(timeofday, zlevel)
	load_template_departments()
	..()
