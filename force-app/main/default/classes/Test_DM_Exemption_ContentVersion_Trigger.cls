@isTest
private class Test_DM_Exemption_ContentVersion_Trigger {

	@isTest static void TestHappyPath_ContentTrigger() {
     
        String emailSubject = 'Deposit Exemption'; // Title
        String fileName = 'proof.doc'; // PathOnClient
        Blob encodedFile = Blob.valueOf('SGVsbG8sDQoNCkhlcmUgaXMgbXkgcHJvb2YuDQoNClRoYW5rcy4NCg==');
       
        String bpId = '1234567890';
        String accountNum = '9876543210';
        String exemptionType = 'Letter of Credit';
        String description = 'DME,'  + bpId + ', ' + accountNum + ',' + exemptionType ;
        
        ContentVersion cv = new ContentVersion(Title = emailSubject,
                                              PathOnClient = fileName,
                                              VersionData = encodedFile,
                                              Description = description );
            
        // <Title>#[emailSubject]</Title>
		// <PathOnClient>#[filename]</PathOnClient>
		//            <VersionData>#[org.mule.util.Base64.encodeBytes(message.inboundAttachments['emailBody'].dataSource.content, org.mule.util.Base64.DONT_BREAK_LINES).getBytes()]</VersionData>
		//            <Description>#[flowVars['descriptionValue']]</Description>
        //);
        
        Test.startTest();
        Database.SaveResult result = Database.insert(cv);
        Test.stopTest();
        
        System.assert(result.isSuccess());
	}
    
    @isTest static void TestHappyPathWithJpg_ContentTrigger() {
     
        String emailSubject = 'Deposit Exemption'; // Title
        String fileName = 'proof.jpg'; // PathOnClient
        Blob encodedFile = Blob.valueOf('SGVsbG8sDQoNCkhlcmUgaXMgbXkgcHJvb2YuDQoNClRoYW5rcy4NCg==');
       
        String bpId = '1234567890';
        String accountNum = '9876543210';
        String exemptionType = 'Letter of Credit';
        String description = 'DME,'  + bpId + ', ' + accountNum + ',' + exemptionType ;
        
        ContentVersion cv = new ContentVersion(Title = emailSubject,
                                              PathOnClient = fileName,
                                              VersionData = encodedFile,
                                              Description = description );
        
        Test.startTest();
        Database.SaveResult result = Database.insert(cv);
        Test.stopTest();
        
        System.assert(result.isSuccess());
	}

    @isTest static void NotTriggeredFromDigiMoveApp_ContentTrigger() {
     
        String emailSubject = 'Deposit Exemption'; // Title
        String fileName = 'proof.txt'; // PathOnClient
        Blob encodedFile = Blob.valueOf('SGVsbG8sDQoNCkhlcmUgaXMgbXkgcHJvb2YuDQoNClRoYW5rcy4NCg==');
       
        String bpId = '1234567890';
        String accountNum = '9876543210';
        String exemptionType = 'Letter of Credit';
        String description = 'lalalalalala,'  + bpId + ', ' + accountNum + ',' + exemptionType ;
        
        ContentVersion cv = new ContentVersion(Title = emailSubject,
                                              PathOnClient = fileName,
                                              VersionData = encodedFile,
                                              Description = description );

        Test.startTest();
        Database.SaveResult result = Database.insert(cv);
        Test.stopTest();
        
        System.assert(result.isSuccess());
     }

    @isTest static void TestHappyPathWithGif_ContentTrigger() {
     
        String emailSubject = 'Deposit Exemption'; // Title
        String fileName = 'proof.gif'; // PathOnClient
       	Blob encodedFile = Blob.valueOf('SGVsbG8sDQoNCkhlcmUgaXMgbXkgcHJvb2YuDQoNClRoYW5rcy4NCg==');
       
        String bpId = '1234567890';
        String accountNum = '9876543210';
        String exemptionType = 'Letter of Credit';
        String description = 'DME,'  + bpId + ', ' + accountNum + ',' + exemptionType ;
        
        ContentVersion cv = new ContentVersion(Title = emailSubject,
                                              PathOnClient = fileName,
                                              VersionData = encodedFile,
                                              Description = description );
        
        Test.startTest();
        Database.SaveResult result = Database.insert(cv);
        Test.stopTest();
        
        System.assert(result.isSuccess());
     }

     @isTest static void TestHappyPathWithPng_ContentTrigger() {
     
        String emailSubject = 'Deposit Exemption'; // Title
        String fileName = 'proof.png'; // PathOnClient
        Blob encodedFile = Blob.valueOf('SGVsbG8sDQoNCkhlcmUgaXMgbXkgcHJvb2YuDQoNClRoYW5rcy4NCg==');
       
        String bpId = '1234567890';
        String accountNum = '9876543210';
        String exemptionType = 'Letter of Credit';
        String description = 'DME,'  + bpId + ', ' + accountNum + ',' + exemptionType ;
        
        ContentVersion cv = new ContentVersion(Title = emailSubject,
                                              PathOnClient = fileName,
                                              VersionData = encodedFile,
                                              Description = description );
        
        Test.startTest();
        Database.SaveResult result = Database.insert(cv);
        Test.stopTest();
        
        System.assert(result.isSuccess());
     }
}