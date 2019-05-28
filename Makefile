USER_NAME = 4babushkin

build: post comment ui prometheus mondodb_exporter cloudprober
push: push_comment push_post push_ui push_prometheus push_mondodb_exporter push_cloudprober

post: 
	cd src/post-py && bash docker_build.sh
comment: 
	cd src/comment && bash docker_build.sh
ui: 
	cd src/ui && bash docker_build.sh

prometheus:
	cd monitoring/prometheus && docker build -t ${USER_NAME}/prometheus .
mondodb_exporter:
	cd monitoring/mondodb_exporter && docker build -t ${USER_NAME}/mondodb_exporter .
cloudprober:
	cd monitoring/cloudprober && docker build -t ${USER_NAME}/cloudprober .


push_post:
	docker push ${USER_NAME}/post
push_comment:
	docker push ${USER_NAME}/comment
push_ui:
	docker push ${USER_NAME}/ui

push_prometheus:
	docker push ${USER_NAME}/prometheus
push_mondodb_exporter:
	docker push ${USER_NAME}/mondodb_exporter
push_cloudprober:
	docker push ${USER_NAME}/cloudprober
