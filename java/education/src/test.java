import java.util.Scanner;

public class test {
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
        StringBuilder sb = new StringBuilder();

        int T = sc.nextInt();

        for (int i = 0; i < T; i++) {
            int money = sc.nextInt();

            int q = money / 25;
            money %= 25;

            int d = money / 10;
            money %= 10;

            int n = money / 5;
            money %= 5;

            int p = money;

            sb.append(q)
              .append(" ")
              .append(d)
              .append(" ")
              .append(n)
              .append(" ")
              .append(p)
              .append("\n");
        }
        System.out.print(sb.toString());
  
	}

}
