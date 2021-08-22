/datum/game_mode/casual_shift
	name = "Casual Shift"
	config_name = "extended"
	probability = 40
	minimum_player_count = 0

/datum/game_mode/casual_shift/announce()
	to_chat(world, "<B>The current game mode is - Casual Shift!</B>")
	to_chat(world, "<B>Типичная смена которая идёт своим чередом. Но не стоит увязать только в рутине своей работы. \
	Чтобы было интереснее и вам и другим, пусть ваш персонаж чего-нибудь желает, боится, помимо злого начальника. \
	Выберите себе цель по душе и стремитесь к ней. Стройте планы и обязательно заманивайте в них других персонажей.\n\
	Так рождаются истории.</B>")

/datum/game_mode/casual_shift/Setup()
	return TRUE
