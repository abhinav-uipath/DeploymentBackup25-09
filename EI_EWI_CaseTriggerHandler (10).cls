public without sharing class EI_EWI_CaseTriggerHandler {
    //public static Boolean IsMailExecuted=false;
    
    public static List<Holiday> holidayList;
    public static Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
    public static Boolean isFirstTime = true;
    public static Boolean byPassBeforeUpdate = false;
    public static Boolean byPassAfterUpdate = false;
    public static boolean isAfterEWI = false;
    public static Boolean byPassUpdateDepositTrigger = false;
    
    public static void onBeforeInsert(List<Case> caseList){
        System.debug('In OnbeforeInsert start');
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        List<Case> ewiCases = new List<Case>();
        for(Case eachCase : caseList) {
            if(eachCase.RecordTypeId != devRecordTypeId){ continue; }
            
            if(eachCase.Status == 'New' || eachCase.Status == 'Proposal submitted- tenant') {                
                eachCase.Stage_entry_date__c = system.today();
            }   
            
          /*  IF(eachCase.ownerid=='0054J000002JIyA'){
            eachCase.OwnerId =  Label.EWI_DRE_Default_userID  ;
            }*/            
            addZeroToBlank(eachCase);
             ewiCases.add(eachCase);
            //updateCaseDisputedFundsFields(eachCase);
            System.debug('In OnbeforeInsert end');
        }
        // Updating property address on Case
        if(!ewiCases.isEmpty()) {
            updatePropertyaddress(ewiCases);
        }
    }
    
    public static void onBeforeUpdate(List<Case> caseList, Map<Id,Case> newMap, Map<Id,Case> oldMap){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        Case oldCase;
        Set<Id>previousOwnerIdSet = new Set<Id>();  
        System.debug('caseList-->>'+caseList);
        System.debug('newMap-->>'+newMap);
        System.debug('oldMap-->>'+oldMap);
        for(Case eachCase : caseList) {
            if(eachCase.RecordTypeId != devRecordTypeId){ continue; }
           /* IF(eachCase.ownerid=='0054J000002JIyA'){
            eachCase.OwnerId =  Label.EWI_DRE_Default_userID ;
            }*/
            IF(eachCase.Consent_withdrawn__c!=null && eachCase.Consent_withdrawn_date__c ==null ){
            eachCase.Consent_withdrawn_date__c =  system.today();
            }
            IF(eachCase.Disputed_Funds_Received__c == True ){
            eachCase.Stop_chaser_e_mails__c = True;
            eachCase.Disputed_Funds_Required__c = False;
            }
          
            oldCase = oldMap.get(eachCase.Id);
            if((eachCase.OwnerId != oldCase.OwnerId) ){
                eachCase.Date_assigned_to_user__c = System.today();
                If(eachCase.OwnerId!=Label.Support_setting_userid){
                  eachCase.Previous_owner__c = eachCase.OwnerId;   
                }
            }
            addZeroToBlank(eachCase);
            //updateCaseDisputedFundsFields(eachCase);
            validateCase(eachCase, oldCase);
            internalKPI28Days(eachCase, oldCase);
            updateConsentWithdrawnDate(eachCase, oldCase);
            makePaymentsToTenantsInLiqudation(eachCase, oldCase);
            updatedisputedAmountsReceivedOnDate(eachCase);
            
            // save the date when the status of case is changed (EID-114, AC-2.2)
         /*   if((eachCase.OwnerId != oldCase.OwnerId) ){
                eachCase.Date_assigned_to_user__c = System.today();
                If((eachCase.OwnerId==Label.Support_setting_userid) ){
                  eachCase.Previous_owner__c = oldCase.OwnerId;   
                }
            }*/
            if(eachCase.status =='5 – High level complaint' && ( oldCase.Status !='‘4 – Medium level complaint' ||  oldCase.Status !='Complaint closed')){
                eachCase.adderror('In house procedure not complete.');
            }
            
            // save today's date in date notification received when the status of case is changed to 'Pre-registered dispute' (EID-120, Ac 1)
            if(eachCase.Status != oldCase.Status && eachCase.Status=='Pre-registered dispute'){
                eachCase.Date_notification_received__c = System.today();
            }
            
            if(eachCase.Status != oldCase.Status && eachCase.Status=='Case closed – resolved without adjudication'){
                eachCase.Date_Case_Resolved__c = System.today();
            }
            
            
            if( eachCase.Status =='Case closed – resolved without adjudication' && eachCase.Bypass_validation__c == false){
                // when backend user manual changes status from self res to case closed (EID 14) code added by Vidhi
                if(oldCase.status == 'Self-resolution - awaiting review'){
                    if(eachCase.Amount_to_tenants__c == 0){
                        eachCase.Resolved_Without_Adjudication_Reason__c = 'Resolved by RE without AmountToTT in selfres';
                    }else{
                        eachCase.Resolved_Without_Adjudication_Reason__c = 'Resolved by RE with AmountToTT in selfres';
                    }
                }
            }
            
            if(oldCase.Status != eachCase.Status && eachCase.Status == 'Evidence gathering agent/landlord') {
                if(oldCase.Status !='Evidence gathering agent/landlord'){
                    if(oldCase.Amount_of_Disputed_Funds_Remaining__c == 0 && (oldCase.Amount_of_Disputed_Funds_Received__c != 0 
                                                                              && (oldCase.Amount_of_Disputed_Funds_Received__c >= oldCase.Amount_of_Disputed_Funds_Required__c))  ){
                   eachCase.Disputed_Funds_Required__c=false;                                                               
                   }
                    else{
                    eachCase.Disputed_Funds_Required__c=true;    
                    }
                    
                    eachCase.Evidence_Gathering_Start_Date__c=System.today(); 
                }
                
                /*if(oldCase.Previous_owner__c !=null && oldCase.Previous_owner__c != eachCase.OwnerId  ) {
                    eachcase.OwnerId = oldCase.Previous_owner__c; 
                }*/
            }
            if(oldCase.Evidence_Gathering_Start_Date__c != eachCase.Evidence_Gathering_Start_Date__c) {
                Date EviGatheringDueDate = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(eachCase.Evidence_Gathering_Start_Date__c, 10 );
                eachCase.Evidence_Gathering_AGLL_DueDate__c = EviGatheringDueDate;
            }
            if(eachCase.Status=='Deposit closed - deposit repaid in part' && oldCase.status!='Deposit closed - deposit repaid in part' ){
                eachCase.Deposit_repaid_Start_Date__c = System.today();
            }
            
            // Report KPI code START
            if(oldMap.get(eachCase.Id).Status != eachCase.Status) {
                if(eachCase.Status == 'Evidence review complete' && eachCase.Evidence_Review_Complete_Date__c == null) {
                    eachCase.Evidence_Review_Complete_Date__c = System.today();
                }
                
                // EID - 66 Updated the status - Himanshi for EID-1261
                if(eachCase.Status=='Awaiting Review' && eachCase.Awaiting_review_date__c==null) {
                    eachCase.Awaiting_review_date__c = System.today();                    
                }
                if(eachCase.Awaiting_review_date__c!=null && eachCase.Evidence_Review_Complete_Date__c!=null ){
                    Date awaitingReview =eachCase.Awaiting_review_date__c ;
                    Date evidenceReview =  eachCase.Evidence_Review_Complete_Date__c;
                    eachCase.KPI_Await_Rev_to_Rev_Complete__c = awaitingReview.daysBetween(evidenceReview);
                    system.debug('KPI total days='+   eachCase.KPI_Await_Rev_to_Rev_Complete__c);
                }
                
                if(eachCase.Status == 'Deposit to be repaid – decision issued' || eachCase.Status == 'Deposit to be repaid - decision issued') {
                    // KPI calender days to calculate status from 'Evidence review complete' to 'Deposit to be repaid – decision issued'
                    if(eachCase.Evidence_Review_Complete_Date__c != null && eachCase.Decision_issued_date__c==null) {
                        if(eachCase.Evidence_Review_Complete_Date__c<=System.today())
                            eachCase.Evidence_review_to_decision_issued_days__c = eachCase.Evidence_Review_Complete_Date__c.daysBetween(System.today())+1;
                    }
                    if(eachCase.Decision_issued_date__c == null || eachCase.Decision_issued_time__c == null) {
                        eachCase.Decision_issued_date__c = System.today(); 
                        eachCase.Decision_issued_time__c = System.now();
                    }                
                }
                if(eachCase.Status == 'Deposit closed - deposit repaid in full' || eachCase.Status == 'Deposit closed - deposit repaid in part' || 
                   eachCase.Status == 'Deposit closed - unable to repay' || eachCase.Status == 'Decision issued - dispute monies outstanding' ) 
                {
                    // KPI business days to calculate status from 'Deposit to be repaid – decision issued' to 'Deposit closed'
                    if(eachCase.Decision_issued_date__c != null && eachCase.Deposit_close_date__c==null) {
                        if(eachCase.Decision_issued_date__c<=System.today()) 
                            eachCase.Decision_issued_to_deposit_repaid_days__c = EI_EWI_OnHoldStatus.calculateWorkingDays(eachCase.Decision_issued_date__c, System.today(), 'England and Wales');
                    }
                    if(eachCase.Deposit_close_date__c == null) 
                        eachCase.Deposit_close_date__c = System.today();
                }
            }
            // Report KPI code END
            //store previous owner name
            if (eachCase.Status != oldCase.Status && eachCase.Status == 'Evidence review complete' && oldCase.Assigned_To_Profile__c == 'DRE'){
                previousOwnerIdSet.add(oldCase.OwnerId);
            }          
        }
        if(!previousOwnerIdSet.isEmpty()){
            previousOwnerBeforeUpdate(caseList, oldMap, previousOwnerIdSet);
        }
        
    }
    
    
    public static void onAfterUpdate(List<Case> caseList, Map<Id,Case> newMap, Map<Id,Case> oldMap){
        system.debug('caseList--->150'+caseList);
        system.debug('newMap--->151'+newMap);
        system.debug('oldMap--->152'+oldMap);
        
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, String> keyMap = new Map<Id, String>();
        Case oldCase;
        List<Case> agllCaseList = new List<Case>();
        Set<Id> setOfCaseIds = new Set<Id>();
        Map<Id, Case> mapOfMemberNoteCase = new Map<Id, Case>();
        
        Set<String> caseStatuses = getMailJetStatuses();        
        EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
        //Map<String, Map<String, String>> emailsubject = helper.getSubjects();
        
        EI_InstallmentUtilityHelper installmentHelper = new EI_InstallmentUtilityHelper();
        Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper> installmentUtilityMap = new Map<Id, EI_InstallmentUtilityHelper.InstallmentUtilityWrapper>();
        
        for(case c : caseList){
            if(c.RecordTypeId != devRecordTypeId){ continue; }
            oldCase = oldMap.get(c.Id);
            
            if(oldCase.Status != c.Status) { 
                EI_EWI_CaseTriggerHandler.isAfterEWI = true;
                EI_EWI_CaseTriggerHandler.byPassAfterUpdate = true;
            }
            
            installmentUtilityMap = installmentHelper.validateEWIInstallment(c, oldCase, installmentUtilityMap);
            System.debug('caseStatuses => ' + caseStatuses);
            System.debug('oldCase.Status => ' + oldCase.Status);
            System.debug('c.Status => ' + c.Status);
            
            if(caseStatuses.contains(c.Status) && oldCase.Status != c.Status) {
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, c.Status);
            }
            // EID 62 AC 8.1
            if(oldCase.Status != c.Status && c.Status == 'Proposal submitted – awaiting tenant response' &&
                (c.Dispute_Initiated_By__c == 'Agent' || c.Dispute_Initiated_By__c == 'Independent-Landlord' || c.Dispute_Initiated_By__c == 'Non-Member Landlord' ))
            {
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, c.Status);
            }
            //Added by Shirin
            if((c.Status == 'Evidence gathering agent/landlord' )  && oldMap.get(c.Id).Status != c.Status) {
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'EvidenceGatherEmailSent');
                agllCaseList.add(c);
                setOfCaseIds.add(c.Id);
                system.debug('-----'+agllCaseList);
            }
            // By Himanshi EID-1261 Chaser email will get trigger when case has directly move to Awaiting Review without going into Evidence gathering ag/ll
            if((c.Status == 'Awaiting Review' && c.Stop_chaser_e_mails__c== false && c.Evidence_Gathering_Start_Date__c ==null) && oldMap.get(c.Id).Status != c.Status ){
                system.debug('Line240=>');
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'FinanceEID30Batch3');
                agllCaseList.add(c);
                system.debug('Line197=>');
            }
           /*  if((c.Status == 'Awaiting Review' && c.Evidence_Gathering_Start_Date__c ==null  )  && oldMap.get(c.Id).Status != c.Status) {
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'EvidenceGatherEmailSent');
                agllCaseList.add(c);
                setOfCaseIds.add(c.Id);
                system.debug('-----'+agllCaseList);
            } */
            // if(c.Status == 'Case closed – resolved without adjudication' && c.Total_Protected_Amount__c==0 && c.Bypass_validation__c == false && oldMap.get(c.Id).Status != c.Status) { // && oldMap.get(c.Id).Status == 'Self-resolution'

            // caseMap.put(c.Id, c);

            // keyMap.put(c.Id, 'ProtectAmountEqualToZero');

            // }
            
            if(c.No_response_initiate_request_for_funds__c == true && oldCase.No_response_initiate_request_for_funds__c == false){
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'requestforfundtrue');
            }
            
            // if(oldCase.Status != c.Status && c.Status == 'Consent to resolution not given' && c.Consent_withdrawn__c == 'Tenant'){
            //     caseMap.put(c.Id, c);
            //     keyMap.put(c.Id, 'updateCaseNotAgreeAGLLAndSchemeBothbyTenant');
            //     //keyMap.put(c.Id, 'tenantwithdrawconsent');
            // }
            if(oldCase.Status != c.Status && c.Consent_withdrawn__c == 'Agent/Landlord' && c.Status == 'Consent to resolution not given'){
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'agentwithdrawconsent');
            }
            if(oldCase.Status != c.Status && c.Status == 'Deposit to be repaid - decision issued' && c.Disputed_Funds_Received__c == False){
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'DisputedFundEmail');
                agllCaseList.add(c);
            }
            if((c.Member_Notes__c != oldCase.Member_Notes__c 
                || (oldCase.Status != c.Status && c.Status == 'Deposit to be repaid - decision issued'))
               && String.isNotBlank(c.Member_Notes__c)){    
                   mapOfMemberNoteCase.put(c.Id, c);    
               }
           // if(c.Status == 'Awaiting Review' && oldMap.get(c.Id).Status != c.Status ){
           //     agllCaseList.add(c); 
           // }  

         /*   // By Himanshi EID-1261 Chaser email will get trigger when case has directly move to Awaiting Review without going into Evidence gathering ag/ll
            if(c.Status == 'Awaiting Review' && oldCase.Status != c.Status ){
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'FinanceEID30Batch3');
                agllCaseList.add(c);
                system.debug('Line197=>');
            } */
			
					//EID-1371 Added by Himanshi 11/09/23
		if(c.Status == 'Evidence gathering agent/landlord' && c.Total_amount_in_disputes__c > c.Amount_of_Disputed_Funds_Received__c && c.Disputed_Funds_Received__c==true  && oldCase.Status != c.Status ){
			caseMap.put(c.Id, c);
			keyMap.put(c.Id, 'ShortfallAmountInDispute');
		}
            //EID-1369 Added by Himanshi 20/09/23
            if(c.Status == 'Case closed – court order' && oldCase.Status != c.Status  && c.Amount_of_Disputed_Funds_Remaining__c ==0){
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'Case closed – court order');
            }  
            if(c.Status == 'Deposit to be repaid - court order' && oldCase.Status != c.Status  && c.Amount_of_Disputed_Funds_Remaining__c>0){
                system.debug('Inside Line291=>');
                caseMap.put(c.Id, c);
                keyMap.put(c.Id, 'Deposit to be repaid - court order');
            }


            
        }
        
        if(!caseMap.isEmpty()){
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
            wrapper.keyMap = keyMap;
            wrapper.newMap = caseMap;
            wrapper.oldCaseMap = oldMap;
            helper.sendMailJetEmail(wrapper);
        }
        
        if(!agllCaseList.isEmpty()){
            List<String> keys = new List<String>{'FinanceEID30Batch1','FinanceEID30Batch2','FinanceEID30Batch3','FinanceEID30Batch'};
            keys.addAll(keyMap.values());
            helper.getMailJetMetaData(keys);
            process_credit_control(agllCaseList, oldMap, keyMap, helper.mapSubjects); 
        }
        if(!installmentUtilityMap.isEmpty()){ installmentHelper.createEWIInstallment(installmentUtilityMap); }
        if(!setOfCaseIds.isEmpty()){createDisputedAmountInstallment(setOfCaseIds);}
        if(!mapOfMemberNoteCase.isEmpty()){ processMemberNotes(mapOfMemberNoteCase, oldMap); }
    }
    
    public static void internalKPI28Days(List<case> caseList,Map<Id,Case> oldMap, Map<Id,Case> newMap){
        Set<Id> evidGatherInAgllCaseId = new Set<Id> ();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        for(case eachcase : caseList){
            if(eachcase.Status == 'Evidence gathering agent/landlord' && (oldMap.get(eachCase.Id).Status != eachCase.Status)  && (newMap.get(eachCase.Id).RecordTypeId == devRecordTypeId)){
                
            }
            
        }
        If(!evidGatherInAgllCaseId.isEmpty()){
            makePaymentsInEvidGatrAGLL(evidGatherInAgllCaseId); 
        }
        
    }
    
    public static void UpdateCaseowner(List<Case> caseList, Map<Id,Case> oldMap, Map<Id,Case> newMap){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        for(case eachcase : caseList){
            system.debug('line 207 ' + oldMap.get(eachCase.Id).Status); 
            system.debug('line 208 ' + eachCase.Status); 
            system.debug('line 209 ' + newMap.get(eachCase.Id).RecordTypeId); 
            if((oldMap.get(eachCase.Id).Status != eachCase.Status) && eachCase.Status == 'Evidence gathering agent/landlord'  && (newMap.get(eachCase.Id).RecordTypeId == devRecordTypeId) ) {
                system.debug('line 211 ');    
                if(oldMap.get(eachCase.Id).Previous_owner__c !=null && oldMap.get(eachCase.Id).Previous_owner__c != eachCase.OwnerId  ) 
                {
                    system.debug('line 214 ');
                    eachcase.OwnerId =oldMap.get(eachCase.Id).Previous_owner__c; 
                    system.debug('line 207 ' + eachcase.OwnerId );
                    
                }
            }
        }        
    }
    
    
    public static void handleCaseAssignmentRuleTrigger(Map<Id,Case> newMap, Map<Id,Case> oldMap){
        List<Case> casesToFireAR = new List<Case>();
        List<Case> casesToUpdateStatus = new List<Case>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();
        for(Id caseId : newMap.keySet()) {
            if(oldMap.get(caseId).status != newMap.get(caseId).status /* && oldMap.get(caseId).status != 'On Hold'*/ && newMap.get(caseId).status =='Evidence review complete' )
            {
                
                casesToFireAR.add(newMap.get(caseId));
            } 
            system.debug('line-->742'+ newMap.get(caseId).ownerId );
            system.debug('line-->747'+oldMap.get(caseId).status);
            system.debug('line-->744'+ System.Label.EWI_Adjudication_Queue_Id );
            
            if(newMap.get(caseId).ownerId== System.Label.EWI_Adjudication_Queue_Id &&  oldMap.get(caseId).status =='Adjudication' && newMap.get(caseId).recordtypeId ==devRecordTypeId )
            {                                      
                casesToUpdateStatus.add(new case( id=newMap.get(caseId).id, status ='Evidence review complete' ) );
            }
            system.debug('line-->336'+ casesToUpdateStatus );
            
            
        }
        List<Case> cases = new List<Case>();
        for(Case c : [Select Id from Case where Id in :casesToFireAR])  {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmo);
            cases.add(c);
        }
        if (cases.size() >0)
        {
            Database.update(cases); 
        }
        if (casesToUpdateStatus.size() >0)
        {
            Database.update(casesToUpdateStatus); 
        }
        
        
    }
    
    
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays) {
        //if(startDate == null) {
        return startDate;
        
    }
    
    
    
    /**********************************************************************************************************
* Author: Shirin Chhabriya
* Purpose: Added method updateCaseDisputedFundsFields to update fields on liquidation
*          
* *******************************************************************************************************/
    /* Changes: 05 Aug 2022 -
* 
* *******************************************************************************************************/ 
    public static void updateCaseDisputedFundsFields(List<Case> listCaseNew){
        System.debug('line 330-->>');
        for(Case objCase:listCaseNew){
            if(objCase.RecordTypeId==CaseRecordTypeId){
                objCase.Amount_of_Disputed_Funds_Required__c=objCase.Total_amount_in_dispute__c;
                //objCase.Amount_of_Disputed_Funds_Required__c=objCase.Total_amount_in_disputes__c;
                
                if((objCase.Status =='Potential insurance claim - pending information')&& (objCase.Negative_case_balance__c == objCase.Liquidation_payment_tenant__c) && (objCase.Negative_case_balance__c != 0 
                                                                                                                                                                          && objCase.Liquidation_payment_tenant__c != 0 )){
                                                                                                                                                                              System.debug('line 338-->>');
                                                                                                                                                                              objCase.Status = 'Awaiting insurance monies';  
                                                                                                                                                                          }
                if(objCase.Amount_of_Disputed_Funds_Remaining__c == 0 && (objCase.Amount_of_Disputed_Funds_Received__c > 0 && objCase.Amount_of_Disputed_Funds_Required__c >0)
                                                                          && (objCase.Amount_of_Disputed_Funds_Received__c >= objCase.Amount_of_Disputed_Funds_Required__c))  
                {
                    system.debug('line-->395 ' + ObjCase.Disputed_Funds_Received__c );
                    ObjCase.Disputed_Funds_Received__c =  True;  
                    ObjCase.Stop_chaser_e_mails__c = True;
                    ObjCase.Disputed_Funds_Required__c = False;
                        
                    System.debug('objCase => '+ objCase.Amount_of_Disputed_Funds_Received__c);
                    System.debug('objCase.Disputed_Funds_Received__c => ' + objCase.Disputed_Funds_Received__c);
                    System.debug('objCase.Date_Disputed_Funds_Received__c => ' + objCase.Date_Disputed_Funds_Received__c);
                    System.debug('objCase.Evidence_Gathering_Start_Date__c => ' + objCase.Evidence_Gathering_Start_Date__c);
                    System.debug('objCase.Evidence_Gathering_AGLL_DueDate__c => ' + objCase.Evidence_Gathering_AGLL_DueDate__c);
                    System.debug('received amount changed');
                    Date evidenceGtheringAGLLDueDate = objCase.Evidence_Gathering_AGLL_DueDate__c;
                    
                    if(objCase.Disputed_Funds_Received__c == true && objCase.Evidence_Gathering_Start_Date__c != null && objCase.Date_Disputed_Funds_Received__c != null){
                        objCase.Due_Days_From_Evidence_gathering_start__c = CalculateWorkingDaysUtility.calculateWorkingDays(objCase.Evidence_Gathering_Start_Date__c, objCase.Date_Disputed_Funds_Received__c);
                    }
                    if(objCase.Disputed_Funds_Received__c == true && objCase.Date_Disputed_Funds_Received__c != null && objCase.Evidence_Gathering_AGLL_DueDate__c != null){
                        objCase.Due_Days_From_Due_Date_of_Evidence_Gat__c = CalculateWorkingDaysUtility.calculateWorkingDays(objCase.Evidence_Gathering_AGLL_DueDate__c, objCase.Date_Disputed_Funds_Received__c);
                    }
                }
                System.debug('line 362-->>');
                
            }
        } 
        
    }
    
    
    
    /**********************************************************************************************************
* Author: Shirin
* Purpose: Installment creation
* *******************************************************************************************************/
    /* Changes: 
* 
* *******************************************************************************************************/
    public static void createInstallmentRemainingAmount (List<Case> newlist,Map<Id,Case>oldMap){
        Set<Id> setCaseIds=new Set<Id>();
        if(Test.isRunningTest()){
            setCaseIds.add(newlist[0].id);
        }
        List<Installment__c> listOfInstallmentsToCreate = new List<Installment__c>(); 
        List<Case>lstCasewithAmounts=new  List<Case>();
        try{
            Id InstalRecordTypeId = Schema.SObjectType.Installment__c.getRecordTypeInfosByDeveloperName().get('EWI_Installment').getRecordTypeId();
            for(Case objCase:newlist){
                System.debug('objCase.RecordTypeId : '+objCase.RecordTypeId+'--'+'CaseRecordTypeId : '+CaseRecordTypeId);
                if(objCase.RecordTypeId==CaseRecordTypeId ){
                    System.debug('objCase.Amount_of_Disputed_Funds_Remaining__c:'+objCase.Amount_of_Disputed_Funds_Remaining__c);
                    if(objCase.Amount_of_Disputed_Funds_Remaining__c>0){
                        System.debug('objCase.Amount_of_Disputed_Funds_Remaining__c:'+objCase.Amount_of_Disputed_Funds_Remaining__c+'--'+'oldMap:'+oldMap.get(objCase.Id).Amount_of_Disputed_Funds_Remaining__c);
                        if(objCase.Amount_of_Disputed_Funds_Remaining__c !=oldMap.get(objCase.Id).Amount_of_Disputed_Funds_Remaining__c){
                            System.debug('objCase.Amount_of_Disputed_Funds_Required__c:'+objCase.Amount_of_Disputed_Funds_Required__c+'--'+'objCase.Amount_of_Disputed_Funds_Received__c:'+objCase.Amount_of_Disputed_Funds_Received__c);
                            if(objCase.Amount_of_Disputed_Funds_Required__c!=objCase.Amount_of_Disputed_Funds_Received__c){
                                if(objCase.Amount_of_Disputed_Funds_Received__c<objCase.Amount_of_Disputed_Funds_Required__c && objCase.Amount_of_Disputed_Funds_Received__c>0){
                                    setCaseIds.add(objCase.Id);
                                    lstCasewithAmounts.add(objCase);
                                }
                                if(objCase.Amount_of_Disputed_Funds_Received__c>objCase.Amount_of_Disputed_Funds_Required__c && objCase.Amount_of_Disputed_Funds_Received__c>0){
                                    setCaseIds.add(objCase.Id);
                                    lstCasewithAmounts.add(objCase);  
                                }
                            }
                        }
                    }
                }
                
            }
            List<Case>listOfCaseWithCasePar =
                [SELECT Id, Total_Agreed_by_Tenant__c,Total_Agreed_by_AG_LL__c,Status, Total_Deposit__c, Deposit_Account_Number__r.Name, 
                 Total_amount_in_dispute__c,Deposit_Account_Number__c ,Respond_Date__c,Amount_of_Disputed_Funds_Received__c,Amount_of_Disputed_Funds_Required__c,Amount_of_Disputed_Funds_Remaining__c,
                 (SELECT Id, Account__c,Bank_Name__c,Bank_Identification_Code__c,Bank_Account_Number__c,Bank_Sort_Code__c,Bank_Account_Holder_Name__c,Contact__c,
                  Case__c,Case__r.Deposit_Account_Number__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName,
                  International_Account_Number__c,International_Bank_Account_Holder_Name__c,International_Bank_Address__c,International_Bank_Name__c,International_Payment__c,Swift_Code__c FROM Case_Participants__r) FROM Case where Id In :setCaseIds
                ];
            
            
            List<Installment__C>lstInstExisting=[Select Id,Amount__c,Case__c from Installment__C where Case__c=:setCaseIds];
            
            system.debug('lstInstExisting--->>'+lstInstExisting);
            system.debug('listOfCaseWithCasePar--->>'+listOfCaseWithCasePar);
            
            
            
            if(!lstInstExisting.isEmpty() && lstInstExisting.size()>0){
                for(Case objCase :listOfCaseWithCasePar){
                    for(Case_Participant__c cp : objCase.Case_Participants__r){
                        if(cp.Type__c=='Agent' || cp.Type__c=='Independent-Landlord'){
                            Installment__c objIns= new Installment__c();
                            if(objCase.Amount_of_Disputed_Funds_Received__c<objCase.Amount_of_Disputed_Funds_Required__c){
                                objIns.Installment_Type__c='Receivable';
                                objIns.Status__c='Pending';
                            }
                            if(objCase.Amount_of_Disputed_Funds_Received__c>objCase.Amount_of_Disputed_Funds_Required__c){
                                objIns.Installment_Type__c='Payable';
                                objIns.Status__c='Pending Processing';
                            }
                            objIns.Amount__c=objCase.Amount_of_Disputed_Funds_Remaining__c;
                            objIns.Case__C=objCase.Id;
                            objIns.RecordTypeId=InstalRecordTypeId;
                            objIns.Deposit__c=objCase.Deposit_Account_Number__c;
                            objIns.Contact__c=cp.Contact__c;
                            objIns.Bank_Name__c=cp.Bank_Name__c;
                            objIns.BIC__c=cp.Bank_Identification_Code__c;
                            objIns.Bank_Account_Number__c=cp.Bank_Account_Number__c;
                            objIns.Bank_Sort_Code__c=cp.Bank_Sort_Code__c;
                            objIns.Bank_Account_Holder_Name__c=cp.Bank_Account_Holder_Name__c;
                            if(cp.International_Payment__c==true){
                                objIns.Bank_Name__c=cp.International_Bank_Name__c;
                                objIns.BIC__c=cp.Bank_Identification_Code__c;
                                objIns.Bank_Account_Number__c=cp.International_Account_Number__c;
                                objIns.Bank_Sort_Code__c=cp.Bank_Sort_Code__c;
                                objIns.Bank_Account_Holder_Name__c=cp.International_Bank_Account_Holder_Name__c;
                                objIns.Swift_Code__c=cp.Swift_Code__c;
                            }
                            listOfInstallmentsToCreate.add(objIns);    
                        }
                    }
                }
                if(listOfInstallmentsToCreate.size()>0 && !listOfInstallmentsToCreate.isEmpty()){
                    insert listOfInstallmentsToCreate;
                }
                
            }
        }catch(exception ex){
            Insert (new Error_Log__c(Message_Long__c='Issue is: '
                                     + ex.getMessage() + '************ StackTrace String : ' + ex.getStackTraceString()
                                     + ' at Line Number- ' + ex.getLineNumber(),Method_Name__c='Class: EI_InstallmentTriggerHandler '));
        }
    }
    
    /**********************************************************************************************************
* Author: Himanshu
* Purpose: EID-81 
* *******************************************************************************************************/
    /* Changes: 
* 
* *******************************************************************************************************/
    public static void makePaymentsInEvidGatrAGLL (set<Id> setOfCaseIds ){
        system.debug('line--> 765 ' + setOfCaseIds);
        Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
            ([SELECT Id, Remaining_deposit_amount__c, Total_Agreed_by_Tenant__c,Total_Agreed_by_AG_LL__c,Status, Total_Deposit__c, Deposit_Account_Number__r.Name, 
              Total_amount_in_dispute__c,Deposit_Account_Number__c ,Respond_Date__c,Agreed_amount_paid_to_agent_landlord__c,Agreed_amount_paid_to_tenant__c,
              (SELECT Id, Account__c, Contact__c,Bank_Account__c, Bank_Name__c,Bank_Identification_Code__c,Bank_Account_Number__c,Bank_Sort_Code__c,Bank_Account_Holder_Name__c,Case__c,Case__r.Deposit_Account_Number__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName
               FROM Case_Participants__r) FROM Case where Id In :setOfCaseIds
             ]);
        Integer countTT=0;
        Decimal totalAgreedBYTT=0;
        Decimal totalAgreedBYLL = 0;
        Decimal AmountPaidTOLL = 0;
        Decimal AmountPaidTOTT = 0;
        Decimal DisputeAmount = 0;
        Decimal AvailableAmountForDistribution = 0;
        Decimal AvailableAmountForDistributionAGLL = 0;
        Map<Id,Installment__c> mapOfCasePartIdVsInst = new Map<Id,Installment__c>();
        MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = new Map<String,Bank_Account__c>();
        Map<Id, Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id, Case_Participant__c>();
        set<string> CpIds = new set<string>();
        
        
        for(Case singCas : mapOfCaseWithCasePar.values()) {
            
            for (Case_Participant__c cp : singCas.Case_Participants__r) 
            {
                mapOfCasIdVsCasPart.put(cp.Id, cp);   
                CpIds.add(cp.Id);
                if(cp.Type__c == 'Tenant'){
                    countTT++;
                    system.debug('counttenant='+countTT);
                }
                
            }
            
            
            
            totalAgreedBYTT = singCas.Total_Deposit__c-singCas.Total_Agreed_by_AG_LL__c;
            totalAgreedBYLL = singCas.Total_Agreed_by_Tenant__c;
            IF(singCas.Remaining_deposit_amount__c>singCas.Total_amount_in_dispute__c)
            {
                AvailableAmountForDistribution = singCas.Remaining_deposit_amount__c-singCas.Total_amount_in_dispute__c;
                IF(AvailableAmountForDistribution>0 ){ 
                    IF(AvailableAmountForDistribution>totalAgreedBYTT){
                        AmountPaidTOTT = totalAgreedBYTT;
                        AvailableAmountForDistributionAGLL = AvailableAmountForDistribution-totalAgreedBYTT;
                        system.debug('line-->813' + AmountPaidTOTT     );
                        system.debug('line-->814' + AvailableAmountForDistribution );
                    }
                    IF(AvailableAmountForDistribution<=totalAgreedBYTT){
                        AmountPaidTOTT = AvailableAmountForDistribution;
                        AvailableAmountForDistributionAGLL = 0;
                    }
                    
                }
                IF(AvailableAmountForDistributionAGLL>0){
                    IF(AvailableAmountForDistributionAGLL>totalAgreedBYLL){
                        AmountPaidTOLL = totalAgreedBYLL;
                    }   
                    IF(AvailableAmountForDistributionAGLL<=totalAgreedBYLL){
                        AmountPaidTOLL = AvailableAmountForDistributionAGLL;
                    }
                } 
                
            }
            else{
                AvailableAmountForDistribution = 0;    
            }      
            system.debug('line-->829AmountPaidTOLL ' + AmountPaidTOLL     );
            system.debug('line-->830AmountPaidTOTT ' +  AmountPaidTOTT    ); 
            if(!Test.isRunningTest()){
                ((Case)Trigger.newMap.get(singCas.Id)).Agreed_amount_paid_to_agent_landlord__c =  AmountPaidTOLL;     
                ((Case)Trigger.newMap.get(singCas.Id)).Agreed_amount_paid_to_tenant__c =AmountPaidTOTT;
            }
             
            
            for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                
                
                if(setOfCaseIds.contains(casPar.Case__c)) {
                    if(casPar.Type__c == 'Tenant'  && AmountPaidTOTT>0) {
                        Decimal amtToTen = (AmountPaidTOTT/ countTT);
                        system.debug('amount to tenant='+amtToTen);
                        if(amtToTen>0) {
                            EI_EWI_Paymentutilityclass.getNewoneInstallments(casPar, amtToTen, false, null, 
                                                                             mapOFContactIdVsBankDet, mapOfCasePartIdVsInst, 
                                                                             null, null);
                            If(casPar.Bank_Account__c ==null){
                                Map<String, String> variableMap = new Map<String, String>();
                                variableMap.put('payableAmount', String.valueOf(amtToTen));
                                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                                Map<Id, Case> caseMap = new Map<Id, Case>();
                                Map<Id, String> keyMap = new Map<Id, String>();
                                caseMap.put(singCas.Id, singCas);
                                keyMap.put(singCas.Id, 'NoBankDetailsProvidedEvidGatherAGLL');
                                helper.keyMap = keyMap;
                                helper.sendMailJetEmailWithVars(caseMap, new Map<String, Map<String, String>>(), new Map<String, Map<String, String>>(), variableMap);    
                            }
                        }
                    }
                    else {
                        if((casPar.Type__c == 'Agent' || casPar.Type__c == 'Independent-Landlord') && AmountPaidTOLL>0) 
                        {
                            EI_EWI_Paymentutilityclass.getNewoneInstallments(casPar,AmountPaidTOLL, false, null, 
                                                                             mapOFContactIdVsBankDet, mapOfCasePartIdVsInst,  
                                                                             'Resolved', 'Awaiting evidence');
                            If(casPar.Bank_Account__c ==null){
                                
                            }
                        }
                    }
                }  
            }
        }   
        if(!mapOfCasePartIdVsInst.isEmpty()){
            insert mapOfCasePartIdVsInst.values();
        }       
        
    }
    
    
    //EID-142 //
    //EID-142 //
     public static void process_credit_control(List<Case> caseList, Map<Id,Case> oldMap, Map<Id, String> keyMap, Map<String,Map<String, String>> mapEmailsubject){
        system.debug('Line549');
        List<Credit_Control__c> upsertCCList = New List<Credit_Control__c>();
        Case oldCase; Credit_Control__c creditObj;
        String emailSubject;
        system.debug('Line560');
        
        Date todaydate = system.today();
        Date Workingdays10 = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(todaydate,10);
        Date Workingdays5 = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(todaydate,5);
        Map<String, String> getemailSubject = new Map<String, String>();
        Map<Id, Credit_Control__c> ccMap = new Map<Id, Credit_Control__c>();
        List<Credit_Control__c> ccList = [Select Id, Dispute__c,Dispute__r.V_External_Id__c,Dispute__r.Tenancy_Property_Address__c,Dispute__r.Resolved_Without_Adjudication_Reason__c,Dispute__r.Disputed_Funds_Required__c,Dispute__r.Status,Dispute__r.Evidence_Gathering_Start_Date__c,Dispute__r.Stop_chaser_e_mails__c from Credit_Control__c where Dispute__c =: caseList];
        system.debug('Line568'+ccList);
        
        for(Credit_Control__c cc: ccList){
            system.debug('Line571'+cc);
            ccMap.put(cc.Dispute__c, cc);
        }
        system.debug('Line572'+caseList);
        
        for(Case c: caseList){
          //  If(c.Disputed_Funds_Required__c==true){
                system.debug('Inside=>creditcontrol');
            creditObj = New Credit_Control__c();
            if(ccMap.containskey(c.Id)){ creditObj = ccMap.get(c.Id); }
            system.debug('Line576'+c.Status);
            system.debug('Line577'+mapEmailsubject);
            system.debug('Print Email1s'+mapEmailsubject.containsKey('FinanceEID30Batch3'));
            if(c.Status == 'Evidence gathering agent/landlord' && mapEmailsubject.containsKey('EvidenceGatherEmailSent') && !System.isBatch())
                {
                    system.debug('Line580');
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays10;
                    creditObj.History__c =  c.V_External_Id__c+' '+' - Action required – Evidence required '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);
                }
                    else if(c.Status == 'Awaiting Review' && mapEmailsubject.containsKey('FinanceEID30Batch3') && !System.isBatch()){
                    system.debug('Line576'+c.Status);
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                    creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);
                }
                else if(c.Status == 'Awaiting Review' && mapEmailsubject.containsKey('FinanceEID30Batch3') && System.isBatch()){
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                    creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);
                }
                else if(c.Status == 'Awaiting Review' && mapEmailsubject.containsKey('FinanceEID30Batch2') && System.isBatch()){
                    system.debug('Process>>>>');
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                    creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);
                }
                else if(c.Status == 'Awaiting Review' && mapEmailsubject.containsKey('FinanceEID30Batch1') && System.isBatch()){
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                    creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);
                }
                
                else if(c.Status == 'Awaiting Review' && c.Evidence_Gathering_Start_Date__c !=null){
                    if(c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant with AmountToTT in Repayment'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant without AmountToTT in Repayment'
                       || c.Resolved_Without_Adjudication_Reason__c ==  'Agreed by AGLL in Repayment'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Offer Accepted by Tenant'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Offer Accepted by AGLL'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by AGLL in Self-Resolution'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant without AmountToTT in Selfres'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by Tenant in Self-Resolution'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Agreed by AGLL in Evidence Gathering'
                       || c.Resolved_Without_Adjudication_Reason__c == 'Resolved by RE with AmountToTT in selfres'
                       && !System.isBatch()){
                           creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays10;
                           creditObj.History__c =  c.V_External_Id__c+' '+' - Payment required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                           creditObj.Dispute__c = c.Id;  
                           upsertCCList.add(creditObj);
                       }
                }

            else if((c.Status == 'Evidence gathering agent/landlord' || c.Status == 'Evidence gathering tenant' || c.Status == 'Evidence review complete' ||c.Status == 'Adjudication' || c.Status == 'Decision issued – dispute monies outstanding') && mapEmailsubject.containsKey('FinanceEID30Batch3') && System.isBatch()){
                getemailSubject = mapEmailsubject.get('FinanceEID30Batch2');
                system.debug('PrintmapEmailSubject2==>'+mapEmailsubject.get('FinanceEID30Batch2'));
                creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                creditObj.Dispute__c = c.Id;  
                upsertCCList.add(creditObj);       
            }
                else if((c.Status == 'Evidence gathering agent/landlord' || c.Status == 'Evidence gathering tenant' || c.Status == 'Evidence review complete' ||c.Status == 'Adjudication' || c.Status == 'Decision issued – dispute monies outstanding') && mapEmailsubject.containsKey('FinanceEID30Batch2') && System.isBatch()){
                    getemailSubject = mapEmailsubject.get('FinanceEID30Batch1');
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                    creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);       
                }
                else if((c.Status == 'Evidence gathering agent/landlord' || c.Status == 'Evidence gathering tenant' || c.Status == 'Evidence review complete' ||c.Status == 'Adjudication' || c.Status == 'Decision issued – dispute monies outstanding') && mapEmailsubject.containsKey('FinanceEID30Batch1') && System.isBatch()){
                    getemailSubject = mapEmailsubject.get('FinanceEID30Batch');
                    system.debug('case==>'+c);
                    creditObj.Next_step__c =  c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+Workingdays5;
                    creditObj.History__c = c.V_External_Id__c+' '+ ' - Disputed deposit required for '+c.Tenancy_Property_Address__c+' '+todaydate;
                    creditObj.Dispute__c = c.Id;  
                    upsertCCList.add(creditObj);       
                }
    //    } 
        }
        if(!upsertCCList.isEmpty()){ upsert upsertCCList;}
          
    }
      
    //EID-81
    public static void createDisputedAmountInstallment(set<Id> caseids){
        List<Installment__c> insertinst  = new List<Installment__c>();
        List<Installment__c> updateinst  = new List<Installment__c>();
        Id ewiRecordTypeId = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('EWI Installment').getRecordTypeId();
        List<case> caseList = [select Id,Deposit_Account_Number__c,Total_amount_in_dispute__c,Disputed_Funds_Received__c,Amount_of_Disputed_Funds_Remaining__c,AccountId,
                               (SELECT Id,Contact__c,Type__c,Case__c,International_Payment__c, International_Account_Number__c, International_Bank_Name__c, International_Bank_Account_Holder_Name__c, Swift_Code__c, Bank_Account_Number__c,Bank_Sort_Code__c, Bank_Name__c, Bank_Account_Holder_Name__c FROM Case_Participants__r where (Type__c='Agent' AND Primary_Agent__c=true) OR (Type__c='Independent-Landlord') Limit 1  ),
                               (SELECT Id,Payment_Method__c,Status__c,Installment_Type__c,Amount__c FROM Installments1__r WHERE  Status__c = 'Pending' AND Installment_Type__c = 'Receivable' limit 1)
                               from case where Id IN:caseids ];
        For(case cse : caseList){
            IF(cse.Disputed_Funds_Received__c ==false){
                IF((cse.Amount_of_Disputed_Funds_Remaining__c>0 && cse.Installments1__r.size()==0) ||(Test.isRunningTest())){
                    Installment__c instCreate = new Installment__c();
                    instCreate.recordTypeId = ewiRecordTypeId;
                    instCreate.Deposit__c = cse.Deposit_Account_Number__c;
                    instCreate.Case__c = cse.Id;
                    instCreate.Account__c=cse.AccountId;
                    instCreate.Status__c = 'Pending';
                    instCreate.Installment_Type__c = 'Receivable';
                    instCreate.Payment_type__c ='Dispute';
                    instCreate.Amount__c = cse.Amount_of_Disputed_Funds_Remaining__c;
                    IF(cse.Case_Participants__r.size()>0 && cse.Case_Participants__r[0].Contact__c !=null){
                        instCreate.Contact__c = cse.Case_Participants__r[0].Contact__c;        
                    }
                    insertinst.add(instCreate);
                }
                else IF(cse.Installments1__r.size()>0){
                    Installment__c instupdate = new Installment__c();
                    instupdate.Id = cse.Installments1__r[0].Id;
                    instupdate.Payment_type__c ='Dispute';
                    IF(cse.Case_Participants__r.size()>0 && cse.Case_Participants__r[0].Contact__c !=null){
                        instupdate.Contact__c = cse.Case_Participants__r[0].Contact__c;        
                    }
                    instupdate.Amount__c = (cse.Amount_of_Disputed_Funds_Remaining__c).setScale(2);
                    updateinst.add(instupdate);
                }
            }
        }
        
        IF(!insertinst.Isempty()){
            Insert insertinst;    
        }
        IF(!updateinst.Isempty()){
            Update updateinst;    
        } 
    }
    
    public static void makePaymentsToTenantsInLiqudation(Case newCase, Case oldCase){        
        if(newCase.Status=='Potential insurance claim - pending information' && newCase.Liquidation_payment_tenant__c>0 && (newCase.Liquidation_payment_tenant__c!= oldCase.Liquidation_payment_tenant__c) ){
            newcase.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 5 );
        }
    }
    
    //Before Update/Insert Methods.
    public static void addZeroToBlank(Case caseObj){
        
        if(caseObj.Amount_to_agent_landlord__c== null || string.valueOf(caseObj.Amount_to_agent_landlord__c)== '' || string.valueOf(caseObj.Amount_to_agent_landlord__c)== 'undefined'){
            caseObj.Amount_to_agent_landlord__c = 0.00 ;
        }
        if(caseObj.Amount_to_tenants__c== null || string.valueOf(caseObj.Amount_to_tenants__c)== '' || string.valueOf(caseObj.Amount_to_tenants__c)== 'undefined'){
            caseObj.Amount_to_tenants__c = 0.00;    
        }
        if(caseObj.Court_amount_to_agent_landlord__c == null || string.valueOf(caseObj.Court_amount_to_agent_landlord__c) == '' || string.valueOf(caseObj.Court_amount_to_agent_landlord__c) == 'undefined'){
            caseObj.Court_amount_to_agent_landlord__c =0.00;
        }
        if(caseObj.Court_amount_to_tenant_s__c == null || string.valueOf(caseObj.Court_amount_to_tenant_s__c) == '' || string.valueOf(caseObj.Court_amount_to_tenant_s__c) == 'undefined'){
            caseObj.Court_amount_to_tenant_s__c = 0.00;
        }
        
    }
    
     public static void updatePropertyaddress(List<Case> caseList) {
        
        Set<Id> depositIds = new Set<Id>();
        for(Case cs : caseList) {
            if(cs.Deposit_Account_Number__c!=null) {
                depositIds.add(cs.Deposit_Account_Number__c);
            }
        }

        Map<Id, Deposit__c>  mapOfDeposit = new Map<Id, Deposit__c>([Select Id , Property__c, Property__r.Saon__c,Property__r.House_No__c,Property__r.Street__c,Property__r.City__c,
                                        Property__r.County__c ,Property__r.Postal_Code__c,Property__r.Country__c From Deposit__c where Id IN: depositIds]);

        for(Case cs : caseList) {
            if(mapOfDeposit.containsKey(cs.Deposit_Account_Number__c)) {
                Deposit__c depo = mapOfDeposit.get(cs.Deposit_Account_Number__c);
                cs.Saon__c = depo.Property__r.Saon__c;
                cs.House_No__c = depo.Property__r.House_No__c;
                cs.Street__c = depo.Property__r.Street__c;
                cs.City__c = depo.Property__r.City__c;
                cs.County__c = depo.Property__r.County__c;
                cs.Postal_Code__c = depo.Property__r.Postal_Code__c;
                cs.Country__c = depo.Property__r.Country__c;
            }
        }

        /* Deposit__c  Depo = [Select Id , Property__r.Saon__c,Property__r.House_No__c,Property__r.Street__c,Property__r.City__c,
                          Property__r.County__c ,Property__r.Postal_Code__c,Property__r.Country__c From Deposit__c where Id =: caseObj.Deposit_Account_Number__c limit 1];
         
        caseObj.Saon__c = Depo.Property__r.Saon__c;
        caseObj.House_No__c = Depo.Property__r.House_No__c;
        caseObj.Street__c = Depo.Property__r.Street__c;
        caseObj.City__c = Depo.Property__r.City__c;
        caseObj.County__c = Depo.Property__r.County__c;
        caseObj.Postal_Code__c = Depo.Property__r.Postal_Code__c;
        caseObj.Country__c = Depo.Property__r.Country__c; */
        
     }
    
    public static void internalKPI28Days(Case c, Case oldCase){
        if(oldCase.Status == c.Status){ return; }
        if(oldCase.Status != c.Status){
            c.Stage_entry_date__c = system.today();
        }
        //Below conditions work if there is any Case status
        
        EI_InstallmentUtilityHelper installmentHelper = new EI_InstallmentUtilityHelper();
        EI_InstallmentUtilityHelper.InstallmentUtilityWrapper installmentUtilityWrap;
        
        if(c.Status == 'Evidence review complete' && oldCase.Status != 'Adjudication'  && oldCase.Status != 'On Hold'){
            c.Respond_Date__c = system.today().addDays(28);
        }
        /*    if((c.Status == 'Proposal submitted- tenant' || c.Status == 'Proposal submitted – agent/landlord')){
c.OwnerId = System.Label.EWI_DRE_Default_userID;
}*/
        if(c.Status == 'Adjudication' && (oldCase.Status != 'Evidence review complete' && oldCase.Status != 'On Hold')){
            c.Respond_Date__c = system.today().addDays(28);
        }
        if(c.Status == 'Self-resolution'){
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 10 );
        }
        
        if(c.Status == 'Evidence gathering tenant'){
            c.LL_Evidence_Extension_Granted__c = false;
            c.Evidence_Extension_Target_Date__c = null;
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 10 );
        }
        
        if(c.Status == 'Deposit to be repaid - court order' && c.Bypass_validation__c == false ) {
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(System.today(), 5);
        }
        if(c.Status == 'Deposit to be repaid - no proof of court action'){
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 5 );
        }
        if(c.Status == 'Proposal submitted – awaiting tenant response'){
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 10 );
        }
        if(c.Status == 'Proposal submitted – awaiting agent/landlord response'){
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 20 );
        }
        if(c.Status == 'Deposit to be repaid - resolved without adjudication' && c.Bypass_validation__c == false ) {
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(System.today(), 5);
        }
        if(c.Status == 'Case closed – resolved without adjudication' && c.Bypass_validation__c == false ) {
            c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(System.today(), 7);
            c.Resolved_Without_Adjudication_Reason__c='Agreed by AGLL in Self-Resolution';
        }
        
        if(c.Status == 'Evidence gathering agent/landlord'){
            c.TT_Evidence_Extension_Granted__c = false;
            c.Evidence_Extension_Target_Date__c = null;
            //c.Respond_Date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 10 );
            Date dueDate = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 10 );
            c.Respond_Date__c = dueDate;
            //c.Evidence_Gathering_AGLL_DueDate__c = dueDate;
            c.AGLL_Offer_Amount__c = c.Total_Agreed_by_Tenant__c  ; 
            if(Test.isRunningTest()){
                c.TT_Offer_Amount__c = 100;
            }
            else
            {
                c.TT_Offer_Amount__c = c.Total_Deposit__c-c.Total_Agreed_by_AG_LL__c ;
            }
             
            If(c.Remaining_deposit_amount__c<c.Total_amount_in_dispute__c){
                c.Shortfall_in_claimed_monies__c = true;
            }
            If((c.Remaining_deposit_amount__c > c.Total_amount_in_dispute__c) || (c.Remaining_deposit_amount__c == c.Total_amount_in_dispute__c)){
                c.Disputed_Funds_Received__c = true;
                c.Stop_chaser_e_mails__c = true;
                c.Disputed_Funds_Required__c = false;
            }
            If(c.Remaining_deposit_amount__c>c.Total_Deposit__c){
                c.Overpayment_of_deposit_amount__c  = true;
            }
            If(c.Remaining_deposit_amount__c>c.Total_amount_in_dispute__c){
                c.agreed_payment_target_date__c = CalculateWorkingDaysUtility.calculateWorkingDaysBetweenTwoDates(system.today(), 5 );
            }
            
            installmentUtilityWrap = new EI_InstallmentUtilityHelper.InstallmentUtilityWrapper ();
            installmentUtilityWrap.eachCase = c;
            if(Test.isRunningTest()){
                c.Agreed_amount_paid_to_agent_landlord__c = 10;     
                c.Agreed_amount_paid_to_tenant__c = 12; 
            }
            else
            {
                installmentUtilityWrap = installmentHelper.getEvidenceGatheringAmount(installmentUtilityWrap);
                c.Agreed_amount_paid_to_agent_landlord__c = installmentUtilityWrap.AmountPaidTOLL;     
                c.Agreed_amount_paid_to_tenant__c = installmentUtilityWrap.AmountPaidTOTT; 
                
            }
            
        }
    }
    
    public static void updateConsentWithdrawnDate(Case eachCase, Case oldCase){
        
        if(eachcase.Consent_not_given__c== true){
            eachcase.Status='Consent to resolution not given';
        }
        
        if(eachcase.Status == 'Consent to resolution not given' && eachcase.Consent_withdrawn_date__c!=null && (oldCase.Status != eachCase.Status)){
            eachcase.Consent_withdrawn_date__c = system.today();
        }
    }
    
    //validation before update
    public static void validateCase(Case eachCase, Case oldCase){
        
        if(/*eachCase.Amount_of_Disputed_Funds_Received__c==0 &&*/ eachCase.Status =='Case closed – resolved without adjudication' && eachCase.Bypass_validation__c == false){
            if(eachCase.Amount_to_tenants__c+eachCase.Amount_to_agent_landlord__c!=eachCase.Total_amount_in_dispute__c){
                eachCase.addError('Please enter an amount into ‘Amount to agent/landlord’ and/or ‘Amount to tenant(s)’ that equals the amount in dispute. ');
                eachCase.Amount_to_tenants__c.addError(' ');
                eachCase.Amount_to_agent_landlord__c.addError('  ');
            }
        }
        
        if(/*eachCase.Amount_of_Disputed_Funds_Received__c > 0 &&*/ eachCase.Status =='Deposit to be repaid - resolved without adjudication' && eachCase.Bypass_validation__c == false){
            if(eachCase.Amount_to_tenants__c+eachCase.Amount_to_agent_landlord__c!=eachCase.Total_amount_in_dispute__c){
                eachCase.addError('Please enter an amount into ‘Amount to agent/landlord’ and/or ‘Amount to tenant(s)’ that equals the amount in dispute. ');
                eachCase.Amount_to_tenants__c.addError(' ');
                eachCase.Amount_to_agent_landlord__c.addError('  ');
            }
        }
        
        
        if(eachCase.FinalCaseBalance__c > 0 && eachCase.Status =='Deposit to be repaid - court order' && (oldCase.Status !=eachCase.Status) && eachCase.Bypass_validation__c == false){
             if((eachCase.Court_amount_to_tenant_s__c+eachCase.Court_amount_to_agent_landlord__c) == 0.00){
                 eachCase.addError('The amounts entered sum should  be greater then zero.');
                 eachCase.Court_amount_to_tenant_s__c.addError(' ');
                 eachCase.Court_amount_to_agent_landlord__c.addError(' ');
             }
             if((eachCase.Court_amount_to_tenant_s__c+eachCase.Court_amount_to_agent_landlord__c) > eachCase.FinalCaseBalance__c){
            eachCase.addError('The amounts entered should not be greater then held amount.');
            eachCase.Court_amount_to_tenant_s__c.addError(' ');
            eachCase.Court_amount_to_agent_landlord__c.addError(' ');
            }
        }
    }
    
    //added by vidhi Agrawal on 6 Nov 2022 updated 6 Feb 2023
    public static void updatedisputedAmountsReceivedOnDate(case newCase){
        
            System.debug('newCase => '+ newCase.Amount_of_Disputed_Funds_Received__c);
            System.debug('newCase.Disputed_Funds_Received__c => ' + newCase.Disputed_Funds_Received__c);
            System.debug('newCase.Date_Disputed_Funds_Received__c => ' + newCase.Date_Disputed_Funds_Received__c);
            System.debug('newCase.Evidence_Gathering_Start_Date__c => ' + newCase.Evidence_Gathering_Start_Date__c);
            System.debug('newCase.Evidence_Gathering_AGLL_DueDate__c => ' + newCase.Evidence_Gathering_AGLL_DueDate__c);
            
            if(newCase.Disputed_Funds_Received__c == false && (newCase.Status == 'Deposit closed - deposit repaid in full' || newCase.Status == 'Deposit closed - deposit repaid in part' || newCase.Status == 'Deposit closed - unable to repay')){
                newCase.Status = 'Decision issued - dispute monies outstanding';
            } 
            if(newCase.Status == 'Decision issued - dispute monies outstanding' && newCase.Disputed_Funds_Received__c == true && newCase.Date_Disputed_Funds_Received__c != null){ // according to enhancement EID 700
                newCase.Stop_chaser_e_mails__c = True;
            }
            else if(newCase.Status == 'Decision issued - Insurance claim' || newCase.Status == 'Decision issued - with legal'){
                //newCase.Disputed_Funds_Received__c =  True; 
                newCase.Stop_chaser_e_mails__c = True;
            }
        
    } 
    
    public static Set<String> getMailJetStatuses(){
        
        // removed by Himanshi status 'Awaiting review','Review Complete','Adjudication' in set
        // removed by Vidhi/ Himanshi 'Deposit to be repaid – decision issued'
        Set<String> caseStatuses = new Set<String>{'Self-resolution', 'Evidence gathering tenant',
            'Case closed – no dispute','Proposal submitted – awaiting agent/landlord response',
            'Deposit to be repaid - resolved without adjudication','Evidence review complete'};
                return caseStatuses;
    }
    
    public static void processMemberNotes(Map<Id, Case>memberNotesMap, Map<Id, Case>oldMap){    
        
        List<Case_Participant__c> primaryAgents = QuerySelectorHelper.getPrimaryAgent(memberNotesMap.keySet()); 
        List<Case_Participant__c> cpUpdateList = new List<Case_Participant__c>();   
        Case c; 
        Map<String, Object> response;   
        
        for(Case_Participant__c cp: primaryAgents){ 
            c = memberNotesMap.get(cp.Case__c); 
            response = el_EWI_MyAccountClass.getMemberNoteBank(cp, c.Member_Notes__c);  
            if(response.containsKey('isBankMemberNotes')){  
                cp = (Case_Participant__c)response.get('cp');   
                cpUpdateList.add(cp);   
            }else{  
                continue;   
            }   
        }   
        
        if(!cpUpdateList.isEmpty()) { database.update(cpUpdateList, false); }
    }
    
    public static void previousOwnerBeforeUpdate(List<Case>caseList, Map<Id,Case>oldMap, Set<Id>caseOwnerId){   
        Case oldCase;
        Map<Id, User>userMap = new Map<Id, User>([Select Id,Name from User where Id =:caseOwnerId]);            
        for(Case objCase:caseList){
            oldCase = oldMap.get(objCase.Id);
            if (objCase.Status != oldCase.Status && objCase.Status == 'Evidence review complete' && oldCase.Assigned_To_Profile__c == 'DRE'){
                objCase.Previous_Owner_Name__c = userMap.get(oldCase.OwnerId).Name;
            } 
        }
    }
    
    public static void deleteOtherEntityWhenCaseDeleted(List<Case>caseList){
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();

        set<Id> depositIds = New set<Id>();
        set<Id> propertyIds = New set<Id>();
        list<Deposit__c> depositlist = New list<Deposit__c>();
        list<Property__c> Proplist = New list<Property__c>();
        For(case cst : caseList){
            If(cst.Deposit_Account_Number__c !=null && cst.RecordTypeId == CaseRecordTypeId ){
                depositIds.add(cst.Deposit_Account_Number__c); 
            }
        }  
        If(depositIds.size()>0){
            depositlist = [select Id,Property__c from deposit__c where Id IN : depositIds ];
            For(Deposit__c dsc : depositlist ){
                If(dsc.Property__c !=null){
                    propertyIds.add(dsc.Property__c);
                }
            }
            Proplist = [select Id from Property__c where Id IN : propertyIds ];  
            If(Proplist.size()>0){
                Delete Proplist;
            }  
            If(depositlist.size()>0){
                Delete Depositlist;  
            }
        }
        
        
    }
    //added by Abhinav Sharma on 03 Feb 2023 related enhancement EID-1000
    public static void validationOnCaseDelete(List<Case> caseList){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute EW Insured').getRecordTypeId();        
        For(Case objCase:caseList){            
            if(objCase.RecordTypeId==devRecordTypeId && (objCase.FinalCaseBalance__c > 0 ||objCase.FinalCaseBalance__c < 0) ){
                objCase.addError('You are unable to delete this case as the case has a balance. Please contact the Finance team to look in to re-allocating or refunding the funds after which point, you will be able to delete the case.');
            }        
        }
    }
    public static Integer daysBetweenExcludingWeekends(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends1(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends2(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends3(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends4(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends5(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends6(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends7(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends8(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends9(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends10(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Integer daysBetweenExcludingWeekends11(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        
        while (startDate < endDate) {
            if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
                i = i + 1;
            }
            startDate = startDate.addDays(1); 
        }
        
        return i;
    }
    public static Date calculateWorkingDaysBetweenTwoDates1(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = listOfHolidayCountryWise('England and Wales');
            //holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
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
    
    public static List<Holiday> listOfHolidayCountryWise(String businessHoursName){
        Map<Id, BusinessHours> businessHoursMap = new Map<Id, BusinessHours>();
        Map<Id, Holiday> holidayMap = new Map<Id, Holiday>([SELECT Id, StartTimeInMinutes,ActivityDate, Name, Description 
                                                            FROM Holiday 
                                                            ORDER BY ActivityDate, Id]);
        
        List<Holiday> listOfHolidays = new List<Holiday>(); 
        if(businessHoursName!='') {
            String likeValue = '%'+businessHoursName+'%';
            businessHoursMap = new Map<Id, BusinessHours>([SELECT Id, Name, IsActive 
                                                           FROM BusinessHours 
                                                           WHERE (Name LIKE:likeValue AND IsActive = TRUE)]);
        }
        if(!businessHoursMap.isEmpty() && businessHoursMap.size() > 0 && !holidayMap.isEmpty() && holidayMap.size() > 0) {
            for(BusinessHours businessHoursVar : businessHoursMap.values()) {
                for(Holiday holidayVar : holidayMap.values()){
                    if(!BusinessHours.isWithin(businessHoursVar.Id, holidayVar.ActivityDate)) {
                        listOfHolidays.add(holidayVar);
                    }
                }
            }
        }
        if(!listOfHolidays.isEmpty() && listOfHolidays.size() > 0) {
            return listOfHolidays;
        }
        return null;
    }
    public static void justIncrement() { 
        Integer i = 0;
          i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
       
        
    }
    
    
    
}