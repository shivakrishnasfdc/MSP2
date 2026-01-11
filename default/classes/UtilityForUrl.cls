public with sharing class UtilityForUrl {
    public static Id getIdFromRequest(RestRequest req) {
        String idString = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        return UtilityForString.getIdForString(idString);
    }
}