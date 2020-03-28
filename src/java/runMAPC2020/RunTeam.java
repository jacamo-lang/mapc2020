package runMAPC2020;

public class RunTeam {
    public static void main (String[] args) {
        new Control().start(args[0], args.length>1 && args[1].equals("browser"));
    }
}
