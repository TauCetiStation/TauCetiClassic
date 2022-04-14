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

	var/damaged = FALSE // needs recalculating

/datum/modval/New(new_value, base_multiplier=1.0, base_additive=0.0, multiple=1.0, additive=0.0)
	src.base_multiplier = base_multiplier
	src.base_additive = base_additive
	src.multiple = multiple
	src.additive = additive
	Set(new_value)

/datum/modval/Destroy()
	QDEL_LIST_ASSOC_VAL(modifiers) // since modifiers hold reference to us, let them clean it up
	return ..()

/datum/modval/proc/Set(new_value)
	base_value = new_value
	damaged = TRUE

/datum/modval/proc/Get()
	if(damaged)
		Update()
	return value

/datum/modval/proc/Update()
	var/old_value = value
	value = (base_value * base_multiplier + base_additive) * multiple + additive
	damaged = FALSE
	SEND_SIGNAL(src, COMSIG_MODVAL_UPDATE, old_value)

/datum/modval/proc/AddModifier(category, base_multiplier=0.0, base_additive=0.0, multiple=0.0, additive=0.0)
	if(modifiers && modifiers[category])
		RemoveModifier(category)
	if(!modifiers)
		modifiers = list()

	var/datum/modval_modifier/MM = new(base_multiplier, base_additive, multiple, additive)
	MM.Attach(src)
	modifiers[category] = MM

/datum/modval/proc/RemoveModifier(category)
	var/datum/modval_modifier/MM = modifiers[category]
	qdel(MM)

	modifiers -= category
	if(modifiers.len == 0)
		modifiers = null

/datum/modval_modifier
	var/base_multiplier = 0.0
	var/base_additive = 0.0

	var/multiple = 0.0
	var/additive = 0.0

	var/datum/modval/holder

/datum/modval_modifier/New(base_multiplier=0.0, base_additive=0.0, multiple=0.0, additive=0.0)
	src.base_multiplier = base_multiplier
	src.base_additive = base_additive

	src.multiple = multiple
	src.additive = additive

/datum/modval_modifier/Destroy()
	Detach()
	return ..()

/datum/modval_modifier/proc/Attach(datum/modval/holder)
	src.holder = holder
	Commit()

/datum/modval_modifier/proc/Detach()
	Withdraw()
	holder = null

/datum/modval_modifier/proc/Commit()
	if(!holder)
		return

	holder.base_multiplier += base_multiplier
	holder.base_additive += base_multiplier
	holder.multiple += multiple
	holder.additive += additive
	holder.damaged = TRUE

/datum/modval_modifier/proc/Withdraw()
	if(!holder)
		return

	holder.base_multiplier -= base_multiplier
	holder.base_additive -= base_multiplier
	holder.multiple -= multiple
	holder.additive -= additive
	holder.damaged = TRUE

/datum/modval_modifier/proc/SetBaseMultiplier(base_multiplier)
	Withdraw()
	src.base_multiplier = base_multiplier
	Commit()

/datum/modval_modifier/proc/SetBaseAdditive(base_additive)
	Withdraw()
	src.base_additive = base_additive
	Commit()

/datum/modval_modifier/proc/SetMultiplier(multiple)
	Withdraw()
	src.multiple = multiple
	Commit()

/datum/modval_modifier/proc/SetAdditive(additive)
	Withdraw()
	src.additive = additive
	Commit()

// null means no change
/datum/modval_modifier/proc/Set(base_multiplier = null, base_additive = null, multiple = null, additive = null)
	Withdraw()
	if(!isnull(base_multiplier))
		src.base_multiplier = base_multiplier
	if(!isnull(base_additive))
		src.base_additive = base_additive
	if(!isnull(multiple))
		src.multiple = multiple
	if(!isnull(additive))
		src.additive = additive
	Commit()
