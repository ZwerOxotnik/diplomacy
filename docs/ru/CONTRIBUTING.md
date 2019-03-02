# Руководство контрибьютора

## О переводе

Пожалуйста, обратите внимание, что мод находится в процессе интернационализации.

## Соглашения о кодировании

Мы оптимизируем для удобочитаемости:

* Мы делаем отступ, используя табуляцию, однако пробелами тоже приемлемо
* Прочитайте [заметка о сообщениях Git commit](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
* Каждая ветка делится на версии игры Factorio x.x (например, 0.17)

## <a name="issue"></a> Нашли ошибку?

Пожалуйста, сообщайте о любых проблемах или ошибках в документации, вы можете помочь нам
[submitting an issue](https://gitlab.com/ZwerOxotnik/timesaver-for-crafting/issues) на нашем GitLab репозитории или сообщите на [mods.factorio.com](https://mods.factorio.com/mod/timesaver-for-crafting/discussion).

## <a name="feature"></a> Хотите новую функцию?

Вы можете *запросить* новую функцию [submitting an issue](https://gitlab.com/ZwerOxotnik/timesaver-for-crafting/issues) на нашем GitLab репозитории или сообщите на [mods.factorio.com](https://mods.factorio.com/mod/timesaver-for-crafting/discussion).

## Предпосылки

Мы рекомендуем несколько инструментов, чтобы собрать мод, включая:

* [Git](https://git-scm.com) — распределённая система управления версиями
* [jq](https://stedolan.github.io/jq/) — процессор командной строки JSON

## Расширения

Если вы используйте [Visual Studio code](https://code.visualstudio.com), мы рекомендуем:

* [Lua](https://marketplace.visualstudio.com/items?itemName=keyring.Lua)
* [vscode-lua](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua)
* [Factorio Lua API autocomplete](https://marketplace.visualstudio.com/items?itemName=svizzini.factorio-lua-api-autocomplete)
* [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight)
* [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
* [Guides](https://marketplace.visualstudio.com/items?itemName=spywhere.guides)

### Для других IDE:

* Для Vim, [Syntastic](https://github.com/vim-syntastic/syntastic) содержит [luacheck checker](https://github.com/vim-syntastic/syntastic/wiki/Lua%3A---luacheck);
* Для Sublime Text 3 есть [SublimeLinter-luacheck](https://packagecontrol.io/packages/SublimeLinter-luacheck), который требует [SublimeLinter](https://sublimelinter.readthedocs.io/en/latest/);
* Для Atom есть [linter-luacheck](https://atom.io/packages/linter-luacheck), который требует [AtomLinter](https://github.com/steelbrain/linter);
* Для Emacs, [Flycheck](http://www.flycheck.org/en/latest/) содержит [luacheck checker](http://www.flycheck.org/en/latest/languages.html#lua);
* Для Brackets, есть [linter.luacheck](https://github.com/Malcolm3141/brackets-luacheck) расширение;
