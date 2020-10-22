// CArtAgO artifact code for project jcmrest

package coordination;

import cartago.*;

@ARTIFACT_INFO(outports = { @OUTPORT(name = "out-1") })

public class stepCounter extends Artifact {
    void init(int initialValue) {
        defineObsProperty("common_step", initialValue);
    }

    @OPERATION
    void incStepCounter(int oldValue) {
        ObsProperty prop = getObsProperty("common_step");
        if (prop.getValue(0).equals(oldValue)) {
            prop.updateValue(prop.intValue()+1);
            signal("tick");
        }
    }

    @OPERATION
    void resetStepCounter(int value) {
        ObsProperty prop = getObsProperty("common_step");
        prop.updateValue(value);
    }
}

