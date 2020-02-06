DO $$ BEGIN
  PERFORM lib.drop_function('lib', 'foreign_key_list');
END $$;
CREATE OR REPLACE FUNCTION lib.foreign_key_list(
)
returns table(
   conname TEXT,
   fk_table TEXT,
   fk_column TEXT,
   pk_table TEXT,
   pk_column TEXT
)
AS
$$
    BEGIN
    RETURN QUERY
        SELECT c.conname::TEXT, conrelid::regclass::TEXT AS "FK_Table"
            ,CASE WHEN pg_get_constraintdef(c.oid) LIKE 'FOREIGN KEY %' THEN substring(pg_get_constraintdef(c.oid), 14, position(')' in pg_get_constraintdef(c.oid))-14) END AS "FK_Column"
            ,CASE WHEN pg_get_constraintdef(c.oid) LIKE 'FOREIGN KEY %' THEN substring(pg_get_constraintdef(c.oid), position(' REFERENCES ' in pg_get_constraintdef(c.oid))+12, position('(' in substring(pg_get_constraintdef(c.oid), 14))-position(' REFERENCES ' in pg_get_constraintdef(c.oid))+1) END AS "PK_Table"
            ,CASE WHEN pg_get_constraintdef(c.oid) LIKE 'FOREIGN KEY %' THEN substring(pg_get_constraintdef(c.oid), position('(' in substring(pg_get_constraintdef(c.oid), 14))+14, position(')' in substring(pg_get_constraintdef(c.oid), position('(' in substring(pg_get_constraintdef(c.oid), 14))+14))-1) END AS "PK_Column"
        FROM   pg_constraint c
                 JOIN   pg_namespace n ON n.oid = c.connamespace
        WHERE  contype IN ('f', 'p ')
          AND pg_get_constraintdef(c.oid) LIKE 'FOREIGN KEY %'
        ORDER BY pg_get_constraintdef(c.oid), conrelid::regclass::text, contype DESC;
    END
$$
language plpgsql
STABLE;
