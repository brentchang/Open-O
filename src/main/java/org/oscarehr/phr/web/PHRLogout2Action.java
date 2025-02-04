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

package org.oscarehr.phr.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.dao.ProviderPreferenceDao;
import org.oscarehr.common.model.ProviderPreference;
import org.oscarehr.myoscar.utils.MyOscarLoggedInInfo;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.ServletActionContext;

public class PHRLogout2Action extends ActionSupport {
    HttpServletRequest request = ServletActionContext.getRequest();
    HttpServletResponse response = ServletActionContext.getResponse();

    private static Logger log = MiscUtils.getLogger();

    public PHRLogout2Action() {
    }

    public String execute() throws Exception {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String providerNo = loggedInInfo.getLoggedInProviderNo();

        HttpSession session = request.getSession();
        MyOscarLoggedInInfo.setLoggedInInfo(session, null);

        clearSavedMyOscarPassword(providerNo);

        String forwardTo = request.getParameter("forwardto");
        return forwardTo;
    }

    private void clearSavedMyOscarPassword(String providerNo) {
        try {
            ProviderPreferenceDao providerPreferenceDao = (ProviderPreferenceDao) SpringUtils.getBean(ProviderPreferenceDao.class);
            ProviderPreference providerPreference = providerPreferenceDao.find(providerNo);
            if (providerPreference.getEncryptedMyOscarPassword() != null) {
                providerPreference.setEncryptedMyOscarPassword(null);
                providerPreferenceDao.merge(providerPreference);
            }
        } catch (Exception e) {
            log.error("Error clearing myoscarPassword.", e);
        }
    }
}
