@isTest
private class CaseTrigger_TEST {
    
    public static decimal NUMCASES = 500;
    
    @isTest
    private static void sendSurveyBulkTest(){
        List<Case> testCases = new List<Case>();
        //creating new tests cases
        //for probabilities tests more number of records better.... 
        for(Integer i=0;i<NUMCASES;i++){
            Case c = new Case();
            c.Subject = 'Test Case';
            testCases.add(c);
        }        
        insert testCases;
        
        //updating cases to 'close' status and then fire the trigger
        Test.startTest();
            for(Case c : testCases){
                c.Status = 'Closed';
            }
            update testCases;
        Test.stopTest();
        
        //getting the total of cases where suvery has been sent
        decimal totalSurvey = [SELECT Id FROM Case WHERE Subject ='Case Survey has been sent'].size();
        
        //getting the total distribution set in custom metadata
        decimal totalDistribution = Integer.valueOf([SELECT Variant_Distribution__c  FROM AB_Testing_Configuration__mdt WHERE QualifiedApiName = 'AB_Testing_Case_E_mail_Survey' LIMIT 1].Variant_Distribution__c);

    }

}