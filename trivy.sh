#!/bin/bash

dockerImageName=${awk 'NR==1 {print$2' Dockerfile}
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache aquasec/trivy:0.17.2 -q image --exit-code 0 --severity CRITICAL --light $dockerImageName

   exit_code=$?
   echo "Exit code : $exit_code"

   if [[  "${exit_code}" == 1 ]]; then
      echo "Image scanning failed. Critical Vulenariblity found"
      exit 1;
   else
      echo "PASSED -- Trivy"
   fi;