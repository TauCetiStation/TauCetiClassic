/proc/BaseValueModifiable(list/p)
	return (
		p["base_multiplier"] * p["base_value"] + p["base_additive"]
	) * p["multiplier"] + p["multiplier"]

var/global/datum/callback/BaseValueModifiableFormula = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(BaseValueModifiable))

/proc/CreateBaseValueStat(base_value)
	return new /stat(
		list(
			"base_value" = base_value,
			"base_multiplier" = 1.0,
			"base_additive" = 0.0,
			"multiplier" = 1.0,
			"additive" = 0.0,
		),
		global.BaseValueModifiableFormula,
	)
