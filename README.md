# 4babushkin_microservices
4babushkin microservices repository

# Lesson-25 HW kubernetes-1
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=kubernetes-1)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание 

* Выполнил [Туториал Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

* Проверил что поды создаются по созданным  deployment-ам (ui, post, mongo, comment)
```bash
▶ kubectl apply -f reddit 
deployment.apps/comment-deployment created
deployment.apps/mongo-deployment created
deployment.apps/post-deployment created
deployment.apps/ui-deployment created

▶ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
busybox-bd8fb7cbd-gxq79               1/1     Running   0          27m
comment-deployment-55dd6c56b6-rzgxf   1/1     Running   0          2m5s
mongo-deployment-6895dffdf4-hhr9p     1/1     Running   0          2m5s
nginx-dbddb74b8-vsxwg                 1/1     Running   0          23m
post-deployment-54b547d9bb-qkdr7      1/1     Running   0          2m5s
ui-deployment-54cf59dcf8-bqgm9        1/1     Running   0          2m5s
untrusted                             1/1     Running   0          15m

```


# Lesson-23 HW logging-1
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=logging-1)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание 

* Запуск докер машины `start_docker_machine_logging`
* Создадал отдельный compose-файл для нашей системы логирования - `docker/docker-compose-logging.yml` который включает в себя 3 осовных компонента: 
    - ElasticSearch (TSDB и поисковый движок для хранения данных)
    - Fluentd (для агрегации и трансформации данных)
    - Kibana (для визуализации) (kibana слушает на порту 5601)
* Настроил и соберал docker image для fluentd
    - что бы собрать `make fluentd`

* В Fluentd настроен парсинг структурированных логов из сервиса Post
* В Fluentd настроен парсинг неструктурированных логов из сервиса UI

Что бы собрать нужные образы делаем `make hw23`

Запуск `docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d`

## Задание со *
* Настроил fluentd для разбора еще одого формата логов



# Lesson-21 HW monitoring-2
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=monitoring-2)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание 

* Создадим  **docker-host** `start_docker_machine.sh`

* Все правила мониторинга для gcp firewall
```
gcloud compute firewall-rules create grafana-default --allow tcp:3000
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
gcloud compute firewall-rules create cloudprober-default --allow tcp:9313
gcloud compute firewall-rules create prometheus-alertmanager --allow tcp:9093
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
```

* собрать образы
  ```bash
  make
  ```
* запушить образы в [DockerHub](https://hub.docker.com/u/4babushkin)
  ```bash
  make push
  ```

* запустить приложение через `docker-compose` docker/docker-compose.yml
  ```bash
  docker-compose up -d 
  ```
* запустить мониторинг и алерты через `docker-compose` docker/docker-compose-monitoring.yml
  ```bash
  docker-compose -f docker-compose-monitoring.yml up -d
  ```
  * если остановить только один сервис `docker-compose -f docker-compose-monitoring.yml down grafana`
  * если запустить только один сервис `docker-compose -f docker-compose-monitoring.yml up -d grafana`

**[сайт Grafana](https://grafana.com/dashboards)**

* Настроен сбор метрик докера с помощью [cAdvisor](https://github.com/google/cadvisor)
* Подняты [Grafana](https://grafana.com/dashboards) и [AlertManager](https://prometheus.io/docs/alerting/alertmanager/)
* Настроены дашборды для сбора метрик приложения и бизнес метрик
* Настроены алерты на остановку сервисов
* Настроил интеграцию  тестовым Slack-чатом `https://devops-team-otus.slack.com/messages/CGZ9TTVC4`
  

## Задание со *
* Доработал [Makefile](Makefile)
* [В Docker в экспериментальном режиме реализована отдача метрик в формате
Prometheus](https://docs.docker.com/config/thirdparty/prometheus/) 
   * 1) создадим фаил /etc/docker/daemon.json 
      ```json
      {
        "metrics-addr" : "0.0.0.0:9323",
        "experimental" : true
      }
      ```
    * 2) в prometheus.yml добавим таргет
      ```yml
       - job_name: 'docker'
         # metrics_path defaults to '/metrics'
         # scheme defaults to 'http'.
         static_configs:
           - targets: ['10.132.0.42:9323']
      ```
    https://medium.com/lucjuggery/docker-daemon-metrics-in-prometheus-7c359c7ff550

# Lesson-20 HW monitoring-1
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=monitoring-1)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание
Создадим правило фаервола для Prometheus и Puma
```bash
$ gcloud compute firewall-rules create prometheus-default --allow tcp:9090
$ gcloud compute firewall-rules create puma-default --allow tcp:9292
```
Создадим  **docker-host** `start_docker_machine.sh`

Запуск Prometheus
```docker
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
```

Конфигурация
  * В директории monitoring/prometheus создайте файл `prometheus.yml` c [настройками](https://gist.githubusercontent.com/Nklya/bfe2d817f72bc6376fb7d05507e97a1d/raw/9de77435fd7cb626767f358a488d5346ca7f3a74/prometheus.yml) 

В директории prometheus собираем Docker образ:

```bash
$ export USER_NAME=4babushkin
$ docker build -t $USER_NAME/prometheus .
```
Соберем images при помощи скриптов `docker_build.sh` в директории каждого сервиса

```bash
for i in post-py ui comment; do cd src/$i; bash docker_build.sh; cd -; done
```

Будем поднимать наш Prometheus совместно с микросервисами. `docker/docker-compose.yml` 
 ```bash
 docker-compose up -d
 ```

## Задание со * #1
* Для мониторинга mongodb использую [percona/mongodb_exporter](https://github.com/percona/mongodb_exporter) Based on MongoDB exporter by David Cuadrado (@dcu), but forked for full sharded support and structure changes.
* [По подобию собираю образ mongodb_exporter, чутка допилив](https://github.com/percona/mongodb_exporter/blob/master/Dockerfile) /monitoring/mondodb_exporter/
## Задание со * #2

Мониторинг сервисов с помощью Cloudprober

/monitoring/cloudprober/Dockerfile

- http://<ip_address>:9313/status
- http://<ip_address>:9313/metrics

Информация 
* https://cloudprober.org/getting-started/
* https://medium.com/google-cloud/cloudprober-1c16b2d05835

## Просто так
  * Добавил мониторинг cAdvisor - собирает метрики хостов и контейнеров

## Задание со * #3
* Создал Makefile который умеет собирать и пушить образы на [DockerHub](https://hub.docker.com/u/4babushkin)
    - `make` или `make build` - просто собирает образы
    - `make push` - отправляет в DockerHub

[DockerHub](https://hub.docker.com/u/4babushkin)
```
4babushkin/cloudprober        latest    d472f7285c02    2 minutes ago    26.5MB
4babushkin/prometheus         latest    df84ec07e2f1    2 hours ago      121MB
4babushkin/ui                 latest    4acf7635e929    2 hours ago      235MB
4babushkin/comment            latest    0b04a45160eb    2 hours ago      232MB
4babushkin/post               latest    256fde96d531    2 hours ago      116MB
4babushkin/mondodb_exporter   latest    aae1c6adc1ba    5 hours ago      16.7MB
```



# Lesson-19 HW gitlab-ci-1
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=gitlab-ci-1)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)


### Можно создать виртуальную машину через docker-machine 
```bash
#!/bin/bash
export GOOGLE_PROJECT=docker-239201
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-disk-size 60 \
--google-zone europe-west1-d \
gitlab-ci
```
 добавить правила в фаервол
```bash
#!/bin/bash
gcloud compute firewall-rules create gitlab-ci\
 --allow tcp:80,tcp:443 \
 --target-tags=docker-machine \
 --description="gitlab-ci connections http & https" \
 --direction=INGRESS
 ```
Что бы подключить docker-machine к созданному инстансу выполняем 

```bash
docker-machine create --driver generic --generic-ip-address=35.233.42.177 --generic-ssh-key ~/.ssh/appuser --generic-ssh-user=appuser gitlab-ci

eval $(docker-machine env gitlab-ci)
```
изменнить ip в файле `gitlab-ci/docker-compose.yml` на внешний gitlab-ci инстанса

`docker-compose up -d`

### Я автоматизировал все через terraform
`terraform apply terraform/`

Создает инстанс, устанаваливает docker и запускает docker-compose.yml с запуском Gitlab 

* Произвел настройку GitLab, создал группу и проект;
* Зарегистрировал раннер
    * Что такое `.gitlab-ci.yaml`.  Это обычный yaml файл, который содержит инструкции для раннера, а именно:
      * из какого docker образа собирать контейнер,
      * какие переменные окружения установить,
      * в какой последовательности запускать шаги,
      * описание каждого шага.

## Задание со *
* Поднимает инстанс для для запуска контейнеров reddit `terraform apply terraform-reddit/`
* В шаг build добавил сборку контейнера с приложением reddit. Пушить на DockerHub ([описано тут](https://angristan.xyz/build-push-docker-images-gitlab-ci/) )
 
 **Деплой сделать не успел**


https://docs.gitlab.com/ee/ci/docker/using_docker_build.html 



* Запуск ранера осуществляется через ansible, с проверкой установленных компонентов и проверкой запущен ли ранер
* зависимости ролей Ansible Galaxy `ansible-galaxy install -r environments/stage/requirements.yml`
* Старт `ansible-playbook playbooks/runner.yml`

( Запускать gitlab-runner надо с --docker-privileged иначе runer не видет docker

```bash
docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://35.241.141.247/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-privileged \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --tag-list "linux,xenial,ubuntu,docker" \
  --run-untagged="true" \
  --locked="false" \
```
)

что нужно почитать 
[АВТОМАТИЧЕСКОЕ МАСШТАБИРОВАНИЕ НЕПРЕРЫВНОГО РАЗВЕРТЫВАНИЯ GITLAB С ПОМОЩЬЮ GITLAB RUNNER](https://www.8host.com/blog/avtomaticheskoe-masshtabirovanie-nepreryvnogo-razvertyvaniya-gitlab-s-pomoshhyu-gitlab-runner/)

Настроил интеграцию Pipeline с тестовым Slack-чатом

`https://devops-team-otus.slack.com/messages/CGZ9TTVC4`


# Lesson-17 HW Docker-4
[![Build Status](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices.svg?branch=docker-4)](https://travis-ci.com/otus-devops-2019-02/4babushkin_microservices)

## Основное задание
Запустим контейнер с использованием none-драйвера.
> docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
```cmd
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

Запустим контейнер в сетевом пространстве docker-хоста
> docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
```cmd
docker0   Link encap:Ethernet  HWaddr 02:42:E0:C3:43:A5  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:15  
          inet addr:10.132.0.21  Bcast:10.132.0.21  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:15%32692/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:3617 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3125 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:72891843 (69.5 MiB)  TX bytes:348718 (340.5 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32692/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
Запустим несколько раз (2-4)
> docker run --network host -d nginx

Видим что стартует только один котнейнер, потому что порт занят

На docker-host машине выполните команду:
> sudo ln -s /var/run/docker/netns /var/run/netns

Теперь вы можете просматривать существующие в данный момент net-namespaces с помощью команды:
> sudo ip netns

* Bridge network driver
  
Создадим docker-сети
> docker network create back_net --subnet=10.0.2.0/24

> docker network create front_net --subnet=10.0.1.0/24

```docker
docker run -d --network=front_net -p 9292:9292 --name ui 4babushkin/ui:3.0 && \
docker run -d --network=back_net --name comment 4babushkin/comment:1.0 && \
docker run -d --network=back_net --name post 4babushkin/post:1.0 && \
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```
Docker при инициализации контейнера может подключить к нему только 1
сеть. Поэтому нужно поместить контейнеры post и comment в обе сети
```docker
docker network connect front_net post
docker network connect front_net comment
```

Остановим старые копии контейнеров
> docker kill $(docker ps -q)

* Docker-compose
  
 Установка Docker-compose в ubuntu & debian
 ```bash
 sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 ```
```bash
export USERNAME=4babushkin
docker-compose up -d
docker-compose ps
```

1) Имя проекта можно задать через через параметр `container_name` в docker-compose.yml
   ```yaml
   container_name: post_db_name
   ```

2) Имя проекта можно задать через через параметр `project_name` в docker-compose.yml
   ```yaml
   project_name: project_name
   ```
3) добавить переменную COMPOSE_PROJECT_NAME=project_name
4) Еще можно запутить с ключем -p `docker-compose -p project_name up -d`


## Задание со *
* Что бы менять код без пересборки надо каким то образом наш код передать на хостовую машину
* 1) можно склонировать с Git `git clone -b docker-4 https://github.com/otus-devops-2019-02/4babushkin_microservices.git`
* Запуск `docker-compose -f docker-compose.override.example.yml up -d`

https://devilbox.readthedocs.io/en/latest/configuration-files/docker-compose-override-yml.html




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
