package mabOptimizer;

import java.util.ArrayList;

/**
 * Multi-armed bandit arm that maintains a list of its previous rewards
 * @author Timotheus Kampik
 *
 */
public class MABArm {
    private String name;
    private ArrayList<Double> rewardHistory = new ArrayList<Double>();
    private double average;
    
    public MABArm(String name, ArrayList<Double> rewardHistory) {
        this.name = name;
        this.rewardHistory = rewardHistory;
        this.updateAverage();
    }
    
    public MABArm(String name) {
        this.name = name;
        this.average = 0;
    }
    
    public void pull(double reward) {
        rewardHistory.add(reward);
        this.updateAverage();
    }
    
    void updateAverage() {
        this.average = this.rewardHistory.stream().mapToDouble(a -> a).sum();
    }
    
    public String getName() {
        return this.name;
    }
    
    public double getAverage() {
        return this.average;
    }
    
    public ArrayList<Double> getRewardHistory() {
        return this.rewardHistory;
    }
    
}
