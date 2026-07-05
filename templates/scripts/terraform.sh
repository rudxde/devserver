#!/bin/bash

tfi () {
    terraform init $@
}

tfa () {
    terraform apply -refresh=false $@
}
tfar () {
    terraform apply $@
}
