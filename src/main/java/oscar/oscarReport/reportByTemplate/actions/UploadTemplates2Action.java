//CHECKSTYLE:OFF
/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * <p>
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */

//Action that takes place when uploading an XML template file


/*
 * UploadTemplate.java
 *
 * Created on March 24/2007, 10:47 AM
 *
 */

package oscar.oscarReport.reportByTemplate.actions;


import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import oscar.oscarReport.reportByTemplate.ReportManager;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

public class UploadTemplates2Action extends ActionSupport {
    HttpServletRequest request = ServletActionContext.getRequest();
    HttpServletResponse response = ServletActionContext.getResponse();

    public String execute() {

        String roleName$ = request.getSession().getAttribute("userrole") + "," + request.getSession().getAttribute("user");
        if (!com.quatro.service.security.SecurityManager.hasPrivilege("_admin", roleName$) && !com.quatro.service.security.SecurityManager.hasPrivilege("_report", roleName$)) {
            throw new SecurityException("Insufficient Privileges");
        }

        String action = request.getParameter("action");
        String message = "Error: Improper request - Action param missing";
        String xml = "";
        try {
            byte[] bytes = Files.readAllBytes(templateFile.toPath());
            xml = new String(bytes);
        } catch (IOException ioe) {
            message = "Exception: File Not Found";
            MiscUtils.getLogger().error("Error", ioe);
        }
        ReportManager reportManager = new ReportManager();
        if (action.equals("add")) {
            message = reportManager.addTemplate(null, xml, LoggedInInfo.getLoggedInInfoFromSession(request));
        } else if (action.equals("edit")) {
            String templateId = request.getParameter("templateid");
            message = reportManager.updateTemplate(null, templateId, xml, LoggedInInfo.getLoggedInInfoFromSession(request));
        }
        request.setAttribute("message", message);
        request.setAttribute("action", action);
        request.setAttribute("templateid", request.getParameter("templateid"));
        request.setAttribute("opentext", request.getParameter("opentext"));
        return SUCCESS;
    }

    private File templateFile;

    public File getTemplateFile() {
        return templateFile;
    }

    public void setTemplateFile(File templateFile) {
        this.templateFile = templateFile;
    }
}
