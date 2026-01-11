public interface IRelationshipMapUserObject {
    Id id();
    Id managerId();
    Id userId();
    String userFirstName();
    String userLastName();
    String objectName();
    Object get(String key);
}