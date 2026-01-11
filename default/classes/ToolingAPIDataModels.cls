@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.FieldNamingConventions')
public with sharing class ToolingAPIDataModels{

    public class DescribeLayoutResult {
        public List<DescribeLayout> layouts;
        public List<RecordTypeMapping> recordTypeMappings;
        public List<Boolean> recordTypeSelectorRequired;
    }

    public class DescribeLayout {
        public DescribeLayoutButtonSection buttonLayoutSection;
        public List<DescribeLayoutSection> detailLayoutSections;
        public List<DescribeLayoutSection> editLayoutSections;
        public List<DescribeLayoutSection> highlightsPanelLayoutSection;
        public List<DescribeLayoutSection> multirowEditLayoutSections;
        public Id id;
        public DescribeQuickActionListResult quickActionList;
        public RelatedContent relatedContent;
        public List<RelatedList> relatedLists;
        public List<DescribeLayoutSaveOption> saveOptions;
    }

    public class RecordTypeMapping {
        public Boolean available;
        public Boolean defaultRecordTypeMapping;
        public Id layoutId;
        public String name;
        public List<PickListForRecordType> picklistsForRecordType;
        public Id recordTypeId;
        public LayoutUrl urls;
    }

    public class LayoutUrl {
        public String layout;
    }

    public class DescribeQuickActionListResult {
        public List<DescribeQuickActionListItemResult> quickActionListItems;
    }

    public class DescribeQuickActionListItemResult {
        public List<DescribeColor> colors;
        public String iconUrl;
        public List<DescribeIcon> icons;
        public String label;
        public String miniIconUrl;
        public String quickActionName;
        public String targetSobjectType;
        public String type;
    }

    public class DescribeLayoutSection {
        public Integer columns;
        public String heading;
        public List<DescribeLayoutRow> layoutRows;
        public Id parentLayoutId;
        public Integer rows;
        public String tabOrder;
        public Boolean useCollapsibleSection;
        public Boolean useHeading;
    }

    public class DescribeLayoutRow {
        public List<DescribeLayoutItem> layoutItems;
        public Integer numItems;
    }

    public class DescribeLayoutItem {
        public Boolean editable;
        public Boolean editableForNew;
        public Boolean editableForUpdate;
        public String label;
        public List<DescribeLayoutComponent> layoutComponents;
        public Boolean placeholder;
        public Boolean required;
    }

    public class DescribeLayoutButtonSection {
        public List<DescribeLayoutButton> detailButtons;
    }

    public class DescribeLayoutButton {
        public WebLinkWindowType behavior;
        public List<DescribeColor> colors;
        public String content;
        public WebLinkType contentSource;
        public Boolean custom;
        public String encoding;
        public Integer height;
        public List<DescribeIcon> icons;
        public String label;
        public Boolean menubar;
        public String name;
        public Boolean overridden;
        public Boolean resizeable;
        public Boolean scrollbars;
        public Boolean showsLocation;
        public Boolean showsStatus;
        public Boolean toolbar;
        public String url;
        public Integer width;
        public WebLinkPosition windowPosition;
    }

    public class DescribeLayoutSaveOption {
        public Boolean defaultValue;
        public Boolean isDisplayed;
        public String label;
        public String name;
        public String restHeaderName;
        public String soapHeaderName;
    }

    public class DescribeColor {
        public String color;
        public String context;
        public String theme;
    }

    public class DescribeIcon{
        public String contentType;
        public Integer height;
        public String theme;
        public String url;
        public String width;
    }

    public class PickListForRecordType {
        public String picklistName;
        public List<PickListEntry> picklistValues;
    }

    public class PickListEntry {
        public Boolean active;
        public Blob validFor;
        public Boolean defaultValue;
        public String label;
        public String value;
    }

    public class RelatedList {
        public List<DescribeLayoutButton> buttons;
        public List<RelatedListColumn> columns;
        public Boolean custom;
        public String field;
        public String label;
        public Integer limitRows;
        public String name;
        public String sobject_z;
        public List<RelatedListSort> sort_z;
    }

    public class RelatedListColumn{
        public String field;
        public String fieldApiName;
        public String format;
        public String label;
        public String lookupId;
        public String name;
    }

    public class RelatedListSort {
        public String column;
        public Boolean ascending;
    }

    public enum WebLinkPosition {
        fullScreen,
        none,
        topleft
    }

    public enum WebLinkType {
        javascript,
        page,
        sControl,
        url
    }

    public enum WebLinkWindowType {
        newWindow,
        noSidebar,
        onClickJavaScript,
        replace,
        sidebar
    }

    public class DescribeLayoutComponent {
        public Integer displayLines;
        public Integer tabOrder;
        public LayoutComponentType type;
        public String value;
    }

    public enum LayoutComponentType {
        AuraComponent,
        AnalyticsCloud,
        Canvas,
        CustomLink,
        EmptySpace,
        ExpandedLookup,
        Field,
        ReportChart,
        SControl,
        Separator,
        VisualforcePage
    }

    public class RelatedContent {
        public List<DescribeRelatedContentItem> relatedContentItems;
    }

    public class DescribeRelatedContentItem {
        public DescribeLayoutItem describeLayoutItem;
    }
}