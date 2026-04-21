import java.util.Scanner;

public class java2 {
    public static void main(String[] args) {
        Scanner ac = new Scanner(System.in);
        int n = ac.nextInt();
        int b = ac.nextInt();
        
        StringBuilder sb = new StringBuilder();
        
        while (n != 0) {
            int remainder = n % b;
            if (remainder < 10) {
                sb.append((char)(remainder + '0'));
            } else {
                sb.append((char)(remainder - 10 + 'A')); 
            }
            n /= b;
        }
        
        System.out.println(sb.reverse());
    }
}
