const expect = require('chai').expect;
const tql = require('../dist/tql');

describe('Parser specification', () => {
    describe('Inferred type declarations', () => {
        it('Shouldn\'t support free-type variables', () => {
            expect(() => tql.parse('Declare Age')).to.throw(TypeError, /Cannot infer type of free variable/);
        });

        it('Should infer integers', () => {
            const ast = tql.parse('Declare Age := 18');
            expect(ast[0].type[0]).to.be.equal('int');
        });

        it('Should infer doubles', () => {
            const ast = tql.parse('Declare Price := 10.5');
            expect(ast[0].type[0]).to.be.equal('double');
        });

        it('Should infer symbols', () => {
            const ast = tql.parse('Declare Table := STJT30');
            expect(ast[0].type[0]).to.be.equal('symbol');
        });

        it('Should infer any char(*) to varchar', () => {
            const ast = tql.parse('Declare Username := \'Admin\'');
            expect(ast[0].type[0]).to.be.equal('varchar');
        });

        it('Should infer booleans', () => {
            const ast = tql.parse('Declare ShouldUpdate := .F.');
            expect(ast[0].type[0]).to.be.equal('bool');
        });
    });

    describe('Type declarations' , () => {
        it('Should allow every type to have defined variables without value', () => {
            const source = [
                'Declare Val: Int',
                'Declare Name: VarChar',
                'Declare When: Date',
                'Declare Age: Nat',
                'Declare Trigger: Bool',
                'Declare Table: Symbol',
                'Declare Id: Char(32)',
                'Declare Limit: Range(10, 100)',
                'Declare Price: Double'
            ];

            tql.parse(source.join('\n'));
        });

        it('Should restrict negative numbers on Nat', () => {
            expect(() => {
                tql.parse('Declare Age: Nat := -10');
            }).to.throw(TypeError, /Value of type `int\(-10\)' is not assignable to field of type `nat'/);
        });

        it('Should restrict max length of string in Char(*)', () => {
            expect(() => {
                tql.parse('Declare Val: Char(10) := \'Trixie Mattel\'');
            }).to.throw(TypeError, /Value of type `string\(13\)' is not assignable to field of type `char\(10\)'/);
        });

        it('Should restrict max number in Range(*, *)', () => {
            expect(() => {
                tql.parse('Declare Val: Range(1, 10) := 11');
            }).to.throw(TypeError, /Value of type `int\(11\)' is not assignable to field of type `range\(1, 10\)'/);
        });

        it('Should restrict min number in Range(*, *)', () => {
            expect(() => {
                tql.parse('Declare Val: Range(1, 10) := -20');
            }).to.throw(TypeError, /Value of type `int\(-20\)' is not assignable to field of type `range\(1, 10\)'/);
        });
    });

    describe('Duplication', () => {
        it('Doesn\'t allow duplicated fields', () => {
            const source = [
                'Declare age := 18',
                'Declare Age := .T.'
            ];

            expect(() => {
                tql.parse(source.join(''));
            }).to.throw(Error, /Field `AGE' declared twice/);
        });
    });

    describe('Picture', () => {
        it('Allows pictures after type declaration', () => {
            tql.parse('Declare Price: Nat Picture \'99.99\' := 10');
        });

        it('Allows pictures after name declaration', () => {
            tql.parse('Declare Price Picture \'99.99\' := 10');
        });
    });

    describe('Description', () => {
        it('Allows descriptions to be placed after all', () => {
            tql.parse('Declare Table: Symbol := STJT30 { Table to select }');
        });

        it('Allows descriptions with line break', () => {
            tql.parse('Declare Table: Symbol := STJT30 { Table\n to select }');
        });
    });

    describe('Dates', () => {
        it('Should allow a date to be assigned to Date', () => {
            tql.parse('Declare BirthDay: Date := 4 Dec 1996');
        });

        it('Should reject negative day', () => {
            expect(() => {
                tql.parse('Declare BirthDay := -4 Dec 1996');
            }).to.throw(Error, /Day of date must be positive/);
        });

        it('Should reject negative year', () => {
            expect(() => {
                tql.parse('Declare BirthDay := 4 Dec -1996');
            }).to.throw(Error, /Year of date must be positive/);
        });
    });
});
