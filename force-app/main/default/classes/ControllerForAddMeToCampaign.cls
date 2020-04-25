public without sharing class ControllerForAddMeToCampaign {
	
	private CampaignMember campMemb{get;set;}
        public string emailtoadd{get;set;}
        public string leadfirst{get;set;}
        public string leadlast{get;set;}
	
	public ControllerForAddMeToCampaign(){
		
	}
	public PageReference saveCampaignMember(){
		//campaign with lead
                if(ApexPages.currentpage().getParameters().get('campaign')!=null 
			   && ApexPages.currentpage().getParameters().get('campaign')!=''
			   && ApexPages.currentpage().getParameters().get('lead')!=null 
			   && ApexPages.currentpage().getParameters().get('lead')!=''){
				 campMemb = new CampaignMember();
				 Try{
				 	campMemb.CampaignID=ApexPages.currentpage().getParameters().get('campaign');
				 	campMemb.LeadId=ApexPages.currentpage().getParameters().get('lead');
				 	insert campMemb;
				 } catch(dmlexception e){}
				   catch(exception e){}
                            return null;
			}
                //campaign with contact
		if(ApexPages.currentpage().getParameters().get('campaign')!=null 
			   && ApexPages.currentpage().getParameters().get('campaign')!=''
			   && ApexPages.currentpage().getParameters().get('contact')!=null 
			   && ApexPages.currentpage().getParameters().get('contact')!=''){
				 campMemb = new CampaignMember();
				 Try{
				 	campMemb.CampaignID=ApexPages.currentpage().getParameters().get('campaign');
				 	campMemb.ContactId=ApexPages.currentpage().getParameters().get('contact');
				 	insert campMemb;
				 } catch(dmlexception e){}
				   catch(exception e){}
                            return null;
			}
                //campaign with neither, but user is logged in
                        //grab contactid from user
                if(ApexPages.currentpage().getParameters().get('campaign')!=null 
                       && ApexPages.currentpage().getParameters().get('campaign')!=''
                       && (ApexPages.currentpage().getParameters().get('contact') == null || ApexPages.currentpage().getParameters().get('contact')=='')
                       && (ApexPages.currentpage().getParameters().get('lead') == null || ApexPages.currentpage().getParameters().get('lead')=='')
                       && (Userinfo.getname()!='TrueCost Site Guest User')
                  ){
                           campMemb = new CampaignMember();
                            
                           Try{
                                User u = [select id, contactid from User where id =: UserInfo.getUserId() limit 1];                               
                                campMemb.CampaignID=ApexPages.currentpage().getParameters().get('campaign');
                                campMemb.ContactId=u.contactid;
                                insert campMemb;
                             } catch(dmlexception e){}
                               catch(exception e){}
                           return null;
                   }
                
                //campaign with neither, is guest user
                        //show email field on page with special link to process email (no dupes!!) and return to the page.
                if(ApexPages.currentpage().getParameters().get('campaign')!=null 
                       && ApexPages.currentpage().getParameters().get('campaign')!=''
                       && (ApexPages.currentpage().getParameters().get('contact') == null || ApexPages.currentpage().getParameters().get('contact')=='')
                       && (ApexPages.currentpage().getParameters().get('lead') == null || ApexPages.currentpage().getParameters().get('lead')=='')
                       && (Userinfo.getname()=='TrueCost Site Guest User')
                  ){
                  PageReference pr = page.AddMeToCampaign;
                  pr.getParameters().put('campaign', ApexPages.CurrentPage().GetParameters().get('campaign'));
                  pr.getParameters().put('lead', 'needemail');
                  pr.setredirect(true);
                  return pr;
                  }
            
                return null; //needed just in case all the other if statements fail.
	}

	
	public string getCampaignName(){
		list<Campaign> camplist = [select id, name from Campaign where id=:ApexPages.currentpage().getParameters().get('campaign')];
		if (!camplist.isempty() ) return camplist[0].name; else return null;
	}
        
        public pageReference handleEmail(){
          lead l = new lead();
            try{
                l=[select id from lead where email =: emailToAdd limit 1];
            }catch(exception e){                    
                    l.lastname='Not Set';
                    l.email = emailToAdd;
                    insert l;
                } 
          PageReference pr = page.AddMeToCampaign;
          pr.getParameters().put('campaign', ApexPages.CurrentPage().GetParameters().get('campaign'));
          pr.getParameters().put('lead', l.id);
          pr.setRedirect(true);
          return pr;

        }
}