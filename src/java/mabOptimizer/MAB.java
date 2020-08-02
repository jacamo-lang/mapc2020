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
public abstract class MAB {
    private ArrayList<MABArm> arms = new ArrayList<MABArm>();
    
    public MAB(ArrayList<MABArm> arms) {
        this.arms = arms;
    }
    
    abstract public String pullArm();
    
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
