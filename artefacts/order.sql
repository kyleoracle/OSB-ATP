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
    "temp": "27.2",
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
group by product_name order by count desc

-- post
begin
insert into orders(jsondata) values(:jsondata);
end;

curl -X "POST" "xxx" \
     -H 'Content-Type: application/json' \
     -d @test.json


-- json index / json guide / virtual column
DROP INDEX json_docs_search_idx;
CREATE SEARCH INDEX json_docs_search_idx ON Orders (jsondata) FOR JSON;
-- enable auto add virtual column
ALTER INDEX json_docs_search_idx REBUILD PARAMETERS ('DATAGUIDE ON CHANGE ADD_VC');
-- query json guide
SELECT JSON_DATAGUIDE(jsondata) dg_doc FROM Orders;

SELECT DBMS_JSON.get_index_dataguide(
        'Orders',
        'jsondata',
        DBMS_JSON.format_hierarchical,
        DBMS_JSON.pretty) AS dg
FROM   dual;
-- add virtual column, must be format_hierarchical, array is ignored
BEGIN
DBMS_JSON.add_virtual_columns(
tablename  => 'Orders',
jcolname   => 'jsondata',
dataguide  => DBMS_JSON.get_index_dataguide(
                'Orders',
                'jsondata',
                DBMS_JSON.format_hierarchical)
                );
END;
/

-- remove virtual column
BEGIN
  DBMS_JSON.drop_virtual_columns(
    tablename  => 'Orders',
    jcolname   => 'jsondata');
END;
/

-- Create view, array is included
BEGIN
  DBMS_JSON.create_view(
    viewname  => 'Orders_v1',
    tablename => 'Orders',
    jcolname  => 'jsondata',
    dataguide =>  DBMS_JSON.get_index_dataguide(
                    'Orders',
                    'jsondata',
                    DBMS_JSON.format_hierarchical));
END;
/

-- remove view
DROP VIEW Orders_v1;

-- Create view, defined column names.
BEGIN
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.source', DBMS_JSON.TYPE_STRING, 'o_source');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details', DBMS_JSON.TYPE_BOOLEAN, 'o_details');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details.temp', DBMS_JSON.TYPE_STRING, 'o_temp');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details.memid', DBMS_JSON.TYPE_STRING, 'o_memid');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details.payment', DBMS_JSON.TYPE_STRING, 'o_payment');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details.products', DBMS_JSON.TYPE_STRING, 'o_products');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details.products.size', DBMS_JSON.TYPE_STRING, 'o_size');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.details.products.product', DBMS_JSON.TYPE_STRING, 'o_product');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.version', DBMS_JSON.TYPE_STRING, 'o_version');
  DBMS_JSON.rename_column('Orders', 'jsondata', '$.orderdate', DBMS_JSON.TYPE_STRING, 'o_orderdate');
END;
/

BEGIN
  DBMS_JSON.create_view(
    viewname  => 'Orders_v2',
    tablename => 'Orders',
    jcolname  => 'jsondata',
    dataguide =>  DBMS_JSON.get_index_dataguide(
                    'Orders',
                    'jsondata',
                    DBMS_JSON.format_hierarchical));
END;
/

-- remove view
DROP VIEW Orders_v2;







