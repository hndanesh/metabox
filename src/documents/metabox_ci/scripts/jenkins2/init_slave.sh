DIR=$(dirname "$0")
NAME=${1:-metabox-default-slave}

echo "Running Swarm client from folder: $DIR"
java -jar "$DIR/swarm-client-3.5.jar" -name "$NAME" \
    -disableSslVerification \
    -master http://localhost:8082 \
    -username metabox \
    -password metabox \
    -labels metabox