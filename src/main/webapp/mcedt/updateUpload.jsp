<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>

<%@ page errorPage="error.jsp" %>

<!DOCTYPE html>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html>
    <head>
        <jsp:include page="head-includes.jsp"/>
        <script language="javascript">
            function cancel(control) {
                if (control) {
                    control.disabled = true;
                }
                window.location.href = "update.do";
                return false;
            }

            function update(control) {
                if (control) {
                    control.disabled = true;
                }
                var form = $("form");
                form.submit();
                return true;
            }
        </script>


        <title>MCEDT: Update Upload</title>

        <base href="<%= request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/" %>">
    </head>

    <body>
    <div class="container-fluid">
        <div class="row-fluid">
            <h2>Update Upload</h2>

            <form action="${pageContext.request.contextPath}/mcedt/update" method="post" styleId="form"
                       enctype="multipart/form-data">

                <% 
    java.util.List<String> actionErrors = (java.util.List<String>) request.getAttribute("actionErrors");
    if (actionErrors != null && !actionErrors.isEmpty()) {
%>
    <div class="action-errors">
        <ul>
            <% for (String error : actionErrors) { %>
                <li><%= error %></li>
            <% } %>
        </ul>
    </div>
<% } %>

                <c:if test="${not empty savedMessage}">
                    <div class="messages">
                            ${savedMessage}
                    </div>
                </c:if>

            <input id="method" name="method" type="hidden"
                   value="addUpdateRequest"/>

            <div class="form-group">
                <label>Upload ID</label>
                <input type="text" name="resourceId" readonly="true"/>
            </div>

            <div class="form-group">
                <label>File Upload</label>
                <input type="file" name="content" id="content"/>
            </div>

            <div class="control-group" style="margin-top: 1em;">
                <div class="controls">
                    <button class="btn btn-primary" onclick="return update(this);">Update</button>
                    <button class="btn" onclick="return cancel(this);">Cancel</button>
                </div>
            </div>
            </form>
    </body>
</html>