@isTest
private class PlanScoreTest {
    @isTest
    static void instanceTest() {
        PlanScore result = new PlanScore('planName');

        System.assertEquals('planName', result.name);
        System.assertEquals(0, result.scores.size());
    }
}