public without sharing class EI_EWI_BatchOfStatementCls {

    public class doInitData{
        @AuraEnabled public List<nameAndGnumberWrapper> nameAndGnumber;
        @AuraEnabled public List<PDFWrapper> PDFWrapperList;
    }
    public class nameAndGnumberWrapper{
        @AuraEnabled Public String name;
        @AuraEnabled Public String gNumber;
        @AuraEnabled Public Account accRecord;
    }
    
    public class inbReporDetailsWrapper{
        @AuraEnabled Public Inbound_Report__c inbReport {get;set;}
        @AuraEnabled Public String gNumber {get;set;}
        @AuraEnabled Public Case Dispute_Reference {get;set;}
    }
    
    public class PDFWrapper implements Comparable{
        @AuraEnabled public String gNumber {get;set;}
        @AuraEnabled public String agllName {get;set;}
        @AuraEnabled public Date lastSentDate {get;set;}
        @AuraEnabled public Decimal totalBalanceAmount {get;set;}
        @AuraEnabled public Decimal recivedAmount {get;set;}
        @AuraEnabled public Decimal remainingAmount {get;set;}
        @AuraEnabled public Decimal balanceOutstanding {get;set;}
        @AuraEnabled public Decimal amountAfter10Days {get;set;}
        @AuraEnabled public Decimal amountAfter20Days {get;set;}
        @AuraEnabled public Decimal amountAfter30Days {get;set;}
        @AuraEnabled public Decimal amountBefore10Days {get;set;}
        @AuraEnabled public List<reportColumnsWrapper> reportColumnsWrapperList {get; set;}
        @AuraEnabled public List<brancheDetailsWrapper> brancheDetailsWrapperList {get; set;}
        @AuraEnabled public Boolean isSelected {get;set;}

        // Implement the compareTo() method 
        public Integer compareTo(Object compareTo) {
            PDFWrapper compareToEmp = (PDFWrapper)compareTo;
            if (gNumber == compareToEmp.gNumber) return 0;
            if (gNumber > compareToEmp.gNumber) return 1; // ascending order
            return -1;         
        }
    }

    public class reportColumnsWrapper implements Comparable{
        
        @AuraEnabled public Date dueDate {get;set;}
        @AuraEnabled public String daysoverDue {get;set;}
        @AuraEnabled public String AGLLNumber {get;set;}
        @AuraEnabled public String AGLLName {get;set;}
        @AuraEnabled public String accRecordId {get; set;}
        @AuraEnabled public String memberStatus {get;set;}
        @AuraEnabled public String EWIBranchName {get;set;}
        @AuraEnabled public String EWIBranchId {get;set;}
        @AuraEnabled public String totalBalanceAmount {get;set;}
        @AuraEnabled public String recivedAmount {get;set;}
        @AuraEnabled public Decimal remainingAmount {get;set;}
        @AuraEnabled public String amountAfter10Days {get;set;}
        @AuraEnabled public String amountAfter20Days {get;set;}
        @AuraEnabled public String amountAfter30Days {get;set;}
        @AuraEnabled public String amountBefore10Days {get;set;}
        @AuraEnabled public String balanceOutstanding {get;set;}
        @AuraEnabled public String Type {get;set;}
        @AuraEnabled public String CaseId {get;set;}
        @AuraEnabled public String caseStatus {get;set;}
        @AuraEnabled public String caseDisputeRef {get;set;}
        @AuraEnabled public String tenancyAddress {get;set;}
        @AuraEnabled public Decimal NoOfTimesChased {get;set;}
        @AuraEnabled public Date LastChasedDate {get;set;}

        // Implement the compareTo() method 
        public Integer compareTo(Object compareTo) {
            reportColumnsWrapper compareToEmp = (reportColumnsWrapper)compareTo;
            if (dueDate == compareToEmp.dueDate) return 0;
            if (dueDate > compareToEmp.dueDate) return 1; // ascending order
            return -1;         
        }
    }

    public class brancheDetailsWrapper implements Comparable{
        @AuraEnabled Public String label {get;set;}
        @AuraEnabled Public String value {get;set;}
        @AuraEnabled Public Boolean selected {get;set;}

        // Implement the compareTo() method 
        public Integer compareTo(Object compareTo) {
            brancheDetailsWrapper compareToEmp = (brancheDetailsWrapper)compareTo;
            if (label == compareToEmp.label) return 0;
            if (label > compareToEmp.label) return 1; // ascending order
            return -1;         
        }
    }
    
    @AuraEnabled
    public static String getGnumberandNameofAcc(String accId){
        String gNumberAndName = '';
        List<Account> accList = [Select Id, Name, G_Number__c, G_Number__pc, EWI_Landlord_Id__c 
                                From Account Where Id =: accId];

        if(accList.size() > 0){
            if(accList[0].G_Number__c!=null && accList[0].G_Number__c!=''){
                gNumberAndName = accList[0].G_Number__c+':'+accList[0].Name;
            }else if(accList[0].G_Number__pc!=null && accList[0].G_Number__pc!=''){
                gNumberAndName = accList[0].G_Number__pc+':'+accList[0].Name;
            }else if(accList[0].EWI_Landlord_Id__c!=null && accList[0].EWI_Landlord_Id__c!=''){
                gNumberAndName = accList[0].EWI_Landlord_Id__c+':'+accList[0].Name;
            }
        }
        return gNumberAndName;                      
    }
    
    @AuraEnabled(cacheable=true)
    public static doInitData getDataInWrapperList(String selectedgNumber, String agllName, String selectedBranchSTR){
        System.debug('Statement of Acc selectedgNumber => ' + selectedgNumber);
        System.debug('Statement of Acc agllName => ' + agllName);
        System.debug('Statement of Acc selectedBranchSTR => ' + selectedBranchSTR);
        List<String> selectedBranchList = new List<String>();
        selectedBranchList = selectedBranchSTR.split(', ');
        Set<String> selectedBranch = new Set<String>();
        selectedBranch.addAll(selectedBranchList);
        try{
            List<Installment__c> installmentList = new List<Installment__c>();
            List<Inbound_Report__c> InboundReportsList = new List<Inbound_Report__c>();
            
            if(selectedgNumber == 'Select all' && selectedBranchSTR == 'Select all'){
                installmentList = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.Id, Account__r.Statement_Last_Send_Date__c ,
                    Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, 
                    Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c, Case__r.Agent_Branch__c, Case__r.Agent_Branch__r.EWI_Branch_Name__c,
                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Case__r.Days_Overdue__c, Case__r.Awaiting_review_Date__c,
                    (Select id, Amount__c, Collection_Date__c, Reference1__c,
                        Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                        from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                    from Installment__c where Case__c != null and Account__c!=null
                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                    Case__r.Status = 'Evidence gathering tenant' OR
                    Case__r.Status = 'Evidence review complete' OR
                    Case__r.Status = 'Adjudication' OR
                    Case__r.Status = 'Deposit to be repaid - resolved without adjudication' OR
                    Case__r.Status = 'Deposit to be repaid - decision issued' OR
                    Case__r.Status = 'On Hold' OR
                    Case__r.Status = 'Awaiting Review' OR
                    Case__r.Status = 'Potential insurance claim - pending information' OR
                    Case__r.Status = 'Clarification needed' OR
                    Case__r.Status = 'Consent to resolution not given' OR
                    Case__r.Status = 'Decision issued – dispute monies outstanding' OR
                    Case__r.Status = 'Deposit to be repaid - Court order' OR
                    Case__r.Status = 'Deposit to be repaid - no proof of court action' OR
                    Case__r.Status = 'Decision issued – insurance claim' OR
                    Case__r.Status = 'Decision issued - with legal' OR
                    Case__r.Status = 'Overpayments' OR
                    Case__r.Status = 'Case closed – Resolved without adjudication' OR
                    Case__r.Status = 'Deposit closed - deposit repaid in part' OR
                    Case__r.Status = 'Deposit closed - deposit repaid in full' OR
                    Case__r.Status = 'Case closed – court order' OR
                    Case__r.Status = 'Case closed - Court case' OR
                    Case__r.Status = 'Complaint closed' OR
                    Case__r.Status = '4 - Medium level complaint' OR
                    Case__r.Status = '5 - High level complaint' OR
                    Case__r.Status = 'Case closed – no dispute') 
                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 
                    and ((Case__r.Evidence_Gathering_Start_Date__c!=null and Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR (Case__r.Awaiting_review_Date__c !=null AND Case__r.Awaiting_review_Date__c <=today) )
                    and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                    and (Account__r.G_Number__c != null OR Account__r.G_Number__pc != null OR Account__r.EWI_Landlord_Id__c != null)
                    and case__r.recordtype.Name = 'Dispute EW Insured' 
                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc
                ];

                InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Reference2__c, Reference3__c, Reference4__c, Reference5__c, Collection_Date__c, 
                                                            Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                            from Inbound_Report__c WHERE Amount__c>0 and Collection_Date__c<=Today
                                                            and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' and (NOT Reference1__c like '%44576714%') 
                                                            order by Collection_Date__c desc];
                
            }else if(selectedgNumber != 'Select all' && selectedBranchSTR == 'Select all'){
                installmentList = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.Id, Account__r.Statement_Last_Send_Date__c ,
                    Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, 
                    Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c, Case__r.Agent_Branch__c, Case__r.Agent_Branch__r.EWI_Branch_Name__c,
                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Case__r.Days_Overdue__c, Case__r.Awaiting_review_Date__c,
                    (Select id, Amount__c, Collection_Date__c, Reference1__c,
                        Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                        from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                    from Installment__c where Case__c != null and Account__c!=null
                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                    Case__r.Status = 'Evidence gathering tenant' OR
                    Case__r.Status = 'Evidence review complete' OR
                    Case__r.Status = 'Adjudication' OR
                    Case__r.Status = 'Deposit to be repaid - resolved without adjudication' OR
                    Case__r.Status = 'Deposit to be repaid - decision issued' OR
                    Case__r.Status = 'On Hold' OR
                    Case__r.Status = 'Awaiting Review' OR
                    Case__r.Status = 'Potential insurance claim - pending information' OR
                    Case__r.Status = 'Clarification needed' OR
                    Case__r.Status = 'Consent to resolution not given' OR
                    Case__r.Status = 'Decision issued – dispute monies outstanding' OR
                    Case__r.Status = 'Deposit to be repaid - Court order' OR
                    Case__r.Status = 'Deposit to be repaid - no proof of court action' OR
                    Case__r.Status = 'Decision issued – insurance claim' OR
                    Case__r.Status = 'Decision issued - with legal' OR
                    Case__r.Status = 'Overpayments' OR
                    Case__r.Status = 'Case closed – Resolved without adjudication' OR
                    Case__r.Status = 'Deposit closed - deposit repaid in part' OR
                    Case__r.Status = 'Deposit closed - deposit repaid in full' OR
                    Case__r.Status = 'Case closed – court order' OR
                    Case__r.Status = 'Case closed - Court case' OR
                    Case__r.Status = 'Complaint closed' OR
                    Case__r.Status = '4 - Medium level complaint' OR
                    Case__r.Status = '5 - High level complaint' OR
                    Case__r.Status = 'Case closed – no dispute') 
                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 
                    and ((Case__r.Evidence_Gathering_Start_Date__c!=null and Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR (Case__r.Awaiting_review_Date__c !=null AND Case__r.Awaiting_review_Date__c <=today) )
                    and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                    and (Account__r.G_Number__c =: selectedgNumber OR Account__r.G_Number__pc =: selectedgNumber OR Account__r.EWI_Landlord_Id__c =: selectedgNumber)
                    and case__r.recordtype.Name = 'Dispute EW Insured' 
                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc
                ];

                InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Reference2__c, Reference3__c, Reference4__c, Reference5__c, Collection_Date__c, 
                                                            Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                            from Inbound_Report__c WHERE Amount__c>0 and Collection_Date__c<=Today and Reference1__c =: agllName
                                                            and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' and (NOT Reference1__c like '%44576714%') 
                                                            order by Collection_Date__c desc];

            }else if(selectedgNumber != 'Select all' && selectedBranchSTR != 'Select all'){
                installmentList = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.Id, Account__r.Statement_Last_Send_Date__c ,
                    Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, 
                    Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c, Case__r.Agent_Branch__c, Case__r.Agent_Branch__r.EWI_Branch_Name__c,
                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Case__r.Days_Overdue__c, Case__r.Awaiting_review_Date__c,
                    (Select id, Amount__c, Collection_Date__c, Reference1__c,
                        Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                        from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                    from Installment__c where Case__c != null and Account__c!=null
                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                    Case__r.Status = 'Evidence gathering tenant' OR
                    Case__r.Status = 'Evidence review complete' OR
                    Case__r.Status = 'Adjudication' OR
                    Case__r.Status = 'Deposit to be repaid - resolved without adjudication' OR
                    Case__r.Status = 'Deposit to be repaid - decision issued' OR
                    Case__r.Status = 'On Hold' OR
                    Case__r.Status = 'Awaiting Review' OR
                    Case__r.Status = 'Potential insurance claim - pending information' OR
                    Case__r.Status = 'Clarification needed' OR
                    Case__r.Status = 'Consent to resolution not given' OR
                    Case__r.Status = 'Decision issued – dispute monies outstanding' OR
                    Case__r.Status = 'Deposit to be repaid - Court order' OR
                    Case__r.Status = 'Deposit to be repaid - no proof of court action' OR
                    Case__r.Status = 'Decision issued – insurance claim' OR
                    Case__r.Status = 'Decision issued - with legal' OR
                    Case__r.Status = 'Overpayments' OR
                    Case__r.Status = 'Case closed – Resolved without adjudication' OR
                    Case__r.Status = 'Deposit closed - deposit repaid in part' OR
                    Case__r.Status = 'Deposit closed - deposit repaid in full' OR
                    Case__r.Status = 'Case closed – court order' OR
                    Case__r.Status = 'Case closed - Court case' OR
                    Case__r.Status = 'Complaint closed' OR
                    Case__r.Status = '4 - Medium level complaint' OR
                    Case__r.Status = '5 - High level complaint' OR
                    Case__r.Status = 'Case closed – no dispute') 
                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 
                    and ((Case__r.Evidence_Gathering_Start_Date__c!=null and Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR (Case__r.Awaiting_review_Date__c !=null AND Case__r.Awaiting_review_Date__c <=today) )
                    and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                    and (Account__r.G_Number__c =: selectedgNumber OR Account__r.G_Number__pc =: selectedgNumber OR Account__r.EWI_Landlord_Id__c =: selectedgNumber)
                    and Case__r.Agent_Branch__r.EWI_Branch_Name__c =: selectedBranch
                    and case__r.recordtype.Name = 'Dispute EW Insured' 
                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc
                ];

                InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Reference2__c, Reference3__c, Reference4__c, Reference5__c, Collection_Date__c, 
                                                            Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                            from Inbound_Report__c WHERE Amount__c>0 and Collection_Date__c<=Today and Reference1__c =: agllName
                                                            and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' and (NOT Reference1__c like '%44576714%') 
                                                            order by Collection_Date__c desc];
            }

            List<PDFWrapper> allAgentsList = new List<PDFWrapper>();
            List<reportColumnsWrapper> allReportColumnsWrapperList = new List<reportColumnsWrapper>();
            List<nameAndGnumberWrapper> nameAndGnumberList = new List<nameAndGnumberWrapper>(); 
            
            if(installmentList.size() > 0){
                // create reportColumnsWrapper element from installment records
                for(Installment__c instRec : installmentList){
                    String agllNumber = '';
                    if(instRec.Account__r.G_Number__c!= null){
                        agllNumber = instRec.Account__r.G_Number__c;
                    }else if(instRec.Account__r.G_Number__pc!= null){
                        agllNumber = instRec.Account__r.G_Number__pc;
                    }else if(instRec.Account__r.EWI_Landlord_Id__c!= null){
                        agllNumber = instRec.Account__r.EWI_Landlord_Id__c;
                    }

                    Boolean isRecordValid = false;
                    if(instRec.Inbound_Reports__r.size() > 0){
                        if(instRec.Case__r.Status == 'Case closed – Resolved without adjudication' ||
                            instRec.Case__r.Status == 'Deposit closed - deposit repaid in part' ||
                            instRec.Case__r.Status == 'Deposit closed - deposit repaid in full' ||
                            instRec.Case__r.Status == 'Case closed – court order' ||
                            instRec.Case__r.Status == 'Case closed - Court case' ||
                            instRec.Case__r.Status == 'Complaint closed' ||
                            instRec.Case__r.Status == '4 - Medium level complaint' ||
                            instRec.Case__r.Status == '5 - High level complaint' ||
                            instRec.Case__r.Status == 'Case closed – no dispute')
                        {
                            isRecordValid = true;
                        }
                    }
                    else if(instRec.Case__r.Status == 'Evidence gathering agent/landlord' ||
                        instRec.Case__r.Status == 'Evidence gathering tenant' ||
                        instRec.Case__r.Status == 'Evidence review complete' ||
                        instRec.Case__r.Status == 'Adjudication' ||
                        instRec.Case__r.Status == 'Deposit to be repaid - resolved without adjudication' ||
                        instRec.Case__r.Status == 'Deposit to be repaid - decision issued' ||
                        instRec.Case__r.Status == 'On Hold' ||
                        instRec.Case__r.Status == 'Awaiting review' ||
                        instRec.Case__r.Status == 'Potential Insurance Claim - pending information' ||
                        instRec.Case__r.Status == 'Clarification needed' ||
                        instRec.Case__r.Status == 'Consent to resolution not given' ||
                        instRec.Case__r.Status == 'Decision issued – dispute monies outstanding' ||
                        instRec.Case__r.Status == 'Deposit to be repaid - Court order' ||
                        instRec.Case__r.Status == 'Deposit to be repaid - no proof of court action' ||
                        instRec.Case__r.Status == 'Decision issued – insurance claim' ||
                        instRec.Case__r.Status == 'Decision issued - with legal' ||
                        instRec.Case__r.Status == 'Overpayments')
                    {
                        isRecordValid = true;
                    }

                    if(isRecordValid == true){
                        reportColumnsWrapper reportCol = new reportColumnsWrapper();
                        reportCol.dueDate = instRec.Inbound_Reports__r.size()>0
                            ? instRec.Inbound_Reports__r[0].Collection_Date__c
                            : (instRec.Case__r.Evidence_Gathering_Start_Date__c!=null && instRec.Case__r.Awaiting_review_Date__c!=null)
                                ? (instRec.Case__r.Evidence_Gathering_Start_Date__c > instRec.Case__r.Awaiting_review_Date__c
                                   ? instRec.Case__r.Evidence_Gathering_AGLL_DueDate__c
                                   : instRec.Case__r.Awaiting_review_Date__c)
                                : (instRec.Case__r.Evidence_Gathering_Start_Date__c!=null
                                   ? instRec.Case__r.Evidence_Gathering_AGLL_DueDate__c
                                   : instRec.Case__r.Awaiting_review_Date__c);
                        reportCol.daysoverDue = instRec.Case__r.Days_Overdue__c==null? '': String.valueOf(instRec.Case__r.Days_Overdue__c);
                        reportCol.AGLLNumber = agllNumber;
                        reportCol.AGLLName = instRec.Account__r.Name;
                        reportCol.accRecordId = instRec.Account__r.Id;
                        reportCol.memberStatus = instRec.Case__r.Member_Status__c!=null? instRec.Case__r.Member_Status__c: '';
                        reportCol.EWIBranchName = instRec.Case__r.Agent_Branch__c!=null && instRec.Case__r.Agent_Branch__r.EWI_Branch_Name__c!=null
                                                    ? instRec.Case__r.Agent_Branch__r.EWI_Branch_Name__c: '';
                        reportCol.EWIBranchId = instRec.Case__r.Agent_Branch__c==null?'': instRec.Case__r.Agent_Branch__c;
                        reportCol.totalBalanceAmount= instRec.Case__r.Amount_of_Disputed_Funds_Required__c!=null? String.valueOf(instRec.Case__r.Amount_of_Disputed_Funds_Required__c):''; 
                        reportCol.recivedAmount= instRec.Case__r.Amount_of_Disputed_Funds_Received__c!=null? String.valueOf(instRec.Case__r.Amount_of_Disputed_Funds_Received__c):''; 
                        reportCol.remainingAmount= instRec.Inbound_Reports__r.size()>0
                                                    ? (instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null && instRec.Inbound_Reports__r[0].Amount__c!=null
                                                        ? instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c-instRec.Inbound_Reports__r[0].Amount__c
                                                        : instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c)
                                                    : instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c;
                        reportCol.amountAfter30Days = instRec.Inbound_Reports__r.size()>0
                                                    ? (instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c) : '')
                                                    : (instRec.Case__r.Amount_Received_After_30_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_After_30_Days__c) : '');
                        reportCol.amountAfter20Days = instRec.Inbound_Reports__r.size()>0
                                                    ? (instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c) : '')
                                                    : (instRec.Case__r.Amount_Received_After_20_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_After_20_Days__c) : '');
                        reportCol.amountAfter10Days = instRec.Inbound_Reports__r.size()>0
                                                    ? (instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c) : '')
                                                    : (instRec.Case__r.Amount_Received_After_10_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_After_10_Days__c) : '');
                        reportCol.amountBefore10Days = instRec.Inbound_Reports__r.size()>0
                                                    ? (instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c) : '')
                                                    : (instRec.Case__r.Amount_Received_Before_10_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_Before_10_Days__c) : '');
                        reportCol.balanceOutstanding = instRec.Inbound_Reports__r.size()>0
                                                    ? (instRec.Inbound_Reports__r[0].Amount__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount__c) : '')
                                                    : (instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null? string.valueOf(instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c) : '');
                        reportCol.Type = instRec.Inbound_Reports__r.size()>0
                                        ? 'Unallocated receipt'
                                        : 'Outstanding case';
                        reportCol.CaseId = instRec.Case__c;
                        reportCol.caseStatus = instRec.Case__r.Status;
                        reportCol.caseDisputeRef = instRec.Case__r.Dispute_Reference__c!=null? instRec.Case__r.Dispute_Reference__c : '';
                        reportCol.tenancyAddress = instRec.Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c!=null
                                                    ? instRec.Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c
                                                    : '';
                        
                        // create brnach details wrapper
                        brancheDetailsWrapper branchopt = new brancheDetailsWrapper();
                        branchopt.label = instRec.Case__r.Agent_Branch__c!=null && instRec.Case__r.Agent_Branch__r.EWI_Branch_Name__c!=null
                                            ? instRec.Case__r.Agent_Branch__r.EWI_Branch_Name__c: '';
                        branchopt.value = instRec.Case__r.Agent_Branch__c==null?'': instRec.Case__r.Agent_Branch__c;
                        branchopt.selected = false;
                        
                        // nameAndGnumberList from installments
                        nameAndGnumberWrapper newwrap = new nameAndGnumberWrapper();
                        newwrap.name= instRec.Account__r.Name; 
                        newwrap.gNumber= agllNumber;
                        newwrap.accRecord = instRec.Account__r;
                        nameAndGnumberList.add(newwrap);

                        // add installmet to allAgent's ReportColumnWrapperList
                        Boolean gNumberFlag = false;
                        for(integer a=0; a<allAgentsList.size(); a++){
                            if(allAgentsList[a].gNumber == agllNumber){
                                if(instRec.Account__r.Statement_Last_Send_Date__c!=null && allAgentsList[a].lastSentDate!=null){
                                    if(instRec.Account__r.Statement_Last_Send_Date__c > allAgentsList[a].lastSentDate){
                                        allAgentsList[a].lastSentDate = instRec.Account__r.Statement_Last_Send_Date__c;
                                    }
                                }else if(allAgentsList[a].lastSentDate==null){
                                    allAgentsList[a].lastSentDate = instRec.Account__r.Statement_Last_Send_Date__c;
                                }

                                allAgentsList[a].totalBalanceAmount += instRec.Case__r.Amount_of_Disputed_Funds_Required__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Required__c:0;
                                allAgentsList[a].recivedAmount += instRec.Case__r.Amount_of_Disputed_Funds_Received__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Received__c:0;
                                allAgentsList[a].remainingAmount += instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c:0;
                                allAgentsList[a].balanceOutstanding += instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c:0;
                                
                                if(instRec.Inbound_Reports__r.size() > 0){
                                    allAgentsList[a].remainingAmount -= instRec.Inbound_Reports__r[0].Amount__c!= null? instRec.Inbound_Reports__r[0].Amount__c:0;
                                    allAgentsList[a].balanceOutstanding -= instRec.Inbound_Reports__r[0].Amount__c!= null? instRec.Inbound_Reports__r[0].Amount__c:0;
                                    allAgentsList[a].amountAfter10Days -= instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c:0;
                                    allAgentsList[a].amountAfter20Days -= instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c:0;
                                    allAgentsList[a].amountAfter30Days -= instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c:0;
                                    allAgentsList[a].amountBefore10Days -= instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c:0;
                                }else{
                                    allAgentsList[a].amountAfter10Days += instRec.Case__r.Amount_Received_After_10_Days__c!=null?instRec.Case__r.Amount_Received_After_10_Days__c:0;  
                                    allAgentsList[a].amountAfter20Days += instRec.Case__r.Amount_Received_After_20_Days__c!=null?instRec.Case__r.Amount_Received_After_20_Days__c:0;  
                                    allAgentsList[a].amountAfter30Days += instRec.Case__r.Amount_Received_After_30_Days__c!=null?instRec.Case__r.Amount_Received_After_30_Days__c:0;  
                                    allAgentsList[a].amountBefore10Days += instRec.Case__r.Amount_Received_Before_10_Days__c!=null?instRec.Case__r.Amount_Received_Before_10_Days__c:0;  
                                }
                                List<reportColumnsWrapper> reportColumnsWrapperList = allAgentsList[a].reportColumnsWrapperList;
                                reportColumnsWrapperList.add(reportCol);
                                allAgentsList[a].reportColumnsWrapperList = reportColumnsWrapperList;

                                List<brancheDetailsWrapper> brancheDetailsWrapperList = allAgentsList[a].brancheDetailsWrapperList;
                                brancheDetailsWrapperList.add(branchopt);
                                allAgentsList[a].brancheDetailsWrapperList = brancheDetailsWrapperList;
                                gNumberFlag = true;
                                break;
                            }
                        }
                        if(gNumberFlag == false){
                            List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                            reportColumnsWrapperList.add(reportCol);

                            List<brancheDetailsWrapper> brancheDetailsWrapperList = new List<brancheDetailsWrapper>();
                            brancheDetailsWrapperList.add(branchOpt);
                            
                            PDFWrapper newpdfwrap = new PDFWrapper();
                            newpdfwrap.gNumber= agllNumber;
                            newpdfwrap.agllName= instRec.Account__r.Name;
                            newpdfwrap.balanceOutstanding = instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c:0;
                            newpdfwrap.lastSentDate = instRec.Account__r.Statement_Last_Send_Date__c;
                            
                            newpdfwrap.totalBalanceAmount= instRec.Case__r.Amount_of_Disputed_Funds_Required__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Required__c:0; 
                            newpdfwrap.recivedAmount= instRec.Case__r.Amount_of_Disputed_Funds_Received__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Received__c:0; 
                            newpdfwrap.remainingAmount= instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c:0;

                            if(instRec.Inbound_Reports__r.size() > 0){
                                newpdfwrap.remainingAmount -= (instRec.Inbound_Reports__r[0].Amount__c!= null? instRec.Inbound_Reports__r[0].Amount__c:0);
                                newpdfwrap.balanceOutstanding -= (instRec.Inbound_Reports__r[0].Amount__c!= null? instRec.Inbound_Reports__r[0].Amount__c:0);
                                newpdfwrap.amountAfter10Days =  -(instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c:0);
                                newpdfwrap.amountAfter20Days =  -(instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c:0);
                                newpdfwrap.amountAfter30Days =  -(instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c:0);
                                newpdfwrap.amountBefore10Days =  -(instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c:0);
                            }else{
                                newpdfwrap.amountAfter10Days = instRec.Case__r.Amount_Received_After_10_Days__c!=null?instRec.Case__r.Amount_Received_After_10_Days__c:0;  
                                newpdfwrap.amountAfter20Days = instRec.Case__r.Amount_Received_After_20_Days__c!=null?instRec.Case__r.Amount_Received_After_20_Days__c:0;  
                                newpdfwrap.amountAfter30Days = instRec.Case__r.Amount_Received_After_30_Days__c!=null?instRec.Case__r.Amount_Received_After_30_Days__c:0;  
                                newpdfwrap.amountBefore10Days = instRec.Case__r.Amount_Received_Before_10_Days__c!=null?instRec.Case__r.Amount_Received_Before_10_Days__c:0;  
                            }
                            newpdfwrap.reportColumnsWrapperList = reportColumnsWrapperList;
                            newpdfwrap.brancheDetailsWrapperList = brancheDetailsWrapperList;
                            newpdfwrap.isSelected = false;
                            allAgentsList.add(newpdfwrap);
                        }
                    }
                }
            }

            Map<String, String> nameAndGNumberMap =	new Map<String, String>(); 
            Map<String, Account> nameAndAccountMap = new Map<String, Account>(); 
            Map<String, Case> nameAndCaseRefMap =	new Map<String, Case>(); 

            List<inbReporDetailsWrapper> inbReportWrapperList = new List<inbReporDetailsWrapper>();
            if(InboundReportsList.size() > 0){
                Set<String> nameSet = new Set<String>();
                Set<String> caseRefSet = new Set<String>();
                for(Inbound_Report__c inbrep : InboundReportsList){
                    nameSet.add(inbrep.Reference1__c);

                    if(inbrep.Reference2__c != null && inbrep.Reference2__c != ''){
                        caseRefSet.add(inbrep.Reference2__c);
                    }else if(inbrep.Reference3__c != null && inbrep.Reference3__c != ''){
                        caseRefSet.add(inbrep.Reference3__c);
                    }else if(inbrep.Reference4__c != null && inbrep.Reference4__c != ''){
                        caseRefSet.add(inbrep.Reference4__c);
                    }else if(inbrep.Reference5__c != null && inbrep.Reference5__c != ''){
                        caseRefSet.add(inbrep.Reference5__c);
                    }
                }
                
                List<Account> accList = [Select Id, Name, G_Number__c, G_Number__pc, EWI_Landlord_Id__c, Statement_Last_Send_Date__c 
                                        From Account Where Name in :nameSet and (recordType.Name = 'EWI_Agent' or recordType.Name = 'EWI_IndependentLandlord' or 
                                        recordType.Name = 'EWI_NonMemberLandlord' or recordType.Name = 'EWI_Tenant')];
                // List<Account> unknownAcc = [Select Id, Name, G_Number__c, Statement_Last_Send_Date__c From Account Where Name = 'Agent Unknown Red' limit 1];
                List<Case> caseRefList = new  List<Case>();
                if(selectedBranchSTR != 'Select all'){
                    caseRefList = [Select Id, Dispute_Reference__c, Status, Member_Status__c, Agent_Branch__c, Agent_Branch__r.EWI_Branch_Name__c, Deposit_Account_Number__r.First_line_of_address_with_postcode__c, No_of_Times_Chased__c, Last_Chased_Date__c From Case
                                    Where Dispute_Reference__c IN :caseRefSet and Agent_Branch__r.EWI_Branch_Name__c =: selectedBranch  and recordtype.Name = 'Dispute EW Insured'];
                }else{
                    caseRefList = [Select Id, Dispute_Reference__c, Status, Member_Status__c, Agent_Branch__c, Agent_Branch__r.EWI_Branch_Name__c, Deposit_Account_Number__r.First_line_of_address_with_postcode__c, No_of_Times_Chased__c, Last_Chased_Date__c From Case
                                    Where Dispute_Reference__c IN :caseRefSet and recordtype.Name = 'Dispute EW Insured'];
                }

                for(Account acc : accList){
                    if(!nameAndGNumberMap.containsKey(acc.Name)){
                        String gNumberForMap = '';
                        if(acc.G_Number__c!= null){
                            gNumberForMap = acc.G_Number__c;
                        }else if(acc.G_Number__pc!= null){
                            gNumberForMap = acc.G_Number__pc;
                        }else if(acc.EWI_Landlord_Id__c!= null){
                            gNumberForMap = acc.EWI_Landlord_Id__c;
                        }
                        nameAndGNumberMap.put(acc.Name, gNumberForMap);
                        nameAndGNumberMap.put(gNumberForMap, gNumberForMap);
                        nameAndAccountMap.put(acc.Name, acc);
                    }
                    /*else{
                        nameAndGNumberMap.put(acc.Name, unknownAcc[0].G_Number__c);
                    }*/
                }
                // for(string str : nameSet ){
                //     if(!nameAndGNumberMap.containsKey(str)){
                //         nameAndGNumberMap.put(str, unknownAcc[0].G_Number__c);
                //         nameAndAccountMap.put(str, unknownAcc[0]);
                //     }
                // }
                for(String keyName : nameAndGNumberMap.keySet()){
                    nameAndGnumberWrapper newwrap = new nameAndGnumberWrapper();
                    newwrap.name= keyName; 
                    newwrap.gNumber= nameAndGNumberMap.get(keyName);
                    newwrap.accRecord = nameAndAccountMap.get(keyName);
                    nameAndGnumberList.add(newwrap);
                }

                for(Case cs : caseRefList){
                    nameAndCaseRefMap.put(cs.Dispute_Reference__c, cs);
                }

                for(Inbound_Report__c inbRep : InboundReportsList){
                    String disputeRef = '';
                    if(inbrep.Reference2__c != null && inbrep.Reference2__c != ''){
                        disputeRef = inbrep.Reference2__c;
                    }else if(inbrep.Reference3__c != null && inbrep.Reference3__c != ''){
                        disputeRef = inbrep.Reference3__c;
                    }else if(inbrep.Reference4__c != null && inbrep.Reference4__c != ''){
                        disputeRef = inbrep.Reference4__c;
                    }else if(inbrep.Reference5__c != null && inbrep.Reference5__c != ''){
                        disputeRef = inbrep.Reference5__c;
                    }
                    if(nameAndGNumberMap.get(inbRep.Reference1__c) != null){
                        inbReporDetailsWrapper newwrap = new inbReporDetailsWrapper();
                        newwrap.inbReport= inbRep; 
                        newwrap.gNumber= nameAndGNumberMap.get(inbRep.Reference1__c);
                        newwrap.Dispute_Reference = nameAndCaseRefMap.get(disputeRef);
                        inbReportWrapperList.add(newwrap);
                    }
                    // if(nameAndCaseRefMap.get(disputeRef) != null && nameAndGNumberMap.get(inbRep.Reference1__c) != null){
                    //     Case inbReportDispute = nameAndCaseRefMap.get(disputeRef);
                    //     if(inbReportDispute != null && inbReportDispute.Status != null &&
                    //         (inbReportDispute.Status == 'Case closed – Resolved without adjudication' ||
                    //         inbReportDispute.Status == 'Deposit closed - deposit repaid in part' ||
                    //         inbReportDispute.Status == 'Deposit closed - deposit repaid in full' ||
                    //         inbReportDispute.Status == 'Case closed – court order' ||
                    //         inbReportDispute.Status == 'Case closed - Court case' ||
                    //         inbReportDispute.Status == 'Complaint closed' ||
                    //         inbReportDispute.Status == '4 - Medium level complaint' ||
                    //         inbReportDispute.Status == '5 - High level complaint' ||
                    //         inbReportDispute.Status == 'Case closed – no dispute')
                    //     ){
                            // inbReporDetailsWrapper newwrap = new inbReporDetailsWrapper();
                            // newwrap.inbReport= inbRep; 
                            // newwrap.gNumber= nameAndGNumberMap.get(inbRep.Reference1__c);
                            // newwrap.Dispute_Reference = nameAndCaseRefMap.get(disputeRef);
                            // inbReportWrapperList.add(newwrap);
                    //     }
                    // }
                }

                // create reportColumnsWrapper element from Inbound Reports records
                for(inbReporDetailsWrapper inbReportRec : inbReportWrapperList){
                    reportColumnsWrapper reportCol = new reportColumnsWrapper();
                    reportCol.dueDate = inbReportRec.inbReport.Collection_Date__c;
                    reportCol.daysoverDue = '';
                    reportCol.AGLLNumber = inbReportRec.gNumber;
                    reportCol.AGLLName = inbReportRec.inbReport.Reference1__c!=null && inbReportRec.inbReport.Reference1__c!= ''
                                        ? inbReportRec.inbReport.Reference1__c : 'Unidentified Rec';
                    reportCol.accRecordId = nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c) !=null
                        ?nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Id : '';
                    reportCol.memberStatus = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Member_Status__c!=null
                                            ? inbReportRec.Dispute_Reference.Member_Status__c : '';
                    reportCol.EWIBranchName = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Agent_Branch__c!=null && inbReportRec.Dispute_Reference.Agent_Branch__r.EWI_Branch_Name__c!=null
                                                ? inbReportRec.Dispute_Reference.Agent_Branch__r.EWI_Branch_Name__c: '';
                    reportCol.EWIBranchId = inbReportRec.Dispute_Reference==null || inbReportRec.Dispute_Reference.Agent_Branch__c==null? '': inbReportRec.Dispute_Reference.Agent_Branch__c;
                    reportCol.recivedAmount = inbReportRec.inbReport.Amount__c!= null? String.valueOf(inbReportRec.inbReport.Amount__c):''; 
                    reportCol.remainingAmount = (inbReportRec.inbReport.Amount__c!= null? -(inbReportRec.inbReport.Amount__c):0);  
                    reportCol.amountAfter30Days = inbReportRec.inbReport.Amount_Received_After_30_Days__c != null
                                                    ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_After_30_Days__c)
                                                    : '';
                    reportCol.amountAfter20Days = inbReportRec.inbReport.Amount_Received_After_20_Days__c != null
                                                    ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_After_20_Days__c)
                                                    : '';
                    reportCol.amountAfter10Days = inbReportRec.inbReport.Amount_Received_After_10_Days__c != null
                                                    ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_After_10_Days__c)
                                                    : '';
                    reportCol.amountBefore10Days = inbReportRec.inbReport.Amount_Received_Before_10_Days__c != null
                                                    ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_Before_10_Days__c)
                                                    : '';
                    reportCol.balanceOutstanding = inbReportRec.inbReport.Amount__c!=null
                                                    ? '-'+string.valueOf(inbReportRec.inbReport.Amount__c) : '';
                    reportCol.Type = 'Unallocated receipt';
                    
                    System.debug('inbReportRec.Dispute_Reference.Id => ' + inbReportRec.Dispute_Reference);
                    
                    reportCol.CaseId = inbReportRec.Dispute_Reference==null ? '' : inbReportRec.Dispute_Reference.Id ;
                    reportCol.caseStatus = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Status!=null
                                            ? inbReportRec.Dispute_Reference.Status : '';
                    reportCol.caseDisputeRef = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Dispute_Reference__c!=null && inbReportRec.Dispute_Reference.Dispute_Reference__c!=''
                                                ? inbReportRec.Dispute_Reference.Dispute_Reference__c 
                                                : inbReportRec.inbReport.Reference2__c;
                    reportCol.tenancyAddress = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Deposit_Account_Number__r!=null && inbReportRec.Dispute_Reference.Deposit_Account_Number__r.First_line_of_address_with_postcode__c!=null
                                                ? inbReportRec.Dispute_Reference.Deposit_Account_Number__r.First_line_of_address_with_postcode__c : '';
                    
                    // create brnach details wrapper
                    brancheDetailsWrapper branchopt = new brancheDetailsWrapper();
                    branchopt.label = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Agent_Branch__c!=null && inbReportRec.Dispute_Reference.Agent_Branch__r.EWI_Branch_Name__c!=null
                                        ? inbReportRec.Dispute_Reference.Agent_Branch__r.EWI_Branch_Name__c: '';
                    branchopt.value = inbReportRec.Dispute_Reference==null || inbReportRec.Dispute_Reference.Agent_Branch__c==null? '': inbReportRec.Dispute_Reference.Agent_Branch__c;
                    branchopt.selected = false;
                    
                    //add inbound report to allAgent's ReportColumnWrapperList
                    Boolean gNumberFlag = false;
                    for(integer a=0; a<allAgentsList.size(); a++){
                        if(allAgentsList[a].gNumber == inbReportRec.gNumber)
                        {
                            if(nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Statement_Last_Send_Date__c!=null && allAgentsList[a].lastSentDate!=null){
                                if(nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Statement_Last_Send_Date__c > allAgentsList[a].lastSentDate){
                                    allAgentsList[a].lastSentDate = nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Statement_Last_Send_Date__c;
                                }
                            }else if(allAgentsList[a].lastSentDate==null){
                                allAgentsList[a].lastSentDate = nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Statement_Last_Send_Date__c;
                            }

                            allAgentsList[a].recivedAmount += inbReportRec.inbReport.Amount__c!= null? inbReportRec.inbReport.Amount__c:0;  
                            allAgentsList[a].remainingAmount -= inbReportRec.inbReport.Amount__c!= null? inbReportRec.inbReport.Amount__c:0;  

                            allAgentsList[a].balanceOutstanding -= inbReportRec.inbReport.Amount__c!= null? inbReportRec.inbReport.Amount__c:0;
                            allAgentsList[a].amountAfter10Days -= inbReportRec.inbReport.Amount_Received_After_10_Days__c!=null? inbReportRec.inbReport.Amount_Received_After_10_Days__c:0;
                            allAgentsList[a].amountAfter20Days -= inbReportRec.inbReport.Amount_Received_After_20_Days__c!=null? inbReportRec.inbReport.Amount_Received_After_20_Days__c:0;
                            allAgentsList[a].amountAfter30Days -= inbReportRec.inbReport.Amount_Received_After_30_Days__c!=null? inbReportRec.inbReport.Amount_Received_After_30_Days__c:0;
                            allAgentsList[a].amountBefore10Days -= inbReportRec.inbReport.Amount_Received_Before_10_Days__c!=null? inbReportRec.inbReport.Amount_Received_Before_10_Days__c:0;
                            
                            List<reportColumnsWrapper> reportColumnsWrapperList = allAgentsList[a].reportColumnsWrapperList;
                            reportColumnsWrapperList.add(reportCol);
                            allAgentsList[a].reportColumnsWrapperList = reportColumnsWrapperList;

                            List<brancheDetailsWrapper> brancheDetailsWrapperList = allAgentsList[a].brancheDetailsWrapperList;
                            brancheDetailsWrapperList.add(branchopt);
                            allAgentsList[a].brancheDetailsWrapperList = brancheDetailsWrapperList;
                            gNumberFlag = true;
                            break;
                        }
                    }
                    if(gNumberFlag == false){
                        List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                        reportColumnsWrapperList.add(reportCol);
                        
                        List<brancheDetailsWrapper> brancheDetailsWrapperList = new List<brancheDetailsWrapper>();
                        brancheDetailsWrapperList.add(branchopt);

                        PDFWrapper newpdfwrap = new PDFWrapper();
                        newpdfwrap.gNumber= inbReportRec.gNumber;
                        newpdfwrap.agllName= inbReportRec.inbReport.Reference1__c;
                        newpdfwrap.lastSentDate = nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Statement_Last_Send_Date__c;
                        newpdfwrap.recivedAmount = inbReportRec.inbReport.Amount__c!= null? inbReportRec.inbReport.Amount__c:0; 
                        newpdfwrap.remainingAmount = -(inbReportRec.inbReport.Amount__c!= null? inbReportRec.inbReport.Amount__c:0);  
                        newpdfwrap.balanceOutstanding = -(inbReportRec.inbReport.Amount__c!= null? inbReportRec.inbReport.Amount__c:0);
                        newpdfwrap.amountAfter10Days = -(inbReportRec.inbReport.Amount_Received_After_10_Days__c!=null? inbReportRec.inbReport.Amount_Received_After_10_Days__c:0);
                        newpdfwrap.amountAfter20Days = -(inbReportRec.inbReport.Amount_Received_After_20_Days__c!=null? inbReportRec.inbReport.Amount_Received_After_20_Days__c:0);
                        newpdfwrap.amountAfter30Days = -(inbReportRec.inbReport.Amount_Received_After_30_Days__c!=null? inbReportRec.inbReport.Amount_Received_After_30_Days__c:0);
                        newpdfwrap.amountBefore10Days = -(inbReportRec.inbReport.Amount_Received_Before_10_Days__c!=null? inbReportRec.inbReport.Amount_Received_Before_10_Days__c:0);
                        newpdfwrap.reportColumnsWrapperList = reportColumnsWrapperList;
                        newpdfwrap.brancheDetailsWrapperList = brancheDetailsWrapperList;
                        newpdfwrap.isSelected = false;
                        allAgentsList.add(newpdfwrap);
                    }
                }
            }

            allAgentsList.sort();
            for(PDFWrapper pdfWrap : allAgentsList){
                pdfWrap.reportColumnsWrapperList.sort();
            }
			System.debug('nameAndGnumberList => ' + nameAndGnumberList);
            System.debug('allAgentsList => ' + allAgentsList);
            if(allAgentsList.size()>0 && nameAndGnumberList.size()>0 ){
                System.debug('return Data');
                doInitData dd = new doInitData();
                dd.nameAndGnumber = nameAndGnumberList;
                dd.PDFWrapperList = allAgentsList;
                return dd;
            }else{
                System.debug('return NULL');
                return null;
            }
        }catch(exception e){
            System.debug('ERROR => ' + e.getMessage()+' at Line => ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' at Line => ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static String sendAsPDF(String selectedAgllListstr, String selectedBranch){
        try{
            System.debug('String JSON.deserialize => ' + selectedAgllListstr);
            Map<Id, Account> accListToUpdate = new Map<Id, Account>();
            
            List<String> gNumberandNameList = selectedAgllListstr.split(',');
            System.debug('gNumberandNameList => ' + gNumberandNameList);
            
            List<EI_MailJetUtility.EmailWrapper> emailWrapperList = new List<EI_MailJetUtility.EmailWrapper>();
            for(String gNumberandName : gNumberandNameList){
                String gNumber = gNumberandName.split(':')[0];
                String agllName = gNumberandName.split(':')[1];
                List<Case_participant__c> caseParList = [select Id,Access_Code__c,Case__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Bank_Name__c, Case__r.Dispute_Reference__c,
                                                         Contact__r.Sort_Code__c,Contact__r.Account_Number__c,Account__c, Account__r.Name, Account__r.Email__c, 
                                                         Account__r.PersonEmail, Is_Lead__c, Type__c,Case__r.Disputed_Amount__c,Bank_Account__c,Bank_Account__r.Name,
                                                         International_Payment__c,Swift_Code__c,International_Bank_Name__c,Primary_Agent__c,Bank_Account_Number__c,Bank_Sort_Code__c,
                                                         Case__r.V_External_Id__c,case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,
                                                         Case__r.Respond_Date__c, Case__r.Amount_to_tenants__c,Disputes_credit_control__c,
                                                         Case__r.Amount_to_agent_landlord__c, Case__r.Status, Case__r.Amount_of_Disputed_Funds_Remaining__c,
                                                         Primary_Email__c, Other_Emails__c, Phone__c, House_No__c, Street__c, City__c, State__c, Postal_Code__c, Country__c
                                                         from Case_Participant__c where 
                                                         (Account__r.G_Number__c =:gNumber or Account__r.G_Number__pc =:gNumber or Account__r.EWI_Landlord_Id__c =:gNumber)
                                                         and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                                                        Case__r.Status = 'Evidence gathering tenant' OR
                                                        Case__r.Status = 'Evidence review complete' OR
                                                        Case__r.Status = 'Adjudication' OR
                                                        Case__r.Status = 'Deposit to be repaid - resolved without adjudication' OR
                                                        Case__r.Status = 'Deposit to be repaid - decision issued' OR
                                                        Case__r.Status = 'On Hold' OR
                                                        Case__r.Status = 'Awaiting Review' OR
                                                        Case__r.Status = 'Potential insurance claim - pending information' OR
                                                        Case__r.Status = 'Clarification needed' OR
                                                        Case__r.Status = 'Consent to resolution not given' OR
                                                        Case__r.Status = 'Decision issued – dispute monies outstanding' OR
                                                        Case__r.Status = 'Deposit to be repaid - Court order' OR
                                                        Case__r.Status = 'Deposit to be repaid - no proof of court action' OR
                                                        Case__r.Status = 'Decision issued – insurance claim' OR
                                                        Case__r.Status = 'Decision issued - with legal' OR
                                                        Case__r.Status = 'Overpayments' OR
                                                        Case__r.Status = 'Case closed – Resolved without adjudication' OR
                                                        Case__r.Status = 'Deposit closed - deposit repaid in part' OR
                                                        Case__r.Status = 'Deposit closed - deposit repaid in full' OR
                                                        Case__r.Status = 'Case closed – court order' OR
                                                        Case__r.Status = 'Case closed - Court case' OR
                                                        Case__r.Status = 'Complaint closed' OR
                                                        Case__r.Status = '4 - Medium level complaint' OR
                                                        Case__r.Status = '5 - High level complaint' OR
                                                        Case__r.Status = 'Case closed – no dispute') 
                                                        and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and Case__r.Evidence_Gathering_Start_Date__c!=null and Case__r.Evidence_Gathering_AGLL_DueDate__c <=today
                                                        and case__r.recordtype.Name = 'Dispute EW Insured' 
                                                        order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc
                                                    ];
                
                Account acc = new Account();
                acc.Id = caseParList[0].Account__c;
                acc.Statement_Last_Send_Date__c = System.today();
                accListToUpdate.put(acc.id, acc);
                string address1 = caseParList[0].House_No__c+' '+caseParList[0].Street__c;
                String address2 = caseParList[0].City__c+' '+caseParList[0].State__c;
                String postCode = caseParList[0].Postal_Code__c;
                PageReference pdfPage = new PageReference('/apex/EI_EWI_StatementOfAccount');
                pdfPage.getParameters().put('gNumber', gNumber);
                pdfPage.getParameters().put('selectedBranch', selectedBranch);
                pdfPage.getParameters().put('agllName', agllName);
                pdfPage.getParameters().put('address1', address1);
                pdfPage.getParameters().put('address2', address2);
                pdfPage.getParameters().put('postCode', postCode);
                Blob bodyAsBlob = pdfPage.getContentAsPDF();
                //System.debug('bodyAsBlob => ' + bodyAsBlob);
                
                //if(bodyAsBlob != null ){ 
                system.debug('line 785 '+caseParList);
                String emails = '';
                for(Case_participant__c cs : caseParList){
                    System.debug('cs.Type__c => ' + cs.Type__c);
                    System.debug('cs.Primary_Email__c => ' + cs.Primary_Email__c);
                    System.debug('cs.Disputes_credit_control__c => ' + cs.Disputes_credit_control__c);
                    System.debug('emails Before' + emails);
                    List<EI_MailJetUtility.recipient> emailRecipientList = new List<EI_MailJetUtility.recipient>();
                    if(cs.Type__c != 'Agent' || (cs.Type__c == 'Agent' && cs.Disputes_credit_control__c == null)){
                        if(cs.Primary_Email__c!=null && !emails.contains(cs.Primary_Email__c)){
                            System.debug('emails does not contains ' + emails);
                            emailRecipientList.add(new EI_MailJetUtility.recipient(cs.Primary_Email__c, cs.Account__r.Name, cs.Id, cs.Account__c, cs.Id));
                    		emails += cs.Primary_Email__c+',';
                            System.debug('emails After' + emails);
                            
                            Map<String, String> variableMap = new Map<String, String>();
                            variableMap.put('TDSN_No', cs.Case__r.Dispute_Reference__c!=null?cs.Case__r.Dispute_Reference__c:'');
                            variableMap.put('property_address', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'') ;
                            
                            List<EI_MailJetUtility.attachmentWrapper> attachmentWrapperList = new List<EI_MailJetUtility.attachmentWrapper>();
                            attachmentWrapperList.add(new EI_MailJetUtility.attachmentWrapper('application/pdf', 'statement of Account-'+gNumber, EncodingUtil.base64Encode(bodyAsBlob)));
                            
                            emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 'Statement_of_account', cs.Case__r.Dispute_Reference__c+'Statement of Account', cs, JSON.serialize(attachmentWrapperList)));
                        }
                    }else if(cs.Type__c == 'Agent' && cs.Disputes_credit_control__c != null){
                        emails += cs.Disputes_credit_control__c;

                        Map<String, String> variableMap = new Map<String, String>();
                        variableMap.put('TDSN_No', cs.Case__r.Dispute_Reference__c!=null?cs.Case__r.Dispute_Reference__c:'');
                        variableMap.put('property_address', cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c!=null?cs.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c:'') ;
                        
                        List<EI_MailJetUtility.attachmentWrapper> attachmentWrapperList = new List<EI_MailJetUtility.attachmentWrapper>();
                        attachmentWrapperList.add(new EI_MailJetUtility.attachmentWrapper('application/pdf', 'statement of Account-'+gNumber, EncodingUtil.base64Encode(bodyAsBlob)));
                        
                        emailWrapperList.add(new EI_MailJetUtility.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 'Statement_of_account', cs.Case__r.Dispute_Reference__c+'Statement of Account', cs, JSON.serialize(attachmentWrapperList)));
                    }
                    
                    
                }  
            }
    
            if(emailWrapperList.size() > 0){
                EI_MailJetUtility.sendEmail(JSON.serialize(emailWrapperList));    
                System.debug('emailWrapperList => ' + emailWrapperList);
            }
            
            if(accListToUpdate.size() > 0){
                update accListToUpdate.values();
            }
            return 'success';
           
        }catch(exception e){
            System.debug('Errors => ' + e.getMessage() + e.getLineNumber());
            return e.getMessage() + e.getLineNumber();
        }
    }
    
    public string gNumber {get;set;}
    public string agllName {get;set;}
    public string address1 {get;set;}
    public string address2 {get;set;}
    public string postCode {get;set;}
    public Date todayDate {get;set;}
    public List<Installment__c> installmentListDATA {get;set;}
    public List<Inbound_Report__c> InboundReportsListDATA {get;set;}
    public PDFWrapper PDFWrapperData {get;set;}
    public Decimal balanceOutstanding {get;set;}
    public Decimal amountAfter10Days {get;set;}
    public Decimal amountAfter20Days {get;set;}
    public Decimal amountAfter30Days {get;set;}
    public Decimal amountBefore10Days {get;set;}
    public EI_EWI_BatchOfStatementCls(){
        todayDate = System.today();
        gNumber = ApexPages.currentPage().getParameters().get('gNumber');
        agllName = ApexPages.currentPage().getParameters().get('agllName');
        address1 = ApexPages.currentPage().getParameters().get('address1');
        address2 = ApexPages.currentPage().getParameters().get('address2');
        postCode = ApexPages.currentPage().getParameters().get('postCode');
        String selectedBranchSTR = ApexPages.currentPage().getParameters().get('selectedBranch');
        String isDownload = ApexPages.currentPage().getParameters().get('isDownload');
        // System.debug('Statement of Acc selectedBranch => ' + selectedBranchSTR);
        // List<String> selectedBranchList = new List<String>();
        // selectedBranchList = selectedBranchSTR.split(', ');
        // Set<String> selectedBranch = new Set<String>();
        // selectedBranch.addAll(selectedBranchList);

        // if(selectedBranchSTR != 'Select all'){
        //     List<Installment__c> installmentList = [select Id, Amount__c, Status__c, Contact__c, Contact__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
        //                                             Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c,
        //                                             Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.Property_Address__c, Case__r.Dispute_Reference__c,
        //                                             Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
        //                                             Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
        //                                             Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Case__r.Agent_Branch__r.EWI_Branch_Name__c, Case__r.Days_Overdue__c,
        //                                             (Select id, Amount__c, Collection_Date__c, Days_Overdue__c,
        //                                              Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
        //                                              from Inbound_Reports__r WHERE Amount__c>0)
        //                                             from Installment__c where Case__c != null and Account__c!=null 
        //                                             and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and Case__r.Evidence_Gathering_Start_Date__c!=null
        //                                             and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
        //                                             and (Account__r.G_Number__c =:gNumber OR Account__r.G_Number__pc=:gNumber OR Account__r.EWI_Landlord_Id__c =:gNumber)
        //                                             and Case__r.Agent_Branch__c =: selectedBranch
        //                                             and case__r.recordtype.Name = 'Dispute EW Insured'];
        //     installmentListDATA = installmentList;    
        // }
        // else{
        //     List<Installment__c> installmentList = [select Id, Amount__c, Status__c, Contact__c, Contact__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
        //                                             Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c,
        //                                             Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.Property_Address__c, Case__r.Dispute_Reference__c,
        //                                             Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
        //                                             Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
        //                                             Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Case__r.Agent_Branch__r.EWI_Branch_Name__c, Case__r.Days_Overdue__c,
        //                                             (Select id, Amount__c, Collection_Date__c, Days_Overdue__c,
        //                                              Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
        //                                              from Inbound_Reports__r WHERE Amount__c>0)
        //                                             from Installment__c where Case__c != null and Account__c!=null 
        //                                             and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and Case__r.Evidence_Gathering_Start_Date__c!=null
        //                                             and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
        //                                             and (Account__r.G_Number__c =:gNumber OR Account__r.G_Number__pc=:gNumber OR Account__r.EWI_Landlord_Id__c =:gNumber)
        //                                             and case__r.recordtype.Name = 'Dispute EW Insured'];
        //     installmentListDATA = installmentList;    
            
        //     List<Inbound_Report__c> InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Collection_Date__c, Days_Overdue__c,
        //                                                   Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
        //                                                   from Inbound_Report__c 
        //                                                   WHERE Amount__c>0 and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' 
        //                                                   and Reference1__c = :agllName ];
        //     InboundReportsListDATA = InboundReportsList;
        // }

        // balanceOutstanding = 0;
        // amountAfter10Days = 0;
        // amountAfter20Days = 0;
        // amountAfter30Days = 0;
        // amountBefore10Days = 0;
        // if(installmentListDATA!= null && installmentListDATA.size() > 0){
        //     for(Installment__c inst : installmentListDATA){
        //         balanceOutstanding += inst.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null? inst.Case__r.Amount_of_Disputed_Funds_Remaining__c:0;
                
        //         if(inst.Inbound_Reports__r.size() > 0){
        //             balanceOutstanding -= inst.Inbound_Reports__r[0].Amount__c!= null? inst.Inbound_Reports__r[0].Amount__c:0;
        //             amountAfter10Days -= inst.Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? inst.Inbound_Reports__r[0].Amount_Received_After_10_Days__c:0;
        //             amountAfter20Days -= inst.Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? inst.Inbound_Reports__r[0].Amount_Received_After_20_Days__c:0;
        //             amountAfter30Days -= inst.Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? inst.Inbound_Reports__r[0].Amount_Received_After_30_Days__c:0;
        //             amountBefore10Days -= inst.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? inst.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c:0;
        //         }else{
        //             // balanceOutstanding += inst.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null? inst.Case__r.Amount_of_Disputed_Funds_Remaining__c:0;
        //             amountAfter10Days += inst.Case__r.Amount_Received_After_10_Days__c!=null? inst.Case__r.Amount_Received_After_10_Days__c:0;
        //             amountAfter20Days += inst.Case__r.Amount_Received_After_20_Days__c!=null? inst.Case__r.Amount_Received_After_20_Days__c:0;
        //             amountAfter30Days += inst.Case__r.Amount_Received_After_30_Days__c!=null? inst.Case__r.Amount_Received_After_30_Days__c:0;
        //             amountBefore10Days += inst.Case__r.Amount_Received_Before_10_Days__c!=null? inst.Case__r.Amount_Received_Before_10_Days__c:0;
        //         }
        //     }
        // }
        
        // if(InboundReportsListDATA!= null && InboundReportsListDATA.size() > 0){
        //     for(Inbound_Report__c inbReport : InboundReportsListDATA){            
        //         balanceOutstanding -= inbReport.Amount__c!= null? inbReport.Amount__c:0;
        //         amountAfter10Days -= inbReport.Amount_Received_After_10_Days__c!=null? inbReport.Amount_Received_After_10_Days__c:0;
        //         amountAfter20Days -= inbReport.Amount_Received_After_20_Days__c!=null? inbReport.Amount_Received_After_20_Days__c:0;
        //         amountAfter30Days -= inbReport.Amount_Received_After_30_Days__c!=null? inbReport.Amount_Received_After_30_Days__c:0;
        //         amountBefore10Days -= inbReport.Amount_Received_Before_10_Days__c!=null? inbReport.Amount_Received_Before_10_Days__c:0;
        //     }
        // }

        doInitData doInitDataWrapper = getDataInWrapperList(gNumber, agllName, selectedBranchSTR);
        System.debug('doInitDataWrapper => ' + doInitDataWrapper);
        PDFWrapperData = doInitDataWrapper.PDFWrapperList[0];

        String str = 'attachment; filename=Statement of Account-'+gNumber+'.pdf';
        if(isDownload == 'true'){
            Apexpages.currentPage().getHeaders().put('content-disposition',str);
        }
    }
    
    public static List<Holiday> holidayList;
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
    
}