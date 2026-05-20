package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class OfferServletTest extends BaseServletTest {

    private final OfferServlet servlet = new OfferServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_sentTab_showsSentOffers() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 1, 2, "5000.00", "PENDING");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("tab", "sent");
        servlet.doGet(request, response);

        List<?> offers = (List<?>) request.getAttribute("offerList");
        assertEquals(1, offers.size());
    }

    @Test
    void doGet_receivedTab_showsReceivedOffers() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("tab", "received");
        servlet.doGet(request, response);

        List<?> offers = (List<?>) request.getAttribute("offerList");
        assertEquals(1, offers.size());
    }

    @Test
    void doPost_createOffer_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "create");
        request.setParameter("productId", "1");
        request.setParameter("offerPrice", "5000");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_createOffer_ownProduct_fails() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "create");
        request.setParameter("productId", "1");
        request.setParameter("offerPrice", "5000");
        servlet.doPost(request, response);

        assertEquals("不能对自己的商品出价", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_acceptOffer_createsOrder() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");

        User seller = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(seller);
        request.setParameter("action", "accept");
        request.setParameter("offerId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_rejectOffer_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertOffer(1, 1, 2, 1, "5000.00", "PENDING");

        User seller = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(seller);
        request.setParameter("action", "reject");
        request.setParameter("offerId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
