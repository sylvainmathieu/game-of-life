import org.junit.*;

import java.util.*;
import play.test.*;
import util.Tools;
import models.*;

public class BasicTest extends UnitTest {

    @Test
    public void aVeryImportantThingToTest() {
        assertEquals(2, 1 + 1);
    }


    @Test
    public void testRandomString() {
    	for(int i = 0; i < 1000; i++) {
    		assertEquals(6, Tools.randomString(6).length());
    	}
    }

}
