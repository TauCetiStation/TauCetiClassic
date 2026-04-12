// for humans, other species use rgb

var/global/list/skin_tones_by_name
var/global/list/skin_tones_by_ru_name
var/global/list/datum/skin_tone/skin_tones

/datum/skin_tone
	var/name
	var/hex

// sorted from light to dark

// albino used as default
/datum/skin_tone/albino
	name = "albino"
	cases = list("альбинос", "альбиноса", "альбиносу", "альбиноса", "альбиносом", "альбиносе")
	hex = "#fff4e6"

/datum/skin_tone/porcelain
	name = "porcelain"
	cases = list("фарфоровый", "фарфорового", "фарфоровому", "фарфоровый", "фарфоровым", "фарфоровом")
	hex = "#ffe0d1"

/datum/skin_tone/ivory
	name = "ivory"
	cases = list("слоновая кость", "слоновой кости", "слоновой кости", "слоновую кость", "слоновой костью", "слоновой кости")
	hex = "#ffdeb3"

/datum/skin_tone/light_peach
	name = "light peach"
	cases = list("светло-персиковый", "светло-персикового", "светло-персиковому", "светло-персиковый", "светло-персиковым", "светло-персиковом")
	hex = "#fcccb3"

/datum/skin_tone/beige
	name = "beige"
	cases = list("бежевый", "бежевого", "бежевому", "бежевый", "бежевым", "бежевом")
	hex = "#e3ba84"

/datum/skin_tone/light_brown
	name = "light brown"
	cases = list("светло-коричневый", "светло-коричневого", "светло-коричневому", "светло-коричневый", "светло-коричневым", "светло-коричневом")
	hex = "#c4915e"

/datum/skin_tone/peach
	name = "peach"
	cases = list("персиковый", "персикового", "персиковому", "персиковый", "персиковым", "персиковом")
	hex = "#e8b59b"

/datum/skin_tone/light_beige
	name = "light beige"
	cases = list("светло-бежевый", "светло-бежевого", "светло-бежевому", "светло-бежевый", "светло-бежевым", "светло-бежевом")
	hex = "#d9ae96"

/datum/skin_tone/olive
	name = "olive"
	cases = list("оливковый", "оливкового", "оливковому", "оливковый", "оливковым", "оливковом")
	hex = "#c79b8b"

/datum/skin_tone/chestnut
	name = "chestnut"
	cases = list("каштановый", "каштанового", "каштановому", "каштановый", "каштановым", "каштановом")
	hex = "#a57a66"

/datum/skin_tone/macadamia
	name = "macadamia"
	cases = list("макадамия", "макадамии", "макадамии", "макадамию", "макадамией", "макадамии")
	hex = "#866e63"

/datum/skin_tone/walnut
	name = "walnut"
	cases = list("ореховый", "орехового", "ореховому", "ореховый", "ореховым", "ореховом")
	hex = "#87563d"

/datum/skin_tone/coffee
	name = "coffee"
	cases = list("кофейный", "кофейного", "кофейному", "кофейный", "кофейным", "кофейном")
	hex = "#725547"

/datum/skin_tone/brown
	name = "brown"
	cases = list("коричневый", "коричневого", "коричневому", "коричневый", "коричневым", "коричневом")
	hex = "#b87840"

/datum/skin_tone/medium_brown
	name = "medium brown"
	cases = list("средне-коричневый", "средне-коричневого", "средне-коричневому", "средне-коричневый", "средне-коричневым", "средне-коричневом")
	hex = "#754523"

/datum/skin_tone/dark_brown
	name = "dark brown"
	cases = list("темно-коричневый", "темно-коричневого", "темно-коричневому", "темно-коричневый", "темно-коричневым", "темно-коричневом")
	hex = "#471c18"
