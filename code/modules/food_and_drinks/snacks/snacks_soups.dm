
///-----------------------------------------------------//
///														//
///						Soups							//
///		Food items made by cooking in pots				//
///														//
///-----------------------------------------------------//

//Soup as snack type
/obj/item/weapon/reagent_containers/food/snacks/soup
	name = "Just a template"
	icon = 'icons/obj/food_and_drinks/soups_salads.dmi'
	trash = /obj/item/weapon/kitchen/dirty_bowl
	filling_color = "#D1F4FF"
	w_class = 3
	bitesize = 5
	cant_be_put_on_plate = 1

/obj/item/weapon/reagent_containers/food/snacks/soup/atom_init()
	.=..()
	eatverb = pick("slurp","sip","suck","inhale")

//////////////////
//LIST OF SOUPS//
//////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/gazpacho
	name = "gazpacho"
	desc = "A cool, refreshing soup originating in Space Spain's desert homeworld."
	icon_state = "gazpacho"
	bitesize = 4
	filling_color = "#FF0000"
	list_reagents = list("nutriment" = 8, "tomatojuice" = 6)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	filling_color = "#785210"
	list_reagents = list("protein" = 8, "water" = 5, "vitamin" = 4)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#C4DBA0"
	list_reagents = list("protein" = 4, "water" = 10, "vitamin" = 4, "slimejelly" = 5)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	list_reagents = list("protein" = 2, "water" = 5, "vitamin" = 4, "blood" = 10)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	list_reagents = list("nutriment" = 4, "water" = 10, "vitamin" = 8, "banana" = 5)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal."
	icon_state = "vegetablesoup"
	filling_color = "#AFC4B5"
	list_reagents = list("plantmatter" = 8, "water" = 5, "vitamin" = 4)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	filling_color = "#AFC4B5"
	list_reagents = list("plantmatter" = 8, "water" = 5, "vitamin" = 4, "tricordrazine" = 5)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	filling_color = "#F082FF"

/obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup/atom_init()
	. = ..()
	var/mysteryselect = pick(1,2,3,4,5,6,7,8,9,10)
	switch(mysteryselect)
		if(1)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("capsaicin", 3)
			reagents.add_reagent("tomatojuice", 2)
		if(2)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("frostoil", 3)
			reagents.add_reagent("tomatojuice", 2)
		if(3)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("water", 5)
			reagents.add_reagent("tricordrazine", 5)
		if(4)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("water", 10)
		if(5)
			reagents.add_reagent("nutriment", 2)
			reagents.add_reagent("banana", 10)
		if(6)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("blood", 10)
		if(7)
			reagents.add_reagent("slimejelly", 10)
			reagents.add_reagent("water", 10)
		if(8)
			reagents.add_reagent("carbon", 10)
			reagents.add_reagent("toxin", 10)
		if(9)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("tomatojuice", 10)
		if(10)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("tomatojuice", 5)
			reagents.add_reagent("imidazoline", 5)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup
	name = "Wish Soup"
	desc = "I wish this was a soup."
	icon_state = "wishsoup"
	filling_color = "#D1F4FF"

/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup/atom_init()
	. = ..()
	reagents.add_reagent("water", 10)
	if(prob(20))
		src.desc = "A wish come true!"
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("vitamin", 10)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	filling_color = "#FF3C00"
	list_reagents = list("plantmatter" = 6, "capsaicin" = 3, "vitamin" = 2, "tomatojuice" = 2)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	bitesize = 5
	list_reagents = list("plantmatter" = 6, "frostoil" = 3, "vitamin" = 2, "tomatojuice" = 2)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	filling_color = "#D92929"
	list_reagents = list("plantmatter" = 5, "water" = 2, "vitamin" = 3, "tomatojuice" = 10)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 2)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	filling_color = "#E386BF"
	list_reagents = list("plantmatter" = 8, "water" = 2, "vitamin" = 4)
	bitesize = 4

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	filling_color = "#FAC9FF"
	list_reagents = list("nutriment" = 10, "water" = 2, "vitamin" = 10)
	bitesize = 8

/obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup/atom_init()
	. = ..()
	switch(rand(1,6))//Fuckeng stupied Amereckans
		if(1)
			name = "borsch"
		if(2)
			name = "bortsch"
		if(3)
			name = "borstch"
		if(4)
			name = "borsh"
		if(5)
			name = "borshch"
		if(6)
			name = "borscht"

/obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup/On_Consume()
	if(prob(30))
		to_chat(usr, "<span class='rose'>Вы чувствуете вкус родины!</span>")
	..()

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/soup/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	filling_color = "#F0F2E4"
	list_reagents = list("nutriment" = 5)
	bitesize = 1

///////////////////////////////////////////////
