public interface IRelationshipMapObject {
    Id id();
    Id parentId();
    Id contactId();
    String contactFirstName();
    String contactLastName();
    String objectName();
    String influence();
    String support();
    String supportColor();
    Object get(String key);
}