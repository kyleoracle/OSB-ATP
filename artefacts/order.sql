CREATE TABLE Orders (
      jsondata VARCHAR2(4000) CONSTRAINT ensure_jsondata CHECK (jsondata IS JSON(STRICT))
); 

INSERT INTO Orders (jsondata) VALUES ('{
  "source": "mobile",
  "version": 1.0,
  "orderdate": "2019-11-04T12:40:00.000Z",
  "details": {
    "memid": "12345",
    "payment": "visa",
    "products": [
      {
        "product": "Iced Latte1"
      },
      {
        "product": "Iced Mocha"
      }
    ]
  }
}');

commit;


-- enable
apex -> create workspace
db name=KYLE
workspace=KYLE
login kyle workspace -> sql workshop -> rest service -> register schema with ORDS -> enable sample module
create new module -> create template -> create handler

-- get, not ends with ;
select * from Orders;

select count(t.product_name) count, t.product_name
from orders o, 
     json_table(o.jsondata, '$.details.products[*]' 
         columns (
              product_name VARCHAR2 path '$.product'
         )
     ) t
where TO_DATE(SUBSTR(json_value(o.jsondata, '$.orderdate'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') > (sysdate - 10/(24*60))
group by product_name

-- post
begin
insert into orders(jsondata) values(:jsondata);
end;

curl -X "POST" "xxx" \
     -H 'Content-Type: application/json' \
     -d @test.json









