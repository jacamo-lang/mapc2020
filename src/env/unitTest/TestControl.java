// CArtAgO artifact code for project jcmrest

package unitTest;

import cartago.*;

@ARTIFACT_INFO(outports = { @OUTPORT(name = "out-1") })

public class TestControl extends Artifact {
    void init(int initialValue) {

    }

    @OPERATION
    void exitWithError() {
        System.exit(1);
    }

}
