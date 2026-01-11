({
    ENTER: 13,
    ESCAPE: 27,
    ARROW_UP: 38,
    ARROW_DOWN: 40,

    updateSearchTerm: function (component, searchTerm) {
        // Cleanup new search term
        const updatedSearchTerm = searchTerm.trim().replace(/\*/g).toLowerCase();

        // Compare clean new search term with current one and abort if identical
        const curSearchTerm = component.get('v.searchTerm');

        if (curSearchTerm === updatedSearchTerm) {
            return;
        }

        // Update search term
        component.set('v.searchTerm', updatedSearchTerm);

        // Ignore search terms that are too small
        if (updatedSearchTerm.length < 2) {
            component.set('v.searchResults', []);

            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = component.get('v.searchThrottlingTimeout');

        if (searchTimeout) {
            window.clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(function () {
                // Send search event if it long enougth
                searchTerm = component.get('v.searchTerm');
                if (searchTerm.length >= 2) {
                    const searchEvent = component.getEvent('onSearch');

                    searchEvent.fire();
                }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },

    selectResult: function (component, recordId) {
        // Save selection
        const searchResults = component.get('v.searchResults');
        const selectedResult = searchResults.find(function (result) {
            return result.id === recordId;
        });

        if (selectedResult) {
            component.set('v.selectedRecordId', recordId);
            component.set('v.selection', selectedResult);
        }

        // Fire event
        const selectEvent = component.getEvent('onSelect');

        selectEvent.fire();

        // Reset search
        const searchInput = component.find('searchInput');

        searchInput.getElement().value = '';
        component.set('v.searchTerm', '');
        component.set('v.searchResults', []);
    },

    clearSelection: function (component) {
        component.set('v.selectedRecordId', '');
        component.set('v.selection', null);
    },

    isSelectionAllowed: function (component) {
        return $A.util.isEmpty(component.get('v.selection'));
    }
});