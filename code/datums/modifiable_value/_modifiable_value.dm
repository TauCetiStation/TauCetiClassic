/*
 * Modifiable value is a float value you can apply modifiers to.
 *
 * Use cases: Movespeed, actionspeed, beauty.
 *
 * General formula for value is: (val * base_multi + base_additive) * multi + additive
 */
/datum/modval
	var/value = 0.0

	var/base_value = 0.0

	var/base_multiplier = 1.0
	var/base_additive = 0.0

	var/multiple = 1.0
	var/additive = 0.0

	var/list/modifiers

/datum/modval/New(new_value, base_multiplier=1.0, base_additive=0.0, multiple=1.0, additive=0.0)
	src.base_multiplier = base_multiplier
	src.base_additive = base_additive
	src.multiple = multiple
	src.additive = additive
	Set(new_value)

/datum/modval/proc/Set(new_value)
	base_value = new_value
	Update()

/datum/modval/proc/Get()
	return value

/datum/modval/proc/Update()
	var/old_value = value
	value = (base_value * base_multiplier + base_additive) * multiple + additive
	SEND_SIGNAL(src, COMSIG_MODVAL_UPDATE, old_value)

/datum/modval/proc/AddModifier(category, base_multiplier=0.0, base_additive=0.0, multiple=0.0, additive=0.0, update=TRUE)
	if(modifiers && modifiers[category])
		RemoveModifier(category, update=FALSE)
	if(!modifiers)
		modifiers = list()

	var/datum/modval_modifier/MM = new(base_multiplier, base_additive, multiple, additive)
	src.base_multiplier += MM.base_multiplier
	src.base_additive += MM.base_additive
	src.multiple += MM.multiple
	src.additive += MM.additive

	if(update)
		Update()

	modifiers[category] = MM

/datum/modval/proc/RemoveModifier(category, update=TRUE)
	var/datum/modval_modifier/MM = modifiers[category]

	base_multiplier -= MM.base_multiplier
	base_additive -= MM.base_multiplier
	multiple -= MM.multiple
	additive -= MM.additive

	qdel(MM)

	if(update)
		Update()

	modifiers -= category
	if(modifiers.len == 0)
		modifiers = null



/datum/modval_modifier
	var/base_multiplier = 0.0
	var/base_additive = 0.0

	var/multiple = 0.0
	var/additive = 0.0

/datum/modval_modifier/New(base_multiplier=0.0, base_additive=0.0, multiple=0.0, additive=0.0)
	src.base_multiplier = base_multiplier
	src.base_additive = base_additive

	src.multiple = multiple
	src.additive = additive
