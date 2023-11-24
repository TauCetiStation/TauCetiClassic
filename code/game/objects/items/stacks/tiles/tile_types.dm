/* Diffrent misc types of tiles
 * Contains:
 *		Grass
 *		Wood
 *		Carpet
 */

/obj/item/stack/tile
	var/turf/turf_type
	icon_state = "tile"
	lefthand_file = 'icons/mob/inhands/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/tiles_righthand.dmi'

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tile"
	cases = list("травяного покрытия", "травяному покрытию", "травяное покрытие", "травяным покрытием", "травяном покрытии")
	singular_name = "grass floor tile"
	desc = "Травяное покрытие, используемое для игр в гольф."
	icon_state = "tile_grass"
	w_class = SIZE_SMALL
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 20
	flags = CONDUCT
	max_amount = 60
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/grass

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wood floor tile"
	cases = list("деревянного пола", "деревянному полу", "деревянный пол", "деревянным полом", "деревянном поле")
	singular_name = "wood floor tile"
	desc = "Простая в укладке деревянная напольная плитка."
	icon_state = "tile-wood"
	w_class = SIZE_SMALL
	force = 1.0
	throwforce = 1.0
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/wood

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "carpet"
	cases = list("ковра", "ковру", "ковёр", "ковром", "ковре")
	singular_name = "carpet"
	desc = "Часть ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	w_class = SIZE_SMALL
	force = 1.0
	throwforce = 1.0
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/carpet
	var/carpet_icon_state = "carpet"

/obj/item/stack/tile/carpet/black
	name = "black carpet"
	singular_name = "black carpet"
	desc = "Часть чёрного ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-black"
	turf_type = /turf/simulated/floor/carpet/black
	carpet_icon_state = "blackcarpet"

/obj/item/stack/tile/carpet/purple
	name = "purple carpet"
	singular_name = "purple carpet"
	desc = "Часть фиолетового ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-purple"
	turf_type = /turf/simulated/floor/carpet/purple
	carpet_icon_state = "purplecarpet"

/obj/item/stack/tile/carpet/orange
	name = "orange carpet"
	singular_name = "orange carpet"
	desc = "Часть оранжевого ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-orange"
	turf_type = /turf/simulated/floor/carpet/orange
	carpet_icon_state = "orangecarpet"

/obj/item/stack/tile/carpet/green
	name = "green carpet"
	singular_name = "green carpet"
	desc = "Часть зелёного ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-green"
	turf_type = /turf/simulated/floor/carpet/green
	carpet_icon_state = "greencarpet"

/obj/item/stack/tile/carpet/blue
	name = "blue carpet"
	singular_name = "blue carpet"
	desc = "Часть синего ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-blue"
	turf_type = /turf/simulated/floor/carpet/blue
	carpet_icon_state = "bluecarpet"

/obj/item/stack/tile/carpet/blue2
	name = "blue carpet"
	singular_name = "blue carpet"
	desc = "Часть голубого ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-blue2"
	turf_type = /turf/simulated/floor/carpet/blue2
	carpet_icon_state = "blue2carpet"

/obj/item/stack/tile/carpet/red
	name = "red carpet"
	singular_name = "red carpet"
	desc = "Часть красного ковра, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-red"
	turf_type = /turf/simulated/floor/carpet/red
	carpet_icon_state = "redcarpet"

/obj/item/stack/tile/carpet/cyan
	name = "cyan carpet"
	singular_name = "cyan carpet"
	desc = "Часть ковра цвета морской волны, соразмерная плитке."
	icon_state = "tile-carpet"
	item_state = "tile-carpet-cyan"
	turf_type = /turf/simulated/floor/carpet/cyan
	carpet_icon_state = "cyancarpet"
