
///-----------------------------------------------------//
///														//
///						Sweets							//
///			Food items inside candy type				//
///														//
///-----------------------------------------------------//

//Candy as snack type
/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	icon = 'icons/obj/food_and_drinks/sweets.dmi'
	filling_color = "#7D5F46"
	bitesize = 2
	list_reagents = list("nutriment" = 1, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/candy/donor/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge
	name = "Fudge"
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7D5F46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/atom_init()
	. = ..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("nutriment",2)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry
	name = "Chocolate Cherry Fudge"
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"
	filling_color = "#7D5F46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry/atom_init()
	. = ..()
	reagents.add_reagent("cream", 3)
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "Cookies 'n' Cream Fudge"
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7D5F46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream/atom_init()
	. = ..()
	reagents.add_reagent("cream", 5)
	reagents.add_reagent("nutriment", 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle
	name = "Turtle Fudge"
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"
	filling_color = "#7D5F46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle/atom_init()
	. = ..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee
	name = "Toffee"
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7D5F46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel
	name = "Caramel"
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#DB944D"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel/atom_init()
	. = ..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#F2F2F2"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy
	name = "Saltwater Taffy"
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7D5F46"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy/atom_init()
	. = ..()
	icon_state = pick("candy1", "candy2", "candy3", "candy4", "candy5")
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat
	name = "Nougat"
	desc = "A soft, chewy candy commonly found in candybars."
	icon_state = "nougat"
	filling_color = "#7D5F46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)

///////////////////////////////////////////
// COTTONS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_plain"
	filling_color = "#FFFFFF"
	trash = /obj/item/weapon/c_tube
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 15)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_red"
	filling_color = "#801E28"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_green"
	filling_color = "#365E30"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_yellow"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_orange"
	filling_color = "#E78108"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_purple"
	filling_color = "#993399"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_pink"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink/atom_init()
	. = ..()
	reagents.add_reagent("watermelonjuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	filling_color = "#C8A5DC"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("psilocybin", 1)

///////////////////////////////////////////
// GUM and SUCKERS :D :>
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear
	name = "gummy bear"
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	filling_color = "#FFFFFF"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	filling_color = "#FFFFFF"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas."
	icon_state = "jbean"
	filling_color = "#FFFFFF"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ED0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/cash/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("hot_coco", 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/coin/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("hot_coco",4)

/obj/item/weapon/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	desc = "Chewy!"
	icon_state = "bubblegum"
	filling_color = "#FF7495"
	bitesize = 0.2

/obj/item/weapon/reagent_containers/food/snacks/candy/gum/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	desc = "For being such a good sport!"
	icon_state = "sucker"
	filling_color = "#FFFFFF"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

///////////////////////////////////////////
// BEAR GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red
	name = "gummy bear"
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801E28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365E30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#E78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	desc = "A small bear. Wait... what?"
	icon_state = "gbear_wtf"
	filling_color = "#60A584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// WORM GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801E28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365E30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#E78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60A584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// JELLY BEANS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801E28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365E30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#E78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate/atom_init()
	. = ..()
	reagents.add_reagent("hot_coco",2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola/atom_init()
	. = ..()
	reagents.add_reagent("cola", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb/atom_init()
	. = ..()
	reagents.add_reagent("dr_gibb", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee/atom_init()
	. = ..()
	reagents.add_reagent("coffee", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. You aren't sure what color it is."
	icon_state = "jbean_wtf"
	filling_color = "#60A584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// CANDYBARS! :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar
	name = "candy bar"
	desc = "Nougat, love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/rice
	name = "Asteroid Crunch Bar"
	desc = "Crunchy rice deposits in delicious chocolate! A favorite of miners galaxy-wide."
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/yumbaton
	name = "Yum-baton Bar"
	desc = "Chocolate and toffee in the shape of a baton. Security sure knows how to pound these down!"
	icon_state = "yumbaton"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/malper
	name = "Malper Bar"
	desc = "A chocolate syringe filled with a caramel injection. Just what the doctor ordered!"
	icon_state = "malper"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel_nougat
	name = "Toxins Test Bar"
	desc = "An explosive combination of chocolate, caramel, and nougat. Research has never been so tasty!"
	icon_state = "toxinstest"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/toolerone
	name = "Tool-erone Bar"
	desc = "Chocolate-covered nougat, shaped like a wrench. Great for an engineer on the go!"
	icon_state = "toolerone"
	filling_color = "#7D5F46"

///////////////////////////////////////////
// SUCKERS! :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/red
	name = "sucker"
	desc = "For being such a good sport! It's red!"
	icon_state = "sucker_red"
	filling_color = "#801E28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/blue
	name = "sucker"
	desc = "For being such a good sport! It's blue!"
	icon_state = "sucker_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/green
	name = "sucker"
	desc = "For being such a good sport! It's green!"
	icon_state = "sucker_green"
	filling_color = "#365E30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/yellow
	name = "sucker"
	desc = "For being such a good sport! It's yellow!"
	icon_state = "sucker_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/orange
	name = "sucker"
	desc = "For being such a good sport! It's orange!"
	icon_state = "sucker_orange"
	filling_color = "#E78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/purple
	name = "sucker"
	desc = "For being such a good sport! It's purple!"
	icon_state = "sucker_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

///////////////////////////////////////////
// WORM GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801E28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365E30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#E78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60A584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)
