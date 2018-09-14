# hadoop-distributed

Dockerfiles for the [`jaysong/hadoop`](https://hub.docker.com/r/jaysong/hadoop/)
Docker Hub images.

## Feature:

- Hadoop 2.9.1
- Mount points created at `HADOOP_CONF_DIR=/etc/hadoop`, `HADOOP_LOG_DIR=/var/log/hadoop`,
and `HADOOP_DATA_DIR=/data/hadoop`.

## How-To:

### Start a single-node pseudo distributed operation
`docker run -d -p 8088:8088 -p 19888:19888 hadoop`
