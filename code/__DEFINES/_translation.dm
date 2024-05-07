////////////////////////////////////////////////
//                   Падежи                   //
////////////////////////////////////////////////

#define NOMINATIVE_CASE    1 //delete when names get translated... or dont.
#define GENITIVE_CASE      2
#define DATIVE_CASE        3
#define ACCUSATIVE_CASE    4
#define ABLATIVE_CASE      5
#define PREPOSITIONAL_CASE 6

// Пример определения CASEs у объекта:
//	/datum
//		cases = list("атом", "атома", "атому", "атом", "атомом", "атоме")
//
// Пример использования:
// "... [CASE(datum, DATIVE_CASE)] ..."
// Если у объекта не определены cases, будет взят дефолтный name, который скорее всего на английском.

#define CASE(datum, case) (datum.cases && datum.cases[case] ? datum.cases[case] : datum.name)

////////////////////////////////////////////////
//              Местоимения(ENG)              //
////////////////////////////////////////////////

// В английском большинство ситуаций покрывается дефолтными бьендовскими макросами:
// https://www.byond.com/docs/ref/info.html#/DM/text/macros
// но дефолтные макросы контекстно зависимы от положения в строке и их не всегда достаточно

#define P_THEY(atom) atom.gender == MALE && "he" \
               || atom.gender == FEMALE && "she" \
               || atom.gender == NEUTER && "it" \
               || "they"

#define P_THEM(atom) atom.gender == MALE && "him" \
               || atom.gender == FEMALE && "her" \
               || "them"

#define P_THEIR(atom) atom.gender == MALE && "his" \
               || atom.gender == FEMALE && "her" \
               || "their"

////////////////////////////////////////////////
//              Местоимения(RU)               //
////////////////////////////////////////////////

// По большей части аналоги дефолтных бьендовских макросов, но для русского языка

// И Кто/что
// "Неудачно пошутив, [THEY_RU(src)] падает без признаков жизни"
#define THEY_RU(atom) atom.gender == MALE && "он" \
               || atom.gender == FEMALE && "она" \
               || atom.gender == NEUTER && "оно" \
               || "они"
// Р Кого/чего
// "У вас больше нет [THEIR_RU(src)]"
#define THEIR_RU(atom) atom.gender == MALE && "его" \
               || atom.gender == FEMALE && "её" \
               || atom.gender == NEUTER && "этого" \
               || "их"
// Д Кому/чему
// "Вы передали [TO_RU(src)] предмет"
#define TO_RU(atom) atom.gender == MALE && "ему" \
               || atom.gender == FEMALE && "ей" \
               || atom.gender == NEUTER && "этому" \
               || "им"
// Д К кому/к чему
// "По [TO2_RU(src)] сразу видно"
#define TO2_RU(atom) atom.gender == MALE && "нему" \
               || atom.gender == FEMALE && "ней" \
               || atom.gender == NEUTER && "этому" \
               || "ним"
// В Кого/что
// "Вы больше не видите [THEM_RU(src)]"
#define THEM_RU(atom) atom.gender == MALE && "его" \
               || atom.gender == FEMALE && "её" \
               || atom.gender == NEUTER && "это" \
               || "их"
// Т Кем/чем
// "Вы пытаетесь ударить [BY_RU(src)]"
#define BY_RU(atom) atom.gender == MALE && "им" \
               || atom.gender == FEMALE && "ею" \
               || atom.gender == NEUTER && "этим" \
               || "ими"
// П (В) ком/чём
// "Вы полностью уверены в [IN_RU(src)]"
#define IN_RU(atom) atom.gender == MALE && "нём" \
               || atom.gender == FEMALE && "ней" \
               || atom.gender == NEUTER && "этом" \
               || "них"
// П О ком/о чём
// "Вы всё время думаете [ABOUT_RU(src)]"
#define ABOUT_RU(atom) atom.gender == MALE && "о нём" \
               || atom.gender == FEMALE && "о ней" \
               || atom.gender == NEUTER && "об этом" \
               || "о них"
// Чьё
// "По неизвестной причине [MY_RU(src)] зрение ухудшается" // todo: имеется в виду [MY_RU(зрение)], тут и ниже - так себе примеры
#define MY_RU(atom) atom.gender == MALE && "мой" \
               || atom.gender == FEMALE && "моя" \
               || atom.gender == NEUTER && "моё" \
               || "мои"
// Чьё
// "Вы пытаетесь встать, но [YOURS_RU(src)] ноги не шевелятся"
#define YOURS_RU(atom) atom.gender == MALE && "ваш" \
               || atom.gender == FEMALE && "ваша" \
               || atom.gender == NEUTER && "ваше" \
               || "ваши"
// Который
// "К сожалению, [WHICH_RU(src)] органическое лезвие нельзя положить в сумку"
#define WHICH_RU(atom) atom.gender == MALE && "этот" \
               || atom.gender == FEMALE && "эта" \
               || atom.gender == NEUTER && "это" \
               || "эти"

////////////////////////////////////////////////
//                   Глагол                   //
////////////////////////////////////////////////

// Прошедшее время глагола
// "делал[VERB_RU(src)]"
#define VERB_RU(atom) atom.gender == FEMALE && "а" \
               || atom.gender == NEUTER && "о" \
               || atom.gender == PLURAL && "и" \
               || ""
// Прошедшее время возвратного глагола
// "отказал[VERB2_RU(src)] взять предмет"
#define VERB2_RU(atom) atom.gender == MALE && "ся" \
               || atom.gender == FEMALE && "ась" \
               || atom.gender == NEUTER && "ось" \
               || "ись"

////////////////////////////////////////////////
//                   Прочее                   //
////////////////////////////////////////////////

// Произвольное слово в вариации по родам
// "[vessel] [ANYMORPH(vessel, "полон", "полна", "полно", "полны")]"
#define ANYMORPH(atom, w_male, w_female, w_neuter, w_plural) atom.gender == MALE && w_male \
               || atom.gender == FEMALE && w_female \
               || atom.gender == NEUTER && w_neuter \
               || w_plural

// Capitalize Case: тоже самое, что и CASE, только превращает первую букву в заглавную
#define C_CASE(atom, case) capitalize(CASE(atom, case))

// Часто встречаемые pluralize_russian(). Не забывайте про существование нецелых чисел и округления - они тоже влияют.
#define PLUR_UNITS(units) pluralize_russian(units, "юнит", "юнита", "юнитов")

#define PLUR_SECONDS_LEFT(seconds) pluralize_russian(seconds, "секунда", "секунды", "секунд") // "Осталась 1 секунда". Не путайте с нижним.
#define PLUR_SECONDS_IN(seconds)   pluralize_russian(seconds, "секунду", "секунды", "секунд") // "Через 1 секунду". Не путайте с верхним.
