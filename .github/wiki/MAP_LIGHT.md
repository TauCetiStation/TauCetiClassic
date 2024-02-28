# Smart Light

Умный свет - система цветного света для лампочек на станции, пресеты и моды позволяют настроить индивидуальное освещение для вашей карты.

### Как добавить новый набор-пресет для карты:

* Добавить новый ``/datum/smartlight_preset/вашеимя`` в [``/code/datums/lighting/smartlight_presets.dm``](/code/datums/lighting/smartlight_presets.dm) со своими настройками и уникальным ``.name``
* Добавить в json конфига карты параметр ``smartlight_preset`` с ``.name`` нового пресета. Конфиг тестовой карты как пример.

### Как добавить новый набор-пресет для зоны:
* Добавить новый ``/datum/smartlight_preset/вашеимя`` в [``/code/datums/lighting/smartlight_presets.dm``](/code/datums/lighting/smartlight_presets.dm) со своими настройками и уникальным ``.name``
* На карте прописать нужному APC в параметры ``custom_smartlight_preset`` с ``.name`` нового пресета. APC бара на боксе как пример.

### Как добавить новый световой мод:
* Смотреть [``/code/datums/lighting/light_modes.dm``](/code/datums/lighting/light_modes.dm), добавить новый datum. Поэкспериментировать с параметрами для света можно дебаг-вербом "Add Smartlight Preset".
  *  Рекомендую для ярких цветов уменьшать рейндж или силу, иначе оно начинает выглядеть как скучный цвето-фильтр на весь экран.
* Опционально - добавить новый тип ``/obj/item/weapon/disk/smartlight_programm`` в ``/code/game/machinery/computer/smartlight_console.dm``, добавить в карго заказы по подобию ``/datum/supply_pack/smartlight_standart``.

### Как добавить новые уникальные лампочки:
* Рекомендуется: добавить новый тип ``/obj/item/weapon/light/*`` со своим световым модом и прочими настройками, и соответствующую ему лампу ``/obj/machinery/light/*``.
* Старый вариант: в параметрах лампы (любой ``/obj/machinery/light/*``) на карте прописать параметры ``force_override_color``, ``force_override_power``, ``force_override_range``. *Не рекомендуется, потому что хардкод и игнорирует параметры вставленной лампочки.*

