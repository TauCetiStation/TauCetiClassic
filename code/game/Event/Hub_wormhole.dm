/obj/effect/portal/hub
	name = "В Хаб"
	var/area/A =/area/custom/hub
	var/list/turf/possible_tile
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_enter"
	failchance = 0

/obj/effect/portal/hub/atom_init()
	possible_tile = get_area_turfs(get_area_by_type(A))
	target = pick(possible_tile)

/obj/effect/portal/hub/human
	A =/area/custom/human_hub
	name = "Фракция Замок"
	desc = "Королевство людей.Официальное название - Эрафия.Многоразовые профессии - Крестьянин, Шахтер, Помощник в Монастыре. Заранее отобранные игроки владеют такими профессиями как: Герой, Монахи, Рыцари, Торгаш."

/obj/effect/portal/hub/wizard
	A =/area/custom/wizard_hub
	name = "Фракция Башня"
	desc = "Королевство колдунов и чародеек.Официальное название - Бракада.Многоразовые профессии - Житель, Гремлин, Помощник Чародея. Заранее отобранные игроки владеют такими профессиями как: Герой, Гремлин-прораб, Чародей, Торгаш."

/obj/effect/portal/hub/krigan
	A =/area/custom/krigan_hub
	name = "Фракция Инферно"
	desc = "Инопланетные захватчики, которые необразованные селюки и паладины кличут - Демоны. Официальное название - Инферно. Многоразовые професии - Еретик, Бес, Пророк. Заранее отобранные игроки владеют такими профессиями как: Герой, Погонщик Бесов, Вестник Огня, Магог."

/obj/effect/portal/hub/peasant
	A = /area/custom/peasant_hub
	name = "Крестьянин"
	desc = ""

/obj/effect/portal/hub/miner
	A = /area/custom/miner_hub
	name = "Шахтер"
	desc = ""

/obj/effect/portal/hub/helper
	A = /area/custom/helper_hub
	name = "Помощник в Монастыре"
	desc = ""