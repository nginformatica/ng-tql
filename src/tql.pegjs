{
  var isDouble = function (n) {
    return n % 1 !== 0;
  };

  var checkDuplication = function (list) {
    var found = [];
    list.forEach(function (item) {
      if (found.indexOf(item.name.toUpperCase()) !== -1) {
        throw new Error('Field `' + item.name.toUpperCase() + "' declared twice");
      }

      found.push(item.name.toUpperCase());
    });
    return list;
  };

  var valTypeToString = function (decl) {
    switch (decl.value.type) {
      case 'number':
        var subtype = isDouble(decl.value.value) ? 'double' : 'int';
        return subtype + '(' + decl.value.value + ')';
      case 'string':
        return 'string(' + decl.value.value.length + ')';
      default:
        return decl.value.value.toString();
    }
  };

  var typeToString = function (type) {
    switch (type[0]) {
      case 'char':
        return 'char(' + type[1].size + ')';
      case 'range':
        return 'range(' + type[1].from + ', ' + type[1].to + ')';
      default:
        return type[0];
    }
  };

  var typeChecker = function (decl) {
    // Unable to infer type because neither type nor value were informed
    if (null === decl.type && null === decl.value) {
      throw new TypeError('Cannot infer type of free variable ' + decl.name);
    }

    // When only type declaration was provided
    if (null === decl.value && null !== decl.type) {
      return decl;
    }

    // When no type was provided, but there is a default value
    // Reassign variable type to value type
    if (null === decl.type && null !== decl.value) {
      switch (decl.value.type) {
        case 'number':
          decl.type = [isDouble(decl.value.value) ? 'double' : 'int'];
          break;
        case 'symbol':
          decl.type = ['symbol'];
          break;
        case 'string':
          decl.type = ['varchar'];
          break;
        case 'bool':
          decl.type = ['bool'];
          break;
      }

      return decl;
    }

    // When both types are declared, check whether right matches left
    switch (decl.type[0]) {
      case 'int':
        if ('number' === decl.value.type && !isDouble(decl.value.value)) {
          return decl;
        }
        break;
      case 'varchar':
        if ('string' === decl.value.type) {
          return decl;
        }
        break;
      case 'nat':
        if ('number' === decl.value.type && decl.value.value >= 0) {
          return decl;
        }
        break;
      case 'bool':
        if ('bool' === decl.value.type) {
          return decl;
        }
        break;
      case 'symbol':
        if ('symbol' === decl.value.type) {
          return decl;
        }
        break;
      case 'char':
        if ('string' === decl.value.type && decl.value.value.length <= decl.type[1].size) {
          return decl;
        }
        break;
      case 'range':
        if ('number' === decl.value.type
          && decl.value.value >= decl.type[1].from
          && decl.value.value <= decl.type[1].to) {
          return decl;
        }
        break;
      case 'double':
        if ('number' === decl.value.type) {
          return decl;
        }
        break;
    }

    throw new TypeError("Value of type `" + valTypeToString(decl) + "' is not " +
      "assignable to field of type `" + typeToString(decl.type) + "'");
  };
}

TQLCode 'TQL code'
  = fields:FieldDecl* _ {
    var declarations = fields.map(typeChecker);
    checkDuplication(declarations);
    return declarations;
  }

FieldDecl 'field declaration'
  = _ 'declare'i __
    name:Ident
    type:TypeDecl?
    picture:Picture?
    value:Assignment?
    description:Description? {
    return {
      kind: 'FieldDecl',
      name: name,
      type: type,
      picture: picture,
      value: value,
      description: description
    }
  }

Ident 'identifier'
  = x:[_a-z]i xs:[_a-z0-9]i* {
    return [x].concat(xs).join('');
  }

Assignment 'assignment'
  = _ ':=' _ v:Value { return v; }

TypeDecl 'type declaration'
  = _ ':' _ type:Type { return type; }

Type 'type'
  = 'int'i     { return ['int']; }
  / 'double'i  { return ['double']; }
  / 'varchar'i { return ['varchar']; }
  / 'date'i    { return ['date']; }
  / 'nat'i     { return ['nat']; }
  / 'bool'i    { return ['bool']; }
  / 'symbol'i  { return ['symbol']; }
  / 'char'i _ '(' _ n:Int _ ')' { return ['char', { size: n }] }
  / 'range'i _ '(' _ from:Int _ ',' _ to:Int _ ')' {
    return ['range', {
      from: from,
      to: to
    }];
  }

Picture 'picture'
  = _ 'picture'i __ s:String { return s; }

Value 'value'
  = n:Number { return { type: 'number', value: n }; }
  / i:Ident  { return { type: 'symbol', value: i }; }
  / s:String { return { type: 'string', value: s }; }
  / b:Bool   { return { type: 'bool', value: b }; }

Number 'number'
  = Double
  / Int

Int 'integer'
  = sig:[+-]? xss:[0-9]+ {
    return parseInt((sig || '') + xss.join(''), 10);
  }

Double 'double'
  = base:Int '.' rest:[0-9]+ {
    return parseFloat(base.toString() + '.' + rest.join(''));
  }

String 'string'
  = "'" chr:(!"'" w:. { return w; })* "'" { return chr.join(''); }

Bool 'bool'
  = '.t.'i { return true; }
  / '.f.'i { return false; }

Description 'description'
  = _ '{' chr:( !'}' c:. { return c; } )* '}' _ {
    return chr.join('').trim();
  }

_ 'optional whitespace'
  = [ \t\r\n]*

__ 'obligatory whitespace'
  = [ \t\r\n]+
