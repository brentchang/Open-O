//CHECKSTYLE:OFF
/**
 * Copyright (c) 2024. Magenta Health. All Rights Reserved.
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
 * <p>
 * Modifications made by Magenta Health in 2024.
 */
package org.oscarehr.common.dao;

import org.oscarehr.common.model.MyGroup;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.MiscUtils;
import org.springframework.stereotype.Repository;
import org.oscarehr.common.model.MyGroupPrimaryKey;

import javax.persistence.Query;
import java.util.List;

@Repository
public class MyGroupDaoImpl extends AbstractDaoImpl<MyGroup> implements MyGroupDao {

    public MyGroupDaoImpl() {
        super(MyGroup.class);
    }

    @Override
    public List<MyGroup> findAll() {
        Query query = createQuery("x", null);
        return query.getResultList();
    }

    @Override
    public List<String> getGroupDoctors(String groupNo) {

        Query query = entityManager.createQuery("SELECT g.id.providerNo FROM MyGroup g WHERE g.id.myGroupNo=?1");
        query.setParameter(1, groupNo);

        @SuppressWarnings("unchecked")
        List<String> dList = query.getResultList();

        if (dList != null && dList.size() > 0) {
            return dList;
        } else {
            return null;
        }
    }

    @Override
    public List<String> getGroups() {
        Query query = entityManager.createQuery("SELECT distinct g.id.myGroupNo FROM MyGroup g");

        @SuppressWarnings("unchecked")
        List<String> dList = query.getResultList();

        return dList;
    }

    @Override
    public List<MyGroup> getGroupByGroupNo(String groupNo) {
        Query query = entityManager.createQuery("SELECT g FROM MyGroup g where g.id.myGroupNo = ?1");
        query.setParameter(1, groupNo);

        @SuppressWarnings("unchecked")
        List<MyGroup> dList = query.getResultList();

        return dList;
    }

    @Override
    public void deleteGroupMember(String myGroupNo, String providerNo) {
        MyGroupPrimaryKey key = new MyGroupPrimaryKey();
        key.setMyGroupNo(myGroupNo);
        key.setProviderNo(providerNo);
        remove(key);
    }

    @Override
    public List<MyGroup> getProviderGroups(String providerNo) {
        Query query = entityManager.createQuery("SELECT g FROM MyGroup g WHERE g.id.providerNo = ?1");
        query.setParameter(1, providerNo);

        @SuppressWarnings("unchecked")
        List<MyGroup> dList = query.getResultList();

        return dList;
    }

    @Override
    public String getDefaultBillingForm(String myGroupNo) {
        Query query = entityManager.createQuery("SELECT distinct g.defaultBillingForm FROM MyGroup g WHERE g.id.myGroupNo = ?1");
        query.setParameter(1, myGroupNo);

        @SuppressWarnings("unchecked")
        List<String> dList = query.getResultList();

        if (dList.size() > 1)
            MiscUtils.getLogger().warn("More than one Default biling form for this group. Should only be one");
        String billingForm = "";
        if (dList != null && !dList.isEmpty())
            billingForm = dList.get(0);
        return billingForm;
    }

    @Override
    public List<Provider> search_groupprovider(String groupNo) {

        Query query = entityManager.createQuery("SELECT p  FROM MyGroup g, Provider p WHERE g.id.myGroupNo=?1 and p.ProviderNo = g.id.providerNo order by p.LastName");
        query.setParameter(1, groupNo);

        @SuppressWarnings("unchecked")
        List<Provider> dList = query.getResultList();

        return dList;
    }

    @Override
    public List<MyGroup> search_mygroup(String groupNo) {
        Query query = entityManager.createQuery("SELECT g FROM MyGroup g WHERE g.id.myGroupNo like ?1 group by g.id.myGroupNo order by g.id.myGroupNo");
        query.setParameter(1, groupNo);

        @SuppressWarnings("unchecked")
        List<MyGroup> dList = query.getResultList();

        return dList;
    }

    @Override
    public List<MyGroup> searchmygroupno() {
        Query query = entityManager.createQuery("SELECT g FROM MyGroup g group by g.id.myGroupNo order by g.id.myGroupNo");

        @SuppressWarnings("unchecked")
        List<MyGroup> dList = query.getResultList();

        return dList;
    }

    @Override
    public List<MyGroup> search_providersgroup(String lastName, String firstName) {
        Query query = entityManager.createQuery("SELECT g FROM MyGroup g where g.lastName like ?1 and g.firstName like ?2 order by g.lastName, g.firstName, g.id.myGroupNo");
        query.setParameter(1, lastName);
        query.setParameter(2, firstName);

        @SuppressWarnings("unchecked")
        List<MyGroup> dList = query.getResultList();

        return dList;
    }

}
