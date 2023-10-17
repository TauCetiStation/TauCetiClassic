#define CHANGELING_TEST_INACTIVE 0
#define CHANGELING_TEST_PROCESS  1
#define CHANGELING_TEST_DONE     3

/obj/item/weapon/changeling_test
	name = "changeling test device"
	desc = "Single use test. Read attached instructions before use."

	icon = 'icons/obj/changeling_test.dmi'
	icon_state = "chantest0"

	w_class = SIZE_TINY
	flags = NOREACT

	var/label
	
	var/test_stage = CHANGELING_TEST_INACTIVE
	var/test_result_positive = FALSE

	var/datum/reagents/chamber_A
	var/datum/reagents/chamber_B

	origin_tech = "biotech=1" // after succesfull test biotech=5

/obj/item/weapon/changeling_test/atom_init()
	. = ..()

	chamber_A = new(5)
	chamber_A.my_atom = src
	chamber_B = new(5)
	chamber_B.my_atom = src

	reagents = chamber_A

/obj/item/weapon/changeling_test/Destroy()
	reagents = null
	
	QDEL_NULL(chamber_A)
	QDEL_NULL(chamber_B)

	return ..()

/obj/item/weapon/changeling_test/prepared/atom_init()
	. = ..()

	var/list/blood_data = list("changeling_marker"=list("id" = md5("catch 'em all!"), "timelimit" = FALSE))
	chamber_A.add_reagent("blood", 5, data = blood_data, safety = TRUE)

	reagents = chamber_B

	update_status()

/obj/item/weapon/changeling_test/attack_self(mob/living/user)
	if(test_stage != CHANGELING_TEST_INACTIVE)
		to_chat(user, "<span class='notice'>[result_message()]</span>")
		return

	if(!chamber_A.total_volume || !chamber_B.total_volume )
		to_chat(user, "<span class='warning'>Nothing to test, load blood examples first.</span>")
		return

	user.visible_message("<span class='notice'>[usr] toggles [src] test on.</span>", "<span class='notice'>You started [src] test, expect results soon.</span>")

	test_stage = CHANGELING_TEST_PROCESS

	update_status()

	addtimer(CALLBACK(src, PROC_REF(announce_result)), rand(120, 300) SECONDS) // ~2-5 minutes

/obj/item/weapon/changeling_test/proc/announce_result()
	test_stage = CHANGELING_TEST_DONE

	var/datum/reagent/blood/A_blood = chamber_A.get_reagent(/datum/reagent/blood)
	var/datum/reagent/blood/B_blood = chamber_B.get_reagent(/datum/reagent/blood)

	test_result_positive = FALSE

	if(A_blood && A_blood.data["changeling_marker"] && B_blood && B_blood.data["changeling_marker"])
		if(A_blood.data["changeling_marker"]["id"] != B_blood.data["changeling_marker"]["id"]) // no reaction between blood from the same changeling
			test_result_positive = TRUE

	if(test_result_positive)
		origin_tech = "biotech=5"

	update_status()

	audible_message("[bicon(src)] <span class='notice'>\The [src.name] beeps</span>")
	playsound(src, 'sound/effects/triple_beep.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/changeling_test/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		
		var/new_label = sanitize_safe(input(user, "Write new label", label), MAX_NAME_LEN)
		if(!new_label)
			return
		if(!Adjacent(user))
			return

		label = new_label

		update_status()

/obj/item/weapon/changeling_test/on_reagent_change() // someone injected something
	var/datum/reagent/blood/B = reagents.get_reagent(/datum/reagent/blood)

	if(B && B.data["changeling_marker"] && B.data["changeling_marker"]["timelimit"]) // so we have changeling blood, need to "freeze" timer or remove marker if time already ended

		if(world.time > B.data["changeling_marker"]["timelimit"]) // woops time is ended this test is useless now
			B.data["changeling_marker"] = null
		else // we were fast and blood is in secured location now to preserve marker
			B.data["changeling_marker"]["timelimit"] = FALSE

	update_status()

/obj/item/weapon/changeling_test/verb/switch_chamber()
	set name = "Switch opening chamber"
	set category = "Object"
	set src in range(0)

	if(test_stage != CHANGELING_TEST_INACTIVE)
		to_chat(usr, "<span class='warning'>You can't do this, switcher is blocked.</span>")
		return

	if(chamber_A == reagents)
		reagents = chamber_B
		to_chat(usr, "<span class='notice'>You switched opening to chamber \"B\".</span>")
	else
		reagents = chamber_A
		to_chat(usr, "<span class='notice'>You switched opening to chamber \"A\".</span>")

/obj/item/weapon/changeling_test/proc/update_status()
	desc = initial(desc)

	if(label)
		desc += "\n Label has next text: \"[label]\"."

	if(chamber_A.total_volume && chamber_B.total_volume)
		desc += "\n You see both test chambers is filled."
	else if (chamber_A.total_volume)
		desc += "\n You see test chambers A is filled."
	else if (chamber_B.total_volume)
		desc += "\n You see test chambers B is filled."

	var/res = result_message()
	if(res)
		desc += res

	update_icon()

/obj/item/weapon/changeling_test/update_icon()
	cut_overlays()
	icon_state = "chantest0"


	if (test_stage == CHANGELING_TEST_PROCESS)
		icon_state = "chantest1"
	else if (test_stage == CHANGELING_TEST_DONE)
		if(test_result_positive)
			icon_state = "chantest3"
		else
			icon_state = "chantest2"

	if(chamber_A.total_volume)
		add_overlay("blooda")

	if(chamber_B.total_volume)
		add_overlay("bloodb")

/obj/item/weapon/changeling_test/proc/result_message()
	if (test_stage == CHANGELING_TEST_PROCESS)
		. = "You see the light is blinking - test is in progress and will be ready soon."
	else if (test_stage == CHANGELING_TEST_DONE)
		if(test_result_positive)
			. = "\nThe test is done. You see the light is <span class='nicegreen'>GREEN</span>, this means the test was positive!"
		else
			. = "\nThe test is done. You see the light is <span class='red'>RED</span>, this means the test was negative!"

#undef CHANGELING_TEST_INACTIVE
#undef CHANGELING_TEST_PROCESS
#undef CHANGELING_TEST_DONE


/obj/item/weapon/paper/changeling_test_instruction
	name = "test instruction"
	info = {"
Инструкция по применению теста на генокрада.<br>
<br>
Тест содержит две заполняемые камеры: Камера A и Камера B.<br>
Вы можете переключать вводный клапан между этими двумя камерами для дальнейшего заполнения шприцем.<br>
<br>
Процедура тестирования:<br>
<br>
1.Заполните шприцем одну из камер кровью гарантированно подтвержденного генокрада (см. примечание 1). Часть предоставленных корпорацией тестов уже содержат кровь генокрада в Камере A и готовы к использованию.<br>
2. Заполните шприцем вторую камеру кровью тестируемого человека (см. примечание 1).<br>
3. Запустите тест в работу, ожидайте результатов в течении 5 минут.<br>
<br>
Если тест показал позитивный результат (зелёная лампа), это значит, что оба образца крови оказались от различных генокрадов и спровоцировали реакцию.<br>
<br>
Примечания:<br>
<br>
1. Кровь генокрада вне живого тела сохраняет свойства не более нескольких минут. После забора крови для теста <b>важно поместить её в тестовую камеру в первую же минуту</b>, где она будут сохранятся продолжительное время. В противном случае, результаты могут быть не точны. Максимально задукоментированное время активности крови вне специальных условий - около 20 минут.<br>
1.1. В случае забора крови умершего генокрада, счет времени идет от момента его смерти.<br>
2. Реакция не воспроизводится между образцами крови от одного и того же генокрада. Предоставленные корпорацией готовые тесты содержат кровь гарантированно подтвержденного и утилизированного генокрада, что исключает вероятность их ложного срабатывания.<br>
3. Имейте в виду, что изъятие образцов из тестовой камеры невозможно.
<br>
В связи со сложностями воспроизведения готовых тестов, корпорация НаноТрейзен не может предоставить достаточное количество всем объектам.<br>
В случае подозрений на появление генокрадов на объекте, рекомендуется использование готовых тестов для подтверждения генокрада, и использование подтвержденого генокрада для воспроизведения новых готовых тестов на месте.<br>
"}// ... соблюдайте осторожность, генокрады очень хитры и проворны. Нужен редакт.


/obj/item/weapon/storage/box/changeling_tests
	name = "changeling tests"
	desc = "Box containing some tests and instructions."
	icon_state = "box"

/obj/item/weapon/storage/box/changeling_tests/atom_init()
	. = ..()
	new /obj/item/weapon/paper/changeling_test_instruction(src)
	for(var/i in 1 to 2)
		new /obj/item/weapon/changeling_test/prepared(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/changeling_test(src)
