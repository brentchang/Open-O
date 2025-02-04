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


package org.oscarehr.phr.dao.hibernate;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.oscarehr.phr.dao.PHRDocumentDAO;
import org.oscarehr.phr.model.PHRDocument;
import org.oscarehr.phr.model.PHRMessage;
import org.oscarehr.util.MiscUtils;
import org.springframework.orm.hibernate5.HibernateCallback;
import org.springframework.orm.hibernate5.support.HibernateDaoSupport;

/**
 * @author jay
 */
public class PHRDocumentDAOHibernate extends HibernateDaoSupport
        implements PHRDocumentDAO {

    private static Logger log = MiscUtils.getLogger();


    public boolean hasIndex(String idx) {
        final String index = idx;
        Long num = (Long) getHibernateTemplate().execute(new HibernateCallback() {
            public Object doInHibernate(Session session)
                    throws HibernateException {
                Query q = session.createQuery("select count(*) from PHRDocument p where p.phrIndex= ?0");
                q.setCacheable(true);
                q.setParameter(0, index);
                return q.uniqueResult();
            }
        });
        log.debug("number of documents with that idx " + num);
        if (num > 0) {
            return true;
        }
        return false;
    }


    public boolean hasInde2x(String index) {
        String sql = "select count(*) from PHRDocument p where p.phrClassification= '" + index + "'";

        return (((Long) getHibernateTemplate().iterate(sql).next()) == 1);

    }

    public List<PHRDocument> getDocumentsReceived(String docType, String providerNo) {
        // for messages 'urn:org:indivo:document:classification:message'
        String sql = "from PHRDocument d where d.phrClassification = ?0 and d.receiverOscar = ?1 and d.status <= 7 ORDER BY d.dateSent DESC";
        Object[] params = new Object[]{docType, providerNo};
        List<PHRDocument> list = (List<PHRDocument>) getHibernateTemplate().find(sql, params);
        return list;
    }

    public List<PHRDocument> getDocumentsSent(String docType, String providerNo) {
        // for messages 'urn:org:indivo:document:classification:message'
        String sql = "from PHRDocument d where d.phrClassification = ?0 and d.senderOscar = ?1 ORDER BY d.dateSent DESC";
        Object[] params = new Object[]{docType, providerNo};
        List<PHRDocument> list = (List<PHRDocument>) getHibernateTemplate().find(sql, params);
        return list;
    }

    public List<PHRDocument> getDocumentsArchived(String docType, String providerNo) {
        // for messages 'urn:org:indivo:document:classification:message'
        String sql = "from PHRDocument d where d.phrClassification = ?0 and d.receiverOscar = ?1 and d.status > 7 ORDER BY d.dateSent DESC";
        Object[] params = new Object[]{docType, providerNo};
        List<PHRDocument> list = (List<PHRDocument>) getHibernateTemplate().find(sql, params);
        return list;
    }

    public List<PHRDocument> getDocumentsByReceiverSenderStatusClassification(Integer receiverType, Integer senderType, String phrClassification, String receiverOscar, Integer status) {
        String sql = "from PHRDocument d where d.phrClassification=?0 and d.receiverOscar=?1 and d.status=?2 and d.senderType=?3 and d.receiverType=?4 order by d.dateSent desc";
        Object[] params = {phrClassification, receiverOscar, status, senderType, receiverType};
        List<PHRDocument> ret = (List<PHRDocument>) getHibernateTemplate().find(sql, params);
        return ret;
    }

    public PHRDocument getDocumentById(String id) {
        // for messages 'urn:org:indivo:document:classification:message'
        String sql = "from PHRDocument d where d.id = ?0 ";
        List<PHRDocument> list = (List<PHRDocument>) getHibernateTemplate().find(sql, new Integer(id));

        if (list == null || list.size() == 0) {
            return null;
        }

        return list.get(0);
    }

    public PHRDocument getDocumentByIndex(String idx) {
        // for messages 'urn:org:indivo:document:classification:message'
        String sql = "from PHRDocument d where d.phrIndex = ?0 ";
        List<PHRDocument> list = (List<PHRDocument>) getHibernateTemplate().find(sql, idx);

        if (list == null || list.size() == 0) {
            return null;
        }

        return list.get(0);
    }


    public void save(PHRDocument doc) {
        this.getHibernateTemplate().save(doc);
    }

    public void update(PHRDocument doc) {
        this.getHibernateTemplate().update(doc);
    }

    public PHRMessage getMessageById(String idx) {
        String sql = "from PHRDocument d where d.phrIndex = ?0 ";
        List<PHRMessage> list = (List<PHRMessage>) getHibernateTemplate().find(sql, idx);
        if (list == null || list.size() == 0) {
            return null;
        }
        return list.get(0);
    }

    public List<String> getReferencedMessages(PHRDocument doc) {
        List<String> list = null;
        try {
            PHRMessage message = new PHRMessage(doc);
            if (message.getReferenceMessage() != null) {
                list = getReferencedMessagesById(message.getReferenceMessage());
            }
        } catch (Exception e) {
            MiscUtils.getLogger().error("Error", e);
        }
        return list;
    }

    public List<String> getReferencedMessagesById(String id) {
        PHRMessage message = getMessageById(id);
        List<String> list = new ArrayList<String>();
        if (message.getReferenceMessage() == null) {
            return null;
        }
        list.add(message.getBody());
        return getReferenceMessagesById(list, message.getReferenceMessage());
    }

    public List<String> getReferenceMessagesById(List<String> list, String id) {
        PHRMessage message = getMessageById(id);
        if (message.getReferenceMessage() != null) {
            list.add(message.getBody());
            getReferenceMessagesById(list, message.getReferenceMessage());
        }
        return list;
    }


    public int countUnreadDocuments(final String classification, final String providerNo) {
        Long num = (Long) getHibernateTemplate().execute(new HibernateCallback() {
            public Object doInHibernate(Session session)
                    throws HibernateException {
                Query q = session.createQuery("select count(*) from PHRDocument d where d.phrClassification = ?1 and d.receiverOscar = ?2 and d.status = ?3");
                q.setCacheable(true);
                q.setParameter(1, classification);
                q.setParameter(2, providerNo);
                q.setParameter(3, PHRMessage.STATUS_NEW);
                return q.uniqueResult();
            }
        });
        return num.intValue();
    }


    /**
     * Creates a new instance of PHRDocumentDAOHibernate
     */
    public PHRDocumentDAOHibernate() {
    }

}
