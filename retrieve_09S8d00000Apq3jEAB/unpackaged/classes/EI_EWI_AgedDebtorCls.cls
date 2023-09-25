public without sharing class EI_EWI_AgedDebtorCls {

    public List<PDFWrapper> allAgentsListData {get; set;}
    public Date todayDate {get; set;}
    public String currentTime {get; set;}
    public Decimal grandTotalBalance {get; set;}
    public Decimal grandTotalAfter10Days {get; set;}
    public Decimal grandTotalAfter20Days {get; set;}
    public Decimal grandTotalAfter30Days {get; set;}
    public Decimal grandTotalBefore10Days {get; set;}
    
    public EI_EWI_AgedDebtorCls(){
        grandTotalBalance = 0;
        grandTotalAfter10Days = 0;
        grandTotalAfter20Days = 0;
        grandTotalAfter30Days = 0;
        grandTotalBefore10Days = 0;
        
        todayDate = System.today();
        currentTime = System.now().format('HH:mm:ss');
        String gNumber = ApexPages.currentPage().getParameters().get('gNumber');
        String memberStatus = ApexPages.currentPage().getParameters().get('memberStatus');
        String reference1Names = ApexPages.currentPage().getParameters().get('reference1Names');
        System.debug('reference1Names => ' + reference1Names);
        list<string> nameList = new List<String>();
    
        if(reference1Names.contains(',')){
            // nameList = reference1Names.split(', ');
            for(String name : reference1Names.split(',')){
                if(name!='' && name!=' ' && name!=null)
                    nameList.add(name.trim());
            }
        }else{
            nameList.add(reference1Names);
        }
        if(gNumber.contains('G00000')){
            nameList.add('');
            nameList.add(null);
        }
        System.debug('nameList => ' + nameList);
        List<PDFWrapper> allAgentsList = new List<PDFWrapper>();

        List<Installment__c> installmentListDATA = new List<Installment__c>();
        if(gNumber == 'Select all' && memberStatus == 'Select all'){
            System.debug('BOTH Select all ');
            installmentListDATA = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c,Account__r.EWI_Landlord_User_Id__c, Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
                                Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                                Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                                Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                                Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Transaction_Date__c, Transaction_Date_2__c, Case__r.Awaiting_review_Date__c,
                                (Select id, Amount__c, Collection_Date__c, Reference1__c, 
                                Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today 
                                and Reason_For_Unallocation__c != 'Refund to customer'
                                and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                                from Installment__c where Case__c != null and Account__c!=null 
                                and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                                Case__r.Status = 'Evidence gathering tenant' OR
                                Case__r.Status = 'No response from agent/landlord' OR
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
                                and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and ((Case__r.Evidence_Gathering_Start_Date__c!=null AND Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR Case__r.Awaiting_review_Date__c !=null )  
                                and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                                and (Account__r.G_Number__c !=null OR Account__r.G_Number__pc !=null OR Account__r.EWI_Landlord_User_Id__c !=null)
                                and case__r.recordtype.Name = 'Dispute EW Insured' 
                                order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_User_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc ];
        }
        else {
            if(gNumber != 'Select all' && memberStatus != 'Select all'){
                System.debug('gNumber and memberStatus');
                installmentListDATA = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, Account__r.EWI_Landlord_User_Id__c,Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
                                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Transaction_Date__c, Transaction_Date_2__c, Case__r.Awaiting_review_Date__c, 
                                    (Select id, Amount__c, Collection_Date__c, Reference1__c, 
                                    Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                    from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today 
                                    and Reason_For_Unallocation__c != 'Refund to customer'
                                    and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                                    from Installment__c where Case__c != null and Account__c!=null 
                                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                                    Case__r.Status = 'Evidence gathering tenant' OR
                                    Case__r.Status = 'No response from agent/landlord' OR
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
                                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and ((Case__r.Evidence_Gathering_Start_Date__c!=null AND Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR Case__r.Awaiting_review_Date__c !=null )
                                    and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                                    and (Account__r.G_Number__c =:gNumber OR Account__r.G_Number__pc=:gNumber OR Account__r.EWI_Landlord_User_Id__c =:gNumber)
                                    and case__r.recordtype.Name = 'Dispute EW Insured'
                                    and Case__r.Member_Status__c =:memberStatus
                                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_User_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc];
            }
            else if(gNumber != 'Select all'){
                System.debug('memberStatus ');
                installmentListDATA = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, Account__r.EWI_Landlord_User_Id__c,Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
                                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Transaction_Date__c, Transaction_Date_2__c, Case__r.Awaiting_review_Date__c, 
                                    (Select id, Amount__c, Collection_Date__c, Reference1__c, 
                                    Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                    from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today 
                                    and Reason_For_Unallocation__c != 'Refund to customer'
                                    and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                                    from Installment__c where Case__c != null and Account__c!=null 
                                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                                    Case__r.Status = 'Evidence gathering tenant' OR
                                    Case__r.Status = 'No response from agent/landlord' OR
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
                                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and ((Case__r.Evidence_Gathering_Start_Date__c!=null AND Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR Case__r.Awaiting_review_Date__c !=null )
                                    and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                                    and (Account__r.G_Number__c =:gNumber OR Account__r.G_Number__pc=:gNumber OR Account__r.EWI_Landlord_User_Id__c =:gNumber)
                                    and case__r.recordtype.Name = 'Dispute EW Insured' 
                                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_User_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc];
            }
            else if(memberStatus != 'Select all'){
                System.debug('gNumber ');
                installmentListDATA = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c,Account__r.EWI_Landlord_User_Id__c, Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
                                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Transaction_Date__c, Transaction_Date_2__c, Case__r.Awaiting_review_Date__c, 
                                    (Select id, Amount__c, Collection_Date__c, Reference1__c, 
                                    Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                    from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today 
                                    and Reason_For_Unallocation__c != 'Refund to customer'
                                    and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                                    from Installment__c where Case__c != null and Account__c!=null 
                                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                                    Case__r.Status = 'Evidence gathering tenant' OR
                                    Case__r.Status = 'No response from agent/landlord' OR
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
                                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and ((Case__r.Evidence_Gathering_Start_Date__c!=null AND Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR Case__r.Awaiting_review_Date__c !=null )
                                    and (Installment_Type__c = 'Receivable' and Status__c = 'Pending') 
                                    and (Account__r.G_Number__c !=null OR Account__r.G_Number__pc !=null OR Account__r.EWI_Landlord_User_Id__c !=null)
                                    and case__r.recordtype.Name = 'Dispute EW Insured'
                                    and Case__r.Member_Status__c =:memberStatus 
                                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_User_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc];
            }
        }
        
        System.debug('installmentListDATA => ' + installmentListDATA.size());
        
        if(installmentListDATA.size() > 0){
            // iterate over installment list
            for (integer i=0; i<installmentListDATA.size(); i++) {
                // create reportColumnsWrapper element from installment record
                Installment__c instRec = installmentListDATA[i];
                String agllNumber = '';
                if(instRec.Account__r.G_Number__c!= null){
                    agllNumber = instRec.Account__r.G_Number__c;
                }else if(instRec.Account__r.G_Number__pc!= null){
                    agllNumber = instRec.Account__r.G_Number__pc;
                }else if(instRec.Account__r.EWI_Landlord_User_Id__c!= null){
                    //agllNumber = instRec.Account__r.EWI_Landlord_Id__c;
                    agllNumber = instRec.Account__r.EWI_Landlord_User_Id__c;
                    
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
                    instRec.Case__r.Status == 'No response from agent/landlord' ||
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
                    reportCol.AGLLNumber = agllNumber;
                    reportCol.AGLLName = instRec.Account__r.Name;
                    reportCol.memberStatus = instRec.Case__r.Member_Status__c!=null? instRec.Case__r.Member_Status__c: '';
                    reportCol.amountAfter30Days = instRec.Inbound_Reports__r.size()>0
                                                ? (instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_After_30_Days__c.setScale(2)) : '')
                                                : (instRec.Case__r.Amount_Received_After_30_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_After_30_Days__c.setScale(2)) : '');
                    reportCol.amountAfter20Days = instRec.Inbound_Reports__r.size()>0
                                                ? (instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_After_20_Days__c.setScale(2)) : '')
                                                : (instRec.Case__r.Amount_Received_After_20_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_After_20_Days__c.setScale(2)) : '');
                    reportCol.amountAfter10Days = instRec.Inbound_Reports__r.size()>0
                                                ? (instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_After_10_Days__c.setScale(2)) : '')
                                                : (instRec.Case__r.Amount_Received_After_10_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_After_10_Days__c.setScale(2)) : '');
                    reportCol.amountBefore10Days = instRec.Inbound_Reports__r.size()>0
                                                ? (instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount_Received_Before_10_Days__c.setScale(2)) : '')
                                                : (instRec.Case__r.Amount_Received_Before_10_Days__c!=null? string.valueOf(instRec.Case__r.Amount_Received_Before_10_Days__c.setScale(2)) : '');
                    reportCol.balanceOutstanding = instRec.Inbound_Reports__r.size()>0
                                                ? (instRec.Inbound_Reports__r[0].Amount__c!=null? '-'+String.valueOf(instRec.Inbound_Reports__r[0].Amount__c.setScale(2)) : '')
                                                : (instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c!=null? string.valueOf(instRec.Case__r.Amount_of_Disputed_Funds_Remaining__c.setScale(2)) : '');
                    reportCol.Type = instRec.Inbound_Reports__r.size()>0
                                    ? 'Unallocated receipt'
                                    : 'Outstanding case';
                    reportCol.caseStatus = instRec.Case__r.Status;
                    reportCol.caseDisputeRef = instRec.Case__r.Dispute_Reference__c!=null? instRec.Case__r.Dispute_Reference__c : '';
                    reportCol.tenancyAddress = instRec.Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c!=null
                                                ? instRec.Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c
                                                : '';
                    reportCol.NoOfTimesChased = instRec.Case__r.No_of_Times_Chased__c!=null && instRec.Case__r.No_of_Times_Chased__c > 0 
                                                ? instRec.Case__r.No_of_Times_Chased__c 
                                                : 0;
                    reportCol.LastChasedDate = instRec.Case__r.Last_Chased_Date__c;

                    Boolean gNumberFlag = false;
                    for(integer a=0; a<allAgentsList.size(); a++){
                        if(allAgentsList[a].gNumber == agllNumber)
                        {
                            allAgentsList[a].balanceOutstanding += installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c:0;

                            if(installmentListDATA[i].Inbound_Reports__r.size() > 0){
                                if(installmentListDATA[i].Inbound_Reports__r[0].Collection_Date__c > allAgentsList[a].lastTransDate){
                                    allAgentsList[a].lastTransDate = installmentListDATA[i].Inbound_Reports__r[0].Collection_Date__c;
                                }
                                allAgentsList[a].balanceOutstanding -= installmentListDATA[i].Inbound_Reports__r[0].Amount__c!= null? installmentListDATA[i].Inbound_Reports__r[0].Amount__c:0;
                                allAgentsList[a].amountAfter10Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_10_Days__c:0;
                                allAgentsList[a].amountAfter20Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_20_Days__c:0;
                                allAgentsList[a].amountAfter30Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_30_Days__c:0;
                                allAgentsList[a].amountBefore10Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_Before_10_Days__c:0;
                            }else{
                                if(installmentListDATA[i].Transaction_Date_2__c > allAgentsList[a].lastTransDate){
                                    allAgentsList[a].lastTransDate = installmentListDATA[i].Transaction_Date_2__c;
                                }
                                allAgentsList[a].amountAfter10Days += installmentListDATA[i].Case__r.Amount_Received_After_10_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_10_Days__c:0;  
                                allAgentsList[a].amountAfter20Days += installmentListDATA[i].Case__r.Amount_Received_After_20_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_20_Days__c:0;  
                                allAgentsList[a].amountAfter30Days += installmentListDATA[i].Case__r.Amount_Received_After_30_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_30_Days__c:0;  
                                allAgentsList[a].amountBefore10Days += installmentListDATA[i].Case__r.Amount_Received_Before_10_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_Before_10_Days__c:0;  
                            }
                            
                            List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                            reportColumnsWrapperList = allAgentsList[a].reportColumnsWrapperList;
                            reportColumnsWrapperList.add(reportCol);
                            allAgentsList[a].reportColumnsWrapperList = reportColumnsWrapperList;

                            gNumberFlag = true;
                            break;
                        }
                    }
                    if(gNumberFlag == false){
                        List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                        reportColumnsWrapperList.add(reportCol); 

                        PDFWrapper newpdfwrap = new PDFWrapper();
                        newpdfwrap.gNumber= agllNumber;
                        newpdfwrap.agllName= installmentListDATA[i].Account__r.Name;
                        newpdfwrap.balanceOutstanding = installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c:0;
                        if(installmentListDATA[i].Inbound_Reports__r.size() > 0){
                            newpdfwrap.lastTransDate = installmentListDATA[i].Inbound_Reports__r[0].Collection_Date__c;
                            newpdfwrap.balanceOutstanding -= (installmentListDATA[i].Inbound_Reports__r[0].Amount__c!= null? installmentListDATA[i].Inbound_Reports__r[0].Amount__c:0);
                            newpdfwrap.amountAfter10Days =  -(installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_10_Days__c:0);
                            newpdfwrap.amountAfter20Days =  -(installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_20_Days__c:0);
                            newpdfwrap.amountAfter30Days =  -(installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_30_Days__c:0);
                            newpdfwrap.amountBefore10Days =  -(installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_Before_10_Days__c:0);
                        }else{
                            newpdfwrap.lastTransDate= installmentListDATA[i].Transaction_Date_2__c;
                            newpdfwrap.amountAfter10Days = installmentListDATA[i].Case__r.Amount_Received_After_10_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_10_Days__c:0;  
                            newpdfwrap.amountAfter20Days = installmentListDATA[i].Case__r.Amount_Received_After_20_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_20_Days__c:0;  
                            newpdfwrap.amountAfter30Days = installmentListDATA[i].Case__r.Amount_Received_After_30_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_30_Days__c:0;  
                            newpdfwrap.amountBefore10Days = installmentListDATA[i].Case__r.Amount_Received_Before_10_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_Before_10_Days__c:0;  
                        }
                        newpdfwrap.reportColumnsWrapperList= reportColumnsWrapperList;
                        newpdfwrap.isSelected= false;
                        allAgentsList.add(newpdfwrap);
                    }
                    
                    grandTotalBalance += installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c!=null?installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c:0;

                    if(installmentListDATA[i].Inbound_Reports__r.size() > 0){
                        grandTotalBalance -= installmentListDATA[i].Inbound_Reports__r[0].Amount__c!= null? installmentListDATA[i].Inbound_Reports__r[0].Amount__c:0;
                        grandTotalAfter10Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_10_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_10_Days__c:0;
                        grandTotalAfter20Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_20_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_20_Days__c:0;
                        grandTotalAfter30Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_30_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_After_30_Days__c:0;
                        grandTotalBefore10Days -= installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_Before_10_Days__c!=null? installmentListDATA[i].Inbound_Reports__r[0].Amount_Received_Before_10_Days__c:0;  
                    }else{
                        System.debug('remaining => ' + installmentListDATA[i].Case__r.Amount_of_Disputed_Funds_Remaining__c);
                        grandTotalAfter10Days += installmentListDATA[i].Case__r.Amount_Received_After_10_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_10_Days__c:0;  
                        grandTotalAfter20Days += installmentListDATA[i].Case__r.Amount_Received_After_20_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_20_Days__c:0;  
                        grandTotalAfter30Days += installmentListDATA[i].Case__r.Amount_Received_After_30_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_After_30_Days__c:0;  
                        grandTotalBefore10Days += installmentListDATA[i].Case__r.Amount_Received_Before_10_Days__c!=null?installmentListDATA[i].Case__r.Amount_Received_Before_10_Days__c:0;  
                    }
                }
            }
        }
        
        List<Inbound_Report__c> InboundReportsList = new List<Inbound_Report__c>();
        if(reference1Names=='Select all'){
            InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Reference2__c, Reference3__c, Reference4__c, Reference5__c, Collection_Date__c,
                                                        Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                        from Inbound_Report__c WHERE Amount__c>0 and Collection_Date__c<=Today and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' 
                                                        and Reason_For_Unallocation__c != 'Refund to customer'
                                                        and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc
                                                       ]; 
        }else{
            InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Reference2__c, Reference3__c, Reference4__c, Reference5__c, Collection_Date__c,
                                                        Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                        from Inbound_Report__c WHERE Amount__c>0 and Collection_Date__c<=Today and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' 
                                                        and Reason_For_Unallocation__c != 'Refund to customer'
                                                        and Reference1__c IN :nameList and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc]; 
        }
        
        System.debug('InboundReportsList => ' + InboundReportsList.size());
        
        Map<String, String> nameAndGNumberMap =	new Map<String, String>(); 
        Map<String, Case> nameAndCaseRefMap =	new Map<String, Case>(); 
        System.debug('InboundReportsList => ' + InboundReportsList.size());
        if(InboundReportsList.size() > 0){
            Set<String> nameSet = new Set<String>();
            Set<String> caseRefSet = new Set<String>();
            for(Inbound_Report__c inbrep : InboundReportsList){
                
                //if(String.isNotBlank(inbrep.Reference1__c))
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
            
            /*List<Account> accList = [Select Id, Name, G_Number__c, G_Number__pc, EWI_Landlord_Id__c From Account 
                                    Where Name in :nameSet and (recordType.Name = 'EWI_Agent' or recordType.Name = 'EWI_Indepandent_Landlord' or 
                                        recordType.Name = 'EWI_NonMemberLandlord' or recordType.Name = 'EWI_Tenant' or recordType.Name = 'EWI Member')];
            */
            List<Account> accList = [Select Id, Name, G_Number__c, G_Number__pc, EWI_Landlord_Id__c,EWI_Landlord_User_Id__c From Account 
                                    Where Name in :nameSet and (recordType.Name = 'EWI Agent' or recordType.Name = 'EWI Indepandent Landlord' or 
                                        recordType.Name = 'EWI_NonMemberLandlord' or recordType.Name = 'EWI_Tenant' or recordType.Name = 'EWI Member')];
            
            
            List<Account> unknownAcc = [Select Id, Name, G_Number__c From Account Where Name = 'Agent Unknown Red' limit 1];
            List<Case> caseRefList = [Select Id, Dispute_Reference__c, Status, Member_Status__c, Deposit_Account_Number__r.First_line_of_address_with_postcode__c, No_of_Times_Chased__c, Last_Chased_Date__c From Case
                                        Where Dispute_Reference__c IN :caseRefSet and recordtype.Name = 'Dispute EW Insured' ];

            for(Account acc : accList){
                if(!nameAndGNumberMap.containsKey(acc.Name)){
                    //nameAndGNumberMap.put(acc.Name, acc.G_Number__c!= null ? acc.G_Number__c : acc.EWI_Landlord_Id__c);
                    String gNumberForMap = '';
                    if(acc.G_Number__c!= null){
                        gNumberForMap = acc.G_Number__c;
                    }else if(acc.G_Number__pc!= null){
                        gNumberForMap = acc.G_Number__pc;
                    }else if(acc.EWI_Landlord_User_Id__c!= null){
                        //gNumberForMap = acc.EWI_Landlord_Id__c;
                        gNumberForMap = acc.EWI_Landlord_User_Id__c;
                    }
                    nameAndGNumberMap.put(acc.Name, gNumberForMap);
                    nameAndGNumberMap.put(gNumberForMap, gNumberForMap);
                    
                }
                /*else{
                    nameAndGNumberMap.put(acc.Name, unknownAcc[0].G_Number__c);
                }*/
            }
            for(string str : nameSet ){
                System.debug('str => ' + str);
                if(!nameAndGNumberMap.containsKey(str)){
                    nameAndGNumberMap.put(str, unknownAcc[0].G_Number__c);
                }
            }
            
            for(Case cs : caseRefList){
                nameAndCaseRefMap.put(cs.Dispute_Reference__c, cs);
            }

            List<inbReporDetailsWrapper> inbReportWrapperList = new List<inbReporDetailsWrapper>();
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
                
                // if(nameAndCaseRefMap.get(disputeRef) != null){
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
                        inbReporDetailsWrapper newwrap = new inbReporDetailsWrapper();
                        newwrap.inbReport= inbRep; 
                        newwrap.gNumber= nameAndGNumberMap.get(inbRep.Reference1__c);
                        newwrap.Dispute_Reference = nameAndCaseRefMap.get(disputeRef);
                        inbReportWrapperList.add(newwrap);
                //     }
                // }
            }

            // iterate over inbount reports 
            for (integer i=0; i<inbReportWrapperList.size(); i++) {
                // create reportColumnsWrapper element from installment record
                inbReporDetailsWrapper inbReportRec = inbReportWrapperList[i];
                reportColumnsWrapper reportCol = new reportColumnsWrapper();
                reportCol.dueDate = inbReportRec.inbReport.Collection_Date__c;
                reportCol.AGLLNumber = inbReportRec.gNumber;
                reportCol.AGLLName = inbReportRec.inbReport.Reference1__c!=null && inbReportRec.inbReport.Reference1__c!= ''
                                    ? inbReportRec.inbReport.Reference1__c : 'Unidentified Rec';
                reportCol.memberStatus = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Member_Status__c!=null
                                        ? inbReportRec.Dispute_Reference.Member_Status__c : '';
                reportCol.amountAfter30Days = inbReportRec.inbReport.Amount_Received_After_30_Days__c != null
                                                ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_After_30_Days__c.setScale(2))
                                                : '';
                reportCol.amountAfter20Days = inbReportRec.inbReport.Amount_Received_After_20_Days__c != null
                                                ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_After_20_Days__c.setScale(2))
                                                : '';
                reportCol.amountAfter10Days = inbReportRec.inbReport.Amount_Received_After_10_Days__c != null
                                                ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_After_10_Days__c.setScale(2))
                                                : '';
                reportCol.amountBefore10Days = inbReportRec.inbReport.Amount_Received_Before_10_Days__c != null
                                                ? '-'+string.valueOf(inbReportRec.inbReport.Amount_Received_Before_10_Days__c.setScale(2))
                                                : '';
                reportCol.balanceOutstanding = inbReportRec.inbReport.Amount__c!=null
                                                ? '-'+string.valueOf(inbReportRec.inbReport.Amount__c.setScale(2)) : '';
                reportCol.Type = 'Unallocated receipt';
                reportCol.caseStatus = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Status!=null
                                        ? inbReportRec.Dispute_Reference.Status : '';
                reportCol.caseDisputeRef = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Dispute_Reference__c!=null && inbReportRec.Dispute_Reference.Dispute_Reference__c!=''
                                            ? inbReportRec.Dispute_Reference.Dispute_Reference__c 
                                            : inbReportRec.inbReport.Reference2__c;
                reportCol.tenancyAddress = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Deposit_Account_Number__r!=null && inbReportRec.Dispute_Reference.Deposit_Account_Number__r.First_line_of_address_with_postcode__c!=null
                                            ? inbReportRec.Dispute_Reference.Deposit_Account_Number__r.First_line_of_address_with_postcode__c : '';
                reportCol.NoOfTimesChased = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.No_of_Times_Chased__c!=null && inbReportRec.Dispute_Reference.No_of_Times_Chased__c > 0
                                            ? inbReportRec.Dispute_Reference.No_of_Times_Chased__c
                                            : 0;
                reportCol.LastChasedDate = inbReportRec.Dispute_Reference.Last_Chased_Date__c;

                Boolean gNumberFlag = false;
                String G_Number = inbReportWrapperList[i].gNumber;
                for(integer a=0; a<allAgentsList.size(); a++){
                    if(allAgentsList[a].gNumber == G_Number){
                        
                        if(inbReportWrapperList[i].inbReport.Collection_Date__c > allAgentsList[a].lastTransDate){
                            allAgentsList[a].lastTransDate = inbReportWrapperList[i].inbReport.Collection_Date__c;
                        }
                        allAgentsList[a].balanceOutstanding -= inbReportWrapperList[i].inbReport.Amount__c!= null? inbReportWrapperList[i].inbReport.Amount__c:0;
                        allAgentsList[a].amountAfter10Days -= inbReportWrapperList[i].inbReport.Amount_Received_After_10_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_10_Days__c:0;
                        allAgentsList[a].amountAfter20Days -= inbReportWrapperList[i].inbReport.Amount_Received_After_20_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_20_Days__c:0;
                        allAgentsList[a].amountAfter30Days -= inbReportWrapperList[i].inbReport.Amount_Received_After_30_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_30_Days__c:0;
                        allAgentsList[a].amountBefore10Days -= inbReportWrapperList[i].inbReport.Amount_Received_Before_10_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_Before_10_Days__c:0;
                        
                        List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                        if(allAgentsList[a].reportColumnsWrapperList!=null){
                            reportColumnsWrapperList.addAll(allAgentsList[a].reportColumnsWrapperList);
                        }
                        
                        reportColumnsWrapperList.add(reportCol);
                        allAgentsList[a].reportColumnsWrapperList = reportColumnsWrapperList;
                        gNumberFlag = true;
                        break;
                    }
                }
                if(gNumberFlag == false){
                    List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                    reportColumnsWrapperList.add(reportCol); 
                    
                    PDFWrapper newpdfwrap = new PDFWrapper();
                    newpdfwrap.gNumber = G_Number; 
                    newpdfwrap.agllName = inbReportWrapperList[i].inbReport.Reference1__c;
                    newpdfwrap.lastTransDate = inbReportWrapperList[i].inbReport.Collection_Date__c;
                    newpdfwrap.balanceOutstanding = -(inbReportWrapperList[i].inbReport.Amount__c!= null? inbReportWrapperList[i].inbReport.Amount__c:0);
                    newpdfwrap.amountAfter10Days = -(inbReportWrapperList[i].inbReport.Amount_Received_After_10_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_10_Days__c:0);
                    newpdfwrap.amountAfter20Days = -(inbReportWrapperList[i].inbReport.Amount_Received_After_20_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_20_Days__c:0);
                    newpdfwrap.amountAfter30Days = -(inbReportWrapperList[i].inbReport.Amount_Received_After_30_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_30_Days__c:0);
                    newpdfwrap.amountBefore10Days = -(inbReportWrapperList[i].inbReport.Amount_Received_Before_10_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_Before_10_Days__c:0);
                    newpdfwrap.reportColumnsWrapperList = reportColumnsWrapperList;
                    newpdfwrap.isSelected = false;
                    allAgentsList.add(newpdfwrap);
                }
                
                grandTotalBalance -= inbReportWrapperList[i].inbReport.Amount__c!= null? inbReportWrapperList[i].inbReport.Amount__c:0;
                grandTotalAfter10Days -= inbReportWrapperList[i].inbReport.Amount_Received_After_10_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_10_Days__c:0;
                grandTotalAfter20Days -= inbReportWrapperList[i].inbReport.Amount_Received_After_20_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_20_Days__c:0;
                grandTotalAfter30Days -= inbReportWrapperList[i].inbReport.Amount_Received_After_30_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_After_30_Days__c:0;
                grandTotalBefore10Days -= inbReportWrapperList[i].inbReport.Amount_Received_Before_10_Days__c!=null? inbReportWrapperList[i].inbReport.Amount_Received_Before_10_Days__c:0;

            }
        }
        
        allAgentsList.sort();
        for(PDFWrapper pdfWrap : allAgentsList){
            pdfWrap.reportColumnsWrapperList.sort();
        }
        allAgentsListData = allAgentsList;
        String str = 'attachment; filename=Aged Debtor.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition',str);
    }
    
    public void downloadPDF(){
        string str = 'attachment; filename=Aged Debtor';
        Apexpages.currentPage().getHeaders().put('content-disposition',str);
    }

    @AuraEnabled (cacheable=true)
    public static doInitData getInstallments(){
        try{
            List<PDFWrapper> allAgentsList = new List<PDFWrapper>();
            List<reportColumnsWrapper> allReportColumnsWrapperList = new List<reportColumnsWrapper>();
            List<nameAndGnumberWrapper> nameAndGnumberList = new List<nameAndGnumberWrapper>();

            List<Installment__c> installmentList = [select Id, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Account__r.G_Number__c, Account__r.G_Number__pc, Account__r.EWI_Landlord_Id__c, Account__r.EWI_Landlord_User_Id__c,Case__c, Contact__r.Member_Status__c, Case__r.Member_Status__c,
                                                    Case__r.Evidence_Gathering_Start_Date__c, Case__r.status, Case__r.Deposit_Account_Number__r.First_line_of_address_with_postcode__c, Case__r.Dispute_Reference__c,
                                                    Case__r.Amount_of_Disputed_Funds_Remaining__c, Case__r.Amount_of_Disputed_Funds_Required__c, Case__r.Amount_of_Disputed_Funds_Received__c, Case__r.Evidence_Gathering_AGLL_DueDate__c,
                                                    Case__r.Amount_Received_After_30_Days__c, Case__r.Amount_Received_After_20_Days__c, Case__r.Amount_Received_After_10_Days__c, Case__r.Amount_Received_Before_10_Days__c,
                                                    Case__r.No_of_Times_Chased__c, Case__r.Last_Chased_Date__c, Case__r.Awaiting_review_Date__c,
                                                    (Select id, Amount__c, Collection_Date__c, Reference1__c,
                                                        Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                        from Inbound_Reports__r WHERE Amount__c>0 and Collection_Date__c<=Today 
                                                        and Reason_For_Unallocation__c != 'Refund to customer' 
                                                        and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc)
                                                    from Installment__c where Case__c != null and Account__c!=null 
                                                    and (Case__r.Status = 'Evidence gathering agent/landlord' OR
                                                    Case__r.Status = 'Evidence gathering tenant' OR
                                                    Case__r.Status = 'No response from agent/landlord' OR
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
                                                    and Case__r.Amount_of_Disputed_Funds_Remaining__c>0 and ((Case__r.Evidence_Gathering_Start_Date__c!=null AND Case__r.Evidence_Gathering_AGLL_DueDate__c <=today) OR Case__r.Awaiting_review_Date__c !=null )
                                                    and Installment_Type__c = 'Receivable' and Status__c = 'Pending'
                                                    and (Account__r.G_Number__c != null OR Account__r.G_Number__pc != null OR Account__r.EWI_Landlord_User_Id__c != null)
                                                    and case__r.recordtype.Name = 'Dispute EW Insured' 
                                                    order by Account__r.G_Number__c asc, Account__r.EWI_Landlord_User_Id__c asc, Case__r.Evidence_Gathering_AGLL_DueDate__c desc
            ]; //Case__r.Member_Status__c != '' and 
            
            if(installmentList.size() > 0){
                // create reportColumnsWrapper element from installment records
                for(Installment__c instRec : installmentList){
                    String agllNumber = '';
                    if(instRec.Account__r.G_Number__c!= null){
                        agllNumber = instRec.Account__r.G_Number__c;
                    }else if(instRec.Account__r.G_Number__pc!= null){
                        agllNumber = instRec.Account__r.G_Number__pc;
                    }else if(instRec.Account__r.EWI_Landlord_User_Id__c!= null){
                        //agllNumber = instRec.Account__r.EWI_Landlord_Id__c;
                        agllNumber = instRec.Account__r.EWI_Landlord_User_Id__c;
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
                        instRec.Case__r.Status == 'No response from agent/landlord' ||
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

                        reportCol.AGLLNumber = agllNumber;
                        reportCol.AGLLName = instRec.Account__r.Name;
                        reportCol.accRecordId = instRec.Account__r.Id;
                        reportCol.memberStatus = instRec.Case__r.Member_Status__c!=null? instRec.Case__r.Member_Status__c: '';
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
                        reportCol.NoOfTimesChased = instRec.Case__r.No_of_Times_Chased__c!=null && instRec.Case__r.No_of_Times_Chased__c > 0 
                                                    ? instRec.Case__r.No_of_Times_Chased__c 
                                                    : 0;
                        reportCol.LastChasedDate = instRec.Case__r.Last_Chased_Date__c;
                    
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
                                List<reportColumnsWrapper> reportColumnsWrapperList = allAgentsList[a].reportColumnsWrapperList;
                                reportColumnsWrapperList.add(reportCol);
                                allAgentsList[a].reportColumnsWrapperList = reportColumnsWrapperList;
                                gNumberFlag = true;
                                break;
                            }
                        }
                        if(gNumberFlag == false){
                            List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                            reportColumnsWrapperList.add(reportCol);
                            PDFWrapper newpdfwrap = new PDFWrapper();
                            newpdfwrap.gNumber= agllNumber;
                            newpdfwrap.agllName= instRec.Account__r.Name;
                            newpdfwrap.reportColumnsWrapperList = reportColumnsWrapperList;
                            allAgentsList.add(newpdfwrap);
                        }
                    }
                }
            }

            List<Inbound_Report__c> InboundReportsList = [Select id, Amount__c, Matched_Colour__c, Reference1__c, Reference2__c, Reference3__c, Reference4__c, Reference5__c, Collection_Date__c, 
                                                          Amount_Received_After_30_Days__c, Amount_Received_After_20_Days__c, Amount_Received_After_10_Days__c, Amount_Received_Before_10_Days__c
                                                          from Inbound_Report__c WHERE Amount__c>0 and Collection_Date__c<=Today
                                                          and Matched_Colour__c = 'Red' and recordType.name = 'EWI Inbound Report' 
                                                          and Reason_For_Unallocation__c != 'Refund to customer'
                                                          and (NOT Reference1__c like '%44576714%') order by Collection_Date__c desc];
           	
            Map<String, String> nameAndGNumberMap =	new Map<String, String>(); 
            Map<String, Account> nameAndAccountMap = new Map<String, Account>(); 
            Map<String, Case> nameAndCaseRefMap =	new Map<String, Case>(); 

            List<inbReporDetailsWrapper> inbReportWrapperList = new List<inbReporDetailsWrapper>();
            if(InboundReportsList.size() > 0){
                Set<String> nameSet = new Set<String>();
                Set<String> caseRefSet = new Set<String>();
                for(Inbound_Report__c inbrep : InboundReportsList){
                   // if(String.isNotBlank(inbrep.Reference1__c)){
                        nameSet.add(inbrep.Reference1__c);
                    //}
                    

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
                
                /*List<Account> accList = [Select Id, Name, G_Number__c, G_Number__pc, EWI_Landlord_Id__c From Account 
                                        Where Name in :nameSet and (recordType.Name = 'EWI_Agent' or recordType.Name = 'EWI_Indepandent_Landlord' or 
                                        recordType.Name = 'EWI_NonMemberLandlord' or recordType.Name = 'EWI_Tenant' or recordType.Name = 'EWI Member')];
                */
               
                List<Account> accList = [Select Id, Name, G_Number__c, G_Number__pc, EWI_Landlord_Id__c,EWI_Landlord_User_Id__c From Account 
                                        Where Name in :nameSet and (recordType.Name = 'EWI Agent' or recordType.Name = 'EWI Indepandent Landlord' or 
                                        recordType.Name = 'EWI_NonMemberLandlord' or recordType.Name = 'EWI_Tenant' or recordType.Name = 'EWI Member')];
                
                List<Account> unknownAcc = [Select Id, Name, G_Number__c From Account Where Name = 'Agent Unknown Red' limit 1];
                List<Case> caseRefList = [Select Id, Dispute_Reference__c, Status, Member_Status__c, Deposit_Account_Number__r.First_line_of_address_with_postcode__c, No_of_Times_Chased__c, Last_Chased_Date__c From Case
                                        Where Dispute_Reference__c IN :caseRefSet and recordtype.Name = 'Dispute EW Insured' ];

                for(Account acc : accList){
                    if(!nameAndGNumberMap.containsKey(acc.Name)){
                        
                        String gNumberForMap = '';
                        if(acc.G_Number__c!= null){
                            gNumberForMap = acc.G_Number__c;
                        }else if(acc.G_Number__pc!= null){
                            gNumberForMap = acc.G_Number__pc;
                        }else if(acc.EWI_Landlord_User_Id__c!= null){
                            //gNumberForMap = acc.EWI_Landlord_Id__c;
                            gNumberForMap = acc.EWI_Landlord_User_Id__c;
                        }
                        nameAndGNumberMap.put(acc.Name, gNumberForMap);
                        nameAndGNumberMap.put(gNumberForMap, gNumberForMap);
                        nameAndAccountMap.put(acc.Name, acc); 
                        
                        
                    }
                    /*else{
                        nameAndGNumberMap.put(acc.Name, unknownAcc[0].G_Number__c);
                    }*/
                }
                for(string str : nameSet ){
                    if(!nameAndGNumberMap.containsKey(str)){
                        nameAndGNumberMap.put(str, unknownAcc[0].G_Number__c);
                        nameAndAccountMap.put(str, unknownAcc[0]);
                    }
                }
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

                    // if(nameAndCaseRefMap.get(disputeRef) != null){
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
                            inbReporDetailsWrapper newwrap = new inbReporDetailsWrapper();
                            newwrap.inbReport= inbRep; 
                            newwrap.gNumber= nameAndGNumberMap.get(inbRep.Reference1__c);
                            newwrap.Dispute_Reference = nameAndCaseRefMap.get(disputeRef);
                            inbReportWrapperList.add(newwrap);
                    //     }
                    // }
                }

                // create reportColumnsWrapper element from Inbound Reports records
                for(inbReporDetailsWrapper inbReportRec : inbReportWrapperList){
                    reportColumnsWrapper reportCol = new reportColumnsWrapper();
                    reportCol.dueDate = inbReportRec.inbReport.Collection_Date__c;
                    reportCol.AGLLNumber = inbReportRec.gNumber;
                    reportCol.AGLLName = inbReportRec.inbReport.Reference1__c!=null && inbReportRec.inbReport.Reference1__c!= ''
                                        ? inbReportRec.inbReport.Reference1__c : 'Unidentified Rec';
                    //if(String.isNotBlank(inbReportRec.inbReport.Reference1__c)){
                        reportCol.accRecordId = nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c) !=null
                        ?nameAndAccountMap.get(inbReportRec.inbReport.Reference1__c).Id : '';
                    //}
                    
                    reportCol.memberStatus = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.Member_Status__c!=null
                                            ? inbReportRec.Dispute_Reference.Member_Status__c : '';
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
                    reportCol.NoOfTimesChased = inbReportRec.Dispute_Reference!=null && inbReportRec.Dispute_Reference.No_of_Times_Chased__c!=null && inbReportRec.Dispute_Reference.No_of_Times_Chased__c > 0
                                                ? inbReportRec.Dispute_Reference.No_of_Times_Chased__c
                                                : 0;
                    reportCol.LastChasedDate = inbReportRec.Dispute_Reference.Last_Chased_Date__c;

                    //add inbound report to allAgent's ReportColumnWrapperList
                    Boolean gNumberFlag = false;
                    for(integer a=0; a<allAgentsList.size(); a++){
                        if(allAgentsList[a].gNumber == inbReportRec.gNumber)
                        {
                            List<reportColumnsWrapper> reportColumnsWrapperList = allAgentsList[a].reportColumnsWrapperList;
                            reportColumnsWrapperList.add(reportCol);
                            allAgentsList[a].reportColumnsWrapperList = reportColumnsWrapperList;
                            gNumberFlag = true;
                            break;
                        }
                    }
                    if(gNumberFlag == false){
                        List<reportColumnsWrapper> reportColumnsWrapperList = new List<reportColumnsWrapper>();
                        reportColumnsWrapperList.add(reportCol);
                        PDFWrapper newpdfwrap = new PDFWrapper();
                        newpdfwrap.gNumber= inbReportRec.gNumber;
                        newpdfwrap.agllName= inbReportRec.inbReport.Reference1__c;
                        newpdfwrap.reportColumnsWrapperList = reportColumnsWrapperList;
                        allAgentsList.add(newpdfwrap);
                    }
                }
            }

            allAgentsList.sort();
            for(PDFWrapper pdfWrap : allAgentsList){
                pdfWrap.reportColumnsWrapperList.sort();
                allReportColumnsWrapperList.addAll(pdfWrap.reportColumnsWrapperList);
            }

            if(nameAndGnumberList.size()>0 && allReportColumnsWrapperList.size()>0){
                doInitData dd = new doInitData();
                dd.nameAndGnumber = nameAndGnumberList;
                dd.reportColumnsWrapperList = allReportColumnsWrapperList;
                return dd;
            }else{
                return null;
            }
        }catch(exception e){
            System.debug('ERROR => ' + e.getMessage()+' at Line => ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' at Line => ' + e.getLineNumber());
        }
    }
     
    public class doInitData{
        @AuraEnabled public List<Installment__c> instList;
        @AuraEnabled public List<Inbound_Report__c> InboundReportsList;
        @AuraEnabled public List<nameAndGnumberWrapper> nameAndGnumber;
        @AuraEnabled public List<inbReporDetailsWrapper> inbReportAndCaseWrapperList;
        @AuraEnabled public List<reportColumnsWrapper> reportColumnsWrapperList;
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
        public String gNumber {get;set;}
        public String agllName {get;set;}
        public Date lastTransDate {get;set;}
        public Decimal balanceOutstanding {get;set;}
        public Decimal amountAfter10Days {get;set;}
        public Decimal amountAfter20Days {get;set;}
        public Decimal amountAfter30Days {get;set;}
        public Decimal amountBefore10Days {get;set;}
        public List<Installment__c> instListofGNumber {get;set;}
        public List<Inbound_Report__c> inbReportListofGNumber {get;set;}
        public List<inbReporDetailsWrapper> inbReportWrapperListofGNumber {get;set;}
        public List<reportColumnsWrapper> reportColumnsWrapperList {get; set;}
        public Boolean isSelected {get;set;}

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
        @AuraEnabled public String AGLLNumber {get;set;}
        @AuraEnabled public String AGLLName {get;set;}
        @AuraEnabled public String accRecordId {get; set;}
        @AuraEnabled public String memberStatus {get;set;}
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
}