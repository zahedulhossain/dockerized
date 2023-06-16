ARG ELASTICSEARCH_KIBANA_IMAGE_TAG=7.10.1

FROM docker.elastic.co/kibana/kibana:${ELASTICSEARCH_KIBANA_IMAGE_TAG}

ARG ELASTICSEARCH_CERTS_DIR=/usr/share/elasticsearch/config/certificates

LABEL maintainer="Zahedul Hossain <md.zahedulhossain@gmail.com>"

COPY ./.config/certs ${ELASTICSEARCH_CERTS_DIR}
