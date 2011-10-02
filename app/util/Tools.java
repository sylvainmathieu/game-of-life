package util;

import java.util.Random;

public class Tools {

	public static String randomString(int length) {
		String chars = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890";
		Random rand = new Random();
		String randomString = "";
		for(int i = 0; i < length; i++) {
			randomString += chars.charAt(rand.nextInt(chars.length()));
		}
		return randomString;
	}

}
