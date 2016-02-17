/* version: 1.0
   class : for DataScrambling
   
 */

public with sharing class DataScramblingController {

    public String appSelected { get; set; }
    public list < SelectOption > accountRecordType { get; set; }
    public String[] selectedAccRec { get; set ; }
    public list < SelectOption > CaseRecordType { get; set; }
    public String[] selectedCaseRec { get; set ; }
    public String extraVantageAccount{get;set;}
    public String extraVantageAddress{get;set;}
    public String emailid{get;set;}
    public String obj { get; set; }
    private String objAPI ;
    public Boolean isSandboxinstance{ get; set; }
    public Boolean authorizeSection{ get; set; }
    public Boolean enterEmail{ get; set; }
    public Boolean enterOTP{ get; set; }
    public Boolean objSection{ get; set; }
    public Boolean selectValues{ get; set; }
    public Boolean lastSection{ get; set; }
    public Boolean submitMsg{ get; set; }
    public Boolean nextbtn{ get; set; }
    public Boolean selectfieldsbtn{ get; set; }
    public Boolean submitbtn{ get; set; }
    private String passcode;
    public String userCode{ get; set; }
    public List<SelectOption> objoptions {get;set;}
    private Set<String> originalvalues = new Set<String>();
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    private Set<string> leftvalues = new Set<string>();
    private Set<string> rightvalues = new Set<string>();
    Map<String,String> objFieldMap {get;set;}
    private List<string> selectedobject = new List<String>();
    List<String> objectList {get;set;}
    private Integer i =0 ;
    private static final String PROD_ERROR ='You are not allowed to use Data Scrambling Tool in Production';
    private static final String ACCESS_DENIED ='Access Denied!!! Only Indentified Active Novartis IT Support personals are allowed to access this tool, Please contact application manager to get required access.';
    private static final String ACCESS_DENIED_OTP ='Access Denied!!! OTP in Incorrect.';
    private static final String OBJ_SEL_ERROR ='Select atleast One object or click close button';
    private static final String CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    /* constructor defined */
    public DataScramblingController(){
        leftselected = new List<String>();
        rightselected = new List<String>();
        objFieldMap = new Map<String,String>();
        objectList = new List<String>();
        isSandboxinstance = runningInASandbox();
        authorizeSection = true;
        enterEmail = true;
        enterOTP = false;
        objSection = false;
        selectValues = false;
        lastSection = false;
        nextbtn = true;
        selectfieldsbtn = false;
        submitbtn = false;
        submitMsg = false;
        if(!(isSandboxinstance)){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, PROD_ERROR));
                authorizeSection = false;
                nextbtn = false;  
        }
    }
    
    /* method for multiselect picklist  */
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    /* checking sandbox Instance */
    public static Boolean runningInASandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    /* method for unselect multipicklist */
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
    /* method for unselected values */
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
    
    /* method for selected values */
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList){
            options1.add(new SelectOption(s,s));
        }
        return options1;
    }
    
    /* method for random String generator */
    public static String generateRandomString(Integer len) {
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), CHARS.length());
            randStr += CHARS.substring(idx, idx+1);
        }
        return randStr;
    }
    
    /* method for next button */
    public void onNext() {
        if(string.isNotBlank(emailId) && enterEmail){
            sendEmail();
        }
        else if(string.isNotBlank(usercode) && enterOTP ){
            if(usercode == passcode){
                List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
                for(Schema.SObjectType f : gd)
                {
                    if (f.getDescribe().isQueryable() && f.getDescribe().isUpdateable() && (!(f.getDescribe().isCustomSetting())) && (!(f.getDescribe().getName().endsWith('__Share')))) {
                    String s = f.getDescribe().getName();
                        objectList.add(s);
                    }
                    leftvalues.clear();
                    leftvalues.addAll(objectList);
                    enterOTP = false;
                    authorizeSection = false;
                    objSection = true;
                    selectValues = true;
                }   
            }
            else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, ACCESS_DENIED_OTP));
                authorizeSection = false;
                nextbtn = false;
            }
        }
        else{
            if(rightvalues.size()>0){
            selectedobject.addAll(rightvalues);
            rightvalues.clear();
            nextObjFieldSelection();
            nextbtn = false;
            selectfieldsbtn = true;
            }else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, OBJ_SEL_ERROR));
            }

        }
    }
    
    /* method for Sending Email */
    public void sendEmail()
    {
        if(emailId.endsWithIgnoreCase('@novartis.com') && system.label.Data_Scramble_Tool_Allowed_User.contains(emailId)){
            passcode = generateRandomString(8);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String subject = 'Your One time password for using Data Scramble Tool';
            String body = 'Your One time password for using Data Scramble Tool: ' +passcode;
            List<String> toAddresses = new list<String>();
            List<String> ccAddresses = new list<String>();
            toAddresses.add(emailId);
            email.setSubject( subject );
            email.setToAddresses( toAddresses );
            email.setCcAddresses( ccAddresses );
            email.setHtmlBody( body );
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            enterEmail = false;
            enterOTP = true;
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, ACCESS_DENIED));
            authorizeSection= false;
            nextbtn = false;
        }
    }
    
    
    /* method for next objectField selection */
    Public void nextObjFieldSelection(){
        List<string> s1 = new List<String>();
        s1.addAll(rightvalues);
        rightvalues.clear();
        String rightselectedvalues= String.join(s1, ', ');
        if(String.isNotBlank(objAPI)){
            objFieldMap.put(objAPI, rightselectedvalues);
        }
        Map<String, Schema.SObjectField> originalValues = new Map<String, Schema.SObjectField> ();
            if(i < selectedobject.size()){
                originalValues = Schema.getGlobalDescribe().get(selectedobject[i]).getDescribe().fields.getMap();

                leftvalues.clear();
                for(String str:originalValues.keyset())
                {
                    if(Schema.getGlobalDescribe().get(selectedobject[i]).getDescribe().fields.getMap().get(str).getDescribe().isUpdateable() &&
                        Schema.getGlobalDescribe().get(selectedobject[i]).getDescribe().fields.getMap().get(str).getDescribe().isCustom())
                    {
                        if(!(System.Label.Data_Scramble_Tool_Allowed_Fields.contains(Schema.getGlobalDescribe().get(selectedobject[i]).getDescribe().fields.getMap().get(str).getDescribe().getType().name()))){
                        leftvalues.add(Schema.getGlobalDescribe().get(selectedobject[i]).getDescribe().fields.getMap().get(str).getDescribe().getType().name() +' : '+str); 
                        }
                    }   
                }
                obj = Schema.getGlobalDescribe().get(selectedobject[i]).getDescribe().getLabel();
                objAPI = selectedobject[i];
                i++; 
            } 
            else{
                selectfieldsbtn = false;
                objSection = false;
                selectValues = false;
                submitbtn = true;
                lastSection = true;
            }  
    }
    
    /* method for submitting to batch class */
    public void onSubmit() {
    selectfieldsbtn = false;
    submitMsg = true;
    lastSection = false;
    submitbtn = false;
        String query = '';
        for(String sObj : objFieldMap.keySet()){
            String sObjfields = objFieldMap.get(sObj);
            List<String> originalString = sObjfields.split(',');
            
            if (String.isNotBlank(sObjfields)){
                List<String> newList = new List<String>();
                for(String strs:originalString) 
                {
                    String[] temp = strs.split(' : ');
                    newList.add(temp[1]);
                }
                String sfields = String.join(newList, ', ');
                query = 'Select ID,' + sfields + ' From ' +sObj;
            }
            List<string> fieldsList = (((query.removeStartIgnoreCase('Select ')).removeEndIgnoreCase('From ' +sObj)).trim()).split(',');
            DataScrambleBatch a = new DataScrambleBatch(query,fieldsList);
            database.executebatch(a);
        }
    }   
}