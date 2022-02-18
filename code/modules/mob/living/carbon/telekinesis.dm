/mob/living/carbon/has_tk_power(amount)
	return nutrition > (amount / get_tk_level())

/mob/living/carbon/spend_tk_power(amount)
	nutrition -= amount / get_tk_level()
