// Tinsels
/obj/item/taperoll/tinsel/chinese
	name = "chinese tinsel"
	cases = list("моток китайской гирлянды", "мотка китайской гирлянды", "мотку китайской гирлянды", "моток китайской гирлянды", "мотком китайской гирлянды", "мотке китайской гирлянды")
	desc = "Покричим, порычим! В королевстве Хеллоуин!"
	icon = 'icons/holidays/chinese_new_year/decorations.dmi'
	tape_type = /obj/effect/ebeam/tinsel/chinese

/obj/effect/ebeam/tinsel/chinese
	name = "chinese tinsel"
	icon = 'icons/holidays/chinese_new_year/decorations.dmi'
	icon_state = "tinsel"
	cases = list("китайская гирлянда", "китайской гирлянды", "китайской гирлянде", "китайскую гирлянду", "китайской гирляндой", "китайской гирлянде")

	taperoll = /obj/item/taperoll/tinsel/chinese
	decoration_icon = 'icons/holidays/chinese_new_year/tinsel.dmi'

/obj/effect/spawner/tape/tinsel/chinese
	name = "chinese tinsel spawner"
	icon = 'icons/holidays/chinese_new_year/decorations.dmi'
	tape_type = /obj/effect/ebeam/tinsel/chinese

/obj/item/decoration/chinese_roundel
	name = "roundel"
	desc = "Roundel."
	icon = 'icons/holidays/chinese_new_year/decorations.dmi'
	icon_state = "roundel"
