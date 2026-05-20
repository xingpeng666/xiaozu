package com.minzu.servlet;

import com.minzu.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ReportServletTest extends BaseServletTest {

    private final ReportServlet servlet = new ReportServlet();

    @Test
    void doGet_notLoggedIn_redirectsToLogin() throws Exception {
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
        assertTrue(getRedirectUrl().contains("login"));
    }

    @Test
    void doGet_nonAdmin_redirectsToIndex() throws Exception {
        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        servlet.doGet(request, response);
        assertNotNull(getRedirectUrl());
    }

    @Test
    void doGet_admin_doesNotRedirect() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        servlet.doGet(request, response);

        assertNull(getRedirectUrl());
    }

    @Test
    void doPost_submitReport_success() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertUser(2, "2024002", "李四", "lisi", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "submit");
        request.setParameter("productId", "1");
        request.setParameter("reason", "虚假商品");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_submitReport_ownProduct_fails() throws Exception {
        insertUser(1, "2024001", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 1, 1, "iPhone 15", "5999.00", "ON_SALE");

        User user = createTestUser(1, "2024001", "张三", "zhangsan", "STUDENT", "ACTIVE");
        loginUser(user);
        request.setParameter("action", "submit");
        request.setParameter("productId", "1");
        request.setParameter("reason", "测试");
        servlet.doPost(request, response);

        assertEquals("不能举报自己的商品", session.getAttribute("errorMsg"));
    }

    @Test
    void doPost_takedown_adminCanTakedown() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertReport(1, 1, 2, "违规商品", "PENDING");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("action", "takedown");
        request.setParameter("productId", "1");
        request.setParameter("reportId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }

    @Test
    void doPost_dismiss_adminCanDismiss() throws Exception {
        insertUser(1, "2024001", "管理员", "admin", "hash", "ADMIN", "ACTIVE");
        insertUser(2, "2024002", "张三", "zhangsan", "hash", "STUDENT", "ACTIVE");
        insertCategory(1, "电子数码");
        insertProduct(1, 2, 1, "iPhone 15", "5999.00", "ON_SALE");
        insertReport(1, 1, 2, "违规商品", "PENDING");

        User admin = createTestUser(1, "2024001", "管理员", "admin", "ADMIN", "ACTIVE");
        loginUser(admin);
        request.setParameter("action", "dismiss");
        request.setParameter("reportId", "1");
        servlet.doPost(request, response);

        assertNotNull(getRedirectUrl());
    }
}
