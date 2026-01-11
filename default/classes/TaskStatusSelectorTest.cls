@isTest
private class TaskStatusSelectorTest {
    @isTest
    static void selectTasksStatusForClosedReturnsExpectedStatuses() {
        // Given
        List<TaskStatus> closedStatuses = [SELECT ApiName FROM TaskStatus WHERE IsClosed = TRUE];

        // When
        Test.startTest();

        List<TaskStatus> result = TaskStatusSelector.newInstance().selectTasksStatusForClosed();

        Test.stopTest();

        // Then
        System.assertEquals(closedStatuses.size(), result.size());
    }

    @isTest
    static void selectTasksStatusForOpenReturnsExpectedStatuses() {
        // Given
        List<TaskStatus> openStatuses = [SELECT ApiName FROM TaskStatus WHERE IsClosed = FALSE];

        // When
        Test.startTest();

        List<TaskStatus> result = TaskStatusSelector.newInstance().selectTasksStatusForOpen();

        Test.stopTest();

        // Then
        System.assertEquals(openStatuses.size(), result.size());
    }

    @isTest
    static void taskStatusSelectorReturnsCorrectOrder() {
        // Given

        // When
        Test.startTest();
        List<TaskStatus> closedResults = TaskStatusSelector.newInstance().selectTasksStatusForClosed();
        List<TaskStatus> openResults = TaskStatusSelector.newInstance().selectTasksStatusForOpen();

        // Then
        if (closedResults.size() > 0) {
            Integer previousOrder = closedResults[0].SortOrder;
            for (TaskStatus status : closedResults) {
                System.assertEquals(previousOrder <= status.SortOrder, true);
                previousOrder = status.SortOrder;
            }
        }
        if (openResults.size() > 0) {
            Integer previousOrder = openResults[0].SortOrder;
            for (TaskStatus status : openResults) {
                System.assertEquals(previousOrder <= status.SortOrder, true);
                previousOrder = status.SortOrder;
            }
        }
    }

    @isTest
    static void taskStatusSelectorReturnsCorrectObjectType() {
        // Given
        Schema.SObjectType expectedType = TaskStatus.sObjectType;

        // When
        Schema.SObjectType returnedType = TaskStatusSelector.newInstance().getSObjectType();

        // Then
        System.assertEquals(expectedType, returnedType);
    }
}