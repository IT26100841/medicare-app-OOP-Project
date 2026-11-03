<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.medicare.model.*,com.medicare.service.*,com.medicare.factory.DAOFactory,com.medicare.util.*,java.util.*,java.time.*" %>
<% request.setAttribute("pageTitle","Notifications");request.setAttribute("nav","notifications"); %>
<%@ include file="/WEB-INF/views/head.jspf" %>

<div class="page-heading"><div><div class="eyebrow">WORKSPACE UPDATES</div><h1>Notifications</h1><p>Saved messages and reminders in the active storage backend.</p></div><div class="heading-actions"></div></div><section class="panel"><div class="panel-body"><% List<Notification> notifications=DAOFactory.getNotificationDAO().getAllNotifications();for(Notification n:notifications){ %><div class="schedule-item"><%= UI.icon("calendar") %><div><strong><%= UI.e(UI.patient(n.getPatientId())) %></strong><p><%= UI.e(n.getMessage()) %></p><small class="muted"><%= UI.e(n.getDate()) %></small></div></div><% }if(notifications.isEmpty()){ %><div class="empty-state"><div class="empty-icon"><%= UI.icon("file") %></div><h3>All caught up.</h3><p>There are no saved notifications in this workspace.</p></div><% } %></div></section>
<%@ include file="/WEB-INF/views/foot.jspf" %>
