public class ControllerForTrueCostPeople {
    
    public list<UserWrapper> getPeople(){
        list<user> users = [select id, name, title, Public_Profile_Description__c, Public_Picture_URL__c from user where Make_Profile_Public__c=true];
        list<UserWrapper> output = new list<UserWrapper>();
        for (user u:users){
            UserWrapper UW = new UserWrapper();
            UW.name = u.name;
            UW.title = u.title;
            UW.image = u.Public_Picture_URL__c;
            UW.description = u.Public_Profile_Description__c;
            output.add(UW);
        }
        return output;
    }
    
    public class UserWrapper {
        public string name {get;set;}
        public string title{get;set;}
        public string image {get;set;}
        public string description {get;set;}
    }
}