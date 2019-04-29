# 4babushkin_microservices
4babushkin microservices repository

## Lesson-14 HW Docker

[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=docker-1)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

### Установка
* **Установка [Docker](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/) в Ubuntu**
* `docker ps` - Список запущенных контейнеров
* `docker ps -a` - Список всех контейнеров
* `docker images` - Список сохранненных образов
* `docker run` = docker create + docker start + docker attach
* `docker run -it ubuntu:16.04 bash` - запустить ubuntu
  - i - запускает контейнер в foreground режиме (docker attach)
  - d - запускает контейнер в background режиме
  - t - создает TTY
* `docker history` - Показывает историю создания image, слои образа и какие команды использовались
* `docker commit 8d0234c50f77 4babushkin/myapp2 ` - Создает image из контейнера, контейнер  остается запущенным
* `docker kill $(docker ps -q)` - убить все запущенные контейнеры
* `docker system df` - Отображает сколько дискового пространства занято
* 