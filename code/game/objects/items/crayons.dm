/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Please refrain from eating it or putting it in your nose."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = ITEM_SIZE_TINY
	attack_verb = list("attacked", "coloured")
	var/colour = "#ff0000" // RGB
	var/shadeColour = "#220000" // RGB
	var/uses = 30 // 0 for unlimited uses
	var/instant = 0
	var/colourName = "red" // for updateIcon purposes
	var/list/validSurfaces = list(/turf/simulated/floor)
	var/gang = 0 // For marking territory
	var/edible = 1

/obj/item/toy/crayon/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'><b>[user] is jamming the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</b></span>")
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/attack(mob/living/carbon/M, mob/user)
	if(edible && (M == user))
		to_chat(user, "You take a bite of the [src.name]. Delicious!")
		user.nutrition += 5
		uses = max(0, uses - 5)
		if(!uses)
			to_chat(user, "<span class='warning'>There is no more of [src.name] left!</span>")
			qdel(src)
	else if(ishuman(M) && M.lying)
		to_chat(user, "You start outlining [M.name].")
		if(do_after(user, 40, target = M))
			to_chat(user, "You finish outlining [M.name].")
			new /obj/effect/decal/cleanable/crayon(M.loc, colour, shadeColour, "outline", "body outline")
			uses--
			if(!uses)
				to_chat(user, "<span class='warning'>You used up your [src.name]!</span>")
				qdel(src)
	else
		..()

/obj/item/toy/crayon/proc/territory_claimed(area/territory,mob/user)
	var/occupying_gang
	if(territory.type in (ticker.mode.A_territory | ticker.mode.A_territory_new))
		occupying_gang = gang_name("A")
	if(territory.type in (ticker.mode.B_territory | ticker.mode.B_territory_new))
		occupying_gang = gang_name("B")
	if(occupying_gang)
		to_chat(user, "<span class='danger'>[territory] has already been tagged by the [occupying_gang] gang! You must get rid of or spray over the old tag first!</span>")
		return TRUE
	return FALSE


/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(!uses)
		to_chat(user, "<span class='warning'>There is no more of [src.name] left!</span>")
		if(!instant)
			qdel(src)
		return
	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc
	if(is_type_in_list(target,validSurfaces))
		var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") in list("graffiti", "rune", "letter", "arrow", "cancel")
		switch(drawtype)
			if("cancel")
				return
			if("arrow")
				drawtype = input("Choose the letter.", "Crayon scribbles") in list("cancel", "left", "right", "up", "down")
				if(drawtype == "cancel")
					return
				to_chat(user, "<span class = 'notice'>You start [instant ? "spraying" : "drawing"] an arrow on the [target.name].</span>")
			if("letter")
				drawtype = input("Choose the letter.", "Crayon scribbles") in list("cancel", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
				if(drawtype == "cancel")
					return
				to_chat(user, "<span class = 'notice'>You start [instant ? "spraying" : "drawing"] a letter on the [target.name].</span>")
			if("graffiti")
				to_chat(user, "<span class = 'notice'>You start [instant ? "spraying" : "drawing"] graffiti on the [target.name].</span>")
			if("rune")
				to_chat(user, "<span class = 'notice'>You start [instant ? "spraying" : "drawing"] a rune on the [target.name].</span>")

		////////////////////////// GANG FUNCTIONS
		var/area/territory
		var/gangID
		if(gang)
			//Determine gang affiliation
			if(user.mind in (ticker.mode.A_bosses | ticker.mode.A_gang))
				gangID = "A"
			else if(user.mind in (ticker.mode.B_bosses | ticker.mode.B_gang))
				gangID = "B"

			//Check area validity. Reject space, player-created areas, and non-station z-levels.
			if (gangID)
				territory = get_area(target)
				if(territory && is_station_level(territory.z) && territory.valid_territory)
					//Check if this area is already tagged by a gang
					if(!(locate(/obj/effect/decal/cleanable/crayon/gang) in target)) //Ignore the check if the tile being sprayed has a gang tag
						if(territory_claimed(territory, user))
							return
					/*
					//Prevent people spraying from outside of the territory (ie. Maint walls)
					var/area/user_area = get_area(user.loc)
					if(istype(user_area) && (user_area.type != territory.type))
						to_chat(user, "<span class='warning'>You cannot tag [territory] from the outside.</span>")
						return
					*/
					if(locate(/obj/machinery/power/apc) in (user.loc.contents | target.contents))
						to_chat(user, "<span class='warning'>You cannot tag here.</span>")
						return
				else
					to_chat(user, "<span class='warning'>[territory] is unsuitable for tagging.</span>")
					return
		/////////////////////////////////////////

		if(!in_range(user, target))
			to_chat(user, "<span class = 'notice'>You must stay close to your drawing if you want to draw something.</span>")
			return
		if(instant)
			playsound(user, 'sound/effects/spray.ogg', VOL_EFFECTS_MASTER, 5)
		if(instant > 0 || (!user.is_busy(src) && do_after(user, 40, target = target)))

			//Gang functions
			if(gangID)
				//Delete any old markings on this tile, including other gang tags
				if(!(locate(/obj/effect/decal/cleanable/crayon/gang) in target)) //Ignore the check if the tile being sprayed has a gang tag
					if(territory_claimed(territory, user))
						return
				for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
					qdel(old_marking)
				new /obj/effect/decal/cleanable/crayon/gang(target,gangID,"graffiti")
				to_chat(user, "<span class='notice'>You tagged [territory] for your gang!</span>")

			else
				new /obj/effect/decal/cleanable/crayon(target,colour,shadeColour,drawtype)

			if(drawtype in list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"))
				to_chat(user, "<span class = 'notice'>You finish [instant ? "spraying" : "drawing"] a letter on the [target.name].</span>")
			else
				to_chat(user, "<span class = 'notice'>You finish [instant ? "spraying" : "drawing"] [drawtype] on the [target.name].</span>")
			if(instant<0)
				playsound(user, 'sound/effects/spray.ogg', VOL_EFFECTS_MASTER, 5)
			uses = max(0,uses-1)
			if(!uses)
				to_chat(user, "<span class='warning'>There is no more of [src.name] left!</span>")
				if(!instant)
					qdel(src)
	return

/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#da0000"
	shadeColour = "#810c0c"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#ff9300"
	shadeColour = "#a55403"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#fff200"
	shadeColour = "#886422"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#a8e61d"
	shadeColour = "#61840f"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00b7ef"
	shadeColour = "#0082a8"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#da00ff"
	shadeColour = "#810cff"
	colourName = "purple"

/obj/item/toy/crayon/chalk
	name = "white chalk"
	desc = "A piece of regular white chalk. What else did you expect to see?"
	icon_state = "chalk"
	colour = "#ffffff"
	shadeColour = "#cecece"
	colourName = "white"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#ffffff"
	shadeColour = "#000000"
	colourName = "mime"

/obj/item/toy/crayon/mime/attack_self(mob/living/user) //inversion
	if(colour != "#ffffff" && shadeColour != "#000000")
		colour = "#ffffff"
		shadeColour = "#000000"
		to_chat(user, "You will now draw in white and black with this crayon.")
	else
		colour = "#000000"
		shadeColour = "#ffffff"
		to_chat(user, "You will now draw in black and white with this crayon.")
	return

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#fff000"
	shadeColour = "#000fff"
	colourName = "rainbow"

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user)
	colour = input(user, "Please select the main colour.", "Crayon colour") as color
	shadeColour = input(user, "Please select the shade colour.", "Crayon colour") as color
	return

//Spraycan stuff

/obj/item/toy/crayon/spraycan
	icon_state = "spraycan_cap"
	desc = "A metallic container containing tasty paint."
	var/capped = 1
	instant = 1
	edible = 0
	validSurfaces = list(/turf/simulated/floor,/turf/simulated/wall)

/obj/item/toy/crayon/spraycan/atom_init()
	. = ..()
	name = "spray can"
	update_icon()

/obj/item/toy/crayon/spraycan/examine(mob/user)
	..()
	if(uses)
		to_chat(user, "It has [uses] uses left.")
	else
		to_chat(user, "It is empty.")

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user)
	var/choice = input(user,"Spraycan options") as null|anything in list("Toggle Cap","Change Drawing","Change Color")
	switch(choice)
		if("Toggle Cap")
			to_chat(user, "<span class='notice'>You [capped ? "Remove" : "Replace"] the cap of the [src]</span>")
			capped = capped ? 0 : 1
			icon_state = "spraycan[capped ? "_cap" : ""]"
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			colour = input(user,"Choose Color") as color
			update_icon()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return
	if(iscarbon(target) && uses - 10 > 0)
		uses -= 10
		var/mob/living/carbon/C = target
		user.visible_message("<span class='danger'> [user] sprays [src] into the face of [target]!</span>")
		if(C.client)
			C.eye_blurry = max(C.eye_blurry, 3)
			C.eye_blind = max(C.eye_blind, 1)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.lip_style = "spray_face"
			H.lip_color = colour
			H.update_body()
	else if(istype(target, /obj/machinery/nuclearbomb))
		var/obj/machinery/nuclearbomb/N = target
		var/choice = input(user, "Spraycan options") as null|anything in list("fish", "peace", "shark", "nuke", "nt", "heart", "woman", "smile")
		if(!choice)
			return
		uses -= 5
		N.overlays -= image('icons/effects/Nuke_sprays.dmi', N.spray_icon_state)
		N.overlays += image('icons/effects/Nuke_sprays.dmi', choice)
		N.spray_icon_state = choice
	if((istype(target, /obj/mecha) || isrobot(target)) && uses >= 10)
		target.color = normalize_color(colour)
		uses -= 10
	playsound(user, 'sound/effects/spray.ogg', VOL_EFFECTS_MASTER, 5)
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
