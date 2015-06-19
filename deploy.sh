#!/bin/bash -e

cd $(dirname $0)

. utils
. ../../environment

osc create -f - <<EOF
kind: List
apiVersion: v1beta3
items:
- kind: ReplicationController
  apiVersion: v1beta3
  metadata:
    name: broker
    labels:
      service: broker
      function: backend
  spec:
    replicas: 1
    selector:
      service: broker
      function: backend
    template:
      metadata:
        labels:
          service: broker
          function: backend
      spec:
        containers:
        - name: broker
          image: docker.io/cicddemo/amq:latest
          imagePullPolicy: IfNotPresent
          ports:
          - containerPort: 61616
          - containerPort: 8161
            name: jolokia
          env:
          - name: AMQ_USER
            value: admin
          - name: AMQ_PASSWORD
            value: admin
          - name: AMQ_TRANSPORTS
            value: openwire
          - name: AMQ_QUEUES
            value: bookings
          - name: ACTIVEMQ_OPTS
            value: -Dhawtio.authenticationEnabled=false

- kind: Service
  apiVersion: v1beta3
  metadata:
    name: broker
    labels:
      service: broker
      function: backend
  spec:
    ports:
    - port: 61616
    selector:
      service: broker
      function: backend
EOF
