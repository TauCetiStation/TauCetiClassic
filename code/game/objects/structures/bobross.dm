/obj/structure/bobross
	name = "masterpiece"
	desc = "Just a beautiful painting. You can see a man with afro haircut and a painting with happy little trees on it. There are no mistakes, only happy accidents."
	icon = 'icons/obj/decals.dmi'
	icon_state = "bobross"
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = SIGN_LAYER

/obj/structure/bobross/attack_hand(mob/user)
	if(icon_state == "bobross")
		playsound(src, 'sound/effects/doorcreaky.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You gently open the picture.</span>")
		icon_state = "bobross_opened"
		desc = "Back of the painting. It is written here: 'r.i.p. Bob Ross'"
		pixel_x = pixel_x - 6
		return
	if(icon_state == "bobross_opened")
		playsound(src, 'sound/effects/doorcreaky.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You gently close the picture.</span>")
		icon_state = "bobross"
		desc = "Just a beautiful painting. You can see a man with afro haircut and a painting with happy little trees on it. There are no mistakes, only happy accidents."
		pixel_x = pixel_x + 6
		return
