// autotators are just tators ffs! //No, it spawns a faction that has midround recruit enabled ye grot
/datum/game_mode/autotraitor
	name = "Autotraitor"
	factions_allowed=  list(/datum/faction/syndicate/traitor/auto)

/datum/game_mode/autotraitor/announce()
	..()
	to_chat(world, "<B>Game mode is AutoTraitor. Traitors will be added to the round automagically as needed.</B>")
