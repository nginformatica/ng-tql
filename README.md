### TQL

> A domain specific language that extends SQL and allows visual metaprogramming

TQL is a small language that extends SQL and integrates with `ng-sql-parser` and `query-wizard` (that will still be open-sourced). The language has support to a small set of type-inference of literal types (dates, strings, numbers and booleans) and a small type-checker. It receives TQL, processes it by GUI and generates valid SQL as output. Please note that this repository contains only the grammar definitions and the source for TQL, not the integration per se (at least, not now).

All TQL code inside SQL is inside `{{` and `}}`. You specify the field-identifier (with `@`), descriptions, possible types, the default value and, in some situations, a base value to allow compilation. For example, if I'd like to ask for the user for a name to search in the database, I would do:

```sql
SELECT U.NAME, U.EMAIL, U.AGE, U.FAVORITE_CAT_NAME
FROM   TB_USERS U
WHERE  U.NAME = RTRIM(LTRIM({{@Username Default '' Describe 'The name of the user to search'}}))
```

Based on the default value, the name is being inferred as a string, but you could be clear doing `As String` inside it.

TQL is written with [PegJS](http://pegjs.org/) and open-source under MIT License.
