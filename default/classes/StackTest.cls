@isTest
private class StackTest {
    @isTest
    static void testStackOperations() {
        Stack myStack = new Stack();
        Assert.areEqual(true, myStack.isEmpty(), 'Stack should be empty initially');

        myStack.push('Item1');
        myStack.push('Item2');
        Assert.areEqual(2, myStack.size(), 'Stack size should be 2 after pushing two items');

        Object poppedItem = myStack.pop();
        Assert.areEqual('Item2', poppedItem, 'Popped item should be "Item2"');

        Object topItem = myStack.top();
        Assert.areEqual('Item1', topItem, 'Top item should be "Item1"');

        myStack.push('Item3');
        Object peekedItem = myStack.peek();
        Assert.areEqual('Item3', peekedItem, 'Peeked item should be "Item3"');

        Stack emptyStack = new Stack();
        Object peekResult = emptyStack.peek();
        Assert.areEqual(null, peekResult, 'Peek result should be null for an empty stack');
    }

    @isTest
    static void testEmptyStackException() {
        Stack emptyStack = new Stack();

        try {
            emptyStack.pop();
            Assert.fail('ListException should have been thrown for pop on an empty stack');
        } catch (ListException e) {
            Assert.areEqual(
                System.Label.error_empty_stack_pop,
                e.getMessage(),
                'ListException message should be "error_empty_stack_pop"'
            );
        }

        try {
            emptyStack.top();
            Assert.fail('ListException should have been thrown for top on an empty stack');
        } catch (ListException e) {
            Assert.areEqual(
                System.Label.error_empty_stack_top,
                e.getMessage(),
                'ListException message should be "error_empty_stack_top"'
            );
        }
    }
}