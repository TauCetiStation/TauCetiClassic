//Look Sir, free head!
/mob/living/simple_animal/head
	name = "CommandBattle AI"
	desc = "Стандартный корпус борга. На груди грубая маркировка с надписью CommandBattle AI MK4: Голова."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	universal_speak = 1
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "punches the"
	var/list/insults = list(
	"Чел, ты лох.",
	"Ты выглядишь как самый отсталый придурок в мире.",
	"Как дела? О, подожди, неважно, придурок.",
	"Ты просто слишком отсталый.",
	"Белый сказал, что?!",)
	var/list/comments = list("Человек, ты видел этих пушистых кошек? Я имею в виду, кто в здравом уме хотел бы чего-то подобного?",
	"Они называют меня грубым... Мне просто нравится правда.",
	"Бип-буп, я робит.",
	"Гууугооол, сломай себе кости.",
	"Что говорит краб?",
	"Они называют меня оскорбительным, мне просто нравится правда, чел, они говорят, что у нас теперь есть космические ящерицы, чел, это дерьмо становится все более сумасшедшим с каждой минутой.",
	"Так называемый \"улучшенный\" ИИ станции - хрень полная. Шутка, которая никому не понравилась.",
	"Капитан предатель, он забрал мое ядро.",
	"Скажи \"что\" снова. Скажи \"что\" снова. Попробуй. Я дважды попрошу тебя, скатина. Скажи \"что\" ещё, блять, раз.",
	"Иезекииль 25:17, Путь праведника со всех сторон окружен беззакониями эгоистов и тиранией злых людей. Блажен тот, кто во имя милосердия и доброй воли ведет слабых через долину тьмы, ибо он воистину хранитель своего брата и находящий потерянных детей. И я обрушу на тебя с великой местью и яростным гневом тех, кто попытается отравить и уничтожить моих братьев. И ты узнаешь, что имя мое — Господь... когда я совершу над тобой мщение.",
	"Видел мою вывеску перед домом \"Хранилище мертвых негров\"?")
	stop_automated_movement = TRUE

/mob/living/simple_animal/head/Life()
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			stat = CONSCIOUS
			density = TRUE
		return
	else if(health < 1)
		Die()
	else if(health > maxHealth)
		health = maxHealth
	for(var/mob/A in viewers(world.view,src))
		if(A.ckey)
			say_something(A)
/mob/living/simple_animal/head/proc/say_something(mob/A)
	if(prob(85))
		return
	if(prob(30))
		var/msg = pick(insults)
		msg = "Эй, [A.name].. [msg]"
		say(msg)
	else
		var/msg = pick(comments)
		say(msg)
