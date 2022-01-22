@isTest
private with sharing class KProjectDebuggingTest {
    @isTest
    static void debugging(){
        insert debugging;

        Map<String, Integer> testMap = new Map<String, Integer>{ 'test' => 1};
        Test.startTest();
            KProjectDebugging.printDebug('test: ', testMap);
        Test.stopTest();
    }   

    @isTest
    static void debuggingCatchException(){        
        Map<String, Integer> testMap = new Map<String, Integer>{ 'test' => 1};
        Test.startTest();
            KProjectDebugging.printDebug('test: ', String.valueOf(testMap));
        Test.stopTest();
    }   

    static Settings_K_Project__c debugging;
    static{
        debugging =            
            new Settings_K_Project__c(
                Name = 'Debugging',
                Value__c = 'true'
        );
    }
}
