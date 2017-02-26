/mob/living/silicon/robot/Login()
	..()
	for(var/obj/effect/rune/rune in world)
		var/image/blood = image('icons/effects/blood.dmi',rune,"mfloor[rand(1,7)]",2)
		blood.override = 1
		blood.color = "#a10808"
		client.images += blood
	regenerate_icons()
	show_laws(0)
	if(mind)	ticker.mode.remove_revolutionary(mind)
	if(mind)	ticker.mode.remove_gangster(mind)
	return
