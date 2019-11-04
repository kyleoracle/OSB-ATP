/**
 * Application Name: CafeSupremo
 * ViewModel: Discover
 * Author: Rayes Huang
 */
define(['ojs/ojcore', 'knockout', 'jquery', 'ojs/ojknockout', 'ojs/ojlistview', 'ojs/ojjsontreedatasource', 'ojs/ojbutton'],
 function(oj, ko, $) {

    function DiscoverViewModel() {
      var self = this;
      self.products = new ko.observable();
      self.ds = new ko.observable();
      self.v = ko.observable("v1");


      self.itemOnly = function(context)
        {
          return context['leaf'];
        };
      self.selectTemplate = function(file, bindingContext)
      {
        return bindingContext.$itemContext.leaf ? 'item_template' : 'group_template';
      };
      // Below are a set of the ViewModel methods invoked by the oj-module component.
      // Please reference the oj-module jsDoc for additional information.

      /**
       * Optional ViewModel method invoked after the View is inserted into the
       * document DOM.  The application can put logic that requires the DOM being
       * attached here.
       * This method might be called multiple times - after the View is created
       * and inserted into the DOM and after the View is reconnected
       * after being disconnected.
       */
      self.connected = function() {
        // Implement if needed
        $.getJSON("https://lvehgh9rrmbgcid-db201911041446.adb.ap-tokyo-1.oraclecloudapps.com/ords/kyle/atp/products",
        function(data)
        {
          console.log(data.items);
          self.ds({"attr": {"id": "coffee",
                "name": "Blended Beverages"
                }
            });

          self.ds.children = data.items.map(e => {
            return {"attr": {"id": e.id,
                        "name": e.productname,
                        "price": '$' + e.productprice,
                        "img": "americano.png",
                        "count":0
                    }
            };
          })
          
          self.products(new oj.JsonTreeDataSource(self.ds));

        })
      };

      self.more = function(that) {
        console.log(that.id);
        self.ds.children.forEach(e => {
          if(e.attr.id === that.id){
            console.log(e.attr.count);
            e.attr.count = e.attr.count + 1;
            self.products(new oj.JsonTreeDataSource(self.ds));
            return;
          }
        });
      }

      self.less = function(that) {
        console.log(that.id);
        self.ds.children.forEach(e => {
          if(e.attr.id === that.id && e.attr.count>0){
            console.log(e.attr.count);
            e.attr.count = e.attr.count - 1;
            self.products(new oj.JsonTreeDataSource(self.ds));
            return;
          }
        });
      }
      
      self.submit = function() {
      
        console.log(self.ds.children);

        let order = {
          "source": "mobile",
          "version": self.v(),
          "orderdate": new Date().toISOString(),
          "details": {
            "memid": "12345",
            "payment": "visa",
            "products": [
            ]
          }
        };

        self.ds.children.forEach(e => {
          if(e.attr.count>0){
            console.log(e.attr.count);
            for(let i=0;i<e.attr.count;i++){
              order.details.products.push({"product": e.attr.name});
            }
          }
        });

        console.log(order);

        if(order.details.products.length === 0){
          return;
        }


        let data = {"jsondata":JSON.stringify(order)};
        $.ajax({
            type: "POST",
            url: 'https://lvehgh9rrmbgcid-db201911041446.adb.ap-tokyo-1.oraclecloudapps.com/ords/kyle/atp/orders',
            data: JSON.stringify(data),
            contentType: "application/json",
            success: function (data) {
                console.log('success');
                alert('success');
            }
        });

      }

      /**
       * Optional ViewModel method invoked after the View is disconnected from the DOM.
       */
      self.disconnected = function() {
        // Implement if needed
      };

      /**
       * Optional ViewModel method invoked after transition to the new View is complete.
       * That includes any possible animation between the old and the new View.
       */
      self.transitionCompleted = function() {
        // Implement if needed
      };
    }

    /*
     * Returns a constructor for the ViewModel so that the ViewModel is constructed
     * each time the view is displayed.  Return an instance of the ViewModel if
     * only one instance of the ViewModel is needed.
     */
    return new DiscoverViewModel();
  }
);
