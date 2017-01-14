/atom/verb/point()
	set name = "Point To"
	set category = "Object"
	set src in oview()
	var/atom/this = src//detach proc from src
	src = null

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained())
		return
	if(usr.status_flags & FAKEDEATH)
		return

	var/tile = get_turf(this)
	if (!tile)
		return

	var/obj/P = new /obj/effect/decal/point(tile)
	if(this.pixel_x)
		P.pixel_x = this.pixel_x
	if(this.pixel_y)
		P.pixel_y = this.pixel_y
	spawn (20)
		if(P)	qdel(P)

	usr.visible_message("<b>[usr]</b> points to [this]")

	if(isliving(this))
		for(var/mob/living/carbon/slime/S in view(7))
			if(usr in S.Friends)
				S.last_pointed = this
