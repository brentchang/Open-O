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
package org.oscarehr.integration.mchcv;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.ServletActionContext;

public class ValidateSwipeCard2Action extends ActionSupport {
    HttpServletRequest request = ServletActionContext.getRequest();
    HttpServletResponse response = ServletActionContext.getResponse();

    /**
     * This is the action called from the Struts framework.
     *
     * @param mapping  The ActionMapping used to select this instance.
     * @param form     The optional ActionForm bean for this request.
     * @param request  The HTTP Request we are processing.
     * @param response The HTTP Response we are processing.
     * @return
     * @throws java.lang.Exception
     */
    @Override
    public String execute() throws Exception {
        String magneticStripe = this.getMagneticStripe();
        HCMagneticStripe hcMagneticStripe = new HCMagneticStripe(magneticStripe);

        HCValidator validator = HCValidationFactory.getHCValidator();
        HCValidationResult validationResult = validator.validate(hcMagneticStripe.getHealthNumber(), hcMagneticStripe.getCardVersion());

        request.setAttribute("hcMagneticStripe", hcMagneticStripe);
        request.setAttribute("validationResult", validationResult);
        return SUCCESS;
    }

    private String magneticStripe;

    public String getMagneticStripe() {
        return magneticStripe;
    }

    public void setMagneticStripe(String magneticStripe) {
        this.magneticStripe = magneticStripe;
    }
}