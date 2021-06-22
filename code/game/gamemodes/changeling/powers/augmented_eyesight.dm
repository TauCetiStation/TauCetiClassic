/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Дополнительные Фоторецепторы"
	desc = "Создаёт в наших глазах тепловые рецепторы и значительно увеличивает чувствительность к свету."
	helptext = "Даёт вам ночное и термальное видение. Может включаться и выключаться."
	chemical_cost = 0
	genomecost = 3
	var/active = 0 //Whether or not vision is enhanced
	req_stat = UNCONSCIOUS

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/user)
	active = !active
	user.changeling_aug = !user.changeling_aug
	if(active)
		to_chat(user, "<span class='notice'>We feel a minute twitch in our eyes, and darkness creeps away.</span>")
		user.sight |= SEE_MOBS
		user.see_in_dark = 8
		user.see_invisible = SEE_INVISIBLE_MINIMUM
	else
		to_chat(user, "<span class='notice'>Our vision dulls. Shadows gather.</span>")
		user.sight -= SEE_MOBS
		user.see_in_dark = 0
		user.see_invisible = SEE_INVISIBLE_LIVING
	return 1

/mob/living
	var/changeling_aug = 0
