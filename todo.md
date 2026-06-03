- asset_cache ОТДЕЛЬНО
- сжечь тгшные интерфейсы
- вернуть кастомные компоненты и наши интерфейсы
- выпилить преференсы, вынести нужные в сетап
- - /datum/preference/toggle/tgui_input_large
- - /datum/preference/toggle/tgui_input_swapped
- - /datum/preference/toggle/tgui_input
- - /datum/preference/choiced/tgui_layout
- - - /datum/preference/choiced/tgui_layout/smartfridge
- - if(action == "change_tgui_state")
- - сжечь tgui_fancy
- аргументы tgui_input_list - дефолт может занять чужое место
- вернуть эмодзи
- вернуть весь инпут, перенесенный в отдельную залупу
- перенести cbt, но в репе должно храниться актуальное состояние или оставить ручную установку пиздеца (его теперь больше!!)
- автокомпил в ci при конфликте или ci fail(!)?
- (istype(device) && device.loc != src)
- min(..(), UI_UPDATE)
- tgui:storagecdn
- - STORAGE_CDN_IFRAME
- payload["charset"] payload["charset"] payload["charset"]
- payload["localTime"]
- browse_queue_flush
- asset эмодзи (ща base64) (надо ли? вроде и так норм)
- миграция чата с бьонда на идб
- защита стореджа: сообщения, телеметрия
- тг уже сделали несколько пров на тгуи с начала работы
- - https://github.com/tgstation/tgstation/commits/master/tgui
- - https://github.com/tgstation/tgstation/commit/c0333ffc02af88459d27d9582bf2d8dea902c384
- - https://github.com/tgstation/tgstation/commit/c89a3c1798d267fa1e36cf5d9563fd59e8a0b1b1
- - https://github.com/tgstation/tgstation/commit/6220dd85e1551186936f60a23eff4940714d41cf
- - https://github.com/tgstation/tgstation/commit/475fe94750732c8b4e4ad218b2b55c996e90bffa <- видимо делает те же изменения скина, что сделал я

- - хотят вернуть инфо кнопки https://github.com/tgstation/tgstation/pull/95383
- chat styles
- https://github.com/TauCetiStation/TauCetiClassic/pull/13188
- tgui/packages/tgui/components/SegmentDisplay.js

конфиги:
- STORAGE_CDN_IFRAME
- asset_transport
- ...

изменения:
- /mob/living/default_can_use_topic - обезьяны теперь ВРОДЕ БЫ могут юзать консоли. могли ли раньше? чем это плохо?
- ии может тыкать свой апц при отсутствии питания (фикс?)


https://github.com/tgstation/tgstation/pull/95932
