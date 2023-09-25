/**********************************************************************************************************
* Author: Himanshi Bhoria
* Purpose: send email to landlord agent in duration of 10 , 15, 20 25 working dates of responsd date and case status is 
Evidence gathering agent/landlord
* Run Frequency:          
* *******************************************************************************************************/
/* Changes: 14 Sept 2022 Himanshi Bhoria-Added logic for EWI finance EID-30
*          22 Sept 2022 Himanshi Bhoria- Added Logic for EWI finance EID 118
* 
* ******************************************************************************************************/
global class EI_EWI_FinanceSendEmail implements Database.Batchable<sObject>, database.AllowsCallouts, Database.Stateful, Schedulable {
    
     public void execute(SchedulableContext SC){
        Database.executeBatch(new EI_EWI_FinanceSendEmail(), 100);
    }
    
    public static List<Holiday> holidayList;
    //to get the case recordTypeId
    Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
    public EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
    //public Map<String, Map<String, String>> emailsubject = helper.getSubjects();
    Public List<Case> agllCaseList = new List<Case>();
    Public Map<Id, Case> caseMap = new Map<Id, Case>();
    Public Map<Id, String> keyMap = new Map<Id, String>();
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ='select Id,Status,Respond_date__c,OwnerId,V_External_Id__c,Evidence_Gathering_Start_Date__c,Deposit_repaid_Start_Date__c,Tenancy_Property_Address__c,Resolved_Without_Adjudication_Reason__c,'
            + ' Disputed_Funds_Received__c,Stop_chaser_e_mails__c,Consent_withdrawn_date__c,Evidence_of_court_action_received__c,Dispute_Reference__c,Previous_owner__c,Date_Case_Resolved__c,Disputed_Funds_Required__c,'
            +' AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Counter__c,Deposit_Account_Number__r.Property_Address_WO_Country__c,Awaiting_review_date__c,EWI_Payment_genareted__c,Amount_of_Disputed_Funds_Received__c'
            + ' from Case where RecordtypeId=:devRecordTypeId AND (Status In (\'Evidence gathering agent/landlord\',\'Evidence gathering tenant\',\'No response from agent/landlord\',\'Evidence review complete\',\'Adjudication\',\'Decision issued – dispute monies outstanding\',\'Awaiting Review\',\'Deposit closed - deposit repaid in part\',\'Decision issued – with legal\',\'Deposit closed - unable to repay\',\'Decision issued – Insurance claim\',\'Case closed – resolved without adjudication\')  ) '; // and Id =\'5003L000008BDJyQAO\'
        system.debug('Queryy=>'+query);
        //( Evidence_Gathering_Start_Date__c!= Null OR Deposit_repaid_Start_Date__c!=Null)  AND
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList){
        Set<Id> setCaseIds = new Set<Id>();
        Set<Id> setCreditIds = new Set<Id>();
        List<Case> listAllDisputedCase= new List<Case>();
        try{
            
         /*   Map<Id,Case> mapCase = new Map<Id, Case>(caseList);
            
            system.debug('Debugg >>>1');
            listAllDisputedCase=[select Id,Status,Respond_date__c,OwnerId,Evidence_Gathering_Start_Date__c,Disputed_Funds_Received__c, Stop_chaser_e_mails__c,Resolved_Without_Adjudication_Reason__c,
                                 Deposit_repaid_Start_Date__c,Consent_withdrawn_date__c,Evidence_of_court_action_received__c,Dispute_Reference__c,Disputed_Funds_Required__c,
                                 Previous_owner__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Counter__c,Awaiting_review_date__c,
                                 Deposit_Account_Number__r.Property_Address_WO_Country__c,V_External_Id__c,Tenancy_Property_Address__c
                                 from Case 
                                 where RecordtypeId=:devRecordTypeId  //(Evidence_Gathering_Start_Date__c!= null OR Deposit_repaid_Start_Date__c!= null)
                                 AND Id=: mapCase.keySet() ]; */
            
            for(Case eachCase: caseList){
                //EID-30
                date fromDate ;
                system.debug('fromDate'+fromDate);
                //FOR EID-1261
                //Updated the status Review Complete to Evidence Review Complete
                //Case Assigned to Adjudicator to Adjudication
                //Decision issued - dispute monies outstanding 
                if((eachCase.Status=='Evidence gathering agent/landlord' || eachCase.Status=='Evidence gathering tenant'  || eachCase.Status == 'No response from agent/landlord'
                    || eachCase.Status=='Evidence review complete' || eachCase.Status=='Adjudication' || eachCase.Status == 'Decision issued – dispute monies outstanding') && eachCase.Evidence_Gathering_Start_Date__c!= null)
                {
                    fromDate = eachCase.Evidence_Gathering_Start_Date__c;
                    system.debug('fromDateevidegath'+fromDate);
                }else if(eachCase.status=='Awaiting Review'){
                      fromDate = eachCase.Awaiting_review_date__c;
                     system.debug('fromDateevidegath'+fromDate);

                }
                if(((eachCase.Status=='Evidence gathering agent/landlord' || eachCase.Status=='Evidence gathering tenant' || eachCase.Status == 'No response from agent/landlord'
                     || eachCase.Status=='Evidence review complete' || eachCase.Status=='Adjudication' || eachCase.Status == 'Decision issued – dispute monies outstanding') && eachCase.Evidence_Gathering_Start_Date__c!= null))
                {
                    System.debug(eachCase.dispute_reference__c + ' => ' + eachCase.Evidence_Gathering_Start_Date__c );
                    //Date of 10th Working Day 
                    Date check_10_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,11); // eachCase.Evidence_Gathering_Start_Date__c.addDays(10);
                    system.debug('check_10_workingdaycompleted>>>> '+check_10_workingdaycompleted);
                    //Date of 15th Working Day
                    Date check_15_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,15); // eachCase.Evidence_Gathering_Start_Date__c.addDays(15);
                    system.debug('check_15_workingdaycompleted>>>> '+check_15_workingdaycompleted);
                    //Date of 20th Working Day
                    Date check_20_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,20); // eachCase.Evidence_Gathering_Start_Date__c.addDays(20);
                    system.debug('check_20_workingdaycompleted>>>> '+check_20_workingdaycompleted);
                    //Date of 25th Working Day 
                    Date check_25_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,25); // eachCase.Evidence_Gathering_Start_Date__c.addDays(25);
                    system.debug('check_25_workingdaycompleted>>>> '+check_25_workingdaycompleted);
                    
                    system.debug('----'+eachCase.Status); 
                    //25 Working Days and status is Evidence gathering agent/landlord and No monies is allocated to the case
                    if((system.today() == check_25_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false) || Test.isRunningTest()){
                        system.debug('++entry25');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch');
                        agllCaseList.add(eachCase);
                    }
                    
                    //20 Working Days and status is Evidence gathering agent/landlord and No monies is allocated to the case
                    else if(system.today() == check_20_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry20');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch1');
                        agllCaseList.add(eachCase);
                    }
                    
                    //15 Working Days and status is Evidence gathering agent/landlord and No monies is allocated to the case
                    else if(system.today() == check_15_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry15');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch2');
                        system.debug('++entry15--');
                        agllCaseList.add(eachCase);
                    }
                    
                    //Email After 10 Working Days and status is Evidence gathering agent/landlord and No monies is allocated to the case
                    else if(system.today() == check_10_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry10');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch3');
                        agllCaseList.add(eachCase);
                    } 
                }
                
                else if(eachCase.Status== 'Awaiting Review' && eachCase.Evidence_Gathering_Start_Date__c==null && eachCase.Stop_chaser_e_mails__c == false){
                    Date check_5_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,5);
                    Date check_10_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,10); 
                    Date check_15_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,15); 
                    Date check_20_workingdaycompleted = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(fromDate,20);
                    
                    if(system.today() == check_5_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry10');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch3');
                        agllCaseList.add(eachCase);
                    } 
                    
                    else if(system.today() == check_10_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry20');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch2');
                        agllCaseList.add(eachCase);
                    }
                    
                    else if(system.today() == check_15_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry15');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch1');
                        system.debug('++entry15--');
                        agllCaseList.add(eachCase);
                    }
                                        
                    else if(system.today() == check_20_workingdaycompleted && eachCase.Stop_chaser_e_mails__c == false){
                        system.debug('++entry15');
                        caseMap.put(eachCase.Id, eachCase);
                        keyMap.put(eachCase.Id, 'FinanceEID30Batch1');
                        system.debug('++entry15--');
                        agllCaseList.add(eachCase);
                    }
                    
                                        
                }
                
                else if(eachCase.Status=='Deposit closed - deposit repaid in part' || eachCase.Status == 'Deposit closed - unable to repay' 
                        || eachCase.Status == 'Decision issued – dispute monies outstanding' || eachCase.Status == 'Decision issued – with legal' 
                        || eachCase.Status == 'Decision issued – Insurance claim' )
                {
                    fromDate = eachCase.Deposit_repaid_Start_Date__c; 
                }
                else if(eachCase.Status == 'Case closed – resolved without adjudication'){
                    fromDate = eachCase.Date_Case_Resolved__c;
                }
                if(eachCase.Status=='Deposit closed - deposit repaid in part' 
                   || eachCase.Status == 'Deposit closed - unable to repay' 
                   || eachCase.Status == 'Decision issued – dispute monies outstanding' || eachCase.Status == 'Decision issued – with legal' 
                   || eachCase.Status == 'Decision issued – Insurance claim' || eachCase.Status == 'Case closed – resolved without adjudication' && eachCase.EWI_Payment_genareted__c > 0 && eachCase.Amount_of_Disputed_Funds_Received__c >0 && eachCase.Amount_of_Disputed_Funds_Received__c >= eachCase.EWI_Payment_genareted__c ){
                       if(fromDate!=null){
                                //EID 118
                                System.debug('Inside 118'+eachCase.Deposit_repaid_Start_Date__c );
                                //Date of 112th Working Day by adding 5 days in Respond Date
                                Date check_112_workingdaycompleted = fromDate.addDays(112); // calculateWorkingDaysBetweenTwoDates(eachCase.Deposit_repaid_Start_Date__c,112);
                                system.debug('Date>>>>'+check_112_workingdaycompleted);
                                //Date of 84th Working Day by adding 5 days in Respond Date
                                Date check_84_workingdaycompleted = fromDate.addDays(84); // calculateWorkingDaysBetweenTwoDates(eachCase.Deposit_repaid_Start_Date__c,84);
                                system.debug('Line 31'+check_84_workingdaycompleted);
                                //Date of 56th Working Day by adding 10 days in Respond Date
                                Date check_56_workingdaycompleted = fromDate.addDays(56); // calculateWorkingDaysBetweenTwoDates(eachCase.Deposit_repaid_Start_Date__c,56);
                                //Date of 28th Working Day by adding 15 days in Respond Date
                                Date check_28_workingdaycompleted = fromDate.addDays(28); // calculateWorkingDaysBetweenTwoDates(eachCase.Deposit_repaid_Start_Date__c,28);
                                System.debug('check_28_workingdaycompleted => ' + check_28_workingdaycompleted);
                                
                                //Deposit closed - deposit repaid in part
                                
                                system.debug('----+++'+eachCase.Status);
                                
                                System.debug('case number ==>'+eachCase.dispute_reference__c);
                                
                                if(system.today() == check_112_workingdaycompleted ){
                                    caseMap.put(eachCase.Id, eachCase);
                                    keyMap.put(eachCase.Id, 'FinanceEID118Batch1'); 
                                }
                                
                                else if(system.today() == check_84_workingdaycompleted ){
                                    caseMap.put(eachCase.Id, eachCase);
                                    keyMap.put(eachCase.Id, 'FinanceEID118Batch2'); 
                                    
                                }
                                
                                else if(system.today() == check_56_workingdaycompleted ){
                                    system.debug('Line>>>>>> 130');
                                    caseMap.put(eachCase.Id, eachCase);
                                    keyMap.put(eachCase.Id, 'FinanceEID118Batch3');
                                    
                                }
                                
                                else if(system.today() == check_28_workingdaycompleted ){
                                    system.debug('Line>>>>>> 125');
                                    caseMap.put(eachCase.Id, eachCase);
                                    keyMap.put(eachCase.Id, 'FinanceEID118Batch4'); 
                                    
                                } 
                                
                            }
                            
                        }
            } 
            
        }
        
        
        
        catch(DmlException ex){
            Insert (new Error_Log__c(Message_Long__c='Issue is: '
                                     + ex.getMessage() + '************ StackTrace String : ' + ex.getStackTraceString()
                                     + ' at Line Number- ' + ex.getLineNumber(),Method_Name__c='Class: EI_EWI_FinanceSendEmail '));
            
            
            
        }
    }  
    global void finish(Database.BatchableContext BC) {
        if(!caseMap.isEmpty() && !keyMap.isEmpty()){
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(caseMap, keyMap);
            helper.sendMailJetEmail(wrapper);
        }
        
     /*   EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
        wrapper.keyMap = keyMap;
        wrapper.newMap = caseMap;
        helper.sendMailJetEmail(wrapper);
        system.debug('agll---'+agllCaseList); */
        if(!agllCaseList.isEmpty()){ EI_EWI_CaseTriggerHandler.process_credit_control(agllCaseList,new Map<Id,Case>(), keyMap, helper.mapSubjects); }
    }
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
   public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays) {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) == 5 || weekStart.daysBetween(currentDate) == 6) {
            return false;
        } else {
            return true;    
        }
    } 
    
        public static Date calculateWorkingDaysBetweenTwoDates2(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
            public static Date calculateWorkingDaysBetweenTwoDates3(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
                public static Date calculateWorkingDaysBetweenTwoDates4(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
                    public static Date calculateWorkingDaysBetweenTwoDates5(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    
}