### TQL

> A domain specific language that extends SQL and allows visual metaprogramming

TQL is a small language that extends SQL and integrates with [`ng-sql-parser`](https://github.com/nginformatica/ng-sql-parser) and `query-wizard` (that will still be open-sourced). The language has support to a small set of type-inference of literal types (dates, strings, numbers and booleans) and a small type-checker. It receives TQL, processes it by GUI and generates valid SQL as output. Please note that this repository contains only the grammar definitions and the source for TQL, not the integration per se (at least, not now). TQL was built to make easy the integration between the front-end user and TOTVS Protheus ERP.

All TQL code inside SQL is inside `{{` and `}}`. You specify the field-identifier (with `@`), descriptions, possible types, the default value and, in some situations, a base value to allow compilation. For example, if I'd like to ask for the user for a name to search in the database, we would do:

```sql
SELECT U.NAME, U.EMAIL, U.AGE, U.FAVORITE_CAT_NAME
FROM   TB_USERS U
WHERE  U.NAME = RTRIM(LTRIM({{@Username Default '' Describe 'The name of the user to search'}}))
```

Based on the default value, the name is being inferred as a string, but you could be clear doing `As String` inside it.

TQL is written with [PegJS](http://pegjs.org/) and open-source under MIT License.

![NGi](https://avatars1.githubusercontent.com/u/21263692?v=3&s=200)
<div>
  <img src="https://www.totvs.com/assets/images/logo-responsivo.png" width=200 />
</div>
