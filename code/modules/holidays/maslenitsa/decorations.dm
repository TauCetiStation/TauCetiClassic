// Tinsels
/obj/item/taperoll/tinsel/maslenitsa
	name = "maslenitsa tinsel"
	cases = list("моток масленичной гирлянды", "мотка масленичной гирлянды", "мотку масленичной гирлянды", "моток масленичной гирлянды", "мотком масленичной гирлянды", "мотке масленичной гирлянды")
	desc = "Ярмарка в самом разгаре!"
	icon = 'icons/holidays/maslenitsa/decorations.dmi'
	tape_type = /obj/effect/ebeam/tinsel/maslenitsa

/obj/effect/ebeam/tinsel/maslenitsa
	name = "maslenitsa tinsel"
	icon_state = "tinsel"
	cases = list("масленичная гирлянда", "масленичной гирлянды", "масленичной гирлянде", "масленичную гирлянду", "масленичной гирляндой", "масленичной гирлянде")

	taperoll = /obj/item/taperoll/tinsel/maslenitsa
	decoration_icon = 'icons/holidays/maslenitsa/tinsel.dmi'
	decoration_follow = TRUE

/obj/effect/spawner/tape/tinsel/maslenitsa
	name = "maslenitsa tinsel spawner"
	icon = 'icons/holidays/maslenitsa/decorations.dmi'
	tape_type = /obj/effect/ebeam/tinsel/maslenitsa
