import ballerina.lang.datatables;
import ballerina.data.sql;
import ballerina.lang.errors;

struct ResultPrimitive {
    int INT_TYPE;
    int LONG_TYPE;
    float FLOAT_TYPE;
    float DOUBLE_TYPE;
    boolean  BOOLEAN_TYPE;
    string  STRING_TYPE;
}

struct ResultObject {
    string BLOB_TYPE;
    string CLOB_TYPE;
    string TIME_TYPE;
    string DATE_TYPE;
    string TIMESTAMP_TYPE;
    string DATETIME_TYPE;
    string BINARY_TYPE;
}

struct ResultMap {
    map INT_ARRAY;
    map LONG_ARRAY;
    map FLOAT_ARRAY;
    map BOOLEAN_ARRAY;
    map STRING_ARRAY;
}


function getXXXByIndex()(int, int, float, float, boolean, string) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                        "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    int i;
    int l;
    float f;
    float d;
    boolean b;
    string s;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    while (datatables:hasNext(df)) {
        i = datatables:getInt(df, 1);
        l = datatables:getInt(df, 2);
        f = datatables:getFloat(df, 3);
        d = datatables:getFloat(df, 4);
        b = datatables:getBoolean(df, 5);
        s = datatables:getString(df, 6);
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return i, l, f, d, b, s;
}

function getXXXByName()(int, int, float, float, boolean, string) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    int i;
    int l;
    float f;
    float d;
    boolean b;
    string s;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    while (datatables:hasNext(df)) {
        i = datatables:getInt(df, "int_type");
        l = datatables:getInt(df, "long_type");
        f = datatables:getFloat(df, "float_type");
        d = datatables:getFloat(df, "double_type");
        b = datatables:getBoolean(df, "boolean_type");
        s = datatables:getString(df, "string_type");
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return i, l, f, d, b, s;
}

function toJson()(json) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    json result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    result = datatables:toJson(df);
    return result;
}

function toXmlWithWrapper()(xml) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    xml result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    result = datatables:toXml(df, "types", "type");
    return result;
}

function toXmlComplex() (xml) {
    map propertiesMap = {"jdbcUrl":"jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                         "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    xml result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, int_array, long_type, long_array, float_type,
                float_array, double_type, boolean_type, string_type, double_array, boolean_array, string_array
                from MixTypes LIMIT 1",parameters);
    result = datatables:toXml(df, "types", "type");
    return result;
}

function getByName()(string, string, int, int, int) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    string blobValue;
    string clob;
    int time;
    int date;
    int timestamp;

    df = sql:ClientConnector.select(testDB, "SELECT blob_type, clob_type, time_type, date_type, timestamp_type
                from ComplexTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        blobValue = datatables:getStringWithType(df, "blob_type", "blob");
        clob = datatables:getStringWithType(df, "clob_type", "clob");
        time = datatables:getIntWithType(df, "time_type", "time");
        date = datatables:getIntWithType(df, "date_type", "date");
        timestamp = datatables:getIntWithType(df, "timestamp_type", "timestamp");
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return blobValue, clob, time, date, timestamp;
}

function getByIndex()(string, string, int, int, int, string) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    string blobValue;
    string clob;
    int time;
    int date;
    int timestamp;
    string binary;

    sql:ClientConnector.update(testDB, "Update ComplexTypes set clob_type = 'Test String' where row_id = 1",parameters);

    df = sql:ClientConnector.select(testDB, "SELECT blob_type, clob_type, time_type, date_type, timestamp_type,
            binary_type from ComplexTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        blobValue = datatables:getStringWithType(df, 1, "blob");
        clob = datatables:getStringWithType(df, 2, "clob");
        time = datatables:getIntWithType(df, 3, "time");
        date = datatables:getIntWithType(df, 4, "date");
        timestamp = datatables:getIntWithType(df, 5, "timestamp");
        binary = datatables:getStringWithType(df, 6, "binary");
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return blobValue, clob, time, date, timestamp, binary;
}

function getObjectAsStringByIndex()(string, string, string, string, string, string ) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    string blobValue;
    string clob;
    string time;
    string date;
    string timestamp;
    string datetime;

    df = sql:ClientConnector.select(testDB, "SELECT blob_type, clob_type, time_type, date_type, timestamp_type,
                datetime_type from ComplexTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        blobValue = datatables:getValueAsString(df, 1);
        clob = datatables:getValueAsString(df, 2);
        time = datatables:getValueAsString(df, 3);
        date = datatables:getValueAsString(df, 4);
        timestamp = datatables:getValueAsString(df, 5);
        datetime = datatables:getValueAsString(df, 6);
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return blobValue, clob, time, date, timestamp, datetime;
}

function getObjectAsStringByName()(string, string, string, string, string, string) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    string blobValue;
    string clob;
    string time;
    string date;
    string timestamp;
    string datetime;

    df = sql:ClientConnector.select(testDB, "SELECT blob_type, clob_type, time_type, date_type, timestamp_type,
                datetime_type from ComplexTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        blobValue = datatables:getValueAsString(df, "blob_type");
        clob = datatables:getValueAsString(df, "clob_type");
        time = datatables:getValueAsString(df, "time_type");
        date = datatables:getValueAsString(df, "date_type");
        timestamp = datatables:getValueAsString(df, "timestamp_type");
        datetime = datatables:getValueAsString(df, "datetime_type");
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return blobValue, clob, time, date, timestamp, datetime;
}


function getArrayByName()(map int_arr, map long_arr, map float_arr, map string_arr, map boolean_arr) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;

    df = sql:ClientConnector.select(testDB, "SELECT int_array, long_array, float_array, boolean_array, string_array
                from ArrayTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        int_arr = datatables:getArray(df, "int_array");
        long_arr = datatables:getArray(df, "long_array");
        float_arr = datatables:getArray(df, "float_array");
        boolean_arr = datatables:getArray(df, "boolean_array");
        string_arr = datatables:getArray(df, "string_array");
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return;
}

function getArrayByIndex()(map int_arr, map long_arr, map float_arr, map string_arr, map boolean_arr) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                            "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;

    df = sql:ClientConnector.select(testDB, "SELECT int_array, long_array, float_array, boolean_array, string_array
                from ArrayTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        int_arr = datatables:getArray(df, 1);
        long_arr = datatables:getArray(df, 2);
        float_arr = datatables:getArray(df, 3);
        boolean_arr = datatables:getArray(df, 4);
        string_arr = datatables:getArray(df, 5);
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return;
}

function testDateTime(int time, int date, int timestamp) (int time1, int date1, int timestamp1) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                         "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter para1 = {sqlType:"TIME", value:time, direction:0};
    sql:Parameter para2 = {sqlType:"DATE", value:date, direction:0};
    sql:Parameter para3 = {sqlType:"TIMESTAMP", value:timestamp, direction:0};
    sql:Parameter[] parameters = [para1,para2,para3];

    int insertCount = sql:ClientConnector.update(testDB,"Insert into DateTimeTypes
        (time_type, date_type, timestamp_type) values (?,?,?)", parameters);

    sql:Parameter[] emptyParam = [];
    datatable dt = sql:ClientConnector.select(testDB, "SELECT time_type, date_type, timestamp_type
                from DateTimeTypes LIMIT 1", emptyParam);
    while (datatables:hasNext(dt)) {
        time1 = datatables:getIntWithType(dt, "time_type", "time");
        date1 = datatables:getIntWithType(dt, "date_type", "date");
        timestamp1 = datatables:getIntWithType(dt, "timestamp_type", "timestamp");
    }
    datatables:close(dt);
    sql:ClientConnector.close(testDB);
    return;
}

function testJsonWithNull()(json) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                         "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    json result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 2",parameters);
    result = datatables:toJson(df);
    return result;
}

function testXmlWithNull()(xml) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                         "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    xml result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 2",parameters);
    result = datatables:toXml(df, "types", "type");
    return result;
}

function getXXXByIndexWithStruct()(int, int, float, float, boolean, string) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                        "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    int i;
    int l;
    float f;
    float d;
    boolean b;
    string s;
    errors:CastError err;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    while (datatables:hasNext(df)) {
        any para = datatables:next(df);
        ResultPrimitive rs;
        rs, err = (ResultPrimitive) para;

        i = rs.INT_TYPE;
        l = rs.LONG_TYPE;
        f = rs.FLOAT_TYPE;
        d = rs.DOUBLE_TYPE;
        b = rs.BOOLEAN_TYPE;
        s = rs.STRING_TYPE;
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return i, l, f, d, b, s;
}

function getObjectAsStringByNameWithStruct()(string, string, string, string, string, string, string) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                        "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    string blobValue;
    string clob;
    string time;
    string date;
    string timestamp;
    string datetime;
    string binary;
    errors:CastError err;

    df = sql:ClientConnector.select(testDB, "SELECT blob_type, clob_type, time_type, date_type, timestamp_type,
                datetime_type, binary_type from ComplexTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        any para = datatables:next(df);
        ResultObject rs;
        rs, err = (ResultObject) para;

        blobValue = rs.BLOB_TYPE;
        clob = rs.CLOB_TYPE;
        time = rs.TIME_TYPE;
        date = rs.DATE_TYPE;
        timestamp = rs.TIMESTAMP_TYPE;
        datetime = rs.DATETIME_TYPE;
        binary = rs.BINARY_TYPE;
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return blobValue, clob, time, date, timestamp, datetime, binary;
}

function testGetArrayByNameWithStruct()(map, map, map, map, map) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                        "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    map int_arr;
    map long_arr;
    map float_arr;
    map string_arr;
    map boolean_arr;
    errors:CastError err;

    df = sql:ClientConnector.select(testDB, "SELECT int_array, long_array, float_array, boolean_array, string_array
                from ArrayTypes LIMIT 1",parameters);
    while (datatables:hasNext(df)) {
        any para = datatables:next(df);
        ResultMap rs;
        rs, err = (ResultMap) para;

        int_arr = rs.INT_ARRAY;
        long_arr = rs.LONG_ARRAY;
        float_arr = rs.FLOAT_ARRAY;
        boolean_arr = rs.BOOLEAN_ARRAY;
        string_arr = rs.STRING_ARRAY;
    }
    datatables:close(df);
    sql:ClientConnector.close(testDB);
    return int_arr, long_arr, float_arr, string_arr, boolean_arr;
}

function testtoJsonWithStruct()(json) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                        "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    json result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    result = <json> df;
    return result;
}

function testToXmlWithStruct()(xml) {
    map propertiesMap = {"jdbcUrl" : "jdbc:hsqldb:file:./target/tempdb/TEST_DATA_TABLE_DB",
                        "username":"SA", "password":"", "maximumPoolSize":1};
    sql:ClientConnector testDB = create sql:ClientConnector(propertiesMap);
    sql:Parameter[] parameters=[];
    datatable df;
    xml result;

    df = sql:ClientConnector.select(testDB, "SELECT int_type, long_type, float_type, double_type, boolean_type,
                string_type from DataTable WHERE row_id = 1",parameters);
    result = <xml> df;
    return result;
}