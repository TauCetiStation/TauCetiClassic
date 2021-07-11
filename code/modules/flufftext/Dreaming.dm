#define IS_DREAMING 1
#define IS_NIGHTMARE 2
#define NOT_DREAMING 0

var/global/list/dreams = list(
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

var/global/list/nightmares = list(
	"c'thulhu","a cultist","a deity","rituals","blood","gibs","death","horror","abyss","damnation","a sign","a shadow","fear","the giant spider",
	"darkness","voices from all around","a catastrpohe","freezing","ruins","blinking lights","flames","a voice","a pair of red eyes",
	"the unknown","a murderer","a killer","a xeno","a criminal","visions","it","a gasmask","look","a painting","an abomination","an yellow sign","shadows",
	"the undead","whispers","suicide","creatures","cave","eyes","a child","plague","hunger","rot","rats","a witch","screams","claws","fangs",
	"height","knife","a corpse","guilt","singularity","a ghost"
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
	if(stat != UNCONSCIOUS || paralysis <= 0)
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
		addtimer(CALLBACK(src, .proc/dream_sequence, segments), rand(10,30))
	else
		dreaming = NOT_DREAMING

/mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(10))
		dream()

/mob/living/carbon/var/dreaming = NOT_DREAMING

#undef IS_DREAMING
#undef IS_NIGHTMARE
#undef NOT_DREAMING
