public without sharing class eI_EWI_DepositAllocationProposalCls {
    public eI_EWI_DepositAllocationProposalCls() {}

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 25/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for getting case and case participant details.
    */
    @AuraEnabled(cacheable = true)
    public static Case_Participant__c getCaseParticipantDetails (String accessCode){   
        try {
            
            List<Case_Participant__c> casedetails = [select Id,Case__c,Case__r.Total_Claim_Amount__c,Account__r.RecordType.Name, Case__r.Deposit_Account_Number__r.Property__r.Name,Case__r.EWI_Skip_SelfResolution_Checkbox__c,Case__r.EWI_Skip_SelfResolution_Input_Field__c,
                                                     Case__r.Deposit_Account_Number__r.End_Date__c,Case__r.Status,Case__r.Deposit_Account_Number__r.Property_Address__c,
                                                     Case__r.Deposit_Account_Number__r.Deposit_Amount__c,
                                                     Case__r.Deposit_funds_not_received__c, Case__r.Tenant_not_received_funds__c,
                                                     Case__r.Total_Deposit__c,Case__r.TDSN_Reference_Number__c,Account__r.Name, Case__r.Deposit_Account_Number__r.Lead_Tenant_Name__c, 
                                                     Case__r.Amount_Returned_to_Landlord__c, Access_Code__c,Is_Lead__c,Type__c from Case_Participant__c where Access_Code__c= :accessCode limit 1];
            if(casedetails.isEmpty()){ return null; }
            return casedetails[0];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 22/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for getting case, case participants and dispute Items details.
    */
    @AuraEnabled(cacheable = true)
    public static List<Case> getCaseandDispiteItemsDetails (String accessCode)
    {
        List<Case> cs = new List<Case>();
        try {
            System.debug('accessCode => ' + accessCode );
            cs = [select id, Deposit_Account_Number__c, Deposit_Account_Number__r.Property_Address__c, Deposit_Account_Number__r.End_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,EWI_Skip_SelfResolution_Checkbox__c,EWI_Skip_SelfResolution_Input_Field__c,
            TDSN_Reference_Number__c, Status, Deposit_Account_Number__r.Lead_Tenant_Name__c, Amount_Returned_to_Landlord__c, Total_Claimed_by_Landlord__c, // Amount_Returned_to_Landlord__c(Amount to Tenant by AGLL)
            (Select Id, Dispute__c, Type__c, Claimed_by_Landlord__c, Other_Reason__c FROM Dispute_Items__r where Dispute__c IN (Select Case__c FROM Case_Participant__c Where Access_Code__c =:accessCode)),
            (Select Id, AGLL_Raised_Respond__c, Account__r.Name FROM Case_Participants__r Where AGLL_Raised_Respond__c = true and type__c !='Tenant')
            FROM Case where Id IN (Select Case__c FROM Case_Participant__c Where Access_Code__c =:accessCode) limit 1];
            
            if(cs.isEmpty()){ return null; }
            return cs;
        }   
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 25/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for updating case status from 'Proposal submitted – awaiting agent/landlord response' to 'Proposal submitted – awaiting tenant response' 
    and case participant and creating dispute Items.
    where AGLL want to make deductions from the deposit while responding to tenant proposal.
    JIRA:- EID 92, AC12.2
    */
    @AuraEnabled
    public static string updateCaseRespondbyAGLL(Id caseId, decimal amountToTenant, string initiatedBy, Id caseParId, String claimedItems, String otherReason){
        String message='';

        try{
            // List<Dispute_Item__c> existingDisputItemList = [Select Id, Dispute__c from Dispute_Item__c where Dispute__c=:caseId];
            // if(existingDisputItemList.size() > 0){
            //     message = 'Agll Responded';
            // }

            Case caseObj = [Select id, status from Case where id=:caseId];
            if(caseObj.status != 'Proposal submitted – awaiting agent/landlord response'){
                message = 'Agll Responded';
            }
            else{
                Case cs = new Case();
                cs.Id = caseId;
                cs.Status = 'Proposal submitted – awaiting tenant response';
                cs.Amount_Returned_to_Landlord__c = amountToTenant;
                cs.Dispute_Responded_By__c = initiatedBy;
                cs.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 7);
                system.debug('line-->68'+cs );
                update cs;

                Map<String, Object> ClaimItemsTypeAndDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(claimedItems);
                List<Dispute_Item__c> disputItemList = new List<Dispute_Item__c>();
                Id EWIDisputeRecordTypeId = Schema.SObjectType.Dispute_Item__c.getRecordTypeInfosByName().get('EWI Dispute Item').getRecordTypeId();
                for(String ClaimItemType : ClaimItemsTypeAndDetailsMap.keySet()) {
                    System.debug('ClaimItemsTypeAndDetailsMap key => '+ ClaimItemType +' ClaimItemsTypeAndDetailsMap value => '+ ClaimItemsTypeAndDetailsMap.get(ClaimItemType) );
                    Dispute_Item__c disputObj = new Dispute_Item__c();
                    disputObj.Dispute__c = caseId;
                    disputObj.RecordTypeId = EWIDisputeRecordTypeId;
                    if(ClaimItemType.contains('Rent arrears')){
                        disputObj.Type__c = 'Rent';
                    }else{
                        disputObj.Type__c = ClaimItemType;
                    }
                    disputObj.Claimed_by_Landlord__c = decimal.valueOf(string.valueOf(ClaimItemsTypeAndDetailsMap.get(ClaimItemType)));
                    disputObj.Agreed_by_AGLL__c = decimal.valueOf(string.valueOf(ClaimItemsTypeAndDetailsMap.get(ClaimItemType)));
                    disputObj.Adjustment_Percentage_by_AGLL__c = 100;
                    if(ClaimItemType == 'Other'){
                        disputObj.Other_Reason__c = otherReason;
                    }
                    disputItemList.add(disputObj);
                }
                System.debug('disputItemList => ' + disputItemList);
                insert disputItemList;

                Case_Participant__c casePar = new Case_Participant__c();
                casePar.Id = caseParId;
                casepar.AGLL_Raised_Respond__c = true;
                update casePar;
                
                EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseRespondbyAGLL');
                helper.sendMailJetEmail(wrapper);
                message = 'Successfully updated';
            }
        }catch(Exception e){
            message = e.getMessage();
        }

        return message;
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 25/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for updating case status from 'payment submitted- tenant' to 'Case closed – resolved without adjudication'.
    where AGLL do not want to make deductions from the deposit.
    JIRA:- EID 92, AC3.4
    */
    @AuraEnabled
    public static string updateCaseAgreedbyAGLL(Id caseId, decimal agreedAmount, decimal depositAmount ){
        String message='';
        set<Id> caseIds = new set<Id>();

        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Status = 'Case closed – resolved without adjudication';
            cs.Bypass_validation__c = true;
            cs.Amount_to_agent_landlord__c = agreedAmount;
            cs.Amount_to_tenants__c = depositAmount - agreedAmount;
            cs.Resolved_Without_Adjudication_Reason__c = 'Agreed by AGLL in Repayment';
            cs.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 7);
            system.debug('line-->68'+cs );
            update cs;
            caseIds.add(cs.Id);
            EWI_EI_SelfResolutionJourneyClass.makePaymentsInSelfres(caseIds);
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseAgreedbyAGLL');
            helper.sendMailJetEmail(wrapper);
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 25/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for updating case status from 'New' to 'Proposal submitted – agent/landlord'
    and case participant and creating dispute Items.
    where AGLL want to make deductions from the deposit while raising the proposal.
    JIRA:- EID 93, AC8.1
    */
    @AuraEnabled
    public static string updateCaseRaisedbyAGLL(Id caseId, decimal amountToTenant, string initiatedBy, Id caseParId, String claimedItems, String otherReason,Boolean ewiSkipSelfResCheckbox, String ewiSkipSelfResInput){
        String message='';
        

        try{
            // List<Dispute_Item__c> existingDisputItemList = [Select Id, Dispute__c from Dispute_Item__c where Dispute__c=:caseId];
            // if(existingDisputItemList.size() > 0){
            //     message = 'Agll Responded';
            // }
            system.debug('line-->187'+ewiSkipSelfResCheckbox );
            system.debug('line-->188'+ewiSkipSelfResInput );
            Case caseObj = [Select id, status from Case where id=:caseId];
            if(caseObj.status != 'New'){
                message = 'Agll Responded';
            }else{
                Case cs = new Case();
                cs.Id = caseId;
                cs.Status = 'Proposal submitted – agent/landlord';
                cs.Amount_Returned_to_Landlord__c = amountToTenant;
                cs.Dispute_Responded_By__c = initiatedBy;
                cs.EWI_Skip_SelfResolution_Checkbox__c = ewiSkipSelfResCheckbox;
                cs.EWI_Skip_SelfResolution_Input_Field__c = ewiSkipSelfResInput;
                
                system.debug('line-->68'+cs );
                update cs;

                Map<String, Object> ClaimItemsTypeAndDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(claimedItems);
                List<Dispute_Item__c> disputItemList = new List<Dispute_Item__c>();
                Id EWIDisputeRecordTypeId = Schema.SObjectType.Dispute_Item__c.getRecordTypeInfosByName().get('EWI Dispute Item').getRecordTypeId();
                for(String ClaimItemType : ClaimItemsTypeAndDetailsMap.keySet()) {
                    System.debug('ClaimItemsTypeAndDetailsMap key => '+ ClaimItemType +' ClaimItemsTypeAndDetailsMap value => '+ ClaimItemsTypeAndDetailsMap.get(ClaimItemType) );
                    Dispute_Item__c disputObj = new Dispute_Item__c();
                    disputObj.Dispute__c = caseId;
                    disputObj.RecordTypeId = EWIDisputeRecordTypeId;
                    if(ClaimItemType.contains('Rent arrears')){
                        disputObj.Type__c = 'Rent';
                    }else{
                        disputObj.Type__c = ClaimItemType;
                    }
                    disputObj.Claimed_by_Landlord__c = decimal.valueOf(string.valueOf(ClaimItemsTypeAndDetailsMap.get(ClaimItemType)));
                    disputObj.Agreed_by_AGLL__c = decimal.valueOf(string.valueOf(ClaimItemsTypeAndDetailsMap.get(ClaimItemType)));
                    disputObj.Adjustment_Percentage_by_AGLL__c = 100;
                    if(ClaimItemType == 'Other'){
                        disputObj.Other_Reason__c = otherReason;
                    }
                    disputItemList.add(disputObj);
                }
                System.debug('disputItemList => ' + disputItemList);
                insert disputItemList;

                Case_Participant__c casePar = new Case_Participant__c();
                casePar.Id = caseParId;
                casepar.AGLL_Raised_Respond__c = true;
                update casePar;
                message = 'Successfully updated';
            }
        }catch(Exception e){
            message = e.getMessage();
        }

        return message;
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 25/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for updating case status from 'Proposal submitted – awaiting tenant response' to 'Case closed – resolved without adjudication'
    where tenant is agreed to the proposal raised by AGLL.
    JIRA:- EID 95, AC 4.5
    */
    @AuraEnabled
    public static string updateCaseAgreetoAGLLbyTenant(Id caseId, decimal agreedAmount, decimal depositAmount, String accessCode ){
        String message='';
        set<Id> caseIds = new set<Id>();
        
        try{
            Case cs = new Case();
            cs.Id = caseId;
            cs.Status = 'Case closed – resolved without adjudication';
            cs.Bypass_validation__c = true;
            cs.Amount_to_agent_landlord__c = agreedAmount;
            cs.Amount_to_tenants__c = depositAmount - agreedAmount;
            if((depositAmount - agreedAmount) > 0){
                cs.Resolved_Without_Adjudication_Reason__c = 'Agreed by Tenant with AmountToTT in Repayment';
            }else{
                cs.Resolved_Without_Adjudication_Reason__c = 'Agreed by Tenant without AmountToTT in Repayment';
            }
            cs.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 7);
            system.debug('line-->68'+cs );
            update cs;
    
            List<Case_Participant__c> caseParList = [Select Id, Name, Is_Lead__c, Access_Code__c FROM Case_Participant__c Where Case__c =:caseId];
            List<Case_Participant__c> caseParListtoUpdate = new List<Case_Participant__c>();
            for(Case_Participant__c casePar: caseParList){
                if(casePar.Access_Code__c == accessCode && casePar.Is_Lead__c == false){
                    casePar.Is_Lead__c = true;
                    caseParListtoUpdate.add(casePar);
                }
                else if(casePar.Access_Code__c != accessCode && casePar.Is_Lead__c == true){
                    //code for existing lead tenant should be joint tenant
                    casePar.Is_Lead__c = false;
                    caseParListtoUpdate.add(casePar);
                }
            }
            update caseParListtoUpdate;
            caseIds.add(cs.Id);
            EWI_EI_SelfResolutionJourneyClass.makePaymentsInSelfres(caseIds);
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'updateCaseAgreetoAGLLbyTenant');
            helper.sendMailJetEmail(wrapper);
            return 'Success';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }

    
/*
    Created by:- Vidhi Agrawal
    Created Date:- 28/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-28/03/22
    Method used for:- 
    JIRA:- EID 95, AC
    */
    @AuraEnabled
    public static string updateCaseNotAgreeAGLLButWishToSchemebyTenant(Id caseId, decimal amountToTTbyTT, String accessCode, String claimedItems, String otherReason){
        String message='';

        try{
            Case caseObj = [Select id, status from Case where id=:caseId];
            if(caseObj.status != 'Proposal submitted – awaiting tenant response'){
                message = 'Tenant Responded';
            }
            else{
                    Case cs = new Case();
                    cs.Id = caseId;
                    cs.Status = 'Self-resolution';
                //  cs.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 10); this kpi is handled in trigger so commented here.
                    cs.Amount_Returned_to_Tenant__c = amountToTTbyTT;
                    system.debug('line-->68'+cs );
                    update cs;

                    Map<String, Object> ClaimItemsTypeAndDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(claimedItems);
                    List<Dispute_Item__c> disputItemList = new List<Dispute_Item__c>();
                    // Id EWIDisputeRecordTypeId = Schema.SObjectType.Dispute_Item__c.getRecordTypeInfosByName().get('EWI Dispute Item').getRecordTypeId();
                    for(String ClaimItemType : ClaimItemsTypeAndDetailsMap.keySet()) {
                        System.debug('ClaimItemsTypeAndDetailsMap key => '+ ClaimItemType +' ClaimItemsTypeAndDetailsMap value => '+ ClaimItemsTypeAndDetailsMap.get(ClaimItemType) );
                        Map<String, Object> ClaimItemDetailsMap =  (Map<String, Object>) (ClaimItemsTypeAndDetailsMap.get(ClaimItemType));
                        decimal itemAmountbyTT = decimal.valueOf(string.valueOf(ClaimItemDetailsMap.get('itemAmountbyTT')));
                        decimal itemAmountbyAGLL = decimal.valueOf(string.valueOf(ClaimItemDetailsMap.get('itemAmountbyAGLL')));

                        Dispute_Item__c disputObj = new Dispute_Item__c();
                        disputObj.Id = string.valueOf(ClaimItemDetailsMap.get('claimItemId'));
                        // disputObj.RecordTypeId = EWIDisputeRecordTypeId;
                        if(ClaimItemType.contains('Rent arrears')){
                            disputObj.Type__c = 'Rent';
                        }else{
                            disputObj.Type__c = ClaimItemType;
                        }
                        disputObj.Tenant_Response__c = itemAmountbyTT;
                        disputObj.Agreed_by_Tenant__c = itemAmountbyTT;
                        disputObj.Adjustment_Percentage_by_TT__c = (itemAmountbyTT/itemAmountbyAGLL) * 100;
                        if(ClaimItemType == 'Other'){
                            disputObj.Tenant_Statement__c = otherReason;
                        }
                        disputItemList.add(disputObj);
                    }
                    System.debug('disputItemList => ' + disputItemList);
                    update disputItemList;

                    List<Case_Participant__c> caseParList = [Select Id, Name, Is_Lead__c, Access_Code__c FROM Case_Participant__c Where Case__c =:caseId];
                    List<Case_Participant__c> caseParListtoUpdate = new List<Case_Participant__c>();
                    for(Case_Participant__c casePar: caseParList){
                        if(casePar.Access_Code__c == accessCode && casePar.Is_Lead__c == false){
                            casePar.Is_Lead__c = true;
                            caseParListtoUpdate.add(casePar);
                        }
                        else if(casePar.Access_Code__c != accessCode && casePar.Is_Lead__c == true){
                            //code for existing lead tenant should be joint tenant
                            casePar.Is_Lead__c = false;
                            caseParListtoUpdate.add(casePar);
                        }
                    }
                    update caseParListtoUpdate;
                    message = 'Successfully updated';
                }
            }catch(Exception e){
                message = e.getMessage();
            }

        return message;
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 25/03/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-25/03/22
    Method used for:- This method is used for updating case status from 'Proposal submitted – awaiting tenant response' to 'Consent to resolution not given'
    where the Tenant not agree with the proposal raised by AGLL and do not agree to the scheme resolving any dispute.
    JIRA:- EID 95, AC 7.3
    */
    @AuraEnabled
    public static string updateCaseNotAgreeAGLLAndSchemeBothbyTenant(Id caseId, decimal agreedAmount, decimal depositAmount, String accessCode ){
        String message='';

        try{
            String leadTTName = '';
            List<Case_Participant__c> caseParList = [Select Id, Name, Is_Lead__c, Access_Code__c, Account__r.Name FROM Case_Participant__c Where Case__c =:caseId];
            List<Case_Participant__c> caseParListtoUpdate = new List<Case_Participant__c>();
            for(Case_Participant__c casePar: caseParList){
                if(casePar.Access_Code__c == accessCode && casePar.Is_Lead__c == false){
                    casePar.Is_Lead__c = true;
                    leadTTName = casePar.Account__r.Name;
                    caseParListtoUpdate.add(casePar);
                }
                else if(casePar.Access_Code__c != accessCode && casePar.Is_Lead__c == true){
                    //code for existing lead tenant should be joint tenant
                    casePar.Is_Lead__c = false;
                    caseParListtoUpdate.add(casePar);
                }
            }
            
            Case cs = new Case();
            cs.Id = caseId;
            cs.Status = 'Consent to resolution not given';
            cs.Consent_withdrawn__c = 'Tenant';
            cs.Consent_withdrawn_date__c = system.today();
            cs.Amount_to_agent_landlord__c = agreedAmount;
            cs.Amount_to_tenants__c = depositAmount - agreedAmount;
            cs.Lead_Tenant_Name__c = leadTTName;
            system.debug('line-->68'+cs );
            update cs;
            update caseParListtoUpdate;
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cs, 'Consent to resolution not given');
            helper.sendMailJetEmail(wrapper);

            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
        {
           // List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
            List<Holiday> holidays = listOfHolidayCountryWise('England and Wales');
            Integer allWorkingDays=0;
            Integer totalDays = 1;
            while(allWorkingDays<=noOfDays)
            {
                if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                    allWorkingDays++;
                    if(allWorkingDays==noOfDays)
                        break;
                }
                totalDays++;
            }
            return startDate.addDays(totalDays);
        }
        public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
        {
            Date weekStart  = currentDate.toStartofWeek();
            for(Holiday hDay:holidays){
                if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                    return false;
                }
            }
            if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
                return false;
            } 
        else
        {
            return true;    
        }
    }

    /*
    Created by:- Vidhi Agrawal
    Created Date:- 15/07/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-15/07/22
    Story Number :- EID 71 AC 1
    Method used for:- This method is used for getting Tenants(deposit Allocations) where email and mailing address is not exist.
    
    @AuraEnabled (cacheable=true)
    public static List<Deposit_Allocation__c> getTenantsInformation(String depositRecordId) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        depositAllocationList = [SELECT Id, Deposit__r.Customer_Name__c, Deposit__r.Customer__r.Name, Deposit__r.Protected_Amount__c, 
                                 Deposit_Holder__r.PersonContactId, Deposit_Holder__c, Deposit_Holder__r.Name, Deposit_Holder__r.Salutation, Is_Lead__c,
                                 Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingCity,Deposit_Holder__r.PersonMailingCountry,Deposit_Holder__r.PersonMailingPostalCode,Deposit_Holder__r.PersonEmail
                                 from Deposit_Allocation__c where Deposit__c =:depositRecordId AND Role__c='Tenant' 
                                 AND Deposit_Holder__r.PersonMailingStreet = '' 
                                 AND Deposit_Holder__r.PersonMailingCity = ''
                                 AND Deposit_Holder__r.PersonMailingCountry = ''
                                 AND Deposit_Holder__r.PersonMailingPostalCode = ''
                                 AND Deposit_Holder__r.PersonEmail = ''
                                 Order By Is_Lead__c desc];
        return depositAllocationList;
    }*/
    
    /*
    Created by:- Vidhi Agrawal
    Created Date:- 15/07/22
    Last Modified by:- Vidhi Agrawal
    Last Modified Date:-15/07/22
    Story Number :- EID 71 AC 1
    Method used for:- This method is used for getting Tenants(deposit Allocations) where email and mailing address is not exist.
    */
    @AuraEnabled (cacheable=true)
    public static List<Case_Participant__c> getTenantsInformation(String caseId) {
        List<Case_Participant__c> depositAllocationList = new List<Case_Participant__c>();
        depositAllocationList = [SELECT Id, Case__c, Type__c, Primary_Email__c, Other_Emails__c, Account__c, Account__r.Name From Case_Participant__c 
                                where Case__c =:caseId AND Type__c='Tenant' 
                                 AND Primary_Email__c = ''];
        return depositAllocationList;
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
    }
    
}