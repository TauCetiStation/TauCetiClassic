//TRAIN STATION 13

//This module is all about doors.

//Like a dog without a bone, an actor out on loan, riders on the storm! - The DOORS

/obj/structure/mineral_door/wood/single
	name = "wooden door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wood"

/obj/structure/mineral_door/wood/double
	name = "wooden double door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wooddouble"

/obj/structure/mineral_door/wood/doubledirty
	name = "dirty wooden double door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wooddoubledirty"

/obj/structure/mineral_door/transparent/wood
	name = "wooden door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "woodglass"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/transparent/wooddouble
	name = "wooden double door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wooddoubleglass"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/transparent/metal
	name = "metal double door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "metaldoubleglass"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/metal

/obj/structure/mineral_door/transparent/automatic
	name = "automatic door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "locomotiveglass"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/turret/open.ogg'

/obj/structure/mineral_door/metal/automatic
	name = "automatic door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "locomotive"
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/turret/open.ogg'

/obj/structure/mineral_door/metal/reinforced
	name = "blast door"
	desc = "This door is as strong, as it looks."
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "blastdoor"
	max_integrity = 1000
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/turret/open.ogg'

//GATES

/obj/machinery/door/poddoor/gateleft
	name = "gate"
	icon = 'trainstation13/icons/gateleft.dmi'

/obj/machinery/door/poddoor/gateright
	name = "gate"
	icon = 'trainstation13/icons/gateright.dmi'