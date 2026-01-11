public interface IRelationshipMapLeadObject {
    Id id();
    Id leadId();
    String firstName();
    String lastName();
    String objectName();
    Object get(String key);
}