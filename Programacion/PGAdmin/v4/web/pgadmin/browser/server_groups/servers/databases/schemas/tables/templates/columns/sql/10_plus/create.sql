{% import 'columns/macros/security.macros' as SECLABEL %}
{% import 'columns/macros/privilege.macros' as PRIVILEGE %}
{% import 'macros/variable.macros' as VARIABLE %}
{% import 'types/macros/get_full_type_sql_format.macros' as GET_TYPE %}
{###  Add column ###}
{% if data.name and  data.cltype %}
ALTER TABLE {{conn|qtIdent(data.schema, data.table)}}
    ADD COLUMN {{conn|qtIdent(data.name)}} {% if is_sql %}{{data.displaytypname}}{% else %}{{ GET_TYPE.CREATE_TYPE_SQL(conn, data.cltype, data.attlen, data.attprecision, data.hasSqrBracket) }}{% endif %}{% if data.collspcname %}
 COLLATE {{data.collspcname}}{% endif %}{% if data.attnotnull %}
 NOT NULL{% endif %}{% if data.defval is defined and data.defval is not none and data.defval != '' %}
 DEFAULT {{data.defval}}{% endif %}{% if data.colconstype == 'i' %}{% if data.attidentity and data.attidentity == 'a' %} GENERATED ALWAYS AS IDENTITY{% elif data.attidentity and data.attidentity == 'd' %} GENERATED BY DEFAULT AS IDENTITY{% endif %}
{% if data.seqincrement or data.seqcycle or data.seqincrement or data.seqstart or data.seqmin or data.seqmax or data.seqcache %} ( {% endif %}
{% if data.seqcycle is defined and data.seqcycle %}
CYCLE {% endif %}{% if data.seqincrement is defined and data.seqincrement|int(-1) > -1 %}
INCREMENT {{data.seqincrement|int}} {% endif %}{% if data.seqstart is defined and data.seqstart|int(-1) > -1%}
START {{data.seqstart|int}} {% endif %}{% if data.seqmin is defined and data.seqmin|int(-1) > -1%}
MINVALUE {{data.seqmin|int}} {% endif %}{% if data.seqmax is defined and data.seqmax|int(-1) > -1%}
MAXVALUE {{data.seqmax|int}} {% endif %}{% if data.seqcache is defined and data.seqcache|int(-1) > -1%}
CACHE {{data.seqcache|int}} {% endif %}
{% if data.seqincrement or data.seqcycle or data.seqincrement or data.seqstart or data.seqmin or data.seqmax or data.seqcache %}){% endif %}
{% endif %}{% endif %};

{###  Add comments ###}
{% if data and data.description %}
COMMENT ON COLUMN {{conn|qtIdent(data.schema, data.table, data.name)}}
    IS {{data.description|qtLiteral}};

{% endif %}
{###  Add variables to column ###}
{% if data.attoptions %}
ALTER TABLE {{conn|qtIdent(data.schema, data.table)}}
    {{ VARIABLE.SET(conn, 'COLUMN', data.name, data.attoptions) }}

{% endif %}
{###  ACL ###}
{% if data.attacl %}
{% for priv in data.attacl %}
{{ PRIVILEGE.APPLY(conn, data.schema, data.table, data.name, priv.grantee, priv.without_grant, priv.with_grant) }}
{% endfor %}
{% endif %}
{###  Security Lables ###}
{% if data.seclabels %}
{% for r in data.seclabels %}
{{ SECLABEL.APPLY(conn, 'COLUMN',data.schema, data.table, data.name, r.provider, r.label) }}
{% endfor %}
{% endif %}
