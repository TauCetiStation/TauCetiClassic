/obj/structure/pbag
	name = "punching bag"
	desc = "It's made by some goons."

	icon = 'code/modules/sports/pbag.dmi'
	icon_state = "pbag"

	density = 0
	anchored = 1

	var/health = 1000

/obj/structure/pbag/New()
	//color = pick("#aaffaa", "#aaaaff", "#ff3030", "#ff1010", "#ffffff")
	color = random_color()

/obj/structure/pbag/attack_hand(mob/user)
	if(!anchored) return
	user.do_attack_animation(src)
	hit(user)

/obj/structure/pbag/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
			else
				down()
		if(3.0)
			swing(rand(10, 50))
			return

/obj/structure/pbag/proc/down()
	anchored = 0
	icon_state = "pbagdown"
	playsound(src.loc, 'sound/weapons/tablehit1.ogg', 70, 1, -1)
	update_icon()
	return

/obj/structure/pbag/proc/hit(mob/user)
	if(health < 0)
		down()
	else
		if(HULK in user.mutations)
			health -= rand(100, 500)
		else
			health -= rand(10, 50)
		playsound(src.loc, "swing_hit", 50, 1, -1)
		swing()

	return

/obj/structure/pbag/proc/swing(time = rand(5, 20))
	icon_state = "pbaghit"
	spawn(time)
		icon_state = "pbag"

/obj/structure/pbag/verb/hang()
	set name = "Hang Bag"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/user = usr

	if(iscarbon(user))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		src.anchored = !src.anchored
		user.visible_message("[user] [anchored? "secures":"unsecures"] the [src].", \
			"You [anchored? "secure":"undo"] the external bolts.", \
			"You hear a ratchet")

	if(anchored)
		icon_state = "pbag"
		health = 1000
	else
		icon_state = "pbagdown"
		health = 0
