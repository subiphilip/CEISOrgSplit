public  class UsageRequestManager {

	public void reply(uhitmessage__c  message){

		try{
			//data setup
			system.debug('start process +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' + message);
			String requestId = '%'+message.requestId__c+'%';
			system.debug('requestid +++++++++++++++++++++++++++++++++++++++++++++' + requestId);
			uhitrequest__c msg = [SELECT APA__c,RequestId__c  FROM UHITRequest__c where requestId__c LIKE :requestId limit 1];
			system.debug('msg size_____________________________________________'+ msg);
			AccountPremiseAssociation__c apa = [SELECT Account__c, Id, X50KVA__c, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c,premise__r.id FROM AccountPremiseAssociation__c where id=:msg.APA__c limit 1];
			system.debug('apa_______________________________________________' + apa);

			list<uhitmessage__c> dataPassed = [SELECT item__c, ActKWH__c,BilledKVA__c,EndDate__c,ESID__c,Id,MeteredKVA__c,MeterReadCycle__c,PowerFactor__c,LoadProfile__c, RateCode__c,RequestId__c,RequestStatus__c,StartDate__c,status__c FROM uhitmessage__c where requestId__c LIKE :requestId order by item__c];

			UsageRequestManager.sharedDataProcessing(apa, dataPassed);

			AsyncRequest__c ASR = new AsyncRequest__c(type__c='UHITDaily', params__c=APA.id);
			insert ASR;

			System.debug('seting complete');
			
		}catch(exception e){
			system.debug(e);
		}
	}

	public static void processManualUHM(string APAid){
		//get the APA
		AccountPremiseAssociation__c apa = [SELECT Account__c, Id, X50KVA__c, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c,premise__r.id, premise__r.ESID__c FROM AccountPremiseAssociation__c where id=:APAid];

		//get all the UHM for that APAid
		list<uhitmessage__c> dataPassed = [SELECT item__c, ActKWH__c,BilledKVA__c,EndDate__c,ESID__c,Id,MeteredKVA__c,MeterReadCycle__c,PowerFactor__c,LoadProfile__c, RateCode__c,RequestId__c,RequestStatus__c,StartDate__c, Status__c 
			FROM uhitmessage__c 
			where ESID__c =:apa.premise__r.ESID__c];

		UsageRequestManager.sharedDataProcessing(apa, dataPassed);



	}

	public static void sharedDataProcessing(AccountPremiseAssociation__c apa, list<uhitmessage__c> dataPassed){
		//the premise for updating
		Premises__c premiseReq = [SELECT id, Load_Profile__c FROM Premises__c where id=:apa.Premise__c];

		dataPassed = DedupeUHIT(dataPassed); //dedupe by start date
		
		AllocateUsage(dataPassed, apa); //turning into monthly usages

		apa.Meter_Data_Request_Status__c = 'Complete';
		//billed KVA > 50, then flip flag on APA.
		if (!apa.X50KVA__c){
			for (uhitmessage__c uhm:dataPassed){
				if (uhm.BilledKVA__c>50){
					apa.X50KVA__c=true;
				}
			}
		}
		update apa;

		//set load profile on premise
		premiseReq.Load_Profile__c = dataPassed[0].LoadProfile__c;
		system.debug('before update complete___________________________________________________________'+ premiseReq);
		update premiseReq;
		system.debug('after update complete___________________________________________________________'+ premiseReq);

	}

	public static list<uhitmessage__c> DedupeUHIT(list<uhitmessage__c> data){
		map<date, uhitmessage__c> DedupeMap = new map<date, uhitmessage__c>();
		for (uhitmessage__c uhm:data){
			DedupeMap.put(uhm.StartDate__c, uhm);
		}
        return DedupeMap.values();
	}

	public static void AllocateUsage(list<uhitmessage__c> data, AccountPremiseAssociation__C APA){

		list<monthly_usage__c> output = new list<monthly_usage__c>();

		//build the output set with the month numbers, premise, APA, and usage ==0 
		for (integer x=1; x<13; x++){
			monthly_usage__C mu = new monthly_usage__c();
			mu.month_number__c = x;
			mu.APA__c = APA.id;
			mu.premise__c = APA.premise__r.id;
			mu.Usage__c = 0;
			mu.estimated__c = false;
			output.add(mu);    

		}
		system.debug('output'+ output);

		for (uhitmessage__c row:data){
			integer startmonth = row.StartDate__c.month(); system.debug('=========================================StartMonth is '+ startmonth);
			integer endmonth = row.EndDate__c.month();  system.debug('=========================================EndMonth is '+ endmonth);
			integer startmonthdays;
			integer endmonthdays;            
			decimal startmonthusage;
			decimal endmonthusage;

			//startmonth is endmonth
			if(startmonth == endmonth){
				output[startmonth-1].usage__c=output[startmonth-1].usage__c + row.ActKWH__c;
				system.debug('==========================usage is '+row.ActKWH__c + ' for month' + startmonth);
			}
			
			//consecutive months
			if(endmonth == startmonth + 1 || (endmonth ==1 && startmonth ==12 )){
				startmonthdays = date.daysInMonth(row.StartDate__c.month(), row.StartDate__c.year()) - row.StartDate__c.day()+1; //how many days in month 1
				endmonthdays = row.EndDate__c.day();
				startmonthusage = row.ActKWH__c*startmonthdays/(startmonthdays+endmonthdays); 
				system.debug('==========================startmonthusage is '+startmonthusage + ' for ' + startmonthdays + 'days');
				endmonthusage = row.ActKWH__c*endmonthdays/(startmonthdays+endmonthdays);  
				system.debug('==========================endmonthusage is '+endmonthusage + ' for ' + endmonthdays + 'days');
				output[startmonth-1].usage__c=output[startmonth-1].usage__c + startmonthusage;
				output[endmonth-1].usage__c=output[endmonth-1].usage__c + endmonthusage;
			}

			//3 month range
			if(endmonth == startmonth + 2 || (endmonth ==1 && startmonth ==11 ) || (endmonth ==2 && startmonth ==12 )){
				decimal midmonthusage; //need extra variables for ths case
				integer midmonth;
				integer midmonthdays;
				
				startmonthdays = date.daysInMonth(row.StartDate__c.month(), row.StartDate__c.year()) - row.StartDate__c.day()+1; //how many days in month 1
				midmonth = math.mod(startmonth +1, 12);
				if (midmonth == 0){
					midmonth = startmonth +1;
				}
				midmonthdays = date.daysinMonth(row.StartDate__c.addDays(15).month(),  row.StartDate__c.addDays(15).year()    );  //add 15days to start and get the days of that month
				endmonthdays = row.EndDate__c.day(); //how many days in month 3
				startmonthusage = row.ActKWH__c*startmonthdays/(startmonthdays+endmonthdays+midmonthdays); 
				system.debug('==========================startmonthusage is '+startmonthusage + ' for ' + startmonthdays + 'days');
				midmonthusage = row.ActKWH__c*midmonthdays/(startmonthdays+endmonthdays+midmonthdays);
				system.debug('==========================midmonthusage is '+midmonthusage + ' for ' + midmonthdays + 'days');
				endmonthusage = row.ActKWH__c*endmonthdays/(startmonthdays+endmonthdays+midmonthdays);  
				system.debug('==========================endmonthusage is '+endmonthusage + ' for ' + endmonthdays + 'days');
				system.debug('==========================start month is.. '+startmonth );
				system.debug('==========================mid month is.. '+midmonth );
				system.debug('==========================end month is '+endmonth );
				output[midmonth-1].usage__c=output[midmonth-1].usage__c + midmonthusage;

				output[startmonth-1].usage__c=output[startmonth-1].usage__c + startmonthusage;
				
				output[endmonth-1].usage__c=output[endmonth-1].usage__c + endmonthusage;

			}
		}
		//now, round all the stuff off!
		for (monthly_usage__c mu:output){
			mu.usage__c = math.round(mu.usage__c);
		}
		List<monthly_usage__c> oldValues= [select id from monthly_usage__c where APA__c =:apa.id ];
		system.debug('_________________olld values'+ oldvalues);
		delete oldValues;
		insert output;
	
	}




}