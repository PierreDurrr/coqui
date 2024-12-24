#!/bin/bash

reset

echo -e "Compose down:"
sudo docker-compose down

echo -e "\n\nRemove physicsreplicatorai/coqui-tts:1.0 image:"
sudo docker rmi pierredurrr/coqui-tts:1.0

echo -e "\n\nRemove build log:"
rm build.txt

echo -e "\n\nBuild:"
sudo docker build -t pierredurrr/coqui-tts:1.0 . | tee build.txt
