### 基于文本搜索某表某列
#### 创建测试表
```sql
 create table tmp_tb1(id bigint, name text);
 
--插入测试数据
  id   |                            name
-------+-------------------------------------------------------------
 23391 | FX8-24 (ibm)
  8700 | XPS 600-Renegade
  4886 | 6224P
 21024 | CPT-600
 14103 | 1100E
   177 | network inlet FC
   144 | network inlet FC LAN
    76 | network inlet FC WAN
  3913 | ME-3600X-24TS-M
 16539 | Rack 28U(600x800)
 20547 | 4 Port Wall Jack
```

#### 创建索引及打分UDF
```sql
CREATE INDEX ON tmp_tb1 USING gin (name gin_trgm_ops);

-- 本案例要求连续数字字符权重值更大
CREATE OR REPLACE FUNCTION similarity(_text text, _query text)
 RETURNS numeric(10,5)
 LANGUAGE plpgsql
AS $function$
declare    _score           numeric(10,5);
           _text_tokens     bigint[];
           _search_tokens   bigint[];
begin
    _score := 0;
    select similarity(_text, _query) into _score;
    -- raise notice 'begin text: % , similarity %',_text, _score;
    select array_agg(token[1]) into _text_tokens
        from (select regexp_matches(_text, '([0-9]{2,})', 'g') token) t where array_length(t.token, 1) > 0;
    select array_agg(token[1])  into _search_tokens 
        from (select regexp_matches(_query, '([0-9]{2,})', 'g') token) t where array_length(t.token, 1) > 0;
    -- raise notice '%  % %', _text_tokens, _search_tokens, _search_tokens is null;
    if _text_tokens is not null and 
        _search_tokens is not null then 
        if arraycontains(_text_tokens, array[_search_tokens[1]]) then 
            _score = _score + 0.5 ;
        elsif array_length(_search_tokens, 1) > 1 and 
           arraycontains(_text_tokens, array[_search_tokens[2]]) then 
            _score = _score + 0.1;
        end if;
    end if;
    -- raise notice 'end text: % , similarity %',_text, _score;
    if _score > 1 then 
        return 1;
    else 
        return _score;
    end if;
end;
$function$ immutable
;
```

### 搜索语句及结果
```sql
=# select name
-#     from tmp_tb1 
-#     where name % 'ME 3600X 24TS-M 2.5G Base Bundle, K9, AES, Built-in 6x1G'::text
-#     order by similarity(name, 'ME 3600X 24TS-M 2.5G Base Bundle, K9, AES, Built-in 6x1G'::text ) desc limit 100;
                      name
-------------------------------------------------
 ME-3600X-24TS-M
 ME 3600X-24CX-M
 ME-3600X-24FS-M
 ME 3600X 24CX
 ...
 ...
```

-- References
- https://www.postgresql.org/docs/9.4/static/textsearch.html
- https://github.com/digoal/blog/blob/8671e49eb79cc1ab94ce7cdba93959bc8d3da177/201712/20171206_01.md
- https://www.postgresql.org/docs/9.4/static/pgtrgm.html
