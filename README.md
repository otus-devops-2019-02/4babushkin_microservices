# 4babushkin_microservices
4babushkin microservices repository

# Lesson-16 HW Docker-3
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=docker-3)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание
* Создал файл для запуска docker-machine и подключния к хосту `start_docker_machine.sh`
* скачал [файл](https://github.com/express42/reddit/archive/microservices.zip) 
  ```bash
  wget https://github.com/express42/reddit/archive/microservices.zip && unzip microservices.zip && mv reddit-microservices src && rm microservices.zip
  ```
* Создал Docker файлы для `post-py`, `comment` и `ui` и собрал образы

  ```bash
  docker pull mongo:latest
  docker build --tag 4babushkin/post:1.0 ./post-py
  docker build --tag 4babushkin/comment:1.0 ./comment
  docker build -t 4babushkin/ui:1.0 ./ui
  ```
* Создадим сеть для приложения 
  ```bash
  docker network create reddit
  docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
  docker run -d --network=reddit --network-alias=post 4babushkin/post:1.0
  docker run -d --network=reddit --network-alias=comment 4babushkin/comment:1.0
  docker run -d --network=reddit -p 9292:9292 4babushkin/ui:1.0
  ```
* Выключим старые копии контейнеров `docker kill $(docker ps -q)`
* Создадим Docker volume `docker volume create reddit_db`
* Информация по volume `docker volume inspect reddit_db`
* Запустим новые копии контейнеров:
  ```bash
  docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db \
  -v reddit_db:/data/db mongo:latest
  docker run -d --network=reddit --network-alias=post 4babushkin/post:1.0
  docker run -d --network=reddit --network-alias=comment 4babushkin/comment:1.0
  docker run -d --network=reddit -p 9292:9292 4babushkin/ui:1.0
  ```
* Так как не очень удобное расположение volume, размещаем его в папке `/srv/mongodb` 
  ```bash
  docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db \
  -v /srv/mongodb:/data/db mongo:latest
  ```

## Задание со *
* Заменим алиасы через файл `env.list`. 
  ```bash
  docker run -d --network=reddit --network-alias=mongo_db -v reddit_db:/data/db mongo:latest
  docker run -d --network=reddit --network-alias=post --env-file ./env.list 4babushkin/post:1.0 
  docker run -d --network=reddit --network-alias=comment --env-file ./env.list 4babushkin/comment:3.0
  docker run -d --network=reddit -p 9292:9292 --env-file ./env.list 4babushkin/ui:3.0
  ```
  можно и так `--env VAR1=value1`

* Оптимизировали образы используя alpine-linux и кое что еще ))
  - 4babushkin/post 
  [![](https://images.microbadger.com/badges/image/4babushkin/post.svg)](http://microbadger.com/images/4babushkin/post "Get your own image badge on microbadger.com")
  - 4babushkin/ui [![](https://images.microbadger.com/badges/image/4babushkin/ui.svg)](http://microbadger.com/images/4babushkin/ui "Get your own image badge on microbadger.com")
  - 4babushkin/comment [![](https://images.microbadger.com/badges/image/4babushkin/comment.svg)](http://microbadger.com/images/4babushkin/comment:3.0 "Get your own image badge on microbadger.com")

  ```bash
  $ docker images
  REPOSITORY            TAG    IMAGE ID         CREATED        SIZE
  4babushkin/post       1.0    3804823c5e86     3 hours ago    96.4MB
  4babushkin/ui         1.0    78a1ae5d310c     5 hours ago    222MB
  4babushkin/comment    1.0    faaf5fb536cc     5 hours ago    219MB
  ```

## Просто так
* Запустил docker-machine на локальной машине в Virtualbox
  - `docker-machine create --driver virtualbox default`
  - ```bash
    docker-machine env default
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.100:2376"
    export DOCKER_CERT_PATH="/home/4babushkin/.docker/machine/machines/default"
    export DOCKER_MACHINE_NAME="default"
    # Run this command to configure your shell: 
    # eval $(docker-machine env default)
    ```
* если недо подключится по ssh `docker-machine ssh default`



# Lesson-15 HW Docker-2
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=docker-2)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание
* gcloud init && gcloud auth
* Установил docker-machine
  ```bash
  $ base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo install /tmp/docker-machine /usr/local/bin/docker-machine
  ```

* Docker machine
  ```bash
  export GOOGLE_PROJECT=_ваш-проект_
  ```
  ```bash
  $ docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type f1-micro \
  --google-zone europe-west1-b docker-host
  ```
  Переключение между машинами через eval (переключится на  docker-host)
  ```bash
  eval $(docker-machine env docker-host)
  ```
  Переключение на локальный докер
  ```bash
  eval $(docker-machine env --unset)
  ```
* Docker hub - уже был зарегин
* Загрузим наш образ на docker hub
  ```docker
  docker tag reddit:latest 4babushkin/otus-reddit:1.0
  ```
  ```docker
  docker push 4babushkin/otus-reddit:1.0
  ```
  
  [![](https://images.microbadger.com/badges/image/4babushkin/otus-reddit.svg)](http://microbadger.com/images/4babushkin/otus-reddit "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/4babushkin/otus-reddit.svg)](https://microbadger.com/images/4babushkin/otus-reddit "Get your own version badge on microbadger.com")


* Проверил запуск на локальной машине
  ```bash
    docker run --name reddit -d -p 9292:9292 4babushkin/otus-reddit:1.0
  ```

* Отсановить docker-machine `docker-machine rm docker-host`

## Задание со *
* Поднятие инстансов с помощью Terraform, их количество задается `count` в файле `terraform.tfvars`
    - Запуск `terraform apply` 
* Ansible. Несколько плейбуков с использованием динамического инвентори
  - Первый плейбук для установки Docker `install_docker.yml`
  - Второй реализован через роль `deploy` установка приложения
  - Запуск `ansible-playbook playbooks/site.yml`
* Packer: образ с докером `packer build packer/docker.json` 
  * Нагуглил роль `nickjj.docker` собрал образ испольуя ее; (устанвока роли `ansible-galaxy install nickjj.docker`)
 

# Lesson-14 HW Docker-1

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
* rm - удаляет контейнер; rmi - удаляет image
* `docker rm $(docker ps -a -q)` # удалит все незапущенные контейнеры
