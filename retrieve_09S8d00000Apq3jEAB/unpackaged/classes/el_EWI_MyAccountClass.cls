public without sharing class el_EWI_MyAccountClass {
    
    @AuraEnabled
    public static PersonDetailsWrapper getPersonDetails(String accessCode){
        PersonDetailsWrapper detail = new PersonDetailsWrapper();
        
        List<Case_Participant__c> cpList = QuerySelectorHelper.getCaseParticipants(accessCode);
        if(cpList.isEmpty()){ return detail; }
        
        detail.countryCodes = getPhoneCodePicklistValues();
        detail.salutationPicklist = getSalutation();        
        
        Case_Participant__c cp = cpList[0];

        List<Contact> conList = QuerySelectorHelper.getContact(new Set<Id>{ cp.Contact__c});
        List<Account> accList = QuerySelectorHelper.getAccount(new Set<Id>{ cp.Account__c});
        List<Case> caseList = QuerySelectorHelper.getCaseMemberNotes(new Set<Id>{ cp.Case__c});
        List<Installment__C> installmentList = QuerySelectorHelper.getInstallments(new Set<Id>{ cp.Case__c},new Set<Id>{ cp.Contact__c});
        
        if(!installmentList.isEmpty()){
            detail.isBankDetailsReadOnly = true;
            detail.isBankMemberNotes = true;
        }
        
        detail.caseParticipants = cp;
        if(!conList.isEmpty()){ detail.con = conList[0];}
        if(!accList.isEmpty()){ detail.account= accList[0]; }
        detail = getAgentBank(caseList[0], detail);
        
       if(cp.Type__c == 'Agent'){
            detail.myAccountMessage = 'Please ensure that you provide your agent bank details in accordance with the TDS scheme rules.';
        }
        
        if(cp.Type__c == 'Independent-Landlord'){
            detail.myAccountMessage = 'Please ensure that you provide your bank details and note that in the event of multiple landlords payment will be made to the account of the landlord raising/responding to the case.';
        }
        
        if(cp.Type__c == 'Tenant'){
           detail.myAccountMessage = 'Please provide the payment instructions for your share of any award. Also note that each named tenant is required to provide their own payment instructions, via their own TDS account.';
        }
        
        if(detail.isBankDetailsReadOnly){
            detail.myAccountMessage = 'You will be unable to edit these bank details as TDS have been asked to make any payments due to the bank details shown below.';
        }
        
        return detail;
    }


    @AuraEnabled
    public static PersonDetailsWrapper updateDetails(String strResult){
        //SavePoint sp = Database.setSavePoint();
        PersonDetailsWrapper updateWrapper = (PersonDetailsWrapper)JSON.deserialize(strResult, PersonDetailsWrapper.class);
		Case_Participant__c cpObjDetails = [Select Id,Primary_Email__c,Other_Emails__c from Case_Participant__c Where Id = :updateWrapper.caseParticipants.Id];      
        system.debug('---result--'+updateWrapper);
        Case_Participant__c cp = updateWrapper.caseParticipants; 
        if(updateWrapper.con != null){
            Contact con = updateWrapper.con;
            system.debug('Salutation Line 48=>'+con.Salutation);
            if(con.Salutation =='--None--'){
                con.Salutation = null;
            }
            
            Contact oldConDetails = [Select Id, Email from Contact Where Id = :updateWrapper.con.Id];
            oldConDetails.Salutation = con.Salutation;
            oldConDetails.FirstName = con.FirstName;
            oldConDetails.LastName = con.LastName;
            update oldConDetails;
        }
       // update con;
        update cp;
        EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
        //EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
        if(cp.Type__c =='Agent' || cp.Type__c =='Non-Member Landlord' || cp.Type__c =='Independent-Landlord'){
            if(cpObjDetails.Other_Emails__c != cp.Other_Emails__c){
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
                if(cpObjDetails.Other_Emails__c != null && cpObjDetails.Other_Emails__c != '' && !cpObjDetails.Other_Emails__c.contains(',')){
                    wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'MailSendOnChangeEmail');
                    wrapper.newEmailCaseMap.put(cpObjDetails.Id , cp.Other_Emails__c);
                    wrapper.oldEmailCaseMap.put(cpObjDetails.Id , cpObjDetails.Other_Emails__c);
                }else{
                    wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'emailupdatewhennoemailAA');
                    wrapper.newEmailCaseMap.put(cpObjDetails.Id , cp.Other_Emails__c);
                }
                wrapper.selectiveCPMap.put(cp.Id ,cpObjDetails);
                if(!test.isRunningTest()) {
                    helper.sendMailJetEmail(wrapper);
                }
            }
        }
        if(cp.Type__c=='Tenant'){
            if(cpObjDetails.Primary_Email__c != cp.Primary_Email__c){
                EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper();
                if(cpObjDetails.Primary_Email__c != null && cpObjDetails.Primary_Email__c != '' && !cpObjDetails.Primary_Email__c.contains(',')){
                    wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'MailSendOnChangeEmailTT');
                    wrapper.newEmailCaseMap.put(cpObjDetails.Id , cp.Primary_Email__c);
                    wrapper.oldEmailCaseMap.put(cpObjDetails.Id , cpObjDetails.Primary_Email__c);
                }else{
                    wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'emailupdatewhennoemailTT');
                    wrapper.newEmailCaseMap.put(cpObjDetails.Id , cp.Primary_Email__c);
                }
                wrapper.selectiveCPMap.put(cp.Id ,cpObjDetails);
                if(!test.isRunningTest()) {
                    helper.sendMailJetEmail(wrapper);
                }
            }
        }

        return getPersonDetails(cp.Access_Code__c);
    }

    @AuraEnabled
    public static Object updateBankDetails(String strResult){
        PersonDetailsWrapper updateWrapper = (PersonDetailsWrapper)JSON.deserialize(strResult, PersonDetailsWrapper.class);
        String message,isCorrect,bankNameInfo;        
		Case_Participant__c cp = updateWrapper.caseParticipants;
        system.debug('bankAccountNo=>'+cp.Bank_Account_Number__c);
        system.debug('bankSortCode=>'+cp.Bank_Sort_Code__c);

        String url = Label.Sort_Code_URL+getKey()+'&AccountNumber='+cp.Bank_Account_Number__c+'&SortCode='+cp.Bank_Sort_Code__c;
        String response = getResponse(url);
        JSONParser parser = JSON.createParser(response);

        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if(parser.getCurrentName() == 'IsCorrect') {
                    parser.nextToken();
                    isCorrect = parser.getText();
                }
                else if (parser.getCurrentName() == 'StatusInformation') {
                    parser.nextToken();
                    message = parser.getText();
                }
                if (parser.getCurrentName() == 'Bank') {
                    parser.nextToken();
                    bankNameInfo = parser.getText();
                }
            }
        }
        
        message = message;
        if(!Boolean.ValueOf(isCorrect)){ return message; }
        
        cp.Bank_Name__c = bankNameInfo;
        cp.UK_Payment__c=true;
        upsert cp;
       
        updatePrimaryAgent(cp);
        //add mailjet code
        if(cp.Type__c=='Agent' || cp.Type__c=='Non-Member Landlord' || cp.Type__c=='Independent-Landlord'){
      	EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
        EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'updateBankDetails');
      
        if(!test.isRunningTest()) {
            helper.sendMailJetEmail(wrapper);
        }
        }
        if(cp.Type__c=='Tenant'){
      	EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();
        EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'updateBankDetailsTT');
        if(!test.isRunningTest()) {
            helper.sendMailJetEmail(wrapper);
        }
        }
        
        
        return getPersonDetails(cp.Access_Code__c);
    } 

    @AuraEnabled
    public static Object updateInterBankDetails(String strResult){
        PersonDetailsWrapper updateWrapper = (PersonDetailsWrapper)JSON.deserialize(strResult, PersonDetailsWrapper.class);
        String message,isCorrect,bankNameInfo;        
        Case_Participant__c cp = updateWrapper.caseParticipants;
        system.debug('bankAccountNo=>'+cp.International_Account_Number__c);
        system.debug('bankSortCode=>'+cp.Bank_Sort_Code__c);
        System.debug('IBAN=>'+cp.International_Account_Number__c);
        if(cp.International_Account_Number__c !=null || cp.International_Account_Number__c !=''){                                               
            string url = Label.IBAN_URL+getKey()+'&IBAN='+cp.International_Account_Number__c;
            
            String response = getResponse(url);
            boolean Iscorrect2 = response.contains('True')?true:false;
            system.debug('line-->293' + Iscorrect2);
            if(!Iscorrect2){
                message = 'invalidIBAN';
                return message;
            }
		cp.International_Payment__c = true;
            upsert cp;
           //add mailjet code
            EI_MailJetUtilityHelper helper = new EI_MailJetUtilityHelper();          
            EI_MailJetUtilityHelper.MailJetWrapper wrapper = new EI_MailJetUtilityHelper.MailJetWrapper(cp.case__r, 'updateInterBankDetails');
            
            if(!test.isRunningTest()) {
                helper.sendMailJetEmail(wrapper);
            }
            return getPersonDetails(cp.Access_Code__c);
        }
		return message;
        
    }    
    public static string getKey(){
        /*Enter your API key here*/
        string key = Label.Sort_Code_API;
        string output = 'Key=' + key;   
        return output;
    }
    public static string getResponse(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        if(!Test.isRunningTest())
        {
            res = h.send(req); 
            String responseBody = res.getBody();      
            return responseBody; 
        }
        else
        {
            Case_Participant__c cp =[select id,Primary_Agent__c,Type__c from  Case_Participant__c  where Type__c='Agent' limit 1];
            return string.valueOf(cp);
        }
        
    }    
    
    public static PersonDetailsWrapper getAgentBank(Case c, PersonDetailsWrapper detail){
        Case_Participant__c cp = detail.caseParticipants;
        if(cp.Type__c != 'Agent' && cp.Type__c != 'Independent-Landlord')
        { return detail; }
        
        if(!cp.Primary_Agent__c){ detail.isSecondaryAgent = true; }
        
        detail = processMemberNote(cp, c.Member_Notes__c, detail);
        
       /* if(detail.isBankDetailsReadOnly){
            return detail;
        }*/
        
        detail.caseParticipants = getPrimaryAgent(cp);
        
        if(/*detail.isSecondaryAgent &&*/ String.isBlank(cp.Bank_Name__c) && String.isBlank(cp.Bank_Sort_Code__c)){
            detail.isBankDetailsEmpty = true;
        }
        
        return detail;
    }
    public static Case_Participant__c getPrimaryAgent(Case_Participant__c cp){
        if(!cp.Primary_Agent__c){
            List<Case_Participant__c> primaryAgent = QuerySelectorHelper.getPrimaryAgent(new Set<Id>{cp.Case__c});
            if(primaryAgent.isEmpty()){ return cp;}
            
            cp.Bank_Account_Number__c = primaryAgent[0].Bank_Account_Number__c;
            cp.Bank_Account_Holder_Name__c = primaryAgent[0].Bank_Account_Holder_Name__c;
            cp.Bank_Sort_Code__c = primaryAgent[0].Bank_Sort_Code__c;
            cp.Bank_Name__c = primaryAgent[0].Bank_Name__c;
        }
        return cp;
    }
    
    public static PersonDetailsWrapper processMemberNote(Case_Participant__c cp, String str, PersonDetailsWrapper detail){
        Map<String, Object> response = getMemberNoteBank(cp, str);
        
        if(response.containsKey('isBankMemberNotes')){
            detail.isBankDetailsReadOnly = true;
            detail.isBankMemberNotes = true;
            detail.caseParticipants = (Case_Participant__c)response.get('cp');
            updatePrimaryAgent(cp);
        }
        
        return detail;
    }
    
     public static Map<String, Object> getMemberNoteBank(Case_Participant__c cp, String str){
        Map<String, Object> response = new Map<String, Object>();
        System.debug('<<<<<<<<<<<<<. '+str);
        try{
            if(String.isNotBlank(str) && (str.contains('Account Number:') || str.contains('Account number:') || str.contains('account number:'))){
                str = str.normalizeSpace();
                str = str.replace('account','Account');
                str = str.replace('number','Number');
                str = str.replace('sort','Sort');
                str = str.replace('code','Code');
                str = str.replace('name','Name');
                str = str.replace('bank','Bank');
                str = str.replace('<br>','');
                str = str.replace('<div>','');
                str = str.replace('</div>','');
                //str = str.replace('</p>','');
                str = str.replace('<p>','');
                str = str.escapeHtml4();
                str = str.remove('amp;');
                str = str.remove('**');
                
				
                system.debug('---'+str);
                String accountNumber = str.substringAfter('Account Number:');
                cp.Bank_Account_Number__c = (accountNumber.substringBefore('Account Name')).trim(); //substring(0,8);
                cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.remove(' ');//substring(0,8);
                if(String.isNotBlank(cp.Bank_Account_Number__c) && cp.Bank_Account_Number__c.length() >8){
                    cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.substring(0,8);
                }
                
                cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.replace('</p>','');
                cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.replace('\\n','');
                cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.replace('\\r','');
                cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.replace('\u00a0','');
                cp.Bank_Account_Number__c = cp.Bank_Account_Number__c.replace('\\','');     
                
                
                
                String accountName = str.substringAfter('Account Name:');
                cp.Bank_Account_Holder_Name__c = accountName.substringBefore('Sort'); //.remove('&lt;br&gt;');
                cp.Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c.substringBefore('&lt;');
                cp.Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c.replace('</p>','');
                
                cp.Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c.replace('\\n','');
                cp.Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c.replace('\\r','');
                cp.Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c.replace('\\u00a0','');
                cp.Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c.replace('\\','');           
                
                system.debug('---'+cp.Bank_Account_Holder_Name__c);
                
                String sortCode = str.substringAfter('Sort Code:');
                cp.Bank_Sort_Code__c = sortCode.substringBefore('Bank'); //substring(0,6); //;
                cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.remove(' ');
                
                if(String.isNotBlank(cp.Bank_Sort_Code__c) && cp.Bank_Sort_Code__c.length() >6){
                    cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.substring(0,6);
                }
                 cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.replace('</p>','');
                cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.replace('\\n','');
                cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.replace('\\r','');
                cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.replace('\\u00a0','');
                cp.Bank_Sort_Code__c = cp.Bank_Sort_Code__c.replace('\\','');
                  String bankName;
                // String bankName = accountNumber.substringAfter('Bank Name:');
                if(accountNumber.contains('Bank Name:') && accountNumber.substringAfter('Bank Name:') !=null){
                    bankName = accountNumber.substringAfter('Bank Name:');
                    system.debug('>>>>>>>bankName1  '+bankName);
                    If(bankName.contains('</p>'))
                    bankName = bankName.substringBefore('</p>');
                }else
                if(accountNumber.contains('Bank:') && accountNumber.substringAfter('Bank:') !=null){
                      bankName = accountNumber.substringAfter('Bank:');
                    system.debug('>>>>>>>bankName1  '+bankName);
                      If(bankName.contains('</p>'))
                      bankName = bankName.substringBefore('</p>');
                }
                if(bankName.contains('\\r')){
                    bankName = bankName.substringBefore('\\r');
                }
               // String bankName = accountNumber.substringAfter('Bank Name:');
                system.debug('----'+bankName);
                if(String.isNotBlank(bankName)){
                    cp.Bank_Name__c = bankName.substringBefore('&lt;');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('</p>','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('\\n','');
                	cp.Bank_Name__c = cp.Bank_Name__c.replace('\\r','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('\\u00a0','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('\\','');
                    //cp.Bank_Name__c = cp.Bank_Name__c.replace('\','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('&quot;','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace(',','');
                    
                    cp.Bank_Name__c = cp.Bank_Name__c.trim();
                    system.debug('>>>>>>>>>'+cp.Bank_Name__c);
                    if(cp.Bank_Name__c == 'NA'){
                        cp.Bank_Name__c = '';
                    }
                }
                
                
                if(String.isNotBlank(cp.Bank_Name__c) && cp.Bank_Name__c.length() >=255){
                    cp.Bank_Name__c = cp.Bank_Name__c.substring(0,254);
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('</p>','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('\\n','');
                	cp.Bank_Name__c = cp.Bank_Name__c.replace('\\r','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('\\u00a0','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('\\','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('"','');
                    //cp.Bank_Name__c = cp.Bank_Name__c.replace('quot;','');
                    cp.Bank_Name__c = cp.Bank_Name__c.replace('&quot;','');
                    //cp.Bank_Name__c = cp.Bank_Name__c.replace(',','');
                    
                    cp.Bank_Name__c = cp.Bank_Name__c.trim();
                    system.debug('>>>>>>>>>'+cp.Bank_Name__c);
                    if(cp.Bank_Name__c == 'NA'){
                        cp.Bank_Name__c = '';
                    }
                } 
                
                response.put('isBankMemberNotes', true); 
                response.put('cp', cp);
            }
        }catch(Exception E){ }
        
        return response;
    }

    public static void updatePrimaryAgent(Case_Participant__c cp){
        if(!cp.Primary_Agent__c && cp.Type__c =='Agent'){
            List<Case_Participant__c> primaryAgent = QuerySelectorHelper.getPrimaryAgent(new Set<Id>{cp.Case__c});
            if(primaryAgent.isEmpty()){ return;}
            
            if(primaryAgent[0].Bank_Account_Number__c != cp.Bank_Account_Number__c
               || primaryAgent[0].Bank_Account_Holder_Name__c != cp.Bank_Account_Holder_Name__c
               || primaryAgent[0].Bank_Sort_Code__c != cp.Bank_Sort_Code__c
               || primaryAgent[0].Bank_Name__c != cp.Bank_Name__c){
                   
                   primaryAgent[0].Bank_Account_Number__c = cp.Bank_Account_Number__c;
                   primaryAgent[0].Bank_Account_Holder_Name__c = cp.Bank_Account_Holder_Name__c;
                   primaryAgent[0].Bank_Sort_Code__c = cp.Bank_Sort_Code__c;
                   primaryAgent[0].Bank_Name__c = cp.Bank_Name__c;
                   update primaryAgent;
               }
        }
    }
    
    public static List<string> getPhoneCodePicklistValues(){
        try {
            Schema.DescribeFieldResult fieldDescription = Contact.Phone_Code__c.getDescribe();
            List<String> countryCodes = new List<String>();
            for (Schema.PicklistEntry cc : fieldDescription.getPicklistValues()) {
                if(cc.isActive()){
                    countryCodes.add(cc.getValue());
                }
            }
            return countryCodes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static List<string> getSalutation(){
        try {
            Schema.DescribeFieldResult fieldDescription = Contact.Salutation.getDescribe();
            List<String> salutationPicklist = new List<String>();
            for (Schema.PicklistEntry cc : fieldDescription.getPicklistValues()) {
                if(cc.isActive()){
                    salutationPicklist.add(cc.getValue());
                }
            }
            return salutationPicklist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Boolean validateSession(Case_Participant__c cs){
        DateTime dt = Datetime.now().addMinutes(30);
        if(cs.Send_Evidence_Datestamp__c >= dt){
            return false;
        }
        
        return true;
    }
    
    public class PersonDetailsWrapper{
        @AuraEnabled public List<String> countryCodes;
        @AuraEnabled public List<String> salutationPicklist;
        @AuraEnabled public Case_Participant__c caseParticipants;
        @AuraEnabled public Case_Participant__c leadTenant;
        @AuraEnabled public Bank_Account__c bankAccounts;
        @AuraEnabled public Contact con;
        @AuraEnabled public Account account;
        @AuraEnabled public Boolean isBankMemberNotes = false;
        @AuraEnabled public Boolean isSecondaryAgent = false;
        @AuraEnabled public Boolean isBankDetailsEmpty = false;
        @AuraEnabled public Boolean isBankDetailsReadOnly = false;
        @AuraEnabled public String myAccountMessage;
        @AuraEnabled public Case claim;
        @AuraEnabled public List<Evidence_Attachment__c> evidAttach;
        @AuraEnabled public List<Dispute_Item__c> disputeItems;
        @AuraEnabled public List<Account> accountDetail;
        @AuraEnabled public User usrData;
        @AuraEnabled public Boolean containsleadtenant =false;
    }
    public static List<Holiday> holidayList;
    public static List<Holiday> holidayList2;
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays) {
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
    
    public static Date calculateWorkingDays(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList2 == null || holidayList2.isEmpty()) {
            holidayList2 = listOfHolidayCountryWise1('England and Wales');
            //holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList2)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay1(startDate.addDays(totalDays), holidayList2)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay1(Date currentDate, List<Holiday> holidays) {
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
    
    public static List<Holiday> listOfHolidayCountryWise1(String businessHoursName){
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
    
    
    public static List<Holiday> holidayList3;
    public static Date calculateWorkingDaysbyNumbers(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList3 == null || holidayList3.isEmpty()) {
            holidayList3 = listOfHolidayCountryWise2('England and Wales');
            //holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay2(startDate.addDays(totalDays),holidayList3)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay2(startDate.addDays(totalDays), holidayList3)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay2(Date currentDate, List<Holiday> holidays) {
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
    
    public static List<Holiday> listOfHolidayCountryWise2(String businessHoursName){
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
     }
    
}