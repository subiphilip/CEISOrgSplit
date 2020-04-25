public class CampaignAutomationController extends ControllerForMobileMain{
    
    @RemoteAction
    public static void saveCampaignMember(string e, string cid, string cmstatus, boolean leads, boolean CampMember, string source){
        if(Cid!=null && Cid!='' && E!=null && E!=''){
            CampaignMember campMemb = new CampaignMember();
            Try{
                campMemb.Status = CMStatus;
                campMemb.CampaignID = Cid;
                //try the most recently created contact with that email
                try{
                    campMemb.ContactId=[select id from contact where email like: E order by createddate DESC limit 1].id;
                }catch(dmlexception ex){ //if not, we'll try finding a lead               
                  campMemb.LeadId=[select id from lead where email like: E order by createddate DESC limit 1].id ;
                }catch (exception ex){
                }
                //if it doesn't exist in either place
                if (campMemb.ContactId==null && campMemb.LeadId==null && leads){
                  lead l = new lead(email=e, lastname='not set', leadsource=Source);
                    try{
                      insert l;
                        campMemb.LeadId=l.id;
                    } catch(exception ex){}
                }
                
                insert campMemb;
            } catch(dmlexception ex){}
            catch(exception ex){}
        } 
    }      
    
    @RemoteAction
    public static void saveCampaignMemberFull(string E, string fn, string ln, string company, string cid, string cmstatus, boolean leads, boolean CampMember, string source){
        if(Cid!=null && Cid!='' && E!=null && E!=''){
            //first, get the lead and/or contactid
            id IncomingContactId; id IncomingLeadId; boolean exists = false;
            try{
                IncomingContactId=[select id from contact where email like: E order by createddate DESC limit 1].id;
                exists=true;
            } catch(dmlexception ex){ //if not, we'll try finding a lead               
                IncomingLeadId=[select id from lead where email like: E order by createddate DESC limit 1].id ;
                exists=true;
            }catch (exception ex){ //and if there was no lead, then we're creating one
                lead L = new lead(email=e, lastname=ln, firstname=fn, leadsource=Source, company=company);
                try{
                    insert L;
                    IncomingLeadId=l.id;
                } catch(exception ex2){}
            }
            CampaignMember campMemb;

            if (exists && IncomingLeadId !=null){
                list<CampaignMember> members = [select Id, Status, LeadId, ContactId from CampaignMember where LeadId=:IncomingLeadId and CampaignID=:cid];
                if (!members.isempty()) {
                    campMemb = members[0];
                }else{
                    campMemb = new CampaignMember(LeadId=IncomingLeadId, CampaignID=cid);
                }
            } else if (exists && IncomingContactId !=null){
                list<CampaignMember> members = [select Id, Status, LeadId, ContactId from CampaignMember where ContactId=:IncomingContactId and CampaignID=:cid];
                if (!members.isempty()) {
                    campMemb = members[0];
                }else{
                    campMemb = new CampaignMember(ContactId=IncomingContactId, CampaignID=cid);
                }
            } else if (!exists) campMemb = new CampaignMember(LeadId=IncomingLeadId, CampaignID=cid);
            
            campMemb.Status = CMStatus;
            upsert campMemb;
        } 
    }       
    
    @RemoteAction
        public static void saveActivity(string subject, string description, string parentID){
      task t = new task(WhatId=parentID, subject=subject, description=description, ownerID='0050M00000EMXh6');
            insert t;
        }
    
    
    @RemoteAction
    public static void saveCampaignMemberCustom(CampaignMemberContainer campaignMemberContainer){

        saveCampaignMemberFull(campaignMemberContainer.Email, 
                               campaignMemberContainer.FirstName,
                               campaignMemberContainer.LastName,
                               campaignMemberContainer.Company, 
                               '7010M000000OF9d', 
                               'Responded', 
                               true, 
                               true, 
                               'webinar form');
        
        string questions = '';
        for (String question : campaignMemberContainer.Questions)
        {
          questions += question + ', ';
        }
        
        saveActivity('Question from ' + campaignMemberContainer.FirstName + ' ' + campaignMemberContainer.LastName,
                      questions,
                     '7010M000000OF9d'
        );
    }      
    
    @RemoteAction
    public static CampaignMemberContainer getCampaignMemberContainerInstance() {
        return new CampaignMemberContainer();
    }
    
    public class CampaignMemberContainer {
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Company { get; set; }
        public String Email { get; set; }
        public List<String> Questions { get; set; }
    }  
    
}