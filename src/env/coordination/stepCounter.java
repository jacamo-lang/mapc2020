// CArtAgO artifact code for project jcmrest

package coordination;

import cartago.*;

@ARTIFACT_INFO(outports = { @OUTPORT(name = "out-1") })

public class stepCounter extends Artifact {
    void init(int initialValue) {
        defineObsProperty("common_step", initialValue, System.currentTimeMillis());
    }

    @OPERATION
    void incStepCounter(int oldValue) {
        ObsProperty prop = getObsProperty("common_step");
        if (prop.getValue(0).equals(oldValue)) {
            prop.updateValues(prop.intValue()+1, System.currentTimeMillis());
            signal("tick");
        }
    }

    @OPERATION
    void resetStepCounter(int value) {
        ObsProperty prop = getObsProperty("common_step");
        prop.updateValues(value, System.currentTimeMillis());
    }
}

