var/global/list/weighted_randomevent_locations = list()
var/global/list/weighted_mundaneevent_locations = list()

/datum/trade_destination
	var/name = ""
	var/description = ""
	var/distance = 0
	var/list/willing_to_buy = list()
	var/list/willing_to_sell = list()
	var/can_shuttle_here = 0		//one day crew from the exodus will be able to travel to this destination
	var/list/viable_random_events = list()
	var/list/temp_price_change[BIOMEDICAL]
	var/list/viable_mundane_events = list()

/datum/trade_destination/proc/get_custom_eventstring(event_type)
	return null

//distance is measured in AU and co-relates to travel time
/datum/trade_destination/centcomm
	name = "ЦентКом"
	description = "Административный центр NanoTrasen в системе Тау Кита."
	distance = 1.2
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, CORPORATE_ATTACK, AI_LIBERATION)
	viable_mundane_events = list(ELECTION, RESIGNATION, CELEBRITY_DEATH)

/datum/trade_destination/anansi
	name = "КСА Ананси"
	description = "Медицинская станция, управляемая организацией Второй Красный Крест (но принадлежащая NT), предназначенная для обработки экстренных случаев с ближайших колоний."
	distance = 1.7
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, CULT_CELL_REVEALED, BIOHAZARD_OUTBREAK, PIRATES, ALIEN_RAIDERS)
	viable_mundane_events = list(RESEARCH_BREAKTHROUGH, RESEARCH_BREAKTHROUGH, BARGAINS, GOSSIP)

/datum/trade_destination/anansi/get_custom_eventstring(event_type)
	if(event_type == RESEARCH_BREAKTHROUGH)
		return "Благодаря исследованиям, проведённым на КСА Ананси, Второй Красный Крест объявляет о крупном прорыве в области \
		[pick("интерфейсов мозг-машина","нейронауки","нано-аугментации","генетики")]. Ожидается, что NanoTrasen заключит соглашение о совместной эксплуатации в течение двух недель."
	return null

/datum/trade_destination/icarus
	name = "КМВ Икар"
	description = "Корвет, патрулирующий локальное пространство вокруг КСН Эксодус."
	distance = 0.1
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(SECURITY_BREACH, AI_LIBERATION, PIRATES)

/datum/trade_destination/redolant
	name = "ОАВ Редолант"
	description = "Атмосферная станция Osiris на орбите единственного газового гиганта в системе. Они жёстко контролируют права на перевозки, и корабли Osiris, защищающие их добычу, нередки в Тау Кита."
	distance = 0.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(INDUSTRIAL_ACCIDENT, PIRATES, CORPORATE_ATTACK)
	viable_mundane_events = list(RESEARCH_BREAKTHROUGH, RESEARCH_BREAKTHROUGH)

/datum/trade_destination/redolant/get_custom_eventstring(event_type)
	if(event_type == RESEARCH_BREAKTHROUGH)
		return "Благодаря исследованиям, проведённым на ОАВ Редолант, Osiris Atmospherics объявляет о крупном прорыве в области \
		[pick("исследования фазона","высокоэнергетической ёмкостной проводимости","сверхсжатых материалов","теоретической физики частиц")]. Ожидается, что NanoTrasen заключит соглашение о совместной эксплуатации в течение двух недель."
	return null

/datum/trade_destination/beltway
	name = "Шахтёрский пояс Белтвей"
	description = "Совместный проект Белтвей и NanoTrasen по добыче ресурсов из богатого внешнего астероидного пояса системы Тау Кита."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(PIRATES, INDUSTRIAL_ACCIDENT)
	viable_mundane_events = list(TOURISM)

/datum/trade_destination/biesel
	name = "Бизель"
	description = "Крупные верфи, сильная экономика и стабильное, образованное население. Бизель в основном сохраняет верность Солнцу / Vessel Contracting и с неохотой терпит NT. Столица — Лоуэлл Сити."
	distance = 2.3
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RIOTS, INDUSTRIAL_ACCIDENT, BIOHAZARD_OUTBREAK, CULT_CELL_REVEALED, FESTIVAL, MOURNING)
	viable_mundane_events = list(BARGAINS, GOSSIP, SONG_DEBUT, MOVIE_RELEASE, ELECTION, TOURISM, RESIGNATION, CELEBRITY_DEATH)

/datum/trade_destination/new_gibson
	name = "Нью-Гибсон"
	description = "Сильно индустриализированная каменистая планета, содержащая большую часть планетарных ресурсов системы. Нью-Гибсон раздирается беспорядками, и его богатство сосредоточено в руках корпораций, конкурирующих с NT."
	distance = 6.6
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(RIOTS, INDUSTRIAL_ACCIDENT, BIOHAZARD_OUTBREAK, CULT_CELL_REVEALED, FESTIVAL, MOURNING)
	viable_mundane_events = list(ELECTION, TOURISM, RESIGNATION)

/datum/trade_destination/luthien
	name = "Лютиэн"
	description = "Небольшая колония, основанная на диком, необузданном мире (в основном джунгли). На поселение регулярно нападают дикари и дикие звери, хотя NT поддерживает жёсткий военный контроль."
	distance = 8.9
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(WILD_ANIMAL_ATTACK, CULT_CELL_REVEALED, FESTIVAL, MOURNING, ANIMAL_RIGHTS_RAID, ALIEN_RAIDERS)
	viable_mundane_events = list(ELECTION, TOURISM, BIG_GAME_HUNTERS, RESIGNATION)

/datum/trade_destination/reade
	name = "Рийд"
	description = "Холодный мир с дефицитом металлов. NT содержит обширные пастбища на доступных территориях, пытаясь извлечь хоть какую-то прибыль из этой бесперспективной колонии."
	distance = 7.5
	willing_to_buy = list()
	willing_to_sell = list()
	viable_random_events = list(WILD_ANIMAL_ATTACK, CULT_CELL_REVEALED, FESTIVAL, MOURNING, ANIMAL_RIGHTS_RAID, ALIEN_RAIDERS)
	viable_mundane_events = list(ELECTION, TOURISM, BIG_GAME_HUNTERS, RESIGNATION)
