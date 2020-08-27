package mabOptimizer;

import java.util.ArrayList;

public class UBCMAB extends MAB {
    private ArrayList<MABArm> arms = new ArrayList<MABArm>();
    
    public UBCMAB(ArrayList<MABArm> arms) {
        super(arms);
        this.arms = arms;
    }

    @Override
    public String pullArm() {
        MABArm bestArm = null;
        Integer bestArmIndex = null;
        int currentArmIndex = 0;
        for(MABArm arm: this.arms) {
            if(bestArm == null || isBetter(arm, bestArm, currentArmIndex, bestArmIndex)) {
                bestArm = arm;
                bestArmIndex = currentArmIndex;
            }
            currentArmIndex++;
        }
        return bestArm.getName();
    }
    
    public boolean isBetter(MABArm thisArm, MABArm otherArm, int thisIndex, int otherIndex) {
        int numberOfAllPulls = this.getFrequencies().stream().mapToInt(a -> a).sum();
        if (this.getFrequencies().get(thisIndex) == 0) {
            return true;
        }
        double thisFrequency = this.getFrequencies().get(thisIndex);
        double otherFrequency = this.getFrequencies().get(otherIndex);
        double thisArmScore = thisArm.getAverage() + Math.sqrt(2 * Math.log(numberOfAllPulls) / thisFrequency);
        double otherArmScore = otherArm.getAverage() + Math.sqrt(2 * Math.log(numberOfAllPulls) / otherFrequency);
        return thisArmScore > otherArmScore;
    }
}
