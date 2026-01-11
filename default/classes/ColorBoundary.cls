public with sharing class ColorBoundary {
    @AuraEnabled
    public String lowColor { get; set; }
    @AuraEnabled
    public String midColor { get; set; }
    @AuraEnabled
    public String highColor { get; set; }
    @AuraEnabled
    public Decimal lowMidBoundary { get; set; }
    @AuraEnabled
    public Decimal midHighBoundary { get; set; }

    public ColorBoundary() {
        this.lowColor = '#E1341E';
        this.midColor = '#EB8214';
        this.highColor = '#2DD24A';
        this.lowMidBoundary = .25;
        this.midHighBoundary = .75;
    }

    public ColorBoundary(
        String lowColor,
        String midColor,
        String highColor,
        Decimal lowMidBoundary,
        Decimal midHighBoundary
    ) {
        this.lowColor = lowColor;
        this.midColor = midColor;
        this.highColor = highColor;
        this.lowMidBoundary = lowMidBoundary;
        this.midHighBoundary = midHighBoundary;
    }
}