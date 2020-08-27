package mabOptimizer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

public class MABSimulator {
    
    private static ArrayList<String> armNames = new ArrayList<String>();
    private static ArrayList<Double> armPerformance = new ArrayList<Double>();
    private static ArrayList<Integer> armLog = new ArrayList<Integer>();
    static Random random = new Random();
    
    static double pullArm(String armName) {
        return armPerformance.get(armNames.indexOf(armName)) + (random.nextDouble() - 0.5) * 10;
    }
    
    public static void main(String[] args){
        random.setSeed(10);
        armNames.add("a");
        armNames.add("b");
        armNames.add("c");
        armNames.add("d");
        armNames.add("e");
        // the bandit does not "know" the average rewards
        // (and also not the random reward determination function)
        armPerformance.add(1d);
        armPerformance.add(2d);
        armPerformance.add(3d);
        armPerformance.add(4d);
        armPerformance.add(5d);
        //
        ArrayList<MABArm> arms = new ArrayList<MABArm>(Arrays.asList(
                new MABArm("a"),
                new MABArm("b"),
                new MABArm("c"),
                new MABArm("d"),
                new MABArm("e")));
        //EGreedyMAB bandit = new EGreedyMAB(arms, 0.2, 0.1, true, random);
        UBCMAB bandit = new UBCMAB(arms);
        armLog = new ArrayList<Integer>(Arrays.asList(0, 0, 0, 0, 0));
        for(int i = 0; i < 100; i++) {
            String armName = bandit.pullArm();
            bandit.setReward(armName, pullArm(armName));
            int armIndex = armNames.indexOf(armName);
            armLog.set(armIndex, armLog.get(armIndex) + 1);
        }
        System.out.println(armLog);
    }
    
}
