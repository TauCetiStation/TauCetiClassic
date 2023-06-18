#define IS_DREAMING 1
#define IS_NIGHTMARE 2
#define NOT_DREAMING 0

var/global/list/dreams = list(
	"идентификационная карта","бутылка","знакомое лицо","член экипажа","ящик с инструментами","офицер службы безопасности","капитан",
	"голоса со всех сторон","глубокий космос","доктор","двигатель","предатель","союзник","темнота",
	"свет","учёный","обезьяна","катастрофа","любимый человек","пушка","тепло","мороз","солнце",
	"шляпа","Луна","уничтоженная станция","планета","форон","воздух","медицинский отдел","мостик","мерцающие огни",
	"голубой свет","заброшенная лаборатория", "НаноТрейзен","Синдикат","кровь","лечение","сила","уважение",
	"богатства","космос","крушение","счастье","гордость","падение","вода","пламя","лёд","арбузы","полёт","куриные яйца","деньги",
	"глава персонала","глава службы безопасности","старший инженер","директор исследований","главврач",
	"детектив","смотритель","агент внутренних дел","инженер","уборщик","атмосферный техник",
	"завхоз","грузчик","ботаник","шахтёр","психолог","химик","генетик",
	"вирусолог","робототехник","повар","барбер","бармен","священник","библиотекарь","мышь","член ОБР",
	"пляж","голодек","прокуренная комната","голос","холод","мышь","операционный стол","бар","дождь","скрелл",
	"унатх","таяран","ядро ИИ","шахтерский аванпост","научный аванпост","склянка странной жидкости",
	)

var/global/list/nightmares = list(
	"Ктулху","культист","божество","ритуалы","кровь","кишки","смерть","ужас","бездна","проклятие","знак","тень","страх","огромный паук",
	"тьма","голоса отовсюду","катастрофа", "холод","руины","мерцающие огни","пламя","голос","пара алых глаз",
	"неизвестный","маньяк","убийца","ксенос","преступник","видения","оно","противогаз","взгляд","картина","мерзость","желтый знак","тени",
	"нежить","шёпот","суицид","существа","пещера","глаза","дитя","чума","голод","гниль","крысы","ведьма","крики","когти","клыки",
	"высота","нож","труп","вина","сингулярность","призрак"
	)

/mob/living/carbon/proc/dream()
	dreaming = IS_DREAMING
	if(reagents.has_reagent("unholywater"))
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(!(H.species && H.species.flags[NO_BLOOD]))
				dreaming = IS_NIGHTMARE
		else
			dreaming = IS_NIGHTMARE
	for(var/obj/item/candle/ghost/CG in range(4, src))
		if(CG.lit)
			dreaming = IS_NIGHTMARE
			break

	dream_sequence(rand(1,4))

	return TRUE

/mob/living/carbon/proc/dream_sequence(segments)
	if(stat != UNCONSCIOUS)
		dreaming = NOT_DREAMING
		return

	if(dreaming == IS_NIGHTMARE)
		to_chat(src, "<span class='warning italic'>... [pick(nightmares)] ...</span>")
		adjustHalLoss(4) // Nightmares are quite agonizing. Since just sleeping remove 3 HalLoss, adding 4 here would in total give just 1 haldamage/life tick.
		if(prob(10))
			playsound_local(null, pick(SOUNDIN_HORROR), VOL_EFFECTS_MASTER, 40, FALSE)
	else
		to_chat(src, "<span class='notice italic'>... [pick(dreams)] ...</span>")

	if(segments)
		addtimer(CALLBACK(src, PROC_REF(dream_sequence), segments), rand(10,30))
	else
		dreaming = NOT_DREAMING

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(50))
		dream()

/mob/living/carbon/var/dreaming = NOT_DREAMING

#undef IS_DREAMING
#undef IS_NIGHTMARE
#undef NOT_DREAMING
