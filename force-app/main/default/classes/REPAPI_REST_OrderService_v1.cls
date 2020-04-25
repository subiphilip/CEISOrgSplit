@RestResource(urlMapping='/rep-api/v1/*')
global with sharing class REPAPI_REST_OrderService_v1  {

    /****************************************************************************************************
    HOW TO PUBLIC TEST:
    Go To https://workbench.developerforce.com/restExplorer.php
    Here you can perform GET and POST methods once authenticated
    ****************************************************************************************************/


    /****************************************************************************************************
    * Description - Sample Apex REST service with GET method
        /services/apexrest/rep-api/v1/a0P3000000AEq8tEAD

    ****************************************************************************************************/
    global class GetResponseWrapper {
        List<Order__c> orderlist;
        String status;
        String message;

        public GetResponseWrapper(){

        }
    }
    @HttpGet
    global static GetResponseWrapper getOrder() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        GetResponseWrapper response = new GetResponseWrapper();

        try {
            User userId = [Select contactid from User where id =: Userinfo.getUserid()];
            List<AccountTeamMember> ATM = [SELECT Id, UserId, AccountID, SystemModstamp, TeamMemberrole FROM AccountTeamMember WHERE AccountId=:accountId AND UserId=:userId.id];
            List<REP_Profile__c> REP = [SELECT Id, Name, REP_Account__c from REP_Profile__c where REP_Account__c =:ATM[0].AccountID];

            List<Order__c> orderlist = [
            select
                Name,
                rep_profile__r.id,
                repstatus__c,
                id,
                order_status__c,
                Record_Type_Name__c,
                Enrollment_Type__c,
                InitialDateofService__c,
                ESIID_Number__c,
                TDSP__c,
                Premise_Order_Type__c,
                Plan_ID__c,
                kWh_rate_1000__c,
                Fixed_Energy_Rate__c,
                Reward__c,
                Contract_Length__c,
                First_Name__c,
                Last_Name__c,
                Email_Address__c,
                Customer_Email__c,
                Customer_Phone_Number__c,
                SSN__c,
                Customer_Date_of_Birth__c,
                Language_Preference__c,
                Authorized_Representative__c,
                Phone_of_Authorized__c,
                Last_4_SSN_of_Authorized__c,
                Service_Address__c,
                Service_City__c,
                Service_State__c,
                Service_Zip__c,
                Mailing_Street_Address__c,
                Mailing_City__c,
                Mailing_State__c,
                Mailing_Zip_Code__c,
                Customer_Acceptance_of_Plan_Terms__c,
                Customer_IP_Address__c,
                Created_Date_Formula__c,
                DBA_Name__c,
                Tax_Id__c,
                DUNS__c
            from Order__c
            where rep_profile__c = :REP[0].Id AND Created_Date_Formula__c > LAST_N_MONTHS:1
            limit 200];
            response.status = 'Success';
            response.message = 'You may review your recent orders';
            response.orderlist = orderlist;

        } catch(Exception exc) {

            res.StatusCode = 500;
            response.orderlist = null;
            response.status = 'Error';
            response.message = 'Your request failed with the following error: ' + exc.getMessage();
        }

        return response;
    }

    /****************************************************************************************************
     * Description - Sample Apex REST service with POST method
     // URI: /services/apexrest/rep-api/v1/00130000017qL6h/332956
    {
        "updateOrder": {
            "order_status": "Confirmed",
            "Rejection_Reason": "Credit Quality",
            "Order_Rejection_Comments": "Fix the address",
            "Plan_Expiration": "2020-08-04",
            "Deposit": "34.22",
            "Deposit_Requested": true,
            "REPOrderSubStatus": "Anything can go here",
            "repstatus": "Good to go",
            "Exception_Date": "2020-04-06"

        }
    }
    ****************************************************************************************************/
    global class RequestWrapper {
        String Record_Type_Name;
        String order_status;
        String Rejection_Reason;
        String Order_Rejection_Comments;
        Date Plan_Expiration;
        Decimal Deposit;
        Boolean Deposit_Requested;
        String REPOrderSubStatus;
        String repstatus;
        String Exception_Date;
    }

    global class PostResponseWrapper {
        List<Order__c> order;
        String requestURI;
        String status;
        String message;
        //User user;
        //String orderName;
        //String accountId;
        //List<AccountTeamMember> accountTeamMember;
        public PostResponseWrapper(){

        }
    }

    @HttpPost
    global static PostResponseWrapper updateOrder(RequestWrapper updateOrder) {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PostResponseWrapper response = new PostResponseWrapper();
        List<String> uriArr = req.requestURI.split('/');
        String accountId = uriArr[3];
        String orderName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Boolean flag = false;
        User userId;
        List<AccountTeamMember> ATM;
        List<REP_Profile__c> REP;

        try{

            userId = [Select contactid from User where id =: Userinfo.getUserid()];

        } catch(Exception exc) {

            res.StatusCode = 403;
            response.order = null;
            response.status = 'Not Authorized';
            response.message = 'Your update failed with the following error: User cannot be found';
            return response;
        }

        try{

            ATM = [SELECT Id, UserId, AccountID, SystemModstamp, TeamMemberrole FROM AccountTeamMember WHERE AccountId=:accountId AND UserId=:userId.id];

        } catch(Exception exc) {

            res.StatusCode = 403;
            response.order = null;
            response.status = 'Not Authorized';
            response.message = 'Your update failed with the following error: Account Team Member does not exist';
            return response;
        }

        try{

            REP = [SELECT Id, Name, REP_Account__c from REP_Profile__c where REP_Account__c =:ATM[0].AccountID];

        } catch(Exception exc) {

            res.StatusCode = 403;
            response.order = null;
            response.status = 'Not Authorized';
            response.message = 'Your update failed with the following error: Unauthorized access';
            return response;
        }

        try {

            List<Order__c> order = [
            select
                Name, // Order Number
                Record_Type_Name__c, // Order Name
                id, // Order Number
                order_status__c, // Order Status
                Rejection_Reason__c, // Rejection Reason
                Order_Rejection_Comments__c, // Rejection Comments
                Expected_Confirmation_Date__c, // Confirmation Date
                Plan_Expiration__c, // Plan Expiration
                Deposit__c, // Deposit Required
                Deposit_Requested__c, // Deposit
                rep_profile__r.id,  // REP Order Id
                REPOrderSubStatus__c, // REP Order Sub Status
                repstatus__c, // REP Status
                Exception__c // Exception

             from Order__c
             //where id = :accountId limit 1];
             where rep_profile__c = :REP[0].Id  and Name = :orderName limit 1 ];

            if(order.size() == 0){
                flag = true;
                res.StatusCode = 200;
                response.order = null;
                response.status = 'No orders';
                response.message = 'Your update failed with the following error: No orders found';
            }

            if(!flag) {
                if(!updateOrder.order_status.equalsIgnoreCase('Confirmed') && !updateOrder.order_status.equalsIgnoreCase('Rejected')) {
                  flag = true;
                  res.StatusCode = 403;
                  response.order = null;
                  response.status = 'Not Authorized';
                  response.message = 'Your update failed with the following error: Status update must be Confirmed or Rejected';
                }
            }

            if(!flag) {

                if(updateOrder.order_status.equalsIgnoreCase('Confirmed') && updateOrder.Plan_Expiration == null) {

                    flag = true;
                    res.StatusCode = 403;
                    response.order = null;
                    response.status = 'Not Authorized';
                    response.message = 'Your update failed with the following error: If order is Confirmed a Plan Expiration must be provided';

                }
                // if status is rejected a reason is required
                else if(updateOrder.order_status.equalsIgnoreCase('Rejected') && String.isBlank(updateOrder.Rejection_Reason)) {
                  // flag and send error rejection_reson must be given
                  flag = true;
                  res.StatusCode = 403;
                  response.order = null;
                  response.status = 'Not Authorized';
                  response.message = 'Your update failed with the following error: If order is Rejected must privide a reason';

                } else if( updateOrder.order_status.equalsIgnoreCase('Rejected') && !String.isBlank(updateOrder.Rejection_Reason)) {

                    if(updateOrder.Rejection_Reason.equalsIgnoreCase('Other') && String.isBlank(updateOrder.Order_Rejection_Comments)){

                        flag = true;
                        res.StatusCode = 403;
                        response.order = null;
                        response.status = 'Not Authorized';
                        response.message = 'Your update failed with the following error: If Rejected Reason is Other must provide comments';

                    }// if rejected and a reason is given the reason must match one of the following
                    else if(
                        updateOrder.Rejection_Reason.equalsIgnoreCase('Credit Quality') ||
                        updateOrder.Rejection_Reason.equalsIgnoreCase('Customer Rescinded') ||
                        updateOrder.Rejection_Reason.equalsIgnoreCase('Inaccurate Address') ||
                        updateOrder.Rejection_Reason.equalsIgnoreCase('Admin Rejection') ||
                        updateOrder.Rejection_Reason.equalsIgnoreCase('Deposit Unpaid')) {

                        // continue

                    } else {
                        // flag and send error
                        flag = true;
                        res.StatusCode = 403;
                        response.order = null;
                        response.status = 'Not Authorized';
                        response.message = 'Your update failed with the following error: If order is Rejected order reason must be Admin Rejection, Credit Quality, Customer Rescinded, Inaccurate Address or Deposit Unpaid';
                    }

                }
            }


            if(!flag){
                order[0].order_status__c = updateOrder.order_status;
                order[0].Rejection_Reason__c = updateOrder.Rejection_Reason;
                order[0].Order_Rejection_Comments__c = updateOrder.Order_Rejection_Comments;
                order[0].Plan_Expiration__c = updateOrder.Plan_Expiration;
                order[0].Deposit__c = updateOrder.Deposit;
                order[0].Deposit_Requested__c = updateOrder.Deposit_Requested;
                order[0].REPOrderSubStatus__c = updateOrder.REPOrderSubStatus;
                order[0].repstatus__c = updateOrder.repstatus;
                order[0].Exception__c = updateOrder.Exception_Date;
                update order;
                response.status = 'Success';
                response.message = 'Your Order has been updated successfully';
                response.order = order;
            }


        } catch(Exception exc) {

            res.StatusCode = 500;
            response.order = null;
            response.status = 'Error';
            response.message = 'Your update failed with the following error: ' + exc.getMessage();
        }

        return response;

    }

}