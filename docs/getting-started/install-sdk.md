---
title: Установка SDK
---

Для программирования NAO нужно установить SDK с сайта Aldebaran. Это можно
сделать двумя способами -- скачать с сайта или скомпилировать из исходников.

!!! note "Заметка"
	В данной статье описывается установка SDK в Debian (и его производные), для
	работы с SDK на Windows или macOS рекомендуется использовать
	[Vagrant](vagrant.md).

Перед установкой SDK нужно убедиться, что в системе установлен интерпретатор
Python 2.7. Для этого в терминале выполним следующую команду:

	python --version
	# Python 2.7.13

Пользователи Arch Linux набирают `python2` (скорее всего они сами знают чего
набирать).

Если Python 2.7 не установлен, ставим его командой

	sudo apt install python

## Загрузка SDK

Архив с SDK под Linux находится по ссылке
[https://community.ald.softbankrobotics.com/en/resources/software/][sdk-path].
Его достаточно распаковать в любую удобную папку и добавить путь к ней в
переменную среды `PYTHONPATH`.

```bash
export PYTHONPATH=/path/to/sdk/sdk-python
```

Рекомендуется добавить эту команду в .bashrc (.profile, .bash_profile и
т.п.)

```bash
echo "export PYTHONPATH=/path/to/sdk/sdk-python" >> $HOME/.bashrc
```

Проверим, что все работает, для этого импортируем главный модуль `qi` в Python

```bash
python -c "import qi"
```

В случае успеха данная команда должна завершиться без каких-либо сообщений.

## Компиляция SDK

Установку всех программ под Debian рекомендуется начинать со следующей команды

```bash
sudo apt update
```

Для компиляции SDK нам потребуются Git, CMake и pip (менеджер пакетов для
Python)

```bash
sudo apt install git cmake python-pip
```

Разработчики SDK распространяют специальную утилиту для работы с SDK, для работы
с SDK для Python она не нужна, но требуется для компиляции

```bash
sudo pip install qibuild
```

После установки всего необходимого нужно создать папку, в которой будут лежать
исходные коды SDK

```bash
mkdir sdk
cd sdk
```

Инициируем в этой папке проект QiBuild

```bash
qibuild init
```

Добавим к проекту все необходимые для сборки проекта зависимости

```bash
qisrc add https://github.com/aldebaran/gtest.git
qisrc add https://github.com/aldebaran/libqi.git
qisrc add https://github.com/aldebaran/libqi-python.git
```

Утилита `qitoolchain` позволяет загрузить неободимые зависимости для SDK

```bash
qitoolchain create --feed-name linux64 linux64 https://github.com/aldebaran/toolchains.git
```

Запустим конфигурацию проекта для нашей системы (linux64):

``` bash
qibuild add-config linux64 -t linux64
qibuild configure libqi-python --config linux64 --release
```

Произведем сборку проекта. Данная команда выполняется _довольно продолжительное_
время.

```bash
qibuild make libqi-python --config linux64 --njobs 2
```

После того как сборка будет завершена, стоит проверить, что библиотека
скомпилирована корректно, для этого нужно добавить следующие пути в переменную
системы `PYTHONPATH`:

```bash
export PYTHONPATH=/home/vagrant/sdk/aldebaran/libqi-python/build-linux64/sdk/lib/python2.7/site-packages:/home/vagrant/sdk/aldebaran/libqi-python/build-linux64/sdk/lib
```

Проверим, что все работает, для этого импортируем главный модуль `qi` в Python

```bash
python -c "import qi"
```

В случае успеха данная команда должна завершиться без каких-либо сообщений.

[sdk-path]: https://community-static.aldebaran.com/resources/2.1.4.13/sdk-python/pynaoqi-python2.7-2.1.4.13-linux64.tar.gz