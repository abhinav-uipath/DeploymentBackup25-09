import { LightningElement, track, wire } from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import getCaseParticipantDetails from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.getCaseParticipantDetails";
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import updateCaseRespondbyAGLL from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.updateCaseRespondbyAGLL";
import updateCaseAgreedbyAGLL from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.updateCaseAgreedbyAGLL";
import EWIVPlus_Link from '@salesforce/label/c.EWIVPlus_Link';

export default class EI_EWI_DepositAllocationRespondByAgentLL extends NavigationMixin(LightningElement) {
    ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';
    pound_icon = EWITheme + '/assets/img/pound_icon.png';
    home_icon = EWITheme + '/assets/img/home_icon.png';
    circle_checked_icon = EWITheme + '/assets/img/circle_checked_icon.png';

    @track caseDetails;
    @track caseParticipantDetails;
    @track accessCode;
    @track formattedEndDate;
    @track depositAmount;
    @track isDepoAllocProposal = false;
    @track isShowThankyouPage = false;
    @track depositAmountReceived = 0.00;
    @track depositAmountClaimed = 0.00;
    @track otherName = '';
    @track claimedItems = [];
    @track summaryDisputeItems = [];
    @track isAmountReceivedYES = false;
    @track isAmountReceivedNO = false;
    @track showIfRecieved0 = false;
    @track showIfRecievedFullAmount = false;
    @track isProposalSummarySubmit = false;
    @track isDepositSummaryReview = false;
    @track showIfClaimedMoreAmount = false;
    //@track isDisbaleNObtn = false;
    @track isDisbaleYESbtn = false;
    @track isOtherNameRequired = false;
    @track isOtherNameLimitExceed = false;
    @track showDetails=true;
    @track disablesubmit=false;
    get isOtherClaimEntered(){
        if(this.claimedItems[5].value > 0 )
            return true;
        return false;
    }

    // get otherNameRequired(){
    //     if(this.otherName == '') 
    //         return true;
    //     return false;
    // }

    connectedCallback(){
    // @wire(CurrentPageReference)
    // getpageRef(pageRef) {
        // console.log('data => ', JSON.stringify(pageRef));
        // console.log("pageReference state => " + JSON.stringify(pageRef.state));
        // console.log("pageReference state Id => " + pageRef.state.id);
        // let recId = pageRef.state.id;
        // let location = window.location.href;
        // console.log('location => ' + location);

      setTimeout(() => { window.history.forward();  }, 0);

        const queryString = window.location.search;
        console.log('queryString => ' + queryString);
        const urlParams = new URLSearchParams(queryString);
        console.log('urlParams => ' + urlParams);
        const caseId = urlParams.get('caseId');
        console.log('caseId => ' + caseId);
        const accessCode = urlParams.get('accessCode');
        this.accessCode = accessCode;
        if(accessCode == '' || accessCode == null){
            this.showDetails = false;
            return;
          }
        console.log('accessCode => ' + accessCode);

        getCaseParticipantDetails({accessCode : this.accessCode}).then(result1 => {
            if(result1==null){
                this.showDetails=false;
                return;
              }
              this.showDetails=true;
            console.log("getCaseParticipantDetails success result 1: ", result1);
            this.caseParticipantDetails = result1;
            this.caseDetails = result1.Case__r;
            this.depositAmount = (result1.Case__r.Deposit_Account_Number__r.Deposit_Amount__c).toFixed(2);
            this.isDepoAllocProposal = true;
            
            var endDate = new Date( this.caseDetails.Deposit_Account_Number__r.End_Date__c);
            if(isNaN(endDate)){
                this.dateValue='';
            } 
            else if(endDate!= null || endDate!= undefined|| endDate!= ''){
                var checkdate = endDate.getDate().toString().padStart(2, "0");;
                var checkmonth = (endDate.getMonth()+1).toString().padStart(2, "0");
                var checkyear = endDate.getFullYear();
                var newDate = checkdate +'/'+ checkmonth+'/'+checkyear;
                this.formattedEndDate = newDate;
                console.log('endDate => '+ endDate );
                console.log('formattedEndDate => '+this.formattedEndDate);     
                console.log('depositAmount => '+this.depositAmount); 
            } 
        }).catch(error => {
            console.log("getCaseParticipantDetails error 1: ", error);
        });

    this.claimedItems.push({value:0, key:'Cleaning'});
    this.claimedItems.push({value:0, key:'Damage'});
    this.claimedItems.push({value:0, key:'Redecoration'});
    this.claimedItems.push({value:0, key:'Gardening'});
    this.claimedItems.push({value:0, key:'Rent arrears'});
    this.claimedItems.push({value:0, key:'Other'});
    }

    restrictDecimal(event) {  
        var t = event.target.value;
        return (t.indexOf(".") >= 0) ? (t.substr(0, t.indexOf(".")) + t.substr(t.indexOf("."), 3)) : t
        
        // if(t.includes(".")){
        //     var arr = t.split(".");
        //     var lastVal = arr.pop();
        //     var arr2 = lastVal.split('');
        //     if (arr2.length > '1') {
        //         event.preventDefault();
        //     }
        // }
    }

    removeZero(event) {
        // alert('remove zero');
        var edValue = event.target.value;
        
        function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>=1 && !s.includes(".")) { 
                s = s.substring(1,9999); 
            }
            return s;
        }
        // alert('remove zero 1');
        var trimeVal = trimNumber(edValue);
        event.target.value = trimeVal;
        // alert('remove zero 3');
        
        if(trimeVal.includes('.')){
            // alert('remove zero 4');
            var number = trimeVal.split('.');
            console.log('numbs '+number[1]);
            if(number[1].length>2)
            event.target.value = parseFloat(trimeVal).toFixed(2);
        }else{
            // alert('remove zero 5');
            event.target.value = trimeVal;
        }
    }

    restrictNegativeVal(event){
        if(event.target.value < 0){
            event.target.value = 0;
        }
    }

    handleGoBack(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            },
            state:{
                accessCode: this.accessCode
            }
        });
    }

    handleDepositAmountReceivedChange(event){
        let val = this.restrictDecimal(event);
        event.target.value = val;
        this.depositAmountReceived = (event.target.value);
    }

    handleAmountReceivedYES(){
        this.isAmountReceivedYES = true;
        this.isAmountReceivedNO = false;
        this.template.querySelector('.amt-recv-yes-btn').classList.add('bg-color-blue'); 
        this.template.querySelector('.amt-recv-no-btn').classList.remove('bg-color-blue');
    }

    handleAmountReceivedNO(){
        this.depositAmountReceived = 0.00;
        this.depositAmountClaimed = 0.00;
        this.isAmountReceivedNO = true;
        this.isAmountReceivedYES = false;
        for(let ind in this.claimedItems ){
            this.claimedItems[ind].value = 0.00;
        }
        this.otherName = '';
        this.template.querySelector('.amt-recv-no-btn').classList.add('bg-color-blue'); 
        this.template.querySelector('.amt-recv-yes-btn').classList.remove('bg-color-blue');
    }
    handleSubmit(event){
        this.disablesubmit = true;
        event.preventDefault();
        updateCaseAgreedbyAGLL({caseId: this.caseDetails.Id, 
            agreedAmount: this.depositAmountClaimed,
            depositAmount: this.depositAmount}).then(result => {
            console.log("updateCaseAgreedbyAGLL result => " + result);
            this.isShowThankyouPage = true;
            let makededuction = '';
            if(this.isAmountReceivedYES){
                makededuction = 'Yes';
            }else if(this.isAmountReceivedNO){
                makededuction = 'No';
            }
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'ewithankyou'
                },
                state:{
                    accessCode: this.accessCode,
                    thanksfor: 'respondedbyagll',
                    makededuction: makededuction
                }
            });
            this.isDepoAllocProposal = false;
            this.isDepositSummaryReview = false;
        }).catch(error => {
            console.log("updateCaseAgreedbyAGLL error => ", error);
        });
    }
    handleDepositSummaryReview(){
        window.location.href =  EWIVPlus_Link+this.accessCode;
        
        // let currentURL = window.location.href;
        // console.log('currentURL => ' + currentURL);
        // let homeURL = currentURL.split('/ewinsured/s');
        // console.log('homeURL => ' + homeURL);
        // let redirectToURL = homeURL[0]+'/ewinsured/s/?accessCode='+this.accessCode;
        // console.log('redirectToURL => ' + redirectToURL);
        // window.location.href = redirectToURL; //"https://espdev2-thedisputeservice.cs80.force.com/ewinsured/s/?accessCode="+this.accessCode;

    }
    handleCalculateClaimAmount(event){
        let val = this.restrictDecimal(event);
        event.target.value = val;

        let index = event.target.title;
        let claimItemValue = event.target.value;
        this.claimedItems[index].value = claimItemValue;
        
        this.depositAmountClaimed = 0;
        
        for(let ind in this.claimedItems ){
            console.log(" on change claimedItem => " + this.claimedItems[ind].value);
            if(this.claimedItems[ind].value > 0){
                this.depositAmountClaimed = (parseFloat(this.depositAmountClaimed) + parseFloat(this.claimedItems[ind].value)).toFixed(2);
            }
        }
        console.log("this.depositAmountClaimed => " + this.depositAmountClaimed);
        this.isOtherNameRequired = false;
    }

    handleOtherName(event){
        var othertext = event.target.value;
        if(othertext.length > 300){
            event.target.value = othertext.substring(0, 300);
            this.otherName = othertext.substring(0, 300);
            this.isOtherNameLimitExceed = true;
        }else{
            this.otherName = othertext;
            this.isOtherNameLimitExceed = false;
        }
    }

    handleClaimContinue(event){
        if(this.depositAmountReceived > 0){
            this.depositAmountReceived = (parseFloat(this.depositAmountReceived)).toFixed(2);
        }else{
            this.depositAmountReceived = (parseFloat(0.00)).toFixed(2);
        }
        if(this.depositAmountClaimed > 0){
            this.depositAmountClaimed = (parseFloat(this.depositAmountClaimed)).toFixed(2);
        }else{
            this.depositAmountClaimed = (parseFloat(0.00)).toFixed(2);
        }
        this.summaryDisputeItems=[];
        console.log("handleClaimContinue => " + this.claimedItems);
        for(let ind in this.claimedItems ){
            console.log('claimedItems['+ind+'].value => ' + this.claimedItems[ind].value);
            if( this.claimedItems[ind].value > 0){
                this.summaryDisputeItems.push({value:(parseFloat(this.claimedItems[ind].value)).toFixed(2), key:this.claimedItems[ind].key});
            }
        }

        let isValid = true;
        
        if((( parseFloat(this.depositAmountClaimed) + parseFloat(this.depositAmountReceived) ).toFixed(2)) != (parseFloat(this.caseDetails.Deposit_Account_Number__r.Deposit_Amount__c).toFixed(2))){
            this.showIfClaimedMoreAmount = true;
            isValid = false;
        }else{
            this.showIfClaimedMoreAmount = false;
        }
        if(this.isOtherClaimEntered && this.otherName == ''){
            this.isOtherNameRequired = true;
            isValid = false;
        }else{
            this.isOtherNameRequired = false;
        }
        // if(this.isOtherNameLimitExceed){
        //     isValid = false;
        // }
        
        if(isValid){
            this.showIfClaimedMoreAmount = false;
            this.isOtherNameRequired = false;
            this.isOtherNameLimitExceed = false;
            this.isDepoAllocProposal = false;
            this.isDepositSummaryReview = true;
        }
    }
    handleSummaryReviewGoBack(event){
        this.isDepoAllocProposal = true;
        this.isDepositSummaryReview = false;

        setTimeout(() => {
            //alert("this.template.querySelector('.amt-recv-yes-btn') => " + this.template.querySelector('.amt-recv-yes-btn'))
            this.template.querySelector('.amt-recv-yes-btn').classList.add('bg-color-blue'); 
            this.template.querySelector('.amt-recv-no-btn').classList.remove('bg-color-blue');
        }, 100);      
    }
    handleSubmitProposal(){
        console.log("this.claimedItems => " + JSON.stringify(this.claimedItems));
        this.isDisbaleYESbtn = true;
        this.template.querySelector('.submit-btn').classList.remove('bg-color-blue');
        this.template.querySelector('.submit-btn').classList.add('disable_ew_btn');

        var objectofMap = {};
        for(let ind in this.claimedItems){
            if(this.claimedItems[ind].value > 0){
                objectofMap[this.claimedItems[ind].key] = this.claimedItems[ind].value;
            }
            console.log("key => " + this.claimedItems[ind].key);
            console.log("value => " + this.claimedItems[ind].value);
            console.log("objectofMap => " + JSON.stringify(objectofMap));
        }
        var objectofMapstr = JSON.stringify(objectofMap);

        updateCaseRespondbyAGLL({caseId: this.caseDetails.Id, amountToTenant: this.depositAmountReceived, initiatedBy: this.caseParticipantDetails.Type__c, 
            caseParId: this.caseParticipantDetails.Id,
            claimedItems: objectofMapstr, otherReason: this.otherName }).then(result => {
            console.log("updateCaseRespondbyAGLL result => " + result);
            if(result == 'Agll Responded'){
                this.handleDepositSummaryReview();
            }else if(result == 'Successfully updated'){
                this.isShowThankyouPage = true;
                let makededuction = '';
                if(this.isAmountReceivedYES){
                    makededuction = 'Yes';
                }else if(this.isAmountReceivedNO){
                    makededuction = 'No';
                }
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'ewithankyou'
                    },
                    state:{
                        accessCode: this.accessCode,
                        thanksfor: 'respondedbyagll',
                        makededuction: makededuction
                    }
                });
                this.isDepoAllocProposal = false;
                this.isDepositSummaryReview = false;
            }
        }).catch(error => {
            console.log("updateCaseRespondbyAGLL error => ", error);
        });
    }

}