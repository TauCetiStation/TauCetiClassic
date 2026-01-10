/obj/structure/big_rock
	name = "big rock"
	desc = "Ты чувствуешь бессмысленность бытия"
	icon = 'icons/obj/objects.dmi'
	icon_state = "rock"
	density = TRUE

/obj/structure/big_rock/Bumped(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		L.Stun(0.5)
