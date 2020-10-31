package runMAPC2020;

import java.util.Arrays;

public class RunTeam {
    public static void main (String[] args) {
        new Control().start(
                args[0], 
                args.length > 1 && Arrays.asList(args).contains("browser"),
                args.length > 1 && Arrays.asList(args).contains("autoRun")
        );
    }
}
