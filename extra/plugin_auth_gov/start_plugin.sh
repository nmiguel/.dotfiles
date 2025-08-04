#!/bin/bash

sudo systemctl start pcscd.service
sudo systemctl status pcscd.service
java -jar plugin-autenticacao-gov.jar
