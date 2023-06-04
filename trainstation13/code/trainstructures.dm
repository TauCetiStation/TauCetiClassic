//TRAIN STATION 13

//MACHINES
//TRAIN MOVEMENT IS BASED ON CONVEYOR BELTS CODE

/obj/machinery/conveyor/train
	name = "ice"
	desc = "Layer of ice has formed on top of the snow. You see nothing out of the ordinary."
	icon = 'trainstation13/icons/trainstructures.dmi'


/obj/machinery/media/jukebox/trainjukebox
	name = "wall radio"
	desc = "A modern wall mounted radio with audio visualizer."
	icon = 'trainstation13/icons/trainstructures.dmi'
	density = 0
	playlist_id="train"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"mogesfm84"  = "Moghes FM-84",
		"moges" = "Moghes Club Music",
		"club" = "Club Mix",
		"customs" = "Customs Music",
		"japan" = "Banzai Radio",
		"govnar" = "Soviet Radio",
		"classic" = "Classical Music",
		"ussr_disco" = "Disco USSR-89s",
		"topreptilian" = "Top Reptillian",
		"zvukbanok" = "Sounds of beer cans",
		"eurobeat" = "Eurobeat",
		"finland" = "Suomi wave",
		"dreamsofvenus" = "Dreams of Venus",
		"hiphop" = "Hip-Hop for Space Gangstas",
		"vaporfunk" = "Qerrbalak VaporFunkFM",
		"thematic" = "Side-Bursting Tunes",
		"lofi" = "Sadness/Longing/Loneliness",
	)

/obj/machinery/space_heater/potbellystove
	name = "potbelly stove"
	desc = "This little stove will keep you warm and cozy during cold winter."
	anchored = TRUE
	density = TRUE
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "sheater-off"


//FURNITURE

/obj/structure/rack/traintable //Sort of a table limited to a single tile
	name = "table"
	desc = "A wedge shaped piece of metal standing on single metal leg. It can not move, but you can fold it." //Add table folding feature.
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "table" //Has 4 directions

/obj/structure/rack/trainshelf //Technically a rack, but really a wall shelf you can pass through because it's attached to a wall slightly above human height.
	name = "wall shelf"
	desc = "A sturdy cargo wall shelf attached to a wall with metal pipes."
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "shelf_metal" //Has 4 directions
	density = FALSE

/obj/structure/stool/bed/chair/wood/fancy //Why does vanilla wooden furniture look so terrible?
	name = "fancy wooden chair"
	desc = "Judging by its soft red velour seat, this chair is too expensive for you."
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "wooden_chair_fancy"

/obj/structure/stool/sofa //Technically a stool, until Tau Ceti gets sofas.
	name = "sofa"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "sofa"

/obj/structure/bedsheetbin/trainbedsheetbin
	name = "linen bin"
	desc = "A linen bin. Don't forget to turn in your bedsheet."
	icon = 'icons/obj/structures.dmi'
	amount = 5

//DOORS

/obj/structure/mineral_door/wood/single
	name = "wooden door"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "wood"

/obj/structure/mineral_door/wood/double
	name = "wooden double door"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "wooddouble"

/obj/structure/mineral_door/wood/doubledirty
	name = "dirty wooden double door"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "wooddoubledirty"

/obj/structure/mineral_door/transparent/wood
	name = "wooden door with doorlight"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "woodglass"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/transparent/wooddouble
	name = "wooden double door with doorlight"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "wooddoubleglass"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/transparent/metal
	name = "metal double door with doorlight"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "metaldoubleglass"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/metal