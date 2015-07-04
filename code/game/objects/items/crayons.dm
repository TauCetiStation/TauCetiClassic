/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	shadeColour = "#810C0C"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	shadeColour = "#A55403"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	shadeColour = "#886422"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	shadeColour = "#61840F"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	shadeColour = "#0082A8"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	shadeColour = "#810CFF"
	colourName = "purple"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	shadeColour = "#000000"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob) //inversion
	if(colour != "#FFFFFF" && shadeColour != "#000000")
		colour = "#FFFFFF"
		shadeColour = "#000000"
		user << "You will now draw in white and black with this crayon."
	else
		colour = "#000000"
		shadeColour = "#FFFFFF"
		user << "You will now draw in black and white with this crayon."
	return

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	shadeColour = "#000FFF"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	colour = input(user, "Please select the main colour.", "Crayon colour") as color
	shadeColour = input(user, "Please select the shade colour.", "Crayon colour") as color
	return

/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	if(!uses)
		user << "<span class='warning'>There is no more of [src.name] left!</span>"
		if(!instant)
			qdel(src)
		return
	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc
	if(is_type_in_list(target,validSurfaces))
		var/temp
		var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") in list("graffiti","rune","letter")
		switch(drawtype)
			if("letter")
				drawtype = input("Choose the letter.", "Crayon scribbles") in list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
				user << "You start drawing a letter on the [target.name]."
			if("graffiti")
				user << "You start drawing graffiti on the [target.name]."
			if("rune")
				user << "You start drawing a rune on the [target.name]."

		////////////////////////// GANG FUNCTIONS
		var/area/territory
		var/gangID
		if(gang)
			//Determine gang affiliation
			if(user.mind in (ticker.mode.A_bosses | ticker.mode.A_gang))
				temp = "[gang_name("A")] gang tag"
				gangID = "A"
			else if(user.mind in (ticker.mode.B_bosses | ticker.mode.B_gang))
				temp = "[gang_name("B")] gang tag"
				gangID = "B"

			//Check area validity. Reject space, player-created areas, and non-station z-levels.
			if (gangID)
				territory = get_area(target)
				if(territory && (territory.z == 1) && territory.valid_territory)
					//Check if this area is already tagged by a gang
					if(!(locate(/obj/effect/decal/cleanable/crayon/gang) in target)) //Ignore the check if the tile being sprayed has a gang tag
						if(territory_claimed(territory, user))
							return
					/*
					//Prevent people spraying from outside of the territory (ie. Maint walls)
					var/area/user_area = get_area(user.loc)
					if(istype(user_area) && (user_area.type != territory.type))
						user << "<span class='warning'>You cannot tag [territory] from the outside.</span>"
						return
					*/
					if(locate(/obj/machinery/power/apc) in (user.loc.contents | target.contents))
						user << "<span class='warning'>You cannot tag here.</span>"
						return
				else
					user << "<span class='warning'>[territory] is unsuitable for tagging.</span>"
					return
		/////////////////////////////////////////


		user << "You start [instant ? "spraying" : "drawing"] a [temp] on the [target.name]."
		if(instant)
			playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		if((instant>0) || do_after(user, 50))

			//Gang functions
			if(gangID)
				//Delete any old markings on this tile, including other gang tags
				if(!(locate(/obj/effect/decal/cleanable/crayon/gang) in target)) //Ignore the check if the tile being sprayed has a gang tag
					if(territory_claimed(territory, user))
						return
				for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
					qdel(old_marking)
				new /obj/effect/decal/cleanable/crayon/gang(target,gangID,"graffiti")
				user << "<span class='notice'>You tagged [territory] for your gang!</span>"

			else
				new /obj/effect/decal/cleanable/crayon(target,colour,shadeColour,drawtype)

			user << "You finish [instant ? "spraying" : "drawing"] [temp]."
			if(instant<0)
				playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
			uses = max(0,uses-1)
			if(!uses)
				user << "<span class='warning'>There is no more of [src.name] left!</span>"
				if(!instant)
					qdel(src)
	return

/obj/item/toy/crayon/attack(mob/M as mob, mob/user as mob)
	if(edible && (M == user))
		user << "You take a bite of the [src.name]. Delicious!"
		user.nutrition += 5
		uses = max(0,uses-5)
		if(!uses)
			user << "<span class='warning'>There is no more of [src.name] left!</span>"
			qdel(src)
	else
		..()

/obj/item/toy/crayon/proc/territory_claimed(var/area/territory,mob/user)
	var/occupying_gang
	if(territory.type in (ticker.mode.A_territory | ticker.mode.A_territory_new))
		occupying_gang = gang_name("A")
	if(territory.type in (ticker.mode.B_territory | ticker.mode.B_territory_new))
		occupying_gang = gang_name("B")
	if(occupying_gang)
		user << "<span class='danger'>[territory] has already been tagged by the [occupying_gang] gang! You must get rid of or spray over the old tag first!</span>"
		return 1
	return 0


//Spraycan stuff

/obj/item/toy/crayon/spraycan
	icon_state = "spraycan_cap"
	desc = "A metallic container containing tasty paint."
	var/capped = 1
	instant = 1
	edible = 0
	validSurfaces = list(/turf/simulated/floor,/turf/simulated/wall)

/obj/item/toy/crayon/spraycan/New()
	..()
	name = "spray can"
	update_icon()

/obj/item/toy/crayon/spraycan/examine(mob/user)
	..()
	if(uses)
		user << "It has [uses] uses left."
	else
		user << "It is empty."

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user as mob)
	var/choice = input(user,"Spraycan options") as null|anything in list("Toggle Cap","Change Drawing","Change Color")
	switch(choice)
		if("Toggle Cap")
			user << "<span class='notice'>You [capped ? "Remove" : "Replace"] the cap of the [src]</span>"
			capped = capped ? 0 : 1
			icon_state = "spraycan[capped ? "_cap" : ""]"
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			colour = input(user,"Choose Color") as color
			update_icon()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user as mob, proximity)
	if(capped)
		return
	else
		if(iscarbon(target))
			if(uses)
				playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
				var/mob/living/carbon/human/C = target
				user.visible_message("<span class='danger'> [user] sprays [src] into the face of [target]!</span>")
				if(C.client)
					C.eye_blurry = max(C.eye_blurry, 3)
					C.eye_blind = max(C.eye_blind, 1)
					C.confused = max(C.confused, 3)
					C.Weaken(3)
				//C.lip_style = "spray_face"
				//C.lip_color = colour
				C.update_body()
				uses = max(0,uses-10)
		..()

/obj/item/toy/crayon/spraycan/update_icon()
	overlays.Cut()
	var/image/I = image('icons/obj/crayons.dmi',icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = colour
	overlays += I

/obj/item/toy/crayon/spraycan/gang
	desc = "A modified container containing suspicious paint."
	gang = 1
	uses = 20
	instant = -1
