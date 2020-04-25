@RestResource(urlMapping='/HSPS/*')
global class HSPSResource {
    @HttpGet
    global static String emailOCS() {
        RestRequest request = RestContext.request;
        String [] leadId = new String[]{request.params.get('id')};
        String [] accountNumber = new String[]{request.params.get('account')};
        String [] customerName = new String[]{request.params.get('customer')};
        String [] premiseAddress = new String[]{request.params.get('premiseAddress')};
        String [] premiseId = new String[]{request.params.get('premiseId')};
        String [] phone = new String[]{request.params.get('phone')};
        String [] moveDate = new String[]{request.params.get('date')};
        List<Object> plans = (List<Object>)JSON.deserializeUntyped(request.params.get('plans'));

        try {
            System.debug(LoggingLevel.Info, 'DM Home Service Enrollment');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String [] toAddresses = new String[]{'SouthHSP@Centerpointenergy.com'};
            //String [] toAddresses = new String[]{'djordan@credera.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('no-reply@centerpointenergy.com');
            mail.setSenderDisplayName('no-reply@centerpointenergy.com');
            mail.setSubject('DM Home Service Enrollment');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            
            String body = '';
              body += 'Account Number: ' + accountNumber + '<br/>';
              body += 'Customer Name: ' + customerName + '<br/>';
              body += 'Premise ID: ' + premiseId + '<br/>';
              body += 'Premise Address: ' + premiseAddress + '<br/>';
              body += 'Phone Number: ' + phone + '<br/>';
              body += 'Effective Date: ' + moveDate + '<br/>';
              
              for(Object p : plans){    
                Map<String,Object> data = (Map<String,Object>)p;
                body += '<br/>Plans: ' + data.get('plan') + '<br/> Price: ' +data.get('price') + '<br/>';
              }
              mail.setHtmlBody(body);
          
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            return 'true';
        } catch (Exception e) {
            System.debug(e);
            return 'false';
        }
        
        
    }
}