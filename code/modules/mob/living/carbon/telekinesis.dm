/mob/living/carbon/has_tk_power(amount)
	return nutrition > amount

/mob/living/carbon/spend_tk_power(amount)
	nutrition -= amount
