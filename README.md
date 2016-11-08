## TQL

[![Build Status](https://travis-ci.org/nginformatica/ng-tql.svg?branch=master)](https://travis-ci.org/nginformatica/ng-tql)
![Language: TQL](https://img.shields.io/badge/language-tql-blue.svg?style=flat)

> A domain specific language that extends SQL and allows visual metaprogramming

TQL is a small language that extends SQL and integrates with [`ng-sql-parser`](https://github.com/nginformatica/ng-sql-parser) and `query-wizard` (that will still be open-sourced). The language has support to a small set of type-inference of literal types and a small type-checker. It receives TQL, processes it by GUI and generates valid SQL as output. Please note that this repository contains only the grammar definitions and the source for TQL, not the integration per se (at least not for now). TQL was built to make easy the integration between the front-end user and TOTVS Protheus ERP.

### Type System

TQL has a small type-system and an inference model. It is able to deduce the type of **every** expression placed (all expressions are literals). All type declarations are optional.

```cobol
Declare Val: Int
Declare Name: VarChar
Declare When: Date
Declare Age: Nat
Declare Trigger: Bool
Declare Table: Symbol
Declare Id: Char(32)
Declare Limit: Range(10, 100)
Declare Price: Double
```

### Default Values

Use `:=` to create default values, such as:

```cobol
Declare Age: Nat := 18
```

### Pictures

Pictures are made to tell how to display the data (on Protheus and on Query Wizard).

```cobol
Declare Price: Double Picture '99.99' := 13.87
```

### Range Types

Range types allow you to restrict data in ranges

```cobol
Declare Age: Range(18, 60) := 10
Declare CPF: Char(11)
```

### DateTime

You can use formats like:

```cobol
Declare BirthDay := 4 Dec 1996
Declare EventTime := 7 Nov 2016 13:45
```

### Descriptions

Specify information about the field within `{` and `}`.

```cobol
Declare Age: Nat Picture '99' := 18 { The user age to search }
```

## Usage

### Install

- Yarn: `yarn add ng-tql`
- npm: `npm install ng-tql`

### Compile from sources

Using Yarn:

```shell
yarn
yarn compile
yarn test
```

Using npm:

```shell
npm install
npm run compile
npm test
```

### Using with ES6

```javascript
import { parse } from 'ng-tql';

try {
    console.log(parse('Declare Age: Nat := 18'));
} catch (e) {
    console.log(e);
}
```

## Credits

TQL is written with [PegJS](http://pegjs.org/) by [Marcelo Camargo](https://github.com/haskellcamargo) and open-source under MIT License.

![NGi](https://avatars1.githubusercontent.com/u/21263692?v=3&s=200)
