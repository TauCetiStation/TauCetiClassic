// Printed by the QM console within the first 15 minutes. The QM physically carries this to
// CentComm; the round-end resolver activates the edict if the QM is at CC, alive and not under
// arrest, while holding this exact type (forge-proof: players cannot fabricate the type).
/obj/item/weapon/paper/cargo_guard_request
	name = "запрос на ЧОП (форма Л-1)"
	info = {"<h2 style="text-align: center;">Запрос на учреждение ЧОП Карго</h2>
	<p>Настоящим отдел снабжения станции ходатайствует перед Логистическим департаментом ЦК об учреждении частного охранного предприятия для защиты активов Карго на будущие смены.</p>
	<p>Для удовлетворения запроса носитель данной формы (квартирмейстер) обязан лично прибыть на станцию Центрального Командования к моменту прибытия шаттла смены экипажа или эвакуационного шаттла, будучи живым и не находясь под арестом. Финансовое обеспечение запроса подтверждается остатком счёта Карго на момент конца смены.</p>
	<p><b>Ограничение по численности.</b> Запрос рассматривается только если к концу смены на сервере находится не менее %MIN_POP% живых игроков. При меньшей численности число сотрудников ЧОП не изменяется.</p>"}

/obj/item/weapon/paper/cargo_guard_request/atom_init()
	info = replacetext(info, "%MIN_POP%", "[CARGO_GUARD_MIN_POP]")
	. = ..()
	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "CentComm Logistics Department")

// Spawned in the QM office and on the bridge at round start while the edict is active. Carries the
// instructions for keeping/losing the law. To revoke the edict, command stamps this sheet with the
// Captain and HoS stamps and delivers it to CentComm (see the resolver).
/obj/item/weapon/paper/cargo_guard_edict
	name = "указ о ЧОП Карго"
	info = {"<h2 style="text-align: center;">Действующий указ: ЧОП Карго</h2>
	<p>На станции действует частное охранное предприятие Карго: в штат добавлены сотрудники ЧОП с правом ношения оружия (до 4 человек).</p>
	<p><b>Содержание.</b> К концу каждой смены на счету Карго должно оставаться по 10 000$ за каждого сотрудника ЧОП. Не хватило — указ <b>полностью отменяется</b> (все ЧОП распускаются).</p>
	<p><b>Численность экипажа.</b> Указ пересматривается только при населении не менее %MIN_POP% живых игроков к концу смены. Если игроков меньше, число сотрудников ЧОП остаётся прежним независимо от остальных условий.</p>
	<p><b>Расширение.</b> Чтобы добавить ещё одного ЧОП (+1, не более 4), квартирмейстер запрашивает его на консоли и доставляет форму на ЦК, а к концу смены на счету держится сумма уже на нового сотрудника.</p>
	<p><b>Отмена.</b> Указ также отменяется, если к концу смены среди эвакуировавшихся каргонцев меньше, чем офицеров СБ; либо если данный лист заверен печатями Капитана и Главы СБ, доставлен на ЦК, оба главы живы и находятся на основном эвакуационном шаттле (эвакуационные капсулы не считаются), а все сотрудники ЧОП арестованы (в наручниках) на этом шаттле.</p>"}

// Tracked so the round-end resolver can find the (few) genuine edict sheets without scanning world.
// Only these original typed sheets count for revocation - a photocopy is a plain /paper and ignored.
var/global/list/cargo_guard_edict_papers = list()

/obj/item/weapon/paper/cargo_guard_edict/atom_init()
	info = replacetext(info, "%MIN_POP%", "[CARGO_GUARD_MIN_POP]")
	. = ..()
	cargo_guard_edict_papers += src
	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "CentComm Logistics Department")

/obj/item/weapon/paper/cargo_guard_edict/Destroy()
	cargo_guard_edict_papers -= src
	return ..()
