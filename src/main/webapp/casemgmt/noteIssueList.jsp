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
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="org.oscarehr.casemgmt.web.formbeans.CaseManagementEntryFormBean, org.oscarehr.common.model.Facility" %>
<%@page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@page import="org.oscarehr.PMmodule.model.Program" %>
<%@page import="org.oscarehr.PMmodule.dao.ProgramDao" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@ include file="/casemgmt/taglibs.jsp" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String roleName$ = (String) session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed = true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_casemgmt.notes" rights="r" reverse="<%=true%>">
    <%authed = false; %>
    <%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_casemgmt.notes");%>
</security:oscarSec>
<%
    if (!authed) {
        return;
    }
%>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<%
    LoggedInInfo loggedInInfo73557 = LoggedInInfo.getLoggedInInfoFromSession(request);
    String noteIndex = "";
    String encSelect = "encTypeSelect";
    String demoNo = request.getParameter("demographicNo");
    String caseMgmtEntryFrm = "caseManagementEntryForm" + demoNo;
    CaseManagementEntryFormBean frm = (CaseManagementEntryFormBean) request.getAttribute("caseManagementEntryForm");
    if (frm == null) {
        frm = (CaseManagementEntryFormBean) session.getAttribute(caseMgmtEntryFrm);
        request.setAttribute("caseManagementEntryForm", frm);
    }
%>
<c:choose>
    <c:when test="${empty caseManagementEntryForm.caseNote.id}">
        <c:choose>
            <c:when test="${not empty param.newNoteIdx}">
                <c:set var="noteIndex" value="${param.newNoteIdx}" />
                <div id="sumary${param.newNoteIdx}">
                    <div id="observation${param.newNoteIdx}" style="float: right; margin-right: 3px;">
                </div>
            </c:when>
            <c:otherwise>
                <c:set var="noteIndex" value="0" />
                <div id="sumary0">
                    <div id="observation0" style="float: right; margin-right: 3px;">
                </div>
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:otherwise>
        <c:set var="noteIndex" value="${caseManagementEntryForm.caseNote.id}" />
        <div style="background-color: #CCCCFF;"
             id="sumary${caseManagementEntryForm.caseNote.id}">
            <div id="observation${caseManagementEntryForm.caseNote.id}" style="float: right; margin-right: 3px;">
            </div>
        </div>
    </c:otherwise>
</c:choose>
</div>

<div style="margin: 0 3px 0 0;"><span style="float: right;">
    <c:choose>
        <c:when test="${not empty ajaxsave}">
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.encounterDate.title"/>&nbsp;
            <span id="obs${caseManagementEntryForm.caseNote.id}">
                <fmt:formatDate value="${caseManagementEntryForm.caseNote.observation_date}" pattern="dd-MMM-yyyy H:mm"/>
            </span>&nbsp;
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.noteRev.title"/>
            <a href="#" onclick="return showHistory('${caseManagementEntryForm.caseNote.id}', event);">
                ${caseManagementEntryForm.caseNote.revision}
            </a>
        </c:when>
        <c:otherwise>
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.encounterDate.title"/>&nbsp;
            <img src="${ctx}/images/cal.gif" id="observationDate_cal" alt="calendar">&nbsp;
            <input type="text" id="observationDate" name="observation_date" ondblclick="this.value='';"
                   style="border: none; width: 140px;" readonly
                   value="<fmt:formatDate value="${caseManagementEntryForm.caseNote.observation_date}" pattern="dd-MMM-yyyy H:mm"/>">
            rev
            <a href="#" onclick="return showHistory('${caseManagementEntryForm.caseNote.id}', event);">
                ${caseManagementEntryForm.caseNote.revision}
            </a>
        </c:otherwise>
    </c:choose>    
</div>

<div style="margin-left: 3px;"><span style="float: left;">
<fmt:setBundle basename="oscarResources"/><fmt:message key="oscarEncounter.editors.title"/>:</span>
<c:choose>
    <c:when test="${newNote == 'false'}">
        <ul style="list-style: none inside none; margin: 0;">
            <c:forEach var="editor" items="${caseManagementEntryForm.caseNote.editors}" varStatus="status">
                <c:if test="${status.index % 2 == 0}">
                    <li>${editor.formattedName};
                </c:if>
                <c:if test="${status.index % 2 != 0}">
                    ${editor.formattedName}</li>
                </c:if>
            </c:forEach>
            <c:if test="${not empty caseManagementEntryForm.caseNote.editors and caseManagementEntryForm.caseNote.editors.size() % 2 == 1}">
                </li>
            </c:if>
        </ul>
    </c:when>
    <c:otherwise>
        <div style="margin: 0;">&nbsp;</div>
    </c:otherwise>
</c:choose>
</div>

<%
    Facility currentFacility = loggedInInfo73557.getCurrentFacility();
    String programId = (String) request.getSession().getAttribute("case_program_id");
    Program currentProgram = null;
    if (programId != null) {
        ProgramDao programDao = (ProgramDao) SpringUtils.getBean(ProgramDao.class);
        currentProgram = programDao.getProgram(Integer.valueOf(programId));
    }
    if (currentFacility.isEnableEncounterTime() || (currentProgram != null && currentProgram.getEnableEncounterTime())) {
%>
<div style="clear: right; margin: 0 30px 0 0; float: right;"><span>
    <c:choose>
        <c:when test="${not empty ajaxsave}">
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.encounterTime.title"/>:&nbsp;
            <span id="encTimeHr${caseManagementEntryForm.caseNote.id}">
                ${caseManagementEntryForm.caseNote.hourOfEncounterTime}
            </span>:
            <span id="encTimeMin${caseManagementEntryForm.caseNote.id}">
                ${caseManagementEntryForm.caseNote.minuteOfEncounterTime}
            </span>
        </c:when>
        <c:otherwise>
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.encounterTime.title"/>:&nbsp;
            <input type="text" tabindex="11" id="hourOfEncounterTime" name="hourOfEncounterTime" maxlength="2"
                   style="border: 1px; width: 20px; height: 12px;"
                   value="${caseManagementEntryForm.caseNote.hourOfEncounterTime}">&nbsp;<b>:</b>&nbsp;
            <input type="text" tabindex="12" id="minuteOfEncounterTime" name="minuteOfEncounterTime" maxlength="2"
                   style="border: 1px; width: 20px; height: 12px;"
                   value="${caseManagementEntryForm.caseNote.minuteOfEncounterTime}">
        </c:otherwise>
    </c:choose>    
</span></div>
<%}%>

<%
    if (currentFacility.isEnableEncounterTransportationTime() || (currentProgram != null && currentProgram.isEnableEncounterTransportationTime())) {
%>
<div style="clear: right; margin: 0 30px 0 0; float: right;"><span>
    <c:choose>
        <c:when test="${not empty ajaxsave}">
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.encounterTransportation.title"/>:&nbsp;
            <span id="encTransTimeHr${caseManagementEntryForm.caseNote.id}">
                ${caseManagementEntryForm.caseNote.hourOfEncTransportationTime}
            </span>:
            <span id="encTransTimeMin${caseManagementEntryForm.caseNote.id}">
                ${caseManagementEntryForm.caseNote.minuteOfEncTransportationTime}
            </span>
        </c:when>
        <c:otherwise>
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.encounterTransportation.title"/>:&nbsp;
            <input type="text" tabindex="13" id="hourOfEncTransportationTime" name="hourOfEncTransportationTime" maxlength="2"
                   style="border: 1px; width: 20px; height:12px;"
                   value="${caseManagementEntryForm.caseNote.hourOfEncTransportationTime}">&nbsp;<b>:</b>&nbsp;
            <input type="text" tabindex="14" id="minuteOfEncTransportationTime" name="minuteOfEncTransportationTime" maxlength="2"
                   style="border: 1px; width: 20px; height:12px;"
                   value="${caseManagementEntryForm.caseNote.minuteOfEncTransportationTime}">
        </c:otherwise>
    </c:choose>
    
</span></div>
<%}%>

<div id="current_note_addon"></div>

<%
    encSelect += noteIndex;
%>
<div style="clear: right; margin: 0 3px 0 0; float: right;">
    <fmt:setBundle basename="oscarResources"/><fmt:message key="oscarEncounter.encType.title"/>:&nbsp;
    <span id="encType<%=noteIndex%>">
        <c:choose>
            <c:when test="${empty ajaxsave}">
                <select id="${encSelect}" class="encTypeCombo" name="encounter_type">
                    <option value=""></option>
                    <option value="face to face encounter with client">
                        <fmt:setBundle basename="oscarResources"/>
                        <fmt:message key="oscarEncounter.faceToFaceEnc.title"/>
                    </option>
                    <option value="telephone encounter with client">
                        <fmt:setBundle basename="oscarResources"/>
                        <fmt:message key="oscarEncounter.telephoneEnc.title"/>
                    </option>
                    <option value="email encounter with client">
                        <fmt:setBundle basename="oscarResources"/>
                        <fmt:message key="oscarEncounter.emailEnc.title"/>
                    </option>
                    <option value="encounter without client">
                        <fmt:setBundle basename="oscarResources"/>
                        <fmt:message key="oscarEncounter.noClientEnc.title"/>
                    </option>
        
                    <c:if test="${loggedInInfo73557.currentFacility.enableGroupNotes}">
                        <option value="group face to face encounter">
                            <fmt:setBundle basename="oscarResources"/>
                            <fmt:message key="oscarEncounter.groupFaceEnc.title"/>
                        </option>
                        <option value="group telephone encounter">
                            <fmt:setBundle basename="oscarResources"/>
                            <fmt:message key="oscarEncounter.groupTelephoneEnc.title"/>
                        </option>
                        <option value="group encounter with client">
                            <fmt:setBundle basename="oscarResources"/>
                            <fmt:message key="oscarEncounter.emailEnc.title"/>
                        </option>
                        <option value="group encounter without group">
                            <fmt:setBundle basename="oscarResources"/>
                            <fmt:message key="oscarEncounter.groupNoClientEnc.title"/>
                        </option>
                    </c:if>
                </select>
            </c:when>
            <c:otherwise>
                "&quot;<c:out value="${caseManagementEntryForm.caseNote.encounter_type}"/>&quot;"
            </c:otherwise>
        </c:choose>        
</span></div>


<c:set var="numIssues" value="${fn:length(caseManagementEntryForm.caseNote.issues)}"/>

<c:if test="${numIssues > 0}">
    <div style="margin: 0px 0px 0px 3px;">
        <span style="float: left;">
            <fmt:setBundle basename="oscarResources"/>
            <fmt:message key="oscarEncounter.assignedIssues.title"/>
        </span>
        <ul style="float: left; list-style: circle inside; margin: 0px;">
            <c:forEach var="noteIssue" items="${caseManagementEntryForm.caseNote.issues}">
                <li><c:out value="${noteIssue.issue.description}"/></li>
            </c:forEach>
        </ul>
        <br style="clear: both;">
    </div>
</c:if>

<c:if test="${numIssues == 0}">
    <div style="margin: 0px;">
        <br style="clear: both;">
    </div>
</c:if>



<div id="noteIssues">
    <div id="noteIssues-resolved" style="margin: 0; background-color: #CCCCFF; display: none;">
        <b><fmt:setBundle basename="oscarResources"/><fmt:message key="oscarEncounter.referenceResolvedIssues.title"/></b>
        <% int countResolvedIssue = -1; %>
        <table id="setIssueList">
            <c:set var="countResolvedIssue" value="0"/>

<c:forEach var="issueCheckList" items="${caseManagementEntryForm.issueCheckList}" varStatus="status">
    <c:if test="${issueCheckList.issue.resolved == true}">
        <tr>
            <td style="width: 50%; background-color: #CCCCFF;">
                <c:set var="winame" value="window${issueCheckList.issueDisplay.description}"/>
                <c:set var="winame" value="${fn:replace(winame, ' ', '_')}" />
                <c:set var="winame" value="${fn:replace(winame, '/', '_')}" />
                <c:set var="winame" value="${fn:replace(winame, '*', '_')}" />
                
                <c:set var="submitString" value="this.form.method.value='issueChange'; this.form.lineId.value='${status.index}'; return ajaxUpdateIssues('issueChange', $('noteIssues').up().id);" />
                <c:set var="id" value="noteIssue${status.index}" />

                <c:set var="writeAccess" value="${issueCheckList.issueDisplay.writeAccess}" />
                <c:set var="disabled" value="${!writeAccess}" />

                <input type="checkbox" id="${id}" name="issueCheckList" property="checked" ${disabled ? 'disabled="disabled"' : ''}/>

                <a href="#" onclick="return displayIssue('${winame}');">
                    <c:out value="${issueCheckList.issueDisplay.description}" />
                </a>

                <c:if test="${issueCheckList.used == false}">
                    <c:set var="submitDelete" value="removeIssue('${winame}');document.forms['caseManagementEntryForm'].deleteId.value='${status.index}';return ajaxUpdateIssues('issueDelete', $('noteIssues').up().id);" />
                    &nbsp;
                    <a href="#" onclick="${submitDelete}">Delete</a>&nbsp;
                </c:if>

                <!-- change diagnosis button -->
                <c:set var="submitChange" value="return changeDiagnosisResolved('${status.index}');" />
                &nbsp;
                <a href="#" onclick="${submitChange}">Change</a>

                <div id="${winame}" style="margin-left: 20px; display: none;">
                    <div>
                        <div style="width: 50%; float: left; display: inline;">
                            <input type="radio" name="issueCheckList" property="issue.acute" value="true" onchange="${submitString}"> acute
                        </div>
                        <div style="width: 50%; float: left; display: inline; clear: right;">
                            <input type="radio" name="issueCheckList" property="issue.acute" value="false" onchange="${submitString}"> chronic
                        </div>
                        <div style="width: 50%; float: left; display: inline;">
                            <input type="radio" name="issueCheckList" property="issue.certain" value="true" ${disabled ? 'disabled="disabled"' : ''} onchange="${submitString}"> certain
                        </div>
                        <div style="width: 50%; float: left; display: inline; clear: right;">
                            <input type="radio" name="issueCheckList" property="issue.certain" value="false" ${disabled ? 'disabled="disabled"' : ''} onchange="${submitString}"> uncertain
                        </div>
                        <div style="width: 50%; float: left; display: inline;">
                            <input type="radio" name="issueCheckList" property="issue.major" value="true" ${disabled ? 'disabled="disabled"' : ''} onchange="${submitString}"> major
                        </div>
                        <div style="width: 50%; float: left; display: inline; clear: right;">
                            <input type="radio" name="issueCheckList" property="issue.major" value="false" ${disabled ? 'disabled="disabled"' : ''} onchange="${submitString}"> not major
                        </div>
                        <div style="width: 50%; float: left; display: inline;">
                            <input type="radio" name="issueCheckList" property="issue.resolved" value="true" onchange="${submitString}"> resolved
                        </div>
                        <div style="width: 50%; float: left; display: inline; clear: right;">
                            <input type="radio" name="issueCheckList" property="issue.resolved" value="false" onchange="${submitString}"> unresolved
                        </div>
                        <div style="text-align: center;">
                            <input type="text" name="issueCheckList" property="issueDisplay.role" size="10" ${disabled ? 'disabled="disabled"' : ''} />
                        </div>
                    </div>
                </div>
            </td>
        </tr>

        <c:set var="countResolvedIssue" value="${countResolvedIssue + 1}" />
    </c:if>
</c:forEach>
        </table>
    </div>

    <!-- end of div noteIssues-resolved -->

    <% int countUnresolvedIssue = -1; %>
    <div id="noteIssues-unresolved" style="margin: 0px; background-color: #CCCCFF; display: none;">
        <b><fmt:setBundle basename="oscarResources"/><fmt:message key="oscarEncounter.referenceUnresolvedIssues.title"/></b>

        <table id="setIssueList">
            <c:forEach var="issueCheckList" items="${caseManagementEntryForm.issueCheckList}" varStatus="status">
    <c:if test="${issueCheckList.issue.resolved == false}">
        
        <c:set var="winame" value="window${issueCheckList.issueDisplay.description}" />
        <c:set var="winame" value="${fn:replace(winame, ' ', '_')}" />
        <c:set var="winame" value="${fn:replace(winame, '/', '_')}" />
        <c:set var="winame" value="${fn:replace(winame, '*', '_')}" />
        <c:set var="winame" value="${fn:escapeXml(winame)}" />
        <c:set var="countUnresolvedIssue" value="${status.index + 1}" />

        <c:if test="${countUnresolvedIssue % 2 == 0}">
            <tr>
        </c:if>

        <td style="width: 50%; background-color: #CCCCFF;">
            <c:set var="submitString" value="this.form.method.value='issueChange'; this.form.lineId.value='${status.index}'; return ajaxUpdateIssues('issueChange', $('noteIssues').up().id);" />
            <c:set var="id" value="noteIssue${status.index}" />
            
            <c:set var="writeAccess" value="${issueCheckList.issueDisplay.writeAccess}" />
            <c:set var="disabled" value="${!writeAccess}" />

            <input type="checkbox" id="${id}" name="issueCheckList" value="${status.index}" ${disabled ? 'disabled' : ''} />
            
            <a href="#" onclick="return displayIssue('${winame}');">
                ${issueCheckList.issueDisplay.description}
            </a>

            <c:if test="${issueCheckList.issue.used == false}">
                <c:set var="submitDelete" value="removeIssue('${winame}');document.forms['caseManagementEntryForm'].deleteId.value='${status.index}';return ajaxUpdateIssues('issueDelete', $('noteIssues').up().id);" />
                &nbsp;
                <a href="#" onclick="${submitDelete}">Delete</a>
                &nbsp;
            </c:if>

            &nbsp;
            <a href="#" onclick="return changeDiagnosisUnresolved('${status.index}');">Change</a>

            <div id="${winame}" style="margin-left: 20px; display: none;">
                <div>
                    <div style="width: 50%; float: left; display: inline;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.acute" value="true" onchange="${submitString}"> Acute
                    </div>
                    <div style="width: 50%; float: left; display: inline; clear: right;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.acute" value="false" onchange="${submitString}"> Chronic
                    </div>
                    <div style="width: 50%; float: left; display: inline;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.certain" value="true" disabled="${disabled}" onchange="${submitString}"> Certain
                    </div>
                    <div style="width: 50%; float: left; display: inline; clear: right;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.certain" value="false" disabled="${disabled}" onchange="${submitString}"> Uncertain
                    </div>
                    <div style="width: 50%; float: left; display: inline;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.major" value="true" disabled="${disabled}" onchange="${submitString}"> Major
                    </div>
                    <div style="width: 50%; float: left; display: inline; clear: right;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.major" value="false" disabled="${disabled}" onchange="${submitString}"> Not Major
                    </div>
                    <div style="width: 50%; float: left; display: inline;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.resolved" value="true" onchange="${submitString}"> Resolved
                    </div>
                    <div style="width: 50%; float: left; display: inline; clear: right;">
                        <input type="radio" name="issueCheckList[${status.index}].issue.resolved" value="false" onchange="${submitString}"> Unresolved
                    </div>
                    <div style="text-align: center;">
                        <input type="text" name="issueCheckList[${status.index}].issueDisplay.role" size="10" disabled="${disabled}" />
                    </div>
                </div>
            </div>
        </td>

        <c:if test="${countUnresolvedIssue % 2 != 0}">
            </tr>
        </c:if>
        
    </c:if>
</c:forEach>
        </table>
    </div> <!-- end of div noteIssues-unresolved -->
</div>
<!-- end of div noteIssues -->

<div id='autosaveTime' class='sig' style='text-align:center; margin:0px;'></div>
<script type="text/javascript">

    //check to see if we need to update div containers to most recent note id
    //this happens only when we're called thru ajaxsave
    <c:if test="${not empty ajaxsave}">
    <script type="text/javascript">
        var origId = "${origNoteId}";
        var newId = "${ajaxsave}";
        var oldDiv;
        var newDiv;
        var prequel = ["n", "sig", "signed", "full", "bgColour", "print", "editWarn"];

        for (var idx = 0; idx < prequel.length; ++idx) {
            oldDiv = prequel[idx] + origId;
            newDiv = prequel[idx] + newId;
            if ($(oldDiv) != null)
                $(oldDiv).id = newDiv;
        }
        updatedNoteId = newId;

        // Assuming noteTxt comes from request attribute or is passed in a similar way
        var noteTxt = "${fn:escapeXml(noteTxt)}"; // Escape any special characters in noteTxt
        completeChangeToView(noteTxt, newId);

        if (origId.substr(0, 1) == "0") {
            $("nc" + origId).id = "nc" + numNotes;
            ++numNotes;
        }

        <c:if test="${not empty DateError}">
            alert("${DateError}");
        </c:if>
    </script>
</c:if>


    var c = "bgColour" + "<%=noteIndex%>";
    var txtStyles = $F(c).split(";");
    var txtColour = txtStyles[0].substr(txtStyles[0].indexOf("#"));
    var background = txtStyles[1].substr(txtStyles[1].indexOf("#"));
    var summary = "sumary" + "<%=noteIndex%>";

    if ($("observationDate") != null) {
        $("observationDate").style.color = txtColour;
        $("observationDate").style.backgroundColor = background;
    }
    $(summary).style.color = txtColour;
    $(summary).style.backgroundColor = background;

    if ($("toggleIssue") != null)
        $("toggleIssue").disabled = false;

    if (showIssue) {
        $("noteIssues-resolved").show();
        $("noteIssues-unresolved").show();
        for (var idx = 0; idx < expandedIssues.length; ++idx)
            displayIssue(expandedIssues[idx]);
    }

    //do we have a custom encounter type?  if so add an option to the encounter type select
    var encounterType = '${caseManagementEntryForm.caseNote.encounter_type}';
    var selectEnc = "<%=encSelect%>";

    if ($(selectEnc) != null) {

        if ($F(selectEnc) == "" && encounterType != "") {
            var select = document.getElementById(selectEnc);
            var newOption = document.createElement('option');
            newOption.text = encounterType;
            newOption.value = encounterType;

            try {
                select.add(newOption, null); // standards compliant
            } catch (ex) {
                select.add(newOption); // IE only            
            }

            select.selectedIndex = select.options.length - 1;
        }

        new Autocompleter.SelectBox(selectEnc);

    }


    //store observation date so we know if user changes it
    if ($("observationDate") != null) {
        origObservationDate = $("observationDate").value;

        //create calendar
        Calendar.setup({
            inputField: "observationDate",
            ifFormat: "%d-%b-%Y %H:%M ",
            showsTime: true,
            button: "observationDate_cal",
            singleClick: true,
            step: 1
        });
    }
</script>
</div>
