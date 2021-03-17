JaCaMo team for [MAPC 2020](https://multiagentcontest.org/2020/)


# Running a team

Requirements:
- jdk >= 13

# Running local server and client together

1. Edit the script `/clientconf/createFile.sh`, setting on both teams the `host` parameter to `localhost`, `password` to `1`, and set the parameter `username` to `agentA%d` and `agentB%d` on team A and B respectivelly. 
2. Execute the script to create the client configuration files.
3. Make sure the server is being launched by setting the instruction `Server.main(...)` at the file `src/java/runMAPC2020/Control.java`.
4. Execute the default strategy running `./gradlew run`, press enter to start the simulation, and see the execution on a [browser](http://127.0.0.1:8000). You can set another strategy giving arguments, for instance: `./gradlew run --args="src/jcm/individualist.jcm`

# Running for the competition (just client side)

1. Edit the script `/clientconf/createFile.sh`, setting on both teams configuration the `host`, `password`, and `username` that will be used for the competition (e.g.: `agentcontest1.in.tu-clausthal.de`, `some-password`, `agentJaCaMo_Builders%d`). In this case, you can set teamA to play on a server (e.g. `agentcontest1.in.tu-clausthal.de`) and team B to play on a second server (e.g. `agentcontest2.in.tu-clausthal.de`). 
2. Execute the script to create the client configuration files.
3. Make sure the server is NOT being launched removing/commenting the instruction `Server.main(...)` at the file `src/java/runMAPC2020/Control.java`.
4. Execute `./gradlew run --args="src/jcm/teamA.jcm` or `./gradlew run --args="src/jcm/teamB.jcm` according to the server.

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
  * Use the first argument to specify an JCM file (e.g.: `./gradlew run --args="src/jcm/donothing_X_donothing.jcm`.
  * Use the second argument to specify whether you want to open the standard browser automatically (e.g.: `./gradlew run --args="src/jcm/donothing_X_donothing.jcm browser` to open it. Use something else to do not open the browser `./gradlew run --args="src/jcm/donothing_X_donothing.jcm noBrowser`).

## Troubleshoot when using docker

* No X11 DISPLAY variable was set. Solution:
  * change `./logging.properties` file to use `handlers=java.util.logging.ConsoleHandler` and make sure no debug windows are activated in the `.jcm` file.
  * make sure in the `.jcm` the visual interface for local position system is off (`0`), which is the second parameter of `localPositionSystem.lps(_,0)`.

# Project structure
```
mapc2020/
        src/
            agt/ -- Jason Agents
                buildblock/ -- mid-level plans for assembling complex structures
                environment/ -- low-level bridges to artifacts
                exploration/ -- low-level helpers for gps facilities
                simulation/ -- low-level bridges for interacting with massim
                strategies/ -- top-level strategies
                tasks/ -- mid-level helpers for task accomplishment
                walking/ -- low-level helpers for walking
                agentBase.asl -- the base for top-level strategies
            env/ -- CArtAgO Artifacts
                connection/ -- artifacts to connect agents and the simulator
                coordination/ -- artifacts to coordinate agents
                localPositionSystem/ -- artifacts to provide gps facilities
            java/ -- Java supportive classes
                bb/ -- can be used to store beliefs of agents for tests
                jason/stdlib/ -- internal actions for mapc
                mabOptimizer/ -- libs for Multi Armed Bandit stochastic algorithm
                runMAPPC2020/ -- classes for launching the simulator and JaCaMo
                scenario/ -- classes for scenario interpretations
            jcm/ -- initialization scripts
            test/
                jacamo/ -- tests for jacamo systems
                    agt/ -- mapc tester agents folder
                    inc/ -- test helpers for mapc tester agents

```
# Understanding the dynamics behind this project

* [MAPC](https://multiagentcontest.org/) provides an environment which provides body representations for agents which walk on a 2 dimensional space and are expected to achieve given tasks.
* We play at the client side but while developing we are also able to launch the server side and do local simulations.
* The simulation run in steps and each agent has a timeout, i.e., a deadline to reply to the simulator a given action to the current step (default is 4 seconds).
* If no action is provided by a given agent it is counted as a missed step. For the qualification we cannot miss more than 30% of the steps on each round.
* Each round usually has 750 steps.
* The agents have to explore the area and map it to properly navigate and accomplish tasks.
* Tasks ask for delivering some structures composed by blocks (b0, b1 or b2) which must be attached to the agent that has accepted the task and must be delivered on goal areas. The blocks must be positioned exactly as specified by the task and only the agent must be on a goal square. And the given deadline (in steps) for the task must be respected in order to get a reward.
* Tasks rewards falls dramatically each step until they get their minimum reward. For instance, by default a single block task gives at least `1` point and a 2 blocks task gives `4` points.
* Normal terrains, `goal` areas, `dispensers` and `taskboards` are walkable, but `obstacles` or terrains occupied by agents/`entities` or `blocks` are not.
* To attach a block the agent must go to an adjacent position of a `dropped block` to attach it, or it can go to an adjacent position of a specific `dispenser` to request and attach it.
* The whole local simulation is composed by three rounds, the first starts with 15 agents and the other ones with 30 and 50 agents respectivelly.
** Currently, the strategy for the qualification is starting with 50 agents. In the first round, only 15 agents take place in the simulation which does not bring major problems.
** Notice that `src/agt/simulation` provides libraries to deal with the end of a round in order to clean agents' mids and artifacts.
* There are two teams (`a` and `b`). In most of our tests we are developing the team `a` and running against `b` composed by `do_nothing` agents, i.e., these agents just `skip` their actions every step.
* Default agents' identifications start with the word `agent`, followed by the team identification (`A` or `B`) and an unique number for each team starting from the number 1 (e.g.: agentA1, agentA2,... and, agentB1, agentB2,...)

# Developing new strategies

* Although we still have many work on low and mid-level libraries, we already have some base code which allows to focus more on top-level strategies.
* To create new strategies you can use `src/jcm/weak_individualistg.jcm` and `src/agt/strategies/weak_individualist.asl` as model, duplicating these file and changing the copy for your own purposes. This model agent already uses `src/agt/agentBase.asl` which provides exploration facilities, i.e., an empty new strategy (just including the `agentBase.asl` code) is already supposed to work well, but just doing the exploration.
* In your strategy you may find a good starting point to create a plan for `+task(T,D,R,REQs)` in order to define actions that your strategy will perform when the simulator announces a task.
* While launching, please, give some time to the system to create the agents and artifacts instances. After a few seconds, and no new messages are printed, just press ENTER to start the simulation.
* Running locally, open in your browser the address http://127.0.0.1:8000 to watch the simulation. You can also debug your agents at http://127.0.0.1:3272 and your artifacts at http://127.0.0.1:3273.

## Using artifacts

* We are creating the artifacts from `asl` files instead of `jcm`. To create new artifacts you may find interesting using the same model we have in `src/agt/environment` files. For instance, `artifact_eis.asl` shows how to create one artifact for each existing agent and `artifact_gps.asl` shows how to create a shared artifact.

# Server and clients setup

* The server setup is stated at `mapc2020/serverconf/` and client setups, which are the most important part for us, are stated at `mapc2020/clientconf/` folder.
* When running locally, our `json` configuration files on `mapc2020/clientconf/` are set to connect to the `localhost` machine. When qualifying or during matches we will need to set our agents to some given server.
** The script `createFiles.sh` helps to quickly create a set of configuration files, just edit the template inside of `createFiles.sh` and run it `$ ./createFiles.sh`.

# Using jason unit tests

1. Create an agent for testing your agent(s). You can use the default `src/test/jason/asl` folder (all agents in this folder are automatically launched in the test task).
2. Provide to your tester agent the testing facilities
 ```
{ include("$jasonJar/test/jason/inc/tester_agent.asl") }
 ```
3. Add to your test agent (eg.: `src/test/jason/asl/test_meeting.asl`) support to the agent it is going to test:
  ```
{ include("exploration/meeting.asl") }
  ```
4. The plans in which the label has the annotation `[test]` are automatically launched (e.g.: `@test_coord_same_position[test]`)
5. Run `./gradlew test` to check results. You can run `./gradlew test -i` to see more detailed messages or event `./gradlew test --debug` for a full debug

For instance, let us say tat `@test_coord_same_position` is as below:
```
@test_coord_same_position[test]
+!test_coord_same_position
    <-
    ?coord(0,0,0,0,[],L1);

    !assert_equals(61,.length(L1));

    .findall(p(X,Y),proof(X,Y),L0);

    .difference(L0,L1,DIFF);
    !assert_equals([],DIFF);
.
```
In the file `src/test/jason/asl/test_meeting.asl` we add some known facts. When running `./gradlew test`, it will launch this `[test]` plan and get from a rule `coord/6` which is provided by `exploration/meeting.asl` a list `L1`. From the known facts, we know that two perspectives from the same origin (0,0) have same view, so, they are sharing 61 elements, so we can assert it as done in `!assert_equals(61,.length(L1));`. Then since we previously know each coordinate they are sharing (which regards to vision(5), i.e., 5 squares in radius) we have also created proof facts that are being confronted with the result provided by `coord/6`. The difference from the proof and the result from `coord/6` must be an empty set! In this sense, we are testing in this plan the rule `coord/6` in the hypothetical case of two agents sharing the same position (0,0).

## Why it is important to create unit tests?

Tests are run every git push and can also be performed locally using `./gradlew test` or `gradle test`.
* When we have a plan being tested on every push we have the opportunity to be advised if some change has affected other parts of the system. It is specially effective when we have many developers working in the same project.
* Performing local tests may also be a more convenient and faster way to test new features. The local tests usually run faster than the simulation. It is also often hard to test from the simulation since usually we have to wait for agents to reach some specific condition in which some test is going to be performed. It takes time, needs focus of the developer and usually many .print/.log messages.


# Using a jacamo-web playgroung

We have a JCM using [jacamo-web](https://github.com/jacamo-lang/jacamo-web) which may be helpful for faster the development of new features and tests. Actually, since MAPC uses a simulator which can produce changes very fast, jacamo-web is not being shown a good development environment. For this reason, the playground proposes the use jacamo-web out of the simulation. It is useful since it allows to quickly make changes (even while running) and after it has some maturity we can move from player's code to a final agent code or a tester agent. The script `src/jcm/playground.jcm` just launches a jacamo-web environment with the agent `src/agt/player.asl`. For instance, if we want to test the rule `get_rotation` provided by `walking/rotate_jA_star.asl`.

```
{ include("test_walking_helpers.asl") }
{ include("walking/rotate_jA_star.asl") }

+!start
    <-
    -+myposition(0,0);
    -+origin(mymap);

    ?get_rotation(b(1,0,b0),b(0,1,b0),D0);
    .log(warning,"Rotate a block from 3 o'clock to 6 o'clock got ",D0);
.
```

* We can use jacamo-web command box to trigger the plan `!start` whenever we want to check the result.
* We can use jacamo-web to edit and reload the agent `player` with the new code to quickly try different possibilities.
* Since we don't have inputs from the simulation, it is often necessary to use some snapshot of the simulation like the one we have at `src/test/inc/test_walking.bb`.
* It is also often necessary to mock plans that triggers actions on the environment (the file `src/test/inc/test_walking_helpers.asl` has some examples of mocks at plan `!add_test_plans_do(MIN_I)`).

---
**WARNING:**  
* Unfortunately, jacamo-web is not updating agent's rules after hot-swapping the agent, instead it is necessary to manually kill/create the agent.
---
