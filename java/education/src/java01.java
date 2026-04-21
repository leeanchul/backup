
import java.util.Scanner;


public class java01 {

	public static void main(String[] args) {

        Scanner ac = new Scanner(System.in);
        String n= ac.next().toUpperCase();
       
        int b = ac.nextInt();
        int tmp = 1;
        int result = 0;
        
        for (int i = n.length() - 1; i >= 0; i--) {
            char c = n.charAt(i);
            if (c >= 'A' && c <= 'Z') {
                result += (c - 55) * tmp;
            } else {
                result += (c - 48) * tmp;
            }
            tmp *= b;
        }
        System.out.println(result);
			
		}
	}
		
