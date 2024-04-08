/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

	beauty = -50

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = TRUE

	beauty = -50

/obj/effect/decal/cleanable/ash/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>[src] sifts through your fingers.</span>")
	user.SetNextMove(CLICK_CD_RAPID)
	var/turf/simulated/floor/F = get_turf(src)
	if (istype(F))
		F.dirt += 4
	qdel(src)

/obj/effect/decal/cleanable/ash/large
	name = "large pile of ashes"
	icon_state = "big_ash"
	beauty = -100

/obj/effect/decal/cleanable/greenglow

/obj/effect/decal/cleanable/greenglow/atom_init()
	. = ..()
	QDEL_IN(src, 1200)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	beauty = -50

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

	beauty = -25

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	light_range = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

	beauty = -100

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = FALSE
	anchored = TRUE
	plane = GAME_PLANE
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

	beauty = -25

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = FALSE
	anchored = TRUE
	layer = 3
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"

	beauty = -300

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = FALSE
	anchored = TRUE
	plane = GAME_PLANE
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

	beauty = -25

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")

	beauty = -250

/obj/effect/decal/cleanable/vomit/Destroy()
	set_light(0)
	return ..()

/obj/effect/decal/cleanable/vomit/proc/stop_light()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), rand(150, 300))

/obj/effect/decal/cleanable/shreds
	name = "shreds"
	desc = "The shredded remains of what appears to be clothing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shreds"

/obj/effect/decal/cleanable/shreds/atom_init(mapload, oldname)
	. = ..()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	if(!isnull(oldname))
		desc = "The sad remains of what used to be [oldname]"

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

	beauty = -100

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

	beauty = -100

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

	beauty = -100

/obj/effect/decal/cleanable/toilet_paint
	name = "lettering"
	desc = "A lettering."
	layer = 2.1
	anchored = TRUE

	beauty = -100

var/global/list/toilet_overlay_cache = list()

/obj/effect/decal/cleanable/toilet_paint/atom_init(mapload, main = random_color(), shade = random_color())
	. = ..()

	var/type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")

	var/icon/mainOverlay = toilet_overlay_cache["[type]"]
	var/icon/shadeOverlay = toilet_overlay_cache["[type]s"]

	if(!mainOverlay)
		mainOverlay = toilet_overlay_cache["[type]"] = new/icon('icons/effects/crayondecal.dmi',"[type]", 2.1)
	if(!shadeOverlay)
		shadeOverlay = toilet_overlay_cache["[type]s"] = new/icon('icons/effects/crayondecal.dmi',"[type]s", 2.1)
		shadeOverlay.Blend(shade, ICON_ADD)

	add_overlay(mainOverlay)
	add_overlay(shadeOverlay)

/obj/effect/decal/cleanable/gourd
	name = "swampy grease"
	desc = "Мерзкая гадость. Кому придёт в голову пихать в себя ЭТО?"
	anchored = TRUE
	density = FALSE

	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")

	color = "#95ba43"

	beauty = -200

/obj/effect/decal/cleanable/gourd/atom_init()
	..()
	AddComponent(/datum/component/slippery, 2, NO_SLIP_WHEN_WALKING, CALLBACK(src, PROC_REF(try_faceplant_react)))
	return INITIALIZE_HINT_LATELOAD

/obj/effect/decal/cleanable/gourd/atom_init_late()
	// Only one gourd puddle per tile.
	for(var/obj/effect/decal/cleanable/gourd/G in loc)
		if(G != src && G.type == type)
			qdel(G)

/obj/effect/decal/cleanable/gourd/proc/try_faceplant_react(atom/movable/AM)
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(L.get_species() == UNATHI)
		return
	L.vomit()
