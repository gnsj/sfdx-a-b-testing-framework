trigger CaseTrigger on Case (after update) {
    
    private static Boolean isRecursion = false;

    if(Trigger.isUpdate && Trigger.isAfter && !isRecursion){

        List<Case> closedCases = new List<Case>();
        for(Case c : Trigger.New){
            if(Trigger.newMap.get(c.Id).Status != Trigger.oldMap.get(c.Id).Status 
               &&  Trigger.newMap.get(c.Id).Status == 'Closed'){
                isRecursion = true;
                closedCases.add(c);
            }
        }
        surveyCasesCandidates(closedCases);
        
    }
    
  	//note
    private static void surveyCasesCandidates(List<Case> cases){
        //getting AB testing config
		AB_Testing_Configuration__mdt abTestingConfiguration = [SELECT MasterLabel, QualifiedApiName, Variant_Distribution__c  FROM AB_Testing_Configuration__mdt WHERE QualifiedApiName = 'AB_Testing_Case_E_mail_Survey' LIMIT 1];
        
        //checking if AB testing configuration is valid
        if(abTestingConfiguration != NULL && abTestingConfiguration.Variant_Distribution__c != 100 && abTestingConfiguration.Variant_Distribution__c != 0){
            
            List<Case> surveyCases = new List<Case>();
            //getting selected cases
            for(Case c : cases){
                Integer seed = Integer.valueOf(Math.floor(Math.random() * 101));
                if(seed <= abTestingConfiguration.Variant_Distribution__c){
                    surveyCases.add(c);
                }
            }
            
            if(surveyCases.size() > 0)
            	sendSurvey(surveyCases);
        }
    }
    
    //note
    private static void sendSurvey(List<Case> cases){ 
        List<Case> casesToUpdate = new List<Case>();
        for(Case c : cases){
            Case uCase = new Case();
            uCase.Subject = 'Case Survey has been sent';
            uCase.Id = c.Id;
            casesToUpdate.add(uCase);
        }
        update casesToUpdate;
    }

}