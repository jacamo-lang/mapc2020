package mabOptimizer;

import java.util.ArrayList;
import java.util.Random;

public class EGreedyMAB extends MAB {
    private ArrayList<MABArm> arms = new ArrayList<MABArm>();
    private double epsilon;
    private double decayRate;
    private int roundRobinIndex = -1;
    private Random random;

    public EGreedyMAB(ArrayList<MABArm> arms, double epsilon, double decayRate, boolean roundRobin, Random random) {
        super(arms);
        this.epsilon = epsilon;
        this.decayRate = decayRate;
        this.arms = arms;
        this.random = random;
        if(roundRobin) {
            this.roundRobinIndex = arms.size() - 1;
        }
    }

    @Override
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

}
