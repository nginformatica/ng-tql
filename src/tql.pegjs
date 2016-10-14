/**
 * Grammar for (T)emplate (Q)uery (L)anguage
 * @author Marcelo Camargo
 * @since 2015/10/08
 */
{
  var TypeChecker = {
    assert: function(t1, t2) {
      if (t1 !== t2) {
        throw new TypeError("Type [" + t2 + "] is not assignable to [" + t1 + "]");
      }
    }
  };
}

Start
  = Template

Template "template"
  = f:FieldDecl t:(__ t:Type { return t; })? _ d:DefaultValue? _ ds:Describe? _ b:BaseValue? _ p:Picture? {
    var expect, currentType;
    var needsCheck = true;
    var is = function(x) { return x !== null; };

    // Type inference implementation

    if (!is(t) && is(d)) {
      /**
       * When no expectations, but value defined, expectations become of the
       * type of the defined value.
       * Infer EXPECTED on VALUE.
       */
      currentType = typeof d;
      expect      = typeof d;
    } else if (is(t) && is(d)) {
      /**
       * When there are expectations and a value, type check them.
       */
      currentType = typeof d;
      expect      = t;
    } else if (!is(t) && !is(d)) {
      /**
       * When no value and no typecheck, auto-infer string.
       */
      expect = "string";
      needsCheck  = false;
      // Auto-infer
    } else if (is(t) && !is(d)) {
      /**
       * When expectations, but no value, set the expectations and skip the
       * type check.
       */
      expect     = t;
      needsCheck = false;
    }

    needsCheck && TypeChecker.assert(expect, currentType);

    return {
      field: f,
      type: expect,
      default: d,
      base: b || "_",
      describe: ds || "",
      picture: p || ""
    };
  }

/* Declarations */
FieldDecl "field declaration"
  = "@" name:Identifier {
    return name.value;
  }

Type "type declaration"
  = AsToken __ t:SupportedType {
    return t;
  }

SupportedType "type"
  = NumberType  { return "number"; }
  / StringType  { return "string"; }
  / DateType    { return "object"; }

DefaultValue "default value"
  = DefaultToken __ e:Expr {
    return e;
  }

Describe "describe value"
  = DescribeToken __ e:String {
    return e;
  }

BaseValue "base value"
  = BaseToken __ e:Expr {
    return e;
  }

Picture "picture"
  = PictureToken __ s:String {
    return s;
  }

Expr "expression"
  = Number
  / String
  / Date

Number "number"
  = m:( "+" / "-" )? x:[0-9]+ xs:("." xs:[0-9]+ { return xs; })? {
    var op = m || "";

    return xs
      ? parseFloat(op + x.join("") + "." + xs.join(""))
      : parseInt(op + x.join(""));
  }

String "string"
  = '""' {
    return "";
  }
  / '"' str:(!UnescapedQuote AnyChar)* last:UnescapedQuote {
    var r = "";
    for (var c in str) {
      r += str[c][1];
    }
    return r + last;
  }

Date "date"
  = "#" year:[0-9]+ "/" month:[0-9]+ "/" day:[0-9]+ _ time:Time? {
    var record = function(n) {
      return parseInt(n.join(""));
    };

    return time
      ? new Date(record(year), record(month) - 1, record(day), time.hour, time.minute, time.second)
      : new Date(record(year), record(month) - 1, record(day));
  }

Time "time"
  = "#" hour:[0-9]+ ":" minute:[0-9]+ ":" second:[0-9]+ {
    var record = function(n) {
      return parseInt(n.join(""));
    };

    return {
      hour: record(hour),
      minute: record(minute),
      second: record(second)
    };
  }

UnescapedQuote
  = last:[^\\] '"' { return last; }

AnyChar
  = .

/* Keywords */

Keyword "keyword"
  = AsToken
  / BaseToken
  / DefaultToken
  / DescribeToken

AsToken "as"
  = "as"i !IdentRest

BaseToken "base"
  = "base"i !IdentRest

DefaultToken "default"
  = "default"i !IdentRest

DescribeToken "describe"
  = "describe"i !IdentRest

PictureToken "picture"
  = "picture"i !IdentRest

/* Type keywords */
NumberType "number type"
  = "number"i !IdentRest

StringType "string type"
  = "string"i !IdentRest

DateType "date type"
  = "date"i !IdentRest

/* Identifier */
Identifier "identifier"
  = !Keyword name:IdentName {
    return name;
  }

IdentName
  = x:IdentStart xs:IdentRest* {
    return {
      type: "Identifier",
      value: [x].concat(xs).join("")
    };
  }

IdentStart
  = [a-zA-Z_\x7f-\xff]

IdentRest
  = [a-zA-Z0-9_\x7f-\xff]

/* Whitespace and newline */
_ "optional whitespace"
  = [ \t]*

__ "mandatory whitespace"
  = [ \t]+
