/**
 * Class implements a Unit of Work factory
 **/
public virtual class PQUnitOfWorkFactory {
    private List<SObjectType> factoryObjectTypes;
    private fflib_ISObjectUnitOfWork factoryMockUow;

    /**
     * Constructs a Unit Of Work factory
     *
     * @param objectTypes List of SObjectTypes in dependency order
     **/
    public PQUnitOfWorkFactory(List<SObjectType> objectTypes) {
        factoryObjectTypes = objectTypes.clone();
    }

    /**
     * Returns a new fflib_SObjectUnitOfWork configured with the
     *   SObjectType list provided in the constructor, returns a Mock implementation
     *   if set via the setMock method
     **/
    public fflib_ISObjectUnitOfWork newInstance() {
        // Mock?
        if (factoryMockUow != null) {
            return factoryMockUow;
        }
        return new fflib_SObjectUnitOfWork(factoryObjectTypes, new SecureDML());
    }

    /**
     * Returns a new fflib_SObjectUnitOfWork configured with the
     *   SObjectType list provided in the constructor, returns a Mock implementation
     *   if set via the setMock method
     **/
    public fflib_ISObjectUnitOfWork newInstance(fflib_SObjectUnitOfWork.IDML dml) {
        // Mock?
        if (factoryMockUow != null) {
            return factoryMockUow;
        }
        return new fflib_SObjectUnitOfWork(factoryObjectTypes, dml);
    }

    /**
     * Returns a new fflib_SObjectUnitOfWork configured with the
     *   SObjectType list specified, returns a Mock implementation
     *   if set via the setMock method
     *
     * @remark If mock is set, the list of SObjectType in the mock could be different
     *         then the list of SObjectType specified in this method call
     **/
    public fflib_ISObjectUnitOfWork newInstance(List<SObjectType> objectTypes) {
        // Mock?
        if (factoryMockUow != null) {
            return factoryMockUow;
        }
        return new fflib_SObjectUnitOfWork(objectTypes, new SecureDML());
    }

    /**
     * Returns a new fflib_SObjectUnitOfWork configured with the
     *   SObjectType list specified, returns a Mock implementation
     *   if set via the setMock method
     *
     * @remark If mock is set, the list of SObjectType in the mock could be different
     *         then the list of SObjectType specified in this method call
     **/
    public fflib_ISObjectUnitOfWork newInstance(List<SObjectType> objectTypes, fflib_SObjectUnitOfWork.IDML dml) {
        // Mock?
        if (factoryMockUow != null) {
            return factoryMockUow;
        }
        return new fflib_SObjectUnitOfWork(objectTypes, dml);
    }

    @TestVisible
    private void setMock(fflib_ISObjectUnitOfWork mockUow) {
        factoryMockUow = mockUow;
    }
}