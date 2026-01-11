public class FFLibHelper {
    public static Object mockSelector(Type classToMock, fflib_ApexMocks mocks) {
        fflib_SObjectSelector selectorInstance = (fflib_SObjectSelector) classToMock.newInstance();
        fflib_SObjectSelector mockSelector = (fflib_SObjectSelector) Test.createStub(classtoMock, mocks);
        mocks.startStubbing();
        mocks.when(mockSelector.sObjectType()).thenReturn(selectorInstance.sObjectType());
        mocks.stopStubbing();
        return mockSelector;
    }

    public static Object mockDomain(SObjectType objectType, Type classToMock, fflib_ApexMocks mocks) {
        fflib_SObjectDomain mockDomain = (fflib_SObjectDomain) Test.createStub(classtoMock, mocks);

        mocks.startStubbing();
        mocks.when(mockDomain.sObjectType()).thenReturn(objectType);
        mocks.stopStubbing();

        return mockDomain;
    }

    public static Set<Id> eqIdSet(Set<Id> toMatch) {
        return (Set<Id>) fflib_Match.matches(new fflib_MatcherDefinitions.Eq(toMatch));
    }

    public static fflib_QueryFactory subSelectHistories(fflib_QueryFactory queryFactory) {
        return subSelectHistories(queryFactory, new Set<String>());
    }

    public static fflib_QueryFactory subSelectHistories(fflib_QueryFactory queryFactory, Set<String> extraFields) {
        Set<String> historyFields = new Set<String>{
            'Id',
            'ParentId',
            'Parent.Name',
            'Field',
            'OldValue',
            'NewValue',
            'CreatedById',
            'CreatedDate'
        };

        if (extraFields != null) {
            historyFields.addAll(extraFields);
        }

        return queryFactory.subselectQuery('Histories')
            .selectFields(historyFields)
            .selectField('CreatedBy.Name', User.getSObjectType());
    }

    /**
     * ListOfSize matcher: checks if the supplied argument is an instance of a List with the specified number of elements
     */
    public class ListOfSize implements fflib_IMatcher {
        private Integer size;
        public ListOfSize(Integer size) {
            this.size = size;
        }

        public Boolean matches(Object arg) {
            Boolean isList = arg != null && arg instanceof List<Object>;
            return isList && ((List<Object>) arg).size() == size;
        }

        public override String toString() {
            return '[list of size ' + size + ']';
        }
    }
}