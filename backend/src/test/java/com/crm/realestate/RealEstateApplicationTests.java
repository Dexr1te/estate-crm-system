package com.crm.realestate;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * The cheapest thing that catches a broken bean wiring: if the context cannot be built, every
 * other test in the suite fails for reasons that are much harder to read than this one.
 */
@SpringBootTest
class RealEstateApplicationTests {

    @Test
    @DisplayName("the application context starts")
    void contextLoads() {
    }

}
