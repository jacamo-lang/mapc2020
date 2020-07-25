package mabOptimizer;

import java.util.ArrayList;
import java.util.Random;

/**
 * Implements a Multi-Armed Bandit (MAB) for dynamic optimization/reinforcement learning
 * Example use case:
 *   Agents can use different variants of path-finding algorithms.
 *   It may not be clear which algorithm is the best.
 *   The MAB can maintain a list of the algorithm and systematically execute the one that, given the information
 *   that has been collected so far, is most likely to be best (and do the occasional exploration).
 * More about MAB: https://towardsdatascience.com/solving-the-multi-armed-bandit-problem-b72de40db97c
 * @author Timotheus Kampik
 *
 */
public class MAB {
    private ArrayList<MABArm> arms = new ArrayList<MABArm>();
    private double epsilon;
    private double decayRate;
    private int roundRobinIndex = -1;
    private Random random;
    
    public MAB(ArrayList<MABArm> arms, double epsilon, double decayRate, boolean roundRobin, Random random) {
        this.epsilon = epsilon;
        this.decayRate = decayRate;
        this.arms = arms;
        this.random = random;
        if(roundRobin) {
            this.roundRobinIndex = arms.size() - 1;
        }
    }
    
    public String pullArm() {
        MABArm bestArm = null;
        if(this.roundRobinIndex >= 0) {
            String bestArmName = this.arms.get(roundRobinIndex).getName();
            this.roundRobinIndex--;
            return bestArmName;
        }
        if(this.epsilon > random.nextDouble()) {
            return this.arms.get(random.nextInt(this.arms.size())).getName();
        }
        for(MABArm arm: this.arms) {
            if(bestArm == null || arm.getAverage() > bestArm.getAverage()) {
                bestArm = arm;
            }
        }
        this.epsilon = this.epsilon * (1 - this.decayRate);
        return bestArm.getName();
    }
    
    public void setReward(String armName, double reward) {
        for(MABArm arm: this.arms) {
            if(arm.getName().equals(armName)) {
                arm.pull(reward);
                break;
            }
        }
    }
    
    public ArrayList<Integer> getFrequencies() {
        ArrayList<Integer> frequencies = new ArrayList<Integer>();
        for(MABArm arm: this.arms) {
            frequencies.add(arm.getRewardHistory().size());
        }
        return frequencies;
    }
    
    
}
