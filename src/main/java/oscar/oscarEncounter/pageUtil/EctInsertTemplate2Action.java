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

package oscar.oscarEncounter.pageUtil;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.oscarehr.common.dao.EncounterTemplateDao;
import org.oscarehr.common.model.EncounterTemplate;
import org.oscarehr.util.SpringUtils;

import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.ServletActionContext;

public final class EctInsertTemplate2Action extends ActionSupport {
    HttpServletRequest request = ServletActionContext.getRequest();
    HttpServletResponse response = ServletActionContext.getResponse();


    public String execute() throws Exception {
        String templateName = request.getParameter("templateName");

        EncounterTemplateDao dao = SpringUtils.getBean(EncounterTemplateDao.class);
        EncounterTemplate t = dao.find(templateName);

        if (t != null) {
            String encounterTmpValue = t.getEncounterTemplateValue();

            encounterTmpValue = encounterTmpValue.replaceAll("\\\\", "\\\\u005C"); // replace \ with unicode equiv.
            encounterTmpValue = encounterTmpValue.replaceAll("\"", "\\\\u0022"); // replace " with unicode equiv.
            encounterTmpValue = encounterTmpValue.replaceAll("'", "\\\\u0027"); // replace ' with unicode equiv.
            encounterTmpValue = encounterTmpValue.replaceAll(">", "\\\\u003E");
            encounterTmpValue = encounterTmpValue.replaceAll("<", "\\\\u003C");
            encounterTmpValue = encounterTmpValue.replaceAll("\n", "\\\\u000A");
            encounterTmpValue = encounterTmpValue.replaceAll("\r", "\\\\u000D");
            request.setAttribute("templateValue", encounterTmpValue);
        }

        String version = request.getParameter("version");
        if (version != null && version.equals("2")) {
            return "success2";
        } else {
            return SUCCESS;
        }

    }
}
