title: Работа с Vagrant
description: Установка Nao SDK при помощи виртуальной машины Vagrant

Чтобы упростить работу с SDK на Windows и macOS используем Vagrant. Vagrant
помогает установить и настроить виртуальную машину на основе конфигурационного
файла.

!!! tip "Linux"
	Vagrant и все необходимые программы есть и под Linux, инструкции по установке
	см. на официальных сайтах.

Для работы с Vagrant нужно поставить [VirtualBox][virtualbox] и
[Vagrant][vagrant]. После установки этих программ нужно скачать образ
виртуальной машины с Debian. Рекомендуется использовать актуальную версию
Debian, список доступных образов можно найти на сайте
[https://atlas.hashicorp.com/][bento]. На момент написания статьи актуальная
версия -- debian-8.7.

```bash
vagrant box add bento/debian-8.7
```

Перейдем в папку, в которой будем работать и выполним команду инициализации
Vagrant.

```bash
vagrant init bento/debian-8.7
```

Данная команда создаст в текущем каталоге конфигурационный файл Vagrantfile.
Откроем файл и заменим его следующим содержанием.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Образ виртуальной машины
  config.vm.box = "bento/debian-8.7"
  # Переброс портов 9559:9559 (понадобятся для программирования NAO)
  config.vm.network :forwarded_port, guest: 9559, host: 9559

  # Настройки виртуальной машины
  config.vm.provider "virtualbox" do |vb|
    # Отключаем интерфейс, он не понадобится
    vb.gui = false
    # Двухядерный процессор
    vb.cpus = 2
    # 512 Мб оперативной памяти
    vb.memory = 512
  end

  # Команда, которая выполнится после создания машины
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
  SHELL
end
```

Запустим машину

```bash
vagrant up
```

Первый раз виртуалка устанавливается, это может занимать какое-то время, в
следующий раз она будет запускаться быстрее.

После того, как машина выполнит процесс настройки и запустится, можно
подключиться к ней

```bash
vagrant ssh
```

После этого можно приступить к [установке SDK](installing.md). Выход из
Vagrant осущствляется командой `exit`.

После завершения работы виртуальную машину нужно выключить

```bash
vagrant halt
```

Если виртуальная машина больше не нужна, ее можно удалить комадной

```bash
vagrant destroy
```

[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant]: https://www.vagrantup.com/downloads.html
[bento]: https://atlas.hashicorp.com/bento