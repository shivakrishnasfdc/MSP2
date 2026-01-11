(function(w) {
    w.StrategyUtils = {
        _bodyOverflow: '',

        successToast: function(message) {
            var toastEvent = $A.get('e.force:showToast');

            if (toastEvent) {
                toastEvent.setParams({
                    message: message,
                    type: 'success',
                    duration: 3000
                });
                toastEvent.fire();
            }
        },

        errorToast: function(message) {
            var toastEvent = $A.get('e.force:showToast');

            if (toastEvent) {
                toastEvent.setParams({
                    message: message,
                    type: 'error'
                });
                toastEvent.fire();
            }
        },

        hideModal: function(component, modalName) {
            var modal = component.find(modalName);
            $A.util.removeClass(modal, 'slds-fade-in-open');

            var backdrop = component.find('backdrop');
            $A.util.removeClass(backdrop, 'slds-backdrop_open');

            document.body.style.overflow = this._bodyOverflow;
        },

        showModal: function(component, modalName) {
            var modal = component.find(modalName);
            $A.util.addClass(modal, 'slds-fade-in-open');

            var backdrop = component.find('backdrop');
            $A.util.addClass(backdrop, 'slds-backdrop_open');

            this._bodyOverflow = document.body.style.overflow;
            document.body.style.overflow = 'hidden';
        },

        executeAction: function(component, actionName, params, setBackground) {
            return new Promise(function(resolve, reject) {
                var action = component.get(actionName);

                action.setParams(params);
                action.setCallback(this, function(response) {
                    if (component.isValid() && response.getState() === 'SUCCESS') {
                        resolve(response.getReturnValue());
                    } else {
                        reject(response.getError()[0]);
                    }
                });
                if (setBackground) {
                    action.setBackground();
                }
                $A.enqueueAction(action);
            });
        },

        cloneObject: function(obj) {
            if (Object && Object.assign) {
                return Object.assign({}, obj);
            } else {
                return JSON.parse(JSON.stringify(obj));
            }
        },

        cloneArray: function(arr) {
            var self = this,
                copy = arr.slice();

            copy.forEach(function(item, index) {
                copy[index] = self.cloneObject(item);
            });

            return copy;
        },

        refreshView: function() {
            var refresh = $A.get('e.force:refreshView');
            if (refresh) {
                refresh.fire();
            } else {
                window.location.reload();
            }
        },

        // This augments Promise.all(...) to allow for some promises to reject without losing the data returned from those that succeeded.
        // See the following StackOverflow post: http://stackoverflow.com/questions/31424561/wait-until-all-es6-promises-complete-even-rejected-promises
        promiseReflect: function(promise) {
            return promise.then(function (d) { return { data: d, status: "resolved" } },
            function (e) { return { error: e, status: "rejected" } });
        }

    };
})(window);
