sudo docker volume create --name gradle-cache
sudo docker run -ti --rm -u gradle -v gradle-cache:/home/gradle/.gradle -v "$PWD":/home/gradle/project -w /home/gradle/project -p 8000:8000 gradle:6.3.0-jdk13 ./gradlew run
