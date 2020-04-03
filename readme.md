JaCaMo team for [MAPC 2020](https://multiagentcontest.org/2020/)


# Running a team

Requirements:
- jdk >= 13

Execute `./gradlew run`, press enter to start the simulation, and see the execution on a [browser](http://127.0.0.1:8000).


# Configuring an Eclipse Project

Requirements:
- jdk >= 13
- Eclipse Java-EE or Committer

To add the project in your workspace, use the Eclipse menu `File|Import|Existing Gradle Project` and select the project directory.

Then
1. use gradle tasks to run the team, or
2. select and run class `runMAPC2020.Run`

# Running a team using Docker

Requirements:
- Docker
-
(no need to install java, gradle, jacamo, ... only Docker)

Run once:
```
docker volume create --name gradle-cache
```

Run the team (replace USERNAME with your username checking if .gradle/ location is correct):
```
docker run -ti --rm -u gradle -v gradle-cache:/home/USERNAME/.gradle -v "$PWD":/home/USERNAME/project -w /home/USERNAME/project -p 8000:8000 gradle:6.3.0-jdk13 gradle run
```
