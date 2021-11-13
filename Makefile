DOCKER_NETWORK = docker-hadoop_default
ENV_FILE = hadoop.env
current_branch := latest
TAG_PREFIX = xzcr/hadoop

export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

build:
	docker build -t ${TAG_PREFIX}-base:$(current_branch) ./base
	docker build -t ${TAG_PREFIX}-namenode:$(current_branch) ./namenode
	docker build -t ${TAG_PREFIX}-datanode:$(current_branch) ./datanode
	docker build -t ${TAG_PREFIX}-resourcemanager:$(current_branch) ./resourcemanager
	docker build -t ${TAG_PREFIX}-nodemanager:$(current_branch) ./nodemanager
	docker build -t ${TAG_PREFIX}-historyserver:$(current_branch) ./historyserver
	docker build -t ${TAG_PREFIX}-submit:$(current_branch) ./submit

wordcount:
	docker build -t hadoop-wordcount ./submit
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${TAG_PREFIX}-base:$(current_branch) hdfs dfs -mkdir -p /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${TAG_PREFIX}-base:$(current_branch) hdfs dfs -copyFromLocal -f /opt/hadoop-3.3.1/README.txt /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${TAG_PREFIX}-base:$(current_branch) hdfs dfs -cat /output/*
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${TAG_PREFIX}-base:$(current_branch) hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${TAG_PREFIX}-base:$(current_branch) hdfs dfs -rm -r /input
