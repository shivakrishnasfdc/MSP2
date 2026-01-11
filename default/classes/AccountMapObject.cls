public interface AccountMapObject {
    Id id();
    Id parentId();
    Id accountId();
    String accountFirstName();
    String accountLastName();
    String objectName();
    String influence();
    String support();
    String supportColor();
    Object get(String key);
}