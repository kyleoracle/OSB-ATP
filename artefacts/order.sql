CREATE TABLE Orders (
      jsondata VARCHAR2(4000) CONSTRAINT ensure_jsondata CHECK (jsondata IS JSON(STRICT))
); 

INSERT INTO Orders (jsondata) VALUES ('{
  "source": "mobile",
  "version": 1.0,
  "orderdate": "2019-11-04T16:50:00.000Z",
  "details": {
    "memid": "12345",
    "payment": "visa",
    "products": [
      {
        "product": "Iced Latte1",
        "size": "Large"
      },
      {
        "product": "Iced Mocha",
        "size": "Small"
      }
    ]
  }
}');

commit;

select * from Orders;

select count(t.product_name) count, t.product_name
from orders o, 
     json_table(o.jsondata, '$.details.products[*]' 
         columns (
              product_name VARCHAR2 path '$.product'
         )
     ) t
where to_timestamp(json_value(o.jsondata, '$.orderdate'), 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"') > sysdate - interval '10' minute
group by product_name
-- not ends with ;









