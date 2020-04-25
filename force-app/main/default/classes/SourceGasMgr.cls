public class SourceGasMgr {

public static boolean firstRun = true;    
    
public static void  sourcegas(id order)
{

String orderpass = order;

		
	
   Order__c orders = [select id,order_status__c, Rejection_Reason__c,Control__c,Confirmation_code__c,Account_Number__c, Order_Confirmed_Verification_Code__c , exception__c, response__c from order__c where id =: order];

if (orders.Order_Confirmed_Verification_Code__c == null)
{    
sourceComm(orderpass);
}

}
    
@future (callout= true)
public static void sourceComm(String orderId )
{
	triggerhelper.recursiveHelper(true);
	

system.debug('Order______________________________________'+ orderId);	
   Order__c order = [select id,order_status__c, Rejection_Reason__c,Control__c,Confirmation_code__c,Account_Number__c, Order_Confirmed_Verification_Code__c , exception__c, response__c from order__c where id =: orderId];
      Logger__c log = new Logger__c(
              
			   Name = 'Apex Action Source Gas call - ' + System.now(),
			   Message__c = string.valueof(order),Order__c = orderId
			  );
		Logger__c log2 = new Logger__c(
              
			   Name = 'Apex Action Source Gas call good - ' + orderId + System.now(),Order__c = orderId
			  );
SourceGasPrd.ZCgSelfservEnrlRfcResponse_element resp ;
    Try{
        
  
       SourceGasPrd.ZBN_CG_SIGNUP signup = new SourceGasPrd.ZBN_CG_SIGNUP();
  
 
        String IvAnlage = '';
        //String IvCaNo;
        //String IvConfCode;
        //String IvControlNo;
        String IvEnrlMeth = 'WEBSERVICE';
        String IvSubmit = 'X';
        
         //string IvCaNo = '211012415467';
         //string IvConfCode = '36028';//enrollment period is closed
         //string IvControlNo = '700531268';
    
         string IvCaNo = order.Account_Number__c;
         string IvConfCode = order.Confirmation_code__c;//enrollment period is closed text 30
         string IvControlNo = order.Control__c; // text 10
    
    
    
          signup.inputHttpHeaders_x = new map<String,String>();
          signup.outputHttpHeaders_x = new map<String,String>();
          signup.inputHttpHeaders_x.put('Authorization', getSGAuthHeader());
          
        
         resp = signup.ZCgSelfservEnrlRfc(IvAnlage, IvCaNo, IvConfCode, IvControlNo, IvEnrlMeth, IvSubmit);
           log2.message__c = string.valueof(resp);
           
          system.debug(resp);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line1);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line2);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line3);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line4);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line5);
          system.debug('resp.EsEadrln:   '+resp.EsEadrln.Line6);
          
          
          system.debug('resp.EsMessage:  '+resp.EsMessage.Id);
          system.debug('resp.EsMessage:  '+resp.EsMessage.Message);
          system.debug('resp.EsReturn:   '+resp.EsReturn.Id);
          system.debug('resp.EsReturn:   '+resp.EsReturn.LogMsgNo);
          system.debug('resp.EsReturn:   '+resp.EsReturn.LogNo);
          system.debug('resp.EsReturn:   '+resp.EsReturn.Message);
          system.debug('resp.EsReturn:   '+resp.EsReturn.MessageV1);
          system.debug('resp.EsReturn:  '+resp.EsReturn.MessageV2);
          system.debug('resp.EsReturn:   '+resp.EsReturn.MessageV3);
          system.debug('resp.EsReturn:  '+resp.EsReturn.MessageV4);
          system.debug('resp.EsReturn:  '+resp.EsReturn.Number_x);
          system.debug('resp.EsReturn:  '+resp.EsReturn.Type_x);
          
          system.debug('resp.EvAnlage:  '+resp.EvAnlage);
          system.debug('resp.EvName1:   '+resp.EvName1);
          system.debug('resp.EvName2:   '+resp.EvName2);
          system.debug('resp.EvPriceOpt:  '+resp.EvPriceOpt);
          system.debug('resp.EvServId:  '+resp.EvServId);
          system.debug('resp.EvServProv:  '+resp.EvServProv);
          system.debug('resp.EvVerifNoe:  '+resp.EvVerifNo);
          
          order.response__c  = string.valueof(resp);
        if (resp.EsMessage != null && resp.EsMessage.Id.length() > 0 && resp.EsMessage.id != 'E05')
        {
        order.Rejection_Reason__c = 'Code:'+ resp.EsMessage.Id + 'Message:' + resp.EsMessage.Message;
         order.order_status__c = 'Rejected';
         update order;
        }else if ( resp.EvVerifNo != null)
        {
         order.Order_Confirmed_Verification_Code__c= resp.EvVerifNo;
         order.Order_status__c = 'Success';
         update order;
        }else if( resp.Esmessage.id.contains('E0'))
        {
         order.Rejection_Reason__c = 'Code:'+ resp.EsMessage.Id + 'Message:' + resp.EsMessage.Message;
         order.order_status__c = 'Rejected';
         update order;
        
        }
        }

       catch (CalloutException ce){
         
         Exceptions__c error = new Exceptions__c(
              
			   Name = 'Apex Exception - ' + System.now(),
			   Error__c = ce.getMessage(),
			   Error_Type__c = ce.getTypeName()
			  );
			   
			  insert error;

         order.exception__c = ce.getTypeName() + ':' + ce.getMessage();
         order.order_status__c = 'API Error';
         update order;
			    
    } 
     
     catch(exception e)
     {
       
        Exceptions__c error = new Exceptions__c(
              
			   Name = 'Apex Exception - ' + System.now(),
			   Error__c = e.getMessage(),
			   Error_Type__c = e.getTypeName()
			  );
			   
			  insert error;
			  
         order.exception__c = e.getmessage();
         order.response__c  = string.valueof(resp);
         order.order_status__c = 'Failed';
         update order;
     }
     finally {
  insert log;
  insert log2;

}
}

public static string getSGAuthHeader(){
  PartnerAPI__c Papi = PartnerAPI__c.getInstance('SourceGas');
   Blob headerValue = Blob.valueOf(Papi.username__c + ':' + Papi.password__c);
   String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
   system.debug(authorizationHeader);
   return authorizationHeader;
}

public static void sourceCommMan(String orderId )
{
	
system.debug('Order______________________________________'+ orderId);	
   Order__c order = [select id,order_status__c, Rejection_Reason__c,Control__c,Confirmation_code__c,Account_Number__c, Order_Confirmed_Verification_Code__c , exception__c, response__c from order__c where id =: orderId];
    
	SourceGasPrd.ZCgSelfservEnrlRfcResponse_element resp ;
  PartnerAPI__c Papi = PartnerAPI__c.getInstance('SourceGas');

	if (order.Order_Confirmed_Verification_Code__c == null && Papi.Active__c){
    Try{
        
         
       SourceGasPrd.ZBN_CG_SIGNUP signup = new SourceGasPrd.ZBN_CG_SIGNUP();
 
        String IvAnlage = '';
        //String IvCaNo;
        //String IvConfCode;
        //String IvControlNo;
        String IvEnrlMeth = 'WEBSERVICE';
        String IvSubmit = 'X';
        
         //string IvCaNo = '211012415467';
         //string IvConfCode = '36028';//enrollment period is closed
         //string IvControlNo = '700531268';
    
         string IvCaNo = order.Account_Number__c;
         string IvConfCode = order.Confirmation_code__c;//enrollment period is closed text 30
         string IvControlNo = order.Control__c; // text 10
    
    
    
          signup.inputHttpHeaders_x = new map<String,String>();
          signup.outputHttpHeaders_x = new map<String,String>();
           signup.inputHttpHeaders_x.put('Authorization', getSGAuthHeader());
          
          
         resp = signup.ZCgSelfservEnrlRfc(IvAnlage, IvCaNo, IvConfCode, IvControlNo, IvEnrlMeth, IvSubmit);
          
          system.debug(resp);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line1);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line2);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line3);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line4);
          system.debug('resp.EsEadrln:  '+resp.EsEadrln.Line5);
          system.debug('resp.EsEadrln:   '+resp.EsEadrln.Line6);
          
          
          system.debug('resp.EsMessage:  '+resp.EsMessage.Id);
          system.debug('resp.EsMessage:  '+resp.EsMessage.Message);
          system.debug('resp.EsReturn:   '+resp.EsReturn.Id);
          system.debug('resp.EsReturn:   '+resp.EsReturn.LogMsgNo);
          system.debug('resp.EsReturn:   '+resp.EsReturn.LogNo);
          system.debug('resp.EsReturn:   '+resp.EsReturn.Message);
          system.debug('resp.EsReturn:   '+resp.EsReturn.MessageV1);
          system.debug('resp.EsReturn:  '+resp.EsReturn.MessageV2);
          system.debug('resp.EsReturn:   '+resp.EsReturn.MessageV3);
          system.debug('resp.EsReturn:  '+resp.EsReturn.MessageV4);
          system.debug('resp.EsReturn:  '+resp.EsReturn.Number_x);
          system.debug('resp.EsReturn:  '+resp.EsReturn.Type_x);
          
          system.debug('resp.EvAnlage:  '+resp.EvAnlage);
          system.debug('resp.EvName1:   '+resp.EvName1);
          system.debug('resp.EvName2:   '+resp.EvName2);
          system.debug('resp.EvPriceOpt:  '+resp.EvPriceOpt);
          system.debug('resp.EvServId:  '+resp.EvServId);
          system.debug('resp.EvServProv:  '+resp.EvServProv);
          system.debug('resp.EvVerifNoe:  '+resp.EvVerifNo);
        }

       catch (CalloutException ce){
         order.exception__c = ce.getMessage();
    
    }
       system.debug('______________'+ resp.esmessage.id);
        if (resp.EsMessage.Id.length() >0)
        {
        order.Rejection_Reason__c = 'Code:'+ resp.EsMessage.Id + 'Message:' + resp.EsMessage.Message;
         order.order_status__c = 'Rejected';
         update order;
        }else{
         //order.response__c = stringvalueof(resp);
         order.Order_Confirmed_Verification_Code__c= resp.EvVerifNo;
         order.Order_status__c = 'Success';
         update order;
        }
	}
          //Order_Confirmed_Verification_Code__c

}
}