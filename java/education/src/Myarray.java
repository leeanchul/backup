
public class Myarray {

	int[] array;
	int count;
	
	public Myarray() {
		array=new int[10];
		count=0;
	}
	
	public Myarray(int size) {
		array=new int[size];
		count=0;
	}
	
	public int getSize() {
		return count;
	}
	
	public void add(int item) {
		array[count]=item;
		count++;
	}
}
