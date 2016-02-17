/* Batch class for DataScramble */
global class DataScrambleBatch implements Database.Batchable<sObject>{
    private String query;
    private List<String> fieldsList = new List<String>();
    private static final String PHONE_NO ='9876543219';
    private static final String STAT_EMAIL ='example@novartis.com';
    
    /* constructor defined */
    global DataScrambleBatch(String query, List <String> fieldsList){
        this.query = query;
        this.fieldsList = fieldsList;
    }
   
    /* Start Method */
    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr = query;
        return Database.getQueryLocator(queryStr);
    }
    
    /* execute batch logic */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> accUppate = new List<sObject>();
        for(sObject a: scope){
            for(String fieldAPI: fieldsList){
                fieldAPI=fieldAPI.trim();
                String sObjectName = (query.substringAfter('From ')).trim();
                String fieldldType = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldAPI).getDescribe().getType().name();
                if(String.isNotBlank((String.valueOf(a.get(fieldAPI))))){   
                    if(fieldldType.equalsIgnoreCase('Phone')){ 
                        a.put(fieldAPI,PHONE_NO);
                    }else if(fieldldType.equalsIgnoreCase('Email')){
                        a.put(fieldAPI, STAT_EMAIL );
                    }
                    else{
                        if(!(fieldldType.equalsIgnoreCase('ID'))){
                        a.put(fieldAPI,ScrambleData.scrambleText(String.valueof(a.get(fieldAPI))));
                        }
                    }
                }
            }
            accUppate.add(a);
        }
        
        if(accUppate.size() > 0)
        {
        	Database.update(accUppate);
        }
    }
    
    /* finish method */   
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        String subject = 'Account First Name Scrambling';
        String body = 'Account First Name Scrambling complete';
        List<String> toAddresses = new list<String>();
        List<String> ccAddresses = new list<String>();
        ToAddresses.add('vasanth.krishnamoorthi@novartis.com');
        email.setSubject( subject );
        email.setToAddresses( toAddresses );
        email.setCcAddresses( ccAddresses );
        email.setHtmlBody( body );
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    }
    
}