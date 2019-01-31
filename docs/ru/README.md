# Дипломатия

Хотите прочитать на другом языке? | [English](/README.md) | [Русский](/docs/ru/README.md)
|---|---|---|

## Быстрые ссылки

[Список изменений](CHANGELOG.md) | [Руководство контрибьютора](CONTRIBUTING.md)
|---|---|

## Содержание

* [Введение](#overview)
* [Настройки мода](#mod-settings)
    * [Для карты](#map)
    * [Для карты](#startup)
* [Сообщить об ошибке](#issue)
* [Запросить функцию](#feature)
* [Установка](#installing)
* [Зависимости](#dependencies)
    * [Встроенные](#embedded)
* [Особая благодарность](special-thanks)
* [Лицензия](#license)

## <a name="overview"></a> Введение


Рекомендую использовать с модами: [secondary chat][secondary chat], так как позволит писать союзникам;
[Tiny pole][Tiny pole] если защита от кражи от электричества выключена;
Трудно найти вражеских врагов? Используй [Dirty talk][Dirty talk];
Для балансировки фактор эволюции между командами [Soft evolution][Soft evolution];
Для пользовательского сценарий "PvP" [Pack scenarios][Pack scenarios].

Более подробнее на [английском языке]((/README.md)).

## <a name="mod-settings"></a> Настройки мода

### <a name="map"></a> Для карт:

| Описание | Параметры | (По умолчанию) |
| -------- | --------- |  ------------- |
| Защита от кражи электричества - не позволяет врагу подключиться к чужому электричеству else's electricity | логический | истина |
| Показывать все фракции - скрывает в дипломатии фракции без игроков | логический | ложь |
| Кол-во жизней для смены отношений при уничтожение объекта - изменит состояние отношений при уничтожение объекта >= кол-во жизней | 1-100000000000 | 300 |
| Кол-во жизней для смены отношений при добыче объекта - изменит состояние отношений при добыче объекта >= кол-во жизней | 1-100000000000 | 300 |
| Кол-во жизней для смены отношений при уроне по объекту - изменит состояние отношений при уроне по объекту >= кол-во жизней | 1-100000000000 | 300 |
| Разрешить игроку добывать объект у союзной фракции | логический | ложь |
| Авто-дипломатия при нанесение урона - Проверяет урон и меняет отношения между фракциями | логический | истина |
| Дипломатические привилегии - Определяет игроков, которые могут менять дипломатические позиции к другим командам. Все игроки: каждый игрок в команде. Лидер команды: игрок, который дольше всех был в команде | ["all players", "team leader"] | all players |

### <a name="startup"></a> При старте:

| Описание | Параметры | (По умолчанию) |
| -------- | --------- |  ------------- |
| Скрыть все маркеры объектов на карте | логический | ложь |
| Кол-во жизней у ракетной шахты - изменить кол-во жизней у ракетной шахты | 1-10000000000 | 50000 |
| Кол-во колб за технологию танков | 1-10000000000 | 1000 |
| Кол-во колб за технологию силовая броня MK2 | 1-10000000000 | 1000 |
| Кол-во колб за технологию урановые боеприпасы | 1-10000000000 | 1800 |

## <a name="issue"></a> Нашли ошибку?

Пожалуйста, сообщайте о любых проблемах или ошибках в документации, вы можете помочь нам
[submitting an issue][issues] на нашем GitLab репозитории или сообщите на [mods.factorio.com][mod portal] или на [forums.factorio.com][homepage].

## <a name="feature"></a> Хотите новую функцию?

Вы можете *запросить* новую функцию [submitting an issue][issues] на нашем GitLab репозитории или сообщите на [mods.factorio.com][mod portal] или на [forums.factorio.com][homepage].

## Установка

Если вы скачали zip архив:

* просто поместите его в директорию модов.

Для большей информации, смотрите [вики Factorio "загрузка и установка модов"](https://wiki.factorio.com/Modding/ru#.D0.97.D0.B0.D0.B3.D1.80.D1.83.D0.B7.D0.BA.D0.B0_.D0.B8_.D1.83.D1.81.D1.82.D0.B0.D0.BD.D0.BE.D0.B2.D0.BA.D0.B0_.D0.BC.D0.BE.D0.B4.D0.BE.D0.B2).

Если вы скачали исходный архив (GitLab):

* скопируйте данный мод в директорию модов Factorio
* переименуйте данный мод в event-listener_*версия*, где *версия* это версия мода, которую вы скачали (например, 2.0.0)

## <a name="dependencies"></a> Зависимости

### <a name="embedded"></a> Встроенные

* Event listener: [mods.factorio.com](https://mods.factorio.com/mod/event-listener), [GitLab](https://gitlab.com/ZwerOxotnik/event-listener)

## <a name="special-thanks"></a> Особая благодарность

* **Plov** - тестер

## <a name="license"></a> Лицензия

Пожалуйста, прочитайте [Terms of Service and information](/Terms-of-Service-and-information.txt) и [LICENSE](/LICENSE)

[Tiny pole]: https://mods.factorio.com/mod/TinyPole
[secondary chat]: https://mods.factorio.com/mods/ZwerOxotnik/secondary-chat
[Pack scenarios]: https://mods.factorio.com/mod/pack-scenarios
[Soft evolution]: https://mods.factorio.com/mod/soft-evolution
[Dirty talk]: https://mods.factorio.com/mod/dirty-talk
[issues]: https://gitlab.com/ZwerOxotnik/soft-evolution/issues
[mod portal]: https://mods.factorio.com/mod/soft-evolution/discussion
[homepage]: https://forums.factorio.com/viewtopic.php?f=190
[Factorio]: https://factorio.com/
