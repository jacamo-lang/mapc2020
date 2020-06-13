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
- (no need to install java, gradle, jacamo, ... only Docker)

Run once (sudo - root privileges can be necessary):
```
docker volume create --name gradle-cache
```

Run the team (sudo - root privileges can be necessary):
```
docker run -ti --rm -u gradle -v gradle-cache:/home/gradle/.gradle -v "$PWD":/home/gradle/project -w /home/gradle/project -p 8000:8000 gradle:6.3.0-jdk13 ./gradlew run
```

# Additional running configurations
* To add addition configurations when running add `--args=` after `./gradlew run`.
  * Use the first argument to specify an JCM file (eg.: `./gradlew run --args="src/jcm/donothing_X_donothing.jcm`.
  * Use the second argument to specify whether you want to open the standard browser automatically (eg.: `./gradlew run --args="src/jcm/donothing_X_donothing.jcm browser` to open it. Use something else to do not open the browser `./gradlew run --args="src/jcm/donothing_X_donothing.jcm noBrowser`).
  * Use the third argument to specify whether you want to wait for an ENTER or not (eg.: `./gradlew run --args="src/jcm/donothing_X_donothing.jcm browser waitEnter` to wait. Use something else to do not wait `./gradlew run --args="src/jcm/donothing_X_donothing.jcm browser noWait`). PS.: Running on docker the `noWait` option may not work properly due to connection errors.

## Troubleshoot when using docker

* No X11 DISPLAY variable was set. Solution:
  * change `./logging.properties` file to use `handlers= java.util.logging.ConsoleHandler` and make sure no debug windows are activated in the `.jcm` file.
  * make sure in the `.jcm` the visual interface for local position system is off (`0`), which is the second parameter of `localPositionSystem.lps(_,0)`.
