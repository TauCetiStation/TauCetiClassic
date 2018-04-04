#define IS_DREAMING 1
#define IS_NIGHTMARE 2
#define NOT_DREAMING 0

var/list/dreams = list(
	"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
	"voices from all around","deep space","a doctor","the engine","a traitor","an ally","darkness",
	"light","a scientist","a monkey","a catastrophe","a loved one","a gun","warmth","freezing","the sun",
	"a hat","the Luna","a ruined station","a planet","phoron","air","the medical bay","the bridge","blinking lights",
	"a blue light","an abandoned laboratory","Nanotrasen","The Syndicate","blood","healing","power","respect",
	"riches","space","a crash","happiness","pride","a fall","water","flames","ice","melons","flying","the eggs","money",
	"the head of personnel","the head of security","a chief engineer","a research director","a chief medical officer",
	"the detective","the warden","a member of the internal affairs","a station engineer","the janitor","atmospheric technician",
	"the quartermaster","a cargo technician","the botanist","a shaft miner","the psychologist","the chemist","the geneticist",
	"the virologist","the roboticist","the chef","the barber","the bartender","the chaplain","the librarian","a mouse","an ert member",
	"a beach","the holodeck","a smokey room","a voice","the cold","a mouse","an operating table","the bar","the rain","a skrell",
	"a unathi","a tajaran","the ai core","the mining station","the research station","a beaker of strange liquid",
	)

var/list/nightmares = list(
	"c'thulhu","a cultist","a deity","rituals","blood","gibs","death","horror","abyss","damnation","a sign","a shadow","fear","the giant spider",
	"darkness","voices from all around","a catastrpohe","freezing","ruins","blinking lights","flames","a voice","a pair of red eyes",
	"the unknown","a murderer","a killer","a xeno","a criminal","visions","it","a gasmask","look","a painting","an abomination","an yellow sign","shadows",
	"the undead","whispers","suicide","creatures","cave","eyes","a child","plague","hunger","rot","rats","a witch","screams","claws","fangs",
	"height","knife","a corpse","guilt","singularity","a ghost"
	)

/mob/living/carbon/proc/dream()
	dreaming = IS_DREAMING
	for(var/obj/item/candle/ghost/CG in range(4, src))
		dreaming = IS_NIGHTMARE
	var/i = rand(1,4)
	while(i)
		if(dreaming == 2)
			to_chat(src, "<span class='warning italics'>... [pick(nightmares)] ...</span>")
		else
			to_chat(src, "<span class='notice italics'>... [pick(dreams)] ...</span>")
		sleep(rand(40,70))
		if(paralysis <= 0)
			dreaming = NOT_DREAMING
			return FALSE
		i--
	dreaming = 0
	return TRUE

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()

/mob/living/carbon/var/dreaming = NOT_DREAMING
