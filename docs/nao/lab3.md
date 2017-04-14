---
title: Урок 3: Введение в libqi-python
description: Программирование робота Nao на языке Python при помощи библиотеки libqi-python
---

!!! note "Заметка"
	Для данной работы требуется виртуальная машина с установленными _SDK_.
	(см. [Vagrant](/vagrant.md))

## Цель работы

Цель данной работы --- научиться программировать роботов Aldebaran Nao.
Официально робот Nao поддерживает для языка программирования: `C++` и `Python`.
Кроме того существуют тестовые порты для `Java` и `JavaScript`. В наших
лабораторных работах мы будем использовать `Python`.

## Теория

### Использование сервисов

Использование базового сервиса `ALTextToSpeeсh` для произнесения фразы _Hello
World_

Создайте текстовый файл и назовите его, например, `say-hello.py`. Рассмотрим
следующий код:

``` python linenums="1"
"""main.py"""
import qi
import sys

app = qi.Application(sys.argv)
app.start()
tts = app.session.service("ALTextToSpeech")
tts.say("Hello, World")
```

Запустите код командой:

``` bash
python say-hello.py --qi-url=tcp://<robot-ip>:9559
```

Робот должен произнести "Hello, World".

Помимо `ALTextToSpeech` существуют и другие модули сервисы. С полным списком
можно ознакомиться в документации по адресу
http://doc.aldebaran.com/2-1/naoqi/index.html#naoqi-api.

Рассмотрим пример с несколькими сервисами одновременно:

``` python linenums="1" hl_lines="8 9 10"
"""main.py"""
import qi
import sys

app = qi.Application(sys.argv)
app.start()

tts = app.session.service("ALTextToSpeech")
motion = app.session.service("ALMotion")
posture = app.session.service("ALRobotPosture")

motion.wakeUp()
posture.goToPosture("Stand", 1.0)
tts.say("Hello, my name is Nao!")
motion.rest()
```

> 1. речевая функция
> 2. управление движением робота
> 3. управление позами робота

Алгоритм действий робота следующий:

* Запускаются все моторы робота функцией `wakeUp()` сервиса `ALMotion` (в
	_Choregraphe_ --- `stiffness`).
* Робот принимает позу `Stand` (т.е. встает, если сидел).
* Робот произносит `Hello, my name is Nao`.
* Моторы снова отключаются

Данный пример описывает создание последовательных действий в роботе, каждое
действие является _блокирующим_, т.е. пока оно не выполнится --- следующее не
наступит. Добавим параллельное действие:

``` python linenums="1"
"""main.py"""
import qi
import sys

HEY_ANIMATION_1 = "animations/Stand/Gestures/Hey_1"

app = qi.Application(sys.argv)
app.start()

tts = app.session.service("ALTextToSpeech")
motion = app.session.service("ALMotion")
posture = app.session.service("ALRobotPosture")
bhm = app.session.service("ALBehaviorManager")

motion.wakeUp()
posture.goToPosture("Stand", 1.0)
animation = bhm.runBehavior(HEY_ANIMATION_1, _async=True)
tts.say("Hello, my name is Nao!")
animation.value()
posture.goToPosture("Sit", 1.0)
tts.say("Bye-bye")
motion.rest()
```

Первая часть алгоритма не изменилась, но функция `runBehaviour()` вызывается с
ключом `_async=True`, которое производит действие _асинхронно_. В данном случае
робот помашет рукой и одновременно произнесет `Hello, my name is Nao`. Ожидание
выполнения действия осуществляется в строке `animation.value()`, после нее
действия снова становятся последовательными.

### Извлечение данных из памяти робота

В памяти робота содержится множество данных о текущем состоянии. Рассмотрим
алгоритм извлечения данных о гироскопе робота.

``` python linenums="1"
"""main.py"""
import qi
import sys

app = qi.Application(sys.argv)
app.start()

memory = app.session.service("ALMemory")

# Get the Gyroscope Values
gx = memory.getData("Device/SubDeviceList/InertialSensor/GyroscopeX/Sensor/Value")
gy = memory.getData("Device/SubDeviceList/InertialSensor/GyroscopeY/Sensor/Value")
gz = memory.getData("Device/SubDeviceList/InertialSensor/GyroscopeZ/Sensor/Value")
print("Gyrometer:\n\tX:%.3f, Y: %.3f, Z: %.3f" % (gx, gy, gz))

# Get the Accelerometer Values
ax = memory.getData("Device/SubDeviceList/InertialSensor/AccelerometerX/Sensor/Value")
ay = memory.getData("Device/SubDeviceList/InertialSensor/AccelerometerY/Sensor/Value")
az = memory.getData("Device/SubDeviceList/InertialSensor/AccelerometerZ/Sensor/Value")
print("Accelerometer:\n\tX:%.3f, Y: %.3f, Z: %.3f" % (ax, ay, az))

# Gyrometer:
#     X:0.001, Y: 0.005, Z: 0.003
# Accelerometer:
#     X:-0.728, Y: 0.316, Z: -10.318
```

### События

В лабораторной работе 1 мы обращались к событиям некоторых сенсоров робота.
Аналогичные действия можно выполнять и на Python, для этого понадобится метод
`run()` класса `Application`:

``` python linenums="1"
"""main.py"""
import qi
import sys

app = qi.Application(sys.argv)
app.start()

memory = app.session.service("ALMemory")
tts = app.session.service("ALTextToSpeech")

def on_touched(event):
    # value is 1 when pressed, 0 when released
    if event > 0:
        tts.say("ouch")

subscriber = memory.subscriber("FrontTactilTouched")
subscriber.signal.connect(on_touched)

app.run()
```

В конце скрипта вызывается `run()`, что заставляет программу работать, пока ее
не прервет пользователь сочетанием клавиш `[Ctrl+С]`. В данной программе мы
создаем подписчика `subscriber` на событие `FrontTactilTouched` (касание
переднего сенсора на голове) и назначаем функцию `on_touched`, которая будет
срабатывать по сигналу.

### Создание сервиса

Сначала напишем свой сервис, который затем зарегистрируем в системе. Для
создания сервиса достаточно только создать класс на Python. Создадим класс
`HelloService`, который по команде `greet(name)` будет приветствовать
пользователя:

``` python linenums="1" hl_lines="3 6"
"""main.py"""
class HelloService:
    def __init__(self, session):
        self.tts = session.service("ALTextToSpeech")

    def greet(self, name):
        self.tts.say("Hello, %s" % name)
```

> 1. Конструктор класса на языке Python. Аргумент `session` используем для вызова
>    сервиса `ALTextToSpeech`.
> 2. Функция сервиса, принимает на вход переменную `name` и вызывает функцию
>    `say()` с аргументом `Hello, #{name}`.

Чтобы мы могли подключаться к сервису, нужно создать объект класса
`HelloService` и зарегистрировать его в системе:

``` python linenums="1"
"""main.py"""
hello = HelloService(app.session)
app.session.registerService("Hello", hello)
```

Вместе с инициализацией `Application` программа-сервис выглядит следующим образом:

``` python linenums="1" hl_lines="21"
"""server.py"""
import qi
import sys

# Creating a server
class HelloService:
    def __init__(self, session):
        self.tts = session.service("ALTextToSpeech")

    def greet(self, name):
        self.tts.say("Hello, %s" % name)

# Creating a session
app = qi.Application(sys.argv)
app.start()

# Register service
hello = HelloService(app.session)
app.session.registerService("Hello", hello)

app.run()
```

> 1. Ожидается, что сервер будет зарегистрирован в системе до тех пор, пока он не
будет отключен, поэтому требуется вызвать функцию `run()`.

Теперь мы можем использовать сервис в другом скрипте аналогично всем остальным сервисам:

``` python linenums="1" hl_lines="10"
"""client.py"""
import qi
import sys

# Creating a session
app = qi.Application(sys.argv)
app.start()

# Test our service
hello = app.session.service("Hello")
hello.greet("dear user")
```

> 1. Имя сервиса, которое мы использовали при его регистрации.

После запуска обоих скриптов (очевидно, `server.py` запускается первым) робот произнесет `Hello, dear user`.

!!! tip "Подсказка"
	После запуска `python server.py --qi-url=...` консоль будет занята сервером,
	нужно открыть дополнительную консоль и в ней набрать `vagrant ssh -c "python
	client.py --qi-url=..."`.

## Задания

Напишите два скрипта на Python в соответствии с заданием:

**Задание 1:**
:   Робот должен пройтись прямо и одновременно произнести
	какую-нибудь фразу, а после выполнения обоих действий назвать температуру в
	голове и сесть.

**Задание 2:**
:   Робот должен произносить `left hand` или `right
	hand` в зависимости от того, за какую руку его трогают.